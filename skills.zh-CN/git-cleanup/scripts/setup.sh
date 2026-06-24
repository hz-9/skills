#!/usr/bin/env bash
# Git Cleanup 环境准备脚本
# 合并：主分支检测 + 识别当前 Worktree/分支 + 备份创建
# JSON 格式输出到 stdout
set -euo pipefail

# Check if jq is available (all scripts depend on jq for JSON processing)
if ! command -v jq &>/dev/null; then
  echo "{\"error\":\"jq is required but not installed\"}"
  exit 1
fi

WORK_DIR=$(pwd)
REPO_NAME=$(basename "$WORK_DIR")
BACKUP_DIR="${WORK_DIR}.bak.$(date +'%Y%m%dT%H%M%S')"
OUTPUT='{}'

# 检测主分支
detect_main_branch() {
  local main_branch=""
  for candidate in main master prod; do
    if git rev-parse --verify "refs/heads/$candidate" > /dev/null 2>&1; then
      main_branch="$candidate"
      break
    fi
  done
  OUTPUT=$(echo "$OUTPUT" | jq -c --arg b "$main_branch" '. + {"main_branch_candidate": $b}')
}

# 识别当前 Worktree 和检出分支
identify_worktree() {
  local current_wt
  current_wt=$(git worktree list --porcelain 2>/dev/null | head -1 | sed 's/^worktree //' || echo "")
  local current_branch
  current_branch=$(git branch --show-current 2>/dev/null || echo "")
  OUTPUT=$(echo "$OUTPUT" | jq -c \
    --arg wt "$current_wt" \
    --arg br "$current_branch" \
    '. + {"current_worktree": $wt, "current_branch": $br}')
}

# 创建备份
create_backup() {
  if cp -a "$WORK_DIR" "$BACKUP_DIR" 2>/dev/null; then
    OUTPUT=$(echo "$OUTPUT" | jq -c --arg path "$BACKUP_DIR" '. + {"backup_created": true, "backup_path": $path}')
  else
    OUTPUT=$(echo "$OUTPUT" | jq -c '. + {"backup_created": false}')
  fi
}

detect_main_branch
identify_worktree
create_backup

echo "$OUTPUT"
