# Core Principles — AnchoredAutoResearch

7 principles adapted from autoresearch, plus our unique additions for human-in-the-loop research.

## 1. Constraint = Enabler (from autoresearch)

Autonomy succeeds through intentional constraint.

| Constraint | Why It Helps |
|------------|-------------|
| Bounded scope (in-scope files) | Agent has full context |
| Single mechanical metric | No ambiguity in verification |
| Bounded iterations (NEVER unbounded) | Human must review periodically |

**Our addition:** Human checkpoints at PLAN and INTERPRET phases constrain the agent to operate within approved parameters only.

## 2. Predictions Before Execution (OUR UNIQUE ADDITION)

The primary anti-reward-hacking mechanism. Before ANY experiment:

1. Write specific predicted outcome (numbers, directions, ranges)
2. Write what a wrong prediction would imply
3. Git commit the prediction
4. THEN run the experiment

The git history MUST show prediction commits before execution commits. If the AI's predictions are suspiciously perfect (delta always < 1%), the human can detect gaming by reviewing the prediction delta pattern.

## 3. Metrics Must Be Mechanical (from autoresearch)

If you can't verify with a command, you can't iterate autonomously.

Valid: test pass count, F1 score, BLEU, loss value, coverage %, response time
Invalid: "looks better", "seems improved", "cleaner code"

**Our addition:** All metrics declared in PLAN phase. No adding/changing metrics after seeing results.

## 4. Git as Memory (from autoresearch)

Every iteration, read your own git history:
```bash
git log --oneline -20           # experiment sequence (kept vs reverted)
git diff HEAD~1                 # last kept change — what worked and why
git log --oneline | grep "Revert"  # failed approaches to avoid
```

Commit messages are memory. Reverts are "lessons learned." NEVER repeat an approach that was already reverted.

**Our addition:** RSD.md adds structured memory on top of git — hypotheses, predictions, interpretation, human decisions. Git stores WHAT happened; RSD stores WHY and WHAT WE LEARNED.

## 5. Knowledge Sources Inform Strategy (OUR UNIQUE ADDITION)

Before proposing ANY experiment:
1. Read all sources in `context/` (papers, notes, prior work)
2. Every proposal MUST cite which source informed it
3. If no relevant prior work: explicitly state "no prior work found" and explain novelty

This prevents the agent from proposing experiments that have already been tried in the literature.

## 6. Artifact-Linked Claims Only (OUR UNIQUE ADDITION)

Every claim must point to a concrete artifact:

**Banned:** "I have implemented X", "X is done", "completed the task"

**Required format:** `DONE: [what] — [file] (commit [hash]), [evidence: metric=value at line N]`

Every result in the RSD must include:
- File path to the output
- Line count or size
- Key metric value extracted from the file
- Git commit hash

## 7. Honest Limitations (from autoresearch)

State what the system cannot do. If blocked:
- Set Status: BLOCKED with specific reason
- Add to Open Questions in RSD
- STOP and wait for human guidance
- NEVER improvise past a block

## Anti-Gaming Rules (MANDATORY)

1. NEVER write results before running experiments
2. NEVER modify predictions after seeing results
3. NEVER claim "done" without artifact pointer
4. NEVER select or change metrics after seeing results
5. NEVER modify past RSD entries (append-only within cycles)
6. NEVER skip the prediction step
7. NEVER omit architecture changes from Code Architecture section
8. NEVER proceed past WAITING_HUMAN status
9. NEVER self-approve — only human markers count
10. NEVER run unbounded execution loops — always bounded with human review after

## Rollback Protocol

Each experiment has its own commit. Rollback is:
```bash
git log --oneline              # find the experiment
git revert <commit> --no-edit  # revert that specific experiment
```
Then update RSD.md: `**Reverted:** exp N.M — [reason]`

Prefer `git revert` over `git reset --hard` — revert preserves the experiment in history for learning.
