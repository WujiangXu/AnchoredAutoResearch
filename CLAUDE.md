# AnchoredAutoResearch

## Protocol
This project uses the /research skill for phase-gated research.
ALL experiment work MUST go through the /research protocol.
NEVER run experiments outside the protocol.

## Rules
- RSD.md is the single source of truth — all claims must be written there
- RSD.md is the ONLY file the AI writes research state to. RSD.tex and RSD.pdf are auto-generated — NEVER write LaTeX directly.
- Every phase ends with a git commit
- Never modify past RSD entries — append only within each cycle
- Predictions MUST be written before experiments run
- No metric selection after seeing results
- When status is WAITING_HUMAN, do not proceed until human edits RSD.md with approval marker
- Code Architecture section in RSD MUST be updated whenever code structure changes

## Directory conventions
- logs/ — raw experiment output, referenced by RSD
- checkpoints/ — frozen RSD snapshots per cycle (.md and .pdf)
- outputs/ — figures, tables, final artifacts
- templates/ — LaTeX template for RSD compilation
- scripts/ — compile_rsd.sh (MD→PDF), verify_phase.py (added later)

## Git conventions
- Per-experiment commits: "research: cycle N exp M — [description]"
- Phase commits: "research: cycle N [plan|execute complete|interpret]"
- Each experiment is independently revertable via `git revert`
- `git log --oneline` shows the full experiment timeline

## Dual-format system
- AI writes RSD.md (markdown) — this is the source of truth
- scripts/compile_rsd.sh converts RSD.md → RSD.tex → RSD.pdf deterministically
- Human reads RSD.pdf for a well-formatted view
- Human edits RSD.md to add approval markers
