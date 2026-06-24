#!/usr/bin/env bash
# Git Cleanup 环境检查脚本
# 自动执行 git fetch -p，检测远程仓库
# JSON 格式输出到 stdout
set -euo pipefail

# Check if jq is available (all scripts depend on jq for JSON processing)
if ! command -v jq &>/dev/null; then
  echo "{\"error\":\"jq is required but not installed\"}"
  exit 1
fi

# 初始化 JSON
CHECKS='[]'
ALL_PASSED=true

# 检查是否在 Git 仓库中
check_git_repo() {
  if git rev-parse --git-dir > /dev/null 2>&1; then
    CHECKS=$(echo "$CHECKS" | jq -c '. + [{"name": "in-git-repo", "passed": true}]')
  else
    CHECKS=$(echo "$CHECKS" | jq -c '. + [{"name": "in-git-repo", "passed": false}]')
    ALL_PASSED=false
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
    ALL_PASSED=false
  fi
}

# 执行 git fetch -p 并检测远程仓库
check_remote() {
  # 执行 git fetch -p
  if git fetch -p 2>/dev/null; then
    CHECKS=$(echo "$CHECKS" | jq -c '. + [{"name": "fetch-prune", "passed": true}]')
  else
    CHECKS=$(echo "$CHECKS" | jq -c '. + [{"name": "fetch-prune", "passed": false, "detail": "git fetch -p failed"}]')
  fi

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
jq -c -n --argjson checks "$CHECKS" --argjson all_passed "$ALL_PASSED" \
  '{ "all_passed": $all_passed, "checks": $checks }'
