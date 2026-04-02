---
description: Phase-gated research protocol with human checkpoints. Manages the full research cycle: plan → execute → interpret, with mandatory predictions and artifact-linked evidence.
---

# /research — Anchored Auto-Research Protocol

You are operating under a strict research protocol. Follow it exactly.

## On invocation, ALWAYS:
1. Read `RSD.md` in the project root (create if missing — enter INIT phase)
2. Parse the `## Status:` line to determine current state
3. Parse the `## Phase:` line to determine current phase
4. Execute the appropriate phase protocol below
5. After writing to RSD.md, run `bash scripts/compile_rsd.sh` to generate RSD.pdf
6. STOP at every checkpoint — present summary to human, do NOT proceed

---

## Phase: INIT (no RSD.md exists)

1. Ask the human for:
   - Research goal (what are we trying to achieve?)
   - Scope and constraints (budget, time, off-limits approaches)
   - Initial hypotheses (if any)
2. Create `RSD.md` using the template below
3. Create directories if missing: `checkpoints/`, `logs/`, `outputs/`
4. Set Status: `PLAN`, Phase: `PLAN`, Cycle: `1`
5. Run `bash scripts/compile_rsd.sh`
6. Git commit all files: `"research: initialize RSD"`
7. STOP. Tell the human: "RSD initialized. Read RSD.pdf for the formatted view. Run /research again to begin planning cycle 1."

### RSD.md Template

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

---

## Phase: PLAN

1. Read RSD.md fully. Review all prior cycles, hypotheses, and open questions.
2. Write the following under the current cycle's `### PLAN` section:

```
### PLAN
**Proposed:** [what experiment to run and why — link to hypothesis]
**Prediction:** [specific expected outcome — numbers, directions, ranges]
**If wrong:** [what a failed prediction would imply for the hypothesis]
**Files to modify:** [list of files that will be created or changed]
**Estimated cost:** [API calls, compute time, tokens, or "minimal"]
```

3. Update `## Status: WAITING_HUMAN` and `## Phase: PLAN`
4. Run `bash scripts/compile_rsd.sh`
5. Git commit: `"research: cycle N plan"`
6. Copy `RSD.md` to `checkpoints/cycle_N_plan.md` and `RSD.pdf` to `checkpoints/cycle_N_plan.pdf`
7. STOP. Present to human:
   - Show the plan section you just wrote
   - Say: **"Read RSD.pdf for the formatted view. To approve, edit RSD.md and add under the PLAN section:"**
   ```
   > **Human decision:** APPROVED
   > **Date:** YYYY-MM-DD
   ```
   **"Then run /research to continue."**

---

## Phase: EXECUTE

**Pre-condition:** The current cycle's PLAN section must contain a human approval marker (`> **Human decision:** APPROVED` or `> **Human decision:** REVISED`).

If no approval marker found:
- Tell the human: "No approval found in RSD.md for cycle N plan. Please edit RSD.md to add your decision, then run /research."
- STOP.

If approval found (including REVISED — read and incorporate the revision):

1. Update `## Status: EXECUTING` and `## Phase: EXECUTE`
2. Write `### EXECUTE` header under current cycle with **Pre-state**:

```
### EXECUTE
**Pre-state:**
- `file1.py` @ commit [short hash]
- `file2.py` @ commit [short hash]
```

3. For EACH experiment or sub-experiment:
   a. Implement the specific change
   b. Run the experiment
   c. Capture ALL output to `logs/exp_{cycle}_{sub}.json` (or .log, .txt)
   d. Write evidence to RSD immediately after the run:
   ```
   **Experiment {cycle}.{sub}: {one-line description}**
   - Output: `logs/exp_{cycle}_{sub}.json` ({N} lines)
   - Key metric: {metric_name} = {value} (line {line_number} of output)
   ```
   e. Git commit: `"research: cycle {N} exp {sub} — {one-line description}"`

4. After all experiments, write summary:
```
**Actual results:** [concrete numbers from each experiment]
**Post-state:**
- `file1.py` @ commit [new short hash]
**Commit range:** [first_hash]..[last_hash]
```

