# QA Skills for Claude Code -- Setup & Usage Guide

## What are these skills?

Two skills that automate QA analysis of smart components in the `clever-components` project:

1. **`qa-analyze`** -- Analyzes a smart component's code for pattern compliance, edge cases, and potential bugs. Produces a findings file (`QA-findings-<component>.md`).
2. **`qa-generate`** -- Takes the findings file and generates a structured HTML QA test document (`QA-<component>.html`) ready for manual testing across browsers.

## Prerequisites

- [Claude Code](https://docs.anthropic.com/en/docs/claude-code/overview) installed and working
- The `clever-components` project cloned locally

## Setup

### Step 1: Create the skill directories

```bash
mkdir -p ~/.claude/skills/qa-analyze
mkdir -p ~/.claude/skills/qa-generate
```

Placing them in `~/.claude/skills/` makes them available across all your projects. Alternatively, place them in the project's `.claude/skills/` directory to keep them project-scoped (and potentially committed to version control).

### Step 2: Copy the skill files

Get the two `SKILL.md` files from a colleague who already has them and copy them into the directories you just created:

```bash
cp /path/to/qa-analyze/SKILL.md  ~/.claude/skills/qa-analyze/SKILL.md
cp /path/to/qa-generate/SKILL.md ~/.claude/skills/qa-generate/SKILL.md
```

Each skill is a single `SKILL.md` file -- no other dependencies needed.

### Step 3: Verify

Open Claude Code in the `clever-components` project and ask:

```
What skills are available?
```

You should see `qa-analyze` and `qa-generate` listed.

## Usage

### Step 1: Analyze a component

```
/qa-analyze cc-addon-admin
```

This will:

1. Classify the component type (form, action, list+CRUD, read-only) -- it may ask you to confirm
2. Establish expected behavior patterns based on the type
3. Read and critically analyze the `*.smart.js` code
4. Hunt for edge cases (race conditions, network issues, state gaps)
5. Ask you about each deviation or concern found (blocking questions)
6. Generate `QA-findings-cc-addon-admin.md` in the current directory

**Important**: The analysis is interactive. Claude will ask you questions about findings (e.g., "Is this intentional or a bug?"). Answer these before it proceeds.

### Step 2: Generate the QA test document

```
/qa-generate cc-addon-admin
```

This will:

1. Read the findings file from step 1
2. Ask you a few setup questions:
   - Which staging environment to use (staging 1-7 or custom URL)
   - Which test organization (ACME FOO, ACME BAR, or custom)
   - The resource path after the org ID (e.g., `/addons/addon_xxx/settings`)
   - Optional Figma link
   - Current QA status
3. Generate `QA-cc-addon-admin.html`

The HTML file contains tables grouped by category (Loading States, Error Loading, Pattern Verification, Functional Tests, Edge Cases, etc.) with columns for Chrome/Firefox/Safari results and remarks.

Open it in a browser or paste the HTML into Notion for collaborative QA.

## Typical workflow

```
cd ~/Projects/clever-components
claude                           # start Claude Code

/qa-analyze cc-tcp-redirections  # analyze the component
# ... answer Claude's questions about findings ...

/qa-generate cc-tcp-redirections # generate test document
# ... answer setup questions (staging env, org, path) ...

# Output: QA-cc-tcp-redirections.html
```

## Customization notes

- Both skills use Claude Code's interactive question feature to collect context and resolve ambiguities during execution.
- The staging URLs and test orgs in `qa-generate` are hardcoded to Clever Cloud's environments. Edit `~/.claude/skills/qa-generate/SKILL.md` if yours differ.
- Skills work best with components that have a `*.smart.js` file (smart components with data-fetching logic).

## Sharing options

- **Per-project**: Put the skills in `.claude/skills/qa-analyze/` and `.claude/skills/qa-generate/` within the repo and commit them. Everyone who clones the repo gets the skills automatically.
- **Personal only**: Keep them in `~/.claude/skills/` (not committed, available across all projects on that machine).
