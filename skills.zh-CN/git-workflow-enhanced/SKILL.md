---
name: git-workflow-enhanced
description: 基于 git-commit-helper 生成 commit message → 提炼分支名称 → 创建分支 → 自动管理 prepare-commit-msg hook。当用户想要开始新功能、创建分支、初始化提交环境时使用。
---

# Git Workflow Enhanced

自动化工作流：commit message 生成 → 分支提炼 → 分支创建 → prepare-commit-msg 钩子管理。

## 工作流程

- [ ] Step 1: 调用 git-commit-helper 获取 commit message
- [ ] Step 2: 从 commit message 提炼分支名称
- [ ] Step 3: 创建并切换分支
- [ ] Step 4: 检测 prepare-commit-msg hook
- [ ] Step 5: 若 hook 不存在 → 自动创建
- [ ] Step 6: 若 hook 已存在 → 判断是否跳过

### Step 1: 调用 git-commit-helper 获取 commit message

查看当前变更：

```bash
git status
```

按照 [git-commit-helper](../git-commit-helper/SKILL.md) 分析变更并生成 commit message。暂存所有变更：

```bash
git add -A
```

示例输出：`feat(auth): add user login with JWT authentication`

### Step 2: 提炼分支名称

从 message 中提取 type + subject 拼接为分支名：

```
feat(auth): add user login with JWT authentication
↓ type: feat | scope: auth | subject: add user login with JWT authentication
↓ feat/add-user-login-with-jwt-authentication
```

| Commit Message | 分支名 |
|---------------|--------|
| `feat(auth): add user login` | `feat/add-user-login` |
| `fix(utils): correct date formatting` | `fix/correct-date-formatting` |
| `docs: update API docs` | `docs/update-api-docs` |

### Step 3: 创建并切换分支

```bash
git checkout -b <branch-name> 2>/dev/null || git checkout <branch-name>
```

### Step 4: 检测 prepare-commit-msg hook

```bash
ls .git/hooks/prepare-commit-msg .husky/prepare-commit-msg 2>/dev/null
```

### Step 5: 若不存在 → 自动创建

创建 `.git/hooks/prepare-commit-msg`，内容如下：

```bash
#!/bin/sh
COMMIT_MSG_FILE=$1; COMMIT_SOURCE=$2
if [ -z "$COMMIT_SOURCE" ]; then
  GENERATED_MSG=".git/LAST_GENERATED_COMMIT_MSG"
  [ -f "$GENERATED_MSG" ] && cat "$GENERATED_MSG" > "$COMMIT_MSG_FILE" && rm "$GENERATED_MSG"
fi
```

赋予执行权限并保存 commit message：

```bash
chmod +x .git/hooks/prepare-commit-msg
echo "<commit-message>" > .git/LAST_GENERATED_COMMIT_MSG
```

### Step 6: 若已存在 → 判断是否跳过

读取 hook 内容，判断特征：

- **仅用于 git cz**（commitizen）：包含 `exec < /dev/null`、`cz`、`commitizen` → **直接跳过，无需询问**
- **其他用途** → **询问用户**："已存在 prepare-commit-msg 钩子，是否跳过？"

## 输出摘要

完成后显示摘要：

```
✅ Git 工作流就绪

分支: feat/add-user-login-with-jwt-authentication
Commit: feat(auth): add user login with JWT authentication
Hook: 已创建 / 已跳过

提示：执行 git commit 即可自动填充 commit message
```

## 高级功能

- 分支冲突处理、钩子管理细节：参见 [REFERENCE.md](REFERENCE.md)
