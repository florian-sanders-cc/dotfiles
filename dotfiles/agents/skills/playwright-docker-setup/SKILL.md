---
name: playwright-docker-setup
disable-model-invocation: true
description: Scaffold or update the per-project files that run browser/Playwright tests inside the official Playwright Docker image on a NixOS host. Use this when tests need to run but the project has no `playwright-docker/` directory yet (first-time setup), or to bump it when the project's Playwright version changes. To actually run tests once set up, use the `playwright-docker-run` skill (or, in pi, the native `pw_test` tool).
allowed-tools: Bash(docker compose:*) Bash(docker:*) Bash(grep:*) Bash(ls:*) Bash(cat:*)
---

# Set up / update Playwright-in-Docker for a project

Running Playwright on NixOS fails because the host lacks the FHS dynamic loader the
prebuilt browsers need. The fix is to run tests inside the official
`mcr.microsoft.com/playwright` image, which ships the FHS environment, system deps, and the
browser revision for a given Playwright version. This skill writes three files into a
`playwright-docker/` directory at the project root and builds the image. (To *run* tests
afterward, use the `playwright-docker-run` skill — or, in pi, the native `pw_test` tool that
auto-registers once this directory exists.)

All three files live under `playwright-docker/` (not the project root). That directory is
covered by the global gitignore, so the setup stays untracked by the host project.

## Isolation model (why this is shaped the way it is)

The container must never write into the host source tree. On Linux a bind mount is the same
inode on the same kernel, with no UID remapping — so a file the (root) container writes
through a bind mount lands on the host owned by **UID 0**, which your normal user (UID 1000)
then can't read, overwrite, or delete. That is the cause of the "stale cache owned by root
from an earlier Docker run" failures. Rather than chase every cache path, this setup removes
the failure class structurally:

- **Source is mounted read-only** at `/src`. The kernel rejects every write back to the host
  tree — even from root — so nothing can leak out.
- **The entrypoint copies source into a writable `/work`** (a named volume), and the
  container does all its work there. `/work` is Docker-managed storage, so root-owned files
  inside it never appear in your repo.
- **`node_modules` is excluded from that copy.** The host's `node_modules` is built for
  **NixOS** (patched ELF interpreter, NixOS glibc) and its pnpm symlinks point at a host
  store that doesn't exist in the container — copying it in would reintroduce the exact
  loader crash this setup exists to avoid. The container runs its own
  `pnpm install --frozen-lockfile` against the copied lockfile, so `node_modules` is built
  for Ubuntu and lives entirely inside `/work`.

A consequence worth noting: there is **no per-package `node_modules` volume list to
maintain**. The old design shadowed every package's `node_modules` with a named volume to
stop leaks in both directions; the copy model makes that unnecessary — the host modules are
never copied in, and the container's modules never reach the host.

## Files produced

All paths are relative to the project root.

- `playwright-docker/playwright.Dockerfile` — `FROM mcr.microsoft.com/playwright:v<version>-noble`,
  installs `rsync`, layers `mise` on top, and bakes node + pnpm from the project's `mise.toml`.
- `playwright-docker/playwright.entrypoint.sh` — rsyncs `/src` → `/work` (excluding
  `node_modules`/`.git`), runs `pnpm install --frozen-lockfile`, then `exec "$@"`.
- `playwright-docker/compose.playwright.yaml` — mounts the source read-only at `/src`, gives
  `/work` a named volume, and keeps pnpm's store inside that volume so installs/downloads
  stay warm across runs. Its build `context` is the project root (`..`) so the Dockerfile can
  still `COPY` files like `mise.toml` from the repo.

## Steps

1. **Detect the Playwright version (lockfile-exact).** Prefer the resolved version:
   ```bash
   grep -Eo 'playwright@[0-9]+\.[0-9]+\.[0-9]+' pnpm-lock.yaml | sort -u
   ```
   Fall back to the `pnpm-workspace.yaml` catalog (`playwright:`), a `package.json`
   dependency, or `npm ls playwright`. Use the exact `X.Y.Z`.

2. **Detect node/pnpm.** Read `mise.toml` (`[tools]`). If absent, check `.tool-versions`,
   `.nvmrc`, or `package.json` `engines` / `packageManager` and create a minimal
   `mise.toml`. The Dockerfile bakes whatever `mise install` resolves.

3. **Write the three files** from the templates below, substituting the version. No workspace
   enumeration is needed — `node_modules` for every package is built inside `/work`.

4. **Build:**
   ```bash
   docker compose -f playwright-docker/compose.playwright.yaml build
   ```

5. **Verify:**
   ```bash
   docker compose -f playwright-docker/compose.playwright.yaml run --rm playwright node -v   # baked node
   docker compose -f playwright-docker/compose.playwright.yaml run --rm playwright pnpm -v    # baked pnpm
   ```

