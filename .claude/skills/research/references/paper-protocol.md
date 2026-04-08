# PAPER Protocol — Venue-Formatted Paper Generation

`/research:paper` (Codex: `$research-paper` / `$research:paper`) writes and
edits a venue-specific LaTeX paper derived from the Research State Document.
It is a **side-effect command** — it does NOT read-or-write `RSD.md`, does
NOT advance phase, does NOT change `Status`, and does NOT create cycle
checkpoints. The only RSD content it may READ is Goal, Hypotheses, Knowledge
Sources, and the latest INTERPRET sections — for quotation into paper text.

## State-machine independence (MANDATORY)

Paper operations are strictly orthogonal to the research state machine:

| | Allowed | Forbidden |
|---|---|---|
| Read `RSD.md` | yes (for quotation into paper text) | must not mutate it |
| Write `RSD.md` | never | never |
| Change `## Status:` | never | never |
| Change `## Phase:` | never | never |
| Create cycle checkpoints | never | never |
| Read `outputs/paper/paper.tex` | yes | — |
| Write `outputs/paper/paper.tex` | yes (scoped LaTeX exception) | outside `outputs/paper/**` |
| Write any `.cls` file | never | never |

After every paper operation, the user should be able to run
`git diff RSD.md` and see zero changes. If `RSD.md` content and paper
content disagree, **RSD wins** — re-run `/research:paper update <section>`
to re-derive from RSD.

## Scoped LaTeX-write exception

The project's core rule is "AI writes RSD markdown only; NEVER writes RSD
LaTeX" (see `core-principles.md`). `/research:paper` is the ONE scoped
exception:

- **Scoped to path prefix** `outputs/paper/**`.
- **Forbidden** for any `.cls` file regardless of path.
- **Forbidden** outside of an explicit `/research:paper` invocation —
  no other skill may touch paper files.
- **Inactive** during INIT, PLAN, EXECUTE, INTERPRET, or ADOPT.

Before every LaTeX write, the agent MUST verify:
1. The target path starts with `outputs/paper/` (resolved to absolute, no
   path traversal through `..`).
2. The target basename does NOT end with `.cls`.
3. The current command being served is `/research:paper` (or the Codex
   equivalent) — not any other protocol phase.

If any check fails, refuse the write and report the violation.

## `outputs/paper/` directory layout

```
outputs/paper/
├── paper.tex               # AI-writable (scoped exception)
├── references.bib          # AI-writable
├── <venue>.cls             # user-fetched; AI NEVER edits
├── .venue                  # one-line text file: venue name
├── figures/                # symlinks or copies of experiment figures
│   └── *.pdf
└── paper.pdf               # built artifact (gitignored)
```

The `.venue` file records which venue template the paper was initialized
with (e.g., `neurips`, `icml`, `acl`, or a user-provided custom name). It
is read by `init` refusal checks and by `compile` to resolve the expected
`.cls` file name.

## Intent classification

`/research:paper <arbitrary text>` parses `$ARGUMENTS` into ONE of the
intents below using keyword matching. If the user's text is ambiguous (or
matches zero intents), **ask the user** rather than guessing.

| Keyword triggers | Intent |
|---|---|
| `init`, `new <venue>`, `start paper` | **init** |
| `write <section>`, `draft <section>` | **write-section** |
| `update <section>`, `refresh <section>`, `sync <section>` | **update-section** |
| `layout`, `adjust`, `spacing`, `figure`, `table`, `vspace`, `resizebox` | **layout-edit** |
| `compile`, `build`, `pdf` | **compile** |
| `check pages`, `page count`, `fit <N>`, `shrink to <N>` | **check-pages / shrink** |
| `import`, `from tex`, `ingest existing` | **import-from-tex** |

## Intent: `init`

Bootstrap `outputs/paper/` from a venue template.

### Steps

1. Parse the venue name from `$ARGUMENTS`. If omitted, list the available
   venues (by scanning `templates/paper/*/`) and ask the user to pick one.
