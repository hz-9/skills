#!/usr/bin/env bash
# Git Commit Helper environment check script
# Automatically executes git add -A then checks staged changes
# Outputs JSON to stdout
set -euo pipefail

# Check if jq is available (all scripts depend on jq for JSON processing)
if ! command -v jq &>/dev/null; then
  echo "{\"error\":\"jq is required but not installed\"}"
  exit 1
fi

# Initialize JSON
CHECKS='[]'
ALL_PASSED=true

# Check if in a Git repository
check_git_repo() {
  if git rev-parse --git-dir > /dev/null 2>&1; then
    CHECKS=$(echo "$CHECKS" | jq -c '. + [{"name": "in-git-repo", "passed": true}]')
  else
    CHECKS=$(echo "$CHECKS" | jq -c '. + [{"name": "in-git-repo", "passed": false}]')
    ALL_PASSED=false
  fi
}

# Check Git version >= 2.0
check_git_version() {
  local version
  version=$(git --version 2>/dev/null | sed -n 's/.*git version \([0-9]*\.[0-9]*\).*/\1/p' || echo "0.0")
  local major minor
  major=$(echo "$version" | cut -d. -f1)
  minor=$(echo "$version" | cut -d. -f2)
  if [ "$major" -ge 2 ] 2>/dev/null; then
    CHECKS=$(echo "$CHECKS" | jq -c --arg v "$version" '. + [{"name": "git-version", "passed": true, "version": $v}]')
  else
    CHECKS=$(echo "$CHECKS" | jq -c --arg v "$version" '. + [{"name": "git-version", "passed": false, "version": $v}]')
    ALL_PASSED=false
  fi
}

# Check if in a conflict state
check_conflict() {
  local git_dir
  git_dir=$(git rev-parse --git-dir 2>/dev/null) || {
    CHECKS=$(echo "$CHECKS" | jq -c '. + [{"name": "conflict-state", "passed": false, "detail": "not in git repo"}]')
    ALL_PASSED=false
    return
  }

  if [ -f "$git_dir/MERGE_MSG" ]; then
    CHECKS=$(echo "$CHECKS" | jq -c '. + [{"name": "conflict-state", "passed": false, "detail": "merge conflict"}]')
    ALL_PASSED=false
  elif [ -f "$git_dir/CHERRY_PICK_HEAD" ]; then
    CHECKS=$(echo "$CHECKS" | jq -c '. + [{"name": "conflict-state", "passed": false, "detail": "cherry-pick conflict"}]')
    ALL_PASSED=false
  elif [ -f "$git_dir/REVERT_HEAD" ]; then
    CHECKS=$(echo "$CHECKS" | jq -c '. + [{"name": "conflict-state", "passed": false, "detail": "revert conflict"}]')
    ALL_PASSED=false
  elif [ -f "$git_dir/rebase-merge/REBASE_HEAD" ] || [ -d "$git_dir/rebase-apply" ]; then
    CHECKS=$(echo "$CHECKS" | jq -c '. + [{"name": "conflict-state", "passed": false, "detail": "rebase conflict"}]')
    ALL_PASSED=false
  else
    CHECKS=$(echo "$CHECKS" | jq -c '. + [{"name": "conflict-state", "passed": true, "detail": "no conflicts"}]')
  fi
}

# Check if there are changes available for analysis
check_has_changes() {
  # First execute git add -A to stage all changes
  git add -A 2>/dev/null || true

  # Check staged change count
  local staged_count=0
  staged_count=$(git diff --staged --stat 2>/dev/null | wc -l | tr -d ' ' || echo "0")

  if [ "$staged_count" -gt 0 ]; then
    CHECKS=$(echo "$CHECKS" | jq -c --arg detail "${staged_count} staged changes" '. + [{"name": "has-changes", "passed": true, "detail": $detail}]')
  else
    CHECKS=$(echo "$CHECKS" | jq -c '. + [{"name": "has-changes", "passed": false, "detail": "no changes found"}]')
    ALL_PASSED=false
  fi
}

# Main flow
check_git_repo
check_git_version
check_conflict
check_has_changes

# Output JSON
jq -c -n --argjson checks "$CHECKS" --argjson all_passed "$ALL_PASSED" \
  '{ "all_passed": $all_passed, "checks": $checks }'
