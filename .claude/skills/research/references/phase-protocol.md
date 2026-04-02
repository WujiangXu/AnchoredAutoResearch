# Phase Protocol — PLAN → EXECUTE → INTERPRET

The three-phase cycle that drives all research. Each phase has a strict protocol.

## Phase: INIT (No RSD.md exists)

1. Ask human for:
   - Research goal (what are we trying to achieve?)
   - Scope and constraints (budget, time, off-limits approaches)
   - Initial hypotheses (if any)
   - Knowledge sources (papers, URLs, notes to drop in context/)
2. Read all files in `context/` if any exist — write key takeaways
3. Create `RSD.md` using template from `references/rsd-schema.md`
4. Create directories if missing: `checkpoints/`, `logs/`, `outputs/`, `context/papers/`, `context/notes/`, `context/prior_work/`
5. Set Status: `PLAN`, Phase: `PLAN`, Cycle: `1`
6. Run `bash scripts/compile_rsd.sh`
7. Git commit all files: `"research: initialize RSD"`
8. STOP. Tell human: "RSD initialized. Read RSD.pdf. Run /research to begin planning cycle 1."

## Phase: PLAN

### Pre-flight: Read Knowledge Sources

Before proposing any experiment, MUST:
1. Read `context/SOURCES.md` — check for unread sources
2. Read any unread sources in `context/`
3. Update Knowledge Sources table in RSD.md with key takeaways

### Write the Plan

1. Read RSD.md fully. Review all prior cycles, hypotheses, open questions.
2. Write under the current cycle's `### PLAN` section:

```markdown
### PLAN
**Proposed:** [what experiment to run and why — link to hypothesis]
**Grounded in:** [which knowledge source informed this — cite file or URL]
**Prediction:** [specific expected outcome — numbers, directions, ranges]
**If wrong:** [what a failed prediction would imply for the hypothesis]
**Files to modify:** [list of files that will be created or changed]
**Estimated cost:** [API calls, compute time, tokens, or "minimal"]
**Execution mode:** [manual | fast-loop-N (bounded iterations)]
**Verify command:** [command that extracts metric, if fast-loop mode]
**Guard command:** [regression check command, if fast-loop mode]
```

3. Update `## Status: WAITING_HUMAN` and `## Phase: PLAN`
4. Run `bash scripts/compile_rsd.sh`
5. Git commit: `"research: cycle N plan"`
6. Copy `RSD.md` to `checkpoints/cycle_N_plan.md` and `RSD.pdf` to `checkpoints/cycle_N_plan.pdf`
7. STOP. Present to human:
   - Show the plan section
   - Say: **"Read RSD.pdf for the formatted view. To approve, edit RSD.md and add under PLAN:"**
   ```
   > **Human decision:** APPROVED
   > **Date:** YYYY-MM-DD
   ```
   **"Then run /research to continue."**

## Phase: EXECUTE

**Pre-condition:** Current cycle's PLAN must contain approval marker.

If no approval: tell human, STOP.

If approved (including REVISED — incorporate the revision):

### Check Execution Mode

Read the `**Execution mode:**` field from the approved plan:

- **manual** → Execute experiments directly (current behavior)
- **fast-loop-N** → Delegate to autonomous loop protocol (`references/autonomous-loop.md`) with N bounded iterations

### Manual Execution

1. Update `## Status: EXECUTING` and `## Phase: EXECUTE`
2. Write `### EXECUTE` with Pre-state (files @ commit hashes)
3. For EACH experiment:
   a. Implement the change
   b. Run experiment, capture output to `logs/exp_{cycle}_{sub}.json`
   c. Write evidence to RSD: file pointer + line count + key metric
   d. Git commit: `"research: cycle N exp {sub} — {one-line description}"`
4. After all experiments, write summary:
   - Actual results (concrete numbers)
   - Post-state (files @ new commit hashes)
   - Commit range
5. Update Code Architecture if structure changed

### Fast-Loop Execution

Delegate to `references/autonomous-loop.md`:
- Pass: metric, verify command, guard command, bounded iterations from plan
- The loop handles: modify → commit → verify → guard → decide → log
- After loop completes, summarize results in RSD

### Post-Execute: Codex Review

After all experiments (manual or fast-loop):
1. Use `codex:rescue` to review the git diff since EXECUTE started
2. Write Codex review summary to RSD under EXECUTE section:
   ```
   **Codex review:** [summary of code quality findings]
   ```
3. Git commit: `"research: cycle N execute complete"`
4. Auto-advance to INTERPRET phase

## Phase: INTERPRET

1. Read current cycle's PLAN (predictions) and EXECUTE (actual results)
2. Write `### INTERPRET` under current cycle:

```markdown
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
4. Append to `## Human Decisions Log`
5. Run `bash scripts/compile_rsd.sh`
6. Git commit: `"research: cycle N interpret"`
7. Copy to `checkpoints/cycle_N_interpret.{md,pdf}`
8. STOP. Present prediction delta and hypothesis updates to human.

## Advancing to Next Cycle

When INTERPRET has approval marker:
1. Increment `## Cycle:` by 1
2. Add new cycle section: `## Cycle {N+1}`
3. Enter PLAN phase for new cycle

## BLOCKED State

Enter BLOCKED if:
- Results contradict predictions by >2x expected magnitude
- Experiment fails to produce output
- Ambiguity about direction
- Dependency missing
- Human revision unclear

When blocked:
1. Update `## Status: BLOCKED`
2. Write `**BLOCKED:** [reason]` in current section
3. Add to Open Questions
4. Compile RSD, git commit, STOP
