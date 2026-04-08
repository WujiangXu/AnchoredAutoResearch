---
name: research:plan
description: "Alias for the AnchoredAutoResearch Codex planning wizard. Equivalent intent to $research-plan. Supports --effort low|middle|high."
version: 1.0.0
---

# AnchoredAutoResearch — PLAN Alias

Use this skill when the user invokes `$research:plan` in Codex.

Optional flag: `--effort low|middle|high` controls ideation breadth.
Default is `low` (current behavior). See `### Effort levels` in
`../research/references/phase-protocol.md` for the per-level protocol.
Reject any other value with: "unknown effort level — use low, middle, or high".

Follow the same workflow as the `research-plan` skill:
1. Read `AGENTS.md`
2. Read `RSD.md`
3. Read `context/SOURCES.md` if it exists
4. Parse `--effort` flag if present and branch on it per the
   `### Effort levels` section in `../research/references/phase-protocol.md`
5. Follow the PLAN section in `../research/references/phase-protocol.md`
6. Follow `../research/references/knowledge-sources.md`
7. Write the PLAN entry (including `Effort level:` and
   `Alternatives considered:` fields), compile, commit, and stop for human
   approval
