# pi-write: read-write project, LLM providers only; --ports P[,P...] opens
# audited loopback ports. Thin wrapper over `nono run --profile pi-write -- pi ...`.
# Sandbox setup (playwright-cli state dir + env pinning) is in the autoloaded
# _nono_playwright_setup / _nono_sandbox_env helpers under dotfiles/nono/
# functions/ (wired via nono.nix) — see those for the canonical env knowledge.
# The --ports argparse + audit guidance below is pi-write's only consumer, so
# it stays here.
function pi-write --description "pi writing: read-write project, LLM providers only; --ports P[,P...] opens audited loopback ports"
    # --ports P[,P...] / --ports P --ports P : per-invocation loopback TCP
    # grants. Each becomes a nono `--open-port P` (repeatable): bidirectional
    # localhost connect + listen on that exact port. Unlike --allow-domain,
    # --open-port is a DIRECT kernel allowance that BYPASSES nono's filtering
    # proxy — the proxy only sees non-loopback hops, and loopback traffic does
    # not go through it. So granting a port here escapes the "LLM-providers-only"
    # guarantee of the pi-write profile: whatever service owns that port becomes
    # fully reachable by the agent. Audit each port before passing it:
    #   * NO outbound internet / relay / tunnel / proxy role
    #     (caddy/traefik dev proxy, vite proxy, ngrok/cloudflared, ssh -R, an MCP
    #      server that fetches URLs, a notebook server, a local LLM agent with
    #      web/tools) — nono can't see what loopback then reaches.
    #   * NO destructive / auth / admin / message-sending endpoints
    #     (webhook postgers, /deploy /shutdown routes, Home-Assistant API, MTA,
    #      Docker 2375/2376, kube api, MinIO/S3 console).
    #   * NO stored secrets you don't want the agent reading
    #     (localstack keys, dev vault, db conns, OAuth callback servers).
    # Also note pi-write grants R+W to ~/.pi/agent/extensions/, so any code the
    # agent is socially engineered into enabling there runs in-process and can
    # reach whatever these ports host too.
    # Source of truth for what a port is *now*: `ss -tlnp`. A port that's inert
    # today may host a relay tomorrow — re-audit on every grant. A port bound on
    # *:<port> is externally reachable on the host in addition to loopback;
    # granting loopback to it does NOT expose it to the network, but does expose
    # whatever it hosts to the agent.
    set -l open_ports
    # --ports=+ collects repeated --ports into $_flag_ports (a list);
    # --ignore-unknown leaves pi's own flags (--plan, --model, --help,
    # positional args, etc.) in $argv untouched instead of erroring.
    argparse --ignore-unknown 'ports=+' -- $argv
    or return 22
    if set -q _flag_ports
        for token in (string split ',' -- (string join ',' -- $_flag_ports))
            for port in (string split ' ' -- $token)
                test -n "$port"; or continue
                if not string match -qr '^[0-9]{1,5}$' -- $port
                   or test "$port" -gt 65535 -o "$port" -lt 1
                    echo "pi-write: invalid port '$port' (expected 1-65535)" >&2
                    return 22
                end
                set -a open_ports --open-port "$port"
            end
        end
    end
    _nono_playwright_setup
    # pw-broker queue: write=requests/ ONLY, rest of queue/ read-only. runs/
    # must stay read-only — if it were writable the agent could symlink-swap a
    # run dir and make the unsandboxed daemon write container output through it
    # to an arbitrary host path. trusted.json (the pin store) lives one level
    # up in ~/.local/state/pw-broker/ and must stay outside any grant.
    env (_nono_sandbox_env) nono run --profile pi-write \
        --allow "$PWD" --read-file "$HOME/.config/AGENTS.md" \
        --allow "$HOME/.local/state/pw-broker/queue/requests" \
        --read "$HOME/.local/state/pw-broker/queue" \
        $open_ports \
        -- pi $argv
    # Auto-audit on the HOST after the sandbox exits. pi-write gave the
    # agent RW over $PWD (incl. .git/.jj); Landlock can't stop it planting
    # a control file (jj repo config, git hook, local core.hooksPath) that
    # executes when you next run git/jj here. Running the audit now — before
    # you touch the repo with git/jj — is the point where it matters. This
    # is separate from nono's own post-exit rollback review (a generic FS
    # diff); repo-audit targets the three known auto-exec vectors. Informational:
    # it preserves pi's exit code so scripting/`$status` still reflect pi.
    set -l pi_status $status
    echo ""
    echo "── repo-audit (post pi-write) ──────────────────────────────"
    repo-audit
    return $pi_status
end