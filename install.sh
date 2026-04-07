#!/bin/bash
# AnchoredAutoResearch — Install into a research project
#
# Usage:
#   Global:      ./install.sh --global
#   Per-project: ./install.sh /path/to/your-project
#
# After install, run /research in Claude Code or $research in Codex CLI to start.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

usage() {
    echo "Usage:"
    echo "  $0 --global              Install globally (~/.claude/ + ~/.codex/ + ~/.agents/) — available in all projects"
    echo "  $0 /path/to/project      Install into a specific project (path may be new or existing)"
    echo ""
    echo "After install, run /research in Claude Code or \$research in Codex CLI."
    exit 1
}

install_claude_skills() {
    local target_claude="$1"

    # Create target directories
    mkdir -p "$target_claude/skills" "$target_claude/commands"

    # Symlink skills (protocol definitions)
    if [ -L "$target_claude/skills/research" ]; then
        rm "$target_claude/skills/research"
    fi
    ln -sf "$SCRIPT_DIR/.claude/skills/research" "$target_claude/skills/research"
    echo "  ✓ Claude skills linked: $target_claude/skills/research"

    # Symlink main command
    if [ -L "$target_claude/commands/research.md" ]; then
        rm "$target_claude/commands/research.md"
    fi
    ln -sf "$SCRIPT_DIR/.claude/commands/research.md" "$target_claude/commands/research.md"
    echo "  ✓ Claude command linked: /research"

    # Symlink subcommands
    if [ -L "$target_claude/commands/research" ]; then
        rm "$target_claude/commands/research"
    fi
    ln -sf "$SCRIPT_DIR/.claude/commands/research" "$target_claude/commands/research"
    echo "  ✓ Claude subcommands linked: /research:adopt, /research:plan, /research:execute, /research:context"
}

copy_codex_skill() {
    local target_codex="$1"
    local source_dir="$2"
    local target_dir="$3"
    local command_name="$4"
    local target_skill_dir="$target_codex/skills/$target_dir"
    local source_skill_dir="$SCRIPT_DIR/.agents/skills/$source_dir"

    rm -rf "$target_skill_dir"
    mkdir -p "$target_skill_dir"
    cp -R "$source_skill_dir"/. "$target_skill_dir"/
    echo "  ✓ Codex skill installed: \$$command_name"
}

install_codex_skills() {
    local target_codex="$1"

    mkdir -p "$target_codex/skills/research"

    copy_codex_skill "$target_codex" "research" "research" "research"
    copy_codex_skill "$target_codex" "research-adopt" "research-adopt" "research-adopt"
    copy_codex_skill "$target_codex" "research-plan" "research-plan" "research-plan"
    copy_codex_skill "$target_codex" "research-execute" "research-execute" "research-execute"
    copy_codex_skill "$target_codex" "research-context" "research-context" "research-context"
    copy_codex_skill "$target_codex" "research-colon-adopt" "research-colon-adopt" "research:adopt"
    copy_codex_skill "$target_codex" "research-colon-plan" "research-colon-plan" "research:plan"
    copy_codex_skill "$target_codex" "research-colon-execute" "research-colon-execute" "research:execute"
    copy_codex_skill "$target_codex" "research-colon-context" "research-colon-context" "research:context"

    rm -rf "$target_codex/skills/research/references"
    cp -R "$SCRIPT_DIR/.claude/skills/research/references" "$target_codex/skills/research/references"
    echo "  ✓ Codex skills installed under: $target_codex/skills"
    echo "  ✓ Codex references copied from .claude/skills/research/references/"
}

install_project_files() {
    local target_project="$1"

    # CLAUDE.md — only if not exists (don't overwrite user's)
    if [ ! -f "$target_project/CLAUDE.md" ]; then
        cp "$SCRIPT_DIR/CLAUDE.md" "$target_project/CLAUDE.md"
        echo "  ✓ Copied CLAUDE.md"
    else
        echo "  ⚠ CLAUDE.md exists — not overwriting. Merge manually if needed."
    fi

    # AGENTS.md — only if not exists (don't overwrite user's)
    if [ ! -f "$target_project/AGENTS.md" ]; then
        cp "$SCRIPT_DIR/AGENTS.md" "$target_project/AGENTS.md"
        echo "  ✓ Copied AGENTS.md"
    else
        echo "  ⚠ AGENTS.md exists — not overwriting. Merge manually if needed."
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
}

# --- Main ---

if [ $# -eq 0 ]; then
    usage
fi

if [ "$1" = "--global" ]; then
    echo "Installing AnchoredAutoResearch globally..."
    CLAUDE_DIR="$HOME/.claude"
    CODEX_DIR="${CODEX_HOME:-$HOME/.codex}"
    AGENTS_DIR="$HOME/.agents"
    mkdir -p "$CLAUDE_DIR" "$CODEX_DIR" "$AGENTS_DIR"
    install_claude_skills "$CLAUDE_DIR"
    install_codex_skills "$CODEX_DIR"
    install_codex_skills "$AGENTS_DIR"
    echo ""
    echo "Done! Available in ALL projects:"
    echo "  Claude Code: /research"
    echo "  Codex CLI:   \$research, \$research-adopt, \$research-plan, \$research-execute, \$research-context"
    echo "               aliases: \$research:adopt, \$research:plan, \$research:execute, \$research:context"
    echo ""
    echo "To set up a project: create context/ and scripts/ dirs, or run:"
    echo "  $0 /path/to/project"
    echo ""
    echo "No permission settings were changed."
    echo "Claude Code: launch the session with the permissions you want, or approve commands manually."
    echo "Codex CLI: launch with --full-auto or equivalent before invoking \$research."
    echo "Restart Codex after install so it reloads the newly linked skills."

elif [ "$1" = "--help" ] || [ "$1" = "-h" ]; then
    usage

else
    TARGET_INPUT="$1"
    mkdir -p "$TARGET_INPUT"
    TARGET="$(cd "$TARGET_INPUT" && pwd)"
    echo "Installing AnchoredAutoResearch into: $TARGET"
    CLAUDE_DIR="$TARGET/.claude"
    AGENTS_DIR="$TARGET/.agents"
    CODEX_DIR="$TARGET/.codex"
    mkdir -p "$CLAUDE_DIR" "$AGENTS_DIR" "$CODEX_DIR"
    install_claude_skills "$CLAUDE_DIR"
    install_codex_skills "$CODEX_DIR"
    install_codex_skills "$AGENTS_DIR"
    install_project_files "$TARGET"
    echo ""
    echo "Done! From $TARGET, run:"
    echo "  Claude Code: /research"
    echo "  Codex CLI:   \$research, \$research-adopt, \$research-plan, \$research-execute, \$research-context"
    echo "               aliases: \$research:adopt, \$research:plan, \$research:execute, \$research:context"
    echo ""
    echo "Quick start:"
    echo "  1. Drop papers into context/papers/"
    echo "  2. Restart Codex or Claude if the session was already open"
    echo "  3. Start Claude/Codex with the permissions you want"
    echo "  4. Run /research or \$research — it will ask for your research goal"
    echo "  5. Review RSD.pdf, approve in RSD.md, run again"
fi
