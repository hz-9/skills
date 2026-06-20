---
name: your-skill-name
description: 简要描述该技能能做什么、解决什么问题。当用户需要 X、想要做 Y、或提到 Z 时使用。
---

# Skill Name: xxx

## Overview

简要说明这个 Skill 是做什么的、解决什么问题、什么场景下触发。使用第三人称，不超过 1024 字符。

示例：

> 清理 Git 残留分支，支持交互式选择，安全删除已合并的本地分支。

## Definitions

定义技能中涉及的术语和约定，以及跨步骤使用的流程变量（以“是否”开头），帮助理解后续执行指令。每条用一句话说明。每个术语使用 `<a id="术语名"></a>` 标签提供锚点，以便精确引用。

示例：

> - <a id="相似含义目录"></a>**相似含义目录**：与标准目录语义相同但历史命名不同的目录，优化时自动映射无需交互确认。
> - <a id="引用层次"></a>**引用层次**：SKILL.md 直接链接 `references/` 下文件为一层；`references/` 文件再链接外部资源为二层，应避免。
> - <a id="secure-步骤"></a>**Secure 步骤**：Workflow 中的一组固定标准化步骤，其具体构成和结构由 [Workflow 编写规范](references/workflow-standard.md) 定义。
> - <a id="抽象变量名"></a>**抽象变量名**：在 reference 文件中用于替代具体数值或路径的泛化占位符，通常包含在方括号 `[]` 中（如 `[文件名]`、`[目录名]`），确保引用内容不随被引用文件内容变更而失效。
> - <a id="模板标准目录"></a>**模板标准目录**：[模板](template.md) 中通过 `##` 标题节定义的标准目录集合，是结构对齐的目标基准。
> - <a id="是否跨步骤循环引用"></a>**是否跨步骤循环引用**：标记目标 SKILL.md 的 Workflow 子步骤间是否存在跨步骤循环跳转引用，控制是否需要使用数字子编号格式。根据 [Workflow 编写规范](references/workflow-standard.md#数字子编号（引用场景）) 分析引用关系后初始化。

## Prerequisites

执行前需要满足的条件，如依赖工具、环境变量、前置知识。如有互补技能，请在此声明并说明分工边界（避免职责重叠）。

示例：

> 需要 Git 2.0+，当前在 Git 仓库目录，有分支删除权限。如需从零创建技能，使用 `skill-create`。

## Workflow

核心部分：分步骤的详细指令，告诉 AI 具体怎么做。步骤要清晰、可执行。

Workflow 必须包含三个 Secure 步骤（前置检查、复核检查、成果输出），具体定义和结构参考 [Workflow 编写规范](references/workflow-standard.md)。

示例：

> 0. **前置检查** — 确保后续任务的先决条件已达成；
> 1. **获取分支列表** — 执行 `git branch` 获取本地分支列表；
> 2. **过滤保护分支** — 过滤掉当前分支、main/master/develop；
> 3. **逐条确认删除** — 逐个询问用户是否删除；
> 4. **执行删除操作** — 对确认的分支执行 `git branch -d`；
> 5. **复核检查** — 对照 Review List 确认执行结果
> 6. **成果输出** — 输出执行摘要，告知完成

## Rules

告诉 AI：执行 SKILL 过程中需要遵守的约束和行为准则。

建议参照 [Rules 编写标准](references/rules-standard.md#分组建议) 的分组方案，将规则按以下六个维度分组：元数据规范、结构规范、内容规范、行为规范、防御规范、验证规范。每个维度为一组，使用两级缩进列表呈现。

> **分组阈值**：当 Rules 条数 ≥ 10 时建议分组；少于 10 条时使用 flat 列表，避免不必要的分组。

示例：

> - **元数据规范**
>   - description 须遵循格式：第一句说明技能能做什么，第二句说明触发条件（“当...时使用”），使用第三人称，不超过 1024 字符；
> - **结构规范**
>   - 标准结构目录仅适用于目标 SKILL 的 SKILL.md 文件本身，不影响目录下其他文件；
> - **内容规范**
>   - （请根据技能特点补充）
> - **行为规范**
>   - 删除任何文件，都要通过交互式提问向使用者进行提问；
> - **防御规范**
>   - 每个涉及文件移动、拆分或删除的操作，必须同步处理该操作引发的副作用（如更新链接引用、修复相对路径）；
>   - 若执行过程中检测到不可恢复的错误，使用[原始内容副本](../skill-evolve/SKILL.md#原始内容副本)回滚，并告知用户恢复结果；
> - **验证规范**
>   - 示例编写规范参照[示例编写规范](references/example-standard.md#示例自洽性规则)；

## Examples

### 对话交互示例

参照[示例编写规范](references/example-standard.md#对话交互示例规范)。

示例 1：

> **AI 根据触发条件自动唤起**
>
> ```markdown
> 用户> 来帮我检查一下当前项目有没有残留的本地分支需要清理
>
> AI > 检测到用户需要分支清理操作，触发 git-branch-cleanup 技能：
>
> AI > 执行 git branch 获取本地分支列表...
>     发现已合并分支：feature/old-login, fix/temp-patch, test/experiment
>     当前分支：main（跳过）
>     保护分支：main, develop（跳过）
>
> AI > 是否删除 feature/old-login？（已合并至 main）
> 用户 > 是
> AI > 已删除 feature/old-login
>
> AI > 是否删除 fix/temp-patch？（已合并至 main）
> 用户 > 否
> AI > 已跳过 fix/temp-patch
> ```

示例 2：

> **用户主动请求使用特定技能**
>
> ```markdown
> 用户 > 用 commit-helper 帮我生成本次提交的 message
>
> AI   > 好的，正在分析暂存区变更...
>       检测到 3 个文件已暂存：
>       - src/auth.ts（新增）
>       - src/user.ts（修改）
>       - tests/auth.test.ts（新增）
>
>       建议的 commit message：
>       feat(auth): 添加用户认证模块
>
>       - 实现 JWT token 生成与验证
>       - 添加 refresh token 机制
>       - 补充认证相关单元测试
>
>       是否使用此 message？
> 用户 > 是
> AI   > 已使用此 message 完成提交
> ```

### 复核检查示例

参照[示例编写规范](references/example-standard.md#复核检查示例规范)。

```markdown
AI > 进入复核检查，Review List 包含 12 个检查项，开始逐项验收：

**元数据检查**
  - 🟩 name 字段：your-skill-name，与目录名一致
  - 🟥 description 格式：缺少"当...时使用"

**内容检查**
  - 🟩 SKILL.md 150 行（<300）
  - 🟥 示例未使用 ```markdown 代码块包裹

**结构检查**
  - 🟩 所有标准目录齐全
  - 🟩 Secure 步骤完整

**验证检查**
  - 🟩 复核检查示例已存在，展示终止流程
  - 🟩 自洽性：Review List 与 Rules 一一对应

**！！！以下检查项未通过！！！**
  - 🟥 description 格式：缺少"当...时使用"
  - 🟥 示例格式：未使用 markdown 代码块包裹

终止流程，建议人工检查处理后重新执行。
```

### 成果输出示例

参照[示例编写规范](references/example-standard.md#成果输出示例规范)。

示例 1：

> **SKILL 优化类技能执行效果示例：**
>
> ```markdown
> | 维度          | 优化前                          | 优化后                             |
> | ------------- | ------------------------------- | ---------------------------------- |
> | SKILL.md 行数 | 150 行                          | 85 行                              |
> | 目录完整性    | 缺少 Prerequisites、Review List | 补齐所有目录                       |
> | 时效性信息    | 包含 v2.1.0、2024-05-01 等      | 已全部删除                         |
> | 参考文档组织  | REFERENCE.md 单一文件           | 拆分为 references/ 下 3 个独立文件 |
> | 触发条件      | 描述模糊                        | 明确包含“当...时使用”              |
> ```

示例 2：

> **Git 分支清理技能执行效果示例：**
>
> ```markdown
> | 项目                               | 数量    |
> | ---------------------------------- | ------- |
> | 已合并分支                         | 3 个    |
> | 未合并分支（含未推送变更，已跳过） | 1 个    |
> | 已清理                             | 2 个    |
> | 用户拒绝清理                       | 1 个    |
> | 自动跳过（当前分支 + 保护分支）    | 2 个    |
> | 已释放磁盘空间                     | 约 45MB |
> ```

## Review List

告诉 AI：完成 SKILL 后的复核检查项。

**提示**：Review List 的检查项应根据技能的实际输出性质确定，对照 [Review List 编写标准](references/review-list-standard.md#类型适配) 中的“类型适配”规则进行选择：

- **Meta-skill**（修改/验证 SKILL.md 的技能，如 skill-evolve、skill-create）：
  复核包含文件结构类检查（元数据、标准目录、Secure 步骤、自洽性）
- **Domain/Action skill**（执行具体任务的技能，如代码分析、迁移工具、追问工具）：
  复核仅验证输出/结果质量，不包含技能自身的文件结构检查

> 以下示例**仅为 Meta-skill 的参考**，Domain/Action skill 请根据自身输出性质裁剪，切勿机械照搬。

建议参照 [Review List 编写标准](references/review-list-standard.md#分组建议) 的分组方案，将检查项按所检查的质量维度分组（如元数据、内容、引用等），每个维度为一组，使用两级缩进列表呈现。

示例：

> - **元数据检查**
>   - [ ] description 格式：包含触发条件（“当...时使用”）、使用第三人称、不超过 1024 字符
> - **结构检查**
>   - [ ] 扩展目录：需引入 scripts/、tests/ 或 schemas/ 的已评估
>   - [ ] Secure 步骤完整性：Workflow 步骤结构符合 [Workflow 编写规范](references/workflow-standard.md) 中定义的标准
> - **内容检查**
>   - [ ] SKILL.md 不超过 300 行
>   - [ ] 内容质量：无时效性信息、术语一致、包含具体示例且数值与规则一致
>   - [ ] 引用层次不超过一层、无死链
>   - [ ] 格式规范：标点符号与引号风格须遵循[标点符号使用规范](references/punctuation-convention.md#验证清单)
> - **行为检查**
>   - [ ] 交互环节：对照 [Workflow 编写规范](references/workflow-standard.md#交互规范验证)逐项确认
>   - [ ] 分支逻辑：对照 [Workflow 编写规范](references/workflow-standard.md#分支逻辑验证)逐项确认
> - **防御检查**
>   - [ ] 错误处理完整性：复核检查已按防御规范正确处理可恢复/不可恢复错误
> - **验证检查**
>   - [ ] 示例规范自洽性：对照[示例编写规范](references/example-standard.md#验证清单)确认

> **提示**：Review List 的具体检查项可通过锚点引用 `references/` 下各文件的 `## 验证清单` 节来实现，避免内联重复。参考[内容边界标准](references/content-boundary.md)。

> **进阶提示**：若 SKILL 的 Rules 和 Review List 使用锚点引用结构，建议在 Workflow 中增加“格式统一检查”步骤，引用各 reference 文件的 `## 验证清单` 逐项检查。

## References

引用的外部文档和资源列表，按需添加更多引用项。

示例：

> - [SKILL 目录结构](references/directory-structure.md)
> - [SKILL 模板](template.md)
> - [内容边界标准](references/content-boundary.md)：定义 SKILL.md 与 references/ 下各文件之间的内容所有权边界
> - [Workflow 编写规范](references/workflow-standard.md)：定义 Workflow 的固定步骤结构、步骤编写格式、分支逻辑及交互范式
> - [Rules 编写标准](references/rules-standard.md)：约束 AI 的执行行为
> - [Review List 编写标准](references/review-list-standard.md)：定义 Review List 的编写规范
> - [标点符号使用规范](references/punctuation-convention.md)
> - [示例编写规范](references/example-standard.md)：定义 `## Examples` 节的编写格式与自洽性规则

