#!/bin/bash
# Compiles outputs/paper/paper.tex → outputs/paper/paper.pdf
#
# This is a fully separate pipeline from compile_rsd.sh:
# - It does NOT touch RSD.md, RSD.tex, RSD.pdf, or md2latex.py.
# - It only operates on files inside outputs/paper/.
# - It refuses to run on any path outside outputs/paper/.
#
# Usage: scripts/compile_paper.sh [path/to/paper.tex]
# Defaults to outputs/paper/paper.tex in project root.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

INPUT="${1:-${PROJECT_DIR}/outputs/paper/paper.tex}"

# Resolve to absolute path (no .. traversal)
if ! INPUT="$(cd "$(dirname "${INPUT}")" 2>/dev/null && pwd)/$(basename "${INPUT}")"; then
    echo "Error: cannot resolve ${INPUT}" >&2
    exit 1
fi

# Path-prefix guard: must live under outputs/paper/
EXPECTED_PREFIX="${PROJECT_DIR}/outputs/paper/"
case "${INPUT}" in
    "${EXPECTED_PREFIX}"*) ;;
    *)
        echo "Error: ${INPUT} is not under ${EXPECTED_PREFIX}" >&2
        echo "compile_paper.sh refuses to operate outside outputs/paper/." >&2
        exit 1
        ;;
esac

if [ ! -f "${INPUT}" ]; then
    echo "Error: ${INPUT} not found" >&2
    echo "Run /research:paper init <venue> first." >&2
    exit 1
fi

PAPER_DIR="$(dirname "${INPUT}")"
BASENAME="$(basename "${INPUT}" .tex)"
PDF_FILE="${PAPER_DIR}/${BASENAME}.pdf"

# Read venue name (for diagnostic output)
VENUE="unknown"
if [ -f "${PAPER_DIR}/.venue" ]; then
    VENUE="$(cat "${PAPER_DIR}/.venue" | tr -d '[:space:]')"
fi

echo "Compiling ${INPUT} (venue: ${VENUE}) → ${PDF_FILE}..."
cd "${PAPER_DIR}"

# First pass
pdflatex -interaction=nonstopmode "${BASENAME}.tex" > "${BASENAME}.compile.log" 2>&1 || true

# Bibliography pass (if .bib exists and \bibliography{...} is in the .tex)
if [ -f "references.bib" ] && grep -q '\\bibliography' "${BASENAME}.tex"; then
    bibtex "${BASENAME}" >> "${BASENAME}.compile.log" 2>&1 || true
    pdflatex -interaction=nonstopmode "${BASENAME}.tex" >> "${BASENAME}.compile.log" 2>&1 || true
fi

# Final pass for cross-references
pdflatex -interaction=nonstopmode "${BASENAME}.tex" >> "${BASENAME}.compile.log" 2>&1 || true

# Clean intermediate aux files but KEEP the .log for diagnostics
rm -f "${BASENAME}.aux" "${BASENAME}.out" "${BASENAME}.toc" \
      "${BASENAME}.bbl" "${BASENAME}.blg" "${BASENAME}.fls" \
      "${BASENAME}.fdb_latexmk" "${BASENAME}.synctex.gz"

if [ -f "${PDF_FILE}" ]; then
    echo "✓ ${PDF_FILE} generated successfully"
    # Report page count if pdfinfo is available
    if command -v pdfinfo > /dev/null 2>&1; then
        PAGES="$(pdfinfo "${PDF_FILE}" 2>/dev/null | awk '/^Pages:/ {print $2}')"
        if [ -n "${PAGES}" ]; then
            echo "  Pages: ${PAGES}"
        fi
    fi
    # Keep the compile log for the agent to read on next invocation
else
    echo "Error: PDF generation failed. Last 20 lines of ${BASENAME}.compile.log:" >&2
    tail -20 "${BASENAME}.compile.log" >&2
    exit 1
fi
