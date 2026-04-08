# NeurIPS venue template

## `.cls` fetch instructions

1. Go to https://neurips.cc/Conferences/ and find the style file page for the year you're submitting to.
2. Download the NeurIPS LaTeX style package (usually `neurips_<year>.zip`).
3. Extract and copy `neurips_<year>.cls` into `outputs/paper/`.

**Filename `compile_paper.sh` expects:** `outputs/paper/neurips_2025.cls`
(adjust `paper_skeleton.tex` `\documentclass{...}` line if you use a different year).

## Preprint vs. camera-ready

Edit the first lines of `outputs/paper/paper.tex` after `/research:paper init neurips`:

```latex
% For preprint (shows author names, no line numbers):
\usepackage[preprint]{neurips_2025}

% For camera-ready (author names shown, no "submitted to NeurIPS" banner):
\usepackage[final]{neurips_2025}

% For anonymous submission (default — author names hidden):
% (leave the \documentclass line alone)
```

## Page limit

NeurIPS main paper is typically 9 pages + unlimited references/appendix. Use
`/research:paper check-pages` after each write to track the count.

## License

Not redistributed here. Download directly from the NeurIPS organizers.
