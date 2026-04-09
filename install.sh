#!/usr/bin/env bash
set -euo pipefail

# personal-agent installer
# Symlinks skills, instructions, and tools into supported IDEs.
# Run again any time you add or change content — it's idempotent.
#
# Usage:
#   ./install.sh                                    # Install base framework
#   ./install.sh /path/to/personal-agent-skills    # Install + external skills repo

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILLS_SRC="$SCRIPT_DIR/skills"
INSTRUCTIONS_SRC="$SCRIPT_DIR/instructions"
TOOLS_SRC="$SCRIPT_DIR/tools"

# Optional: external skills repo (e.g., personal-agent-skills or org-specific repo)
EXTERNAL_SKILLS_REPO="${1:-}"

# ── Target directories ──────────────────────────────────────────────

# Skills
COPILOT_SKILLS="$HOME/.copilot/skills"
CLAUDE_SKILLS="$HOME/.claude/skills"
CURSOR_SKILLS="$HOME/.cursor/skills"

# Instructions
if [[ "$(uname)" == "Darwin" ]]; then
    VSCODE_PROMPTS="$HOME/Library/Application Support/Code/User/prompts"
else
    VSCODE_PROMPTS="$HOME/.config/Code/User/prompts"
fi

# Tools
TOOLS_BIN="$HOME/.local/bin"

# ── Colors and logging ──────────────────────────────────────────────

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
NC='\033[0m'

log_ok()   { echo -e "  ${GREEN}✓${NC} $1"; }
log_skip() { echo -e "  ${YELLOW}~${NC} $1 (already linked)"; }
log_warn() { echo -e "  ${RED}✗${NC} $1"; }
log_info() { echo -e "  ${CYAN}→${NC} $1"; }

# ── Symlink helpers ─────────────────────────────────────────────────

link_dir() {
    local src="$1"
    local dest_parent="$2"
    local name
    name="$(basename "$src")"

    if [[ -L "$dest_parent/$name" ]]; then
        local current
        current="$(readlink "$dest_parent/$name")"
        if [[ "$current" == "$src" ]]; then
            log_skip "$name"
            return
        fi
    elif [[ -e "$dest_parent/$name" ]]; then
        rm -rf "$dest_parent/$name"
    fi

    ln -sfn "$src" "$dest_parent/$name"
    log_ok "$name"
}

link_file() {
    local src="$1"
    local dest_parent="$2"
    local name
    name="$(basename "$src")"

    if [[ -L "$dest_parent/$name" ]]; then
        local current
        current="$(readlink "$dest_parent/$name")"
        if [[ "$current" == "$src" ]]; then
            log_skip "$name"
            return
        fi
    elif [[ -e "$dest_parent/$name" ]]; then
        rm -f "$dest_parent/$name"
    fi

    ln -sfn "$src" "$dest_parent/$name"
    log_ok "$name"
}

# ── Banner ──────────────────────────────────────────────────────────

echo ""
echo -e "${CYAN}personal-agent installer${NC}"
echo "========================"
echo ""
echo "Source: $SCRIPT_DIR"
if [[ -n "$EXTERNAL_SKILLS_REPO" ]]; then
    echo "External skills: $EXTERNAL_SKILLS_REPO"
fi

# ── Skills ──────────────────────────────────────────────────────────

collect_skill_dirs() {
    local root="$1"
    if [[ ! -d "$root" ]]; then
        return
    fi

    # Include top-level skills and one nested level (e.g., skills/linked/*).
    find -L "$root" -mindepth 1 -maxdepth 2 -type d | sort
}

