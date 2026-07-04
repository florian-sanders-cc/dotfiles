/**
 * pw_test tool — run JS/TS test suites through the host-side `pw-broker`
 * (Docker) from the sandbox, where docker/pnpm/node aren't available.
 *
 * Registered only for projects that have a `playwright-docker/` directory,
 * so non-Playwright projects never see it. Replaces the former
 * `playwright-docker` skill: the exit-code table and setup handoff are now
 * runtime behavior of this tool, not prompt text the model had to memorize.
 *
 * Host-side fallbacks (need Docker the sandbox lacks — ask the human):
 *   reset warm state → docker compose -f playwright-docker/compose.playwright.yaml down -v
 *   extract artifacts → docker compose -f playwright-docker/compose.playwright.yaml run --rm --no-deps playwright tar c -C /work <path> > out.tar
 */

import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { Type } from "typebox";
import { spawn, type ChildProcess } from "node:child_process";
import { existsSync } from "node:fs";
import { join } from "node:path";

const DEFAULT_TIMEOUT_SECS = 1800;
const KILL_GRACE_MS = 1500;
const RING_LINES = 200;
const PW_DIR = "playwright-docker";

const DESCRIPTION = `Run a JS/TS test command through the host-side pw-broker (Docker) — the only thing that works from the sandbox on this NixOS host.

Always pass the FULL test command ("pnpm test", "pnpm vitest run --project chromium", "pnpm -C packages/x test"); it is wrapped as pw-test -- sh -c "<command>" so pipes/&&/env/quotes survive.

Host-side fallbacks you CANNOT run from the sandbox (ask the human):
- reset warm state: docker compose -f playwright-docker/compose.playwright.yaml down -v
- extract artifacts: docker compose -f playwright-docker/compose.playwright.yaml run --rm --no-deps playwright tar c -C /work <path> > out.tar`;

const COMPOSE_NOT_FOUND = "compose.playwright.yaml not found";

