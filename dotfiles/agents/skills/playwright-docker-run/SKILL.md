---
name: playwright-docker-run
description: Run a JS/TS test suite (Playwright or node-only) in a project that has a `playwright-docker/` directory, from this NixOS host. Tests can't run directly here — the host lacks the FHS loader Playwright needs, and sandboxed agents lack docker/pnpm/node. Both are solved by the `pw-test` CLI, which forwards the command to the host-side `pw-broker` Docker runner and streams the log back. Use this whenever you'd otherwise reach for `pnpm test`/`vitest`/`playwright test` in such a project.
allowed-tools: Bash(pw-test:*)
---

# Run tests via the pw-broker Docker runner

On this NixOS host you **cannot** run JS/TS test suites the obvious way:

- Playwright's prebuilt browsers need an FHS dynamic loader the host doesn't have.
- Sandboxed agents don't have `docker`, `pnpm`, or `node` on PATH at all.

Both are solved the same way: the `pw-test` CLI submits "run this command in this
project's Playwright Docker container" to the host-side **`pw-broker`** daemon over a file
queue, blocks while streaming the live log, and exits with the container command's own exit
code — so it feels like running the test command directly. Everything security-relevant
(trust pins, docker execution) happens host-side; `pw-test` only writes the request and
reads the result.

> **Pi users:** pi has a native `pw_test` *tool* (auto-registered in projects with
> `playwright-docker/`) that does all of this with streaming and typed args. If that tool is
> available, use it instead of this skill — this skill is the cross-agent fallback for
> agents (Claude Code, OpenCode, crush, …) that don't have the native tool.

## When to use

Use `pw-test` for **any** test run in a project that has a `playwright-docker/` directory —
including node-only suites, not just browser tests. It is the only thing that works from
this host; a raw `pnpm test` / `pnpm vitest` / `pnpm exec playwright test` will fail.

If the project has **no** `playwright-docker/` directory yet, it isn't set up — use the
**`playwright-docker-setup`** skill first (host-side scaffolding), then have the human run
`pw-broker trust` at the project root.

## How to run

Pass the **full** test command after `--`. It is executed as `sh -c` inside the container,
so pipes, `&&`, env assignments, and quotes all survive:

```bash
pw-test -- pnpm test
pw-test -- pnpm vitest run --project chromium
pw-test -- pnpm -C packages/router-nested test
pw-test --timeout 600 -- pnpm test        # raise the broker timeout for long suites
pw-test --project /path/to/repo -- pnpm test   # default project is the cwd
```

- `--timeout SECS` — broker timeout (default 1800). Raise it if a suite times out (124).
- `--project DIR` — project root; must contain `playwright-docker/`. Defaults to the cwd.
- Everything **after `--`** is the command to run in the container.

## Exit codes — branch on these

| Code    | Meaning                                    | What to do                                                                 |
| ------- | ------------------------------------------ | -------------------------------------------------------------------------- |
| `0`     | Tests passed                               | Done.                                                                       |
| `1–123` | Tests failed (the command's own exit code) | Read the streamed log; fix the code and re-run.                             |
| `124`   | Timed out                                  | Re-run with a larger `--timeout SECS`.                                      |
| `125`   | Infra: broker/docker down or run interrupted | Ask the human: `systemctl --user status pw-broker`.                       |
| `126`   | Refused: project not trusted, or `playwright-docker/` files changed | Ask the human to run `pw-broker trust` at the project root. If the log says `compose.playwright.yaml not found`, the project isn't set up — use the **`playwright-docker-setup`** skill first. |
| `2`     | Usage error (bad flags / missing command)  | Fix the invocation — the command goes **after** `--`.                       |

## Host-side fallbacks (need docker — you cannot run these from the sandbox; ask the human)

```bash
# Reset warm container state (stale /work volume, node_modules, pnpm store):
docker compose -f playwright-docker/compose.playwright.yaml down -v

# Extract artifacts (traces, screenshots) out of the /work volume:
docker compose -f playwright-docker/compose.playwright.yaml run --rm --no-deps \
  playwright tar c -C /work <path> > out.tar
```
