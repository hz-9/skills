#!/usr/bin/env bash
# Git Cleanup 环境检查脚本
# 自动检测远程仓库
# JSON 格式输出到 stdout
set -euo pipefail

# shellcheck source=scripts/lib/common.sh
. "$(dirname "$0")/lib/common.sh"
require_jq

# 初始化 JSON
CHECKS='[]'

# 检查是否在 Git 仓库中
check_git_repo() {
  if git rev-parse --git-dir > /dev/null 2>&1; then
    CHECKS=$(echo "$CHECKS" | jq -c '. + [{"name": "in-git-repo", "passed": true}]')
  else
    CHECKS=$(echo "$CHECKS" | jq -c '. + [{"name": "in-git-repo", "passed": false}]')
  fi
}

# 检查 Git 版本 >= 2.0
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
  fi
}

# 检测远程仓库
check_remote() {
  # 检测远程仓库是否存在
  local has_remote=false
  if git remote 2>/dev/null | head -1 | grep -q .; then
    has_remote=true
  fi
  CHECKS=$(echo "$CHECKS" | jq -c --argjson r "$has_remote" '. + [{"name": "has-remote", "passed": $r}]')
}

# 主流程
check_git_repo
check_git_version
check_remote

# 输出 JSON
jq -c -n --argjson checks "$CHECKS" \
  '{ "checks": $checks }'
