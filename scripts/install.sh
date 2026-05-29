#!/bin/bash
# Install skills to ~/.qoder/skills/
# Usage: bash scripts/install.sh [skill-name]
#   Without arguments, installs all skills.
#   With a skill name, installs only that skill.

set -e

REPO_DIR="$(cd "$(dirname "$0")/.." && pwd)"
SKILLS_SRC="$REPO_DIR/skills"
QODER_SKILLS_DIR="$HOME/.qoder/skills"

if [ ! -d "$QODER_SKILLS_DIR" ]; then
  echo "Creating Qoder skills directory: $QODER_SKILLS_DIR"
  mkdir -p "$QODER_SKILLS_DIR"
fi

install_skill() {
  local skill_name="$1"
  local src="$SKILLS_SRC/$skill_name"
  local dst="$QODER_SKILLS_DIR/$skill_name"

  if [ ! -d "$src" ]; then
    echo "  [SKIP] Skill '$skill_name' not found at $src"
    return 1
  fi

  if [ -d "$dst" ]; then
    echo "  [EXISTS] $skill_name — skipping (remove $dst first to reinstall)"
    return 0
  fi

  cp -r "$src" "$dst"
  echo "  [INSTALLED] $skill_name → $dst"
}

if [ $# -eq 0 ]; then
  echo "Installing all skills to $QODER_SKILLS_DIR..."
  for skill_dir in "$SKILLS_SRC"/*/; do
    if [ -d "$skill_dir" ]; then
      skill_name="$(basename "$skill_dir")"
      install_skill "$skill_name"
    fi
  done
else
  echo "Installing skill '$1' to $QODER_SKILLS_DIR..."
  install_skill "$1"
fi

echo ""
echo "Done! Restart Qoder to load the installed skills."
