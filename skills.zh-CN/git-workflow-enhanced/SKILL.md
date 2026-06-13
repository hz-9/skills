---
name: git-workflow-enhanced
description: 基于 git-commit-helper 生成 commit message → 分支策略决策 → 创建分支 → 管理 prepare-commit-msg hook → 提交 → 推送 → 生成 PR 链接。当用户想要开始新功能、创建分支并提交、或完成"分支+提交+推送+PR"全流程时使用。
---

# Git Workflow Enhanced

自动化 Git 发布工作流：从分支策略决策到 PR 链接生成的全流程。

## Overview

基于暂存变更，自动完成分支策略决策、commit message 生成、分支创建、hook 管理、提交、推送及 PR 链接输出。调用 [git-commit-helper](../git-commit-helper/SKILL.md) 生成符合 Conventional Commits 规范的提交信息。

## Definitions

- **保护分支**：dev、stage、staging、prod、master，禁止直接提交和推送
- **非保护分支**：除保护分支外的所有有效分支
- **功能分支**：从保护分支派生或基于变更语义创建的新分支，命名格式为 `<type>/<kebab-description>`

## Prerequisites

- Git 2.0+
- 当前在 Git 仓库目录中
- 存在已暂存或未暂存的变更
- 如需创建功能分支，确保有分支创建权限

## Workflow

- [ ] Step 1: 确定分支策略
- [ ] Step 2: 生成 commit message
- [ ] Step 3: 提炼分支名并创建分支
- [ ] Step 4: 检测并管理 prepare-commit-msg hook
- [ ] Step 5: 提交
- [ ] Step 6: 推送
- [ ] Step 7: 生成 PR 链接

### Step 1: 确定分支策略

检查当前 HEAD 状态：

```bash
git branch --show-current
git status --short
```

1. **若当前处于保护分支**（含 worktree detached HEAD 源自保护分支的情况）：
   - 基于待提交内容，创建新的功能分支
   - 分支名由 Step 2→3 生成

2. **若当前处于非保护的有效分支**：
   - 基于待提交内容生成新分支名称
   - 向用户提供选择：在当前分支上提交，还是创建新分支

detached HEAD 检测：当 `git branch --show-current` 返回空时，通过 `git log --oneline -1` 结合 `git branch -a --contains <commit>` 推断源头分支。

### Step 2: 生成 commit message

暂存所有变更，并调用 [git-commit-helper](../git-commit-helper/SKILL.md) 分析变更生成 commit message：

```bash
git add -A
```

提交信息规则：
- 采用英文提交信息
- 保持简洁，不过度生成内容
- 禁止包含 `[skip ci]` 等 CI 跳过标记

### Step 3: 提炼分支名并创建分支

仅当需要创建新分支时执行。

从 commit message 提炼分支名，格式为 `<type>/<subject-in-kebab-case>`：

| Commit Message | 分支名 |
|---------------|--------|
| `feat(auth): add user login` | `feat/add-user-login` |
| `fix(utils): correct date formatting` | `fix/correct-date-formatting` |
| `docs: update API docs` | `docs/update-api-docs` |

提炼规则：
- 取 type 作为前缀
- subject 转为 kebab-case（小写 + 连字符），去掉无意义冠词（a, an, the）
- 总长度控制在 50 字符以内，过长则截断 subject

创建并切换分支：

```bash
git checkout -b <branch-name> 2>/dev/null || git checkout <branch-name>
```

### Step 4: 检测并管理 prepare-commit-msg hook

检测 hook 是否存在：

```bash
ls .git/hooks/prepare-commit-msg .husky/prepare-commit-msg 2>/dev/null
```

