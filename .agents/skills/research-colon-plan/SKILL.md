---
name: research:plan
description: "Alias for the AnchoredAutoResearch Codex planning wizard. Equivalent intent to $research-plan. Supports --effort low|middle|high and --search N for literature-pool size."
version: 1.0.0
---

# AnchoredAutoResearch — PLAN Alias

Use this skill when the user invokes `$research:plan` in Codex.

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

Follow the same workflow as the `research-plan` skill:
1. Read `AGENTS.md`
2. Read `RSD.md`
3. Read `context/SOURCES.md` if it exists
4. Parse `--effort` and `--search` flags if present and branch on them
   per the `### Effort levels` section in
   `../research/references/phase-protocol.md` (LOW ignores `--search`,
   MIDDLE honors if passed, HIGH defaults to `--search 200`)
5. Follow the PLAN section in `../research/references/phase-protocol.md`
6. Follow `../research/references/knowledge-sources.md`
7. Write the PLAN entry (including `Effort level:` and
   `Alternatives considered:` fields), compile, commit, and stop for human
   approval
