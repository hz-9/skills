#!/usr/bin/env bash
# Git Cleanup 全面扫描脚本
# 一次性扫描所有类别废弃引用，输出三个独立 JSON
# 参数：--main-branch <名称> 指定主分支名
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

# 扫描 Worktree
scan_worktree() {
  local current_wt
  current_wt=$(git worktree list --porcelain 2>/dev/null | head -1 | sed 's/^worktree //' || echo "")
  local worktrees='[]'
  while IFS= read -r line; do
    if [[ "$line" =~ ^worktree (.*) ]]; then
      local path="${BASH_REMATCH[1]}"
      local branch=""
      # 读取 HEAD 行（跳过）
      read -r head_line
      # 读取下一行，可能是 branch 行或空行（detached HEAD）
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

# 扫描分支
scan_branches() {
  local branches='[]'
  local worktree_branches
  worktree_branches=$(git worktree list --porcelain 2>/dev/null | grep "^branch refs/heads/" | sed 's|^branch refs/heads/||' || echo "")

  # 已合并分支
  while IFS= read -r branch; do
    [ -z "$branch" ] && continue
    # 跳过保护分支、当前分支、worktree 绑定分支
    if echo "$worktree_branches" | grep -q -F "$branch"; then continue; fi
    if [ "$branch" = "$MAIN_BRANCH" ] || [ "$branch" = "develop" ] || [ "$branch" = "$(git branch --show-current)" ]; then continue; fi
    branches=$(echo "$branches" | jq -c --arg b "$branch" --arg t "merged" --arg r "merged into $MAIN_BRANCH" '. + [{"name": $b, "type": $t, "reason": $r}]')
  done < <(git branch --merged "$MAIN_BRANCH" --format='%(refname:short)' 2>/dev/null || echo "")

  # 孤儿分支
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

# 扫描 Tag
scan_tags() {
  local tags='[]'
  while IFS= read -r tag; do
    [ -z "$tag" ] && continue
    # 非版本 Tag
    if ! echo "$tag" | grep -q -E '^v?[0-9]+\.[0-9]+\.[0-9]+(-[a-zA-Z0-9.-]+)?(\+[a-zA-Z0-9.]+)?$'; then
      tags=$(echo "$tags" | jq -c --arg t "$tag" --arg type "non-version" --arg r "does not match semver" '. + [{"name": $t, "type": $type, "reason": $r}]')
      continue
    fi
    # 孤儿 Tag
    local has_branch
    has_branch=$(git branch --all --contains "$tag" 2>/dev/null | head -1 || echo "")
    if [ -z "$has_branch" ]; then
      tags=$(echo "$tags" | jq -c --arg t "$tag" --arg type "orphan" --arg r "no branch references" '. + [{"name": $t, "type": $type, "reason": $r}]')
    fi
  done < <(git tag -l 2>/dev/null || echo "")

  echo "$tags"
}

# 执行扫描并输出
WORKTREE_JSON=$(scan_worktree)
BRANCH_JSON=$(scan_branches)
TAG_JSON=$(scan_tags)

jq -c -n \
  --argjson worktrees "$WORKTREE_JSON" \
  --argjson branches "$BRANCH_JSON" \
  --argjson tags "$TAG_JSON" \
  '{ "worktrees": $worktrees, "branches": $branches, "tags": $tags }'
