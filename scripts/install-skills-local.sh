#!/bin/bash
# Install skills from the local repository
# Usage: bash scripts/install-skills-local.sh
#
# This script uses the local repository directly instead of cloning from GitHub.
#
# Environment variables:
#   SKILLS_DIR  - Target directory (default: ~/.qoder/skills)

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

exec "$SCRIPT_DIR/install-skills.sh" --repo-dir "$REPO_DIR"
