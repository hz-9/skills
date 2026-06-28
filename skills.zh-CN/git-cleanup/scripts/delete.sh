#!/usr/bin/env bash
# Git Cleanup 统一删除脚本
# 接收 JSON 格式的待删除列表，按类别执行删除
# 参数：--worktrees <JSON数组> --branches <JSON数组> --tags <JSON数组>
set -euo pipefail

# shellcheck source=scripts/lib/common.sh
. "$(dirname "$0")/lib/common.sh"
require_jq

WORKTREES='[]'
BRANCHES='[]'
TAGS='[]'
PROTECTED_BRANCHES=''
RESULTS='[]'

while [[ $# -gt 0 ]]; do
  case "$1" in
    --worktrees) WORKTREES="$2"; shift 2 ;;
    --branches) BRANCHES="$2"; shift 2 ;;
    --tags) TAGS="$2"; shift 2 ;;
    --protected-branches) PROTECTED_BRANCHES="$2"; shift 2 ;;
    *) echo "{\"error\":\"unknown option: $1\"}"; exit 1 ;;
  esac
done

if [ -z "$PROTECTED_BRANCHES" ]; then
  # 默认保护分支列表，与 references/protected-branch.md 保持一致
  PROTECTED_BRANCHES="dev,stage,staging,prod,master,main"
fi

# 删除 Worktree
delete_worktrees() {
  while IFS= read -r item; do
    [ -z "$item" ] && continue
    local path
    path=$(echo "$item" | jq -r '.path' 2>/dev/null || echo "")
    [ -z "$path" ] && continue

    # 检查 Worktree 是否存在未提交变更（脏状态），脏 Worktree 不删除
    local is_dirty=false
    if [ -d "$path" ]; then
      local dirty_count
      dirty_count=$(git -C "$path" status --porcelain 2>/dev/null | wc -l | tr -d ' ' || true)
      dirty_count=${dirty_count:-0}
      [ "$dirty_count" -gt 0 ] && is_dirty=true
    fi
    if [ "$is_dirty" = true ]; then
      RESULTS=$(echo "$RESULTS" | jq -c --arg p "$path" '. + [{"type": "worktree", "name": $p, "status": "skipped", "reason": "dirty worktree"}]')
      continue
    fi

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
    # 二次校验：跳过保护分支
    if is_protected_branch "$name" "$PROTECTED_BRANCHES"; then
      RESULTS=$(echo "$RESULTS" | jq -c --arg n "$name" '. + [{"type": "branch", "name": $n, "status": "skipped", "reason": "protected branch"}]')
      continue
    fi
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
