# ADOPT Protocol — Anchoring to an Existing Project

ADOPT is the sibling of INIT. Use it when the user already has an in-progress
research project (existing LaTeX draft, git history, logs) and wants to anchor
the AnchoredAutoResearch protocol to it **without** starting from cycle 1 of a
blank slate.

The imported state collapses into **one big Cycle 1**. The first "real" cycle
(with fresh predictions) is Cycle 2.

## When to Use ADOPT (vs INIT)

| Situation | Use |
|-----------|-----|
| Empty directory, no prior work | INIT |
| Greenfield research idea, no code yet | INIT |
| Existing `.tex` paper draft + code + logs | **ADOPT** |
| Half-finished project with experimental results | **ADOPT** |
| Unsure | Try INIT. If user pushes back, switch to ADOPT. |

The main `$research` / `/research` state machine **offers** ADOPT automatically
when no `RSD.md` exists and the user's free-form input contains signals like
`.tex`, "draft", "have code", "existing", "logs", or a path. The offer is
always a soft ask — the user can decline.

## Modes

### Strict mode (default)

The imported state becomes a single read-only Cycle 1 with **no**
PLAN/EXECUTE/INTERPRET triple. Human must approve before the first real cycle
(Cycle 2) begins. Use when the user wants maximum auditability.

### Fully-auto mode (opt-in via `--mode fully-auto`)

Same single Cycle 1, but with a **synthetic** PLAN/EXECUTE/INTERPRET triple
that is auto-generated from the scan. Every prediction-adjacent field is the
literal string `N/A (imported)` to preserve anti-gaming auditability. Use when
the user trusts the importer and wants to skip per-field verification.

In **both** modes:
- The imported Cycle 1 is marked `imported: true` in its metadata.
- Cycle 1 is effectively read-only.
- No git prediction-commit is required for Cycle 1 (this is the ONLY
  exemption to the prediction-before-execution rule).
- Cycle 2 onward behaves normally — the first real prediction commit occurs
  in Cycle 2 PLAN, before any Cycle 2 EXECUTE commit.

## Pre-flight checks (both modes)

Before doing anything:

1. **Refuse if `RSD.md` exists.** Tell the user to delete, move, or rename it,
   or work in a different workspace. Never overwrite an existing RSD.
2. **Resolve `--from`.** Default: project root (CWD). Refuse if the path does
   not exist or is not a directory.
3. **Refuse if nothing to adopt.** If `--from` contains no `.tex`, no `.git`,
   no `logs/`, and no `context/` files, the project cannot be "anchored".
   Suggest INIT instead.
4. **Parse `--mode`.** If omitted, default to `strict`. If invalid, refuse
   with the list of valid modes.

## Input scan (both modes)

Scan `--from` and collect:

### LaTeX draft
- Find `.tex` files. Prefer `main.tex` or `paper.tex`; otherwise pick the
  largest `.tex` by byte size.
- Extract section titles: every `\section{...}` line, in order.
- Extract the first paragraph after each section (for summarization).
- Extract the abstract if present (first `\begin{abstract}...\end{abstract}`).
- Record the absolute path.
- If no `.tex` is found, note "no LaTeX draft" and continue.

### Git history
- If `.git/` is present, run:
  ```bash
  git log --oneline -100
  ```
- Filter commits whose message matches (case-insensitive):
  `exp|experiment|train|eval|result|ablation|run|benchmark`.
- Record the top 20 matches as `(hash, short-message)` tuples.
- If no git history, note "no git history" and continue.

### Logs
- If `logs/` exists, list its files.
- Pick the 3 newest by modification time.
- Record `(path, byte-size, line-count)` for each.

### Context sources
- If `context/` exists with any files, run the standard knowledge-sources
  indexing protocol from `knowledge-sources.md`: populate `context/SOURCES.md`
  and read any unread sources for key-takeaway extraction.

## Strict mode write-out

