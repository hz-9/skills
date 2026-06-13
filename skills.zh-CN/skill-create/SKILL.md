---
name: skill-create
description: 创建新的 agent 技能，包含合适的结构、渐进式信息揭示和打包的资源。当用户想要创建、编写或构建一个新技能时使用。
---

# 编写技能

## Overview

从零创建新的 agent 技能。按标准模板结构组织内容、打包目录结构和参考文档。创建完成后可交由 `skill-optimizer` 进一步优化。

## Definitions

- **标准模板结构**：由 skill-optimizer 维护的 SKILL.md 标准结构，包含 Overview、Definitions、Prerequisites、Workflow、Rules、Examples、Review List、References 八个目录；
- **引用层次**：SKILL.md 直接链接 `references/` 下文件为一层，`references/` 文件不应再链接外部资源；

## Prerequisites

- 已安装 `skill-optimizer`（本技能依赖其 template.md 和 directory-structure.md）；
- 明确技能要解决什么问题、在什么场景下触发；
- 了解该领域的相关知识。

## Workflow

1. **收集需求** — 向用户了解以下信息：
   - 该技能涉及什么任务/领域？
   - 应处理哪些具体用例？
   - 需要可执行脚本还是只需要指令？
   - 是否有参考资料？
   - 是否有与其他技能的互补或边界关系？

2. **创建目录结构** — 参照 [目录结构标准](../skill-optimizer/references/directory-structure.md) 创建文件和文件夹，至少创建 `SKILL.md`；

3. **起草 SKILL.md** —
   - 参照 [SKILL 模板](../skill-optimizer/template.md) 按标准目录顺序组织内容；
   - description 须遵循 [Rules](#rules) 中的格式要求；
   - 每个目录写入引导语，帮助 AI 理解该目录用途；
   - SKILL.md 不超过 300 行；超过 300 行或有大量复杂内容时拆分到 `references/`；

4. **添加辅助目录** —
   - `references/`：非模板标准但有用的内容移入此处；
   - `scripts/`：确定性操作、重复生成的代码、需显式错误处理的逻辑；
   - `assets/`：模板、图片等静态资源；
   - `schemas/`：需与其他技能传递数据的场景；
   - `tests/`：工程化测试场景；

5. **与用户复核** — 展示草稿并确认：是否覆盖用例、有无遗漏、有无需调整的章节；

6. **最终检查** — 参照 [template.md 的 Review List](../skill-optimizer/template.md#review-list) 逐项确认。

## Rules

- description 须遵循格式：第一句说明技能能力，第二句说明触发条件（"当...时使用"），使用第三人称，不超过 1024 字符；
- SKILL.md 不超过 300 行；
- 引用层次不超过一层（SKILL.md 链接 `references/` 下文件为一层，`references/` 不应再链接外部资源）；
- 删除任何时效性信息；
- 保持术语一致；
- 包含具体示例且示例数值与规则一致；

## Examples

### 对话交互示例

**示例：AI 根据触发条件自动唤起**

```
用户 > 我想要一个自动清理 Git 本地分支的技能
AI   > 检测到用户需要编写新技能，触发 skill-create
AI   > 开始收集需求：该技能涉及什么任务/领域？
用户 > 就是帮我列出已合并的本地分支，然后安全删除
AI   > 需要可执行脚本吗？
用户 > 不需要
AI   > 有参考资料吗？
用户 > 没有
AI   > 按目录结构标准创建 git-branch-cleanup/SKILL.md
AI   > 按模板结构起草 SKILL.md...
      description 格式符合要求 ✓
      85 行（<300，无需拆分）✓
AI   > 请复核草稿，这覆盖了你的用例吗？
用户 > 看起来不错
AI   > 最终检查：参照 template.md 的 Review List 逐项确认 ✓
      技能创建完成！
```

### 执行成功示例

| 维度 | 说明 |
|------|------|
| 创建文件 | SKILL.md |
| 结构 | 对齐标准模板所有目录 |
| 行数 | 85 行（<300） |
| 辅助目录 | 无 |

## Review List

参照 [template.md 的 Review List](../skill-optimizer/template.md#review-list) 逐项确认。

## References

- [SKILL 目录结构](../skill-optimizer/references/directory-structure.md)
- [SKILL 模板](../skill-optimizer/template.md)