skill_count=0
for target_dir in "$COPILOT_SKILLS" "$CLAUDE_SKILLS" "$CURSOR_SKILLS"; do
    echo ""
    echo -e "Skills → ${CYAN}$target_dir${NC}"
    mkdir -p "$target_dir"

    while IFS= read -r skill_dir; do
        if [[ -f "$skill_dir/SKILL.md" ]]; then
            link_dir "$skill_dir" "$target_dir"
            skill_count=$((skill_count + 1))
        fi
    done < <(collect_skill_dirs "$SKILLS_SRC")

    # External skills repo (optional)
    if [[ -n "$EXTERNAL_SKILLS_REPO" && -d "$EXTERNAL_SKILLS_REPO/skills" ]]; then
        while IFS= read -r skill_dir; do
            if [[ -f "$skill_dir/SKILL.md" ]]; then
                link_dir "$skill_dir" "$target_dir"
                skill_count=$((skill_count + 1))
            fi
        done < <(collect_skill_dirs "$EXTERNAL_SKILLS_REPO/skills")
    fi
done

# ── Instructions (VS Code / Copilot) ───────────────────────────────

echo ""
echo -e "Instructions → ${CYAN}$VSCODE_PROMPTS${NC}"
mkdir -p "$VSCODE_PROMPTS"

instruction_count=0
for instruction_file in "$INSTRUCTIONS_SRC"/*.instructions.md; do
    if [[ -f "$instruction_file" ]]; then
        link_file "$instruction_file" "$VSCODE_PROMPTS"
        instruction_count=$((instruction_count + 1))
    fi
done

if [[ $instruction_count -eq 0 ]]; then
    log_info "No instruction files found (add *.instructions.md to instructions/)"
fi

# ── Instructions (Claude Code: ~/.claude/CLAUDE.md) ────────────────

CLAUDE_MD="$HOME/.claude/CLAUDE.md"
BLOCK_START="<!-- personal-agent instructions start -->"
BLOCK_END="<!-- personal-agent instructions end -->"

echo ""
echo -e "Instructions → ${CYAN}$CLAUDE_MD${NC}"
mkdir -p "$(dirname "$CLAUDE_MD")"

COMBINED=""
for instruction_file in "$INSTRUCTIONS_SRC"/*.instructions.md; do
    if [[ -f "$instruction_file" ]]; then
        # Strip YAML frontmatter (lines between first and second ---)
        body=$(awk '/^---$/{found++; next} found>=2{print}' "$instruction_file")
        if [[ -n "$body" ]]; then
            COMBINED="${COMBINED}${body}"$'\n'
        fi
    fi
done

if [[ -z "$COMBINED" ]]; then
    log_info "No instruction content for CLAUDE.md"
else
    if [[ -f "$CLAUDE_MD" ]]; then
        existing=$(awk "/${BLOCK_START}/{found=1} !found{print} /${BLOCK_END}/{found=0}" "$CLAUDE_MD")
        {
            printf '%s\n' "$existing"
            printf '\n%s\n' "$BLOCK_START"
            printf '%s' "$COMBINED"
            printf '%s\n' "$BLOCK_END"
        } > "${CLAUDE_MD}.tmp" && mv "${CLAUDE_MD}.tmp" "$CLAUDE_MD"
    else
        {
            printf '%s\n' "$BLOCK_START"
            printf '%s' "$COMBINED"
            printf '%s\n' "$BLOCK_END"
        } > "$CLAUDE_MD"
    fi
    log_ok "CLAUDE.md"
fi

# ── Tools ───────────────────────────────────────────────────────────

echo ""
echo -e "Tools → ${CYAN}$TOOLS_BIN${NC}"
mkdir -p "$TOOLS_BIN"

tool_count=0
for tool_file in "$TOOLS_SRC"/*; do
    if [[ -f "$tool_file" && -x "$tool_file" ]]; then
        tool_name="$(basename "$tool_file")"
        link_file "$tool_file" "$TOOLS_BIN"
        tool_count=$((tool_count + 1))
    fi
done

if [[ $tool_count -eq 0 ]]; then
    log_info "No executable tools found (add scripts to tools/ and chmod +x)"
fi

# ── Summary ─────────────────────────────────────────────────────────

echo ""
echo "Done. Run ./install.sh again after adding new skills or tools."
echo ""
