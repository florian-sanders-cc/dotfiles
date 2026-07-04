#!/usr/bin/env node
// pw-broker: host-side broker that runs sandbox-submitted Playwright/vitest
// commands in the project's Docker container (see playwright-docker skill).
//
// Trust boundary: the sandboxed agent can only write queue/requests/ and read
// queue/. Everything here runs UNSANDBOXED, so this file must never live under
// a nono-granted subtree, and the systemd unit / CLI wrappers exec the
// immutable nix-store copy of it — an agent edit of this source only takes
// effect after a human rebuild. trusted.json sits outside queue/ so the
// sandbox can neither read nor write the pin store.
//
// Subcommands:
//   pw-broker daemon          run the queue-processing daemon (systemd unit)
//   pw-broker trust [dir]     pin sha256 of every playwright-docker/ file
//   pw-broker untrust [dir]   remove a project's pins
//   pw-broker list            show trusted projects and live pin status

import { spawn, execFile, execFileSync } from "node:child_process";
import { createHash } from "node:crypto";
import fs from "node:fs";
import os from "node:os";
import path from "node:path";

const ROOT = path.join(os.homedir(), ".local/state/pw-broker");
const TRUSTED = path.join(ROOT, "trusted.json");
const QUEUE = path.join(ROOT, "queue");
const REQUESTS = path.join(QUEUE, "requests");
const RUNS = path.join(QUEUE, "runs");
const HEARTBEAT = path.join(QUEUE, "daemon.json");

const PW_DIR = "playwright-docker";
const COMPOSE_FILE = "compose.playwright.yaml";
const CONTAINER_PREFIX = "pwbroker-";
const HEARTBEAT_MS = 5_000;
const RESCAN_MS = 5_000;
const KILL_GRACE_MS = 10_000;
const MIN_TIMEOUT_SECS = 1;
const MAX_TIMEOUT_SECS = 7_200;
const RUN_RETENTION_MS = 7 * 24 * 3600_000;
const TMP_RETENTION_MS = 3600_000;

// Request filenames are `<id>.json`; the id doubles as the run dir name, so
// restrict it to a path-safe charset (no dots — rejects "..").
const ID_RE = /^[A-Za-z0-9]+-[0-9a-f]{8}$/;

interface Result {
  version: 1;
  id: string;
  status: "ok" | "refused" | "timeout" | "error" | "interrupted";
  exitCode: number;
  timedOut: boolean;
  startedAt: string;
  finishedAt: string;
  durationMs: number;
  message: string;
}

function log(msg: string): void {
  console.log(`pw-broker: ${msg}`);
}

/** Same-directory tmp+rename so readers never observe partial JSON. */
function writeJsonAtomic(file: string, value: unknown, mode?: number): void {
  const tmp = path.join(path.dirname(file), `.tmp-${path.basename(file)}-${process.pid}`);
  fs.writeFileSync(tmp, JSON.stringify(value, null, 2) + "\n", mode !== undefined ? { mode } : {});
  fs.renameSync(tmp, file);
}

function readJson(file: string): any {
  return JSON.parse(fs.readFileSync(file, "utf8"));
}

function sha256(file: string): string {
  return createHash("sha256").update(fs.readFileSync(file)).digest("hex");
}

function readTrusted(): { version: 1; projects: Record<string, { trustedAt: string; files: Record<string, string> }> } {
  try {
    return readJson(TRUSTED);
  } catch {
    return { version: 1, projects: {} };
  }
}

function writeTrusted(store: ReturnType<typeof readTrusted>): void {
  fs.mkdirSync(ROOT, { recursive: true });
  writeJsonAtomic(TRUSTED, store, 0o600);
}

/**
 * Enumerate the playwright-docker/ entries of a project the way both `trust`
 * and the daemon must see them: top-level regular files only. Anything else
 * (subdirectory, symlink, socket…) is reported so callers can refuse — a
 * symlink could point outside the project and a subdirectory could smuggle
 * compose `include:` targets that pins would not cover.
 */
