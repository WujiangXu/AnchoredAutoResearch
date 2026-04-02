#!/bin/bash
# AnchoredAutoResearch — Install into a research project
#
# Usage:
#   Global:      ./install.sh --global
#   Per-project: ./install.sh /path/to/your-project
#
# After install, run /research in Claude Code to start.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

usage() {
    echo "Usage:"
    echo "  $0 --global              Install globally (~/.claude/) — available in all projects"
    echo "  $0 /path/to/project      Install into a specific project"
    echo ""
    echo "After install, run /research in Claude Code to start your first research cycle."
    exit 1
}

install_skills() {
    local target_claude="$1"
    local target_project="$2"

    # Create target directories
    mkdir -p "$target_claude/skills" "$target_claude/commands"

    # Symlink skills (protocol definitions)
    if [ -L "$target_claude/skills/research" ]; then
        rm "$target_claude/skills/research"
    fi
    ln -sf "$SCRIPT_DIR/.claude/skills/research" "$target_claude/skills/research"
    echo "  ✓ Skills linked: $target_claude/skills/research"

    # Symlink main command
    if [ -L "$target_claude/commands/research.md" ]; then
        rm "$target_claude/commands/research.md"
    fi
    ln -sf "$SCRIPT_DIR/.claude/commands/research.md" "$target_claude/commands/research.md"
    echo "  ✓ Command linked: /research"

    # Symlink subcommands
    if [ -L "$target_claude/commands/research" ]; then
        rm "$target_claude/commands/research"
    fi
    ln -sf "$SCRIPT_DIR/.claude/commands/research" "$target_claude/commands/research"
    echo "  ✓ Subcommands linked: /research:plan, /research:execute, /research:context"

    # Copy project-level files if installing per-project
    if [ -n "$target_project" ] && [ "$target_project" != "$HOME" ]; then
        # CLAUDE.md — only if not exists (don't overwrite user's)
        if [ ! -f "$target_project/CLAUDE.md" ]; then
            cp "$SCRIPT_DIR/CLAUDE.md" "$target_project/CLAUDE.md"
            echo "  ✓ Copied CLAUDE.md"
        else
            echo "  ⚠ CLAUDE.md exists — not overwriting. Merge manually if needed."
        fi

        # Scripts and templates
        mkdir -p "$target_project/scripts" "$target_project/templates"
        cp "$SCRIPT_DIR/scripts/compile_rsd.sh" "$target_project/scripts/"
        cp "$SCRIPT_DIR/scripts/md2latex.py" "$target_project/scripts/"
        chmod +x "$target_project/scripts/compile_rsd.sh" "$target_project/scripts/md2latex.py"
        cp "$SCRIPT_DIR/templates/rsd.tex" "$target_project/templates/"
        echo "  ✓ Copied scripts/ and templates/"

        # Context directory
        mkdir -p "$target_project/context/papers" "$target_project/context/notes" "$target_project/context/prior_work"
        if [ ! -f "$target_project/context/SOURCES.md" ]; then
            cp "$SCRIPT_DIR/context/SOURCES.md" "$target_project/context/"
        fi
        echo "  ✓ Created context/ directory"

        # Working directories
        mkdir -p "$target_project/checkpoints" "$target_project/logs" "$target_project/outputs"
        echo "  ✓ Created checkpoints/, logs/, outputs/"

        # .gitignore additions
        if [ -f "$target_project/.gitignore" ]; then
            if ! grep -q "\.aux$" "$target_project/.gitignore" 2>/dev/null; then
                cat >> "$target_project/.gitignore" << 'GITIGNORE'

# AnchoredAutoResearch — LaTeX auxiliary files
*.aux
*.log
*.out
*.toc
*.fls
*.fdb_latexmk
*.synctex.gz
GITIGNORE
                echo "  ✓ Added LaTeX ignores to .gitignore"
            fi
        fi
    fi
}

# --- Main ---

if [ $# -eq 0 ]; then
    usage
fi

if [ "$1" = "--global" ]; then
    echo "Installing AnchoredAutoResearch globally..."
    CLAUDE_DIR="$HOME/.claude"
    mkdir -p "$CLAUDE_DIR"
    install_skills "$CLAUDE_DIR" "$HOME"
    echo ""
    echo "Done! /research is now available in ALL Claude Code projects."
    echo "To set up a project: create context/ and scripts/ dirs, or run:"
    echo "  $0 /path/to/project"

elif [ "$1" = "--help" ] || [ "$1" = "-h" ]; then
    usage

else
    TARGET="$(cd "$1" && pwd)"
    echo "Installing AnchoredAutoResearch into: $TARGET"
    CLAUDE_DIR="$TARGET/.claude"
    mkdir -p "$CLAUDE_DIR"
    install_skills "$CLAUDE_DIR" "$TARGET"
    echo ""
    echo "Done! Run /research in Claude Code from $TARGET to start."
    echo ""
    echo "Quick start:"
    echo "  1. Drop papers into context/papers/"
    echo "  2. Run /research — it will ask for your research goal"
    echo "  3. Review RSD.pdf, approve in RSD.md, run /research again"
fi
