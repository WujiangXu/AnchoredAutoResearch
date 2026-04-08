# ACL venue template

## `.cls` / `.sty` fetch instructions

ACL uses a style package (`acl.sty`) loaded via `\usepackage`, not a `\documentclass`.

1. Go to https://github.com/acl-org/acl-style-files
2. Download (or `git clone`) the repo. You need `acl.sty` and `acl_natbib.bst`.
3. Copy `acl.sty` and `acl_natbib.bst` into `outputs/paper/`.

**Filenames `compile_paper.sh` expects:** `outputs/paper/acl.sty` and `outputs/paper/acl_natbib.bst`

## Anonymous vs. camera-ready

Edit the `\usepackage[]{acl}` line in `outputs/paper/paper.tex`:

```latex
% Anonymous submission (default):
\usepackage[]{acl}

% Camera-ready (author names shown, no line numbers):
\usepackage[final]{acl}
```

## Page limit

ACL main paper is typically:
- Long paper: 8 pages of content + unlimited references
- Short paper: 4 pages of content + unlimited references

Use `/research:paper check-pages` after each write to track the count.

## License

Not redistributed here. The acl-style-files repo is MIT-licensed but the
files still belong to ACL — fetch them directly so you have the canonical
version for your year's submission.
