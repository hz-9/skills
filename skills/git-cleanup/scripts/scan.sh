#!/usr/bin/env bash
# Git Cleanup comprehensive scan script
# Scans all categories of stale references at once, outputs three separate JSON arrays
# Parameter: --main-branch <name> specify the main branch name
set -euo pipefail

# Check if jq is available (all scripts depend on jq for JSON processing)
if ! command -v jq &>/dev/null; then
  echo "{\"error\":\"jq is required but not installed\"}"
  exit 1
fi

MAIN_BRANCH=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    --main-branch) MAIN_BRANCH="$2"; shift 2 ;;
    *) echo "{\"error\":\"unknown option: $1\"}"; exit 1 ;;
  esac
done

if [ -z "$MAIN_BRANCH" ]; then
  echo "{\"error\":\"--main-branch is required\"}"
  exit 1
fi

# Scan Worktree
scan_worktree() {
  local current_wt
  current_wt=$(git worktree list --porcelain 2>/dev/null | head -1 | sed 's/^worktree //' || echo "")
  local worktrees='[]'
  while IFS= read -r line; do
    if [[ "$line" =~ ^worktree (.*) ]]; then
      local path="${BASH_REMATCH[1]}"
      local branch=""
      # Read HEAD line (skip)
      read -r head_line
      # Read next line, which may be a branch line or empty (detached HEAD)
      read -r next_line
      if [[ "$next_line" =~ ^branch refs/heads/(.*) ]]; then
        branch="${BASH_REMATCH[1]}"
      fi
      local is_current=false
      [ "$path" = "$current_wt" ] && is_current=true
      worktrees=$(echo "$worktrees" | jq -c --arg p "$path" --arg b "$branch" --argjson c "$is_current" '. + [{"path": $p, "branch": $b, "is_current": $c}]')
    fi
  done < <(git worktree list --porcelain 2>/dev/null || echo "")

  echo "$worktrees"
}

# Scan branches
scan_branches() {
  local branches='[]'
  local worktree_branches
  worktree_branches=$(git worktree list --porcelain 2>/dev/null | grep "^branch refs/heads/" | sed 's|^branch refs/heads/||' || echo "")

  # Merged branches
  while IFS= read -r branch; do
    [ -z "$branch" ] && continue
    # Skip protected branches, current branch, worktree-bound branches
    if echo "$worktree_branches" | grep -q -F "$branch"; then continue; fi
    if [ "$branch" = "$MAIN_BRANCH" ] || [ "$branch" = "develop" ] || [ "$branch" = "$(git branch --show-current)" ]; then continue; fi
    branches=$(echo "$branches" | jq -c --arg b "$branch" --arg t "merged" --arg r "merged into $MAIN_BRANCH" '. + [{"name": $b, "type": $t, "reason": $r}]')
  done < <(git branch --merged "$MAIN_BRANCH" --format='%(refname:short)' 2>/dev/null || echo "")

  # Orphan branches
  while IFS= read -r branch; do
    [ -z "$branch" ] && continue
    if echo "$worktree_branches" | grep -q -F "$branch"; then continue; fi
    if [ "$branch" = "$MAIN_BRANCH" ] || [ "$branch" = "develop" ] || [ "$branch" = "$(git branch --show-current)" ]; then continue; fi
    local exists=false
    exists=$(echo "$branches" | jq --arg b "$branch" '[.[] | select(.name == $b)] | length > 0' 2>/dev/null || echo "false")
    if [ "$exists" = "false" ]; then
      branches=$(echo "$branches" | jq -c --arg b "$branch" --arg t "orphan" --arg r "remote tracking gone" '. + [{"name": $b, "type": $t, "reason": $r}]')
    fi
  done < <(git branch -vv 2>/dev/null | awk '/: gone]/{if ($1 == "*") print $2; else print $1}' || echo "")

  echo "$branches"
}

# Scan tags
scan_tags() {
  local tags='[]'
  while IFS= read -r tag; do
    [ -z "$tag" ] && continue
    # Non-version tags
    if ! echo "$tag" | grep -q -E '^v?[0-9]+\.[0-9]+\.[0-9]+(-[a-zA-Z0-9.-]+)?(\+[a-zA-Z0-9.]+)?$'; then
      tags=$(echo "$tags" | jq -c --arg t "$tag" --arg type "non-version" --arg r "does not match semver" '. + [{"name": $t, "type": $type, "reason": $r}]')
      continue
    fi
    # Orphan tags
    local has_branch
    has_branch=$(git branch --all --contains "$tag" 2>/dev/null | head -1 || echo "")
    if [ -z "$has_branch" ]; then
      tags=$(echo "$tags" | jq -c --arg t "$tag" --arg type "orphan" --arg r "no branch references" '. + [{"name": $t, "type": $type, "reason": $r}]')
    fi
  done < <(git tag -l 2>/dev/null || echo "")

  echo "$tags"
}

# Execute scans and output
WORKTREE_JSON=$(scan_worktree)
BRANCH_JSON=$(scan_branches)
TAG_JSON=$(scan_tags)

jq -c -n \
  --argjson worktrees "$WORKTREE_JSON" \
  --argjson branches "$BRANCH_JSON" \
  --argjson tags "$TAG_JSON" \
  '{ "worktrees": $worktrees, "branches": $branches, "tags": $tags }'
