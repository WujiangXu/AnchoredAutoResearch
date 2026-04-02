#!/bin/bash
# Converts RSD.md → RSD.tex → RSD.pdf
# This is the ONLY way RSD.tex/pdf are generated. AI NEVER writes LaTeX directly.
#
# Usage: scripts/compile_rsd.sh [path/to/RSD.md]
# Defaults to RSD.md in project root.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

INPUT="${1:-${PROJECT_DIR}/RSD.md}"
BASENAME="$(basename "${INPUT}" .md)"
OUTPUT_DIR="$(dirname "${INPUT}")"
TEX_FILE="${OUTPUT_DIR}/${BASENAME}.tex"
PDF_FILE="${OUTPUT_DIR}/${BASENAME}.pdf"

if [ ! -f "${INPUT}" ]; then
    echo "Error: ${INPUT} not found" >&2
    exit 1
fi

echo "Converting ${INPUT} → ${TEX_FILE}..."
python3 "${SCRIPT_DIR}/md2latex.py" "${INPUT}" "${TEX_FILE}"

echo "Compiling ${TEX_FILE} → ${PDF_FILE}..."
cd "${OUTPUT_DIR}"
pdflatex -interaction=nonstopmode "${TEX_FILE}" > /dev/null 2>&1 || true
# Second pass for cross-references
pdflatex -interaction=nonstopmode "${TEX_FILE}" > /dev/null 2>&1 || true

# Clean auxiliary files
rm -f "${BASENAME}.aux" "${BASENAME}.log" "${BASENAME}.out" "${BASENAME}.toc"

if [ -f "${PDF_FILE}" ]; then
    echo "✓ ${PDF_FILE} generated successfully"
else
    echo "Warning: PDF generation may have failed. Check ${BASENAME}.log for errors." >&2
    # Try again with visible output for debugging
    cd "${OUTPUT_DIR}"
    pdflatex -interaction=nonstopmode "${TEX_FILE}" 2>&1 | tail -20
    exit 1
fi
