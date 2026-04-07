# AnchoredAutoResearch

## Protocol
This project uses the /research skill ecosystem for phase-gated research.
ALL experiment work MUST go through the /research protocol.
NEVER run experiments outside the protocol.

## Available Commands
| Command | Purpose |
|---------|---------|
| `/research` | Main state machine — reads RSD, dispatches to current phase |
| `/research:adopt` | Anchor the protocol to an in-progress project (existing LaTeX + git + logs) — imports as read-only Cycle 1 |
| `/research:plan` | Interactive experiment design wizard (Goal→Scope→Metric→Verify→Prediction) |
| `/research:execute` | Run experiments: fast-loop (bounded) or manual, with Codex review |
| `/research:context` | Read, index, and cite knowledge sources from context/ directory |
| `/research:paper` | Write / edit / compile a venue-formatted LaTeX paper from RSD (side-effect only — never touches RSD) |

Permission note:
- `/research` routes the workflow only. It does not change Claude's tool-permission state.
- Start Claude with the permissions you want for the session, or approve commands manually during execution.
- Human checkpoints accept clear normal-language approval or revision in chat or RSD. Exact template wording is optional.

## Rules
- RSD.md is the single source of truth — all claims must be written there
- RSD.md is the ONLY file the AI writes research state to. RSD.tex and RSD.pdf are auto-generated — NEVER write RSD LaTeX directly. The ONLY place AI may write LaTeX is `outputs/paper/**` (excluding any `.cls` file), and ONLY when invoked by `/research:paper`. See `core-principles.md` §8.
- Every phase ends with a git commit
- Never modify past RSD entries — append only within each cycle
- Predictions MUST be written before experiments run
- No metric selection after seeing results
- When status is WAITING_HUMAN, do not proceed until the human gives explicit approval or revision in chat or RSD.md
- Code Architecture section in RSD MUST be updated whenever code structure changes

## Pre-planning knowledge
- Before proposing ANY experiment, read all sources in context/
- Every experiment proposal must cite which knowledge source informed it
- If no relevant prior work exists, explicitly state "no prior work found" and explain novelty
- Human can add new sources between cycles by dropping files in context/

## Execution modes
- **manual** — AI implements each experiment directly, commits per experiment
- **fast-loop-N** — Autonomous loop (modify→commit→verify→guard→decide→log) for N bounded iterations. NEVER unbounded.
- Execution mode specified in PLAN section. Human approves before execution starts.

## Codex review
- After EXECUTE completes, Codex reviews the changed code automatically
- Review summary written to RSD under EXECUTE section
- Human reads Codex summary instead of reviewing code directly

## Directory conventions
- context/ — external knowledge (papers/, notes/, prior_work/, SOURCES.md)
- logs/ — raw experiment output + research-results.tsv, referenced by RSD
- checkpoints/ — frozen RSD snapshots per cycle (.md and .pdf)
- outputs/ — figures, tables, final artifacts
- templates/ — LaTeX template for RSD compilation
- scripts/ — compile_rsd.sh (MD→PDF), md2latex.py (converter)

## Skill architecture
- .claude/skills/research/SKILL.md — main routing + common rules
- .claude/skills/research/references/ — detailed protocol files
- .claude/commands/research/ — thin subcommand dispatchers
- Each protocol independently readable and maintainable

## Git conventions
- Per-experiment commits: "research: cycle N exp M — [description]"
- Phase commits: "research: cycle N [plan|execute complete|interpret]"
- Each experiment is independently revertable via `git revert`
- `git log --oneline` shows the full experiment timeline

## Dual-agent support
This project also supports Codex CLI — see AGENTS.md.

## Dual-format system
- AI writes RSD.md (markdown) — this is the source of truth
- scripts/compile_rsd.sh converts RSD.md → RSD.tex → RSD.pdf deterministically
- Human reads RSD.pdf for a well-formatted view
- Human can give approval or revision in chat or by editing RSD.md
