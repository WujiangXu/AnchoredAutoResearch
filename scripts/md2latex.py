#!/usr/bin/env python3
"""
Deterministic Markdown → LaTeX converter for RSD.md

This is the ONLY way RSD.tex is generated. The AI NEVER writes LaTeX directly.
The converter understands the RSD schema and renders:
- Status badges with colors
- Human decision blockquotes as styled boxes
- Hypothesis tables with booktabs
- File paths and commit hashes in monospace
- Cycle sections with clear visual breaks
"""

import re
import sys
from pathlib import Path


def escape_latex(text: str) -> str:
    """Escape special LaTeX characters, preserving intentional commands."""
    # Don't escape if it looks like it already contains LaTeX commands
    if '\\' in text and any(cmd in text for cmd in ['\\texttt', '\\filepath', '\\commithash', '\\statusbadge']):
        return text
    chars = {
        '&': r'\&',
        '%': r'\%',
        '$': r'\$',
        '#': r'\#',
        '_': r'\_',
        '{': r'\{',
        '}': r'\}',
        '~': r'\textasciitilde{}',
        '^': r'\textasciicircum{}',
    }
    for char, replacement in chars.items():
        text = text.replace(char, replacement)
    return text


def convert_inline(text: str) -> str:
    """Convert inline markdown formatting to LaTeX."""
    # Bold: **text** → \textbf{text}
    text = re.sub(r'\*\*(.+?)\*\*', r'\\textbf{\1}', text)
    # Italic: *text* → \textit{text}
    text = re.sub(r'\*(.+?)\*', r'\\textit{\1}', text)
    # Inline code: `text` → \texttt{text}
    text = re.sub(r'`([^`]+)`', lambda m: r'\texttt{' + m.group(1).replace('_', r'\_') + '}', text)
    # Links: [text](url) → \href{url}{text}
    text = re.sub(r'\[([^\]]+)\]\(([^)]+)\)', r'\\href{\2}{\1}', text)
    return text


def render_status_badge(status: str) -> str:
    """Render a status string as a colored badge."""
    status_clean = status.strip().replace('_', r'\_')
    # Use the raw status (with underscores for LaTeX matching)
    return f'\\statusbadge{{{status.strip()}}}'


def convert_table(lines: list[str]) -> str:
    """Convert a markdown pipe table to LaTeX longtable."""
    if len(lines) < 2:
        return '\n'.join(escape_latex(l) for l in lines)

    # Parse header
    headers = [cell.strip() for cell in lines[0].strip('|').split('|')]
    num_cols = len(headers)

    # Skip separator line (line 1)
    # Parse data rows
    rows = []
    for line in lines[2:]:
        cells = [cell.strip() for cell in line.strip('|').split('|')]
        rows.append(cells)

    # Build LaTeX table
    col_spec = 'l' * num_cols
    result = []
    result.append(f'\\begin{{longtable}}{{{col_spec}}}')
    result.append('\\toprule')
    result.append(' & '.join(f'\\textbf{{{escape_latex(h)}}}' for h in headers) + ' \\\\')
    result.append('\\midrule')
    result.append('\\endhead')
    for row in rows:
        escaped = [escape_latex(convert_inline(c)) for c in row]
        # Pad if needed
        while len(escaped) < num_cols:
            escaped.append('')
        result.append(' & '.join(escaped[:num_cols]) + ' \\\\')
    result.append('\\bottomrule')
    result.append('\\end{longtable}')
    return '\n'.join(result)


def convert_blockquote(lines: list[str]) -> str:
    """Convert blockquote lines (human decision markers) to styled box."""
    content = '\n'.join(line.lstrip('> ').strip() for line in lines)
    content = convert_inline(escape_latex(content))
    return f'\\begin{{humandecision}}\n{content}\n\\end{{humandecision}}'


