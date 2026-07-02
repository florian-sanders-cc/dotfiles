---
name: playwright-docker
description: Use whenever tests are run, written, fixed, or discussed in a JS/TS project on this NixOS host. Browser / Playwright / vitest-browser tests crash if run directly on the host and MUST run inside the project's Playwright Docker image; load this skill to tell whether a given test is a browser test and run it the right way (node-only tests may still run on the host).
allowed-tools: Bash(docker compose:*) Bash(docker:*)
---

# Run browser tests via Docker (NixOS host)

## Hard rule

**Browser / Playwright / vitest-browser tests must NEVER be run directly on this NixOS
host.** The prebuilt browsers expect an FHS dynamic loader (`/lib64/ld-linux…`) that NixOS
does not provide, so they crash with loader/`ENOENT` errors. Always run them through the
project's Playwright Docker container instead. Node-only tests (no browser) may still run
on the host.

How to tell a test is a browser test: it uses `@vitest/browser`, `@vitest/browser-playwright`,
`@playwright/test`, `playwright`, or a vitest config with `test.browser.enabled = true`.

## How to run

A project set up for this has its Docker files in a `playwright-docker/` directory at the
project root, including `playwright-docker/compose.playwright.yaml`. Run any command in the
container by appending it after `playwright`:

```bash
# full test suite
docker compose -f playwright-docker/compose.playwright.yaml run --rm playwright pnpm test

# a single workspace package
docker compose -f playwright-docker/compose.playwright.yaml run --rm playwright pnpm -C packages/router-nested test

# arbitrary command / interactive shell
docker compose -f playwright-docker/compose.playwright.yaml run --rm playwright bash
```

## How it works (so the output makes sense)

- The source is mounted **read-only** at `/src` and copied into a writable `/work` volume by
  the entrypoint on every run, so each run tests your **current working-tree code**. The
  container never writes to the host tree — there are no root-owned files left in your repo.
- `node_modules` is **not** copied from the host (the host's is built for NixOS). On the
  first run the entrypoint runs `pnpm install --frozen-lockfile` inside Ubuntu, so that run
  is slower. `node_modules` lives in the `/work` volume, so later runs reuse it and are fast.
- `--rm` discards the *container* each run, but the `/work` **volume** persists — that's what
  keeps `node_modules` and the pnpm store warm. Disposable container, persistent storage.

## Getting test artifacts out

Because `/work` is isolated, anything the run produces (coverage, Playwright traces,
screenshots) stays inside the container/volume and is gone after `--rm`. If you need an
artifact on the host, copy it out of the work volume with a throwaway container, e.g.:

```bash
docker compose -f playwright-docker/compose.playwright.yaml run --rm --no-deps \
  playwright tar c -C /work coverage > coverage.tar
```

(Or run the suite without `--rm` and `docker compose cp` the path out before removing the
container.) A pass/fail exit code needs none of this.

## Resetting warm state

If the `/work` volume gets into a bad state (corrupt install, stale cache), drop it and let
the next run rebuild from scratch:

```bash
docker compose -f playwright-docker/compose.playwright.yaml down -v
```

## If `playwright-docker/compose.playwright.yaml` is missing

The project has not been set up yet. Use the **playwright-docker-setup** skill to scaffold
the `playwright-docker/` directory (`playwright.Dockerfile`, `playwright.entrypoint.sh`, and
`compose.playwright.yaml`), then come back here to run the tests.

## If the run fails with a browser/version error

If the in-container Playwright complains the browser isn't installed, the image's Playwright
version is out of sync with the project's. Re-run **playwright-docker-setup** to rebuild the
image at the project's current Playwright version (it also handles the case where the exact
image tag is unavailable).

## Legacy: root-owned files in the repo

If you hit `EACCES` on a cache/file inside the project that's owned by `root`, it's a
leftover from an **older bind-mounted** setup (before the read-only `/src` + `/work` copy
model). The current setup can't create these. Clean an existing one up from *inside* a
container (never with host `sudo` against a tree you didn't create as root):

```bash
# run from the project root; $PWD is the repo, mounted writable at /host
docker compose -f playwright-docker/compose.playwright.yaml run --rm \
  -v "$PWD:/host" playwright rm -rf /host/<offending-path>
```
