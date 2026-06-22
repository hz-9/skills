---
name: git-branch-prep
description: Call git-commit-helper to generate commit message → derive branch name → confirm branch and push via AskUserQuestion → create PR link. Use when the user wants to start a new feature, create a branch and commit, or needs to complete the full workflow of "analyze changes → generate branch name + commit message → generate PR".
---

# Git Branch Prep

## Overview

Call [git-commit-helper](../git-commit-helper/SKILL.md) to generate a commit message based on staged changes → derive a branch name → ask the user to confirm branch selection and push intent via AskUserQuestion → execute commit/push → generate a PR link.

## Definitions

- <a id="是否在保护分支上"></a>**On Protected Branch**: Indicates whether the current branch is a protected branch or a detached HEAD originating from a protected branch (see [Protected Branch Handling](references/protected-branch.md)). Determined by step 3.1 during branch status check, used to decide whether to force creating a new branch.

## Prerequisites

- **Standard Path** (obtain changes via Git):
  - Git 2.0+
  - Currently in a Git repository directory
  - Git changes available for analysis (staged changes, working tree changes, specified commit, or branch range)

## Workflow

0. **Preflight Check** — Ensure the environment is ready:
  0.1 Check if in a Git repository:
    - Yes -> next step;
    - No -> report "Not currently in a Git repository", terminate flow;
  0.2 Check if Git version >= 2.0:
    - Yes -> next step;
    - No -> prompt to upgrade Git, terminate flow;
  0.3 Detect and handle detached HEAD:
    - Run `git branch --show-current`:
      - Returns empty (detached state) -> infer source branch based on current commit (see [Protected Branch Handling](references/protected-branch.md#detached-head-detection)):
        - Inference successful -> switch to that branch (`git checkout <branch>`), proceed to next step;
        - Inference failed or switch failed -> report the error reason, terminate flow;
      - Returns non-empty (attached to a branch) -> next step;
  0.4 Detect if in a conflict state:
    - Check for merge conflict (check if `$(git rev-parse --git-dir)/MERGE_MSG` exists):
      - Yes -> inform user they are in a merge conflict, terminate flow;
      - No -> next step;
    - Check for cherry-pick conflict (check if `$(git rev-parse --git-dir)/CHERRY_PICK_HEAD` exists):
      - Yes -> inform user they are in a cherry-pick conflict, terminate flow;
      - No -> next step;
    - Check for revert conflict (check if `$(git rev-parse --git-dir)/REVERT_HEAD` exists):
      - Yes -> inform user they are in a revert conflict, terminate flow;
      - No -> next step;
    - Check for rebase conflict (check if `$(git rev-parse --git-dir)/rebase-merge/REBASE_HEAD` or `$(git rev-parse --git-dir)/rebase-apply/` exists):
      - Yes -> inform user they are in a rebase conflict, terminate flow;
      - No -> next step;
  0.5 Check if the working tree has unstaged or untracked changes (via `git status --porcelain`):
    - Yes (unstaged/untracked changes exist) -> provide options via AskUserQuestion, block-wait for user selection:
      - Yes, run `git add .` first -> execute `git add .`, then proceed to step 0.6;
      - No, do not stage -> terminate flow;
    - No (working tree is clean) -> proceed to step 0.6;
  0.6 Check if Git changes are available for analysis (staged/working tree/commit/branch range):
    - Yes -> next step (proceed to step 1);
    - No -> inform user no changes available for analysis, terminate flow;

1. **Generate Commit Message** — Call git-commit-helper to execute the full commit message generation workflow:
   1.1 Stage all changes: `git add -A`;
   1.2 Call [git-commit-helper](../git-commit-helper/SKILL.md) to execute its complete workflow:
       - Fully follow all internal interaction logic and branch decisions of git-commit-helper;
       - **Must not skip any AskUserQuestion interaction steps of git-commit-helper**;
       - If git-commit-helper triggers AskUserQuestion, must block-wait for user selection;
   1.3 Capture the final output of git-commit-helper (commit message and structured logs);

2. **Derive Branch Name** — Follow [Branch Name Derivation Rules](references/branch-name-rules.md) to extract the branch name from the commit message;

3. **Ask Branch and Push Intent** — Confirm user decisions via AskUserQuestion:
   3.1 Determine whether the current branch is [on a protected branch](#是否在保护分支上):
       - Yes -> only provide the option: create new branch `<derived-branch-name>`, record user decision;
       - No -> provide options via AskUserQuestion:
         - Commit on current branch `<current-branch>` -> record user decision (when entering 4.1 branch handling, select "Keep current branch");
         - Create new branch `<derived-branch-name>` -> record user decision (when entering 4.1 branch handling, select "Create new branch");
   3.2 Ask whether to push via AskUserQuestion:
       - Commit and push, generate PR link -> record user decision (when entering 4.3 push flow, proceed with push);
       - Commit locally, only generate PR link -> record user decision (after 4.2 is executed, skip 4.3, proceed to 4.4 record PR command);

4. **Execute Decision** — Perform actions based on user selection from step 3:
   4.1 Branch handling (based on step 3.1 decision):
       - If creating a new branch -> `git checkout -b <derived-branch-name> 2>/dev/null || git checkout <derived-branch-name>`, proceed to next step;
       - If committing on current branch -> keep current branch, proceed to next step;
   4.2 Commit:
       - Execute commit: `git commit -m "<message>"`;
       - Verify commit success (confirm working tree is clean via `git status --porcelain`):
         - Success -> proceed to next step;
         - Failure -> inform user of the commit failure reason, terminate flow;
   4.3 Push (based on step 3.2 decision, if user chose to push):
       - Check if remote branch exists: `git ls-remote --exit-code origin "<branch>" 2>/dev/null`:
         - Exists (exit code 0) -> refresh local remote tracking branch: `git fetch origin "<branch>"`, check if local is behind remote: `git rev-list --count HEAD..origin/"<branch>"`:
           - Behind (count > 0) -> execute rebase: `git rebase origin/"<branch>"` (if conflict, pause and inform user, see [Error Handling](references/error-handling.md));
           - Not behind -> next step;
         - Does not exist -> next step;
       - Execute push: `git push -u origin <branch>`;
       - Verify push success:
         - Success -> extract PR link from output (proceed to 4.4);
         - Failure -> inform user of the push failure reason, record push command in final output log (proceed to 4.4);
   4.4 Record PR info (based on [PR Link Standard](references/pr-link-standard.md)):
       - If push succeeded -> prefer to extract PR link via regex match `remote:.*(https://github.com/.*/pull/new/.*)` from push output; if no PR link in output, extract repo info via `git remote get-url origin` and dynamically build the PR link based on the actual merge target branches existing in origin, following the [PR Link Standard](references/pr-link-standard.md#build-pr-link-based-on-remote-url);
       - If not pushed or push failed -> extract repo info via `git remote get-url origin`, dynamically build the PR link based on the actual branches existing in origin following the [PR Link Standard](references/pr-link-standard.md#build-pr-link-based-on-remote-url), and record it together with the push command in the final output log;

5. **Review Check** — Refer to [Review List](#review-list) to verify the execution result;
   5.1 Check if the Review List has any items:
       - No -> proceed directly to step 6 (output results);
       - Yes -> next step;
   5.2 Check each item in the Review List one by one:
       - All passed -> proceed to 5.3;
       - Any failures -> record failed items, terminate flow;
   5.3 Output final info summary (including branch name, commit message, push status, PR link, etc.), proceed to step 6;

6. **Output Results** — Output execution summary, inform completion;
   Output a structured summary (refer to "Output Example" for specific format), including the following:
   - Branch name, commit message;
   - Push status;
   - PR link (dynamically generate merge target link based on branches existing in origin);
   - Commands to execute (if any);

## Rules

- Commit messages must be in English, keep concise, and must not contain `[skip ci]`;
- Branch naming should reflect the nature of changes (feat/refactor/docs, etc.), avoid generic names (e.g., `new-branch`);
- PR link should be extracted from `git push` output first; if unavailable, build it based on the remote URL. The merge target is dynamically generated based on actual branches existing in origin.

## Examples

### Conversation Interaction Example

**Create New Branch**

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

**Commit on Current Branch**

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

**Push**

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

### Review Check Example

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

### Output Example

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

> Generate the PR link for the merge branch of the current branch `<branch>`. Only display the corresponding row if the branch exists in origin.

## Review List

- **Commit Message Check**
  - [ ] Commit message follows Conventional Commits specification
  - [ ] Uses English, remains concise
  - [ ] Does not contain CI skip markers like `[skip ci]`
- **Branch Name Check**
  - [ ] Branch name follows `<type>/<kebab-description>` format, length ≤ 50 characters
  - [ ] Reflects the nature of changes (feat/refactor/docs, etc.), avoids generic naming
- **Security Check**
  - [ ] Protected branch is not directly committed to
- **PR Link Check**
  - [ ] PR link correctly generated (prefer extracting from push output, otherwise build based on remote URL)
  - [ ] PR link covers merge target branches actually existing in origin
- **Interaction Completeness Check**
  - [ ] All user decision points used AskUserQuestion to block-wait for user selection
  - [ ] All error scenarios properly handled (branch already exists, invalid changes, rebase conflict, etc.)

## References

- [Branch Name Derivation Rules](references/branch-name-rules.md)
- [Protected Branch Handling](references/protected-branch.md)
- [Error Handling](references/error-handling.md)
- [PR Link Standard](references/pr-link-standard.md)
- Commit message generation: see [git-commit-helper](../git-commit-helper/SKILL.md)
- Conventional Commits specification: see [git-commit-helper/references/conventional-commits.md](../git-commit-helper/references/conventional-commits.md)
