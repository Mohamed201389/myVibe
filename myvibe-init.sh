#!/usr/bin/env bash
# Per-project initializer: drop agent rule files into the current repo.
# Run from inside the project root.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCE="${SOURCE:-$SCRIPT_DIR}"
TPL="$SOURCE/AGENTS.template.md"
[[ -f "$TPL" ]] || { echo "AGENTS.template.md not found in $SOURCE" >&2; exit 1; }

echo "Initializing myVibe rules in $(pwd)..."

create_or_skip() {
  local dst="$1" label="$2"
  mkdir -p "$(dirname "$dst")"
  if [[ -f "$dst" ]]; then
    echo "  exists, skipped: $dst ($label)"
  else
    cp "$TPL" "$dst"
    echo "  created: $dst ($label)"
  fi
}

create_or_skip "AGENTS.md"                       "Codex / OpenAI / generic"
create_or_skip "CLAUDE.md"                       "Claude Code"
create_or_skip ".cursorrules"                    "Cursor"
create_or_skip ".windsurfrules"                  "Windsurf"
create_or_skip ".github/copilot-instructions.md" "GitHub Copilot"

echo ""
echo "Done. Commit these files so the whole team's agents follow the same rules."
