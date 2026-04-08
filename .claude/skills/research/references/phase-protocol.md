# Phase Protocol — PLAN → EXECUTE → INTERPRET

The three-phase cycle that drives all research. Each phase has a strict protocol.

## Phase: INIT (No RSD.md exists)

Supports two input modes — detect automatically based on what the human provides:

### Mode A: Topic description (AI searches + bootstraps)

If human provides a **topic sentence or paragraph** (e.g., "I want to study whether COMPASS alignment improves instruction-following in 7B models"):

1. Parse the topic description into: domain, key concepts, research direction
2. **Search for related work** — search the web for relevant papers on arxiv, Google Scholar, Semantic Scholar:
   - Search 3-5 queries derived from the topic
   - Download or save URLs for the top 5-10 relevant papers
   - Write URLs/summaries to `context/SOURCES.md`
3. Read the found papers/abstracts — extract key findings relevant to the topic
4. **Propose** to the human:
   - A refined research goal based on what the literature says
   - Initial hypotheses grounded in the literature
   - Suggested scope and constraints
   - Key knowledge gaps the research could fill
5. Ask human to confirm/revise the proposed goal + hypotheses
6. Create `RSD.md` from the confirmed inputs
7. Create directories, compile PDF, git commit
8. STOP.

### Mode B: Structured input (human provides fields directly)

If human provides **structured fields** (goal, hypotheses, scope, constraints):

1. Use the provided fields directly
2. Read all files in `context/` if any exist — write key takeaways
3. Create `RSD.md` using template from `references/rsd-schema.md`
4. Create directories if missing: `checkpoints/`, `logs/`, `outputs/`, `context/papers/`, `context/notes/`, `context/prior_work/`
5. Set Status: `PLAN`, Phase: `PLAN`, Cycle: `1`
6. Run `bash scripts/compile_rsd.sh`
7. Git commit all files: `"research: initialize RSD"`
8. STOP. Tell human: "RSD initialized. Read RSD.pdf. Run /research to begin planning cycle 1."

### Detection logic

- If input contains structured fields (`Goal:`, `Hypotheses:`, `Scope:`) → Mode B
- If input is free-form text without structured fields → Mode A
- If input has some fields but is missing key ones → Mode A for missing parts, Mode B for provided parts

### When to offer ADOPT instead of INIT

If no `RSD.md` exists AND the user's free-form input contains any of these
existing-project signals:

- File extension mentions: `.tex`, `.bib`
- Keywords: `draft`, `existing`, `already have`, `in progress`, `half finished`, `half-written`, `paper draft`
- Path-like strings: anything starting with `/`, `~/`, `./`, or containing `logs/`, `context/`, `papers/`
- References to prior work they themselves ran: `my experiments`, `my results`, `my logs`, `my code`

…the agent MUST offer ADOPT before falling through to INIT:

> "It looks like you already have an in-progress project. Do you want to
> **ADOPT** it into the protocol (imports existing state as a read-only Cycle 1)
> instead of starting fresh with INIT? (strict / fully-auto / no)"

- If the user picks `strict` or `fully-auto`: dispatch to
  `adopt-protocol.md` (see `## Phase: ADOPT` below).
- If the user picks `no`: fall through to INIT as normal.

The ADOPT offer is a **soft heuristic**. Never run ADOPT without an
explicit user acceptance. See `adopt-protocol.md` for the full protocol.

## Phase: ADOPT (No RSD.md, existing project being anchored)

Use ADOPT instead of INIT when the user has an already-in-progress research
project (existing LaTeX draft + git history + logs) and wants to anchor the
protocol to it. ADOPT collapses the entire imported state into a single
**Cycle 1**. The first "real" cycle (with fresh predictions) is Cycle 2.

**Entry points:**
1. Explicit command: `/research:adopt [--mode strict|fully-auto] [--from /path]`
   (Codex: `$research-adopt` or `$research:adopt`)
2. Implicit from `/research` when the free-form detection offers ADOPT
   (see "When to offer ADOPT" above) and the user accepts.

**Protocol:**
- Full ADOPT protocol lives in `adopt-protocol.md`. Read that file before
  doing anything.
