# Render-safe Mermaid rules — per diagram type

This file expands on the quick rules in `SKILL.md`. Load it on demand when
debugging a specific diagram type or when the validator reports an error you
don't understand.

> General principle: **quote anything unusual.** A label with `:`, `(`, `)`,
> `[`, `]`, `{`, `}`, `|`, `"`, or a reserved word will be safer quoted than
> bare. Use straight quotes only.

---

## Flowchart (`flowchart TD` / `flowchart LR`)

- Header: `flowchart TD` (top-down) or `flowchart LR` (left-right). `TB`/`BT`/
  `RL` also valid. Prefer `flowchart` over deprecated `graph`.
- Node shapes (always with a label inside, never empty):
  - Rectangle: `A[label]`
  - Rounded: `A(label)`
  - Stadium: `A([label])`
  - Subroutine: `A[[label]]`
  - Cylinder: `A[(label)]`
  - Circle: `A((label))`
  - Double circle: `A(((label)))`
  - Rhombus (decision): `A{label}`
  - Hexagon: `A{{label}}`
  - Parallelogram: `A[/label/]`  — note `/` doubles as trapezoid when reversed
  - Trapezoid: `A[/label\]`  (alt) `A[\label/]`
  - Asymmetric: `A>label]`
  - Flag: `A>O"label"]` — uncommon; prefer standard shapes.
- Edges:
  - Solid arrow: `A --> B`
  - Open arrow: `A --- B`
  - Dotted: `A -.-> B`  (with optional label: `A -. label .-> B`)
  - Thick: `A ==> B`
  - Cross: `A --x B`
  - Circle: `A --o B`
  - Multi-arrow: `A --> B & C --> D`
  - Labelled: `A -->|text| B`  — pipe **must** close.
- Subgraphs: `subgraph title` ... `end` — every opener needs a matching `end`.
  `subgraph X ["Title text"]` form is valid for multi-word titles.
- `classDef name fill:#hex,stroke:#hex,stroke-width:Npx,color:#hex` — colon
  after the name is mandatory; properties are comma-separated `key:value`.
- `class A,B className` to apply. `style A fill:#hex` for one-off styling.
- `linkStyle N stroke:#hex` — N is the 0-based edge index.

### Common flowchart breakers
- `end` or `subgraph` used as a node id → rename to `endNode` / `sub`.
- Unbalanced `|...|` on edge labels → ensure the trailing `|` is present.
- `A[]` empty brackets → always insert a label or drop the brackets.
- Smart quotes in labels → replace with straight quotes.
- `classDef foo fill=#f00` (uses `=`) → must be `fill:#f00`.

---

## Sequence diagram (`sequenceDiagram`)

- Header: `sequenceDiagram`
- Participants / actors: declare with `participant Name as "Display Name"` or
  just use them inline. `actor Bob` is the newer form.
- Messages (from actor → actor):
  - Solid: `A->>B: text`  (solid arrowhead)
  - Dashed: `A-->B: text`  (thin solid) / `A-->>B: text` (dashed arrowhead)
  - Dotted: `A--)B: text`
  - Cross: `A-x B: text`  (async, no arrowhead)
- `Note over A: text` / `Note over A,B: text` / `Note left of A: text` /
  `Note right of A: text`.
- Loops & blocks (each needs matching `end`):
  - `loop description` ... `end`
  - `opt description` ... `end`
  - `alt condition` ... `else other` ... `end`
  - `par description` ... `and other` ... `end`
  - `critical description` ... `option x` ... `end`
  - `break condition` ... `end`
- `autonumber` enables automatic message numbering.
- Actor color: `rect rgb(240,240,240)` ... `end` for a colored region.

### Common sequence breakers
- Missing `end` after `loop`/`alt`/`opt`/`par`/`critical`/`break`/`rect`.
- Message without the `:` — `A->>B text` is invalid; must be `A->>B: text`.
- Reserved actor name `end` → rename.
- Smart quotes in message text.

---

## Class diagram (`classDiagram`)

- Header: `classDiagram` (or `classDiagram-v2` for newer features).
- Class: `class Name { ... }` — the braces enclose members.
- Members (one per line inside braces, indentation optional):
  - Field: `+type name`  `+name: type`
  - Method: `+name()`
  - Visibility prefixes: `+` public, `-` private, `#` protected, `~` package.
- Relationships (with cardinalities):
  - `A <|-- B`  inheritance
  - `A *-- B`  composition
  - `A o-- B`  aggregation
  - `A --> B`  association
  - `A ..> B`  dependency (dotted)
  - `A ..|> B`  realization
  - With labels: `A "1" -- "many" B : owns`
- `class A <<interface>>` stereotyping.
- `namespace GroupName { ... }` for packages.

### Common class breakers
- Empty `{}` for a class — either include members or omit the block entirely
  (`class A` on its own line is valid).
