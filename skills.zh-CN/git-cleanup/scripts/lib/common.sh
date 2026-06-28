#!/usr/bin/env bash
# Git Cleanup 公共库
# 被各脚本通过 source 引用

# 检查 jq 是否可用，不可用时输出 JSON 错误并退出
require_jq() {
  if ! command -v jq &>/dev/null; then
    echo '{"error":"jq is required but not installed"}'
    exit 1
  fi
}

# 判断分支是否在保护列表中
# 参数：(1) 分支名 (2) 保护分支列表（逗号分隔）
is_protected_branch() {
  local branch="$1"
  local protected_list="${2:-}"
  [ -z "$branch" ] && return 1
  [ -z "$protected_list" ] && return 1
  local IFS=','
  for pb in $protected_list; do
    [ "$branch" = "$pb" ] && return 0
  done
  return 1
}
