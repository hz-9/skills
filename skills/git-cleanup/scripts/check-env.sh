#!/usr/bin/env bash
# Git Cleanup environment check script
# Automatically executes git fetch -p, detects remote repository
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

# Execute git fetch -p and detect remote repository
check_remote() {
  # Execute git fetch -p
  if git fetch -p 2>/dev/null; then
    CHECKS=$(echo "$CHECKS" | jq -c '. + [{"name": "fetch-prune", "passed": true}]')
  else
    CHECKS=$(echo "$CHECKS" | jq -c '. + [{"name": "fetch-prune", "passed": false, "detail": "git fetch -p failed"}]')
  fi

  # Detect if remote repository exists
  local has_remote=false
  if git remote 2>/dev/null | head -1 | grep -q .; then
    has_remote=true
  fi
  CHECKS=$(echo "$CHECKS" | jq -c --argjson r "$has_remote" '. + [{"name": "has-remote", "passed": $r}]')
}

# Main flow
check_git_repo
check_git_version
check_remote

# Output JSON
jq -c -n --argjson checks "$CHECKS" --argjson all_passed "$ALL_PASSED" \
  '{ "all_passed": $all_passed, "checks": $checks }'
