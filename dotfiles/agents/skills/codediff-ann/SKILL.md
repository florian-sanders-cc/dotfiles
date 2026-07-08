---
name: codediff-ann
description: Manage CodeDiff review annotations via the `codediff-ann` CLI (list/add/delete/resolve in `<cwd>/.nvim/codediff-annotations.json`).
disable-model-invocation: true
allowed-tools: Bash(codediff-ann:*)
---

# CodeDiff review-annotation management

The `codediff-ann` CLI manages the JSON store consumed by the
`git.codediff-annotate` Neovim module. Annotations are inline review notes
attached to a file + line range, keyed one of two ways:

- `work:<cwd-relative-path>` — real working-tree file (most common)
- `rev:<commit>:<git-root-rel>` — git revision virtual buffer (rare in this workflow)

Each annotation: `{ line, end_line?, text, resolved? }`. `resolved` is a
review-state bit the CLI toggles; the Neovim module ignores it.

## Store location

`<cwd>/.nvim/codediff-annotations.json` — per working directory. Confirm with:

```bash
codediff-ann path
```

## Common workflow

### See what's open

```bash
codediff-ann keys                       # keys + resolved/total counts
codediff-ann list                       # all annotations, tabular
codediff-ann list --unresolved          # only open comments
```

Add `--json` for machine-readable output (parsing, diffs).

### Add a review comment

```bash
codediff-ann add --key src/main.ts --line 42 --text "extract this into a helper"
# range:
codediff-ann add --file "$PWD/src/main.ts" --line 40 --end-line 48 --text "rename"
```

- `--key` accepts a bare relative path (auto-promoted to `work:<path>`).
- `--file` accepts an absolute path (converted to `work:<rel>`).
- `--resolved` marks it resolved immediately.

### Delete

```bash
codediff-ann delete --key src/main.ts --index 2     # by 1-based index (from `list`)
codediff-ann delete --key src/main.ts --line 42     # all annotations covering line 42
```

### Resolve / unresolve

```bash
codediff-ann resolve   --key src/main.ts --index 2
codediff-ann resolve   --key src/main.ts --line 42
codediff-ann resolve   --key src/main.ts --all
codediff-ann unresolve --key src/main.ts --index 2
```

### Maintenance

```bash
codediff-ann sweep      # drop work: keys whose file no longer exists
```

## Reading from outside cwd

```bash
codediff-ann --cwd /path/to/repo list --json
codediff-ann --cwd /path/to/repo keys
```

All commands accept `--cwd <dir>` as a global flag before the subcommand.

## Completion criteria

- Before declaring a review pass done: run `codediff-ann list --unresolved`
  and confirm the output is `(no annotations)` or the remaining items are
  intentionally deferred.
- Before declaring a file reviewed: `codediff-ann --cwd <repo> resolve --key
  <file> --all` (or by index/line), then list to confirm `0` unresolved for
  that key (filter with `--key`).

## Notes

- No `commit`/`push` happens here — the store is a working-tree JSON file.
  A no-commit gate applies separately; do not attempt git commits.
- Adding/deleting/resolving writes immediately and atomically (temp + rename).
- `rev:` keys are not pruned by `sweep` (a past revision's file may be gone
  while the comment still applies to that revision's buffer).
- For Neovim-side rendering (the virtual-line UI), keep the file open after
  CLI changes and re-run `:edit` or fire `:lua
  require("git.codediff-annotate").apply(0)` to re-render; the autocmds also
  re-render on `BufReadPost`/`BufEnter`/`CodeDiffOpen`.