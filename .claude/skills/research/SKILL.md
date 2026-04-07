---
name: research
description: "AnchoredAutoResearch: Phase-gated research protocol with human checkpoints, prediction discipline, knowledge sources, and autonomous execution. Manages the full research cycle: plan → execute → interpret."
version: 1.0.0
---

# AnchoredAutoResearch — Phase-Gated Research Protocol

Inspired by [autoresearch](https://github.com/uditgoenka/autoresearch). Applies autonomous iteration to research — but with human checkpoints at decision boundaries, prediction-before-execution discipline, and mandatory knowledge source citation.

**Core idea:** Knowledge → Plan → Predict → Execute → Interpret → Human Review → Repeat.

## MANDATORY: Read Protocol Before Any Action

**CRITICAL — READ THIS FIRST:**

For ALL commands (`/research`, `/research:plan`, `/research:execute`, `/research:context`):

1. Read `CLAUDE.md` for project rules
2. Read `RSD.md` to determine current state (create if missing → INIT phase)
3. Read `context/SOURCES.md` if it exists — check for unread knowledge sources
4. Follow the appropriate protocol from the references/ directory

## Subcommands

| Subcommand | Purpose | Reference |
|------------|---------|-----------|
| `/research` | Main state machine — dispatches to current phase | `references/phase-protocol.md` |
| `/research:adopt` | Anchor the protocol to an in-progress project (existing LaTeX + git + logs) — imports as read-only Cycle 1 | `references/adopt-protocol.md` |
| `/research:plan` | Interactive experiment design wizard (Goal→Scope→Metric→Verify→Guard) | `references/phase-protocol.md` (PLAN section) |
| `/research:execute` | Fast execution loop (modify→commit→verify→guard→decide→log) or manual execution | `references/autonomous-loop.md` |
| `/research:context` | Manage knowledge sources — add, read, index papers/notes/prior work | `references/knowledge-sources.md` |

## State Machine

The main `/research` command reads RSD.md and dispatches based on status:

```
/research invoked
  │
  ├─ No RSD.md
  │     ├─ User input contains existing-project signals
  │     │  (".tex", "draft", "have code", "logs", path-like strings)
  │     │    → offer ADOPT: "You seem to have an in-progress project.
  │     │                    ADOPT it instead of starting fresh?
  │     │                    (strict / fully-auto / no)"
  │     │       ├─ User accepts → ADOPT (references/adopt-protocol.md)
  │     │       └─ User declines → INIT
  │     └─ Otherwise → INIT (ask goal, read context/, create RSD)
  │
  ├─ Phase: ADOPT → load references/adopt-protocol.md
  │
  ├─ Status: WAITING_HUMAN
  │     ├─ No explicit human approval/revision in chat or RSD → remind human, STOP
  │     └─ Approval or revision found → advance to next phase
  │
  ├─ Phase: PLAN → load references/phase-protocol.md (PLAN section)
  ├─ Phase: EXECUTE → load references/autonomous-loop.md
  ├─ Phase: INTERPRET → load references/phase-protocol.md (INTERPRET section)
  │
  └─ Status: BLOCKED → show reason, STOP
```

The ADOPT offer is a soft heuristic. The main state machine never runs
ADOPT without explicit user consent. See `references/adopt-protocol.md` for
detection signals, pre-flight checks, and the strict/fully-auto write-outs.

## Common Rules (Apply to ALL Subcommands)

Load and follow: `references/core-principles.md`

Summary of non-negotiable rules:
1. **RSD.md is the single source of truth** — all claims written there
2. **Predictions BEFORE execution** — git history must show prediction commits first
3. **Artifact-linked claims only** — every result has a file pointer + metric
4. **Append-only within cycles** — past phases are immutable
5. **Bounded execution only** — NEVER run unbounded loops; human must review
6. **No self-approval** — only explicit human approval or revision in chat or RSD.md counts
7. **Compile after every RSD write** — run `bash scripts/compile_rsd.sh`
8. **Git commit at every phase boundary** — per-experiment commits during EXECUTE

## RSD Format

Load: `references/rsd-schema.md` for the full RSD template and section definitions.

## Dual-Format System

- AI writes `RSD.md` (markdown) — source of truth
- `scripts/compile_rsd.sh` converts RSD.md → RSD.tex → RSD.pdf deterministically
- Human reads `RSD.pdf` for formatted view (status badges, tables, decision boxes)
- Human can approve or revise in chat or by editing `RSD.md`
- AI NEVER writes LaTeX directly — only markdown

## Codex Review Integration

After EXECUTE phase completes, use the code review tool to review changed files:
- Send the git diff to Codex for code review
- Write the review summary to RSD under EXECUTE section
- Human reads the Codex summary instead of reviewing code directly

## Knowledge Sources

Load: `references/knowledge-sources.md` for the full protocol.

Before ANY experiment proposal, the agent MUST:
1. Check `context/SOURCES.md` for unread sources
2. Read all unread sources
3. Cite relevant sources in every proposal