2. Refuse if `outputs/paper/paper.tex` already exists. Tell the user to
   delete or move it, or to use `update`/`write` instead.
3. Refuse if `templates/paper/<venue>/paper_skeleton.tex` does not exist.
   Suggest adding it.
4. Create `outputs/paper/` if missing.
5. Copy `templates/paper/<venue>/paper_skeleton.tex` to
   `outputs/paper/paper.tex`.
6. Copy `templates/paper/references.bib` to `outputs/paper/references.bib`
   (only if the target doesn't exist — don't overwrite the user's bib).
7. Write `outputs/paper/.venue` containing just the venue name.
8. Create `outputs/paper/figures/` if missing.
9. Check whether a venue `.cls` file is present in `outputs/paper/`. If
   not, print the fetch instructions from
   `templates/paper/<venue>/README.md` and tell the user where to place
   the `.cls`.
10. Report: "Paper initialized for venue `<venue>`. Run
    `/research:paper write <section>` to populate a section, or
    `/research:paper compile` once the `.cls` is in place."

### Refusal messages

- Venue not found: `Venue '<name>' not found. Available venues: <list>. To add a custom venue, create templates/paper/<name>/paper_skeleton.tex.`
- Paper already exists: `outputs/paper/paper.tex already exists. Use /research:paper update or delete the file first.`
- `.cls` missing: `outputs/paper/<venue>_<year>.cls missing. See templates/paper/<venue>/README.md for fetch instructions.`

## Intent: `write-section`

Populate a section body with AI-generated prose derived from RSD.

### Steps

1. Verify `outputs/paper/paper.tex` exists. Refuse with "Run
   /research:paper init <venue> first." if not.
2. Parse the section name from `$ARGUMENTS` (e.g., "related work" →
   `Related Work`). Normalize capitalization.
3. Locate `\section{<name>}` (case-insensitive) in `paper.tex`. Refuse if
   the section heading does not exist in the skeleton — tell the user the
   list of sections that do exist.
4. **Read RSD.md (read-only)** — extract the relevant content based on the
   section:
   - **Introduction / Abstract:** Goal, Scope, top-level Hypotheses
   - **Related Work:** `## Knowledge Sources` table + `context/SURVEY.md`
     if present
   - **Method:** Hypotheses + Code Architecture (if relevant)
   - **Experiments / Results:** latest INTERPRET sections + prediction
     deltas from all completed cycles
   - **Discussion / Conclusion:** latest INTERPRET + Open Questions +
     hypothesis updates
5. Generate the section body as LaTeX prose. Use `\cite{key}` macros for
   every factual claim drawn from a knowledge source — add entries to
   `references.bib` as needed.
6. Replace the content between the located `\section{<name>}` and the
   next `\section{...}` (or `\end{document}` if it's the last section).
7. Run the pre-flight path-prefix guard before writing.
8. Write the updated `paper.tex`.
9. Do NOT compile automatically (the user may want to write multiple
   sections first). Report what was written and suggest
   `/research:paper compile` when ready.

## Intent: `update-section`

Same as `write-section`, but merges RSD-derived updates into an existing
section body instead of replacing it wholesale. Preserves the user's manual
LaTeX edits around the AI-generated content when possible.

### Strategy

1. Read the existing section body.
2. Compare against what `write-section` would produce.
3. If the existing body appears to be pure AI output (matches a previous
   generation with no user edits), replace it wholesale.
4. If the existing body contains user edits (detected by diff against the
   last AI generation, if a cache exists), present a merge preview and ask
   the user to confirm before overwriting.
5. Preserve any user-added `\cite{...}`, `\label{...}`, `\ref{...}`,
   `\footnote{...}`, or comment lines.

## Intent: `layout-edit`

Direct LaTeX edit of `paper.tex` driven by a natural-language user
instruction. This is the most delicate intent — it exercises the scoped
LaTeX-write exception.

### Allowed operations

- Adjust `\vspace{...}` values at specific locations named by the user
- Change figure width with `\includegraphics[width=...]`
- Change `\begin{figure}[...]` placement specifiers
- Apply `\resizebox{...}` or `\adjustbox{...}` around tables
- Toggle `\begin{figure*}` / `\begin{figure}` (double-column vs
  single-column)
- Swap to compact bibliography style by editing `\bibliographystyle{...}`
- Reorder sections when explicitly requested

### Forbidden operations

- Editing any `.cls` file (hard refusal)
- Changing `\documentclass{...}` line (hard refusal)
- Editing files outside `outputs/paper/**` (hard refusal)
- Silently "improving" layout beyond what the user asked for

### Steps

1. Verify `outputs/paper/paper.tex` exists. Refuse if not.
2. Parse the user instruction into a concrete edit plan. If the
   instruction is vague ("make it look better"), ASK for specifics rather
   than guessing.
3. Locate the target location(s) in `paper.tex` — figure label, table
   caption, section heading, etc.
4. Present the planned edit (old → new) in chat before writing. For
   trivial single-line changes this can be inline; for multi-line changes
   show a diff.
5. Run the pre-flight path-prefix + `.cls` guard.
6. Apply the edit.
7. Suggest `/research:paper compile` and `/research:paper check-pages` to
   verify the effect.

## Intent: `compile`

Build the PDF from `outputs/paper/paper.tex`.

### Steps

1. Verify `outputs/paper/paper.tex` exists. Refuse if not.
2. Read `outputs/paper/.venue` to determine the expected `.cls` file
   name prefix.
3. Verify a matching `.cls` file exists in `outputs/paper/`. If missing,
   refuse with fetch instructions from the venue README.
4. Run `bash scripts/compile_paper.sh outputs/paper/paper.tex`.
5. Report the resolved PDF path and page count (if compile succeeded) or
   the last 20 lines of the LaTeX log (if it failed).

## Intent: `check-pages` / `shrink`

Report page count; if the user asked to shrink to a target, chain into
layout-edit with a reduction plan.

### Steps

1. Run the `compile` intent first to ensure the PDF is fresh.
2. Extract page count via `pdfinfo outputs/paper/paper.pdf` (fallback:
   grep `\lastpage` from the LaTeX log).
3. If no target page count was given in `$ARGUMENTS`, just report the
   count.
4. If a target was given (e.g., `shrink to 9 pages`):
   - Compute the delta (current − target).
   - If the current count is already ≤ target, report success and stop.
   - Otherwise, propose a layout-edit plan (e.g., "Tighten `\vspace`
     values in Discussion, switch figures to `figure*`, use compact bib
     style"). Present the plan to the user for confirmation before
     applying.
   - On confirmation, apply the edits via layout-edit, recompile, and
     re-check.

## Intent: `import-from-tex`

Copy an external `.tex` file into `outputs/paper/paper.tex`. Used by the
ADOPT handoff.

### Steps

1. Parse the source path from `$ARGUMENTS`. If omitted, ask the user for
   it.
2. Verify the source is a `.tex` file that exists.
3. Refuse if `outputs/paper/paper.tex` already exists.
4. Create `outputs/paper/` if missing.
5. Copy the source file to `outputs/paper/paper.tex` verbatim.
6. Ask the user for the venue name. Write `outputs/paper/.venue`.
7. Create `outputs/paper/figures/` if missing.
8. Remind the user to place the venue `.cls` at `outputs/paper/<venue>.cls`
   before compiling.

## Prohibited operations (ALL intents)

- Editing `RSD.md`
- Editing any file in `context/` (use `/research:context` instead)
- Editing any `.cls` file
- Editing files outside `outputs/paper/**`
- Running `git commit` automatically — paper edits are committed only
  when the user explicitly asks (via their normal workflow)
- Modifying `scripts/compile_rsd.sh` or `scripts/md2latex.py`

## Error recovery

- If `pdflatex` fails: report the last 20 lines of the `.log`. Do NOT
  auto-retry with modifications — the user must diagnose.
- If the `.cls` is missing: refuse cleanly with fetch instructions.
- If a user instruction is ambiguous: ASK, never guess.
