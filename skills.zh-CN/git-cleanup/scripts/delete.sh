#!/usr/bin/env bash
# Git Cleanup 统一删除脚本
# 接收 JSON 格式的待删除列表，按类别执行删除
# 参数：--worktrees <JSON数组> --branches <JSON数组> --tags <JSON数组>
set -euo pipefail

# Check if jq is available (all scripts depend on jq for JSON processing)
if ! command -v jq &>/dev/null; then
  echo "{\"error\":\"jq is required but not installed\"}"
  exit 1
fi

WORKTREES='[]'
BRANCHES='[]'
TAGS='[]'
RESULTS='[]'

while [[ $# -gt 0 ]]; do
  case "$1" in
    --worktrees) WORKTREES="$2"; shift 2 ;;
    --branches) BRANCHES="$2"; shift 2 ;;
    --tags) TAGS="$2"; shift 2 ;;
    *) echo "{\"error\":\"unknown option: $1\"}"; exit 1 ;;
  esac
done

# 删除 Worktree
delete_worktrees() {
  while IFS= read -r item; do
    [ -z "$item" ] && continue
    local path
    path=$(echo "$item" | jq -r '.path' 2>/dev/null || echo "")
    [ -z "$path" ] && continue
    if git worktree remove "$path" 2>/dev/null; then
      RESULTS=$(echo "$RESULTS" | jq -c --arg p "$path" '. + [{"type": "worktree", "name": $p, "status": "success"}]')
    else
      RESULTS=$(echo "$RESULTS" | jq -c --arg p "$path" '. + [{"type": "worktree", "name": $p, "status": "failed"}]')
    fi
  done < <(echo "$WORKTREES" | jq -c '.[]' 2>/dev/null || echo "")
}

# 删除分支
delete_branches() {
  while IFS= read -r item; do
    [ -z "$item" ] && continue
    local name type
    name=$(echo "$item" | jq -r '.name' 2>/dev/null || echo "")
    type=$(echo "$item" | jq -r '.type' 2>/dev/null || echo "")
    [ -z "$name" ] && continue
    if [ "$type" = "orphan" ]; then
      if git branch -D "$name" 2>/dev/null; then
        RESULTS=$(echo "$RESULTS" | jq -c --arg n "$name" '. + [{"type": "branch", "name": $n, "status": "success"}]')
      else
        RESULTS=$(echo "$RESULTS" | jq -c --arg n "$name" '. + [{"type": "branch", "name": $n, "status": "failed"}]')
      fi
    else
      if git branch -d "$name" 2>/dev/null; then
        RESULTS=$(echo "$RESULTS" | jq -c --arg n "$name" '. + [{"type": "branch", "name": $n, "status": "success"}]')
      else
        RESULTS=$(echo "$RESULTS" | jq -c --arg n "$name" '. + [{"type": "branch", "name": $n, "status": "failed"}]')
      fi
    fi
  done < <(echo "$BRANCHES" | jq -c '.[]' 2>/dev/null || echo "")
}

# 删除 Tag
delete_tags() {
  while IFS= read -r item; do
    [ -z "$item" ] && continue
    local name
    name=$(echo "$item" | jq -r '.name' 2>/dev/null || echo "")
    [ -z "$name" ] && continue
    if git tag -d "$name" 2>/dev/null; then
      RESULTS=$(echo "$RESULTS" | jq -c --arg n "$name" '. + [{"type": "tag", "name": $n, "status": "success"}]')
    else
      RESULTS=$(echo "$RESULTS" | jq -c --arg n "$name" '. + [{"type": "tag", "name": $n, "status": "failed"}]')
    fi
  done < <(echo "$TAGS" | jq -c '.[]' 2>/dev/null || echo "")
}

delete_worktrees
delete_branches
delete_tags

echo "$RESULTS"
