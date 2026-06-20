# Review List 编写标准 — 定义 Review List 的编写规范和类型适配标准

## Overview

Review List 验证输出质量（result），定义完成后应该长什么样。

## 内容边界

- **应写入 Review List**：结果验证项、质量验收标准
- **不应写入 Review List**：AI 行为约束（进 Rules）、执行步骤说明（进 Workflow）

## 内联 vs 锚点引用标准

- **使用锚点引用**（避免重复）：检查项已在 reference 文件的 `## 验证清单` 中完整定义
- **保持内联**：仅该 SKILL 特有的检查项、需要特定上下文的验证

## 类型适配

- **Meta-skill**（修改/验证 SKILL.md 的技能）：复核检查包含结构类检查（元数据、标准目录、Secure 步骤、自洽性）
- **Domain/Action skill**（执行具体任务）：复核检查仅验证输出/结果质量

## 分组建议

按质量维度分组，分组名与顺序与 [Rules 分组方案](rules-standard.md#分组建议)保持一致。

> **注意**：分组顺序一致性要求仅对新优化或重新对齐优化的技能生效。对已有 Review List 的自动重新对齐应通过 AskUserQuestion 确认后再执行。

## 验证清单

- [ ] 所有检查项验证的是输出质量（result），非 AI 行为
- [ ] 能通过锚点引用覆盖的检查项未重复内联
- [ ] 分组结构与 Rules 的 Concern 分离原则一致
- [ ] 变量声明完整性：所有跨步骤使用的工作流变量已在 Definitions 中以“是否 xxx”格式声明
- [ ] Review List 分组顺序与 Rules 分组顺序保持一致