function scanPwDir(projectReal: string): { files: string[]; irregular: string[] } {
  const dir = path.join(projectReal, PW_DIR);
  const files: string[] = [];
  const irregular: string[] = [];
  for (const entry of fs.readdirSync(dir, { withFileTypes: true })) {
    if (entry.isFile() && !entry.isSymbolicLink()) files.push(entry.name);
    else irregular.push(entry.name);
  }
  files.sort();
  return { files, irregular };
}

// ---------------------------------------------------------------------------
// trust / untrust / list
// ---------------------------------------------------------------------------

function resolveProjectArg(arg: string | undefined): string {
  const dir = path.resolve(arg ?? process.cwd());
  const real = fs.realpathSync(dir);
  if (!fs.statSync(real).isDirectory()) throw new Error(`not a directory: ${real}`);
  return real;
}

function cmdTrust(arg: string | undefined): void {
  const project = resolveProjectArg(arg);
  const pwDir = path.join(project, PW_DIR);
  if (!fs.existsSync(path.join(pwDir, COMPOSE_FILE))) {
    console.error(`pw-broker: ${pwDir}/${COMPOSE_FILE} not found — run the playwright-docker-setup skill first`);
    process.exit(1);
  }
  const { files, irregular } = scanPwDir(project);
  if (irregular.length > 0) {
    console.error(`pw-broker: refusing to trust — ${PW_DIR}/ contains non-regular entries: ${irregular.join(", ")}`);
    process.exit(1);
  }
  const pins: Record<string, string> = {};
  for (const name of files) pins[`${PW_DIR}/${name}`] = sha256(path.join(pwDir, name));

  const store = readTrusted();
  store.projects[project] = { trustedAt: new Date().toISOString(), files: pins };
  writeTrusted(store);

  log(`trusted ${project}`);
  for (const [file, hash] of Object.entries(pins)) log(`  pinned ${file} sha256=${hash}`);
  log(`re-run \`pw-broker trust\` after any change to ${PW_DIR}/`);
}

function cmdUntrust(arg: string | undefined): void {
  const project = resolveProjectArg(arg);
  const store = readTrusted();
  if (!store.projects[project]) {
    console.error(`pw-broker: not trusted: ${project}`);
    process.exit(1);
  }
  delete store.projects[project];
  writeTrusted(store);
  log(`untrusted ${project}`);
}

function cmdList(): void {
  const store = readTrusted();
  const projects = Object.keys(store.projects).sort();
  if (projects.length === 0) {
    log("no trusted projects");
    return;
  }
  for (const project of projects) {
    console.log(project);
    for (const [file, hash] of Object.entries(store.projects[project].files)) {
      let status = "ok";
      const abs = path.join(project, file);
      try {
        if (sha256(abs) !== hash) status = "CHANGED";
      } catch {
        status = "missing";
      }
      console.log(`  ${status.padEnd(7)} ${file}`);
    }
  }
}

// ---------------------------------------------------------------------------
// daemon
// ---------------------------------------------------------------------------

/** null = valid; string = refusal message shown to the agent. */
function validateAgainstPins(projectReal: string): string | null {
  const trustCmd = `pw-broker trust ${projectReal}`;
  const pinned = readTrusted().projects[projectReal];
  if (!pinned) return `project is not trusted — ask the human to run on the host: ${trustCmd}`;

  let scan: ReturnType<typeof scanPwDir>;
  try {
    scan = scanPwDir(projectReal);
  } catch (e: any) {
    return `cannot read ${PW_DIR}/: ${e?.message ?? e}`;
  }
  if (scan.irregular.length > 0) {
    return `${PW_DIR}/ contains non-regular entries (${scan.irregular.join(", ")}) — remove them, then ask the human to re-run: ${trustCmd}`;
  }
  const current = scan.files.map((f) => `${PW_DIR}/${f}`);
  const pinnedFiles = Object.keys(pinned.files).sort();
  if (JSON.stringify(current) !== JSON.stringify(pinnedFiles)) {
    return `${PW_DIR}/ file set changed since trust (pinned: ${pinnedFiles.join(", ")}; now: ${current.join(", ")}) — ask the human to re-run: ${trustCmd}`;
  }
  for (const [file, hash] of Object.entries(pinned.files)) {
    const abs = path.join(projectReal, file);
    // realpath containment: a pinned path must not resolve outside the project
    let real: string;
    try {
      real = fs.realpathSync(abs);
    } catch {
      return `${file} disappeared — ask the human to re-run: ${trustCmd}`;
    }
    if (real !== abs && !real.startsWith(projectReal + path.sep)) {
      return `${file} resolves outside the project (${real}) — refused`;
    }
    if (sha256(abs) !== hash) {
      return `${file} changed since trust — ask the human to review it and re-run on the host: ${trustCmd}`;
    }
  }
  return null;
}