export default function (pi: ExtensionAPI) {
  let registered = false;

  const shouldRegister = (cwd: string): boolean => existsSync(join(cwd, PW_DIR));

  function register(cwd: string): void {
    if (registered) return;
    registered = true;

    pi.registerTool({
      name: "pw_test",
      label: "Run tests via pw-broker",
      description: DESCRIPTION,
      promptSnippet: "Run JS/TS test suites through the host-side Docker broker (sandbox-safe)",
      promptGuidelines: [
        "Use pw_test (not raw bash) for ANY test run in a project with `playwright-docker/` — node-only suites too; it's the only thing that works from the sandbox on this NixOS host.",
      ],
      parameters: Type.Object({
        command: Type.String({
          description:
            'Full test command, e.g. "pnpm test", "pnpm vitest run --project chromium", "pnpm -C packages/x test". Wrapped as pw-test -- sh -c "<command>".',
        }),
        timeout: Type.Optional(
          Type.Number({
            description: `Broker timeout in seconds (default ${DEFAULT_TIMEOUT_SECS}). Raise for long suites.`,
          }),
        ),
        project: Type.Optional(
          Type.String({ description: `Project dir (default cwd). Must contain ${PW_DIR}/.` }),
        ),
      }),

      async execute(_toolCallId, params, signal, onUpdate, ctx) {
        const timeoutSecs = Math.max(1, Math.trunc(params.timeout ?? DEFAULT_TIMEOUT_SECS));
        const project = params.project ?? ctx.cwd;

        const argv = [
          "--project",
          project,
          "--timeout",
          String(timeoutSecs),
          "--",
          "sh",
          "-c",
          params.command,
        ];

        const ring: string[] = [];
        const pushLine = (line: string) => {
          ring.push(line);
          if (ring.length > RING_LINES) ring.shift();
        };

        let stdoutBuf = "";
        let stderrBuf = "";
        let aborted = false;

        const emit = (text: string) => {
          if (!text) return;
          onUpdate?.({ content: [{ type: "text", text }] });
        };

        const handleChunk = (chunk: Buffer, buf: string, isStderr: boolean) => {
          buf += chunk.toString("utf8");
          let idx: number;
          while ((idx = buf.indexOf("\n")) >= 0) {
            const line = buf.slice(0, idx + 1);
            buf = buf.slice(idx + 1);
            pushLine(line);
            emit(line);
          }
          return buf;
        };

        if (signal?.aborted) {
          return { content: [{ type: "text", text: "Cancelled before start." }], details: {} };
        }

        const child: ChildProcess = spawn("pw-test", argv, {
          cwd: undefined,
          stdio: ["ignore", "pipe", "pipe"],
        });

        const onAbort = () => {
          if (aborted) return;
          aborted = true;
          if (!child.killed) {
            child.kill("SIGTERM");
            setTimeout(() => {
              if (!child.killed) child.kill("SIGKILL");
            }, KILL_GRACE_MS).unref();
          }
        };
        signal?.addEventListener("abort", onAbort);

        const flushedTail = () => {
          if (stdoutBuf) {
            pushLine(stdoutBuf);
            emit(stdoutBuf);
            stdoutBuf = "";
          }
          if (stderrBuf) {
            pushLine(stderrBuf);
            emit(stderrBuf);
            stderrBuf = "";
          }
        };

        const code: number | null = await new Promise((resolve) => {
          const settle = (c: number | null, sig: string | null) => {
            signal?.removeEventListener("abort", onAbort);
            flushedTail();
            if (aborted) return resolve(-1);
            if (c === null && sig) return resolve(130);
            resolve(c ?? -1);
          };
          child.stdout?.on("data", (chunk: Buffer) => {
            stdoutBuf = handleChunk(chunk, stdoutBuf, false);
          });
          child.stderr?.on("data", (chunk: Buffer) => {
            stderrBuf = handleChunk(chunk, stderrBuf, true);
          });
          child.on("error", () => settle(-1, null));
          child.on("close", (c, s) => settle(c, s));
        });

        const log = ring.join("");
        const tail = ring.length ? "\n\n--- log tail ---\n" + ring.slice(-60).join("").trimEnd() : "";

        const make = (text: string, isError: boolean) => ({
          content: [{ type: "text", text }],
          details: { exitCode: code, timeoutSecs, project, isError },
          isError,
        });

        if (aborted || code === -1) {
          return make(`Cancelled.${tail}`, false);
        }

        // 126 with compose-not-found → setup handoff (message comes from the broker).
        if (code === 126 && log.includes(COMPOSE_NOT_FOUND)) {
          return make(
            `No \`${PW_DIR}/compose.playwright.yaml\` here — use the **playwright-docker-setup** skill first (host-side scaffolding), then ask the human to run \`pw-broker trust ${project}\` on the host.${tail}`,
            true,
          );
        }

        switch (code) {
          case 0:
            return make(`Tests passed.${tail}`, false);
          case 124:
            return make(`Timed out after ${timeoutSecs}s — re-run pw_test with a larger \`timeout\`.${tail}`, true);
          case 125:
            return make(
              `Broker/Docker problem — ask the human: \`systemctl --user status pw-broker\`.${tail}`,
              true,
            );
          case 126:
            return make(
              `Broker refused (project not trusted, or \`${PW_DIR}/\` files changed) — ask the human to run \`pw-broker trust ${project}\` on the host.${tail}`,
              true,
            );
          default:
            if (code >= 1 && code <= 123) {
              return make(`Tests failed (exit ${code}).${tail}`, false);
            }
            return make(`pw-test exited with code ${code}.${tail}`, true);
        }
      },
    });
  }

  // session_start fires on startup, reload, new, resume, and fork — enough on
  // its own; resources_discover is kept as a reload backstop.
  pi.on("session_start", async (_event, ctx) => {
    if (shouldRegister(ctx.cwd)) register(ctx.cwd);
  });

  pi.on("resources_discover", async (_event, ctx) => {
    if (shouldRegister(ctx.cwd)) register(ctx.cwd);
  });
}