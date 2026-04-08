# ICML venue template

## `.cls` / `.sty` fetch instructions

ICML uses a style package (`icml<year>.sty`) loaded via `\usepackage`, not a `\documentclass`.

1. Go to https://icml.cc/Conferences/ and find the LaTeX style page for the year you're submitting to.
2. Download the ICML style package (usually a zip with `icml<year>.sty` and a `.bst` file).
3. Extract and copy `icml2025.sty` (or your year's filename) into `outputs/paper/`.
4. Also copy any included `.bst` file (e.g., `icml2025.bst`) into `outputs/paper/`.

**Filenames `compile_paper.sh` expects:** `outputs/paper/icml2025.sty` and `outputs/paper/icml2025.bst`
(adjust `paper_skeleton.tex` `\usepackage{icml2025}` line if you use a different year).

## Anonymous vs. accepted

Edit the `\usepackage{icml2025}` line in `outputs/paper/paper.tex`:

```latex
% Anonymous submission (default — author names hidden):
\usepackage{icml2025}

% Camera-ready (author names shown):
\usepackage[accepted]{icml2025}
```

## Page limit

ICML main paper is typically 8 pages + unlimited references/appendix. Use
`/research:paper check-pages` after each write to track the count.

## License

Not redistributed here. Download directly from the ICML organizers.
