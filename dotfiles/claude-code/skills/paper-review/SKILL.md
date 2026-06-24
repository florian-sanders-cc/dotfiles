---
name: paper-review
description: Conversational code review written to a markdown file the reviewer annotates, then acted on. Use when the user asks to review the current branch or diff, runs /paper-review (optionally with "working tree", "staging", "rescan", or a ref/range), says "review my changes", or asks to act on their annotations in an existing review file.
allowed-tools: Bash(git:*), Bash(gh:*), Read, Write, Edit, Grep, Glob, Task
---

# Paper Review

Conversational code review as a **living markdown file**. The agent writes findings as quoted lines; the reviewer annotates in plain text between or after those lines; the agent re-reads, acts on clear decisions, asks follow-ups, and rescans for new issues. The file is the conversation.

## Protocol (non-negotiable)

- `>` quoted lines = **agent** voice (findings, questions, suggestions, status notes).
- Plain, unquoted text = the **human** reviewer's annotations.
- Never edit or delete the human's plain-text lines. Only add or update `>` lines.
- One sentence per line inside agent blockquotes.
- Item status lives in the item **title**, one of: `[OPEN]` (default), `[DONE]`, `[WONTFIX]`, `[DISCUSS]`. The agent owns it.

## File location

- `.reviews/<branch>.md` — slashes in the branch name become `-` (e.g. `feat/foo` → `feat-foo.md`).
- `.reviews/` is expected to be ignored via the user's **global** gitignore (`git config --global core.excludesfile`). Do not modify the project's `.gitignore`. If a review file shows up in `git status`, tell the user to add `.reviews/` to their global excludes once — never commit review files.

## Engine — thin orchestrator, one fat sub-agent

The whole job runs inside **one sub-agent** (Task tool). The main thread is a dispatcher, nothing more.

**The orchestrator (main thread) does ONLY this:**
1. Read the current branch (`git branch --show-current`) to name the file.
2. Parse any modifier from the invocation: `working tree`, `staging`/`staged`, `rescan`, or an explicit ref/range/PR (default: branch vs base).
3. Spawn one sub-agent, passing: the branch name, the modifier, and the instructions below (point it at `references/directives.md` and `references/format.md` — do not read them yourself).
4. Relay the sub-agent's short summary to the reviewer.

**The orchestrator must NOT** — these all belong to the sub-agent:
- grep or read source files, resolve symbols, or map call-sites
- compute or look at the diff (never let diff content enter the main thread)
- read the review file or the reference files
- **re-verify the sub-agent's work afterwards** — trust its summary; if confidence matters, tell the sub-agent to self-verify and report it

Anything beyond the four orchestrator steps above is a leak. Resist the urge to "just check".

## Sub-agent brief

Give the sub-agent this whole brief. It does everything: resolve, explore, decide, write, self-verify.

**Setup**
- File path: `.reviews/<branch>.md` — slashes in the branch become `-`.
- Get the date itself: `date +%F` (use in the title).
- Detect the mode with a single check: `test -f .reviews/<branch>.md` → exists = **apply**, else = **write**. Treat a later read failure as "fall back to write".
- Resolve the target:
  - default → base = whichever of `main`/`master` exists (`git rev-parse --verify`), diff `<base>...HEAD`
  - `working tree` → `git diff HEAD` plus contents of untracked files (`git ls-files --others --exclude-standard`)
  - `staging`/`staged` → `git diff --cached`
  - explicit arg → that ref/range/PR
- Shell may be **fish**: avoid bash-isms and unescaped globs (`grep --include=*.js` fails); prefer `git grep` / `git ls-files`.

**Write mode**
- Read the diff and only the surrounding context needed to judge it.
- Produce items across four axes: bugs/correctness, simplification/readability, architecture/design, open questions.
- Apply the false-positive filter from `references/directives.md` — keep signal, drop nitpicks.
- Write `.reviews/<branch>.md` per `references/format.md`.
- Return counts (items per axis) + a one-line summary.

**Apply mode** — do all localization yourself (grep/read source as needed; do not expect the orchestrator to have done it). For each item:
- Human gave a clear decision/instruction → make the change in the working tree, set `[DONE]`, add a `> done: <what changed>` line citing `file:line`.
- Human decided not to act (with reason) → set `[WONTFIX]`, add `> wontfix: <reason restated>`.
- Human asked a question or the answer is ambiguous → set `[DISCUSS]`, add a `> ` follow-up question or answer.
- Untouched item → leave `[OPEN]`.

Then rescan the diff against the **same base as the original review** (working-tree edits just made are included) and **append** genuinely new items as `[OPEN]`, numbered from `max(existing number) + 1`. Never renumber existing items, even when non-contiguous after a `[WONTFIX]`.

Self-verify the edits (e.g. a final `git grep` that the changes landed and nothing stale remains) and state the result in the summary. Return: what changed in code + what now awaits the reviewer (`[DISCUSS]` / `[OPEN]` counts).

**Boundaries (sub-agent)**
- Edit only the working tree. Never commit — the reviewer commits.
- Never touch the human's plain-text lines; only add/update `>` lines.
- Preserve item numbers across runs.
- Do not run build/typecheck/lint as part of review (CI handles those).

## References

- **`references/directives.md`** — review axes, context to pull (CLAUDE.md, git history, prior PR comments, code comments), the anti-false-positive list, and the confidence filter.
- **`references/format.md`** — exact file template plus a worked, annotated round-trip example.
