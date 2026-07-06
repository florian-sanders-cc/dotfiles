---
name: mermaid
description: >
  Generate, validate, and render Mermaid diagrams — flowcharts, sequence diagrams,
  class diagrams, state diagrams, ER diagrams, Gantt charts, mindmaps, and more.
  Use this skill whenever the user asks to create, draw, validate, fix, or render
  a Mermaid diagram, or when you need to verify diagram syntax is render-safe.
  Also use it when a diagram won't render or renders incorrectly and needs fixing.
allowed-tools:
  - Bash(node:*)
  - Bash(mmdc:*)
---

# Mermaid Diagram Skill

Generate **render-safe** Mermaid diagrams on the first try, then validate them
against the authoritative grammar (`mmdc`, the @mermaid-js/mermaid-cli binary)
and iterate until the validator exits 0.

`mmdc` is already on `PATH` inside pi: the pi Nix wrapper prefixes
`mermaid-cli` onto `PATH` (see `modules/packages/pi-coding-agent.nix`), and
mermaid-cli reuses the Nix-managed Chromium via `PUPPETEER_EXECUTABLE_PATH` —
**no browser download, no manual setup, no network at render time.**

---

## 1. Render-safe rules — read before writing any diagram

These are the common first-render breakers. Apply them **before** writing the
`.mmd` file so diagrams land right the first time.

### Punctuation & characters
- Use **straight** quotes only: `"` `'` — never smart/curly quotes `"' '' ""` or
  Unicode dashes `— –`. Smart quotes silently corrupt labels and break parsing.
- No unbalanced `[]`, `()`, `{}`, `|`, or `"`. Every opener must have a matching
  closer on the same logical element.
- Pipe edge labels `|...|` must wrap exactly one label and close cleanly:
  `A -->|label| B` (not `A -->|label B` or `A --> label| B`).

### Reserved words as identifiers
- Never use `end`, `subgraph`, `click`, `class`, `classDef`, `linkStyle`,
  `style`, or direction keywords as node ids or labels written bare. Quote them
  if they must appear in a label: `A["end"]` is fine; `end --> B` is not.
- Every `subgraph X` **must** have a matching `end` on its own line.

### Shapes & nodes
- Never leave a shape empty: `A[]`, `A()`, `A{}` are invalid. Always supply a
  label or drop the brackets: `A[label]`, `A(label)`, `A{label}`, or just `A`.
- `classDef` must use a colon: `classDef className fill:#f00,stroke:#333,stroke-width:2px`
  (never `classDef className fill=#f00` or missing the leading property punctuation).

### Diagram header
- Flowcharts start with `flowchart TD` or `flowchart LR` (use `flowchart`, not
  the deprecated `graph`, when in doubt).
- Sequence diagrams: `sequenceDiagram` on its own line.
- Class: `classDiagram`; State: `stateDiagram-v2`; ER: `erDiagram`; Gantt:
  `gantt`; Mindmap: `mindmap`.

### Edges
- Flowchart arrows: `-->`, `---`, `-.->`, `==>`, `--x`, `--o`, `-. label .->`.
- Sequence: solid `->>` dashed `-->>`, dotted `--)`; actors before messages.
- Double-check arrow syntax against the per-type rules in
  `references/RULES.md` — quoting an unusual label is always safer than leaving
  it bare.

For the **deep per-diagram-type** rules (flowchart, sequence, class, state, ER,
gantt, mindmap, etc.), load on demand:

```
read ~/.pi/agent/skills/mermaid/references/RULES.md
```

---

## 2. Workflow (with a checkable completion criterion)

**Definition of done: the validator exits 0.** Iterate until it does.

1. **Write** the diagram to a `.mmd` file, applying the render-safe rules above.
   Write only the diagram body (starting with the diagram header line). Do not
   wrap in a code fence inside the `.mmd` file.
2. **Validate + optionally render:**

   ```bash
   # validate only (renders to a discarded temp SVG under the hood)
   node ~/.pi/agent/skills/mermaid/scripts/mermaid-check.mjs /path/to/diagram.mmd

   # validate and also emit a rendered SVG (or .png)
   node ~/.pi/agent/skills/mermaid/scripts/mermaid-check.mjs /path/to/diagram.mmd --render /path/to/out.svg
   ```

3. **Read** the diagnostics. On failure the validator prints the real grammar
   error from `mmdc` (line/col where available) with exit 1.
4. **Fix** the `.mmd` file using `edit`, applying the render-safe rule that was
   violated (see `references/RULES.md` for type-specific fixes).
5. **Re-run** the validator. **Loop steps 3–5 until the validator exits 0.**
6. (Optional) Run with `--render` to emit the final SVG/PNG once valid.

The validator has a **heuristic fallback**: if `mmdc` is not on PATH (e.g. the
pi wrapper wasn't rebuilt with `mermaid-cli`, or you're outside the pi-managed
environment), it falls back to a zero-dependency line-precise lint for the
common breakers above — so the skill stays useful anywhere. The fallback still
exits 0/1 with line-precise diagnostics, but it cannot certify diagrams that
use advanced features; prefer running inside the pi-wrapped environment so the
authoritative `mmdc` path is used.

---

## 3. Rendering

Rendering is **optional** and secondary — validation is authoritative. Pass
`--render <out.svg|out.png>` to produce a rendered file once the diagram is
valid. If the diagram is invalid, rendering is skipped and the validator exits 1
with the grammar error. `mmdc` supports `.svg`, `.png`, and `.pdf` outputs.

---

## 4. Tips

- Keep diagrams small and focused. Split a giant diagram into several smaller
  ones rather than fighting accumulation of breakers.
- When in doubt about a label, **quote it**: `A["weird: label (with parens)"]`.
- The validator is the source of truth. Never hand-assert "this is valid" —
  run the validator and trust its exit code.