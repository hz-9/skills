#!/bin/bash
# Install skills from GitHub repo to ~/.qoder/skills/
# Usage: bash scripts/install-skills.sh [--repo-dir <path>]
#
# Environment variables:
#   SKILLS_DIR  - Target directory (default: ~/.qoder/skills)
#
# Options:
#   --repo-dir <path>  - Use local repository directory instead of cloning from GitHub

set -e

REPO="hz-9/skills"
BRANCH="master"
CLONE_DIR="/tmp/hz-9-skills"
SKILLS_DIR="${SKILLS_DIR:-$HOME/.qoder/skills}"

# Parse command line arguments
REPO_DIR=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    --repo-dir)
      if [ $# -lt 2 ]; then
        echo "Unknown option: $1"
        echo "Usage: $0 [--repo-dir <path>]"
        exit 1
      fi
      REPO_DIR="$2"
      shift 2
      ;;
    *)
      echo "Unknown option: $1"
      echo "Usage: $0 [--repo-dir <path>]"
      exit 1
      ;;
  esac
done

echo "=== Install skills from $REPO ==="
echo ""

if [ -n "$REPO_DIR" ]; then
  # Use local repository directory
  echo "Using local repository: $REPO_DIR"
  SOURCE_DIR="$REPO_DIR"
  echo ""
else
  # Step 1: Clone repo from GitHub
  echo "Cloning repository $REPO ($BRANCH)..."
  if [ -d "$CLONE_DIR" ]; then
    rm -rf "$CLONE_DIR"
  fi
  git clone --depth 1 -b "$BRANCH" "https://github.com/$REPO.git" "$CLONE_DIR"
  echo ""
  SOURCE_DIR="$CLONE_DIR"
fi

# Step 2: Language selection
echo "Select language for skills source:"
echo "  1) English"
echo "  2) 中文"
read -p "Choice [1/2]: " lang_choice

case "$lang_choice" in
  2|zh*|中*)
    SKILLS_SRC="$SOURCE_DIR/skills.zh-CN"
    lang_display="中文"
    ;;
  *)
    SKILLS_SRC="$SOURCE_DIR/skills"
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

# Clean up (only if cloned from GitHub)
if [ -z "$REPO_DIR" ]; then
  echo ""
  echo "Cleaning up..."
  rm -rf "$CLONE_DIR"
fi

echo ""
echo "Done! $INSTALLED installed, $SKIPPED skipped."
echo "Restart Qoder to load the installed skills."
