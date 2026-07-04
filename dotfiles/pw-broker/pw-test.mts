#!/usr/bin/env node
// pw-test: in-sandbox client for the pw-broker daemon. Submits a "run this
// command in this project's Playwright Docker container" request over the
// file queue, blocks while streaming the live log, and exits with the
// container command's exit code — so to the caller it feels like running the
// test command directly.
//
// It only ever WRITES queue/requests/ and READS queue/runs/ — exactly the two
// grants the nono profiles give the sandbox. Everything security-relevant
// (trust pins, docker execution) happens on the host side in pw-broker.
//
// Exit codes (agents branch on these — keep in sync with the
// playwright-docker skill):
//   0..123  container command's own exit code
//   124     timed out (raise with --timeout SECS)
//   125     infra: daemon/docker down or run interrupted
//   126     refused: project not trusted / playwright-docker/ files changed

import { randomUUID } from "node:crypto";
import fs from "node:fs";
import os from "node:os";
import path from "node:path";

const QUEUE = path.join(os.homedir(), ".local/state/pw-broker/queue");
const REQUESTS = path.join(QUEUE, "requests");
const RUNS = path.join(QUEUE, "runs");
const HEARTBEAT = path.join(QUEUE, "daemon.json");

const POLL_MS = 500;
const HEARTBEAT_STALE_MS = 15_000;
const HEARTBEAT_CHECK_MS = 5_000;
const DEFAULT_TIMEOUT_SECS = 1_800;
// Client-side backstop for the pathological cases where no result will ever
// arrive (e.g. the daemon refused to claim a colliding run id).
const DEADLINE_SLACK_MS = 120_000;

const USAGE = `usage: pw-test [--project DIR] [--timeout SECS] -- <command...>
examples:
  pw-test -- pnpm test
  pw-test --timeout 600 -- pnpm -C packages/router-nested test`;

function fail(message: string, code: number): never {
  process.stderr.write(`pw-test: ${message}\n`);
  process.exit(code);
}

function parseCli(argv: string[]): { project: string; timeoutSecs: number; command: string[] } {
  let project = process.cwd();
  let timeoutSecs = DEFAULT_TIMEOUT_SECS;
  let i = 0;
  for (; i < argv.length; i++) {
    const a = argv[i];
    if (a === "--") {
      i++;
      break;
    } else if (a === "--project") project = argv[++i] ?? "";
    else if (a.startsWith("--project=")) project = a.slice("--project=".length);
    else if (a === "--timeout") timeoutSecs = parseInt(argv[++i] ?? "", 10);
    else if (a.startsWith("--timeout=")) timeoutSecs = parseInt(a.slice("--timeout=".length), 10);
    else if (a === "-h" || a === "--help") {
      console.log(USAGE);
      process.exit(0);
    } else fail(`unknown argument '${a}' (command goes after --)\n${USAGE}`, 2);
  }
  const command = argv.slice(i);
  if (command.length === 0) fail(`missing command\n${USAGE}`, 2);
  if (!Number.isFinite(timeoutSecs) || timeoutSecs < 1) fail("--timeout must be a positive number of seconds", 2);
  return { project, timeoutSecs, command };
}

function heartbeatFresh(): boolean {
  try {
    const beat = JSON.parse(fs.readFileSync(HEARTBEAT, "utf8"));
    return Date.now() - Date.parse(beat.beatAt) < HEARTBEAT_STALE_MS;
  } catch {
    return false;
  }
}

function sleep(ms: number): Promise<void> {
  return new Promise((r) => setTimeout(r, ms));
}

const { project, timeoutSecs, command } = parseCli(process.argv.slice(2));

let projectReal: string;
try {
  projectReal = fs.realpathSync(project);
  if (!fs.statSync(projectReal).isDirectory()) throw new Error();
} catch {
  fail(`project directory not found: ${project}`, 2);
}

if (!heartbeatFresh()) {
  fail("pw-broker daemon is not running — ask the human to start it: systemctl --user start pw-broker", 125);
}

// Sortable + collision-free id: UTC timestamp (ms precision) + random suffix.
const id = `${new Date().toISOString().replace(/[-:.]/g, "")}-${randomUUID().replace(/-/g, "").slice(0, 8)}`;
const requestFile = path.join(REQUESTS, `${id}.json`);
const runDir = path.join(RUNS, id);

// Same-directory tmp+rename so the daemon never reads a partial request.
const tmpFile = path.join(REQUESTS, `.tmp-${id}.json`);
fs.writeFileSync(
  tmpFile,
  JSON.stringify(
    {
      version: 1,
      id,
      project: projectReal,
      argv: command,
      timeoutSecs,
      submittedAt: new Date().toISOString(),
      clientPid: process.pid,
    },
    null,
    2,
  ) + "\n",
);
fs.renameSync(tmpFile, requestFile);

// Cancel cleanly: withdraw the request if the daemon has not claimed it yet
// (once claimed, the run continues on the host — harmless).
for (const signal of ["SIGINT", "SIGTERM"] as const) {
  process.on(signal, () => {
    fs.rmSync(requestFile, { force: true });
    process.exit(130);
  });
}

let logOffset = 0;
function drainLog(): void {
  let fd: number;
  try {
    fd = fs.openSync(path.join(runDir, "run.log"), "r");
  } catch {
    return; // not created yet
  }
  try {
    const buf = Buffer.alloc(64 * 1024);
    for (;;) {
      const read = fs.readSync(fd, buf, 0, buf.length, logOffset);
      if (read === 0) break;
      process.stdout.write(buf.subarray(0, read));
      logOffset += read;
    }
  } finally {
    fs.closeSync(fd);
  }
}

const deadline = Date.now() + timeoutSecs * 1000 + DEADLINE_SLACK_MS;
let lastHeartbeatCheck = Date.now();

for (;;) {
  drainLog();

  let result: any = null;
  try {
    result = JSON.parse(fs.readFileSync(path.join(runDir, "result.json"), "utf8"));
  } catch {
    /* not finished yet (writes are atomic, so a parse error means "absent") */
  }
  if (result) {
    drainLog();
    switch (result.status) {
      case "ok":
        process.exit(result.exitCode);
      case "timeout":
        fail(result.message, 124);
      case "refused":
        fail(result.message, 126);
      default: // error | interrupted | future statuses
        fail(result.message ?? `run ended with status ${result.status}`, 125);
    }
  }

  if (Date.now() - lastHeartbeatCheck > HEARTBEAT_CHECK_MS) {
    lastHeartbeatCheck = Date.now();
    if (!heartbeatFresh()) {
      drainLog();
      fail("pw-broker daemon died while waiting — ask the human: systemctl --user status pw-broker", 125);
    }
  }
  if (Date.now() > deadline) {
    fs.rmSync(requestFile, { force: true });
    fail("no result from pw-broker within the deadline — ask the human: systemctl --user status pw-broker", 125);
  }
  await sleep(POLL_MS);
}
