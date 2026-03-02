---
name: qa-generate
description: Generate QA test document from findings file
user-invocable: true
---

# QA Test Document Generator

Generate QA testing documents from a findings file produced by `/qa-analyze`.

## Usage

```
/qa-generate <component-name>
```

Example: `/qa-generate cc-addon-admin`

## Prerequisites

This skill requires a findings file: `QA-findings-<component-name>.md`

If the findings file doesn't exist, prompt the user to run `/qa-analyze <component-name>` first.

## Instructions

When the user invokes this skill with a component name, follow these phases:

---

## Phase 1: Load Findings

### 1.0 Check Notion Token

Before anything else, check whether the `NOTION_TOKEN` environment variable is set.

**IMPORTANT: NEVER output, echo, or log the value of `NOTION_TOKEN`. The token is a secret and must not appear in the conversation.** To check if it is set, use a command that only tests existence:

```bash
test -n "$NOTION_TOKEN" && echo "SET" || echo "NOT_SET"
```

- If **set**: Notion push will happen automatically in the Completion phase. No message needed now -- just continue.
- If **missing**: Use `AskUserQuestion` with header "Notion Token" and question "NOTION_TOKEN is not set. Notion push requires this env var to create QA entries automatically. Continue with CSV-only output?":
  - **Continue without Notion** - Generate CSV file only (manual import)
  - **Stop** - I'll set up the token first

If the user selects "Stop", end the skill with a message explaining they need to set `NOTION_TOKEN` and re-run.

If the user selects "Continue without Notion", proceed normally but remember to skip Notion push in the Completion phase.

### 1.1 Check for Findings File

Look for `QA-findings-<component-name>.md` in the current directory.

If not found:
```
No findings file found for <component-name>.

Please run the analysis first:
/qa-analyze <component-name>

This will analyze the component and generate the findings file needed for test generation.
```

### 1.2 Parse Findings

Read and parse the findings file to extract:
- Component type and characteristics
- Pattern compliance table
- Edge cases investigated
- Resolutions from user discussion

---

## Phase 2: Collect Test Context (Interactive)

**Use the `AskUserQuestion` tool** to collect test context information. All questions have `custom` enabled, so the user can always type their own answer if none of the predefined options fit.

### Question 1: Staging Environment
Use `AskUserQuestion` with header "Staging" and question "Which staging environment should be used? (pick a number, or type a full custom URL)":
- **Staging 1** - `https://console-staging-one.cleverapps.io/`
- **Staging 2** - `https://console-staging-two.cleverapps.io/`
- **Staging 3** - `https://console-staging-three.cleverapps.io/`
- **Staging 4** - `https://console-staging-four.cleverapps.io/`
- **Staging 5** - `https://console-staging-five.cleverapps.io/`
- **Staging 6** - `https://console-staging-six.cleverapps.io/`
- **Staging 7** - `https://console-staging-seven.cleverapps.io/`

Map the selected option to its URL. If the user types a custom answer, use it as-is for `{base_url}`.

| Selection | `{base_url}` |
|-----------|-------------|
| Staging 1 | `https://console-staging-one.cleverapps.io` |
| Staging 2 | `https://console-staging-two.cleverapps.io` |
| Staging 3 | `https://console-staging-three.cleverapps.io` |
| Staging 4 | `https://console-staging-four.cleverapps.io` |
| Staging 5 | `https://console-staging-five.cleverapps.io` |
| Staging 6 | `https://console-staging-six.cleverapps.io` |
| Staging 7 | `https://console-staging-seven.cleverapps.io` |

### Question 2: Test Organization
Use `AskUserQuestion` with header "Test Org" and question "Which test organization should be used? (or type your own org ID)":
- **ACME FOO** - `orga_540caeb6-521c-4a19-a955-efe6da35d142`
- **ACME BAR** - `orga_3547a882-d464-4c34-8168-add4b3e0c135`

Map the selected option to its org ID. If the user types a custom answer, use it as-is for `{org_id}`.

| Selection | `{org_id}` |
|-----------|-----------|
| ACME FOO | `orga_540caeb6-521c-4a19-a955-efe6da35d142` |
| ACME BAR | `orga_3547a882-d464-4c34-8168-add4b3e0c135` |

