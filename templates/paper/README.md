# Paper Templates

`/research:paper init <venue>` (Codex: `$research-paper init <venue>`) bootstraps `outputs/paper/` from a venue template directory under `templates/paper/<venue>/`.

## Built-in venues

- `neurips` — NeurIPS (uses `neurips_<year>.cls`)
- `icml` — ICML (uses `icml<year>.cls`)
- `acl` — ACL Anthology (uses `acl.sty` + `acl.cls`)

## Adding a custom venue

`/research:paper init` discovers venues by listing the immediate subdirectories of `templates/paper/`. To add a new venue:

1. Create `templates/paper/<your-venue>/`.
2. Add `paper_skeleton.tex` with the conference's `\documentclass{...}` line and the section structure you want pre-populated.
3. Add a `README.md` with two sections:
   - **`.cls` fetch instructions** — where to download the official class file from the conference site.
   - **Filename** — the exact filename `compile_paper.sh` should expect under `outputs/paper/`.
4. (Optional) Add `references_starter.bib` if your venue has venue-specific bib style requirements.

After that, `/research:paper init <your-venue>` will work the same as the built-in venues.

## Why we don't ship `.cls` files

Conference style files are licensed by the venue and are not redistributable here. Each `templates/paper/<venue>/README.md` tells you exactly which file to download and where to place it.

## Why this is separate from `templates/rsd.tex`

`templates/rsd.tex` is for the Research State Document — generated deterministically from `RSD.md` by `scripts/md2latex.py` + `scripts/compile_rsd.sh`. Paper templates are for the venue submission and are edited directly by `/research:paper`. The two pipelines never overlap.
