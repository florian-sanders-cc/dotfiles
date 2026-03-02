---
name: qa-analyze
description: Analyze smart component code for QA patterns and discuss findings with user
user-invocable: true
---

# QA Component Analyzer (Critical Analysis)

Analyze smart component code to verify patterns, identify edge cases, and discuss findings with the user.

**Key principle**: QA should verify that code matches **functional expectations**, not just document what code does.

## Usage

```
/qa-analyze <component-name>
```

Example: `/qa-analyze cc-addon-admin`

## Output

This skill produces a findings file: `QA-findings-<component-name>.md`

The findings file is used as input for `/qa-generate` to create the final QA test document.

## Instructions

When the user invokes this skill with a component name, follow these phases:

---

## Phase 1: Component Classification

Before analyzing code, classify the component type to establish expected behavior patterns:

| Component Type | Characteristics | Key Patterns to Verify |
|----------------|-----------------|------------------------|
| **Form Component** | Creates/submits data (forms, creation wizards) | Reset on success ONLY, preserve data on error |
| **Action Component** | Performs operations (delete, update buttons) | Confirmation for destructive actions, loading states |
| **List+CRUD Component** | List with add/edit/delete operations | Item-level states, optimistic updates |
| **Read-Only Component** | Displays data without modification | No action patterns needed |

**Use the `AskUserQuestion` tool** to confirm the component type if unclear from the component name. Present these options:

- **Form Component** - Creates/submits data (forms, creation wizards)
- **Action Component** - Performs operations (delete, update buttons)
- **List+CRUD Component** - List with add/edit/delete operations
- **Read-Only Component** - Displays data without modification

---

## Phase 2: Establish Expected Behavior Matrix

Based on component type, create a checklist of **expected behaviors** BEFORE reading code:

### Standard Patterns Reference

| Pattern | Expected Behavior | Where to Look |
|---------|-------------------|---------------|
| **Form reset** | ONLY on success, NEVER on error | `resetForm()` calls in smart.js |
| **Error state** | Preserves all form data for retry | `.catch()` blocks should NOT reset |
| **Success toast** | `notifySuccess()` - auto-dismiss | After successful operations |
| **Error toast** | `notifyError()` - auto-dismiss | In `.catch()` blocks |
| **Info toast** | `notify({ timeout: 0, closeable: true })` - persistent | User-actionable info |
| **Loading states** | Three-state: idle → loading → idle | `updateComponent()` calls |
| **State cleanup** | Guaranteed state reset (via `.finally()`, `.catch()`, or both paths) | Ensures no stuck states |
| **Field errors** | API errors → specific form field errors | Error mapping in catch blocks |
| **Event dispatch** | `dispatchEvent()` after significant operations | Parent notification |
| **Initialization** | Explicit state setup during component setup | `onContextUpdate()` or constructor |

### Expected Patterns by Component Type

**Form Component** must have:
- [ ] `resetForm()` called ONLY in success path
- [ ] `.catch()` blocks preserve form data
- [ ] Loading state reset is guaranteed (`.finally()`, `.catch()`, or both paths)
- [ ] `dispatchEvent()` after successful creation
- [ ] Success toast on completion
- [ ] Error toast on failure

**Action Component** must have:
- [ ] Loading state during operation
- [ ] Loading state reset is guaranteed (`.finally()`, `.catch()`, or both paths)
- [ ] Success/error toasts
- [ ] `dispatchEvent()` after successful action
- [ ] Confirmation dialog for destructive actions

**List+CRUD Component** must have:
- [ ] Item-level loading states
- [ ] Optimistic updates OR loading indicators
- [ ] Error recovery per item
- [ ] List refresh after mutations

---

## Phase 3: Code Verification (Critical Analysis)

Read `smart.js` CRITICALLY to verify each expected behavior:

### 3.1 Locate Component Files

Find in `src/components/<component-name>/`:
- `<component-name>.smart.js` - Main logic to verify
- `<component-name>.stories.js` - Story exports for test states
- `<component-name>.smart.md` - Documentation and metadata

