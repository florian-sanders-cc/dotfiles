# Review Directives

Guidance for the review sub-agent: what to inspect, what to ignore, how confident to be. Adapted from Anthropic's `code-review` plugin, condensed for a single-agent pass.

## The four axes

Cover each, in this priority order:

1. **Bugs / correctness** — logic errors, edge cases, off-by-one, null/undefined, race conditions, regressions, wrong error handling. Focus on issues that will actually be hit in practice.
2. **Simplification / readability** — duplicated logic, dead code, needless complexity, poor naming, wrong abstraction level ("altitude"), reinventing something the codebase already provides.
3. **Architecture / design** — coupling, leaky abstractions, misplaced responsibility, structural choices that will be expensive to undo.
4. **Open questions** — points where intent is unclear or a decision is the reviewer's to make. Frame as a genuine question, not a disguised assertion. Not every item needs an action.

## Context to pull (before judging)

- **CLAUDE.md** — the root file plus any in directories the diff touches. Treat as guidance for how code should be written; check the diff against it. Cite the exact rule when flagging.
- **git history / blame** — `git log` and `git blame` on the modified lines. A change can be a bug only in light of why the surrounding code exists.
- **Prior PR comments** — when reviewing against a remote, prior PRs touching these files may carry comments that still apply (`gh pr list`, `gh pr view`).
- **Code comments** — comments in the modified files may state invariants the change must respect.

## Anti-false-positive filter

Drop an item unless it survives scrutiny. Do **not** flag:

- Pre-existing issues on lines the change did not modify.
- Things that look like bugs but are intentional and consistent with the broader change.
- Pedantic nitpicks a senior engineer would not raise.
- Anything a linter, typechecker, compiler, or formatter would catch (imports, type errors, style, newlines) — assume CI runs these.
- General quality gripes (test coverage, docs, broad "security") unless CLAUDE.md explicitly requires them.
- Issues CLAUDE.md mentions but the code explicitly silences (e.g. a lint-ignore comment).

## Confidence filter

For each candidate, estimate confidence it is real and worth the reviewer's time:

- High (verified, will bite in practice, or a direct CLAUDE.md violation) → include as a finding.
- Medium (plausible but unverified) → include only if cheap to act on; otherwise reframe as an **open question**.
- Low (does not survive light scrutiny) → drop.

Bias toward fewer, higher-signal items. A short review the reviewer trusts beats an exhaustive one they skim.

## Output discipline

- Cite `file:line` for every finding.
- One sentence per `>` line.
- Keep explanations tight: what, where, why it matters, and (if obvious) a suggested direction.
- Do not propose running builds or tests as part of the review.