### Question 3: Resource Path
Use `AskUserQuestion` with header "Resource Path" and question "What is the path after the organisation ID? (e.g., /network-groups/ng_xxx, /addons/addon_xxx/settings, /applications/app_xxx)":
- No predefined options - this is always a custom text input. Provide an empty options array so the user must type their answer.

Store the answer as `{resource_path}`. Ensure it starts with `/` (prepend if the user omits it).

### URL Composition

After collecting the three answers above, compose the full test URL:

```
{base_url}/organisations/{org_id}{resource_path}
```

Example:
```
https://console-staging-three.cleverapps.io/organisations/orga_3547a882-d464-4c34-8168-add4b3e0c135/network-groups/ng_f9a4ea60-be1f-47f5-bb93-3363a3afa4b4
```

Store this composed URL as `{test_url}` and use it in all test case steps throughout Phase 3.

### Question 4: Figma Link (Optional)
Use `AskUserQuestion` with header "Figma" and question "Is there a Figma design reference for this component?":
- **No Figma link** - No design reference available
- **Has Figma link** - I'll provide the URL (select the custom option to enter)

### Question 5: Component Status
Use `AskUserQuestion` with header "Status" and question "What is the current QA status of this component?":
- **To Test** - Not yet tested
- **In Progress** - Testing is ongoing
- **Done** - Testing completed

---

## Phase 3: Test Case Generation

Generate test cases grouped by category. Each row in the output CSV is tagged with its category via the `Phase/Group` column.

### Test Categories (in order)

1. **Loading States** - Skeleton mode, initial loading
2. **Error Loading** - Error states when data fails to load
3. **Pattern Verification** - Verifying expected code patterns work correctly
4. **Functional Tests** - Core feature tests (actions, submissions, state transitions)
5. **Edge Cases** - Boundary conditions, race conditions, unusual user behavior
6. **Deviation Investigation** - Items needing manual verification (WARN/ISSUE/UNCERTAIN findings)
7. **Known Issues** - Confirmed bugs to document
8. **Design Verification** - Figma compliance (only if Figma link provided)

Only include categories that have test cases. Skip empty categories.

### 3.1 Pattern Verification Tests (from compliance table)

For each `[OK]` pattern, create verification test:
```
Name: [Pattern name] verification
Action details: [Steps to trigger the pattern]
Expectation: [Expected behavior based on pattern]
```

For each `[WARN]` or `[ISSUE]` pattern, create investigation test (goes in Deviation Investigation category):
```
Name: [VERIFY] [Pattern name]
Action details: [Steps to test the pattern]
Expectation: INVESTIGATE: [What to look for based on finding]
```

### 3.2 Functional Tests (from stories and events)

Read the component's stories file and smart.js to generate:
- Story-based tests (loading, error, data states)
- Event-triggered tests (actions, submissions)
- State transition tests

Use these templates:

**Skeleton Mode** (Loading States category):
```
Name: Skeleton mode
Action details: 1. Go to {test_url}
Expectation: The component displays in skeleton mode before data loads.
```

**Error Loading** (Error Loading category):
```
Name: Error loading
Action details: 1. Block requests to api.clever-cloud.com
2. Go to {test_url}
Expectation: An error notice is displayed.
```

**Action Success** (Functional Tests category):
```
Name: {action_name} (success)
Action details: 1. Go to {test_url}
2. {trigger_action}
Expectation: 1. The component goes into waiting mode.
2. {success_behavior}
3. A success toast is displayed.
4. {event_dispatched if applicable}
```

**Action Error** (Functional Tests category):
```
Name: {action_name} (error)
Action details: 1. Go to {test_url}
2. Block requests to api.clever-cloud.com
3. {trigger_action}
Expectation: 1. The component goes into waiting mode.
2. An error toast is displayed.
3. The component returns to loaded state.
4. Form data is preserved (if applicable).
```

### 3.3 Deviation Investigation Tests (from resolutions)

For items marked "UNCERTAIN" or "SHOULD_TEST" in resolutions:
```
Name: [VERIFY] {description}
Action details: [Steps to investigate]
Expectation: INVESTIGATE: {what to look for}
```

For items marked "BUG" (goes in Known Issues category):
```
Name: [BUG] {description}
Action details: [Steps to reproduce]
Expectation: KNOWN BUG: {expected incorrect behavior}
```

