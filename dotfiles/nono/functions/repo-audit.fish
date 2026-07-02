# repo-audit: detect control files an agent could plant under the
# pi-write write mount ($PWD, which includes .git and .jj) that execute
# on the HOST when you next run git/jj — out of band from a source diff.
# Run it in a repo after a pi-write session, before running git/jj there.
# Standalone-callable; pi-write auto-runs it post-exit.
# Covers three verified vectors:
#   1. jj legacy in-repo config: jj 0.42 reads .jj/repo/config.toml if
#      present (a ~1-year auto-migration window; a healthy 0.42 repo never
#      has this file). Its aliases run arbitrary commands via `util exec`,
#      and non-command aliases (e.g. overriding `st`) win — fires on the
#      next `jj st`. Self-closes when the migration window ends upstream.
#   2. git hooks: an executable .git/hooks/<name> runs on your direct git
#      commands. Globally neutered via core.hooksPath (git.nix), but flagged
#      here as tamper-detection.
#   3. git local-config override: repo-local .git/config core.hooksPath /
#      core.fsmonitor OVERRIDES the global hooksPath disable and is itself
#      agent-writable — this is the residual the global setting can't close.
function repo-audit --description "Flag agent-plantable git/jj control files that auto-execute on the host"
    set -l dir (pwd)
    test -n "$argv[1]"; and set dir $argv[1]
    set -l root (command git -C "$dir" rev-parse --show-toplevel 2>/dev/null)
    test -z "$root"; and set root (command jj -R "$dir" root 2>/dev/null)
    test -z "$root"; and set root "$dir"
    set -l issues 0

    # 1. jj legacy in-repo config (anomalous on jj 0.42+)
    if test -f "$root/.jj/repo/config.toml"
        echo "⚠ jj: in-repo config present → $root/.jj/repo/config.toml"
        echo "   executes on next jj command; a clean jj 0.42 repo never has this file"
        set issues (math $issues + 1)
    end

    # 2. git hooks: executable, non-sample
    for h in (find "$root/.git/hooks" -maxdepth 1 -type f -perm -u+x ! -name '*.sample' 2>/dev/null)
        echo "⚠ git: executable hook present → $h"
        set issues (math $issues + 1)
    end

    # 3. repo-local git config re-pointing hooks / fsmonitor
    for key in core.hooksPath core.fsmonitor
        set -l val (command git -C "$root" config --local --get $key 2>/dev/null)
        if test -n "$val"
            echo "⚠ git: repo-local $key = $val (overrides your global hook-disable)"
            set issues (math $issues + 1)
        end
    end

    if test $issues -eq 0
        echo "✓ repo-audit: no planted control files in $root"
    else
        echo "✗ repo-audit: $issues issue(s) — inspect before running git/jj here"
        return 1
    end
end