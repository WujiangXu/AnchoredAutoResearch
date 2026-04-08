---
name: research-plan
description: "AnchoredAutoResearch planning wizard for Codex. Builds the PLAN section with scope, metrics, verify/guard commands, predictions, and human approval gates. Supports --effort low|middle|high and --search N for literature-pool size."
version: 1.0.0
---

# AnchoredAutoResearch — PLAN Entrypoint

Use this skill when the user invokes `$research-plan` in Codex.

Optional flags:
- `--effort low|middle|high` controls ideation breadth. Default is `low`
  (current behavior). See `### Effort levels` in
  `../research/references/phase-protocol.md` for the per-level protocol.
  Reject any other value with: "unknown effort level — use low, middle,
  or high".
- `--search N` sets the literature discover-pool size when this
  invocation triggers `/research:context search <topic>`. Integer in
  `[10, 500]`; clamped. Default by effort: `low` ignores it, `middle`
  honors if passed, `high` defaults to `N=200`. Deep-read count is
  `min(30, N // 5)`. See `knowledge-sources.md` "Search mode" for the
  two-tier protocol. Reject non-integer values with: "`--search` must
  be a positive integer in 10..500".

## MANDATORY: Read Protocol Before Any Action

1. Read `AGENTS.md` for project rules
2. Read `RSD.md` to determine current state (create if missing only via INIT in `../research/references/phase-protocol.md`)
3. Read `context/SOURCES.md` if it exists
4. Follow the PLAN section in `../research/references/phase-protocol.md`
5. Follow `../research/references/knowledge-sources.md` for source-reading requirements

## Execution

1. Treat any remaining user text as inline goal or planning context.
   Parse `--effort low|middle|high` (default `low`) and `--search N`
   (integer in `[10, 500]`, clamped). Resolve the effective `--search`
   value per effort level: LOW ignores, MIDDLE honors if passed, HIGH
   defaults to `N=200`.
2. Verify the project is in PLAN or can safely enter PLAN from INIT
3. Read unread sources in `context/`
4. Branch on effort level per `### Effort levels` in
   `../research/references/phase-protocol.md`:
   - `low` → one proposal tied to the user's goal (current behavior)
   - `middle` → 2-3 candidates, silent auto-pick, log alternatives
   - `high` → cost gate first; 5-8 candidates spanning sub-topics with at
     least one cross-field candidate; present via interactive selection
5. Build the PLAN entry with:
   - goal and hypothesis linkage
   - grounded-in source citation (every candidate at every effort level)
   - prediction before execution
   - verify and guard commands
   - execution mode
   - `Effort level:` and `Alternatives considered:` fields (use
     `N/A (low effort)` for the default level)
6. Set `Status: WAITING_HUMAN`
7. Run `bash scripts/compile_rsd.sh`
8. Commit the phase boundary
9. Stop and tell the human to approve or revise in chat or `RSD.md` using any clear wording