function makeResult(id: string, partial: Omit<Result, "version" | "id">): Result {
  return { version: 1, id, ...partial };
}

function instantResult(id: string, status: Result["status"], exitCode: number, message: string): Result {
  const now = new Date().toISOString();
  return makeResult(id, { status, exitCode, timedOut: false, startedAt: now, finishedAt: now, durationMs: 0, message });
}

function dockerRmForce(name: string): void {
  execFile("docker", ["rm", "-f", name], () => {
    /* best effort: container may already be gone */
  });
}

class Daemon {
  private pending = new Set<string>();
  private processing = false;
  private stopping = false;
  private current: { id: string; child: ReturnType<typeof spawn> } | null = null;

  start(): void {
    fs.mkdirSync(REQUESTS, { recursive: true });
    fs.mkdirSync(RUNS, { recursive: true });
    this.startupSweep();

    const beat = () =>
      writeJsonAtomic(HEARTBEAT, { pid: process.pid, startedAt: this.startedAt, beatAt: new Date().toISOString() });
    beat();
    setInterval(beat, HEARTBEAT_MS);

    // fs.watch for latency, periodic rescan as the reliability backstop
    fs.watch(REQUESTS, () => this.scanRequests());
    setInterval(() => this.scanRequests(), RESCAN_MS);
    this.scanRequests();

    process.on("SIGTERM", () => this.shutdown());
    process.on("SIGINT", () => this.shutdown());
    log(`daemon ready (queue: ${QUEUE})`);
  }

  private startedAt = new Date().toISOString();

  private startupSweep(): void {
    // Unblock clients whose run was cut short by a daemon crash/restart.
    for (const id of fs.readdirSync(RUNS)) {
      const runDir = path.join(RUNS, id);
      if (!fs.statSync(runDir).isDirectory()) continue;
      const claimed = fs.existsSync(path.join(runDir, "request.json"));
      const finished = fs.existsSync(path.join(runDir, "result.json"));
      if (claimed && !finished) {
        writeJsonAtomic(
          path.join(runDir, "result.json"),
          instantResult(id, "interrupted", 125, "broker restarted mid-run; resubmit the request"),
        );
        log(`swept interrupted run ${id}`);
      }
      const age = Date.now() - fs.statSync(runDir).mtimeMs;
      if (finished && age > RUN_RETENTION_MS) fs.rmSync(runDir, { recursive: true, force: true });
    }
    // Leaked containers from a previous life (timeout/SIGKILL races).
    execFile("docker", ["ps", "-aq", "--filter", `name=${CONTAINER_PREFIX}`], (err, stdout) => {
      if (err) return;
      for (const cid of stdout.split("\n").filter(Boolean)) dockerRmForce(cid.trim());
    });
    // Abandoned client tmp files.
    for (const name of fs.readdirSync(REQUESTS)) {
      if (!name.startsWith(".tmp-")) continue;
      const file = path.join(REQUESTS, name);
      if (Date.now() - fs.statSync(file).mtimeMs > TMP_RETENTION_MS) fs.rmSync(file, { force: true });
    }
  }

  private scanRequests(): void {
    let names: string[];
    try {
      names = fs.readdirSync(REQUESTS);
    } catch {
      return;
    }
    for (const name of names) {
      if (!name.endsWith(".json") || name.startsWith(".tmp-")) continue;
      const id = name.slice(0, -".json".length);
      if (ID_RE.test(id)) this.pending.add(id);
      else {
        log(`dropping request with invalid id: ${name}`);
        fs.rmSync(path.join(REQUESTS, name), { force: true });
      }
    }
    void this.processQueue();
  }

