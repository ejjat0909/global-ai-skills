#!/bin/bash
# Sets up ~/.shared-ai-memory and ~/.shared-ai-skills as the single source of
# truth for every AI agent on this machine, symlinking each agent's own
# memory/skills path to the shared dir. Safe to re-run (idempotent) — restores
# any symlink an agent update clobbered.
set -o pipefail

SHARED_MEMORY_DIR="$HOME/.shared-ai-memory"
SHARED_SKILLS_DIR="$HOME/.shared-ai-skills"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

GREEN='\033[0;32m'; YELLOW='\033[1;33m'; RED='\033[0;31m'; NC='\033[0m'

mkdir -p "$SHARED_MEMORY_DIR" "$SHARED_SKILLS_DIR"

echo "AI Agent Shared Memory & Skills Setup"
echo "========================================="
echo "Shared memory: $SHARED_MEMORY_DIR"
echo "Shared skills: $SHARED_SKILLS_DIR"
echo ""

setup_symlink() {
    local target_path=$1
    local shared_source=$2
    local description=$3

    local parent_dir
    parent_dir=$(dirname "$target_path")
    if [ ! -d "$parent_dir" ]; then
        echo -e "${YELLOW}skip: $description (parent dir missing)${NC}"
        return
    fi

    if [ -L "$target_path" ] && [ -e "$target_path" ]; then
        echo -e "${GREEN}ok: $description already linked${NC}"
        return
    fi

    if [ -L "$target_path" ] || [ -d "$target_path" ]; then
        if [ -d "$target_path" ] && [ ! -L "$target_path" ]; then
            local backup="${target_path}.backup_${TIMESTAMP}"
            echo -e "${YELLOW}  backing up real dir -> $backup${NC}"
            mv "$target_path" "$backup"
        else
            rm -f "$target_path"
        fi
    fi

    ln -s "$shared_source" "$target_path"
    echo -e "${GREEN}linked: $description -> $shared_source${NC}"
}

echo "--- Memory symlinks ---"
for project_dir in "$HOME/.claude/projects"/*; do
    [ -d "$project_dir" ] || continue
    setup_symlink "$project_dir/memory" "$SHARED_MEMORY_DIR" "Claude Code - $(basename "$project_dir")"
done
setup_symlink "$HOME/.hermes/memory"   "$SHARED_MEMORY_DIR" "Hermes Agent"
setup_symlink "$HOME/.codex/memory"    "$SHARED_MEMORY_DIR" "Codex CLI"
setup_symlink "$HOME/.opencode/memory" "$SHARED_MEMORY_DIR" "OpenCode"
setup_symlink "$HOME/.cursor/memory"   "$SHARED_MEMORY_DIR" "Cursor"
setup_symlink "$HOME/.zed/memory"      "$SHARED_MEMORY_DIR" "Zed"

echo ""
echo "--- Skills symlinks ---"
setup_symlink "$HOME/.hermes/skills"          "$SHARED_SKILLS_DIR" "Hermes Agent (global)"
setup_symlink "$HOME/.codex/skills"           "$SHARED_SKILLS_DIR" "Codex CLI"
setup_symlink "$HOME/.config/opencode/skills" "$SHARED_SKILLS_DIR" "OpenCode"
for profile_dir in "$HOME/.hermes/profiles"/*; do
    [ -d "$profile_dir" ] || continue
    setup_symlink "$profile_dir/skills" "$SHARED_SKILLS_DIR" "Hermes profile: $(basename "$profile_dir")"
done
for project_dir in "$HOME/.claude/projects"/*; do
    [ -d "$project_dir" ] || continue
    setup_symlink "$project_dir/skills" "$SHARED_SKILLS_DIR" "Claude Code - $(basename "$project_dir")"
done

echo ""
echo "Done. Re-run this after major agent updates to restore broken symlinks."
echo "Reminder: symlinks alone aren't enough — each agent's AGENTS.md/CLAUDE.md"
echo "must also tell it to read the shared memory dir at session start."
