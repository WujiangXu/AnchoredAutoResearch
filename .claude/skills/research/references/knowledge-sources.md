# Knowledge Sources Protocol

How the agent reads, indexes, and cites external knowledge before planning experiments.

## Directory Structure

```
context/
├── papers/          # PDF papers, arxiv downloads
├── notes/           # Human research notes, ideas, advisor feedback
├── prior_work/      # Related code, baselines, existing results
└── SOURCES.md       # Index: source | type | key takeaway | read?
```

## When to Read Sources

1. **INIT phase** — Read all existing sources when initializing a new RSD
2. **PLAN phase pre-flight** — Check for unread sources before every plan proposal
3. **`/research:context` invocation** — Read and index sources on demand
4. **Between cycles** — Human drops new files; agent detects them next PLAN

## How to Read Sources

### Step 1: Scan for new files

```bash
# Find files in context/ not yet in SOURCES.md
find context/papers/ context/notes/ context/prior_work/ -type f -not -name '.gitkeep' -not -name 'SOURCES.md'
```

Compare against the Source column in `context/SOURCES.md`. Any file not listed is unread.

### Step 2: Read each unread source

- **PDF files**: Read with the Read tool (supports PDF)
- **Markdown/text files**: Read directly
- **URLs in SOURCES.md**: Use WebFetch to retrieve content
- **JSON/CSV data files**: Read and extract key metrics

### Step 3: Update SOURCES.md

For each source, add a row:
```
| `context/papers/compass_alignment.pdf` | paper | COMPASS alignment strongest at L10-L14 (Table 2) | yes |
```

Key takeaway should be 1 sentence — the most relevant finding for our research goal.

### Step 4: Update RSD.md Knowledge Sources table

Copy the updated table from SOURCES.md to the `## Knowledge Sources` section in RSD.md.

## Citation Rules

Every experiment proposal in the PLAN phase MUST include:

```markdown
**Grounded in:** [source filename or URL] ([specific section/table/finding])
```

If no relevant prior work exists for a proposed experiment:
```markdown
**Grounded in:** No prior work found — [explain why this is novel]
```

## `/research:context` Command Protocol

When invoked standalone:
1. Scan `context/` for all files
2. Read any unread sources
3. Update `context/SOURCES.md` with key takeaways
4. If RSD.md exists, update its Knowledge Sources table
5. Report to human: what was read, key findings, any questions