6. **Trust the setup** so sandboxed agents can run tests through the broker (`pw-test`).
   This pins sha256 of every `playwright-docker/` file; the `pw-broker` daemon refuses
   unpinned or modified setups. Must be run by the human, on the host, at the project root:
   ```bash
   pw-broker trust
   ```

## Bumping the version

When the project's Playwright dependency changes, update `PLAYWRIGHT_VERSION` in BOTH
`playwright-docker/playwright.Dockerfile` (ARG default) and
`playwright-docker/compose.playwright.yaml` (`build.args`), then
`docker compose -f playwright-docker/compose.playwright.yaml build`, then have the human
re-run `pw-broker trust` at the project root — any edit to `playwright-docker/` files
invalidates the broker's pins and `pw-test` will exit 126 until re-trusted.

## If the exact image tag is unavailable

MCR may prune very old tags. The official image's real value here is the OS/FHS layer (the
actual NixOS blocker), not the bundled browsers. If `v<version>-noble` 404s on build:
- Use the nearest available `v<near>-noble` tag for the base image, AND
- Add `ENV PLAYWRIGHT_BROWSERS_PATH=/work/node_modules/.pw-browsers` to the Dockerfile and
  have the entrypoint run `pnpm exec playwright install chromium firefox webkit` after the
  install step. Keeping the browsers path inside `node_modules` puts it in the warm `/work`
  volume and (since `node_modules` is excluded from the rsync) keeps it from being wiped on
  the next sync. The browsers download fine inside Ubuntu (only NixOS blocks them).

---

## Templates

The build `context` is the **project root** (`..` relative to the compose file), so `COPY`
sources are written relative to that root — hence the `playwright-docker/` prefix on the
entrypoint copy.

### `playwright-docker/playwright.Dockerfile`
```dockerfile
ARG PLAYWRIGHT_VERSION=<X.Y.Z>
FROM mcr.microsoft.com/playwright:v${PLAYWRIGHT_VERSION}-noble

RUN apt-get update && apt-get install -y --no-install-recommends curl git rsync \
    && rm -rf /var/lib/apt/lists/*

RUN curl -fsSL https://mise.run | sh
ENV PATH="/root/.local/bin:/root/.local/share/mise/shims:${PATH}"
ENV MISE_TRUSTED_CONFIG_PATHS=/work

# Bake node + pnpm from the project's mise.toml. /work is replaced by a volume at runtime,
# so install from a build-only copy here.
WORKDIR /build
COPY mise.toml ./
RUN mise trust /build/mise.toml && mise install

COPY playwright-docker/playwright.entrypoint.sh /usr/local/bin/pw-entrypoint
RUN chmod +x /usr/local/bin/pw-entrypoint

WORKDIR /work
ENTRYPOINT ["/usr/local/bin/pw-entrypoint"]
CMD ["pnpm", "test"]
```

### `playwright-docker/playwright.entrypoint.sh`
```sh
#!/usr/bin/env sh
set -e

# The node_modules exclude below also shields every node_modules in /work from --delete. When a
# package is removed from /src, its leftover node_modules keeps the directory alive and rsync
# fails with "cannot delete non-empty directory". Drop the node_modules whose package no longer
# exists in /src; those of live packages are kept, so the volume stays warm.
find /work -name node_modules -type d -prune | while read -r nm; do
  rel="${nm#/work}"
  if [ ! -d "/src${rel%/node_modules}" ]; then
    rm -rf "$nm"
  fi
done

# Copy the read-only source into the writable work tree. node_modules and .git are excluded:
# the host's node_modules is built for NixOS and must not enter Ubuntu, and .git is large and
# unneeded. --delete keeps /work in sync with deletions in /src on later runs.
rsync -a --delete --exclude node_modules --exclude .git /src/ /work/

cd /work
# Build node_modules for Ubuntu, inside the warm /work volume. A no-op once the volume is
# warm and the lockfile is unchanged.
pnpm install --frozen-lockfile

exec "$@"
```

### `playwright-docker/compose.playwright.yaml`
```yaml
# Lives in playwright-docker/. `context: ..` points the build at the project root so the
# Dockerfile can COPY repo files. The source is mounted READ-ONLY at /src and copied into the
# /work volume by the entrypoint, so the container never writes to the host tree.
services:
  playwright:
    build:
      context: ..
      dockerfile: playwright-docker/playwright.Dockerfile
      args:
        PLAYWRIGHT_VERSION: "<X.Y.Z>"
    image: <project>-playwright:<X.Y.Z>
    init: true
    working_dir: /work
    environment:
      CI: "true"
      # Keep pnpm's store inside node_modules (which lives in the warm /work volume) so
      # downloads are cached across runs and hardlinks into node_modules work.
      npm_config_store_dir: /work/node_modules/.pnpm-store
    volumes:
      - ..:/src:ro          # source, read-only — container physically cannot write the host
      - pw-work:/work       # isolated work tree; persists across runs (warm node_modules)
volumes:
  pw-work: {}
```
