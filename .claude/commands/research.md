---
description: "AnchoredAutoResearch: Phase-gated research protocol with human checkpoints. Manages plan → execute → interpret with prediction discipline and knowledge sources."
---

EXECUTE IMMEDIATELY — do not deliberate before reading the protocol.

## Execution

1. Read the main skill definition: `.claude/skills/research/SKILL.md`
2. Read the core principles: `.claude/skills/research/references/core-principles.md`
3. Read the phase protocol: `.claude/skills/research/references/phase-protocol.md`
4. Read the RSD schema: `.claude/skills/research/references/rsd-schema.md`
5. Read `CLAUDE.md` for project rules
6. Read `RSD.md` to determine current state (if missing → enter INIT phase)
7. If `context/SOURCES.md` exists, read it for knowledge source status
8. Execute the appropriate phase based on RSD status:
   - No RSD.md → INIT (per phase-protocol.md)
   - Status: WAITING_HUMAN → check for approval marker
   - Phase: PLAN → execute PLAN protocol
   - Phase: EXECUTE → load `references/autonomous-loop.md` or manual execute
   - Phase: INTERPRET → execute INTERPRET protocol
   - Status: BLOCKED → show block reason, STOP
9. After writing to RSD.md, ALWAYS run `bash scripts/compile_rsd.sh`
10. STOP at every human checkpoint — present summary, do NOT proceed

Stream all output live. Never run in background.