- **若不存在** → 自动创建 `.git/hooks/prepare-commit-msg`：

  ```bash
  #!/bin/sh
  COMMIT_MSG_FILE=$1; COMMIT_SOURCE=$2
  if [ -z "$COMMIT_SOURCE" ]; then
    GENERATED_MSG=".git/LAST_GENERATED_COMMIT_MSG"
    [ -f "$GENERATED_MSG" ] && cat "$GENERATED_MSG" > "$COMMIT_MSG_FILE" && rm "$GENERATED_MSG"
  fi
  ```

  ```bash
  chmod +x .git/hooks/prepare-commit-msg
  echo "<commit-message>" > .git/LAST_GENERATED_COMMIT_MSG
  ```

- **若已存在** → 读取 hook 内容判断特征：
  - 仅用于 git cz（commitizen）：包含 `exec < /dev/null`、`cz`、`commitizen` → 直接跳过，无需询问
  - 其他用途 → 向用户询问：该 hook 的作用、是否允许跳过、以及跳过方式

### Step 5: 提交

执行提交：

```bash
git commit -m "<message>"
```

若上一步检测到交互型 `prepare-commit-msg` hook，提交前确认用户决策。

### Step 6: 推送

1. **若当前处于保护分支**：不推送
2. **若为非保护分支**：
   - 检查本地是否落后于远端：

     ```bash
     git fetch origin <branch>
     git rev-list --count HEAD..origin/<branch>
     ```

   - 若落后，先 rebase 再推送：

     ```bash
     git rebase origin/<branch>
     git push -u origin <branch>
     ```

   - 若 rebase 产生冲突，暂停并告知用户

### Step 7: 生成 PR 链接

推送完成后，从 `git push` 输出中提取 PR 创建链接并输出。

## Rules

- commit message 必须采用英文，保持简洁，禁止包含 `[skip ci]`
- 分支命名体现变更本质（feat/refactor/docs 等），避免泛化命名（如 `new-branch`）
- PR 链接从 `git push` 输出中的 `remote:` 行正则提取，非硬编码构造
- 若当前为保护分支，禁止直接提交和推送
- 非保护分支推送前必须检查远端同步状态

## Examples

### 对话交互示例

```
用户> /git-ship

AI > 检测到当前分支：main（保护分支）
     变更：新增用户认证模块
     
     正在创建功能分支...

AI > ✅ Git 工作流完成

     分支: feat/add-user-authentication
     Commit: feat(auth): add user authentication with JWT
     Hook: 已创建
     已推送至: origin/feat/add-user-authentication
     PR: https://github.com/org/repo/pull/new/feat/add-user-authentication
```

```
用户> /git-ship

AI > 检测到当前分支：fix/typo-in-readme（非保护分支）
     变更：修正 README 中的拼写错误
     
     建议新分支：docs/fix-typo-in-readme
     请选择：
     1. 在当前分支 fix/typo-in-readme 上提交
     2. 创建新分支 docs/fix-typo-in-readme

用户> 1

AI > 在当前分支提交...
     
     ✅ 提交完成
     Commit: docs: fix typo in README
     已推送至: origin/fix/typo-in-readme
```

### 执行成功示例

| 项目 | 内容 |
|------|------|
| 分支 | feat/add-user-authentication |
| Commit | feat(auth): add user authentication with JWT |
| Hook | 已创建（prepare-commit-msg） |
| 推送状态 | 已推送至 origin/feat/add-user-authentication |
| PR 链接 | https://github.com/org/repo/pull/new/feat/... |

## Review List

完成工作流后，验证以下内容：
- [ ] commit message 符合 Conventional Commits 规范
- [ ] 分支名格式为 `<type>/<kebab-description>`
- [ ] 保护分支未被直接提交或推送
- [ ] 非保护分支推送前已检查远端同步状态
- [ ] PR 链接正确生成

## References

- 分支名提炼细则、错误处理：参见 [REFERENCE.md](REFERENCE.md)
- Commit message 生成：参见 [git-commit-helper](../git-commit-helper/SKILL.md)
- Conventional Commits 规范：参见 [git-commit-helper/references/conventional-commits.md](../git-commit-helper/references/conventional-commits.md)
