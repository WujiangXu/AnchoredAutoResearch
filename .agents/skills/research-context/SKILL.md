---
name: research-context
description: "AnchoredAutoResearch knowledge-source entrypoint for Codex. Reads local context files or searches for prior work, then updates source indexes and citations."
version: 1.0.0
---

# AnchoredAutoResearch — CONTEXT Entrypoint

Use this skill when the user invokes `$research-context` in Codex.

## MANDATORY: Read Protocol Before Any Action

1. Read `AGENTS.md` for project rules
2. Read `../research/references/knowledge-sources.md`
3. Read `context/SOURCES.md` if it exists
4. If `RSD.md` exists, keep its Knowledge Sources section in sync with any new findings

## Execution

### Read mode

If the user provides no extra argument:
1. Scan `context/` for unread files
2. Read them and extract key takeaways
3. Update `context/SOURCES.md`
4. If `RSD.md` exists, update its Knowledge Sources section
5. Report what was read and what matters

### Search mode

If the user provides a topic or `search <topic>`:
1. Extract key concepts from the topic
2. Search the web for relevant prior work
3. Read the most relevant summaries or abstracts
4. Update `context/SOURCES.md`
5. If `RSD.md` exists, update its Knowledge Sources section
6. Report what was found and what it implies
