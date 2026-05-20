#!/usr/bin/env bash
# Install myVibe everywhere — VS Code Copilot, Claude Code, Codex CLI, Cursor.
#
# Usage:
#   ./install.sh                              # all targets
#   ./install.sh --symlink                    # symlinks (edits sync live)
#   ./install.sh --targets=claude,codex       # only specific agents
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCE="${SOURCE:-$SCRIPT_DIR}"
SYMLINK=false
TARGETS="all"

for arg in "$@"; do
  case "$arg" in
    --symlink)    SYMLINK=true ;;
    --source=*)   SOURCE="${arg#*=}" ;;
    --targets=*)  TARGETS="${arg#*=}" ;;
    -h|--help)
      echo "Usage: $0 [--symlink] [--source=<path>] [--targets=all|copilot,claude,codex,cursor,generic]"
      exit 0 ;;
  esac
done

[[ -f "$SOURCE/SKILL.md" ]] || { echo "SKILL.md not found in $SOURCE" >&2; exit 1; }

case "$(uname -s)" in
  Darwin)  VSCODE_USER="$HOME/Library/Application Support/Code/User" ;;
  Linux)   VSCODE_USER="$HOME/.config/Code/User" ;;
  *)       echo "Unsupported OS: $(uname -s). Use install.ps1 on Windows." >&2; exit 1 ;;
esac

KIT_NAME="myvibe"
PROMPT_NAME="myvibe.prompt.md"

want() { [[ "$TARGETS" == "all" ]] && return 0; echo "$TARGETS" | grep -qE "(^|,)$1(,|$)"; }

install_path() {
  local from="$1" to="$2"
  mkdir -p "$(dirname "$to")"
  rm -rf "$to"
  if [[ "$SYMLINK" == "true" ]]; then
    ln -s "$from" "$to" && echo "  linked: $to"
  else
    cp -R "$from" "$to" && echo "  copied: $to"
  fi
}

echo ""
echo "Installing myVibe..."
echo "  Source: $SOURCE"
echo ""

if want generic; then
  echo "[generic] ~/.agents/skills/"
  install_path "$SOURCE" "$HOME/.agents/skills/$KIT_NAME"
fi

if want copilot; then
  echo "[copilot] VS Code prompts (/myvibe, /myedit)"
  install_path "$SOURCE/$PROMPT_NAME" "$VSCODE_USER/prompts/$PROMPT_NAME"
  if [[ -f "$SOURCE/myedit/myedit.prompt.md" ]]; then
    install_path "$SOURCE/myedit/myedit.prompt.md" "$VSCODE_USER/prompts/myedit.prompt.md"
  fi
fi

if want claude; then
  echo "[claude] Claude Code skill"
  install_path "$SOURCE" "$HOME/.claude/skills/$KIT_NAME"
  CLAUDE_MD="$HOME/.claude/CLAUDE.md"
  mkdir -p "$(dirname "$CLAUDE_MD")"
  touch "$CLAUDE_MD"
  if ! grep -q "myVibe" "$CLAUDE_MD" 2>/dev/null; then
    {
      echo ""
      echo "## myVibe"
      echo ""
      echo "When the user gives a one-line project command, follow the myVibe skill at ~/.claude/skills/myvibe/SKILL.md."
    } >> "$CLAUDE_MD"
    echo "  added: myVibe section to ~/.claude/CLAUDE.md"
  fi
fi

if want codex; then
  echo "[codex] Codex CLI skill"
  install_path "$SOURCE" "$HOME/.codex/skills/$KIT_NAME"
fi

if want cursor; then
  echo "[cursor] Cursor rules template"
  install_path "$SOURCE/AGENTS.template.md" "$HOME/.cursor/rules/myvibe.mdc"
fi

echo ""
echo "Done."
echo ""
echo "Quick start:"
echo "  VS Code Copilot : reload window, then type '/myvibe' (new projects) or '/myedit' (existing projects)"
echo "  Claude Code     : 'use the myvibe skill to build a kanban app'"
echo "  Codex CLI       : 'use the myvibe skill: build me a kanban app'"
echo "  Any agent       : 'build me a kanban app' (auto-matches via skill description)"
echo ""
echo "Per-project setup (drops AGENTS.md + CLAUDE.md + .cursorrules):"
echo "  bash ~/.agents/skills/myvibe/myvibe-init.sh"
