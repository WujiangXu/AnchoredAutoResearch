# Autonomous Loop Protocol — Fast Execution Engine

Adapted from [autoresearch](https://github.com/uditgoenka/autoresearch). The 8-phase execution loop for running bounded experiments autonomously within an approved plan.

**Core idea:** Modify → Commit → Verify → Guard → Decide (keep/discard) → Log → Repeat (bounded).

**Critical difference from autoresearch:** ALWAYS bounded. NEVER unbounded. Human must review after N iterations via the INTERPRET phase.

## When This Protocol Activates

During EXECUTE phase, when the approved PLAN specifies:
```
**Execution mode:** fast-loop-N
**Verify command:** [command that extracts metric]
**Guard command:** [regression check, optional]
```

If execution mode is `manual`, this protocol does NOT activate — use the manual execution steps in `phase-protocol.md` instead.

## Permissions (User-Controlled)

The fast-loop runs shell commands (verify, guard, git) repeatedly. Launch the session with the permissions you want before entering EXECUTE:

- **Claude Code:** start Claude in the permission mode you want, or approve commands manually during the loop.
- **Codex CLI:** launch with `codex --full-auto` or equivalent session permissions for low-friction execution.

Research decision checkpoints (WAITING_HUMAN) are protocol-level — they always require human approval in RSD.md regardless of shell permission settings.

## Phase 0: Precondition Checks

**MUST complete ALL checks before entering the loop.**

```bash
# 1. Verify git repo is clean
git status --porcelain
# → If dirty: warn and ask to stash/commit first

# 2. Check for stale lock files
ls .git/index.lock 2>/dev/null && echo "WARN: stale lock"

# 3. Verify the verify command works (dry run)
BASELINE=$({verify_command})
# → Must output a parseable number. If not: STOP, report to human.

# 4. Record baseline in RSD and results TSV
```

## Phase 1: Review (Before Each Iteration)

Build situational awareness every iteration:

1. Read RSD.md — current cycle's PLAN (what was approved, predictions)
2. Read last 10-20 entries from results TSV (`logs/research-results.tsv`)
3. Run `git log --oneline -20` — see recent experiments (kept vs reverted)
4. Run `git diff HEAD~1` — inspect last kept change
5. Identify: what worked, what failed, what's untried
6. Check `current_iteration` vs `max_iterations` — if done, exit loop

**Git IS the memory.** After rollbacks, state may differ from expectations. Always verify via git log.

## Phase 2: Ideate (Pick Next Change)

**MUST consult git history AND results log AND knowledge sources.**

Priority order:
1. **Fix crashes** from previous iteration first
2. **Exploit successes** — try variants of what worked (git diff of last keep)
3. **Explore untried approaches** — cross-reference results + git + knowledge sources
4. **Combine near-misses** — two changes that individually didn't help might work together
5. **Simplify** — remove code while maintaining metric (simpler = better)

Anti-patterns:
- Don't repeat an approach already in `git log` as reverted
- Don't make multiple unrelated changes at once
- Don't chase marginal gains with ugly complexity
- If <3 iterations remaining, prioritize exploitation over exploration

## Phase 3: Modify (One Atomic Change)

- Make ONE focused change to in-scope files
- **One-sentence test:** if you need "and" to describe it, it's two changes — split them
- Write the description BEFORE making the change (forces clarity)

```bash
# Validate atomicity before committing
FILES_CHANGED=$(git diff --name-only | wc -l)
if [ "$FILES_CHANGED" -gt 5 ]; then
  echo "WARN: ${FILES_CHANGED} files changed — verify single intent"
fi
```

## Phase 4: Commit (Before Verification)

**MUST commit before running verification.** Enables clean rollback.

```bash
# Stage ONLY in-scope files (NEVER git add -A)
git add <file1> <file2> ...

# Check there's something to commit
git diff --cached --quiet && echo "no-op — skip this iteration"

# Commit with descriptive message
git commit -m "research: cycle {N} exp {M} — {one-sentence description}"
```

If pre-commit hook blocks: fix the issue, re-stage, retry. NEVER use `--no-verify`.

## Phase 5: Verify (Mechanical Metric)

Run the verify command from the approved plan. Extract the metric.

```bash
METRIC=$({verify_command})
# Must be a parseable number
```

**Timeout:** If verification exceeds 2x normal time, kill and treat as crash.

### Noise Handling (for volatile metrics)

If metric is noisy (benchmarks, ML training):
- Run verify 3 times, take median
- Only keep if improvement > min-delta threshold (e.g., 2%)
- Confirmation run: re-verify before final keep decision

## Phase 5.5: Guard (Regression Check)

If a guard command was defined:

```bash
{guard_command}
# Must exit 0 to pass
```

- Only run if metric improved (no point if we're discarding anyway)
- Guard is pass/fail — no metric extraction
- If guard fails: revert, try reworking (max 2 attempts), then discard
- NEVER modify test files to make guard pass — adapt the implementation instead

## Phase 6: Decide

```
IF metric_improved AND (no guard OR guard_passed):
    STATUS = "keep"
    # Commit stays. Write evidence to RSD.

ELIF metric_improved AND guard_failed:
    safe_revert()
    # Try reworking (max 2 attempts)
    # If still failing: STATUS = "discard"

ELIF metric_same_or_worse:
    STATUS = "discard"
    safe_revert()

ELIF crashed:
    # Attempt fix (max 3 tries), then:
    STATUS = "crash"
    safe_revert()
```

### safe_revert function

```bash
# Preferred: git revert (preserves experiment in history for learning)
git revert HEAD --no-edit

# Fallback: if revert conflicts
git revert --abort && git reset --hard HEAD~1
```

Prefer `git revert` — it preserves the failed experiment in git log so future iterations can learn from it.

## Phase 7: Log Results

### To results TSV (`logs/research-results.tsv`)

```tsv
cycle	exp	commit	metric	delta	guard	status	description
```

Append after every iteration:
```bash
echo -e "{cycle}\t{exp}\t{commit}\t{metric}\t{delta}\t{guard}\t{status}\t{description}" >> logs/research-results.tsv
```

### To RSD.md (evidence for human review)

For "keep" results, write under EXECUTE section:
```markdown
**Experiment {cycle}.{exp}: {description}**
- Output: `logs/exp_{cycle}_{exp}.json` ({N} lines)
- Key metric: {metric_name} = {value}
- Status: keep (delta: {delta})
- Commit: {hash}
```

For "discard" and "crash", write brief summary:
```markdown
**Experiment {cycle}.{exp}: {description}** — discarded ({reason})
```

See `references/results-logging.md` for full TSV format specification.

## Phase 8: Repeat or Exit

```
IF current_iteration < max_iterations:
    Go to Phase 1
ELSE:
    Print summary:
    "=== Fast-loop complete ({N}/{N} iterations) ==="
    "Baseline: {baseline} → Best: {best} ({delta})"
    "Keeps: X | Discards: Y | Crashes: Z"
    Exit loop → continue to post-execute steps
```

## Post-Loop: Codex Review

After the loop completes (or after manual execution):

1. Get the git diff since EXECUTE started:
   ```bash
   git diff {pre_execute_commit}..HEAD
   ```
2. Use the code review tool to review the changed code
3. Write Codex review summary to RSD under EXECUTE section:
   ```markdown
   **Codex review:**
   - [summary of code quality findings]
   - [any issues or suggestions]
   - [risk assessment: low/medium/high]
   ```
4. Git commit: `"research: cycle N execute complete"`

## Post-Loop: Update Code Architecture

If code structure changed during execution:
1. Update `## Code Architecture` section in RSD.md
2. Document: new modules, changed data flow, new dependencies
3. Add `### Changes This Cycle` sub-section

## When Stuck (>5 Consecutive Discards)

1. Re-read ALL in-scope files from scratch
2. Re-read the original goal and approved plan
3. Review entire results TSV for patterns
4. Consult knowledge sources in `context/` for alternative approaches
5. Try combining 2-3 previously successful changes
6. Try the OPPOSITE of what hasn't been working
7. If still stuck after 2 more attempts: set BLOCKED status, STOP
