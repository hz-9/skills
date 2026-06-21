---
name: git-commit-helper
description: 遵循 Conventional Commits 规范生成 Git commit message。当用户请求帮助编写 commit message、查看暂存变更，或提及 “commit” 或 “commit message” 时使用。
---

# Git Commit Helper

## Overview

智能生成遵循 Conventional Commits 规范的 Git commit message。生成的提交信息全部使用英文。

## Definitions

- <a id="Conventional Commits"></a>**Conventional Commits**：一种基于提交信息的轻量级约定，通过结构化元素（类型、范围、描述等）传达变更意图。
- <a id="Commit Message"></a>**Commit Message**：包含 subject、body 和 footer 的 Git 提交信息，遵循 <type>[scope][!]: <description> 格式。
- <a id="Type"></a>**Type（类型）**：Commit 的前缀名词，表示变更类别。合法值包括 feat、fix、docs、style、refactor、perf、test、build、ci、chore、revert 等。
- <a id="Scope"></a>**Scope（范围）**：可选参数，使用括号包裹在 type 之后，表示变更影响的模块/位置，例如 `feat(auth):`。
- <a id="Subject"></a>**Subject**：Commit message 的第一行，格式为 `<type>[scope][!]: <description>`，不超过 50 字符。
- <a id="Body"></a>**Body（正文）**：Subject 后空一行开始的详细说明，阐述“做了什么”和“为什么”。
- <a id="Footer"></a>**Footer（脚注）**：可选部分，位于 Body 之后，用于标记破坏性变更（BREAKING CHANGE:）或关联 Issue（如 Closes #123）。
- <a id="BREAKING CHANGE"></a>**BREAKING CHANGE（破坏性变更）**：导致 API 或行为不兼容的变更，以 `!` 标记在 type/scope 之后，或以 `BREAKING CHANGE:` 开始脚注。
- <a id="Description"></a>**Description（描述）**：Subject 中冒号后的简短说明，以小写动词开头，使用一般现在时，不包含结尾句号。
- <a id="都不合适重试超限"></a>**是否都不合适重试超限**：标记用户在步骤 4.2 中连续选择“都不合适”的次数是否达到 3 次上限（中间选择其他候选则重置；因步骤 5 退回 4.1 的，计数不清零，继续累计）。
- <a id="复核检查重试超限"></a>**是否复核检查重试超限**：标记步骤 5 的复核检查重试次数是否达到 3 次上限。
- <a id="是否对话-Diff-路径"></a>**是否对话 Diff 路径**：标记当前是否处于对话直接提供 diff 的模式。由步骤 0.2 在对话 diff 校验通过时设置为 true，跳过步骤 0.3~0.6 及步骤 1~2，直接进入步骤 3。

## Prerequisites

- **标准路径**（通过 Git 获取变更）：
  - Git 2.0+
  - 当前在 Git 仓库目录中
  - 存在可供分析的 Git 变更（暂存区变更、工作区变更、指定 commit 或分支范围）
- **对话 Diff 路径**（用户直接在对话中提供 diff）：
  - 无需 Git 环境，跳过 Git 相关检查
  - 期望格式为标准的 unified diff 格式，或其他可分析的变更描述
  - 若格式无法解析，应提示用户提供标准 diff 格式

## Workflow

