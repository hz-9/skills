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

定义技能中涉及的术语和约定，帮助理解后续执行指令。每条用一句话说明。

示例：

> - **相似含义目录**：与标准目录语义相同但历史命名不同的目录，优化时自动映射无需交互确认。

## Prerequisites

执行前需要满足的条件，如依赖工具、环境变量、前置知识。如有互补技能，请在此声明并说明分工边界（避免职责重叠）。

示例：

> 需要 Git 2.0+，当前在 Git 仓库目录，有分支删除权限。如需从零创建技能，使用 `skill-create`。

## Workflow

核心部分：分步骤的详细指令，告诉 AI 具体怎么做。步骤要清晰、可执行。

示例：

> 1. 执行 `git branch` 获取本地分支列表
> 2. 过滤掉当前分支、main/master/develop
> 3. 逐个询问用户是否删除
> 4. 对确认的分支执行 `git branch -d`

## Rules

告诉 AI：执行 SKILL 过程中需要遵守的约束和行为准则。

示例：

> - 删除任何文件，都要通过交互式提问向使用者进行提问；
> - 仅建议编辑 `SKILL.md` 和 `references/` 目录下的文件；
> - REFERENCE.md 应该移动到 `references` 文件夹下，并拆散为多个文件；

## Examples

### 对话交互示例

展示用户与 AI 的对话流程，帮助理解 SKILL 的触发方式和 AI 的响应行为。具体示例，应由 markdown 的代码块进行包裹；

示例：

> **示例：AI 根据触发条件自动唤起**
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

### 执行成功示例

展示 SKILL 执行后的成果状态，让用户直观理解应用效果。具体示例，应由 markdown 的代码块进行包裹；

示例 1：

> **SKILL 优化类技能执行效果示例：**
>
> ```markdown
> | 维度 | 优化前 | 优化后 |
> |------|--------|--------|
> | SKILL.md 行数 | 150 行 | 85 行 |
> | 目录完整性 | 缺少 Prerequisites、Review List | 补齐所有目录 |
> | 时效性信息 | 包含 v2.1.0、2024-05-01 等 | 已全部删除 |
> | 参考文档组织 | REFERENCE.md 单一文件 | 拆分为 references/ 下 3 个独立文件 |
> | 触发条件 | 描述模糊 | 明确包含"当...时使用" |
> ```

示例 2：

> **Git 分支清理技能执行效果示例：**
>
> ```markdown
> | 项目 | 数量 |
> |------|------|
> | 已合并分支 | 3 个 |
> | 未合并分支（含未推送变更，已跳过） | 1 个 |
> | 已清理 | 2 个 |
> | 用户拒绝清理 | 1 个 |
> | 自动跳过（当前分支 + 保护分支） | 2 个 |
> | 已释放磁盘空间 | 约 45MB |
> ```

## Review List

告诉 AI：完成 SKILL 后的复核检查项。

示例：

> - [ ] 描述包含触发条件（"当...时使用"）
> - [ ] SKILL.md 不超过 300 行
> - [ ] 内容质量：无时效性信息、术语一致、包含具体示例且数值与规则一致
> - [ ] 引用与链接：引用层次不超过一层、无死链、无未解析占位符
> - [ ] 扩展目录：需引入 scripts/、tests/ 或 schemas/ 的已评估

## References

引用的外部文档和资源列表，按需添加更多引用项。

示例：

> - [SKILL 目录结构](references/directory-structure.md)
> - [SKILL 模板](template.md)
