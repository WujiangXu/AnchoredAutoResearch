---
name: research-execute
description: "AnchoredAutoResearch execution entrypoint for Codex. Runs approved experiments in manual or bounded fast-loop mode and records evidence back into RSD."
version: 1.0.0
---

# AnchoredAutoResearch — EXECUTE Entrypoint

Use this skill when the user invokes `$research-execute` in Codex.

## MANDATORY: Read Protocol Before Any Action

1. Read `AGENTS.md` for project rules
2. Read `RSD.md` and confirm the current cycle is in EXECUTE with explicit human approval or revision
3. Read the approved PLAN section and extract execution mode, verify command, and guard command
4. Follow `../research/references/phase-protocol.md` for manual execution
5. Follow `../research/references/autonomous-loop.md` when the plan specifies bounded fast-loop execution

## Execution

1. Verify the current PLAN has explicit human approval or revision in chat or `RSD.md`
2. Execute the approved experiments only
3. Record artifact-linked evidence in `RSD.md`
4. Update Code Architecture if the structure changed
5. Write the post-execute review summary into `RSD.md`
6. Run `bash scripts/compile_rsd.sh`
7. Commit `"research: cycle N execute complete"`
8. Advance to INTERPRET
