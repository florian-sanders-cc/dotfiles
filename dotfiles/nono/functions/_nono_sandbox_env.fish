# _nono_sandbox_env: emit (one KEY=VAL per line) the environment pinning that
# makes pi + playwright-cli run under nono's Landlock sandbox. Single source
# of truth for the playwright→Landlock env block; pi-plan and pi-write pipe its
# output through `env (_nono_sandbox_env)` before `nono run`. See those
# wrappers for the per-profile nono flags (--read / --allow / --open-port).
#
# JITI_FS_CACHE=false: jiti caches compiled extensions under os.tmpdir()/jiti
# (= /tmp/jiti), which is outside the sandbox allow set, so every extension
# fails to load under nono and registerFlag("plan") never runs -> "Unknown
# option: --plan". Disabling the fs cache makes jiti compile in-memory instead.
#
# --read-file $HOME/.config/AGENTS.md (passed by the wrappers, not here): pi
# walks up the tree from $PWD to find global agent instructions, which live
# outside $PWD and are otherwise denied.
#
# PWTEST_DAEMON_SESSION_DIR: playwright-cli stores its IPC/socket and
# browser --user-data-dir base here. coreBundle.js:69414 + registry.js:120.
#
# PWTEST_CLI_GLOBAL_CONFIG: repoints the *global* config lookup
# (coreBundle.js:65317 — path.join(PWTEST_CLI_GLOBAL_CONFIG ?? homedir(),
# ".playwright", "cli.config.json")). Without this, the lookup hits
# ~/.playwright/cli.config.json, which genuinely exists on the host but whose
# ~/.playwright ancestor is not traversable through the sandbox -> existsSync
# returns true -> readFileSync throws EACCES and the daemon child exits 1.
# --config only short-circuits the *local* .playwright/cli.config.json in CWD
# (line 65299); the global lookup at 65317 is unconditional, so --config does
# NOT fix it. Pointing the env var at the granted dir resolves to
# ~/.local/state/playwright-cli/.playwright/cli.config.json, whose .playwright
# subdir does not exist -> existsSync false (clean ENOENT) -> loadConfig(void 0)
# -> {} -> no read, no crash.
#
# PWTEST_SERVER_REGISTRY: repoints the b/browser@<hash> registry
# (coreBundle.js:51661 + serverRegistry.js:7213 — process.env.PWTEST_SERVER_REGISTRY ||
# ~/.cache/ms-playwright/b). Without this, the daemon child EACCES on
# ~/.cache/ms-playwright/b/browser@..., whose ~/.cache ancestor is denied.
#
# PLAYWRIGHT_MCP_OUTPUT_DIR: repoints outputDir() (coreBundle.js:63812 —
# options.config.outputDir, sourced from PLAYWRIGHT_MCP_OUTPUT_DIR at
# coreBundle.js:71226) else cwd/.playwright-cli. Without this, in pi-plan
# (read-only cwd) the fallback .playwright-cli mkdir EACCES.
#
# TMPDIR: THE KEY FIX for chromium actually running. nono grants /tmp
# write-ONLY (dir read + file O_RDWR are denied — verified: `touch /tmp/x`
# works, `ls /tmp` and reopen-with-O_RDWR both EACCES). Chromium's shared
# memory (--disable-dev-shm-usage is hardcoded by Playwright, forcing /tmp)
# and its --user-data-dir both use os.tmpdir()/TMPDIR. They need O_RDWR (mmap
# MAP_SHARED) + directory reads, which /tmp denies -> SIGTRAP / "Target page
# closed". Pointing TMPDIR at the granted read+WRITE `tmp` subdir moves both
# the shm files and the browser profile into a fully RW location, so chromium
# launches and runs. Also keeps the nono proxy path intact: chromium honors
# HTTPS_PROXY (set by nono) and routes through it — do NOT add --no-proxy-server
# or chromium bypasses nono's filtering proxy and direct connections are blocked.
#
# Verified end-to-end under pi-write: open -> about:blank; goto allowed domain
# (api.anthropic.com) -> navigates; goto disallowed (example.com) ->
# ERR_TUNNEL_CONNECTION_FAILED (intended — allowlist enforced via the proxy).
# Under pi-plan (no allow_domain) the same proxy path allows arbitrary URLs.
function _nono_sandbox_env --description "Emit the playwright→Landlock env pairs for pi-plan / pi-write"
    echo "JITI_FS_CACHE=false"
    echo "TMPDIR=$HOME/.local/state/playwright-cli/tmp"
    echo "PWTEST_DAEMON_SESSION_DIR=$HOME/.local/state/playwright-cli"
    echo "PWTEST_CLI_GLOBAL_CONFIG=$HOME/.local/state/playwright-cli"
    echo "PWTEST_SERVER_REGISTRY=$HOME/.local/state/playwright-cli"
    echo "PLAYWRIGHT_MCP_CONFIG=$HOME/.local/state/playwright-cli/config.json"
    echo "PLAYWRIGHT_MCP_OUTPUT_DIR=$HOME/.local/state/playwright-cli"
end