# pi-plan: read-only project + writable .pi, full internet. Thin wrapper over
# `nono run --profile pi-plan -- pi --plan ...`. Sandbox setup (playwright-cli
# state dir + the env pinning) lives in the autoloaded _nono_playwright_setup /
# _nono_sandbox_env helpers under dotfiles/nono/functions/ (wired via
# nono.nix). See those helpers for the canonical env/provisioning knowledge.
function pi-plan --description "pi planning: read-only project + writable .pi, full internet"
    _nono_playwright_setup
    mkdir -p .pi
    # pw-broker queue grants: see the comment in pi-write.fish (write=requests/
    # only; runs/ read-only; trusted.json outside any grant).
    env (_nono_sandbox_env) nono run --profile pi-plan \
        --read "$PWD" --read-file "$HOME/.config/AGENTS.md" \
        --allow "$PWD/.pi" \
        --allow "$HOME/.local/state/pw-broker/queue/requests" \
        --read "$HOME/.local/state/pw-broker/queue" \
        -- pi --plan $argv
end