### 3.4 Edge-Case Tests (from edge cases investigated)

For each edge case marked `[UNTESTED]` or `[CONCERN]`:
```
Name: {scenario}
Action details: [Steps to reproduce edge case]
Expectation: [Expected behavior - may be "VERIFY: behavior undefined"]
```

Common edge-case test templates:

**Double Submit Prevention:**
```
Name: Double-click submit prevention
Action details: 1. Fill form with valid data
2. Rapidly double-click submit button
Expectation: Only one request is sent, no duplicate creates
```

**Mid-Request Navigation:**
```
Name: Navigate away during request
Action details: 1. Trigger action
2. Immediately navigate away
3. Return to component
Expectation: No console errors, component in clean state
```

---

## Phase 4: Output Generation

Generate a single CSV file containing all test cases, with a `Phase/Group` column to categorize each row.

### 4.1 Output File

Create a single file: `QA-<component-name>.csv`

All test cases from all categories go into this one file. Each row has a `Phase/Group` value indicating which category it belongs to.

**Important**: Output is a CSV file designed for push to a Notion database. Not HTML, not markdown.

### 4.2 CSV Structure

The CSV file has **8 columns**, matching the target Notion database:

| Column | Purpose | Pre-filled? |
|--------|---------|-------------|
| Name | Short descriptive name of the test | Yes |
| Action details | Numbered steps to perform | Yes |
| Expectation | What should happen | Yes |
| Chrome | QA tester selects Ok/KO/Can't validate | No (empty) |
| FF | QA tester selects Ok/KO/Can't validate | No (empty) |
| Safari | QA tester selects Ok/KO/Can't validate | No (empty) |
| Other remarks | Free text for tester notes | No (empty) |
| Phase/Group | Category for grouping (see values below) | Yes |

**Phase/Group values** (use exactly these strings):
- `Loading states`
- `Error loading`
- `Pattern verification`
- `Functional tests`
- `Edge cases`
- `Deviation investigation`
- `Known issues`
- `Design verification`

### 4.3 CSV Template

The CSV uses RFC 4180 compliant format:

```csv
Name,Action details,Expectation,Chrome,FF,Safari,Other remarks,Phase/Group
{test name},"{step one}
{step two}
{step three}","{expected result}",,,,,{category}
```

**Key rules:**
- The header row must be exactly: `Name,Action details,Expectation,Chrome,FF,Safari,Other remarks,Phase/Group`
- Fields containing commas, double quotes, or newlines **must** be enclosed in double quotes
- Double quotes within fields must be escaped as `""` (two double quotes)
- Use actual newline characters (not `<br>`) within quoted fields for multi-line content -- these render as line breaks in Notion
- No HTML tags anywhere -- use plain text only
- Chrome, FF, Safari columns: leave empty (just commas)
- Other remarks: leave empty
- Phase/Group: always fill with the appropriate category value

### 4.4 Escaping Example

When a field contains both newlines and double quotes, escape the quotes by doubling them:

```csv
Name,Action details,Expectation,Chrome,FF,Safari,Other remarks,Phase/Group
Configure columns,"1. Import the CSV into Notion
2. For Chrome, FF, Safari columns: change property type to ""Select""
3. Add options ""Ok"", ""KO"", ""Can't validate""","Columns are configured as Select properties.",,,,,"Pattern verification"
```

In the example above, `""Select""` produces the literal text `"Select"` in Notion.

### 4.5 Formatting Rules

- Use actual newlines (not `<br>`) for line breaks within fields -- wrap the field in double quotes
- Keep the **Name** column concise (a few words, not a sentence)
- **Action details** should be numbered with actual newline characters between each step (inside double-quoted fields)
- **Expectation** should be numbered with newlines when there are multiple expected outcomes
- For `[VERIFY]` and `[BUG]` prefixes, keep them in the Name column
- Use plain text for API endpoints, URLs, or technical identifiers (no HTML `<code>` tags)
- Chrome/FF/Safari cells: leave empty (just consecutive commas in the CSV)
- Other remarks: leave empty
- Phase/Group: always set to the appropriate category value

---

## Storybook Reference

