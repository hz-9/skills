#!/bin/bash
# Sync commands from GitHub repo to local commands directory
# Usage: bash scripts/sync-commands.sh
#
# Downloads command files from the GitHub repository's commands/ directory
# and syncs them to the local directory (default: ~/.agents/commands).
# Set the COMMANDS_DIR environment variable to override the target path.

set -e

REPO="hz-9/skills"
BRANCH="master"
COMMANDS_SRC_URL="https://api.github.com/repos/$REPO/contents/commands"
RAW_BASE_URL="https://raw.githubusercontent.com/$REPO/$BRANCH/commands"
COMMANDS_DIR="${COMMANDS_DIR:-$HOME/.agents/commands}"

echo "=== Sync commands from $REPO to $COMMANDS_DIR ==="
echo ""

# Ensure the target directory exists
if [ ! -d "$COMMANDS_DIR" ]; then
  echo "Creating commands directory: $COMMANDS_DIR"
  mkdir -p "$COMMANDS_DIR"
fi

# Fetch the list of command files from GitHub
echo "Fetching command list from GitHub..."
RESPONSE=$(curl -s "$COMMANDS_SRC_URL")

# Check if the response is an array (success) or an object (error)
if ! echo "$RESPONSE" | python3 -c "import sys,json; data=json.load(sys.stdin); assert isinstance(data, list), 'not a list'" 2>/dev/null; then
  ERROR_MSG=$(echo "$RESPONSE" | python3 -c "import sys,json; data=json.load(sys.stdin); print(data.get('message', 'Unknown error'))" 2>/dev/null || echo "Failed to parse response")
  echo "  [ERROR] Failed to fetch commands: $ERROR_MSG"
  exit 1
fi

# Extract names of .md files
REMOTE_FILES=$(echo "$RESPONSE" | python3 -c "
import sys, json
data = json.load(sys.stdin)
for f in data:
  if f['type'] == 'file' and f['name'].endswith('.md'):
    print(f['name'])
")

if [ -z "$REMOTE_FILES" ]; then
  echo "  [INFO] No command files found in the remote repository."
  exit 0
fi

echo "Remote command files:"
echo "$REMOTE_FILES" | sed 's/^/  - /'
echo ""

# Download each command file
DOWNLOADED=""
for FILE in $REMOTE_FILES; do
  URL="$RAW_BASE_URL/$FILE"
  DEST="$COMMANDS_DIR/$FILE"
  echo "Downloading $FILE ..."
  if curl -sSf -o "$DEST" "$URL"; then
    echo "  [SYNCED] $FILE → $DEST"
    DOWNLOADED="$DOWNLOADED $FILE"
  else
    echo "  [ERROR] Failed to download $FILE"
  fi
done

# Remove local files that no longer exist in the remote
echo ""
echo "Checking for stale local command files..."
for LOCAL_FILE in "$COMMANDS_DIR"/*.md; do
  if [ -f "$LOCAL_FILE" ]; then
    BASENAME=$(basename "$LOCAL_FILE")
    if ! echo "$REMOTE_FILES" | grep -qx "$BASENAME"; then
      rm "$LOCAL_FILE"
      echo "  [REMOVED] $BASENAME (no longer in remote)"
    fi
  fi
done

echo ""
echo "Done! Commands synced to $COMMANDS_DIR"
