# AnchoredAutoResearch

Human-in-the-loop research protocol for AI coding agents. The AI runs experiments; you review decisions — not code.

Supports **Claude Code** and **Codex CLI** — same protocol, same shared references, zero switching cost.

## End-to-End Walkthrough

### 1. Install

```bash
git clone git@github.com:WujiangXu/AnchoredAutoResearch.git ~/AnchoredAutoResearch

# Per-project (recommended)
~/AnchoredAutoResearch/install.sh /path/to/my-project

# Or global (available in all projects)
~/AnchoredAutoResearch/install.sh --global
```

Requires: `pdflatex`, Python 3, and either [Claude Code](https://docs.anthropic.com/en/docs/claude-code) or [Codex CLI](https://github.com/openai/codex).

The target project path may be empty or may not exist yet. The installer will create it.

### 2. Initialize a Research Project

```bash
cd /path/to/my-project
```

Open your agent and run:

| Claude Code | Codex CLI |
|-------------|-----------|
| `/research` | `$research` |

```
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

#### Already have a project? Anchor it instead

If you already have a codebase, experiment results, or a draft paper, use `/research:adopt` (Codex: `$research-adopt`) to anchor the protocol to your existing work instead of starting from a blank `RSD.md`. You don't need all three — **any one** of the following is enough to adopt:

- a `.tex` paper draft
- git history with experiment-style commits
- a `logs/` directory with run artifacts
- knowledge sources in `context/`

Pass your research idea inline so it seeds the imported `RSD.md`:

```
/research:adopt
> Idea: Benchmarking memory-augmented agents on SWE-bench. Hypothesis:
>       persistent scratchpad memory raises fix rate >10% over ReAct.
> Codebase: agents/ has my baseline ReAct loop on top of LangChain
> Experiments so far: logs/ has 5 ablation runs from last week, metric is pass@1
```

ADOPT collapses **everything that already exists** into a read-only **Cycle 1** snapshot. Your first real cycle with predictions starts at **Cycle 2**, which is the first time the prediction-before-execution rule kicks in. Two modes:

| Mode | When |
|------|------|
| `strict` (default) | Cycle 1 is the snapshot only — no synthetic PLAN/EXECUTE/INTERPRET. Maximum auditability. |
| `--mode fully-auto` | Same snapshot, plus a synthetic PLAN/EXECUTE/INTERPRET triple where every prediction-adjacent field is the literal `N/A (imported)` so audits can detect imported cycles. |

After ADOPT finishes you read `RSD.pdf`, fix anything the auto-import got wrong directly in `RSD.md`, approve in chat or in the file, then run `/research` to enter Cycle 2 PLAN.

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

Exact wording is optional. A clear chat reply like `approved, proceed` or `revised: focus more on X` also counts.

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

| Purpose | Claude Code | Codex CLI |
|---------|-------------|-----------|
| Main loop — reads RSD state, runs the current phase | `/research` | `$research` |
| Anchor protocol to an in-progress project (any of: LaTeX draft, git history, logs/, or knowledge sources) | `/research:adopt` | `$research-adopt` |
| Interactive experiment design wizard (optional `--effort low\|middle\|high`, `--search N`) | `/research:plan` | `$research-plan` |
| Run experiments (fast-loop or manual) | `/research:execute` | `$research-execute` |
| Read local papers or search arxiv/web | `/research:context` | `$research-context` |
| Search + build structured literature survey | `/research:context search <topic>` | `$research-context search <topic>` |
| Write / edit / compile a venue-formatted LaTeX paper from RSD | `/research:paper` | `$research-paper` |

### Effort levels for `/research:plan`

`/research:plan` supports two optional flags that control how widely the AI explores before proposing an experiment:

- **`--effort low|middle|high`** — ideation breadth. Default is `low` (current behavior).
- **`--search N`** — literature discover-pool size. Integer in `[10, 500]`, clamped. Default depends on `--effort`.

| Level | Ideation | Default `--search` | Behavior |
|-------|----------|--------------------|----------|
| `low` (default) | 1 proposal | — (no search) | One proposal tied to your stated goal. Backward-compatible. |
| `middle` | 2-3 candidates, silent pick | 10 (honors `--search` if passed) | Generates adjacent candidates, silently picks the best, logs the rejected ones under `Alternatives considered:`. |
| `high` | 5-8 wild candidates, you pick | **200** (user override wins) | Cost gate first, then generates wild candidates spanning multiple sub-topics — including at least one cross-field / unconventional candidate (e.g. Genetic Algorithms for prompt optimization) when plausible. Presents all candidates for you to pick. Every candidate cites a knowledge source. |

Use `low` for incremental work where you already know what you want. Use `high` early in a project when you have a broad topic and want surprising directions.

**About `--search N`:** when triggered, `/research:plan` calls `/research:context search <topic> --search N` under the hood. The search runs a **two-tier protocol**: it discovers up to `N` papers via title+abstract, then deep-reads the top `min(30, N // 5)` in full. At `N=200` you get 200 screened + 30 deep-read. Deep-read papers populate the Methods Landscape and Per-Paper Notes in `context/SURVEY.md`; screened papers go into a `## Screened (abstract-only)` table so they're still visible but don't burn the token budget. Max allowed is `--search 500`.

Examples:
```text
/research:plan --effort high                    # HIGH with default 200-paper wide search
/research:plan --effort high --search 300       # HIGH, scaled up to 300 screened
/research:plan --effort high --search 50        # HIGH, scaled down (cheaper)
/research:plan --effort middle --search 50      # MIDDLE with an unusually wide search
```

Codex alias note:
- If installed with the current bootstrap, Codex also exposes `$research:adopt`, `$research:plan`, `$research:execute`, `$research:context`, and `$research:paper` as alias skill names.
- `/research:*` stays Claude-specific. Codex does not get native slash commands from repo files.
- After install, restart the Codex session so it reloads local `AGENTS.md` and `.agents/skills/`.
- Human checkpoints accept normal-language approval or revision in chat or RSD. Exact marker formatting is optional.

## What You Review

| Layer | What | Time |
|-------|------|------|
| `RSD.pdf` | Decisions: hypotheses, predictions, prediction deltas | 3 min |
| Code Architecture section | Structure: module list, data flow | 1 min |
| Codex review summary | Code quality: issues, risks | 1 min |
| `git log --oneline` | Experiment timeline | 30 sec |

## Permissions for Execution Loop

During fast-loop execution, the AI runs verify/guard shell commands repeatedly. The installer does **not** change Claude or Codex permission defaults. Permission behavior comes from how you launched the session.

### Claude Code

`/research` does not elevate permissions by itself. Start Claude with the permissions you want for the session, or approve commands manually as they are requested.

### Codex CLI

Before using `$research`, give Codex full execution permissions for the session. The simplest path is:
```bash
codex --full-auto
```

Then invoke:
```text
$research
```

If you do not start with `--full-auto`, grant the equivalent full permissions before running the research skill. The skill cannot elevate the live session by itself.

### What still requires human approval

Research decision checkpoints **always** stop for you — regardless of shell permissions:
- End of PLAN → you approve/revise the experiment design
- End of INTERPRET → you approve/revise the next cycle

These are protocol-level gates in `RSD.md`, not shell permission prompts.

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
6. **No self-approval** — only explicit human approval or revision in chat or RSD.md counts

## Project Structure

```
your-project/
├── RSD.md / RSD.pdf        # Research state (AI writes MD, you read PDF)
├── CLAUDE.md               # Project rules (Claude Code)
├── AGENTS.md               # Project rules (Codex CLI)
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

Huge thanks to [Udit Goenka](https://github.com/uditgoenka) for [**autoresearch**](https://github.com/uditgoenka/autoresearch), the upstream project this fork is built on. Udit pioneered the autonomous research loop with git-as-memory, and was gracious enough to [feature AnchoredAutoResearch in the autoresearch README](https://github.com/uditgoenka/autoresearch?tab=readme-ov-file#claude-autoresearch) — the acknowledgment goes both ways.

AnchoredAutoResearch transfers autoresearch's best patterns (autonomous loop engine, git-based experiment memory, multi-persona analysis, modular skill architecture) and adds human checkpoints, prediction discipline, knowledge sources, dual-format RSD, Codex code review, mid-stage `/research:adopt`, and venue-formatted `/research:paper` generation.

The original autoresearch concept traces back to [Andrej Karpathy's tweet](https://x.com/karpathy/status/1908628566789910801) on autonomous AI research.

## License

MIT
