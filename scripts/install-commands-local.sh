#!/bin/bash
# Install commands from the local repository
# Usage: bash scripts/install-commands-local.sh
#
# This script uses the local repository directly instead of cloning from GitHub.
#
# Environment variables:
#   COMMANDS_DIR  - Target directory (default: ~/.agents/commands)

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

exec "$SCRIPT_DIR/install-commands.sh" --repo-dir "$REPO_DIR"
