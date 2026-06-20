---
name: git-commit-helper
description: 遵循 Conventional Commits 规范生成 Git commit message。当用户请求帮助编写 commit message、查看暂存变更，或提及 “commit” 或 “commit message” 时使用。
---

# Git Commit Helper

## Overview

智能生成遵循 Conventional Commits 规范的 Git commit message。生成的提交信息全部使用英文。

## Definitions

- **Conventional Commits**：一种基于提交信息的轻量级约定，通过结构化元素（类型、范围、描述等）传达变更意图。
- **Commit Message**：包含 subject、body 和 footer 的 Git 提交信息，遵循 <type>[scope][!]: <description> 格式。
- **Type（类型）**：Commit 的前缀名词，表示变更类别。合法值包括 feat、fix、docs、style、refactor、perf、test、build、ci、chore、revert 等。
- **Scope（范围）**：可选参数，使用括号包裹在 type 之后，表示变更影响的模块/位置，例如 `feat(auth):`。
- **Subject**：Commit message 的第一行，格式为 `<type>[scope][!]: <description>`，不超过 50 字符。
- **Body（正文）**：Subject 后空一行开始的详细说明，阐述“做了什么”和“为什么”。
- **Footer（脚注）**：可选部分，位于 Body 之后，用于标记破坏性变更（BREAKING CHANGE:）或关联 Issue（如 Closes #123）。
- **Description（描述）**：Subject 中冒号后的简短说明，以小写动词开头，不包含结尾句号。

## Prerequisites

- Git 2.0+。
- 当前在 Git 仓库目录中。
- 存在可供分析的 Git 变更（暂存区变更、工作区变更、指定 commit 或分支范围）。

## Workflow

0. **前置检查** — 确保 commit 环境已就绪；
    - 判断是否在 Git 仓库中：
        - 是 -> 下一步；
        - 否 -> 报告“当前不在 Git 仓库中”，终止流程；
    - 判断 Git 版本是否 >= 2.0：
        - 是 -> 下一步；
        - 否 -> 提示升级 Git，终止流程；
    - 判断是否存在可供分析的变更：
        - 是 -> 下一步（进入步骤 1 判断输入来源）；
        - 否 -> 告知用户无变更可分析，终止流程；

### 1. 判断输入来源

1. 判断用户输入的类型：
   - 用户对话中已包含 diff 内容（如用户贴出了 git diff 的输出） -> 跳过步骤 2，直接进入步骤 3 分析变更；
   - 用户提供了 commit id 或分支范围（如 `abc123`、`HEAD~3`、`main..feature`） -> 进入步骤 2 获取 diff；
   - 用户未提供任何变更信息 -> 通过 AskUserQuestion 提供选项（暂存区或工作区 / 指定 commit / 分支范围），阻塞等待用户选择；

### 2. 获取 diff

1. 检测是否处于合并过程中（通过 `test -f "$(git rev-parse --git-dir)/MERGE_MSG"` 检测）：
   - 是 -> 生成标准合并提交信息，不套用 Conventional Commits 规范，终止流程；
   - 否 -> 下一步；
2. 根据步骤 1 的判定结果映射到对应场景：
   - 用户提供了 commit id -> 场景 B（单个 commit）；
   - 用户提供了分支范围 -> 场景 C（分支范围）；
   - 用户选择了暂存区或工作区 -> 场景 A（暂存区/工作区）；
3. 根据场景类型执行对应命令：
   - 场景 A（暂存区/工作区）：
       - 若用户选择"暂存区" -> 执行 `git diff --staged`，下一步；
       - 若用户选择"工作区" -> 执行 `git diff`，并执行 `git status --short`：
           - 仅有未跟踪文件 -> 建议先 `git add` 后重试，终止流程；
           - 完全无变更 -> 告知用户，终止流程；
   - 场景 B（单个 commit）：执行 `git diff <commit>^!`（若为根提交即无父提交，改用 `git show <commit>`），下一步；
   - 场景 C（分支范围）：执行 `git log <range> -p`；

完成获取 diff 后进入步骤 3；

### 3. 分析变更

1. 打开 [conventional-commits.md](references/conventional-commits.md) 作为规范依据，对照"类型"对照表（feat/fix/docs/style/refactor/perf/test/build/ci/chore/revert）确定适用的 commit 类型，同时分析变更的影响范围和核心意图；
2. 按文件类型分别处理变更内容：
   - 非二进制文件 -> 正常分析变更内容；
   - 二进制文件 -> 仅标注文件名及变更类型，不分析其内容；