- Full Imported Cycle Format lives in `rsd-schema.md` under the
  "Imported Cycle Format (ADOPT only)" section.
- The ONE exemption to the prediction-before-execution rule is documented
  in `core-principles.md` under principle #2 — imported cycles are
  exempted ONLY when explicitly marked `imported: true` with all prediction
  fields set to `N/A (imported)`.

**Post-ADOPT state:**
- `## Status: WAITING_HUMAN`, `## Phase: ADOPT`, `## Cycle: 1`
- Cycle 1 is read-only — its metadata cannot be edited by subsequent phases
- After the human approves in chat or `RSD.md`, the next `/research`
  invocation increments to Cycle 2 and enters PLAN phase normally

## Phase: PLAN

### Pre-flight: Read Knowledge Sources

Before proposing any experiment, MUST:
1. Read `context/SOURCES.md` — check for unread sources
2. Read any unread sources in `context/`
3. Update Knowledge Sources table in RSD.md with key takeaways

### Effort levels

`/research:plan` accepts an `--effort low|middle|high` flag that controls
how widely the ideation step explores before settling on a proposal. The
default is `low` (backward-compatible — identical to the behavior before
the effort flag was added).

Effort level is **orthogonal** to Mode A (human proposes, AI refines) vs
Mode B (AI proposes). A human-proposed core idea with `--effort high`
means "take my idea and explore wild variations of it". A blank plan
with `--effort low` is the classic AI-proposes-narrow behavior.

**Regardless of effort level, the final written PLAN block is ONE
experiment with ONE prediction and ONE metric. Effort affects the
ideation step, not the output shape.** The rejected alternatives are
recorded in the `**Alternatives considered:**` field for auditability.

#### LOW (default)

Current behavior verbatim. AI reads RSD + `context/`, proposes ONE
experiment tied to the user's stated goal, fills the PLAN block. No
candidate generation, no alternatives. The `**Alternatives considered:**`
field is written as `N/A (low effort)`.

Use LOW for incremental research, well-defined problems, time-pressed
iteration.

#### MIDDLE

Silent-pick mode: AI explores 2-3 adjacent framings, picks the best, logs
the rest.

1. **Sub-topic detection**: Parse the user's goal into 1-3 sub-topics using
   the Methods Landscape in `context/SURVEY.md` if present, otherwise from
   the user's own description.