### 3.2 Critical Code Analysis

Search for these patterns and verify correctness:

1. **Reset Pattern Analysis**
   - Search for `resetForm()` or equivalent reset calls
   - Verify: Called ONLY in `.then()` success paths
   - Flag: Any `resetForm()` in `.catch()` blocks = **ISSUE**
   - Flag: Any `resetForm()` outside promise chains = **WARN**

2. **Error Handling Analysis**
   - Search for `.catch()` blocks
   - Verify: Should NOT call reset functions
   - Verify: Should call `notifyError()` or equivalent
   - Verify: Should preserve user input

3. **State Cleanup Analysis**
   - Search for `.finally()` blocks OR state reset in both `.then()` and `.catch()`
   - Verify: Loading state reset is guaranteed on ALL code paths
   - Flag: Loading state set but never reset on error path = **ISSUE**
   - Note: `.finally()` is preferred but `.catch()` handling state reset is valid

4. **Notification Analysis**
   - Search for `notifySuccess`, `notifyError`, `notify`
   - Verify: Correct notification type for each scenario
   - Flag: `notify()` with wrong timeout configuration = **WARN**

5. **Event Dispatch Analysis**
   - Search for `dispatchEvent()` or `this.dispatchEvent`
   - Verify: Dispatched after significant operations
   - Flag: No dispatch after create/update/delete = **MISSING**

6. **Loading State Analysis**
   - Search for state transitions (e.g., `updateComponent`, `_state =`)
   - Verify: Three states exist (idle, loading, result)
   - Flag: Only two states = **WARN**

---

## Phase 4: Adversarial Edge-Case Analysis

After pattern verification, actively hunt for edge cases the developer may have overlooked.

### Mindset
Think like a hostile user or unstable network. Ask: "What could break this that isn't already handled?"

### Edge-Case Categories to Investigate

**Timing & Race Conditions:**
- What if user double-clicks/rapid-fires the submit button?
- What if user navigates away mid-request?
- What if two requests complete out of order?
- What if component unmounts during async operation?

**Network & Connectivity:**
- What if network drops mid-request (not before)?
- What if request times out (very slow, not failed)?
- What if API returns unexpected status (429, 503)?
- What if response is malformed/partial?

**User Behavior:**
- What if user uses browser back/forward during operation?
- What if user refreshes page mid-operation?
- What if user opens same component in two tabs?
- What if user pastes invalid data into fields?
- What if user submits with only whitespace?

**State Machine Gaps:**
- What states can the component be in?
- Are there any impossible-to-escape states?
- What happens if props change while in loading state?
- What if context updates during an operation?

**Input Boundaries:**
- What if required fields are empty strings?
- What if string inputs are extremely long?
- What if numeric inputs are 0, negative, or MAX_INT?
- What if special characters (quotes, slashes, unicode) are used?

**Missing Handling:**
- What if the API returns an empty array vs null vs undefined?
- What if optional data is missing?
- What if IDs don't match expected format?

### Analysis Output

For each relevant category, note:
- [ ] Investigated - No concerns
- [ ] Potential issue found → Add to Phase 5 findings
- [ ] N/A - Not applicable to this component type

---

## Phase 5: Generate Critical Findings Report

Before discussing with user, produce a verification report:

### Pattern Compliance Table Format

```markdown
### Pattern Compliance

| Pattern | Expected | Found | Status |
|---------|----------|-------|--------|
| Form reset on success | Reset in .then() only | [what was found] | [OK/WARN/ISSUE/MISSING] |
| Error preserves data | No reset in .catch() | [what was found] | [OK/WARN/ISSUE/MISSING] |
| State cleanup | Guaranteed state reset on all paths | [what was found] | [OK/WARN/ISSUE/MISSING] |
| Success notification | notifySuccess() | [what was found] | [OK/WARN/ISSUE/MISSING] |
| Error notification | notifyError() | [what was found] | [OK/WARN/ISSUE/MISSING] |
| Event dispatch | dispatchEvent() present | [what was found] | [OK/WARN/ISSUE/MISSING] |
```

