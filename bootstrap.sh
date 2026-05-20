#!/usr/bin/env bash
# Remote bootstrap for the myVibe.
# Clones the public repo to a temp folder, runs install.sh, cleans up.
#
# One-liner:
#   curl -fsSL https://raw.githubusercontent.com/<owner>/myvibe/main/bootstrap.sh | bash
#
# Optional env vars:
#   MV_REPO    = override repo URL  (default: https://github.com/<owner>/myvibe.git)
#   MV_REF     = branch / tag / sha (default: main)
#   MV_SYMLINK = "true" to install in symlink mode (clones to ~/.local/share)
#
set -euo pipefail

REPO="${MV_REPO:-https://github.com/Mohamed201389/myvibe.git}"
REF="${MV_REF:-main}"
SYMLINK="${MV_SYMLINK:-false}"

command -v git >/dev/null 2>&1 || { echo "git is required" >&2; exit 1; }

if [[ "$SYMLINK" == "true" ]]; then
  # Persistent clone so symlinks stay valid
  TARGET="${XDG_DATA_HOME:-$HOME/.local/share}/myvibe"
  mkdir -p "$(dirname "$TARGET")"
  if [[ -d "$TARGET/.git" ]]; then
    git -C "$TARGET" fetch --quiet --depth 1 origin "$REF"
    git -C "$TARGET" checkout --quiet "$REF"
    git -C "$TARGET" reset --hard --quiet "origin/$REF" || true
  else
    rm -rf "$TARGET"
    git clone --quiet --depth 1 --branch "$REF" "$REPO" "$TARGET"
  fi
  bash "$TARGET/install.sh" --symlink --source="$TARGET"
else
  TMP="$(mktemp -d)"
  trap 'rm -rf "$TMP"' EXIT
  git clone --quiet --depth 1 --branch "$REF" "$REPO" "$TMP/kit"
  bash "$TMP/kit/install.sh" --source="$TMP/kit"
fi
