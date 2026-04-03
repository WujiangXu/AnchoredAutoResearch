# AnchoredAutoResearch

Human-in-the-loop research protocol for Claude Code. The AI runs experiments; you review decisions — not code.

## End-to-End Walkthrough

### 1. Install

```bash
git clone git@github.com:WujiangXu/AnchoredAutoResearch.git ~/AnchoredAutoResearch

# Per-project (recommended)
~/AnchoredAutoResearch/install.sh /path/to/my-project

# Or global (available in all projects)
~/AnchoredAutoResearch/install.sh --global
```

Requires: `pdflatex`, Python 3.

### 2. Initialize a Research Project

```bash
cd /path/to/my-project
```

Open Claude Code and run:

```
/research
> I want to study whether memory-augmented agents improve on SWE-bench
```

The AI searches arxiv/web for related work, builds a structured literature survey (`context/SURVEY.md`), and proposes a refined research goal. You confirm, and it creates `RSD.md` + `RSD.pdf`.

Alternatively, provide structured input:

```
/research
> Goal: Compare ReAct vs Reflexion on SWE-bench-lite
> Hypotheses: Reflexion's self-reflection improves fix rate by >10%
> Scope: 50 API budget, 1 week
```

### 3. Plan an Experiment

```
/research
```

The AI reads your knowledge sources, proposes an experiment with predictions, metrics, and cost estimates, then **stops**. You read `RSD.pdf` (3 min) and approve:

Edit `RSD.md` and add under the PLAN section:
```markdown
> **Human decision:** APPROVED
> **Date:** 2025-01-15
```

### 4. Execute

```
/research
```

The AI sees your approval and runs the experiment. Two modes:
- **manual** — AI implements and runs each experiment, commits per experiment
- **fast-loop-N** — Autonomous loop for N bounded iterations (modify → verify → keep/discard)

After execution, Codex reviews the code automatically. You read the review summary in `RSD.pdf`, not the code.

### 5. Interpret

The AI compares actual results to predictions, updates hypotheses, and proposes the next cycle. You review the prediction delta in `RSD.pdf` and approve to continue.

```
PLAN → [you approve] → EXECUTE → INTERPRET → [you approve] → next cycle
```

## Commands

| Command | What it does |
|---------|-------------|
| `/research` | Main loop — reads RSD state, runs the current phase |
| `/research:plan` | Interactive experiment design wizard |
| `/research:execute` | Run experiments (fast-loop or manual) |
| `/research:context` | Read local papers or search arxiv/web for a topic |
| `/research:context search <topic>` | Search + build structured literature survey |

## What You Review

| Layer | What | Time |
|-------|------|------|
| `RSD.pdf` | Decisions: hypotheses, predictions, prediction deltas | 3 min |
| Code Architecture section | Structure: module list, data flow | 1 min |
| Codex review summary | Code quality: issues, risks | 1 min |
| `git log --oneline` | Experiment timeline | 30 sec |

## Permissions for Execution Loop

During fast-loop execution, the AI runs verify/guard shell commands repeatedly. By default, Claude Code prompts you to approve each command. To avoid N approval prompts per loop:

**Option A: Pre-approve specific commands** in `.claude/settings.local.json`:
```json
{
  "permissions": {
    "allowedTools": [
      "Bash(python:*)",
      "Bash(pytest:*)",
      "Bash(bash scripts/*)"
    ]
  }
}
```

**Option B: Use sandbox mode** (recommended). Claude Code auto-allows Bash in sandboxed environments since commands run isolated:
```bash
claude --sandbox
```

Without either option, you'll be prompted to approve each verify/guard command during the loop. The loop still works — it just requires more clicks.

## Knowledge Sources

Drop papers/notes into `context/` or let the AI search:

```
/research:context search <topic>
```

Produces:
- `context/SOURCES.md` — quick-reference index
- `context/SURVEY.md` — structured analysis: methods landscape, what works/doesn't, research gaps, per-paper notes

Every experiment proposal must cite sources.

## Anti-Gaming

1. **Predictions before execution** — committed to git before experiments run
2. **Artifact-linked claims** — every result points to a file + line + metric
3. **No post-hoc metric selection** — all metrics declared in PLAN
4. **Append-only** — past phases can't be edited after commit
5. **Bounded execution** — never unbounded; human reviews after N experiments
6. **No self-approval** — only human-written markers in RSD.md count

## Project Structure

```
your-project/
├── RSD.md / RSD.pdf        # Research state (AI writes MD, you read PDF)
├── CLAUDE.md               # Project rules
├── context/                # Knowledge sources
│   ├── SOURCES.md          # Paper index
│   ├── SURVEY.md           # Structured literature analysis
│   └── papers/ notes/      # Drop files here
├── logs/                   # Experiment outputs + results TSV
├── checkpoints/            # Frozen RSD snapshots per cycle
├── outputs/                # Figures, tables, artifacts
└── scripts/                # compile_rsd.sh, md2latex.py
```

## Credits

Inspired by and adapted from [autoresearch](https://github.com/uditgoenka/autoresearch) by [Udit Goenka](https://github.com/uditgoenka), which pioneered the autonomous research loop with git-as-memory. AnchoredAutoResearch transfers autoresearch's best patterns (autonomous loop engine, git-based experiment memory, multi-persona analysis, modular skill architecture) and adds human checkpoints, prediction discipline, knowledge sources, dual-format RSD, and Codex code review.

The original autoresearch concept traces back to [Andrej Karpathy's tweet](https://x.com/karpathy/status/1908628566789910801) on autonomous AI research.

## License

MIT