### Status Meanings

- `[OK]` - Pattern found and correctly implemented
- `[WARN]` - Pattern present but non-standard implementation
- `[ISSUE]` - Potential bug or clear deviation from patterns
- `[MISSING]` - Expected pattern not found in code

---

## Phase 6: Critical Questions (BLOCKING)

**STOP and use the `AskUserQuestion` tool** to ask about each WARN, ISSUE, or MISSING finding before proceeding.

### For Pattern Deviations

For each deviation found, first present context to the user, then use `AskUserQuestion` with these options:

**Context to present** (as regular text before the question):
```
I found the following deviation from expected patterns:

**[ISSUE/WARN/MISSING]**: [Description of what was found]

Expected behavior: [What the pattern should be]
Actual code: [What the code does]
Risk: [Potential impact if this is a bug]
```

**Then use `AskUserQuestion`** with header "Finding" and these options:
- **Intentional** - Document as expected behavior (component has special requirements)
- **A bug** - Flag for developer fix, add regression test case
- **Uncertain** - Mark as "VERIFY" item for investigation

### For Edge-Case Concerns

For edge-case concerns (from Phase 4), present context then use `AskUserQuestion`:

**Context to present** (as regular text before the question):
```
**[EDGE CASE]**: {Scenario description}

Potential issue: {What could go wrong}
Code check: {Whether any handling exists}
Risk level: Low/Medium/High
```

**Then use `AskUserQuestion`** with header "Edge Case" and these options:
- **Already handled** - Code handles this (show me where)
- **Acceptable risk** - Document as known limitation
- **Should test** - Add to edge-case test category
- **Needs fix** - Flag for developer

**Do NOT proceed to findings file generation until all deviations are resolved.**

Store the resolution for each finding:
- Intentional → Note in findings as "by design"
- Bug → Add to findings with "BUG" flag
- Uncertain → Add to findings as "SHOULD_TEST"

---

## Phase 7: Generate Findings File

After all findings are resolved, generate the findings file.

### Output File

Create file: `QA-findings-<component-name>.md`

### File Format

```markdown
# QA Findings: <component-name>

## Component Classification
- **Type**: [Form Component | Action Component | List+CRUD Component | Read-Only Component]
- **Characteristics**: [brief description]

## Pattern Compliance

| Pattern | Status | Code Location | Notes |
|---------|--------|---------------|-------|
| Form reset on success | [OK/WARN/ISSUE/MISSING] | [file:line] | [details] |
| Error preserves data | [OK/WARN/ISSUE/MISSING] | [file:line] | [details] |
| State cleanup | [OK/WARN/ISSUE/MISSING] | [file:line] | [details] |
| Success notification | [OK/WARN/ISSUE/MISSING] | [file:line] | [details] |
| Error notification | [OK/WARN/ISSUE/MISSING] | [file:line] | [details] |
| Event dispatch | [OK/WARN/ISSUE/MISSING] | [file:line] | [details] |

## Edge Cases Investigated

| Scenario | Status | Notes |
|----------|--------|-------|
| Double-click submit | [OK/UNTESTED/CONCERN] | [details] |
| Network timeout | [OK/UNTESTED/CONCERN] | [details] |
| Navigate away mid-request | [OK/UNTESTED/CONCERN] | [details] |
| [other relevant scenarios] | ... | ... |

## Resolutions

| Finding | Decision | Rationale |
|---------|----------|-----------|
| [Description] | [INTENTIONAL/BUG/UNCERTAIN/SHOULD_TEST] | [User's reasoning] |

## Additional Notes

[Any other observations from analysis]
```

---

## Completion

After generating the findings file, inform the user:

```
Analysis complete! Findings saved to: QA-findings-<component-name>.md

To generate the QA test document (HTML), run:
/qa-generate <component-name>
```
