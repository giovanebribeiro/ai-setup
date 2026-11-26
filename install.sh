#!/usr/bin/env bash
# install.sh — symlink tracked ai-setup files into harness config directories
#
# Usage: bash install.sh --claude [--claude-dir <path>]
#        bash install.sh --cursor [--cursor-dir <path>]
#        bash install.sh --opencode [--opencode-dir <path>]
#        bash install.sh --claude --cursor --opencode  (multiple at once)
#
# At least one harness flag is required.
#
# Each tracked item is symlinked from the repo into the target dir.
# Anything already there that is NOT already our symlink gets backed up
# to ~/.ai-setup-backup/<timestamp>/ before being replaced.
#
# "Merge dirs" (e.g. skills/) are handled entry-by-entry so that
# pre-existing content in the target directory is preserved alongside repo content.

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_DIR="${HOME}/.claude"
CURSOR_DIR="${HOME}/.cursor"
OPENCODE_DIR="${HOME}/.opencode"

INSTALL_CLAUDE=false
INSTALL_CURSOR=false
INSTALL_OPENCODE=false

if [[ $# -eq 0 ]]; then
    echo "Usage: bash install.sh [--claude] [--cursor] [--opencode]" >&2
    echo "       [--claude-dir <path>] [--cursor-dir <path>] [--opencode-dir <path>]" >&2
    echo "" >&2
    echo "At least one harness flag is required." >&2
    exit 1
fi

while [[ $# -gt 0 ]]; do
    case "$1" in
        --claude)       INSTALL_CLAUDE=true; shift ;;
        --cursor)       INSTALL_CURSOR=true; shift ;;
        --opencode)     INSTALL_OPENCODE=true; shift ;;
        --claude-dir)   CLAUDE_DIR="$2"; shift 2 ;;
        --cursor-dir)   CURSOR_DIR="$2"; shift 2 ;;
        --opencode-dir) OPENCODE_DIR="$2"; shift 2 ;;
        *) echo "Unknown option: $1" >&2; exit 1 ;;
    esac
done

if ! $INSTALL_CLAUDE && ! $INSTALL_CURSOR && ! $INSTALL_OPENCODE; then
    echo "Error: at least one of --claude, --cursor, --opencode is required." >&2
    exit 1
fi

BACKUP_DIR="${HOME}/.ai-setup-backup/$(date +%Y%m%d-%H%M%S)"

link_item() {
    local source="$1"
    local target="$2"
    local label="$3"

    if [[ -L "$target" && "$(readlink "$target")" == "$source" ]]; then
        echo "  ok    $label"
        return
    fi

    if [[ -e "$target" || -L "$target" ]]; then
        mkdir -p "$BACKUP_DIR"
        mv "$target" "$BACKUP_DIR/$(basename "$target")"
        echo "  bkp   $label  → $BACKUP_DIR/$(basename "$target")"
    fi

    ln -s "$source" "$target"
    echo "  link  $label"
}

# Symlink each entry in source_dir individually (preserves pre-existing content in target_dir).
link_merge_dir() {
    local source_dir="$1"
    local target_dir="$2"
    local label_prefix="$3"

    if [[ ! -d "$source_dir" ]]; then
        echo "  skip  $label_prefix/  (not found in repo)"
        return
    fi

    if [[ -L "$target_dir" ]]; then
        mkdir -p "$BACKUP_DIR"
        mv "$target_dir" "$BACKUP_DIR/$(basename "$target_dir")"
        echo "  bkp   $label_prefix  → $BACKUP_DIR/$(basename "$target_dir")  (symlink -> merge-dir)"
        mkdir -p "$target_dir"
    elif [[ ! -d "$target_dir" ]]; then
        mkdir -p "$target_dir"
    fi

    for entry in "$source_dir"/*; do
        [[ -e "$entry" ]] || continue
        entry_name="$(basename "$entry")"
        link_item "$source_dir/$entry_name" "$target_dir/$entry_name" "$label_prefix/$entry_name"
    done
}

# --- Claude ---
if $INSTALL_CLAUDE; then
    echo "==> Claude ($CLAUDE_DIR)"
    mkdir -p "$CLAUDE_DIR"

    for item in CLAUDE.md AGENTS.md agents commands contexts rules scripts notes; do
        source="$REPO_DIR/$item"
        [[ -e "$source" ]] || { echo "  skip  $item  (not in repo)"; continue; }
        link_item "$source" "$CLAUDE_DIR/$item" "$item"
    done

    link_merge_dir "$REPO_DIR/skills" "$CLAUDE_DIR/skills" "skills"
    echo ""
fi

# --- Cursor ---
if $INSTALL_CURSOR; then
    echo "==> Cursor ($CURSOR_DIR)"
    mkdir -p "$CURSOR_DIR"
    link_item "$REPO_DIR/.cursor/rules" "$CURSOR_DIR/rules" ".cursor/rules"
    echo ""
fi

# --- Opencode ---
if $INSTALL_OPENCODE; then
    echo "==> Opencode ($OPENCODE_DIR)"
    mkdir -p "$OPENCODE_DIR"
    link_item "$REPO_DIR/AGENTS.md" "$OPENCODE_DIR/AGENTS.md" "AGENTS.md"
    link_merge_dir "$REPO_DIR/rules" "$OPENCODE_DIR/rules" "rules"
    echo ""
fi

echo "Done."
[[ -d "$BACKUP_DIR" ]] && echo "Backups: $BACKUP_DIR"
echo ""
echo "Git workflow: cd $REPO_DIR  (never from the harness config dir)"
