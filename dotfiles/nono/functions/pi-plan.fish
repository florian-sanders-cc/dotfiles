# pi-plan: read-only project + writable .pi, full internet. Thin wrapper over
# `nono run --profile pi-plan -- pi --plan ...`. Sandbox setup (playwright-cli
# state dir + the env pinning) lives in the autoloaded _nono_playwright_setup /
# _nono_sandbox_env helpers under dotfiles/nono/functions/ (wired via
# nono.nix). See those helpers for the canonical env/provisioning knowledge.
function pi-plan --description "pi planning: read-only project + writable .pi, full internet"
    _nono_playwright_setup
    mkdir -p .pi
    env (_nono_sandbox_env) nono run --profile pi-plan \
        --read "$PWD" --read-file "$HOME/.config/AGENTS.md" \
        --allow "$PWD/.pi" -- pi --plan $argv
end