1. Create `RSD.md` from the template in `rsd-schema.md`.
2. Fill the header:
   - `## Status: WAITING_HUMAN`
   - `## Phase: ADOPT`
   - `## Cycle: 1`
3. Fill `## Research Goal` and `## Scope & Constraints` with a short
   AI-written summary extracted from the `.tex` abstract and/or introduction.
   Prefix each field with `[auto-imported, please review]` so the human knows
   to verify.
4. Populate `## Knowledge Sources` from the context/ scan.
5. Write `## Cycle 1` in the **Imported Cycle Format** (defined in
   `rsd-schema.md`):

    ```markdown
    ## Cycle 1

    > **imported:** true
    > **mode:** strict
    > **adopted-at:** YYYY-MM-DD
    > **source:** /absolute/path/to/original/project
    > **read-only:** true (do not edit; cycle 2 is the first live cycle)

    ### IMPORTED SNAPSHOT
    **Extracted LaTeX sections:**
    - [section title 1]
    - [section title 2]
    - ...

    **Extracted LaTeX draft path:** `path/to/paper.tex` (N bytes)

    **Extracted experiments (from git):**
    - `<hash1>` — [short commit message]
    - `<hash2>` — [short commit message]
    - ...

    **Extracted log artifacts:**
    - `logs/latest_run.json` — 1234 bytes, 56 lines
    - ...

    **Summary:** [AI-written 3-5 sentences drawn from the LaTeX abstract and
    conclusion, neutral tone, no editorializing]
    ```

6. **Do NOT write `### PLAN`, `### EXECUTE`, or `### INTERPRET` subsections
   under Cycle 1 in strict mode.** The imported snapshot is the entire cycle.
7. Append to `## Human Decisions Log`:
   ```
   - YYYY-MM-DD: ADOPT (strict) from <source path>
   ```
8. Run `bash scripts/compile_rsd.sh` to produce `RSD.pdf`.
9. Copy the frozen state: `RSD.md` → `checkpoints/cycle_1_adopt.md` and
   `RSD.pdf` → `checkpoints/cycle_1_adopt.pdf`.
10. Git commit:
    ```
    research: adopt existing project (strict)
    ```
11. **Check for PAPER handoff opportunity** (see "PAPER handoff" below).
12. STOP. Tell the human:
    - Read `RSD.pdf` to verify the imported snapshot.
    - Cycle 1 is an imported read-only snapshot.
    - Approve (or revise) in chat or `RSD.md`, then run `/research` to begin
      Cycle 2 (the first real planning cycle).
    - Explicitly state: **"All your existing work is collapsed into Cycle 1.
      Your first new cycle will be Cycle 2."**

## Fully-auto mode write-out

Follow all strict-mode steps **except** step 5–6. Replace with:

5. Write `## Cycle 1` in the Imported Cycle Format, **plus** a synthetic
   `### PLAN`, `### EXECUTE`, `### INTERPRET` triple. Every prediction-adjacent
   field is the literal string `N/A (imported)`:

    ```markdown
    ## Cycle 1

    > **imported:** true
    > **mode:** fully-auto
    > **adopted-at:** YYYY-MM-DD
    > **source:** /absolute/path/to/original/project
    > **read-only:** true (do not edit; cycle 2 is the first live cycle)

    ### IMPORTED SNAPSHOT
    [same fields as strict mode]

    ### PLAN
    **Proposed by:** imported
    **Proposed:** N/A (imported)
    **Grounded in:** N/A (imported)
    **Prediction:** N/A (imported)
    **If wrong:** N/A (imported)
    **Files to modify:** N/A (imported)
    **Estimated cost:** N/A (imported)
    **Execution mode:** imported
    **Verify command:** N/A (imported)
    **Guard command:** N/A (imported)

    ### EXECUTE
    **Pre-state:** N/A (imported)
    **Experiments:**
    - `<git-hash>` — [commit message]
    - `<git-hash>` — [commit message]
    - ...
    **Post-state:** N/A (imported)
    **Commit range:** N/A (imported)
    **Codex review:** N/A (imported)

    ### INTERPRET
    **Analysis:** [2-3 sentence summary drawn from the LaTeX conclusion,
    neutral tone]
    **Prediction delta:**
    - Predicted: N/A (imported)
    - Actual: [one line summary of the most recent log artifact if any]
    - Delta: N/A (imported)
    - Assessment: N/A (imported)
    **Hypothesis updates:** N/A (imported)
    **Next step proposal:** [one line suggestion for Cycle 2, or N/A]
    **Open questions:** N/A (imported)
    ```

