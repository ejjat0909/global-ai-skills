#!/bin/bash
# Sets up ~/.shared-ai-memory and ~/.shared-ai-skills as the single source of
# truth for every AI agent on this machine, symlinking each agent's own
# memory/skills path to the shared dir. Safe to re-run (idempotent) — restores
# any symlink an agent update clobbered.
#
# Also: before symlinking, extracts any *.md memory files already sitting in
# each agent's real (non-symlink) memory dir into the shared dir, so nothing
# gets lost — just backed up. And it appends a read-shared-memory-first
# instruction block to each agent's global instruction file, so once this
# plugin is installed the agent reads + updates the shared memory and infers
# user personality/preferences from it before responding, without being told.
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

# Merge any *.md memory files already in a real dir into the shared dir before
# it gets replaced by a symlink, so existing notes aren't stranded in a backup.
extract_memory() {
    local real_dir=$1
    local description=$2
    [ -d "$real_dir" ] && [ ! -L "$real_dir" ] || return
    local found=0
    while IFS= read -r -d '' f; do
        found=1
        local base
        base=$(basename "$f")
        local dest="$SHARED_MEMORY_DIR/$base"
        if [ -e "$dest" ] && ! diff -q "$f" "$dest" >/dev/null 2>&1; then
            dest="$SHARED_MEMORY_DIR/${base%.md}_from_${description// /_}.md"
        fi
        cp -n "$f" "$dest" 2>/dev/null
    done < <(find "$real_dir" -maxdepth 1 -name '*.md' -print0)
    [ "$found" = 1 ] && echo -e "${GREEN}extracted: $description memory -> $SHARED_MEMORY_DIR${NC}"
}

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

    if [ -d "$target_path" ] && [ ! -L "$target_path" ] && [ "$shared_source" = "$SHARED_MEMORY_DIR" ]; then
        extract_memory "$target_path" "$description"
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

echo "--- Memory symlinks (extracting existing memory first) ---"
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

# Seed a personality/preferences file the instruction block below tells every
# agent to read before responding. Never overwritten once created — it's the
# user's file to edit.
PERSONALITY_FILE="$SHARED_MEMORY_DIR/PERSONALITY.md"
if [ ! -f "$PERSONALITY_FILE" ]; then
    cat > "$PERSONALITY_FILE" <<'EOF'
# User personality & preferences

Fill this in (or let your agent append to it as it learns you): tone,
communication style, standing preferences, pet peeves. Every agent sharing
this memory dir reads this file first and adapts before responding.
EOF
    echo -e "${GREEN}created: $PERSONALITY_FILE (seed it or let the agent fill it in)${NC}"
fi

# Tell each agent, at its own global-instructions file, to read+update the
# shared memory dir and read PERSONALITY.md before responding. Idempotent:
# guarded by a marker comment, only appended once per file.
MARKER="<!-- shared-ai-memory:auto -->"
BLOCK=$(cat <<EOF

$MARKER
## Shared AI memory (auto-added by shared-ai-memory plugin)

Before responding, read $SHARED_MEMORY_DIR/PERSONALITY.md and every other
*.md file in $SHARED_MEMORY_DIR relevant to the request — this is memory
shared across all your AI agents on this machine, not just this one. After
learning a durable fact, preference, or correction, write/update the
matching file in $SHARED_MEMORY_DIR so every other agent sees it too.
EOF
)

inject_instructions() {
    local f=$1
    [ -f "$f" ] || return
    grep -qF "$MARKER" "$f" 2>/dev/null && return
    printf '%s\n' "$BLOCK" >> "$f"
    echo -e "${GREEN}instructed: $f to read/update shared memory${NC}"
}

echo ""
echo "--- Agent instruction files ---"
inject_instructions "$HOME/.claude/CLAUDE.md"
inject_instructions "$HOME/.codex/AGENTS.md"
inject_instructions "$HOME/.config/opencode/AGENTS.md"
inject_instructions "$HOME/.cursor/rules"

echo ""
echo "Done. Re-run this after major agent updates to restore broken symlinks."