Include Storybook links for visual reference where applicable, as plain-text URLs in the Action details or Expectation fields:
- Base URL: `https://www.clever-cloud.com/doc/clever-components/`
- Story URL pattern: `?path=/story/{story-title}--{story-name}`

---

## Example Output

For a form component `cc-token-api-creation-form`, the output is a single file `QA-cc-token-api-creation-form.csv`:

```csv
Name,Action details,Expectation,Chrome,FF,Safari,Other remarks,Phase/Group
Skeleton mode,"1. Go to {test_url}","The form displays skeleton state before data loads.",,,,,Loading states
Error loading,"1. Block requests to api.clever-cloud.com
2. Go to {test_url}","An error notice is displayed.",,,,,Error loading
Error preserves form data,"1. Go to {test_url}
2. Fill form with test data
3. Block API
4. Submit form","1. Error toast is displayed.
2. Form data is preserved for retry.",,,,,Pattern verification
State cleanup,"1. Go to {test_url}
2. Disconnect network mid-request","Loading state resets on all paths.",,,,,Pattern verification
Token creation (success),"1. Go to {test_url}
2. Fill form
3. Submit","1. Component goes into waiting mode.
2. Token created, copy step shown.
3. A success toast is displayed.",,,,,Functional tests
Token creation (error),"1. Go to {test_url}
2. Block API
3. Submit form","1. Component goes into waiting mode.
2. An error toast is displayed.
3. Form data is preserved.",,,,,Functional tests
[VERIFY] Parent notification,"1. Go to {test_url}
2. Create token successfully","INVESTIGATE: Check if parent receives event notification.",,,,,Deviation investigation
```

---

## Phase 5: Cleanup

After generating the CSV file, **use the `AskUserQuestion` tool** to ask whether the intermediate findings file should be removed.

Use `AskUserQuestion` with header "Cleanup" and question "The findings file `QA-findings-<component-name>.md` was used to generate the CSV file. Do you want to remove it?":
- **Remove it** - Delete the findings file (it's captured in the CSV output now)
- **Keep it** - Keep the findings file for future reference

If the user chooses to remove it, delete `QA-findings-<component-name>.md` from the current directory.

---

## Completion

After generating the QA document (and handling cleanup), proceed as follows:

### If NOTION_TOKEN is available

Automatically push the CSV data to Notion by running the `notion-push.mjs` script. Do **not** prompt the user -- just run it.

Construct the command using metadata collected during the skill:
- `--csv`: path to the generated `QA-<component-name>.csv` file
- `--title`: `"QA <component-name>"` (from skill invocation)
- `--description`: the component description extracted from the findings file (Phase 1)
- `--staging`: the full `{test_url}` composed in Phase 2 (Question 1-3)
- `--figma`: the Figma URL from Phase 2 (Question 4); if no Figma link was provided, use `"https://none"`

**Timeout**: The script makes one API call per row with 500ms rate-limiting delays. Allow ~1 second per row when setting the Bash timeout (e.g., 26 rows -> at least 60s). Use 120s as a safe default.

Run:
```bash
node ~/.claude/skills/qa-generate/scripts/notion-push.mjs \
  --csv ./QA-<component-name>.csv \
  --title "QA <component-name>" \
  --description "<description>" \
  --staging "<test_url>" \
  --figma "<figma_url>"
```

If the script **succeeds**, display the Notion URLs from its output and remind the user:

```
Each test category appears as a separate inline table in the Notion page.
```

If the script **fails**, warn the user and fall back to the CSV-only message below.

### If NOTION_TOKEN is not available (or script failed)

Display the CSV file path and manual import instructions:

```
QA test document generated: QA-<component-name>.csv

To import into Notion:
1. In Notion, go to Settings > Import > CSV (or type /csv on a page)
2. Import the CSV file -- it becomes a single database table
3. For Chrome, FF, and Safari columns: change the property type to "Select" and add options Ok, KO, Can't validate
4. To separate categories into sub-tables, you'll need to manually split the imported table by Phase/Group values

Note: When using the automated Notion push (with NOTION_TOKEN), each Phase/Group category
is automatically created as a separate inline database with a colored title.

Line breaks within Action details and Expectation cells are preserved by Notion
when the CSV uses RFC 4180 quoted fields (which this file does).
```
