#!/bin/bash
# Install skills from GitHub repo to ~/.qoder/skills/
# Usage: bash scripts/install-skills.sh
#
# Environment variables:
#   SKILLS_DIR  - Target directory (default: ~/.qoder/skills)

set -e

REPO="hz-9/skills"
BRANCH="master"
CLONE_DIR="/tmp/hz-9-skills"
SKILLS_DIR="${SKILLS_DIR:-$HOME/.qoder/skills}"

echo "=== Install skills from $REPO ==="
echo ""

# Step 1: Clone repo
echo "Cloning repository $REPO ($BRANCH)..."
if [ -d "$CLONE_DIR" ]; then
  rm -rf "$CLONE_DIR"
fi
git clone --depth 1 -b "$BRANCH" "https://github.com/$REPO.git" "$CLONE_DIR"
echo ""

# Step 2: Language selection
echo "Select language for skills source:"
echo "  1) English"
echo "  2) 中文"
read -p "Choice [1/2]: " lang_choice

case "$lang_choice" in
  2|zh*|中*)
    SKILLS_SRC="$CLONE_DIR/skills.zh-CN"
    lang_display="中文"
    ;;
  *)
    SKILLS_SRC="$CLONE_DIR/skills"
    lang_display="English"
    ;;
esac

echo "Selected: $lang_display"
echo ""

# Ensure target directory exists
if [ ! -d "$SKILLS_DIR" ]; then
  echo "Creating target directory: $SKILLS_DIR"
  mkdir -p "$SKILLS_DIR"
fi

# Scan source skills
echo "Scanning available skills..."
AVAILABLE_SKILLS=()
for skill_dir in "$SKILLS_SRC"/*/; do
  if [ -d "$skill_dir" ]; then
    AVAILABLE_SKILLS+=("$(basename "$skill_dir")")
  fi
done

echo "Found ${#AVAILABLE_SKILLS[@]} skills in repository"
echo ""

# Check for existing installed skills
CONFLICT_SKILLS=()
for skill in "${AVAILABLE_SKILLS[@]}"; do
  if [ -d "$SKILLS_DIR/$skill" ]; then
    CONFLICT_SKILLS+=("$skill")
  fi
done

if [ ${#CONFLICT_SKILLS[@]} -gt 0 ]; then
  echo "The following installed skills will be OVERWRITTEN:"
  for skill in "${CONFLICT_SKILLS[@]}"; do
    echo "  - $skill"
  done
  read -p "Overwrite all? [y/N] " confirm
  if [[ ! "$confirm" =~ ^[yY]$ ]]; then
    echo "Skip overwriting existing skills."
  else
    echo "Overwriting existing skills..."
    for skill in "${CONFLICT_SKILLS[@]}"; do
      rm -rf "$SKILLS_DIR/$skill"
    done
  fi
fi

# Install/copy all skills
echo ""
echo "Installing skills..."
INSTALLED=0
SKIPPED=0
for skill in "${AVAILABLE_SKILLS[@]}"; do
  if [ -d "$SKILLS_DIR/$skill" ]; then
    echo "  [SKIP] $skill (already exists)"
    SKIPPED=$((SKIPPED + 1))
    continue
  fi
  cp -r "$SKILLS_SRC/$skill" "$SKILLS_DIR/$skill"
  echo "  [INSTALLED] $skill"
  INSTALLED=$((INSTALLED + 1))
done

# Clean up
echo ""
echo "Cleaning up..."
rm -rf "$CLONE_DIR"

echo ""
echo "Done! $INSTALLED installed, $SKIPPED skipped."
echo "Restart Qoder to load the installed skills."
