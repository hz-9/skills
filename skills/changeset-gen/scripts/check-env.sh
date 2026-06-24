#!/usr/bin/env bash
# Changeset Gen environment check script
# Automatically executes git add -A, checks changes, pnpm changeset, and workspace config
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

# Execute git add -A then check for staged changes
check_has_changes() {
  git add -A 2>/dev/null || true

  local staged_count=0
  staged_count=$(git diff --staged --stat 2>/dev/null | wc -l | tr -d ' ' || echo "0")

  if [ "$staged_count" -gt 0 ]; then
    CHECKS=$(echo "$CHECKS" | jq -c --arg detail "${staged_count} staged changes" '. + [{"name": "has-changes", "passed": true, "detail": $detail}]')
  else
    CHECKS=$(echo "$CHECKS" | jq -c '. + [{"name": "has-changes", "passed": false, "detail": "no changes found"}]')
    ALL_PASSED=false
  fi
}

# Check pnpm changeset configuration
check_pnpm_changeset() {
  local has_changeset_dir=false
  local has_changeset_cli=false

  if [ -d ".changeset" ]; then
    has_changeset_dir=true
  fi

  if [ -f "package.json" ]; then
    local cli_check
    cli_check=$(cat package.json 2>/dev/null | jq -r '.devDependencies["@changesets/cli"] // .dependencies["@changesets/cli"] // ""' 2>/dev/null || echo "")
    if [ -n "$cli_check" ]; then
      has_changeset_cli=true
    fi
  fi

  if [ "$has_changeset_dir" = true ] && [ "$has_changeset_cli" = true ]; then
    CHECKS=$(echo "$CHECKS" | jq -c '. + [{"name": "pnpm-changeset", "passed": true, "detail": "changeset enabled"}]')
  else
    local detail=""
    if [ "$has_changeset_dir" != true ]; then detail="missing .changeset/ directory"; fi
    if [ "$has_changeset_cli" != true ]; then
      if [ -n "$detail" ]; then detail="$detail, "; fi
      detail="${detail}missing @changesets/cli"
    fi
    CHECKS=$(echo "$CHECKS" | jq -c --arg d "$detail" '. + [{"name": "pnpm-changeset", "passed": false, "detail": $d}]')
    ALL_PASSED=false
  fi
}

# Check pnpm-workspace.yaml
check_pnpm_workspace() {
  if [ -f "pnpm-workspace.yaml" ]; then
    local packages
    packages=$(grep -E '^\s*packages:' pnpm-workspace.yaml 2>/dev/null || true)
    if [ -n "$packages" ]; then
      CHECKS=$(echo "$CHECKS" | jq -c '. + [{"name": "pnpm-workspace", "passed": true, "detail": "pnpm-workspace.yaml with packages"}]')
    else
      CHECKS=$(echo "$CHECKS" | jq -c '. + [{"name": "pnpm-workspace", "passed": false, "detail": "pnpm-workspace.yaml missing packages config"}]')
      ALL_PASSED=false
    fi
  else
    CHECKS=$(echo "$CHECKS" | jq -c '. + [{"name": "pnpm-workspace", "passed": false, "detail": "missing pnpm-workspace.yaml"}]')
    ALL_PASSED=false
  fi
}

# Main flow
check_git_repo
check_git_version
check_has_changes
check_pnpm_changeset
check_pnpm_workspace

# Output JSON
jq -c -n --argjson checks "$CHECKS" --argjson all_passed "$ALL_PASSED" \
  '{ "all_passed": $all_passed, "checks": $checks }'
