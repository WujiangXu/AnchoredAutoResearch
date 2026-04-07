---
name: research:paper
description: "Alias for the AnchoredAutoResearch Codex paper skill. Equivalent intent to $research-paper."
version: 1.0.0
---

# AnchoredAutoResearch — PAPER Alias

Use this skill when the user invokes `$research:paper` in Codex.

Follow the same workflow as the `research-paper` skill:

1. Read `AGENTS.md`
2. Read `../research/references/paper-protocol.md`
3. Read `../research/references/core-principles.md` for the scoped
   LaTeX-write exception wording
4. Classify the intent from the user's invocation
5. Run intent-specific protocol: init / write-section / update-section /
   layout-edit / compile / check-pages / import-from-tex
6. Enforce the pre-flight path-prefix guard before ANY LaTeX write:
   - path starts with `outputs/paper/`
   - basename does NOT end with `.cls`
   - current command is `$research:paper` (or its alias)
7. NEVER write `RSD.md`. After this skill finishes, `git diff RSD.md` MUST
   be empty.
8. Do NOT `git commit` automatically.
9. Stop and report: intent, files written, that RSD was untouched, and the
   next suggested step.
