#!/usr/bin/env bash
# Git Cleanup 远程删除脚本
# 批量删除远程分支和 Tag
# 参数：--branches <JSON数组> --tags <JSON数组>
set -euo pipefail

# shellcheck source=scripts/lib/common.sh
. "$(dirname "$0")/lib/common.sh"
require_jq

# 校验远程名称是否为 origin
if ! git remote get-url origin &>/dev/null; then
  echo '{"error":"remote origin not found, remote delete is only supported for origin"}'
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

# 删除远程分支
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

# 删除远程 Tag
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
