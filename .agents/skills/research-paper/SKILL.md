---
name: research-paper
description: "AnchoredAutoResearch paper skill for Codex. Writes, edits, and compiles a venue-specific LaTeX paper from the Research State Document. Strict side-effect command — never touches RSD.md, never advances phase."
version: 1.0.0
---

# AnchoredAutoResearch — PAPER Entrypoint

Use this skill when the user invokes `$research-paper` in Codex.

## HARD GUARDRAILS (non-negotiable)

- NEVER write `RSD.md`.
- NEVER change `## Status:` or `## Phase:`.
- NEVER create cycle checkpoints.
- NEVER edit any `.cls` file (regardless of path).
- NEVER write outside `outputs/paper/**`.
- After this skill finishes, `git diff RSD.md` MUST be empty.

If any step would violate the above, refuse and report the violation.

## MANDATORY: Read Protocol Before Any Action

1. Read `AGENTS.md` for project rules
2. Read `../research/references/paper-protocol.md` — the full PAPER
   protocol, including the scoped LaTeX-write exception rules, the
   `outputs/paper/` directory layout, and the per-intent protocols.
3. Read `../research/references/core-principles.md` to confirm the
   scoped exception wording before writing any LaTeX.

## Argument Parsing (natural-language intent classification)

Parse the user's invocation into ONE intent using the keyword table in
`paper-protocol.md`. If ambiguous, ASK the user rather than guessing.

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

1. Classify the intent. If ambiguous, ask the user.
2. Run the intent-specific protocol from `paper-protocol.md`.
3. Before any LaTeX write, run the pre-flight path-prefix guard:
   - Resolve target to absolute path; reject `..` traversal
   - Verify the path starts with `outputs/paper/`
   - Verify the basename does NOT end with `.cls`
   - Verify the current command is `$research-paper` (or its alias)
   - If any check fails, refuse and report which check failed
4. For `write-section` and `update-section`, RSD content may be READ only —
   extract Goal, Hypotheses, Knowledge Sources, and latest INTERPRET sections
   for quotation. Do NOT mutate `RSD.md`.
5. After a successful edit, suggest (but do NOT auto-run)
   `$research-paper compile` and `$research-paper check-pages`.
6. Do NOT `git commit` automatically.
7. Stop and report which intent ran, which files were written, that
   `RSD.md` was NOT touched, and the next suggested step.

Stream all output live. Never run in background.
