---
name: git-branch-prep
description: 调用 git-commit-helper 生成提交信息 → 提炼分支名 → 通过 AskUserQuestion 确认分支和推送 → 创建 PR 链接。当用户想要开始新功能、创建分支并提交、或需要完成"分析变更→生成分支名+提交信息→生成 PR"全流程时使用。
---

# Git Branch Prep

## Overview

调用 [git-commit-helper](../git-commit-helper/SKILL.md) 基于暂存变更生成 commit message → 提炼分支名 → 通过 AskUserQuestion 询问用户确认分支选择和推送意愿 → 执行提交/推送 → 生成 PR 链接。

## Definitions

- <a id="是否在保护分支上"></a>**是否在保护分支上**：标记当前分支是否为保护分支或 detached HEAD 源自保护分支（参见 [保护分支处理](references/protected-branch.md)）。由步骤 3.1 在分支状态检查时判定，用于决定是否强制创建新分支。

## Prerequisites

- **标准路径**（通过 Git 获取变更）：
  - Git 2.0+
  - 当前在 Git 仓库目录中
  - 存在可供分析的 Git 变更（暂存区变更、工作区变更、指定 commit 或分支范围）

## Workflow

0. **前置检查** — 确保环境已就绪；
  0.1 判断是否在 Git 仓库中：
    - 是 -> 下一步；
    - 否 -> 报告"当前不在 Git 仓库中"，终止流程；
  0.2 判断 Git 版本是否 >= 2.0：
    - 是 -> 下一步；
    - 否 -> 提示升级 Git，终止流程；
  0.3 检测并处理游离 HEAD：
    - 执行 `git branch --show-current`：
      - 返回空（游离状态）-> 基于当前 commit 推断源头分支（参见 [保护分支处理](references/protected-branch.md#detached-head-检测)）：
        - 推断成功 -> 切换到该分支（`git checkout <branch>`），执行后进入下一步；
        - 推断失败或切换失败 -> 报告异常原因，终止流程；
      - 返回非空（已关联分支）-> 下一步；
  0.4 检测是否处于冲突中：
    - 是否处于合并冲突中（检测 `$(git rev-parse --git-dir)/MERGE_MSG` 是否存在）：
      - 是 -> 告知用户处于合并冲突中，终止流程；
      - 否 -> 下一步；
    - 是否处于拣选冲突中（检测 `$(git rev-parse --git-dir)/CHERRY_PICK_HEAD` 是否存在）：
      - 是 -> 告知用户处于拣选冲突中，终止流程；
      - 否 -> 下一步；
    - 是否处于回滚冲突中（检测 `$(git rev-parse --git-dir)/REVERT_HEAD` 是否存在）：
      - 是 -> 告知用户处于回滚冲突中，终止流程；
      - 否 -> 下一步；
    - 是否处于变基冲突中（检测 `$(git rev-parse --git-dir)/rebase-merge/REBASE_HEAD` 或 `$(git rev-parse --git-dir)/rebase-apply/` 是否存在）：
      - 是 -> 告知用户处于变基冲突中，终止流程；
      - 否 -> 下一步；
  0.5 检测工作区是否存在未暂存或未跟踪的变更（通过 `git status --porcelain` 判断）：
    - 是（存在未暂存/未跟踪变更） -> 通过 AskUserQuestion 提供选项，阻塞等待用户选择：
      - 是的，先执行 `git add .` -> 执行 `git add .`，执行后进入步骤 0.6；
      - 否，不暂存 -> 终止流程；
    - 否（工作区干净） -> 进入步骤 0.6；
  0.6 判断是否存在可供分析的 Git 变更（暂存区/工作区/commit/分支范围）：
    - 是 -> 下一步（进入步骤 1）；
    - 否 -> 告知用户无变更可分析，终止流程；

1. **生成 commit message** — 调用 git-commit-helper 执行完整提交信息生成流程；
   1.1 暂存所有变更：`git add -A`；
   1.2 调用 [git-commit-helper](../git-commit-helper/SKILL.md) 执行其完整工作流：
       - 完全遵循 git-commit-helper 内部的全部交互逻辑和分支决策；
       - **不得跳过 git-commit-helper 的任何 AskUserQuestion 交互步骤**；
       - 若 git-commit-helper 触发 AskUserQuestion，必须阻塞等待用户选择；
   1.3 捕获 git-commit-helper 的最终输出（commit message 及结构化日志）；

2. **提炼分支名** — 遵守 [分支名称提炼规则](references/branch-name-rules.md)，从 commit message 提取分支名称；

3. **询问分支与推送意愿** — 通过 AskUserQuestion 确认用户决策；
   3.1 确认当前分支 [是否在保护分支上](#是否在保护分支上)：
       - 是 -> 仅提供选项：创建新分支 `<derived-branch-name>`，记录用户决策；
       - 否 -> 通过 AskUserQuestion 提供选项：
         - 在当前分支 `<current-branch>` 上提交 -> 记录用户决策（进入 4.1 分支处理时，选择 “保持当前分支”）；
         - 创建新分支 `<derived-branch-name>` -> 记录用户决策（进入 4.1 分支处理 — 选择 “创建新分支”）；
   3.2 通过 AskUserQuestion 询问是否推送：
       - 提交并推送，生成 PR 链接 -> 记录用户决策（进入 4.3 推送流程是，进行推送）；
       - 本地提交，仅生成 PR 链接 -> 记录用户决策（当 4.2 执行过后，跳过 4.3，进入 4.4 记录 PR 命令）；

4. **执行决策** — 根据步骤 3 的用户选择执行操作；
   4.1 分支处理（根据步骤 3.1 的决策）：
       - 若选择创建新分支 -> `git checkout -b <derived-branch-name> 2>/dev/null || git checkout <derived-branch-name>`，执行后进入下一步；
       - 若选择在当前分支提交 -> 保持当前分支，进入下一步；
   4.2 提交：
       - 执行提交：`git commit -m "<message>"`；
       - 验证提交是否成功（`git status --porcelain` 确认工作区干净）：
         - 成功 -> 进入下一步；
         - 失败 -> 告知用户提交失败原因，终止流程；
   4.3 推送（根据步骤 3.2 的决策，若用户选择推送）：
       - 检查远端分支是否存在：`git ls-remote --exit-code origin "<branch>" 2>/dev/null`：
         - 存在（退出码 0）-> 刷新本地远程跟踪分支：`git fetch origin "<branch>"`，检查本地是否落后于远端：`git rev-list --count HEAD..origin/"<branch>"`：
           - 落后（计数 > 0）-> 执行 rebase：`git rebase origin/"<branch>"`（若冲突则暂停并告知用户，参见 [错误处理](references/error-handling.md)）；
           - 未落后 -> 下一步；
         - 不存在 -> 下一步；
       - 执行推送：`git push -u origin <branch>`；
       - 验证推送是否成功：
         - 成功 -> 从输出中提取 PR 链接（进入 4.4）；
         - 失败 -> 告知用户推送失败原因，记录推送命令到最终输出日志（进入 4.4）；
   4.4 记录 PR 信息（基于 [PR 链接规范](references/pr-link-standard.md)）：
       - 若已推送成功 -> 优先从推送输出中正则匹配 `remote:.*(https://github.com/.*/pull/new/.*)` 提取 PR 链接；若输出中无 PR 链接，则通过 `git remote get-url origin` 提取仓库信息，按 [PR 链接规范](references/pr-link-standard.md#基于远端地址构建-pr-链接) 根据 origin 实际存在的合并目标分支动态构建 PR 链接；
       - 若未推送或推送失败 -> 通过 `git remote get-url origin` 提取仓库信息，按 [PR 链接规范](references/pr-link-standard.md#基于远端地址构建-pr-链接) 根据 origin 实际存在的分支动态构建 PR 链接，连同推送命令一并记录到最终输出日志；

5. **复核检查** — 对照 [Review List](#review-list)，确认执行结果；
   5.1 判断 Review List 是否有内容：
       - 否 -> 直接进入步骤 6（成果输出）；
       - 是 -> 下一步；
   5.2 逐项检查 Review List 中的每一项：
       - 全部通过 -> 进入 5.3；
       - 存在未通过项 -> 记录失败项，终止流程；
   5.3 输出最终信息摘要（含分支名、commit message、推送状态、PR 链接等维度），进入步骤 6；

6. **成果输出** — 输出执行摘要，告知完成；
   输出结构化摘要（具体格式请参考"成果输出示例"），含以下信息：
   - 分支名、commit message；
   - 推送状态；
   - PR 链接（根据 origin 存在的分支动态生成合并目标链接）；
   - 待执行命令（若有）；

## Rules

- commit message 必须采用英文，保持简洁，禁止包含 `[skip ci]`；
- 分支命名体现变更本质（feat/refactor/docs 等），避免泛化命名（如 `new-branch`）；
- PR 链接优先从 `git push` 输出提取，若无法获取则基于远端地址构建，合并目标根据 origin 实际存在的分支动态生成；

## Examples

### 对话交互示例

**创建新分支**

```markdown
用户> /git-ship

AI > ⏳ Step 1: 生成 commit message...
     正在调用 git-commit-helper 分析变更...
     [完整遵循 git-commit-helper 内部交互流程]
     最终 commit message：feat(auth): add user authentication with JWT

     ⏳ Step 2: 提炼分支名...
     分支名：feat/add-user-authentication

     ⏳ Step 3: 询问决策...
     [AskUserQuestion]
     Q1: 当前分支 main（保护分支），选项：
     - 创建新分支 feat/add-user-authentication
     Q2: 是否推送？
     - 提交并推送，生成 PR 链接
     - 本地提交，仅生成 PR 链接

用户> 创建新分支，提交并推送

AI > ✅ Step 4: 执行决策
     4.1 → 创建新分支 feat/add-user-authentication
     4.2 → 提交完成
     4.3 → 已推送至 origin/feat/add-user-authentication
     4.4 → PR 链接已提取
```

**当前分支提交**

```markdown
用户> /git-ship

AI > ⏳ Step 1: 生成 commit message...
     当前分支：fix/typo-in-readme（非保护分支）
     正在调用 git-commit-helper 分析变更...
     最终 commit message：docs: fix typo in README

     ⏳ Step 2: 提炼分支名...
     分支名：docs/fix-typo-in-readme

     ⏳ Step 3: 询问决策...
     [AskUserQuestion]
     Q1: 当前分支 fix/typo-in-readme（非保护分支），选项：
     - 在当前分支 fix/typo-in-readme 上提交
     - 创建新分支 docs/fix-typo-in-readme
     Q2: 是否推送？
     - 提交并推送，生成 PR 链接
     - 本地提交，仅生成 PR 链接

用户> 当前分支，本地提交

AI > ✅ Step 4: 执行决策
     4.1 → 保持当前分支 fix/typo-in-readme
     4.2 → 提交完成
```

**推送**

```markdown
用户> /git-ship

AI > ⏳ Step 1: 生成 commit message...
     当前分支：feat/update-login（非保护分支）
     正在调用 git-commit-helper 分析变更...
     最终 commit message：feat(auth): enhance login validation

     ⏳ Step 2: 提炼分支名...
     分支名：feat/enhance-login-validation

     ⏳ Step 3: 询问决策...
     [AskUserQuestion]
     Q1: 当前分支 feat/update-login（非保护分支），选项：
     - 在当前分支 feat/update-login 上提交
     - 创建新分支 feat/enhance-login-validation
     Q2: 是否推送？
     - 提交并推送，生成 PR 链接
     - 本地提交，仅生成 PR 链接

用户> 当前分支，提交并推送

AI > ✅ Step 4: 执行决策
     4.1 → 保持当前分支 feat/update-login
     4.2 → 提交完成
     4.3 → 检测远端分支存在，同步后推送
     4.4 → PR 链接已提取
```

### 复核检查示例

```markdown
AI > 进入复核检查，Review List 包含 10 个检查项，开始逐项验收：

**Commit Message 检查**
  - 🟩 commit message 符合 Conventional Commits 规范
  - 🟩 采用英文，保持简洁

**分支名检查**
  - 🟩 分支名格式正确

**安全规范检查**
  - 🟩 保护分支未被直接提交

**PR 链接检查**
  - 🟩 PR 链接已正确生成

（此处仅展示各组代表性通过项；AI 运行时将逐项输出全部 10 个检查项结果）

✅ 全部通过，进入成果输出。
```

### 成果输出示例

```markdown
**摘要**
| 项           | 内容                                     |
|--------------|------------------------------------------|
| 分支         | feat/add-user-authentication              |
| Commit       | feat(auth): add user authentication with JWT |
| 推送状态     | 已推送/本地推送                                    |
| 推送命令   | git push -u origin fix/typo-in-readme / '-'     |

**PR**

| 合并目标 | PR 链接格式 | 说明 |
|---------|-------------|------|
| dev | `https://github.com/{OWNER_REPO}/compare/dev...{branch}?expand=1` | 日常开发合入 |
| stage | `https://github.com/{OWNER_REPO}/compare/stage...{branch}?expand=1` | 预发布环境合入 |
| master | `https://github.com/{OWNER_REPO}/compare/master...{branch}?expand=1` | 生产环境合入 |
```

> 为当前分支 `<branch>` 生成合并分支的 PR 链接，origin 存在以下哪些分支，才显示对应行。

## Review List

- **Commit Message 检查**
  - [ ] commit message 符合 Conventional Commits 规范
  - [ ] 采用英文，保持简洁
  - [ ] 未包含 `[skip ci]` 等 CI 跳过标记
- **分支名检查**
  - [ ] 分支名遵循 `<type>/<kebab-description>` 格式，长度 ≤ 50 字符
  - [ ] 体现变更本质（feat/refactor/docs 等），避免泛化命名
- **安全规范检查**
  - [ ] 保护分支未被直接提交
- **PR 链接检查**
  - [ ] PR 链接已正确生成（优先从推送输出提取，否则基于远端地址构建）
  - [ ] PR 链接覆盖 origin 中实际存在的合并目标分支
- **交互完整性检查**
  - [ ] 所有用户抉择环节已使用 AskUserQuestion 阻塞等待用户选择
  - [ ] 错误场景均已妥善处理（分支已存在、无效变更、rebase 冲突等）

## References

- [分支名称提炼细则](references/branch-name-rules.md)
- [保护分支处理](references/protected-branch.md)
- [错误处理](references/error-handling.md)
- [PR 链接规范](references/pr-link-standard.md)
- Commit message 生成：参见 [git-commit-helper](../git-commit-helper/SKILL.md)
- Conventional Commits 规范：参见 [git-commit-helper/references/conventional-commits.md](../git-commit-helper/references/conventional-commits.md)