2. **SURVEY.md pre-check**: If `context/SURVEY.md` is missing OR has no
   entries matching the detected sub-topic, **offer once** to run
   `/research:context search <topic>` first:
   > "No SURVEY.md entries found for `<topic>`. Run `/research:context
   > search <topic>` first to build a literature survey? (yes / no / skip)"
   - `yes` → run the search, then continue
   - `no` or `skip` → continue with whatever is in `context/` and record a
     `knowledge gap` note in the final PLAN block
3. **Generate 2-3 candidates** within the detected sub-topics. Each
   candidate is a short record: `{direction, 1-line hypothesis, grounded-in
   citation, estimated cost, 1-line risk}`.
4. **Rank** by `relevance_to_user_goal × novelty × feasibility` (each
   scored 1-5). Pick the highest.
5. **Write** the chosen candidate as the PLAN block. Write the 1-2
   rejected candidates as bullets in `**Alternatives considered:**` with
   a one-line reason for rejection each.

MIDDLE does NOT round-trip to the user between start and the final PLAN —
the standard approval step at the end is the user's only opportunity to
revise.

Use MIDDLE when you know the area and want a couple of options to be
considered without burning the tokens of HIGH.

#### HIGH

Wide exploration mode with explicit cross-field ideation and a user
selection step. This is the token-heavy mode — gate it behind a cost
prompt at the start.

**Search-pool size (`--search N`)**: HIGH runs a wide literature search
via `/research:context search` by default. The discover-pool size is:
- `N = 200` when the user did not pass `--search` on `/research:plan`
- `N = <user value>` (clamped to `10`-`500`) when `--search N` was passed
Deep-read count follows `min(30, N // 5)` per `knowledge-sources.md`.
MIDDLE may also inherit a user-passed `--search N` when it offers the
search; LOW never runs a search and ignores `--search` silently.

1. **Cost gate** (MANDATORY first step): Before any candidate generation,
   tell the user:
   > "High-effort exploration will generate 5-8 candidate directions
   > spanning multiple sub-topics, and runs a wide literature search
   > (discover pool = `<N>` papers via `/research:context search`, with
   > top `<min(30, N // 5)>` deep-read). This can use significantly more
   > tokens than low/middle. Proceed? (yes / cancel)"
   - Substitute `<N>` with the effective value (200 default, or the
     user's `--search N` override).
   - `cancel` → STOP, tell the user to rerun with `--effort low` or
     `--effort middle` if they want to continue, or pass a smaller
     `--search N` (e.g. `--search 50`) if the cost is the blocker.
   - `yes` → continue to step 2

2. **SURVEY.md pre-check + wide search**: If `context/SURVEY.md` is
   missing OR has no entries for the detected sub-topic, automatically
   run (no prompt needed — the cost gate already confirmed):
   ```
   /research:context search <topic> --search <N>
   ```
   where `<N>` is the effective search-pool size from the Search-pool
   note above. If SURVEY.md already covers the sub-topic and the user
   did NOT pass `--search`, skip the search; if the user DID pass
   `--search N`, run the search anyway to honor the explicit request.
   If for any reason the search is skipped entirely, mark affected
   candidates with the explicit "novel — no prior work found" marker.

3. **Wild candidate generation**: Enumerate 5-8 candidate directions
   spanning multiple sub-topics. The protocol REQUIRES that the set:
   - Covers at least 3 distinct sub-topics within the user's research
     area (e.g., for "LLM agents": prompting, memory, context engineering,
     tool use, RL training, benchmarks, planning, self-reflection,
     multi-agent coordination)
   - Includes at least ONE combination candidate (two sub-topics combined,
     e.g., "memory-aware tool use" or "RL-trained context compression")
   - Includes at least ONE cross-field / unconventional candidate IF
     plausible (e.g., applying Genetic Algorithms to prompt optimization,
     control-theoretic stability bounds for agent loops, economic
     mechanism design for multi-agent coordination, biology-inspired
     memory consolidation). If no cross-field analogy is plausible, skip
     this requirement rather than force a bad one.

   For each candidate, produce this record:
   ```
   - Direction: [one line]
   - Hypothesis: [one line — what you expect to find]
   - Mechanism sketch: [2-3 lines — how the experiment would work]
   - Grounded in: [source citation, or "novel — no prior work found, see
     SURVEY.md gaps"]
   - Novelty: [1-5]
   - Feasibility: [1-5]
   - Relevance: [1-5]
   - Risk: [one line — what could go wrong]
   ```

   **Cross-field auditability**: If a candidate applies a method from
   outside the user's field (e.g., GA for LLM agents), the Mechanism
   sketch MUST include a one-sentence analogy explaining why the
   cross-field mechanism plausibly applies. No analogy → drop the
   candidate.

4. **Rank** by the simple sum `novelty + feasibility + relevance` (range
   3-15). Ties broken by feasibility (higher wins).

5. **Present to user** via `AskUserQuestion` with the top 5-8 candidates
   as options. Each option: label is the Direction (short), description
   is `Hypothesis + "(N=novelty/F=feasibility/R=relevance)"`. Include an
   explicit extra option labeled "You pick (highest combined score)" so
   the user can delegate back to the AI.

6. **Write the chosen candidate** as the full PLAN block with
   `**Effort level:** high`. The rejected candidates go into
   `**Alternatives considered:**` as bullets — one line each with their
   combined score and the reason they weren't picked. If the user chose
   "You pick", the AI picks the highest-score candidate and the
   `**Alternatives considered:**` bullets include the full ranked list
   with combined scores.

Use HIGH for early-stage exploration, broad topics ("I want to study LLM
agents"), or when the user explicitly wants to be surprised.

#### Effort-level guardrails (all levels)

- **Citation is non-negotiable**: every candidate at every effort level
  MUST cite a `Grounded in:` source — either a SURVEY.md row, a specific
  paper, or the explicit string "novel — no prior work found, see
  SURVEY.md gaps". Silent grounding is a protocol violation.
- **One metric, one prediction**: effort affects ideation breadth, never
  output shape. The final PLAN block has exactly one metric, one
  prediction, one experiment — even in HIGH. This preserves the
  anti-gaming discipline from core-principles.md §2.
- **No unbounded branching**: MIDDLE caps at 3 candidates, HIGH caps at 8.
  If the AI generates more during ideation, it must rank and truncate
  before presenting.
- **Cost gate is single-shot**: the HIGH cost prompt fires once at the
  start, not per-candidate. Once the user says yes, run the whole
  protocol straight through to the selection step without interruption.

### Write the Plan (two modes)

1. Read RSD.md fully. Review all prior cycles, hypotheses, open questions.

**Mode A: Human proposes, AI refines** (human is the PI)

If the human already wrote an experiment idea in the RSD or in chat:
- Read the human's proposal
- AI ADDS: predictions, metrics, verify/guard commands, cost estimates, knowledge source citations
- AI REFINES: fill in any gaps, suggest improvements, flag risks
- DO NOT replace the human's core idea — enhance it

**Mode B: AI proposes** (human delegates ideation)

If no human proposal exists and human says "propose" or leaves PLAN blank:
- AI generates the experiment proposal based on:
  - Current hypotheses and prior results
  - Knowledge sources in context/
  - What worked/failed in previous cycles
  - Open questions flagged by human

**In both modes, write under the current cycle's `### PLAN` section:**

```markdown
### PLAN
**Proposed by:** [human | AI | human-refined-by-AI]
**Effort level:** [low | middle | high]
**Proposed:** [what experiment to run and why — link to hypothesis]
**Grounded in:** [which knowledge source informed this — cite file or URL]
**Alternatives considered:**
- [rejected candidate 1 — one line + why rejected]
- [rejected candidate 2 — one line + why rejected]
- (or "N/A (low effort)" for low-effort plans)
**Prediction:** [specific expected outcome — numbers, directions, ranges]
**If wrong:** [what a failed prediction would imply for the hypothesis]
**Files to modify:** [list of files that will be created or changed]
**Estimated cost:** [API calls, compute time, tokens, or "minimal"]
**Execution mode:** [manual | fast-loop-N (bounded iterations)]
**Verify command:** [command that extracts metric, if fast-loop mode]
**Guard command:** [regression check command, if fast-loop mode]
```

The `**Effort level:**` and `**Alternatives considered:**` fields are
required in new PLAN blocks going forward. Cycle-1 blocks written before
the feature landed remain valid — downstream tools must tolerate both
the old (9-field) and new (11-field) shapes.

3. Update `## Status: WAITING_HUMAN` and `## Phase: PLAN`
4. Run `bash scripts/compile_rsd.sh`
5. Git commit: `"research: cycle N plan"`
6. Copy `RSD.md` to `checkpoints/cycle_N_plan.md` and `RSD.pdf` to `checkpoints/cycle_N_plan.pdf`
7. STOP. Present to human:
   - Show the plan section
   - Say: **"Read RSD.pdf for the formatted view. Reply with approval or revision in chat, or add a clear note under PLAN in RSD.md. Exact template is optional."**
   - Give short examples such as:
   ```
   approved, proceed
   ```
   or:
   ```
   revised: focus more on X while keeping Y fixed
   ```
   **"Then run /research to continue."**

## Phase: EXECUTE

**Pre-condition:** Current cycle's PLAN must have explicit human approval or revision, either in `RSD.md` or in the latest human chat message.

If no approval: tell human, STOP.

If approved (including REVISED — incorporate the revision):
1. If the approval/revision came from chat, append a concise summary of that human feedback to the current PLAN section and `## Human Decisions Log` before proceeding.
2. Use the approved or revised intent as the execution boundary.

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
1. Use the code review tool to review the git diff since EXECUTE started
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
8. STOP. Present prediction delta and hypothesis updates to human, and ask for a normal-language approval or revision in chat or RSD. Exact template is optional.

## Advancing to Next Cycle

When INTERPRET has explicit human approval or revision in chat or RSD:
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
