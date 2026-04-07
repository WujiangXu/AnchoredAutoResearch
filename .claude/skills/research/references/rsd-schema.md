# RSD Schema — Research State Document Format

The RSD.md template and section definitions. This is the ONLY format for the Research State Document.

## Template

```markdown
# Research State Document

## Status: PLAN
## Phase: PLAN
## Cycle: 1

## Research Goal
[filled from human input]

## Scope & Constraints
[filled from human input]

---

## Knowledge Sources
*Read these BEFORE planning any experiment.*

| Source | Type | Key Takeaway | Read? |
|--------|------|--------------|-------|

---

## Hypotheses
| ID | Statement | Status | Evidence |
|----|-----------|--------|----------|
| H1 | [from human or AI-proposed] | active | — |

---

## Code Architecture
*No code yet.*

---

## Cycle 1

### PLAN
*Pending...*

---

## Human Decisions Log
*(append-only)*

## Open Questions
*(AI-flagged items needing human input)*
```

## Section Definitions

### Status Line
`## Status: [PLAN | EXECUTE | INTERPRET | WAITING_HUMAN | BLOCKED]`

### Phase Line
`## Phase: [PLAN | EXECUTE | INTERPRET]`

### Cycle Line
`## Cycle: N` (integer, starts at 1)

### Knowledge Sources Table
Tracks all external knowledge. Updated by `/research:context` and during PLAN pre-flight.

### Hypotheses Table
Living table of research hypotheses. Status: `active`, `confirmed`, `rejected`, `revised`.

### Code Architecture
Updated during EXECUTE when code structure changes. Contains:
- **Modules** — file list with purpose
- **Data Flow** — how data moves through code
- **Dependencies** — external libraries, APIs
- **Changes This Cycle** — what changed and why

### Cycle Sections
Each cycle has three phases: PLAN, EXECUTE, INTERPRET.

### Human Decisions Log
Append-only log of human approvals and revisions with dates.

### Open Questions
AI-flagged items needing human input. Cleared when resolved.

## Imported Cycle Format (ADOPT only)

When a project is anchored via `/research:adopt` (or `$research-adopt`), the
first cycle is an **imported snapshot** of the existing work, not a normal
PLAN/EXECUTE/INTERPRET cycle. The imported cycle is **read-only** — subsequent
cycles may never edit its metadata or fields.

### Strict mode layout

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

**Extracted LaTeX draft path:** `path/to/paper.tex` (N bytes)

**Extracted experiments (from git):**
- `<hash>` — [short commit message]

**Extracted log artifacts:**
- `logs/<filename>` — N bytes, N lines

**Summary:** [3-5 sentence AI-written neutral summary from abstract + conclusion]
```

Strict mode writes **no** `### PLAN`, `### EXECUTE`, or `### INTERPRET`
subsections under the imported cycle.

### Fully-auto mode layout

Same metadata block and IMPORTED SNAPSHOT, **plus** a synthetic
`### PLAN`, `### EXECUTE`, `### INTERPRET` triple. Every prediction-adjacent
field is the literal string `N/A (imported)`:

```markdown
### PLAN
**Proposed by:** imported
**Prediction:** N/A (imported)
**If wrong:** N/A (imported)
**Execution mode:** imported
...

### EXECUTE
**Pre-state:** N/A (imported)
**Experiments:** [bullet list of git hashes + commit messages]
**Post-state:** N/A (imported)
**Codex review:** N/A (imported)

### INTERPRET
**Analysis:** [2-3 sentences from LaTeX conclusion]
**Prediction delta:**
- Predicted: N/A (imported)
- Actual: [one line summary or N/A]
- Delta: N/A (imported)
- Assessment: N/A (imported)
**Hypothesis updates:** N/A (imported)
**Next step proposal:** [one line or N/A]
**Open questions:** N/A (imported)
```

### Invariants

- `imported: true` is **immutable**. Any edit to it is a protocol violation.
- Downstream tooling (prediction-delta audits, etc.) MUST skip cycles with
  `imported: true`.
- Cycle 2 onward must behave normally — the first real prediction commit
  occurs in Cycle 2 PLAN, before any Cycle 2 EXECUTE commit.
- The imported cycle cannot be "revived" into a normal cycle. If the human
  wants to run new experiments on the imported baseline, they must plan them
  as Cycle 2.

See `adopt-protocol.md` for the full ADOPT protocol.

## Human Approval Format

Human approval or revision can be given in either place:
- a clear human-written note in `RSD.md` under the relevant phase
- a clear human chat message in the current session

Exact wording is not required. The important part is that the intent is explicit and unambiguous.

Examples in `RSD.md`:
```markdown
> **Human decision:** APPROVED
> **Date:** YYYY-MM-DD
```
or:
```markdown
> **Human decision:** REVISED — [specific changes]
> **Date:** YYYY-MM-DD
```

Examples in chat:
- "approved, go ahead"
- "looks good, proceed"
- "revised: focus more on X and keep Y fixed"
- "#Revised. Prioritize coding first, then tool use."

When approval or revision is given in chat, the agent should summarize it into `RSD.md` and `## Human Decisions Log` before continuing.
