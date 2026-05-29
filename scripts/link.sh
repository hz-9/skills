#!/bin/bash
# Symlink skills to ~/.qoder/skills/ (for development)
# NOTE: Qoder 0.3.1 does NOT support symlinks for skills.
# This script is provided for future compatibility.
#
# Usage: bash scripts/link.sh [skill-name]
#   Without arguments, links all skills.
#   With a skill name, links only that skill.

set -e

REPO_DIR="$(cd "$(dirname "$0")/.." && pwd)"
SKILLS_SRC="$REPO_DIR/skills"
QODER_SKILLS_DIR="$HOME/.qoder/skills"

if [ ! -d "$QODER_SKILLS_DIR" ]; then
  echo "Creating Qoder skills directory: $QODER_SKILLS_DIR"
  mkdir -p "$QODER_SKILLS_DIR"
fi

link_skill() {
  local skill_name="$1"
  local src="$SKILLS_SRC/$skill_name"
  local dst="$QODER_SKILLS_DIR/$skill_name"

  if [ ! -d "$src" ]; then
    echo "  [SKIP] Skill '$skill_name' not found at $src"
    return 1
  fi

  if [ -L "$dst" ]; then
    echo "  [UPDATE] $skill_name — updating symlink"
    rm "$dst"
  elif [ -d "$dst" ]; then
    echo "  [SKIP] $skill_name — real directory exists at $dst (remove it first to use symlink)"
    return 0
  fi

  ln -s "$src" "$dst"
  echo "  [LINKED] $skill_name → $dst"
}

echo "WARNING: Qoder may not support symlinks for skills."
echo "         If skills don't appear in Qoder, use install.sh instead."
echo ""

if [ $# -eq 0 ]; then
  echo "Linking all skills to $QODER_SKILLS_DIR..."
  for skill_dir in "$SKILLS_SRC"/*/; do
    if [ -d "$skill_dir" ]; then
      skill_name="$(basename "$skill_dir")"
      link_skill "$skill_name"
    fi
  done
else
  echo "Linking skill '$1' to $QODER_SKILLS_DIR..."
  link_skill "$1"
fi

echo ""
echo "Done!"
