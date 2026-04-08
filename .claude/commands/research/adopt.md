---
name: research:adopt
description: "Anchor the research protocol to an in-progress project (existing LaTeX draft + git + logs). Imports state as read-only Cycle 1; real cycles start at Cycle 2."
argument-hint: "[--mode strict|fully-auto] [--from /path/to/existing]"
---

EXECUTE IMMEDIATELY — do not deliberate before reading the protocol.

## Argument Parsing

Extract from $ARGUMENTS:
- `--mode strict|fully-auto` — adopt mode. Default: `strict`.
- `--from /path` — source project path. Default: current working directory.
- Any remaining free-form text — treat as extra user context to quote in the
  Research Goal field.

## Execution

1. Read `.claude/skills/research/references/adopt-protocol.md` — the full
   ADOPT protocol (pre-flight, input scan, strict/fully-auto write-out,
   anti-gaming rules, PAPER handoff).
2. Read `.claude/skills/research/references/rsd-schema.md` — for the RSD
   template and the Imported Cycle Format.
3. Read `.claude/skills/research/references/core-principles.md` — for the
   anti-gaming rules (ADOPT has ONE exemption, which is documented there).
4. Read `.claude/skills/research/references/knowledge-sources.md` — ADOPT
   reuses its scan logic for indexing `context/` when present.

5. Run the ADOPT pre-flight checks:
   - Refuse if `RSD.md` exists.
   - Resolve `--from`. Refuse if missing or not a directory.
   - Refuse if `--from` has no `.tex`, no `.git`, no `logs/`, and no
     `context/` — suggest INIT instead.
   - Validate `--mode`. Default to `strict` if omitted.

6. Run the input scan as defined in `adopt-protocol.md`:
   - LaTeX draft (section titles + first paragraphs + abstract)
   - Git history (experiment-looking commits, top 20)
   - Logs (newest 3 files)
   - Context sources (via knowledge-sources protocol)

7. Write `RSD.md` following the strict or fully-auto protocol in
   `adopt-protocol.md`. Use the Imported Cycle Format from `rsd-schema.md`.
   Set `## Status: WAITING_HUMAN`, `## Phase: ADOPT`, `## Cycle: 1`.

8. Create directories if missing: `checkpoints/`, `logs/`, `outputs/`,
   `context/papers/`, `context/notes/`, `context/prior_work/`.

9. Run `bash scripts/compile_rsd.sh` to produce `RSD.pdf`.

10. Copy the frozen state:
    - `RSD.md` → `checkpoints/cycle_1_adopt.md`
    - `RSD.pdf` → `checkpoints/cycle_1_adopt.pdf`

11. Git commit all files:
    - Strict mode: `"research: adopt existing project (strict)"`
    - Fully-auto mode: `"research: adopt existing project (fully-auto)"`

12. If the input scan found a `.tex` file, offer the PAPER handoff as
    described in `adopt-protocol.md` (ask before copying to
    `outputs/paper/paper.tex`; on yes, pick venue and invoke the PAPER
    `import-from-tex` intent).

13. STOP. Tell the human:
    - "RSD initialized via ADOPT. Cycle 1 is an imported read-only snapshot."
    - "All your existing work is collapsed into Cycle 1. Your first new
      cycle will be Cycle 2."
    - "Read `RSD.pdf` to verify the imported snapshot."
    - "Approve or revise in chat or `RSD.md`, then run `/research` to begin
      Cycle 2 (the first real planning cycle)."

Stream all output live. Never run in background.