0. **前置检查** — 确保 commit 环境已就绪；
  0.1 初始化全局变量 [是否都不合适重试超限](#都不合适重试超限)、[是否复核检查重试超限](#复核检查重试超限)、[是否对话 Diff 路径](#是否对话-Diff-路径) 均为 false；
  0.2 判断用户是否已在对话中提供 diff 内容：
    - 是 -> 校验 diff 格式是否可解析：
      - 是 -> 设置 [是否对话 Diff 路径](#是否对话-Diff-路径) 为 true，跳过步骤 0.3~0.6 及步骤 1~2，直接进入步骤 3；
      - 否 -> 通过 AskUserQuestion 提供选项，阻塞等待用户选择：
        - 重新提供标准 unified diff 格式 -> 等待用户重新输入，重复格式校验（最多 3 次）；
          （3 次校验均失败后，“重新提供”选项将不再可用，仅保留“切换到 Git 路径”和“取消”选项）
        - 切换到 Git 路径 -> 跳转到步骤 0.3，进入 Git 路径检查流程；
        - 取消 -> 终止流程；
    - 否 -> 下一步；
  0.3 判断是否在 Git 仓库中：
    - 是 -> 下一步；
    - 否 -> 报告“当前不在 Git 仓库中”，终止流程；
  0.4 判断 Git 版本是否 >= 2.0：
    - 是 -> 下一步；
    - 否 -> 提示升级 Git，终止流程；
  0.5 检测是否处于合并过程中（通过 `test -f "$(git rev-parse --git-dir)/MERGE_MSG"`）：
    - 是 -> 检查冲突是否已解决（通过 `git diff --name-only --diff-filter=U` 检查是否有未解决的冲突文件）：
      - 存在未解决冲突 -> 提示用户先解决冲突后再生成提交信息，终止流程；
      - 冲突已全部解决 -> 生成标准合并提交信息，不套用 Conventional Commits 规范，终止流程；
    - 否 -> 下一步；
  0.6 判断是否存在可供分析的 Git 变更（暂存区/工作区/commit/分支范围）：
    - 是 -> 下一步（进入步骤 1）；
    - 否 -> 告知用户无变更可分析，终止流程；

1. **判断输入来源** — 确定变更信息来源；
   1.1 判断用户输入的类型：
       - 用户指明了变更来源意图（暂存区/工作区/最近 commit/分支范围等） -> 直接映射到对应场景，进入步骤 2；
       - 用户提供了 commit id 或分支范围 -> 进入步骤 2；
       - 用户未提供任何变更信息 -> 通过 AskUserQuestion 提供选项，阻塞等待用户选择：
         - 暂存区或工作区 -> 场景 A，进入步骤 2；
         - 指定 commit -> 场景 B，进入步骤 2；
         - 分支范围 -> 场景 C，进入步骤 2（分支范围将作为 squash 式单一 commit message 生成）；

2. **获取 diff** — 根据输入来源获取变更内容；
   2.1 根据步骤 1 的判定结果映射到对应场景（“最近 commit”归入场景 B，commit 为 HEAD）：
       - 场景 A（暂存区/工作区）：
         - 用户选择“暂存区” -> 执行 `git diff --staged`：
           - 结果为空 -> 告知用户当前没有暂存变更，建议先 `git add` 后重试，终止流程；
           - 结果非空 -> 进入步骤 2.2；
         - 用户选择“工作区” -> 执行 `git diff`，并执行 `git status --short`：
           - 仅有未跟踪文件 -> 建议先 `git add` 后重试，终止流程；
           - 完全无变更 -> 告知用户，终止流程；
           - 有已修改的跟踪文件 -> 进入步骤 2.2；
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

3. **分析变更** — 分析 diff 内容并确定 commit 类型；
   3.0 检查 diff 行数（无论来源是 Git 还是对话）：
       - diff 行数超过 2000 行 -> 预警用户变更量较大，建议缩小范围后重试，或继续分析关键变更摘要；
       - diff 行数未超过 2000 行 -> 下一步；
   3.1 打开 [conventional-commits.md](references/conventional-commits.md) 确定适用的 commit 类型，分析变更影响范围和核心意图；
   3.2 按文件类型分别处理：
       - 非二进制文件 -> 正常分析变更内容；
       - 二进制文件 -> 仅标注文件名及变更类型，不分析内容；
   3.3 输出变更分析汇总表（按非二进制/二进制文件统计新增/修改/删除/重命名/权限变更数量），进入步骤 4；

4. **生成 commit message** — 生成候选方案并确认最终输出；
   4.1 生成候选方案 — 基于分析结果选取 1~3 种合理 type，每种生成一个候选 commit message：
       - 若变更涉及多种性质（如新功能+重构）-> 考虑多个合理 type；
       - 若变更性质明确单一 -> 只生成 1 个候选；
       - 每个候选严格遵循 [conventional-commits.md](references/conventional-commits.md) 规范格式；
   4.2 用户选择 — 选择提交信息：
       - 按照 **多方案提交信息输出** 输出提交信息
       - 通过 AskUserQuestion 提供选项，阻塞等待用户选择：
         - 方案 1 -> 进入 4.3；
         - 方案 2 -> 进入 4.3 （若存在的话）；
         - 方案 3 -> 进入 4.3 （若存在的话）；
   4.3 破坏性变更确认 — 判断候选是否包含破坏性变更标记（`!` 或 `BREAKING CHANGE:`）：
       - 是 -> 通过 AskUserQuestion 提供选项，阻塞等待用户选择：
         - 是，确实是破坏性变更 -> 保留标记，进入 4.4；
         - 否，移除破坏性标记 -> 移除标记，进入 4.4；
       - 否 -> 进入 4.4；
   4.4 关联 Issue — 询问用户是否需要关联 Issue；
       - 通过 AskUserQuestion 提供选项，阻塞等待用户选择：
         - 是，关联 Issue -> 由用户输入 Issue 编号（如 `#123`），补充到 footer；
         - 否，不关联 -> 跳过；
   4.5 汇总用户已确认的选择（选定方案、破坏性变更标记、关联 Issue），进入步骤 5；

5. **复核检查** — 对照 [Review List](#review-list)，确认提交信息内容；
   5.1 逐项检查 Review List 中的每一项：
       - 全部通过 -> 进入 5.4；
       - 存在未通过项 -> 进入 5.2；
   5.2 根据未通过类型返回对应环节重新生成：
       - 格式/类型问题（[Subject](#Subject) 长度、动词、句号等） -> 返回 4.1；
       - 内容规范问题（英文、CI 跳过标记、二进制文件等） -> 返回 4.1；
       - 破坏性变更标记问题 -> 返回 4.3；
       - Issue 引用问题 -> 返回 4.4；
       - 其他未映射问题 -> 返回 4.1；
   5.3 每次返回重试后计数，最大复核轮次为 3 次：
       - 3 次内全部通过 -> 进入 5.4；
       - 超限仍有未通过项 -> 引导用户手动处理，终止流程；
   5.4 复核通过，进入步骤 6；
6. **成果输出** — 输出最终 commit message；
   6.1 输出最终 commit message 及完整结构化日志（含前置信息、候选方案、确认环节、最终输出等维度的汇总表格）；

## Rules

- **内容规范**
    - 严格遵循 [conventional-commits.md](references/conventional-commits.md) 中的格式定义：`<类型>[可选 范围][!]: <描述>`。
    - [Subject](#Subject) 保持在 50 字符以内。
    - 使用动词开头（add, implement, correct, refactor 等），以小写动词开头，使用一般现在时。
    - [Description](#Description) 结尾不包含句号（.）。
    - 可选 [Scope](#Scope) 使用括号包裹在 [Type](#Type) 之后，如 `feat(auth):`。
    - [Body](#Body) 说明“做了什么”和“为什么”。
    - [Body](#Body) 每行不超过 72 字符。
    - [Type](#Type) 使用 [conventional-commits.md](references/conventional-commits.md) “类型”对照表中的合法值：feat（新功能）、fix（修复）、docs（文档）、style（格式）、refactor（重构）、perf（性能）、test（测试）、build（构建）、ci（持续集成）、chore（杂项）、revert（回滚）。
    - 采用英文的提交信息。
    - 保持简洁，不过度生成内容。
    - 禁止包含 `[skip ci]` 等 CI 跳过标记。
    - 涉及二进制文件变更时，仅标注文件名及变更类型，不分析内容。
    - 破坏性变更以 `[BREAKING CHANGE:](#BREAKING%20CHANGE)` 或 `!` 标记。
    - `!` 标记必须位于 [Type](#Type)/[Scope](#Scope) 之后、冒号之前。
    - 关联相关 Issue（如有）。
- **行为规范**
    - 所有涉及用户抉择的交互环节（选择候选方案、确认破坏性变更、关联 Issue 等），**必须**使用 `AskUserQuestion` 工具，禁止以纯文本追问代替；将问题与选项结构化传入 AskUserQuestion，每次调用 ≤4 个问题；自然地输入（如 Issue 编号等自由文本）不受此限制；

## Examples

### 对话交互示例

**分析变更内容**

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

**提交信息多方案输出**

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

**汇总用户已确认的选择**

```markdown
AI > 已确认您的全部选择，准备进入复核检查：
     - 选定方案：方案 2 — feat(auth)!: add user login and role management
     - 破坏性变更：是
     - 关联 Issue：无
```

### 复核检查示例

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

### 成果输出示例

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

> 【最终提交信息】下的内容，请使用 markdown 的代码块进行包裹


## Review List

完成生成后，验证以下内容：

- **格式检查**
  - [ ] 严格遵循 [conventional-commits.md](references/conventional-commits.md) 格式：`<类型>[可选 范围][!]: <描述>`
  - [ ] [Subject](#Subject) 不超过 50 字符
  - [ ] [Description](#Description) 以小写动词开头（add, implement 等），使用一般现在时，结尾不包含句号
  - [ ] [Body](#Body) 说明了“做了什么”和“为什么”
  - [ ] [Body](#Body) 每行不超过 72 字符
- **类型规范检查**
  - [ ] [Type](#Type) 使用 [conventional-commits.md](references/conventional-commits.md) 中定义的合法值
- **内容检查**
  - [ ] 提交信息采用英文
  - [ ] 保持简洁，不过度生成
  - [ ] 未包含 `[skip ci]` 等 CI 跳过标记
  - [ ] 二进制文件已正确处理（仅标注文件名及变更类型，未分析内容）
- **变更标记检查**
  - [ ] 破坏性变更已正确标记（`[BREAKING CHANGE:](#BREAKING%20CHANGE)` 或 `!`）
  - [ ] `!` 标记位于 [Type](#Type)/[Scope](#Scope) 之后、冒号之前
  - [ ] 关联 Issue（如有）已正确引用

## References

- Conventional Commits 规范详情：参见 [conventional-commits.md](references/conventional-commits.md)
