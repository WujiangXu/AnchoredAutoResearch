---
name: research:context
description: "Manage knowledge sources — read local files, search arxiv/web for related work, index and cite papers."
argument-hint: "[search <topic>] or no args to read local context/"
---

EXECUTE IMMEDIATELY — do not deliberate before reading the protocol.

## Argument Parsing

- No arguments → **read mode**: scan and index local `context/` files
- `search <topic>` → **search mode**: search arxiv/web for related papers on `<topic>`
- Any other text → treat as a topic for search mode

## Execution

1. Read the knowledge sources protocol: `.claude/skills/research/references/knowledge-sources.md`

### Read mode (no arguments)
2. Scan `context/` for all files (papers/, notes/, prior_work/)
3. Read `context/SOURCES.md` to find which sources are already indexed
4. Read any unread sources — extract key takeaways
5. Update `context/SOURCES.md` with new entries
6. If `RSD.md` exists, update the `## Knowledge Sources` table
7. Report to human: what was read, key findings, questions

### Search mode (`search <topic>`)
2. Extract key concepts from the topic
3. Use WebSearch to find relevant papers (arxiv, Google Scholar, Semantic Scholar)
4. Use WebFetch to read abstracts/summaries of top results
5. Add found sources to `context/SOURCES.md` with key takeaways
6. If `RSD.md` exists, update the `## Knowledge Sources` table
7. Report to human: what was found, key findings, suggested directions

Stream all output live. Never run in background.