  private async processQueue(): Promise<void> {
    if (this.processing || this.stopping) return;
    this.processing = true;
    try {
      while (this.pending.size > 0 && !this.stopping) {
        const id = [...this.pending].sort()[0]; // FIFO: ids sort by timestamp
        this.pending.delete(id);
        await this.processRequest(id);
      }
    } finally {
      this.processing = false;
    }
  }

  private async processRequest(id: string): Promise<void> {
    const requestFile = path.join(REQUESTS, `${id}.json`);
    const runDir = path.join(RUNS, id);

    // The daemon owns runs/<id>: creating it ourselves (and refusing if it
    // already exists) is what makes agent symlink-swap games impossible.
    try {
      fs.mkdirSync(runDir);
    } catch {
      log(`refusing ${id}: runs/${id} already exists`);
      fs.rmSync(requestFile, { force: true });
      return; // client unblocks via its own deadline
    }
    try {
      fs.renameSync(requestFile, path.join(runDir, "request.json")); // atomic claim
    } catch {
      fs.rmdirSync(runDir); // request vanished (client cancelled) — undo
      return;
    }

    const resultFile = path.join(runDir, "result.json");
    let request: any;
    try {
      request = readJson(path.join(runDir, "request.json"));
    } catch (e: any) {
      writeJsonAtomic(resultFile, instantResult(id, "error", 125, `unreadable request: ${e?.message ?? e}`));
      return;
    }

    const refusal = this.validateRequest(id, request);
    if (refusal) {
      const [status, exitCode, message] = refusal;
      writeJsonAtomic(resultFile, instantResult(id, status, exitCode, message));
      log(`${status} ${id}: ${message}`);
      return;
    }

    const projectReal = fs.realpathSync(request.project);
    const timeoutSecs = Math.min(MAX_TIMEOUT_SECS, Math.max(MIN_TIMEOUT_SECS, Math.trunc(request.timeoutSecs)));
    await this.execute(id, projectReal, request.argv, timeoutSecs, resultFile, path.join(runDir, "run.log"));
  }

  private validateRequest(id: string, request: any): ["refused" | "error", number, string] | null {
    if (request?.version !== 1) return ["error", 125, `unsupported request version: ${request?.version}`];
    if (request.id !== id) return ["error", 125, "request id does not match its filename"];
    if (!Array.isArray(request.argv) || request.argv.length === 0 || !request.argv.every((a: unknown) => typeof a === "string"))
      return ["error", 125, "argv must be a non-empty array of strings"];
    if (typeof request.timeoutSecs !== "number" || !Number.isFinite(request.timeoutSecs))
      return ["error", 125, "timeoutSecs must be a finite number"];
    if (typeof request.project !== "string" || !path.isAbsolute(request.project))
      return ["error", 125, "project must be an absolute path"];

    let projectReal: string;
    try {
      projectReal = fs.realpathSync(request.project);
      if (!fs.statSync(projectReal).isDirectory()) throw new Error("not a directory");
    } catch {
      return ["error", 125, `project directory not found: ${request.project}`];
    }
    if (!fs.existsSync(path.join(projectReal, PW_DIR, COMPOSE_FILE)))
      return [
        "refused",
        126,
        `${PW_DIR}/${COMPOSE_FILE} not found in ${projectReal} — scaffold it with the playwright-docker-setup skill (host-side), then ask the human to run: pw-broker trust ${projectReal}`,
      ];

    const pinRefusal = validateAgainstPins(projectReal);
    if (pinRefusal) return ["refused", 126, pinRefusal];
    return null;
  }

