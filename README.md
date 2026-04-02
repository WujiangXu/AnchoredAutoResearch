# AnchoredAutoResearch

Human-in-the-loop research protocol for Claude Code. The AI executes experiments; you review decisions — not code.

Inspired by [autoresearch](https://github.com/uditgoenka/autoresearch), with added prediction discipline, knowledge sources, and human checkpoints.

## How It Works

```
You describe a topic
  → AI searches literature, builds a survey
    → AI (or you) proposes an experiment with predictions
      → You approve in RSD.md
        → AI runs experiments (bounded, per-experiment git commits)
          → Codex reviews the code
            → AI interprets results vs predictions
              → You review, approve next cycle
```

**You read a 2-page PDF. You never read code.** The AI writes to `RSD.md` (markdown); it auto-compiles to `RSD.pdf` with status badges, tables, and decision boxes.

## Quick Start

```bash
# Install into your research project
git clone git@github.com:WujiangXu/AnchoredAutoResearch.git ~/AnchoredAutoResearch
~/AnchoredAutoResearch/install.sh /path/to/my-project

cd /path/to/my-project
```

Then in Claude Code:

```
# Option A: Start from a topic sentence — AI searches arxiv, builds survey
/research
> I want to study whether memory-augmented agents improve on SWE-bench

# Option B: Search for related work first
/research:context search memory-augmented LLM agents for code repair

# Option C: Start with structured input
/research
> Goal: Compare ReAct vs Reflexion on SWE-bench-lite
> Hypotheses: Reflexion's self-reflection improves fix rate by >10%
> Scope: 50 API budget, 1 week
```

## Commands

| Command | What it does |
|---------|-------------|
| `/research` | Main loop — reads RSD state, runs the current phase |
| `/research:plan` | Interactive experiment design wizard |
| `/research:execute` | Run experiments (fast-loop or manual) |
| `/research:context` | Read local papers or search arxiv/web for a topic |
| `/research:context search <topic>` | Search + build structured literature survey |

## The Research Cycle

```
PLAN → [you approve] → EXECUTE → INTERPRET → [you approve] → next cycle
```

**PLAN:** AI (or you) proposes an experiment. AI adds predictions, metrics, cost estimates, literature citations. You approve or revise in `RSD.md`.

**EXECUTE:** AI runs experiments with per-experiment git commits. Two modes:
- `manual` — AI implements and runs each experiment directly
- `fast-loop-N` — Autonomous loop (modify→verify→keep/discard) for N iterations

After execution, Codex reviews the code automatically.

**INTERPRET:** AI compares actual results to predictions. Updates hypotheses. Proposes next cycle. You approve or redirect.

## What You Review (Not Code)

| Layer | What | Time |
|-------|------|------|
| `RSD.pdf` | Decisions: hypotheses, predictions, prediction deltas | 3 min |
| Code Architecture section | Structure: module list, data flow, changes | 1 min |
| Codex review summary | Code quality: issues, risks | 1 min |
| `git log --oneline` | Timeline: experiment sequence | 30 sec |

## Knowledge Sources

Drop papers/notes into `context/` or let AI search:

```
/research:context search <topic>
```

Produces two files:
- `context/SOURCES.md` — quick index table
- `context/SURVEY.md` — structured analysis:
  - Methods landscape (strengths, limitations, best results)
  - What works / what doesn't
  - Research gaps and suggested directions
  - Per-paper notes

Every experiment proposal must cite sources. "No prior work found" must be justified.

## Anti-Gaming

The protocol prevents AI from faking results:

1. **Predictions before execution** — written and committed to git before experiments run
2. **Artifact-linked claims** — every result points to a file + line + metric value
3. **No post-hoc metric selection** — all metrics declared in PLAN
4. **Append-only** — past phases can't be edited after commit
5. **Bounded execution** — never unbounded; human reviews after N experiments
6. **No self-approval** — only human-written markers in RSD.md count

## Project Structure

```
your-project/
├── RSD.md              # Research state (AI writes, you approve)
├── RSD.pdf             # Formatted view (you read this)
├── CLAUDE.md           # Project rules
├── context/
│   ├── SOURCES.md      # Paper index
│   ├── SURVEY.md       # Structured literature analysis
│   ├── papers/         # Drop PDFs here
│   └── notes/          # Your research notes
├── logs/               # Experiment outputs + results TSV
├── checkpoints/        # Frozen RSD snapshots per cycle
├── outputs/            # Figures, tables, artifacts
├── scripts/
│   ├── compile_rsd.sh  # MD → LaTeX → PDF
│   └── md2latex.py     # Markdown to LaTeX converter
└── templates/rsd.tex   # LaTeX template
```

## Install

```bash
# Per-project (isolated)
~/AnchoredAutoResearch/install.sh /path/to/project

# Global (available everywhere)
~/AnchoredAutoResearch/install.sh --global
```

Requires: `pdflatex` (for PDF compilation). Python 3 (for md2latex.py).

## How It Differs from autoresearch

| | autoresearch | AnchoredAutoResearch |
|---|---|---|
| Human role | Set goal, walk away | Approve plans, review interpretations |
| Execution | Unbounded loop | Always bounded, human reviews after |
| Predictions | None | Mandatory before every experiment |
| Literature | None | AI searches and builds structured survey |
| Code review | None | Codex reviews automatically |
| Output format | TSV log | RSD.md → LaTeX → PDF with status badges |
| Rollback | git revert | git revert + RSD audit trail |

## License

MIT
