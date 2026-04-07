---
name: research:paper
description: "Write, edit, and compile a venue-specific LaTeX paper from the Research State Document. Strict side-effect command — never touches RSD.md, never advances phase."
argument-hint: "[init <venue> | write <section> | update <section> | layout <instruction> | compile | check-pages | shrink to <N> | import <path>]"
---

EXECUTE IMMEDIATELY — do not deliberate before reading the protocol.

## HARD GUARDRAILS (non-negotiable)

This command is strictly orthogonal to the research state machine:

- NEVER write `RSD.md`.
- NEVER change `## Status:` or `## Phase:`.
- NEVER create cycle checkpoints.
- NEVER edit any `.cls` file (regardless of path).
- NEVER write outside `outputs/paper/**`.
- After this command finishes, `git diff RSD.md` MUST be empty.

If any step would violate the above, refuse and report the violation.

## Argument Parsing (natural-language intent classification)

Parse `$ARGUMENTS` into ONE intent. Match keywords against the table in
`paper-protocol.md` (the "Intent classification" section). If the intent
is ambiguous or matches zero entries, ASK the user rather than guessing.

| Keyword triggers | Intent |
|---|---|
| `init`, `new <venue>`, `start paper` | **init** |
| `write <section>`, `draft <section>` | **write-section** |
| `update <section>`, `refresh <section>`, `sync <section>` | **update-section** |
| `layout`, `adjust`, `spacing`, `figure`, `table`, `vspace`, `resizebox` | **layout-edit** |
| `compile`, `build`, `pdf` | **compile** |
| `check pages`, `page count`, `fit <N>`, `shrink to <N>` | **check-pages / shrink** |
| `import`, `from tex`, `ingest existing` | **import-from-tex** |

## Execution

1. Read `.claude/skills/research/references/paper-protocol.md` — the full
   PAPER protocol, including the scoped LaTeX-write exception rules, the
   `outputs/paper/` directory layout, and the per-intent protocols.
2. Read `.claude/skills/research/references/core-principles.md` to confirm
   the scoped exception wording before writing any LaTeX.
3. Classify the intent from `$ARGUMENTS`. If ambiguous, ask the user.
4. Run the intent-specific protocol from `paper-protocol.md`:
   - `init` — bootstrap `outputs/paper/` from `templates/paper/<venue>/`
   - `write-section` — generate section body from RSD (READ-ONLY)
   - `update-section` — merge RSD updates into existing section
   - `layout-edit` — direct LaTeX edit under scoped exception
   - `compile` — run `bash scripts/compile_paper.sh`
   - `check-pages` / `shrink` — report count, optionally chain to layout-edit
   - `import-from-tex` — copy an external `.tex` into `outputs/paper/paper.tex`

5. **Pre-flight path-prefix guard** before any LaTeX write:
   - Resolve target to absolute path; reject `..` traversal
   - Verify the path starts with `outputs/paper/`
   - Verify the basename does NOT end with `.cls`
   - Verify the current command is `/research:paper` (this dispatcher)
   - If any check fails, refuse and report which check failed

6. For `write-section` and `update-section`, RSD content may be READ only —
   extract Goal, Hypotheses, Knowledge Sources, and latest INTERPRET sections
   for quotation. Do NOT mutate `RSD.md`.

7. After a successful edit, suggest (but do NOT auto-run):
   - `/research:paper compile` to rebuild the PDF
   - `/research:paper check-pages` to verify page count

8. Do NOT `git commit` automatically. Paper edits are committed only when
   the user explicitly asks via their normal workflow.

9. STOP. Report:
   - Which intent was run
   - Which files were written (with path)
   - Whether `RSD.md` was touched (it MUST say "no")
   - Next suggested step

Stream all output live. Never run in background.