- Missing `:` in method signatures inside the block.
- Cardinality quotes not paired: `A "1" -- B` missing the second quoted label
  is fine but mixing quoted/unquoted in one diagram confuses readers — be
  consistent.

---

## State diagram (`stateDiagram-v2`)

- Header: `stateDiagram-v2` (use `-v2`; the original `stateDiagram` is legacy).
- States: `[*]` for start/end pseudo-states; `stateName` plain.
- Transitions: `A --> B : event` / `A --> B`.
- Composite states: `state Big { ... }` with nested transitions — needs `end`
  if using the block form.
- Notes: `note left of A : text` / `note right of A : text`
  `note left of A` ... `end note` (multi-line); ends with `end note`.
- Concurrent: separate regions with `--` inside a composite state.

### Common state breakers
- Missing `end` after a composite `state X { ... }`.
- Missing `end note` after a multi-line note.
- Using `end` as a state name → use `done` or `endState`.

---

## ER diagram (`erDiagram`)

- Header: `erDiagram`.
- Entities: `ENTITY { ... }` with attributes one per line:
  - `type name PK`
  - attribute keys: `PK`, `FK`, `UK` (primary/foreign/unique) optional.
  - Type first: `string name`, `int id`, etc.
- Relationships: `A ||--o{ B : "labels here"`
  - Cardinality parts: `||` (one and only one), `}|` (one or more), `o{` (zero
    or more), `o|` (zero or one) — left and right separated by `--`.
  - Examples: `A ||--|| B`, `A }o--o{ B`, `A ||--o{ B : "has"`.
- Relationship labels support comments: `A ||--o{ B : "has" "comment"`.

### Common ER breakers
- Cardinality ordering wrong (`o--||` reversed) — left entity is matched by
  the left cardinality.
- Entity block never closed — the `{ ... }` must balance.
- Attribute line missing type: `name PK` → must be `string name PK`.

---

## Gantt (`gantt`)

- Header: `gantt` then a config block:
  ```
  dateFormat YYYY-MM-DD
  title My Gantt
  ```
- Sections: `section Name` followed by tasks.
- Tasks: `Task name :id, start, duration` or `Task :id, after prevTask, dur`.
  - Status flags after the id: `done`, `crit`, `active`, `milestone`: e.g.
    `Task :id, start, 2d` / `Task :crit, id2, start, 3d`
- `excludes weekends`, `axisFormat %Y-%m-%d` etc. are config keys before the
  first section.

### Common Gantt breakers
- Missing `dateFormat` → the parser can't resolve start dates.
- Task id reused across tasks → each id must be unique.
- `after prevTask` referencing an id that doesn't exist.

---

## Mindmap (`mindmap`)

- Header: `mindmap`.
- Tree via indentation level (use consistent 2-space or tab indentation).
- Root first, then indented children.
- Optional shape decorators: `root((text))`, `[text]`, `(text)`, `))text((`,
  `{{text}}`, etc. — same shape semantics as flowchart nodes; never empty.
- Icons: `::icon()` after a node line.

### Common mindmap breakers
- Inconsistent/ambiguous indentation — mermaid is whitespace-sensitive here;
  pick one indent unit (2 spaces) and stick with it.
- Empty shape parentheses.

---

## Pie chart (`pie`)

- Header: `pie` then optional `title X`.
- Lines: `"Label" : value` — the label **must** be quoted, value is a number.
- No trailing comma.

### Common pie breakers
- Unquoted labels (`Label : 5` is invalid — must be `"Label" : 5`).
- Non-numeric values.

---

## Journey / User journey (`journey`)

- Header: `journey` then `title X`.
- Sections: `section Name`.
- Steps: `Task name: 5: Actor1, Actor2`
  - format is `description : score : comma,separated,actors`
  - score is a number 1–5.
- Tasks must be indented under their section.

### Common journey breakers
- Missing `:` separating score from description.
- Score in the wrong position.

---

## Git graph (`gitGraph`)

- Header: `gitGraph` then optional `commit`, `branch`, `merge`, `checkout`,
  `cherry-pick`, `tag`, `reset`.
- `commit id: "x"` / `commit tag: "y"`.
- `branch newBranch` then `checkout newBranch` then commit.
- `merge newBranch`.

### Common gitGraph breakers
- Commands not on their own line.
- Referencing a branch that doesn't exist (checkout before branch creation).

---

## General fixes for any unrecognized grammar error

1. Read the validator's `error` field — it usually names the offending token.
2. **Quote** that label / node text and re-run.
3. If quoting doesn't help, check brace/subgraph/end balance — print the file
   with `cat -n` and tally `subgraph` vs `end`, `{` vs `}`, `(` vs `)`, `[` vs
   `]`, `|` opens vs closes.
4. Drop decoration (color/style lines) and re-validate the bare structure
   first, then add pizzazz back one piece at a time.
5. When in doubt, minimize: cut the diagram down to the failing fragment and
   fix it in isolation.