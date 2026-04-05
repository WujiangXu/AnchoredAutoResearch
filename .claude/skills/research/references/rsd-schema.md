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