  private execute(
    id: string,
    project: string,
    argv: string[],
    timeoutSecs: number,
    resultFile: string,
    logFile: string,
  ): Promise<void> {
    return new Promise((resolve) => {
      const startedAt = new Date().toISOString();
      const started = Date.now();
      const containerName = `${CONTAINER_PREFIX}${id}`;
      const composePath = path.join(project, PW_DIR, COMPOSE_FILE);
      const logFd = fs.openSync(logFile, "a");

      log(`run ${id}: [${argv.join(" ")}] in ${project} (timeout ${timeoutSecs}s)`);
      // Agent argv sits strictly after the `playwright` service name, so it is
      // always parsed as the container command — it cannot inject compose flags.
      const child = spawn(
        "docker",
        ["compose", "-f", composePath, "run", "--rm", "--no-deps", "--name", containerName, "playwright", ...argv],
        { cwd: project, env: process.env, stdio: ["ignore", "pipe", "pipe"] },
      );
      this.current = { id, child };

      const append = (chunk: Buffer) => fs.writeSync(logFd, chunk);
      child.stdout!.on("data", append);
      child.stderr!.on("data", append);

      let timedOut = false;
      let killTimer: NodeJS.Timeout | undefined;
      const timeoutTimer = setTimeout(() => {
        timedOut = true;
        child.kill("SIGTERM");
        // `compose run --rm` removal is CLI-side and dies with the CLI — the
        // explicit rm -f is what actually prevents a leaked container.
        dockerRmForce(containerName);
        killTimer = setTimeout(() => child.kill("SIGKILL"), KILL_GRACE_MS);
      }, timeoutSecs * 1000);

      const finish = (result: Result) => {
        clearTimeout(timeoutTimer);
        if (killTimer) clearTimeout(killTimer);
        fs.closeSync(logFd);
        this.current = null;
        writeJsonAtomic(resultFile, result);
        log(`done ${id}: ${result.status} exit=${result.exitCode} in ${result.durationMs}ms`);
        resolve();
      };
      const finishedAt = () => new Date().toISOString();
      const durationMs = () => Date.now() - started;

      child.on("error", (err) => {
        finish(
          makeResult(id, {
            status: "error",
            exitCode: 125,
            timedOut: false,
            startedAt,
            finishedAt: finishedAt(),
            durationMs: durationMs(),
            message: `failed to start docker: ${err.message}`,
          }),
        );
      });
      child.on("close", (code, signal) => {
        if (this.stopping) return; // shutdown() writes the interrupted result
        const result: Result = timedOut
          ? makeResult(id, {
              status: "timeout",
              exitCode: 124,
              timedOut: true,
              startedAt,
              finishedAt: finishedAt(),
              durationMs: durationMs(),
              message: `timed out after ${timeoutSecs}s (container killed); raise with pw-test --timeout SECS`,
            })
          : makeResult(id, {
              status: "ok",
              exitCode: code ?? 125,
              timedOut: false,
              startedAt,
              finishedAt: finishedAt(),
              durationMs: durationMs(),
              message: signal ? `container command killed by ${signal}` : "",
            });
        finish(result);
      });
    });
  }

  private shutdown(): void {
    if (this.stopping) return;
    this.stopping = true;
    log("shutting down");
    if (this.current) {
      const { id, child } = this.current;
      child.kill("SIGTERM");
      // Synchronous on purpose: process.exit() below would kill an async rm -f
      // mid-flight and leak the container until the next daemon start.
      try {
        execFileSync("docker", ["rm", "-f", `${CONTAINER_PREFIX}${id}`], { stdio: "ignore" });
      } catch {
        /* container may already be gone */
      }
      writeJsonAtomic(
        path.join(RUNS, id, "result.json"),
        instantResult(id, "interrupted", 125, "broker stopped mid-run; resubmit the request"),
      );
    }
    // Remove the heartbeat so clients fail fast instead of waiting out staleness.
    fs.rmSync(HEARTBEAT, { force: true });
    process.exit(0);
  }
}

// ---------------------------------------------------------------------------
// entry point
// ---------------------------------------------------------------------------

const USAGE = `usage: pw-broker <daemon | trust [dir] | untrust [dir] | list>`;

const [, , command, arg] = process.argv;
try {
  switch (command) {
    case "daemon":
      new Daemon().start();
      break;
    case "trust":
      cmdTrust(arg);
      break;
    case "untrust":
      cmdUntrust(arg);
      break;
    case "list":
      cmdList();
      break;
    default:
      console.error(USAGE);
      process.exit(2);
  }
} catch (e: any) {
  console.error(`pw-broker: ${e?.message ?? e}`);
  process.exit(1);
}
