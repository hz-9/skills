---
name: pnpm-changeset-workflow
description: 继承 git-workflow-enhanced 的完整发布工作流，并额外基于 commit message 生成 pnpm changeset 文件。当用户在 nx + changeset monorepo 中需要创建分支+changeset、开始新功能并生成变更记录、或完成"分支+提交+changeset"全流程时使用。
---

# pnpm Changeset 工作流

继承 [git-workflow-enhanced](../git-workflow-enhanced/SKILL.md) 的完整发布工作流，额外增加 changeset 文件生成步骤。仅适用于 nx + pnpm changeset 的 monorepo 仓库。

## Overview

本技能是 git-workflow-enhanced 的扩展版本。在 git-workflow-enhanced 完成分支策略、commit message 生成、分支创建、hook 管理和推送的完整流程基础上，额外为每个受影响的包生成独立的 changeset 文件。若不在 nx + changeset 仓库中，使用 [git-workflow-enhanced](../git-workflow-enhanced/SKILL.md)。

## Definitions

- **changeset 文件**：位于 `.changeset/` 目录下的 Markdown 文件，描述包变更类型和内容，用于 changeset 发布流程自动计算版本号和生成 changelog
- **受影响的包**：`packages/*/` 目录下、本次变更涉及到的包，通过 `git diff` 文件路径和每个包的 `package.json` 中的 `name` 字段确定

## Prerequisites

- 与 [git-workflow-enhanced](../git-workflow-enhanced/SKILL.md) 的 Prerequisites 一致
- 项目启用了 pnpm changeset（存在 `.changeset/` 目录和 `@changesets/cli`）
- 项目采用 nx + changeset 的 monorepo 结构

## Workflow

遵循 [git-workflow-enhanced](../git-workflow-enhanced/SKILL.md) 的全部步骤，在 Step 2（生成 commit message）之后、Step 5（提交）之前，插入 changeset 文件生成步骤。

```text
Task Progress:
- [ ] Step 1: 确定分支策略（同 git-workflow-enhanced）
- [ ] Step 2: 生成 commit message（调用 git-commit-helper）
- [ ] Step 3: 提炼分支名并创建分支（同 git-workflow-enhanced）
- [ ] Step 4: 检测并管理 prepare-commit-msg hook（同 git-workflow-enhanced）
- [ ] Step 5: 生成 changeset 文件（本技能扩展）
- [ ] Step 6: 提交（含 changeset 文件）
- [ ] Step 7: 推送（同 git-workflow-enhanced）
- [ ] Step 8: 生成 PR 链接（同 git-workflow-enhanced）
```

### Step 1-4: 基础流程

执行 [git-workflow-enhanced](../git-workflow-enhanced/SKILL.md) 的 Step 1 至 Step 4，完成分支策略决策、commit message 生成、分支创建和 hook 管理。

### Step 5: 生成 changeset 文件

基于 Step 2 生成的 commit message，为每个受影响的包创建独立 `.changeset/<random-name>.md` 文件。

#### 分析受影响的包

```bash
git diff --staged --name-only
```

从变更文件路径中识别 `packages/<name>/` 目录，获取每个包 `package.json` 中的 `name` 字段。

#### 版本类型映射

根据 commit message 的 type 确定 changeset 版本类型：

| Commit Type | Changeset 版本 | 说明 |
|------------|---------------|------|
| feat | `minor` | 新功能 |
| fix | `patch` | Bug 修复 |
| 含 `BREAKING CHANGE:` 或 `!` | `major` | 破坏性变更 |
| refactor / perf / docs / test / build / ci / chore | `patch` | 其他变更 |

#### 生成 changeset 文件

为每个受影响的包创建独立文件，文件名使用随机英文形容词+名词组合（确保唯一，避免手动命名冲突）：

```markdown
---
'@scope/package-name': minor
---

feat: add xxx support for something
```

- Summary 使用 Step 2 生成的 commit message 的 subject 部分
- 若多个包受影响、版本类型不同，为每个包创建独立 changeset 文件
- 文件路径：`.changeset/<random-adjective-noun>.md`

### Step 6: 提交

暂存 changeset 文件并提交：

```bash
git add .changeset/
git commit -m "<message>"
```

### Step 7-8: 推送与 PR

执行 [git-workflow-enhanced](../git-workflow-enhanced/SKILL.md) 的 Step 6 至 Step 7，完成推送和 PR 链接生成。

## Rules

- 遵守 [git-workflow-enhanced](../git-workflow-enhanced/SKILL.md) 的全部 Rules
- changeset 文件名必须随机唯一，避免手动命名冲突
- changeset 版本类型必须与 commit message 的 type 严格对应
- 未暂存变更需提醒用户是否一并提交

## Examples

```
用户> /git-ship

AI > 检测到 nx + changeset monorepo，触发 pnpm-changeset-workflow
     当前分支：main（保护分支）
     变更：
       packages/auth/src/login.ts
       packages/auth/src/signup.ts
       packages/core/src/config.ts
     
     受影响包：@scope/auth (feat→minor), @scope/core (feat→minor)
     
     正在创建功能分支...

AI > ✅ 工作流完成

     分支: feat/add-user-authentication
     Commit: feat(auth): add user authentication with JWT
     Changeset:
       .changeset/curly-boxes-type.md → @scope/auth: minor
       .changeset/flat-tigers-run.md → @scope/core: minor
     已推送至: origin/feat/add-user-authentication
     PR: https://github.com/org/repo/pull/new/feat/...
```

## Review List

- [ ] 遵守 [git-workflow-enhanced](../git-workflow-enhanced/SKILL.md) 的 Review List
- [ ] changeset 文件为每个受影响包独立生成
- [ ] 版本类型与 commit type 正确映射
- [ ] changeset 文件名随机唯一

## References

- 基础工作流：参见 [git-workflow-enhanced](../git-workflow-enhanced/SKILL.md)
- Commit message 生成：参见 [git-commit-helper](../git-commit-helper/SKILL.md)
