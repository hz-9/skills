---
name: git-commit-helper
description: 遵循 Conventional Commits 规范生成 Git commit message。当用户请求帮助编写 commit message、查看暂存变更，或提及 “commit” 或 “commit message” 时使用。
---

# Git Commit Helper

## Overview

智能生成遵循 Conventional Commits 规范的 Git commit message。生成的提交信息全部使用英文。

## Definitions

- <a id="Conventional Commits"></a>**Conventional Commits**：一种基于提交信息的轻量级约定，通过结构化元素（类型、范围、描述等）传达变更意图。
- <a id="Commit Message"></a>**Commit Message**：包含 subject、body 和 footer 的 Git 提交信息，遵循 `<type>[scope][!]: <description>` 格式。
- <a id="Type"></a>**Type（类型）**：Commit 的前缀名词，表示变更类别。合法值包括 feat、fix、docs、style、refactor、perf、test、build、ci、chore、revert 等。
- <a id="Scope"></a>**Scope（范围）**：可选参数，使用括号包裹在 type 之后，表示变更影响的模块/位置，例如 `feat(auth):`。
- <a id="Subject"></a>**Subject**：Commit message 的第一行，格式为 `<type>[scope][!]: <description>`，不超过 50 字符。
- <a id="Body"></a>**Body（正文）**：Subject 后空一行开始的详细说明，阐述“做什么”和“为什么”。
- <a id="Footer"></a>**Footer（脚注）**：可选部分，位于 Body 之后，用于标记破坏性变更（BREAKING CHANGE:）或关联 Issue（如 Closes #123）。
- <a id="BREAKING-CHANGE"></a>**BREAKING CHANGE（破坏性变更）**：导致 API 或行为不兼容的变更，以 `!` 标记在 type/scope 之后，或以 `BREAKING CHANGE:` 开始脚注。
- <a id="Description"></a>**Description（描述）**：Subject 中冒号后的简短说明，以小写动词开头，使用一般现在时，不包含结尾句号。
- <a id="是否对话-Diff-路径"></a>**是否对话 Diff 路径**：标记当前是否处于对话直接提供 diff 的模式。由步骤 0.2 在对话 diff 校验通过时设置为 true，跳过步骤 0.3~0.6 及步骤 1~2，直接进入步骤 3。
- <a id="暂存区"></a>**暂存区（Staging Area）**：执行 `git add` 后变更暂存的位置，通过 `git diff --staged` 查看。
- <a id="工作区"></a>**工作区（Working Directory）**：当前工作目录中已跟踪文件的修改状态，通过 `git diff` 查看。
- <a id="根提交"></a>**根提交（Root Commit）**：仓库中的第一个 commit，无父提交。此类 commit 使用 `git show` 而非 `git diff` 查看变更。
- <a id="未跟踪文件"></a>**未跟踪文件（Untracked File）**：Git 尚未跟踪的新文件，不包含在任何 `git diff` 输出中，需通过 `git status --short` 检测。
- <a id="分支范围"></a>**分支范围（Branch Range）**：用于对比两个分支/commit 之间差异的 Git 范围表达式（如 `main..feature`），通过 `git log <range> -p` 获取变更。

## Prerequisites

- **标准路径**（通过 Git 获取变更）：
  - Git 2.0+
  - 当前在 Git 仓库目录中
  - 存在可供分析的 Git 变更（暂存区变更、工作区变更、指定 commit 或分支范围）
  - `scripts/check-env.sh` 可执行（`bash scripts/check-env.sh` 能正常运行）
  - `jq`（JSON 处理工具，check-env.sh 依赖此命令）
- **对话 Diff 路径**（用户直接在对话中提供 diff）：
  - 无需 Git 环境，跳过 Git 相关检查
  - 期望格式为标准的 unified diff 格式，或其他可分析的变更描述
  - 若格式无法解析，应提示用户提供标准 diff 格式

## Workflow