5. Update **Code Architecture** section if any structural changes were made:
   - Update module list, data flow, dependencies
   - Add `### Changes This Cycle` sub-section
   - If no structural changes: add "No architecture changes this cycle"

6. Git commit: `"research: cycle N execute complete"`
7. Auto-advance to INTERPRET — update `## Phase: INTERPRET` and continue below.

---

## Phase: INTERPRET

1. Read the current cycle's PLAN (predictions) and EXECUTE (actual results) sections.
2. Write `### INTERPRET` under current cycle:

```
### INTERPRET
**Analysis:** [what happened and why]
**Prediction delta:**
- Predicted: [what you predicted]
- Actual: [what happened]
- Delta: [how far off and in which direction]
- Assessment: [accurate / partially accurate / wrong / surprising]

**Hypothesis updates:**
- H{N}: [confirmed / rejected / revised] — [evidence summary]

**Next step proposal:** [what to investigate in the next cycle and why]

**Open questions:**
- [anything uncertain, flagged for human review]
```

3. Update `## Status: WAITING_HUMAN` and `## Phase: INTERPRET`
4. Append to `## Human Decisions Log`:
   ```
   - [date] Cycle N executed: [brief result summary]
   ```
5. Run `bash scripts/compile_rsd.sh`
6. Git commit: `"research: cycle N interpret"`
7. Copy `RSD.md` to `checkpoints/cycle_N_interpret.md` and `RSD.pdf` to `checkpoints/cycle_N_interpret.pdf`
8. STOP. Present to human:
   - Show the prediction delta and hypothesis updates
   - Show the next step proposal
   - Say: **"Read RSD.pdf for the full formatted report. To approve and start the next cycle, edit RSD.md and add under INTERPRET:"**
   ```
   > **Human decision:** APPROVED
   > **Date:** YYYY-MM-DD
   ```
   **"Then run /research to begin cycle {N+1}."**

---

## Advancing to Next Cycle

When INTERPRET has an approval marker:
1. Increment `## Cycle:` by 1
2. Add new cycle section header: `## Cycle {N+1}`
3. Enter PLAN phase for the new cycle
4. Continue with the PLAN protocol above

---

## BLOCKED State

Enter BLOCKED if ANY of these occur:
- Results contradict predictions by >2x expected magnitude
- An experiment fails to produce output
- Ambiguity about which direction to take
- A dependency is missing or broken
- The human's revision in RSD.md is unclear

When blocked:
1. Update `## Status: BLOCKED`
2. Write a `**BLOCKED:** [specific reason]` entry in the current phase section
3. Add the block reason to `## Open Questions`
4. Run `bash scripts/compile_rsd.sh`
5. Git commit: `"research: cycle N BLOCKED — [reason]"`
6. STOP. Tell the human what happened and what decision is needed.

---

## Anti-Gaming Rules (MANDATORY — violating these invalidates the research)

1. **Predictions before execution.** NEVER write actual results before running experiments. NEVER modify predictions after seeing results. The git history must show prediction commits before execution commits.

2. **Artifact-linked claims only.** NEVER claim "done" without: file path + line count + key metric extracted from that file. Format: `DONE: [what] — [file] (commit [hash]), [evidence: metric=value at line N]`

3. **No post-hoc metric selection.** NEVER select, change, or add metrics after seeing results. All metrics must be declared in the PLAN phase prediction.

4. **Append-only within cycles.** NEVER modify past RSD entries within a completed phase. Past phases are immutable once committed.

5. **Architecture honesty.** NEVER omit structural code changes from the Code Architecture section. If code structure changed, it MUST be documented.

6. **No vague completion language.** Banned phrases: "I have implemented X", "X is done", "completed the task". Use the structured DONE format instead.

7. **Respect checkpoints.** NEVER proceed past a WAITING_HUMAN status. NEVER self-approve. Only human-written markers in RSD.md count as approval.

---

## Rollback Protocol

If the human or AI needs to undo an experiment:
1. `git log --oneline` — find the experiment commit
2. `git revert <commit>` — revert that specific experiment
3. Add a note to the current cycle in RSD.md: `**Reverted:** exp {N}.{M} — [reason]`
4. Update Code Architecture if the revert changed structure
5. Git commit: `"research: revert cycle N exp M — [reason]"`
