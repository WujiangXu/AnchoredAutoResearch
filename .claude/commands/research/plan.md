---
name: research:plan
description: "Interactive experiment design wizard. Builds a complete PLAN section for RSD: Goal→Scope→Metric→Verify→Guard→Prediction→Confirm."
argument-hint: "[goal description]"
---

EXECUTE IMMEDIATELY — do not deliberate before reading the protocol.

## Argument Parsing

Extract from $ARGUMENTS:
- Goal text — if user provides it inline, use as starting point
- Any flags: `--scope`, `--metric`, `--verify`, `--guard`, `--mode`

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

### Step 2: Analyze Context
- Read codebase structure and existing code
- Read knowledge sources — what does prior work suggest?
- Identify relevant tools, frameworks, metrics

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
1. Write PLAN section to RSD.md (per phase-protocol.md format)
2. Set Status: WAITING_HUMAN
3. Compile PDF
4. Git commit: "research: cycle N plan"
5. STOP — human reviews and approves in RSD.md

Stream all output live. Never run in background.
