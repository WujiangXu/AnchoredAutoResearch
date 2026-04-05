---
name: research-plan
description: "AnchoredAutoResearch planning wizard for Codex. Builds the PLAN section with scope, metrics, verify/guard commands, predictions, and human approval gates."
version: 1.0.0
---

# AnchoredAutoResearch — PLAN Entrypoint

Use this skill when the user invokes `$research-plan` in Codex.

## MANDATORY: Read Protocol Before Any Action

1. Read `AGENTS.md` for project rules
2. Read `RSD.md` to determine current state (create if missing only via INIT in `../research/references/phase-protocol.md`)
3. Read `context/SOURCES.md` if it exists
4. Follow the PLAN section in `../research/references/phase-protocol.md`
5. Follow `../research/references/knowledge-sources.md` for source-reading requirements

## Execution

1. Treat any remaining user text as inline goal or planning context
2. Verify the project is in PLAN or can safely enter PLAN from INIT
3. Read unread sources in `context/`
4. Build the PLAN entry with:
   - goal and hypothesis linkage
   - grounded-in source citation
   - prediction before execution
   - verify and guard commands
   - execution mode
5. Set `Status: WAITING_HUMAN`
6. Run `bash scripts/compile_rsd.sh`
7. Commit the phase boundary
8. Stop and tell the human to approve or revise in chat or `RSD.md` using any clear wording
