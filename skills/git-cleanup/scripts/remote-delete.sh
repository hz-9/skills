#!/usr/bin/env bash
# Git Cleanup remote deletion script
# Batch delete remote branches and tags
# Parameters: --branches <JSON array> --tags <JSON array>
set -euo pipefail

# Check if jq is available (all scripts depend on jq for JSON processing)
if ! command -v jq &>/dev/null; then
  echo "{\"error\":\"jq is required but not installed\"}"
  exit 1
fi

BRANCHES='[]'
TAGS='[]'
RESULTS='[]'

while [[ $# -gt 0 ]]; do
  case "$1" in
    --branches) BRANCHES="$2"; shift 2 ;;
    --tags) TAGS="$2"; shift 2 ;;
    *) echo "{\"error\":\"unknown option: $1\"}"; exit 1 ;;
  esac
done

# Delete remote branches
delete_remote_branches() {
  while IFS= read -r item; do
    [ -z "$item" ] && continue
    local name
    name=$(echo "$item" | jq -r '.name' 2>/dev/null || echo "")
    [ -z "$name" ] && continue
    if git push origin --delete "$name" 2>/dev/null; then
      RESULTS=$(echo "$RESULTS" | jq -c --arg n "$name" '. + [{"type": "remote-branch", "name": $n, "status": "success"}]')
    else
      RESULTS=$(echo "$RESULTS" | jq -c --arg n "$name" '. + [{"type": "remote-branch", "name": $n, "status": "failed"}]')
    fi
  done < <(echo "$BRANCHES" | jq -c '.[]' 2>/dev/null || echo "")
}

# Delete remote tags
delete_remote_tags() {
  while IFS= read -r item; do
    [ -z "$item" ] && continue
    local name
    name=$(echo "$item" | jq -r '.name' 2>/dev/null || echo "")
    [ -z "$name" ] && continue
    if git push origin --delete "refs/tags/$name" 2>/dev/null; then
      RESULTS=$(echo "$RESULTS" | jq -c --arg n "$name" '. + [{"type": "remote-tag", "name": $n, "status": "success"}]')
    else
      RESULTS=$(echo "$RESULTS" | jq -c --arg n "$name" '. + [{"type": "remote-tag", "name": $n, "status": "failed"}]')
    fi
  done < <(echo "$TAGS" | jq -c '.[]' 2>/dev/null || echo "")
}

delete_remote_branches
delete_remote_tags

echo "$RESULTS"