def convert_rsd(md_text: str) -> str:
    """Convert RSD markdown to LaTeX body content."""
    lines = md_text.split('\n')
    output = []
    i = 0

    while i < len(lines):
        line = lines[i]
        stripped = line.strip()

        # --- Status/Phase/Cycle metadata lines ---
        if stripped.startswith('## Status:'):
            status = stripped.split(':', 1)[1].strip()
            output.append(f'\\section*{{Status: {render_status_badge(status)}}}')
            i += 1
            continue

        if stripped.startswith('## Phase:'):
            phase = stripped.split(':', 1)[1].strip()
            output.append(f'\\noindent Phase: {render_status_badge(phase)}')
            output.append('')
            i += 1
            continue

        if stripped.startswith('## Cycle:'):
            cycle_num = stripped.split(':', 1)[1].strip()
            output.append(f'\\noindent Cycle: \\textbf{{{escape_latex(cycle_num)}}}')
            output.append('')
            i += 1
            continue

        # --- H1: Document title ---
        if stripped.startswith('# ') and not stripped.startswith('## '):
            title = stripped[2:]
            output.append(f'\\begin{{center}}')
            output.append(f'{{\\LARGE \\textbf{{{escape_latex(title)}}}}}')
            output.append(f'\\end{{center}}')
            output.append(f'\\vspace{{0.5em}}')
            i += 1
            continue

        # --- H2: Major sections ---
        if stripped.startswith('## Cycle '):
            cycle_name = stripped[3:]
            output.append(f'\\newpage')
            output.append(f'\\section{{{escape_latex(cycle_name)}}}')
            i += 1
            continue

        if stripped.startswith('## '):
            section_name = stripped[3:]
            output.append(f'\\section*{{{escape_latex(section_name)}}}')
            i += 1
            continue

        # --- H3: Sub-sections (phases within cycles) ---
        if stripped.startswith('### '):
            subsection_name = stripped[4:]
            # Check if it's a phase name and add badge
            phase_names = ['PLAN', 'EXECUTE', 'INTERPRET']
            badge = ''
            for pn in phase_names:
                if subsection_name.strip().upper() == pn:
                    badge = f' {render_status_badge(pn)}'
                    break
            output.append(f'\\subsection*{{{escape_latex(subsection_name)}{badge}}}')
            i += 1
            continue

        # --- Horizontal rule ---
        if stripped in ('---', '***', '___'):
            output.append('\\bigskip\\hrule\\bigskip')
            i += 1
            continue

        # --- Tables ---
        if '|' in stripped and stripped.startswith('|'):
            table_lines = []
            while i < len(lines) and '|' in lines[i].strip():
                table_lines.append(lines[i].strip())
                i += 1
            output.append(convert_table(table_lines))
            continue

        # --- Blockquotes (human decision markers) ---
        if stripped.startswith('>'):
            quote_lines = []
            while i < len(lines) and lines[i].strip().startswith('>'):
                quote_lines.append(lines[i])
                i += 1
            output.append(convert_blockquote(quote_lines))
            continue

        # --- Unordered list items ---
        if stripped.startswith('- ') or stripped.startswith('* '):
            list_items = []
            while i < len(lines) and (lines[i].strip().startswith('- ') or lines[i].strip().startswith('* ')):
                item_text = lines[i].strip()[2:]
                list_items.append(f'  \\item {convert_inline(escape_latex(item_text))}')
                i += 1
            output.append('\\begin{itemize}[nosep]')
            output.extend(list_items)
            output.append('\\end{itemize}')
            continue

        # --- Bold field lines (e.g., **Proposed:** ...) ---
        if stripped.startswith('**') and ':**' in stripped:
            converted = convert_inline(escape_latex(stripped))
            output.append(f'\\noindent {converted}')
            output.append('')
            i += 1
            continue

        # --- Empty lines ---
        if not stripped:
            output.append('')
            i += 1
            continue

        # --- Italic placeholder ---
        if stripped.startswith('*') and stripped.endswith('*') and not stripped.startswith('**'):
            inner = stripped.strip('*')
            output.append(f'\\textit{{{escape_latex(inner)}}}')
            output.append('')
            i += 1
            continue

        # --- Regular paragraph text ---
        para_lines = []
        while i < len(lines) and lines[i].strip() and not any([
            lines[i].strip().startswith('#'),
            lines[i].strip().startswith('|'),
            lines[i].strip().startswith('>'),
            lines[i].strip().startswith('- '),
            lines[i].strip().startswith('* '),
            lines[i].strip() in ('---', '***', '___'),
            lines[i].strip().startswith('**') and ':**' in lines[i].strip(),
        ]):
            para_lines.append(lines[i].strip())
            i += 1
        if para_lines:
            para_text = ' '.join(para_lines)
            output.append(convert_inline(escape_latex(para_text)))
            output.append('')
            continue

        i += 1

    return '\n'.join(output)


def main():
    if len(sys.argv) < 2:
        print("Usage: md2latex.py <input.md> [output.tex]")
        print("  If output.tex not given, writes to stdout.")
        sys.exit(1)

    input_path = Path(sys.argv[1])
    if not input_path.exists():
        print(f"Error: {input_path} not found", file=sys.stderr)
        sys.exit(1)

    md_text = input_path.read_text(encoding='utf-8')
    latex_body = convert_rsd(md_text)

    # Read template
    template_path = input_path.parent / 'templates' / 'rsd.tex'
    if not template_path.exists():
        # Try relative to script location
        template_path = Path(__file__).parent.parent / 'templates' / 'rsd.tex'

    if template_path.exists():
        template = template_path.read_text(encoding='utf-8')
        full_latex = template.replace('\\INPUT_BODY', latex_body)
    else:
        print(f"Warning: template not found at {template_path}, using minimal template", file=sys.stderr)
        full_latex = (
            '\\documentclass[11pt,a4paper]{article}\n'
            '\\usepackage[margin=1in]{geometry}\n'
            '\\usepackage{parskip}\n'
            '\\usepackage{booktabs}\n'
            '\\usepackage{longtable}\n'
            '\\usepackage{hyperref}\n'
            '\\usepackage[T1]{fontenc}\n'
            '\\usepackage{lmodern}\n'
            '\\begin{document}\n'
            f'{latex_body}\n'
            '\\end{document}\n'
        )

    if len(sys.argv) >= 3:
        output_path = Path(sys.argv[2])
        output_path.write_text(full_latex, encoding='utf-8')
        print(f"Wrote {output_path}", file=sys.stderr)
    else:
        print(full_latex)


if __name__ == '__main__':
    main()