分析完成后，输出变更分析汇总表（按非二进制/二进制文件统计新增/修改/删除/重命名/权限变更数量），进入步骤 4；

### 4. 生成 commit message

1. **生成候选方案** — 基于变更分析结果，从以下策略中选取 1 到 3 种合理的 type，每种生成一个候选 commit message：
   - 若变更同时涉及多种性质（如既有新功能又有重构），考虑多个合理 type；
   - 若变更性质明确单一，则只生成 1 个候选，避免不必要的选项；
   - 每个候选严格遵循 [conventional-commits.md](references/conventional-commits.md) 中的规范格式，并一次性输出所有候选内容；
2. **用户选择** — 判断候选方案数量：
   - 若候选数量 ≥ 2 -> 通过 AskUserQuestion 提供选项（由 AI 根据生成的候选方案提供选项），阻塞等待用户选择：
       - 用户选择某个候选 -> 进入下一步（破坏性变更确认）；
       - 用户选择"都不合适" -> 通过 AskUserQuestion 提供选项（由 AI 根据上下文询问具体方向，如 type 调整、描述修改等），基于反馈重新生成后返回步骤 4.1（重新生成候选方案）；若用户累计 3 次选择"都不合适"（连续计数，中间选择其他候选则重置），引导用户手动输入 commit message，终止流程；
   - 若候选数量 = 1 -> 跳过用户选择，直接进入下一步（破坏性变更确认）；
3. **破坏性变更确认** — 若候选方案包含破坏性变更标记（`!` 或 `BREAKING CHANGE:`），通过 AskUserQuestion 提供选项（是，确实是破坏性变更 / 否，移除破坏性标记），阻塞等待用户选择：
   - 用户确认是 -> 保留破坏性变更标记，进入步骤 4；
   - 用户确认否 -> 移除破坏性变更标记，进入步骤 4；
4. **关联 Issue** — 通过 AskUserQuestion 提供选项（是，关联 Issue / 否，不关联），阻塞等待用户选择：
   - 是 -> 通过对话让用户输入 Issue 编号（如 `#123`），补充到 commit message footer；
   - 否 -> 跳过；
5. **最终确认** — 输出最终确定的 commit message，同时输出结构化日志（含前置信息、候选方案、确认环节、最终输出等维度的汇总表格）。

### 5. 复核检查

