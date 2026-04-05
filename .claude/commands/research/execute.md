---
name: research:execute
description: "Run experiments: fast-loop (modify→verify→keep/discard) or manual execution with per-experiment commits."
argument-hint: "[--mode manual|fast-loop] [--iterations N]"
---

EXECUTE IMMEDIATELY — do not deliberate before reading the protocol.

## Argument Parsing

Extract from $ARGUMENTS:
- `--mode manual|fast-loop` — execution mode override (defaults to plan's execution mode)
- `--iterations N` — bounded iteration count override

## Execution

1. Read `RSD.md` — verify we are in EXECUTE phase with explicit human approval or revision
2. Read the approved PLAN section and the latest human feedback — extract execution mode, verify command, guard command, and any revisions
3. If execution mode is `fast-loop`:
   - Read the autonomous loop protocol: `.claude/skills/research/references/autonomous-loop.md`
   - Read the results logging protocol: `.claude/skills/research/references/results-logging.md`
   - Execute the 8-phase loop with bounded iterations
4. If execution mode is `manual`:
   - Read the phase protocol: `.claude/skills/research/references/phase-protocol.md`
   - Follow manual execution steps (EXECUTE section)
5. After execution completes:
   - Use `codex:rescue` to review changed files (Codex review)
   - Write review summary to RSD under EXECUTE section
   - Update Code Architecture if structure changed
   - Git commit: `"research: cycle N execute complete"`
6. Auto-advance to INTERPRET phase

Stream all output live. Never run in background.
