---
name: research-adopt
description: "AnchoredAutoResearch adopt skill for Codex. Anchors the protocol to an in-progress project (existing LaTeX + git + logs). Imports state as read-only Cycle 1; real cycles start at Cycle 2."
version: 1.0.0
---

# AnchoredAutoResearch — ADOPT Entrypoint

Use this skill when the user invokes `$research-adopt` in Codex.

## MANDATORY: Read Protocol Before Any Action

1. Read `AGENTS.md` for project rules
2. Read `RSD.md` if present — if it exists, REFUSE (ADOPT never overwrites).
3. Follow the ADOPT protocol in `../research/references/adopt-protocol.md`
4. Follow the Imported Cycle Format in `../research/references/rsd-schema.md`
5. Follow `../research/references/core-principles.md` for anti-gaming rules
6. Reuse `../research/references/knowledge-sources.md` scan logic for any
   existing `context/` sources

## Argument Parsing

From the user's invocation:
- `--mode strict|fully-auto` — adopt mode. Default: `strict`.
- `--from /path` — source project path. Default: CWD.
- Remaining free-form text — extra user context to quote in Research Goal.

## Execution

1. Run ADOPT pre-flight:
   - Refuse if `RSD.md` exists.
   - Resolve `--from`. Refuse if missing or not a directory.
   - Refuse if `--from` has no `.tex`, no `.git`, no `logs/`, and no
     `context/` — suggest INIT instead.
   - Validate `--mode`. Default to `strict` if omitted.

2. Run the input scan:
   - LaTeX draft (section titles + first paragraphs + abstract)
   - Git history (experiment-looking commits, top 20)
   - Logs (newest 3 files)
   - Context sources (via knowledge-sources protocol)

3. Write `RSD.md` following the strict or fully-auto protocol in
   `adopt-protocol.md`. Use the Imported Cycle Format. Set
   `## Status: WAITING_HUMAN`, `## Phase: ADOPT`, `## Cycle: 1`.

4. Create missing directories: `checkpoints/`, `logs/`, `outputs/`,
   `context/papers/`, `context/notes/`, `context/prior_work/`.

5. Run `bash scripts/compile_rsd.sh`.

6. Copy frozen state to `checkpoints/cycle_1_adopt.md` and
   `checkpoints/cycle_1_adopt.pdf`.

7. Git commit:
   - Strict: `"research: adopt existing project (strict)"`
   - Fully-auto: `"research: adopt existing project (fully-auto)"`

8. If a `.tex` was found, offer the PAPER handoff (ask before copying to
   `outputs/paper/paper.tex`; pick venue; invoke PAPER `import-from-tex`).

9. Stop and tell the human to read `RSD.pdf`, that Cycle 1 is the imported
   read-only snapshot, that their first new cycle will be Cycle 2, and to
   approve or revise in chat or `RSD.md` before running `$research`.

Stream all output live. Never run in background.