6. Append to `## Human Decisions Log`:
   ```
   - YYYY-MM-DD: ADOPT (fully-auto) from <source path>
   ```

The git commit for fully-auto is:
```
research: adopt existing project (fully-auto)
```

## Anti-gaming preservation

- **Prediction fields are never silently missing.** They are literally
  `N/A (imported)` so audits can detect them.
- The `imported: true` metadata flag is **immutable**. Any future phase that
  tries to edit it is a protocol violation.
- Downstream tooling (prediction-delta audits, etc.) MUST skip cycles marked
  `imported: true`.
- Cycle 2 onward is unchanged — the first real prediction commit must occur
  in Cycle 2 PLAN, before any Cycle 2 EXECUTE commit.
- The `imported` Cycle 1 cannot be "revived" into a normal cycle by editing
  its metadata. If a human wants to run experiments on the imported baseline,
  they must plan them as Cycle 2.

## Edge cases

| Case | Behavior |
|------|----------|
| `RSD.md` exists | Refuse. Tell user to delete/move/rename or use another workspace. |
| `--from` missing or not a directory | Refuse with echoed path. |
| `--from` has no `.tex`, `.git`, `logs/`, or `context/` | Refuse and suggest INIT. |
| `--mode` invalid | Refuse with list of valid modes. |
| `--mode` omitted | Default to `strict`. |
| `.tex` file present but no `\section{}` | Fall back to first N paragraphs in Summary; leave "Extracted LaTeX sections" empty. |
| No git history | Skip git scan; note "no git history" in the snapshot; continue. |
| `logs/` empty | Skip log scan; note "no log artifacts"; continue. |
| `context/` has files already indexed | Follow knowledge-sources protocol as normal (no re-index). |

## PAPER handoff

After a successful ADOPT (strict or fully-auto), if a `.tex` file was found
during the scan, ask the human:

> Found `<path>`. Copy it to `outputs/paper/paper.tex` so `/research:paper`
> can edit it later? (yes → pick venue / no)

- **If yes**: ask which venue (`neurips`, `icml`, `acl`, or a custom name
  discovered under `templates/paper/*/`). Then run the PAPER `import-from-tex`
  intent internally, which creates `outputs/paper/paper.tex` and writes
  `outputs/paper/.venue`. Remind the user to place the venue `.cls` file in
  `outputs/paper/` before invoking `/research:paper compile`.
- **If no**: skip the handoff silently. The user can invoke
  `/research:paper import` later.

The handoff is optional. ADOPT is complete either way.

## State machine integration

The main `$research` / `/research` state machine auto-detects existing-project
signals when no `RSD.md` exists:

```
$research invoked
  ├─ No RSD.md
  │    ├─ User input contains existing-project signals
  │    │  (".tex", "draft", "have code", "logs", path-like strings)
  │    │    → ask: "You seem to have an in-progress project. ADOPT it
  │    │            instead of starting fresh? (strict / fully-auto / no)"
  │    │    ├─ User accepts → ADOPT (with chosen mode)
  │    │    └─ User declines → INIT
  │    └─ Otherwise → INIT
  ...
```

The detection is a **soft heuristic**. It must always ask before running
ADOPT. It never auto-runs ADOPT without explicit user consent.
