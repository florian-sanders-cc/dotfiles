# _nono_playwright_setup: provision the chromium-under-Landlock playwright-cli
# state dir used by the pi-plan / pi-write wrappers. Called before `nono run`
# because nono skips grants for nonexistent paths — both the dir and its
# config.json must already exist on the host when the sandbox starts.
#
# All playwright-cli paths that would touch ~/.cache, ~/.playwright, or /tmp
# are repointed to a single granted RW dir (~/.local/state/playwright-cli),
# created outside the sandbox. $HOME/.local/state is already traversable via
# the nix_runtime group, so this adds no new ancestor-traversal exposure.
#
# PLAYWRIGHT_MCP_CONFIG (the config.json we write here): sets browserName=
# chromium + launchOptions.args=[--no-sandbox,...]. This fixes TWO things.
# (1) Channel: with no browserName set, validateBrowserConfig
# (coreBundle.js:65678) defaults launchOptions.channel="chrome" (Google
# Chrome at /opt/google/chrome/chrome) which is not installed -> "Chromium
# distribution 'chrome' is not found". Setting browserName=chromium avoids the
# chrome-channel default. (2) Sandbox: chromium's own setuid/namespace sandbox
# cannot initialize under the outer Landlock -> SIGTRAP. --no-sandbox disables
# it (nono's Landlock is the sandbox now). --disable-crash-reporter suppresses
# crashpad writes to ~/.config/google-chrome-for-testing (denied, non-fatal
# but noisy). NB: the nix wrapper sets a --set-default PLAYWRIGHT_MCP_CONFIG
# for *unsandboxed* use (browserName=chromium only, no --no-sandbox); the env
# value emitted by _nono_sandbox_env overrides it for the sandboxed invocation.
function _nono_playwright_setup --description "Provision ~/.local/state/playwright-cli for chromium-under-Landlock"
    mkdir -p "$HOME/.local/state/playwright-cli/tmp"
    echo '{"browser":{"browserName":"chromium","launchOptions":{"args":["--no-sandbox","--disable-crash-reporter"]}}}' > "$HOME/.local/state/playwright-cli/config.json"
    # pw-broker file queue (pw-test client in-sandbox <-> pw-broker daemon on
    # the host). Pre-created here for the same reason as above: nono skips
    # grants for nonexistent paths, and the queue must be grantable even if the
    # daemon has never run yet.
    mkdir -p "$HOME/.local/state/pw-broker/queue/requests" "$HOME/.local/state/pw-broker/queue/runs"
end