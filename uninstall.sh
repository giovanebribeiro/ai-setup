#!/usr/bin/env bash
# uninstall.sh — remove symlinks created by install.sh
#
# Usage: bash uninstall.sh [--claude] [--cursor] [--opencode]
#        [--claude-dir <path>] [--cursor-dir <path>] [--opencode-dir <path>]
#
# Only removes symlinks that point back into this repo.
# Runtime files in harness config dirs are never touched.

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_DIR="${HOME}/.claude"
CURSOR_DIR="${HOME}/.cursor"
OPENCODE_DIR="${HOME}/.opencode"

UNINSTALL_CLAUDE=false
UNINSTALL_CURSOR=false
UNINSTALL_OPENCODE=false

if [[ $# -eq 0 ]]; then
    echo "Usage: bash uninstall.sh [--claude] [--cursor] [--opencode]" >&2
    echo "       [--claude-dir <path>] [--cursor-dir <path>] [--opencode-dir <path>]" >&2
    echo "" >&2
    echo "At least one harness flag is required." >&2
    exit 1
fi

while [[ $# -gt 0 ]]; do
    case "$1" in
        --claude)       UNINSTALL_CLAUDE=true; shift ;;
        --cursor)       UNINSTALL_CURSOR=true; shift ;;
        --opencode)     UNINSTALL_OPENCODE=true; shift ;;
        --claude-dir)   CLAUDE_DIR="$2"; shift 2 ;;
        --cursor-dir)   CURSOR_DIR="$2"; shift 2 ;;
        --opencode-dir) OPENCODE_DIR="$2"; shift 2 ;;
        *) echo "Unknown option: $1" >&2; exit 1 ;;
    esac
done

if ! $UNINSTALL_CLAUDE && ! $UNINSTALL_CURSOR && ! $UNINSTALL_OPENCODE; then
    echo "Error: at least one of --claude, --cursor, --opencode is required." >&2
    exit 1
fi

remove_link() {
    local target="$1"
    local source="$2"
    local label="$3"

    if [[ -L "$target" && "$(readlink "$target")" == "$source" ]]; then
        rm "$target"
        echo "  removed  $label"
    else
        echo "  skip     $label  (not our symlink)"
    fi
}

# --- Claude ---
if $UNINSTALL_CLAUDE; then
    echo "==> Claude ($CLAUDE_DIR)"
    for item in CLAUDE.md AGENTS.md agents commands contexts rules scripts notes skills; do
        remove_link "$CLAUDE_DIR/$item" "$REPO_DIR/$item" "$item"
    done
    echo ""
fi

# --- Cursor ---
if $UNINSTALL_CURSOR; then
    echo "==> Cursor ($CURSOR_DIR)"
    remove_link "$CURSOR_DIR/rules" "$REPO_DIR/.cursor/rules" ".cursor/rules"
    echo ""
fi

# --- Opencode ---
if $UNINSTALL_OPENCODE; then
    echo "==> Opencode ($OPENCODE_DIR)"
    remove_link "$OPENCODE_DIR/AGENTS.md" "$REPO_DIR/AGENTS.md" "AGENTS.md"
    for entry in "$REPO_DIR/rules"/*; do
        [[ -e "$entry" ]] || continue
        entry_name="$(basename "$entry")"
        remove_link "$OPENCODE_DIR/rules/$entry_name" "$REPO_DIR/rules/$entry_name" "rules/$entry_name"
    done
    echo ""
fi

echo "Done. Runtime files in harness config dirs are untouched."
echo "To restore a backup: cp -r ~/.ai-setup-backup/<timestamp>/* <harness-config-dir>/"
