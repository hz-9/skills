#!/bin/bash
# Install commands from GitHub repo to target directory
# Usage: bash scripts/install-commands.sh [--repo-dir <path>]
#
# Environment variables:
#   COMMANDS_DIR  - Target directory (default: ~/.agents/commands)
#
# Options:
#   --repo-dir <path>  - Use local repository directory instead of cloning from GitHub

set -e

REPO="hz-9/skills"
BRANCH="master"
CLONE_DIR="/tmp/hz-9-skills"
COMMANDS_DIR="${COMMANDS_DIR:-$HOME/.agents/commands}"

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

echo "=== Install commands from $REPO ==="
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
echo "Select language for commands source:"
echo "  1) English"
echo "  2) 中文"
read -p "Choice [1/2]: " lang_choice

case "$lang_choice" in
  2|zh*|中*)
    COMMANDS_SRC="$SOURCE_DIR/commands.zh-CN"
    lang_display="中文"
    ;;
  *)
    COMMANDS_SRC="$SOURCE_DIR/commands"
    lang_display="English"
    ;;
esac

echo "Selected: $lang_display"
echo ""

# Ensure target directory exists
if [ ! -d "$COMMANDS_DIR" ]; then
  echo "Creating target directory: $COMMANDS_DIR"
  mkdir -p "$COMMANDS_DIR"
fi

# Scan source commands (.md files)
echo "Scanning available commands..."
AVAILABLE_COMMANDS=()
for cmd_file in "$COMMANDS_SRC"/*.md; do
  if [ -f "$cmd_file" ]; then
    AVAILABLE_COMMANDS+=("$(basename "$cmd_file")")
  fi
done

echo "Found ${#AVAILABLE_COMMANDS[@]} commands in repository"
echo ""

# Check for existing installed commands
CONFLICT_COMMANDS=()
for cmd in "${AVAILABLE_COMMANDS[@]}"; do
  if [ -f "$COMMANDS_DIR/$cmd" ]; then
    CONFLICT_COMMANDS+=("$cmd")
  fi
done

if [ ${#CONFLICT_COMMANDS[@]} -gt 0 ]; then
  echo "The following installed commands will be OVERWRITTEN:"
  for cmd in "${CONFLICT_COMMANDS[@]}"; do
    echo "  - $cmd"
  done
  read -p "Overwrite all? [y/N] " confirm
  if [[ ! "$confirm" =~ ^[yY]$ ]]; then
    echo "Skip overwriting existing commands."
  else
    echo "Overwriting existing commands..."
    for cmd in "${CONFLICT_COMMANDS[@]}"; do
      rm -f "$COMMANDS_DIR/$cmd"
    done
  fi
fi

# Install/copy all commands
echo ""
echo "Installing commands..."
INSTALLED=0
SKIPPED=0
for cmd in "${AVAILABLE_COMMANDS[@]}"; do
  if [ -f "$COMMANDS_DIR/$cmd" ]; then
    echo "  [SKIP] $cmd (already exists)"
    SKIPPED=$((SKIPPED + 1))
    continue
  fi
  cp "$COMMANDS_SRC/$cmd" "$COMMANDS_DIR/$cmd"
  echo "  [INSTALLED] $cmd"
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
