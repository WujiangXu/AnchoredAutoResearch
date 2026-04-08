---
name: research:plan
description: "Interactive experiment design wizard. Builds a complete PLAN section for RSD: Goal→Scope→Metric→Verify→Guard→Prediction→Confirm. Supports --effort low|middle|high."
argument-hint: "[goal description] [--effort low|middle|high]"
---

EXECUTE IMMEDIATELY — do not deliberate before reading the protocol.

## Argument Parsing

Extract from $ARGUMENTS:
- Goal text — if user provides it inline, use as starting point
- Any flags: `--scope`, `--metric`, `--verify`, `--guard`, `--mode`, `--effort`
- `--effort low|middle|high` — exploration breadth for the ideation step.
  Default: `low` (backward-compatible, same as before the flag was added).
  See `phase-protocol.md` `### Effort levels` for the per-level protocol.
  Validate: if `--effort` is present, value MUST be one of `low`, `middle`,
  `high`. Reject any other value with: "unknown effort level — use low,
  middle, or high".

## Execution

1. Read `.claude/skills/research/references/phase-protocol.md` (PLAN section)
2. Read `.claude/skills/research/references/knowledge-sources.md`
3. Read `RSD.md` — verify we are in PLAN phase (or can enter it)
4. Read `context/SOURCES.md` — check for knowledge sources
5. Read any unread sources in `context/`

## Interactive Wizard (7 Steps)

Adapted from autoresearch:plan. Use `AskUserQuestion` when context is missing.

### Step 1: Capture Goal
If no goal inline, ask:
- What are we trying to achieve?
- Link to which hypothesis in the RSD?

### Step 2: Analyze Context + Ideate at the chosen effort level
- Read codebase structure and existing code
- Read knowledge sources — what does prior work suggest?
- Identify relevant tools, frameworks, metrics
- **Branch on effort level** (see `phase-protocol.md` `### Effort levels`
  for the full per-level protocol):
  - `low` (default) → one proposal tied to the user's stated goal. No
    candidate generation. Continue to Step 3.
  - `middle` → optionally offer `/research:context search` if SURVEY.md
    is thin; generate 2-3 adjacent candidates; rank by
    relevance × novelty × feasibility; silently pick the best; remember
    the rejected candidates for Step 7's `**Alternatives considered:**`
    field.
  - `high` → fire the cost gate FIRST (`"This will use significantly more
    tokens. Proceed?"`); on yes, optionally offer `/research:context
    search`; generate 5-8 candidates spanning 3+ sub-topics with at
    least one combination candidate and at least one cross-field
    candidate when plausible; score each on novelty/feasibility/relevance
    (1-5 each); present the top 5-8 via `AskUserQuestion` with a "You
    pick (highest combined score)" delegation option; use the chosen
    candidate as the seed for Steps 3-6.

### Step 3: Define Scope
Present scope options:
- Which files will be modified?
- Validate: scope resolves to at least 1 file
- Warn if scope > 50 files

### Step 4: Define Metric + Direction
- What number tells us if things got better?
- Must be mechanical (extractable by command)
- Higher or lower is better?

### Step 5: Define Verify + Guard Commands
- Construct verify command that runs experiment and extracts metric
- Optionally: guard command for regression check
- **Dry-run the verify command** — must exit 0 and output a number
- Record baseline metric

### Step 6: Write Prediction
**MANDATORY — this is the anti-gaming mechanism.**
- Specific predicted outcome (numbers, ranges)
- What a wrong prediction would imply
- Grounded in which knowledge source

### Step 7: Confirm + Write to RSD
Present complete plan, ask for confirmation, then:
1. Write PLAN section to RSD.md (per phase-protocol.md format) — include
   the two effort-related fields:
   - `**Effort level:**` — the effort level used for this invocation
     (`low` / `middle` / `high`)
   - `**Alternatives considered:**` — for `middle` / `high`, bullet the
     rejected candidates from Step 2 with a one-line reason each; for
     `low`, write `N/A (low effort)`
2. Set Status: WAITING_HUMAN
3. Compile PDF
4. Git commit: "research: cycle N plan"
5. STOP — human reviews and can approve or revise in chat or RSD.md using any clear wording

Stream all output live. Never run in background.