0. **前置检查** — 确保 commit 环境已就绪；
  0.1 初始化全局变量 [是否对话 Diff 路径](#是否对话-Diff-路径)：
      - 判断用户是否已在对话中提供 diff 内容：
        - 是 -> 设置 [是否对话 Diff 路径](#是否对话-Diff-路径) 为 true；
        - 否 -> 设置 [是否对话 Diff 路径](#是否对话-Diff-路径) 为 false；
  0.2 判断 [是否对话 Diff 路径](#是否对话-Diff-路径) 是否为 true：
      - 是 -> 校验 diff 格式是否可解析：
        - 是 -> 跳过步骤 0.3 及步骤 1~2，直接进入步骤 3；
        - 否 -> 告知用户 diff 格式无法解析，通过 AskUserQuestion 提供选项，阻塞等待用户选择：
          - 切换到 Git 路径 -> 跳转到步骤 0.3，进入 Git 路径检查流程；
          - 取消 -> 终止流程；
      - 否 -> 进入步骤 0.3；
  0.3 执行环境检查（`bash scripts/check-env.sh`）：
    - 判断脚本是否执行成功：
      - 成功 -> 解析 JSON，判断是否包含 "error" 字段：
        - 是 -> 报告脚本错误（如缺少 jq 依赖），终止流程；
        - 否 -> 逐项报告检查结果：
      - "in-git-repo" 未通过 -> 报告"当前不在 Git 仓库中"，终止流程；
      - "git-version" 未通过 -> 提示升级 Git 至 2.0+，终止流程；
      - "conflict-state" 未通过 -> 报告具体冲突类型（合并/拣选/回滚/变基），终止流程；
      - "has-changes" 未通过 -> 告知用户无变更可分析，终止流程；
  0.4 判断是否存在可供分析的 Git 变更（0.3 的 has-changes 是否通过/commit/分支范围）：
    - 是 -> 下一步（进入步骤 1）；
    - 否 -> 告知用户无变更可分析，终止流程；

1. **判断输入来源** — 确定变更信息来源；
   1.1 判断用户输入的类型：
       - 用户指明了变更来源意图（暂存区/最近 commit/分支范围等） -> 直接映射到对应场景，进入步骤 2；
       - 用户提供了 commit id 或分支范围 -> 进入步骤 2；
       - 用户未提供任何变更信息，但暂存区内存在内容 -> 场景 A，进入步骤 2；
       - 用户未提供任何变更信息 -> 通过 AskUserQuestion 提供选项，阻塞等待用户选择：
         - 暂存区 -> 场景 A，进入步骤 2；
         - 指定 commit -> 通过 AskUserQuestion 获取用户输入的 commit ID（留空则默认 HEAD），阻塞等待用户输入；用户输入后 -> 场景 B，进入步骤 2；
         - 分支范围 -> 场景 C，进入步骤 2（分支范围将作为 squash 式单一 commit message 生成）；

2. **获取 diff** — 根据输入来源获取变更内容；
   2.1 根据步骤 1 的判定结果映射到对应场景（“最近 commit”归入场景 B，commit 为 HEAD）：
       - 场景 A（暂存区）：执行 `git diff --staged`：
         - 结果为空 -> 告知用户当前没有暂存变更，终止流程；
         - 结果非空 -> 进入步骤 2.2；
       - 场景 B（单个 commit）：执行 `git rev-list --parents -n 1 <commit>` 检测根提交：
         - 命令执行失败（commit 不存在或无效） -> 告知用户该 commit 不存在，引导用户检查后重试，终止流程；
         - 结果仅含一个 commit hash（无父提交） -> 根提交，改用 `git show <commit>`；
         - 结果包含多个 commit hash（有父提交） -> 执行 `git diff <commit>^!`；
         - 进入步骤 2.2；
       - 场景 C（分支范围）：执行 `git log <range> -p`：
         - 命令执行失败（范围无效） -> 告知用户该分支范围无效，引导用户检查后重试，终止流程；
         - 返回结果为空（范围内无差异变更） -> 告知用户选定范围内无变更差异，引导用户检查范围后重试，终止流程；
         - 进入步骤 2.2；
   2.2 完成获取后进入步骤 3；

3. **分析变更** — 分析 diff 内容并确定 commit 类型，生成候选方案；
   3.0 打开 [conventional-commits.md](references/conventional-commits.md) 确定适用的 commit 类型，分析变更影响范围和核心意图；
   3.1 按文件类型分别处理：
       - 非二进制文件 -> 正常分析变更内容；
       - 二进制文件 -> 仅标注文件名及变更类型，不分析内容；
   3.2 输出 [分析变更内容](#分析变更内容)；
   3.3 生成候选方案 — 基于分析结果选取 1~3 种合理 type，每种生成一个候选 commit message：
       - 若变更涉及多种性质（如新功能+重构）-> 考虑多个合理 type；
       - 若变更性质明确单一 -> 只生成 1 个候选；
   3.4 优化候选方案 — 对照 [Review List](#review-list) 逐项检查并优化每个候选方案：
       - **Subject 长度控制**：强制 subject ≤ 50 字符，超长则精简描述直至符合要求；
       - **格式规范**：校验 type、scope、`!` 标记格式正确；
       - **内容规范**：确认采用英文、保持简洁、无 `[skip ci]` 等；
   3.5 输出 **提交信息多方案输出**（参见 [提交信息多方案输出示例](#提交信息多方案输出示例)）

4. **确认提交信息** — 向用户展示候选方案并完成交互确认（4.1 4.2 4.3 应作为一组 AskUserQuestion 进行询问）；
    4.1 用户选择 — 展示候选方案供用户选择：
        - 通过 AskUserQuestion 提供选项，阻塞等待用户选择：
          - 方案 1 -> 记录选择内容，执行下一步；
          - 方案 2（若存在） -> 记录选择内容，执行下一步；
          - 方案 3（若存在） -> 记录选择内容，执行下一步；
    4.2 破坏性变更确认 — 通过 AskUserQuestion 提供选项，阻塞等待用户选择：
        - 是 -> 记录选择内容，执行下一步；
        - 否 -> 记录选择内容，执行下一步；
    4.3 关联 Issue — 询问用户是否需要关联 Issue；
        - 是 -> 暂停任务，由用户输入 Issue 编号（如 `#123`），用户输出后，执行下一步；
        - 否 -> 记录选择内容，执行下一步；
    4.4 方案优化 - 基于 4.2、4.3 的选择，更新候选信息；
    4.5 输出用户已确认的选择内容（以 [用户已确认信息汇总示例](#用户已确认信息汇总示例) 格式输出）；

5. **复核检查** — 对照 [Review List](#review-list)，确认提交信息内容；
  - 判断 Review List 是否有内容：
    - 否 -> 直接进入步骤 6；
    - 是 -> 下一步；
  - 依次判断 [Review List](#review-list) 中每个检查项，是否通过（须逐项输出全部检查项结果，不得以缩写形式跳过）：
    - 是 -> 继续下一个检查项；
    - 否 -> 记录失败检查项，继续下一个检查项；
  - 判断是否有任一检查失败：
    - 是 -> 引导用户手动处理，终止流程；
    - 否 -> 进入步骤 6；（参见 [复核检查示例](#复核检查示例)）
6. **成果输出** — 输出执行摘要，告知完成；
   6.1 输出最终 commit message 及完整结构化日志（含前置信息、候选方案、确认环节、最终输出等维度的汇总表格）；
   6.2 告知用户执行完成；

## Rules

- **格式规范**
  - 严格遵循 [conventional-commits.md](references/conventional-commits.md) 中的格式定义：`<类型>[可选 范围][!]: <描述>`；
  - [Subject](#Subject) 保持在 50 字符以内；
  - 使用动词开头（add, implement, correct, refactor 等），以小写动词开头，使用一般现在时；
  - [Description](#Description) 结尾不包含句号（.）；
  - 可选 [Scope](#Scope) 使用括号包裹在 [Type](#Type) 之后，如 `feat(auth):`；
  - [Body](#Body) 说明“做什么”和“为什么”；
  - [Body](#Body) 每行不超过 72 字符；
  - 提交信息，全部采用英文
- **类型规范**
  - [Type](#Type) 使用 [conventional-commits.md](references/conventional-commits.md) “类型”对照表中的合法值：feat（新功能）、fix（修复）、docs（文档）、style（格式）、refactor（重构）、perf（性能）、test（测试）、build（构建）、ci（持续集成）、chore（杂项）、revert（回滚）；
- **内容规范**
  - 采用英文的提交信息；
  - 保持简洁，不过度生成内容；
  - 禁止包含 `[skip ci]` 等 CI 跳过标记；
  - 涉及二进制文件变更时，仅标注文件名及变更类型，不分析内容；
  - 破坏性变更以 [BREAKING CHANGE](#BREAKING-CHANGE) 或 `!` 标记；
  - `!` 标记必须位于 [Type](#Type)/[Scope](#Scope) 之后、冒号之前；
  - 关联相关 Issue（如有）；
  - **冲突处理**：破坏性变更标记必须与用户确认一致，当用户回答与候选标记冲突时自动修正（候选含 `!` 但用户说否时移除，候选无 `!` 但用户说是时添加）；
- **行为规范**
  - 所有涉及用户抉择的交互环节（选择候选方案、确认破坏性变更、关联 Issue 等），**必须**使用 `AskUserQuestion` 工具，禁止以纯文本追问代替；将问题与选项结构化传入 AskUserQuestion，每次调用 ≤4 个问题；自然地输入（如 Issue 编号等自由文本）不受此限制；

## Examples

**分析变更内容**<a id="分析变更内容"></a>

```markdown
AI > | 动作     | 非二进制文件 | 二进制文件 |
      |----------|------------|-----------|
      | **汇总** | **5**      | **1**     |
      | 新增     | 2          | 0         |
      | 修改     | 3          | 0         |
      | 重命名   | 0          | 0         |
      | 删除     | 0          | 1         |
      | 权限变更 | 0          | 0         |
```

<a id="提交信息多方案输出示例"></a>**提交信息多方案输出**

```markdown
AI > 基于分析结果，生成以下候选方案：
```

```markdown
--- 方案 1 ---
feat(auth): add user login and role management

- Implement JWT authentication for user login
- Add role-based access control for admin endpoints
```

```markdown
--- 方案 2 ---
feat(auth)!: add user login and role management

BREAKING CHANGE: restructured authentication system

- Implement JWT authentication for user login
- Add role-based access control for admin endpoints
```

<a id="用户已确认信息汇总示例"></a>**用户已确认信息汇总示例**

```markdown
AI > 已确认您的全部选择，准备进入复核检查：
     - 选定方案：方案 2 — feat(auth): add user login and role management
     - 破坏性变更：是（独立确认，候选含 ! 标记，已保留）
     - 关联 Issue：无
```

### <a id="复核检查示例"></a>复核检查示例

```markdown
AI > 进入复核检查，Review List 包含 13 个检查项，开始逐项验收：

**格式检查**
  - 🟩 subject 不超过 50 字符
  - 🟩 description 以小写动词开头（add, implement 等），使用一般现在时

**类型规范检查**
  - 🟩 type 使用合法值

**内容检查**
  - 🟩 提交信息采用英文
  - 🟩 二进制文件已正确处理

**变更标记检查**
  - 🟩 破坏性变更已正确标记（`BREAKING CHANGE:` 或 `!`）
  - 🟩 关联 Issue 已正确引用

（此处仅展示各组代表性通过项；AI 运行时将逐项输出全部 13 个检查项结果）

**！！！以下检查项未通过！！！**
  - 🟥 description 以小写动词开头（以名词开头，应为小写动词）
    未通过检查，根据未通过项类型返回对应环节重新生成。
```

### <a id="成果输出示例"></a>成果输出示例

>  成果输出，应该输出代码框内部的信息；

```markdown
【前置信息】
| 输入来源   | 文件范围                            | 变更分布                |
|------------|-------------------------------------|------------------------|
| 暂存区变更 | 非二进制 5 个 / 二进制 1 个（图片） | 新增 2 / 修改 3 / 删除 0 / 重命名 0 |

【候选方案】
| 候选数量 | 选定方案                               |
|----------|---------------------------------------|
| 2 个     | 方案 1 — feat(auth): add user login… |

【确认环节】
| 破坏性变更       | 关联 Issue                   |
|------------------|------------------------------|
| 否（已确认用户） | #123（Closes #123）          |

【最终提交信息】

feat(auth): add user login and role management

- Implement JWT authentication for user login
- Add role-based access control for admin endpoints

Closes #123
```


## Review List

完成生成后，验证以下内容：

- **格式检查**
  - [ ] 严格遵循 [conventional-commits.md](references/conventional-commits.md) 格式：`<类型>[可选 范围][!]: <描述>`
  - [ ] [Subject](#Subject) 不超过 50 字符
  - [ ] [Description](#Description) 以小写动词开头（add, implement 等），使用一般现在时，结尾不包含句号
  - [ ] [Body](#Body) 说明了“做什么”和“为什么”
  - [ ] [Body](#Body) 每行不超过 72 字符
- **类型规范检查**
  - [ ] [Type](#Type) 使用 [conventional-commits.md](references/conventional-commits.md) 中定义的合法值
- **内容检查**
  - [ ] 提交信息采用英文
  - [ ] 保持简洁，不过度生成
  - [ ] 未包含 `[skip ci]` 等 CI 跳过标记
  - [ ] 二进制文件已正确处理（仅标注文件名及变更类型，未分析内容）
- **变更标记检查**
  - [ ] 破坏性变更已正确标记（[BREAKING CHANGE](#BREAKING-CHANGE) 或 `!`）
  - [ ] `!` 标记位于 [Type](#Type)/[Scope](#Scope) 之后、冒号之前
  - [ ] 关联 Issue（如有）已正确引用
  - [ ] 当用户对破坏性变更的回答与候选标记冲突时，已正确修正标记（添加/移除 `!` 和 `BREAKING CHANGE:`）

## References

- Conventional Commits 规范详情：参见 [conventional-commits.md](references/conventional-commits.md)