1. 对照 [Review List](#review-list)，确认提交信息内容：
   - 判断 Review List 是否有内容：
       - 否 -> 直接进入下一步（成果输出）；
       - 是 -> 下一步；
   - 依次判断 [Review List](#review-list) 中每个检查项，是否通过：
       - 基于“复核检查示例”来显示输出内容；
       - 是 -> 下一步；
       - 否 -> 根据未通过项的类型返回对应环节（格式问题返回步骤 4.1，破坏性变更标记问题返回步骤 3，Issue 引用问题返回步骤 4），重新生成后再次检查；
   - 全部通过后，输出最终信息摘要（含 subject 长度、type、body 行数、footer 等维度），告知生成完成。

### 6. 成果输出

1. 输出最终 commit message 及结构化日志；
2. 判断是否需要推送到远端：
   - 是 -> 通过 AskUserQuestion 确认推送选项；
   - 否 -> 告知生成完成；

## Rules

- **格式规范**
    - 严格遵循 [conventional-commits.md](references/conventional-commits.md) 中的格式定义：`<类型>[可选 范围][!]: <描述>`。
    - subject 保持在 50 字符以内。
    - 使用动词开头（add, implement, correct, refactor 等），以小写动词开头。
    - description 结尾不包含句号（.）。
    - 可选 scope 使用括号包裹在 type 之后，如 `feat(auth):`。
    - body 说明"做了什么"和"为什么"。
- **类型规范**
    - type 使用 [conventional-commits.md](references/conventional-commits.md) "类型"对照表中的合法值：feat（新功能）、fix（修复）、docs（文档）、style（格式）、refactor（重构）、perf（性能）、test（测试）、build（构建）、ci（持续集成）、chore（杂项）、revert（回滚）。
- **内容规范**
    - 采用英文的提交信息。
    - 保持简洁，不过度生成内容。
    - 禁止包含 `[skip ci]` 等 CI 跳过标记。
    - 涉及二进制文件变更时，仅标注文件名及变更类型，不分析内容。
- **交互规范**
    - 所有涉及用户抉择的交互环节（选择候选方案、确认破坏性变更、关联 Issue 等），**必须**使用 `AskUserQuestion` 工具，禁止以纯文本追问代替；将问题与选项结构化传入 AskUserQuestion，每次调用 ≤4 个问题；自然地输入（如 Issue 编号等自由文本）不受此限制；
- **变更标记规范**
    - 破坏性变更以 `BREAKING CHANGE:` 或 `!` 标记。
    - `!` 标记必须位于 type/scope 之后、冒号之前。
    - 关联相关 Issue（如有）。

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

**多方案选择**

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

```markdown
用户 > 我选方案 2（AskUserQuestion 选择）
AI   > 检测到方案 2 包含破坏性变更标记，请确认：
      该变更确实是破坏性变更吗？（AskUserQuestion）

用户 > 是
```

```markdown
AI   > 请问该 commit 是否关联了 Issue？（AskUserQuestion）

用户 > 是
AI   > 请输入 Issue 编号（如 #123）

用户 > #456
```

```markdown
AI > 最终 commit message：

feat(auth)!: add user login and role management

- Implement JWT authentication for user login
- Add role-based access control for admin endpoints

BREAKING CHANGE: restructured authentication system
Closes #456
```

### 执行成功示例

**最终提交信息**

```markdown
AI > 最终 commit message：

feat(auth): add user login and role management

- Implement JWT authentication for user login
- Add role-based access control for admin endpoints

Closes #123
```

**最终输出日志**

```markdown
| 维度             | 说明                                         |
|------------------|----------------------------------------------|
| **前置信息**     |                                              |
| 输入来源         | 暂存区变更                                   |
| 文件范围         | 非二进制 5 个 / 二进制 1 个（2 个图片资源）  |
| 变更分布         | 新增 2 / 修改 3 / 删除 0 / 重命名 0          |
| **候选方案**     |                                              |
| 候选数量         | 2 个（feat / refactor）                      |
| 选定方案         | 方案 1 — feat(auth): ...                     |
| **确认环节**     |                                              |
| 破坏性变更       | 否（已确认用户）                             |
| 关联 Issue       | #123（Closes #123）                          |
| **最终输出**     |                                              |
| Message 类型     | feat（新功能）                               |
| 影响范围         | auth（认证模块）                             |
| Subject 长度     | 48 字符（≤ 50 ✅）                          |
| Body             | 3 行，含变更内容和原因                       |
| Footer           | Closes #123                                  |
```

### 复核检查示例

```markdown
AI > 进入复核检查，对照 Review List 逐项确认：

- subject ≤ 50 字符 ✅
- 使用动词开头 ✅
- description 以小写动词开头 ✅
- description 结尾无句号 ✅
- type 使用合法值 ✅
- …（剩余检查项已逐项通过，此处仅展示关键项）

✅ 全部通过，commit 信息已就绪。
```

### 成果输出示例

```markdown
AI > 最终 commit message：

feat(auth): add user login and role management

- Implement JWT authentication for user login
- Add role-based access control for admin endpoints

Closes #123
```

## Review List

完成生成后，验证以下内容：

- **格式检查**
    - [ ] 严格遵循 [conventional-commits.md](references/conventional-commits.md) 格式：`<类型>[可选 范围][!]: <描述>`
    - [ ] subject 不超过 50 字符
    - [ ] 使用动词开头（add, implement, correct, refactor 等）
    - [ ] description 以小写动词开头
    - [ ] description 结尾不包含句号
    - [ ] body 说明了"做了什么"和"为什么"
- **类型规范检查**
    - [ ] type 使用 [conventional-commits.md](references/conventional-commits.md) 中定义的合法值
- **内容检查**
    - [ ] 提交信息采用英文
    - [ ] 保持简洁，不过度生成
    - [ ] 未包含 `[skip ci]` 等 CI 跳过标记
    - [ ] 二进制文件已正确处理（仅标注文件名及变更类型，未分析内容）
- **交互规范检查**
    - [ ] 所有用户抉择环节已使用 AskUserQuestion，无纯文本追问
    - [ ] AskUserQuestion 每次调用 ≤4 个问题
    - [ ] 用户选择"都不合适"时正确进入重新生成分支
- **变更标记检查**
    - [ ] 破坏性变更已正确标记（`BREAKING CHANGE:` 或 `!`）
    - [ ] `!` 标记位于 type/scope 之后、冒号之前
    - [ ] 关联 Issue（如有）已正确引用
- **完整性检查**
    - [ ] 所有标准目录齐全（Overview、Definitions、Prerequisites、Workflow、Rules、Examples、Review List、References）
    - [ ] Secure 步骤完整（前置检查、复核检查、成果输出）
    - [ ] 自洽性：Review List 检查项与 Rules 约束规则一一对应，不遗漏

## References

- Conventional Commits 规范详情：参见 [conventional-commits.md](references/conventional-commits.md)
