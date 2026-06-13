---
name: skill-optimizer
description: 该技能用于优化 SKILL.md 的目录结构、精简冗余内容、拆分参考文档，以提升可读性和维护性。当用户需要改进、重构或规范化已有 SKILL.md 时使用。
---
# Skill Optimizer

## Overview

规范化和优化已有 SKILL.md，对齐标准模板结构、精简冗余内容、拆分参考文档以提升可维护性。

## Definitions

- **相似含义目录**：与标准目录语义相同但历史命名不同的目录（如 `Description`↔`Overview`、`Checklist`↔`Review List`），由 AI 自动识别是否存在及对应的目标目录，是否采用由用户确认；
- **引用层次**：SKILL.md 直接链接 `references/` 下文件为一层；`references/` 文件再链接外部资源为二层，应避免；
- **预定义选项**：当可选处理方式有限且确定时使用（如覆盖/合并/跳过、采纳/搁置），选项在 SKILL.md 中直接列出；
- **动态选项**：当选项取决于待优化内容的具体特征、无法预先枚举时使用（由 AI 分析上下文后生成修复方案选项）。

## Prerequisites

待修改和优化对象已存在，本 SKILL 负责优化，而非从零创建。如需从零创建技能，使用 `skill-create`。

## Workflow

1. **元数据结构** — 检查 frontmatter 内容正确性；
   - 判断 `name` 是否存在；
      - 是 -> 下一步；
      - 否 -> 通过 AskUserQuestion 提供几个选项（文件夹名，基于 SKILL.md 整理出来的文件名），阻塞等待用户选择；
   - 判断 `description` 是否存在以及满足 [规则](#rules) 中的格式要求；
      - 是 -> 下一步；
      - 否 -> 通过 AskUserQuestion 提供选项（由 AI 根据 description 缺失类型生成修复方案），阻塞等待用户选择；
2. **结构对齐** — 对照 [模板](template.md)，补齐缺失目录、调整目录顺序；
   - 依次判断标准目录是否存在：
      - 是 -> 下一步；
      - 否 -> 通过 AskUserQuestion 提供选项（采用 AI 自动识别的相似含义目录数据 / 留空），阻塞等待用户选择；
   - 非模板标准目录的内容 → 迁移到 `references/` 下
      - 判断是否存在同名文件:
         - 是 -> 通过 AskUserQuestion 提供选项（覆盖 / 合并 / 跳过），阻塞等待用户选择；
         - 否 -> 下一步；
      - 迁移后更新被迁移内容中指向原位置的内部链接；
   - 调整目录顺序；
3. **内容优化** — 优化 SKILL.md 内容；
   - 对照 [模板](template.md) 中各个目录内容的职责要求，尝试优化；
      - 判断是否符合职责要求：
         - 是 -> 下一步；
         - 否 -> 通过 AskUserQuestion 提供选项（由 AI 根据不符合的职责要求生成优化方案），阻塞等待用户选择；
   - 判断 `## Workflow` 中是否存在涉及用户抉择的交互环节
      - 是 -> 基于 [交互式操作写作规范](references/interaction-writing.md) 进行优化
      - 否 -> 下一步
   - 判断 `## Workflow` 中是否存在逻辑判断步骤
      - 是 -> 基于 [分支逻辑写作规范](references/branch-logic-writing.md) 进行优化
      - 否 -> 下一步
4. **内容精简** — 检查并清理 SKILL.md 内容；
   - 行数不超过300行；超过300行或有大量复杂内容时需迁移到 `references/`（优先减少空白行，其次按[文本简化规则](references/text-optimization.md)压缩内容，禁止压缩语义密度）；
   - 删除时效性信息；保持术语一致；
   - 判断是否需要添加 `scripts/` 目录：若技能包含确定性操作（验证、格式化）、会被重复生成的代码、或需显式错误处理的逻辑，建议引入；
5. **参考文档拆分** — 拆分一些独立文件；
   - 判断 `REFERENCE.md` 是否存在：
      - 是 -> 通过 AskUserQuestion 提供选项（由 AI 根据 REFERENCE.md 内容领域生成拆分方案），阻塞等待用户选择；
      - 否 -> 下一步
   - 按领域拆分为 `references/` 下多个文件
      - 是否存在同名文件:
         - 是 -> 通过 AskUserQuestion 提供选项（覆盖 / 合并 / 跳过），阻塞等待用户选择；
         - 否 -> 下一步；
   - 拆分后更新 SKILL.md 中所有指向原文件的链接；
6. **复核检查** — 对照 [Review List](#review-list)，确认优化结果；
   - 逐项检查是否通过；
      - 是 -> 下一步；
      - 否 -> 列出修改方案，通过 AskUserQuestion 提供选项（采纳 / 搁置），阻塞等待用户选择；
   - 全部通过后，输出优化总结（行数对比、目录补齐情况、参考文档拆分情况等），告知优化完成；

## Rules

- description 须遵循格式：第一句说明技能能做什么，第二句说明触发条件（"当...时使用"），使用第三人称，不超过 1024 字符；
- 删除任何文件，都要通过交互式提问向使用者进行提问；
- 仅建议编辑 `SKILL.md` 和 `references/` 目录下的文件（移动/删除根目录下的 REFERENCE.md 或 template.md 属于此范围的例外，需通过 AskUserQuestion 进行确认，阻塞等待用户选择）；
- REFERENCE.md 应该移动到 `references` 文件夹下，并拆散为多个文件；
- 拆分 REFERENCE.md 后，必须逐段对比原文，确认无内容丢失（如括号内示例、注意事项等细节未被遗漏）；
- 每个涉及文件移动、拆分或删除的操作，必须同步处理由该操作引发的副作用（如更新链接引用、修复相对路径）；
- 目录结构标准仅适用于目标 SKILL 的 SKILL.md 文件本身，不影响目录下其他文件；
- 引用层次不超过一层：SKILL.md 可直接链接 `references/` 下文件；`references/` 下文件不应再链接外部资源；
- 所有涉及用户抉择的交互环节（确认修复方案、选择处理方式、确认删除/覆盖/合并等），**必须**使用 `AskUserQuestion` 工具，禁止以纯文本追问代替；将问题与选项结构化传入 AskUserQuestion，每次调用 ≤4 个问题；
- `## Examples` 中的所有示例必须由 markdown 代码块（` ```markdown ... ``` `）包裹，禁止以裸文本呈现示例；

## Examples

### 对话交互示例

```markdown
> **用户**：帮我优化 skills.zh-CN/example-skill/SKILL.md
>
> **AI**：检查元数据…description 缺少触发条件。

<!-- 此时 AI 通过 AskUserQuestion 弹出选项：添加触发条件 / 保持现状，阻塞等待用户选择 -->

> **用户**（选择）：添加触发条件
>
> **AI**：已更新 description。目录对齐中…缺少 Definitions 和 Review List。

<!-- 此时 AI 通过 AskUserQuestion 弹出选项：补齐 / 留空占位，阻塞等待用户选择 -->

> ...后续步骤均以相同方式通过 AskUserQuestion 进行交互确认...
```

### 执行成功示例

```markdown
| 维度 | 优化前 | 优化后 |
|------|--------|--------|
| SKILL.md 行数 | 150 行 | 85 行 |
| 目录完整性 | 缺少 Prerequisites、Review List | 补齐所有目录 |
| 时效性信息 | 包含 v2.1.0、2024-05-01 等 | 已全部删除 |
| 参考文档组织 | REFERENCE.md 单一文件 | 拆分为 references/ 下 3 个独立文件 |
| 触发条件 | 描述模糊 | 明确包含"当...时使用" |
```

## Review List

完成优化后，验证以下内容：
- [ ] description 格式：包含触发条件（"当...时使用"）、使用第三人称（不含 你/您的/we/I 等第一/第二人称代词）、不超过 1024 字符
- [ ] SKILL.md 不超过300行；超过300行或有大量复杂内容即迁移到 references/
- [ ] 内容质量：无时效性信息、术语一致、包含具体示例且数值与规则一致
- [ ] 引用与链接：引用层次不超过一层、无死链（含文件内 #anchor 锚点可跳转到对应标题）、无未解析占位符
- [ ] 拆分后内容完整性：已逐段对比原文，无内容丢失
- [ ] 示例格式：`## Examples` 中的所有示例已由 markdown 代码块包裹
- [ ] 内容精简后，对照[文本简化验证清单](references/text-optimization.md#验证清单)逐项确认
- [ ] 扩展目录：需引入 scripts/、tests/ 或 schemas/ 的已评估

## References

- [SKILL 目录结构](references/directory-structure.md)
- [SKILL 模板](template.md)
- [文本简化规则](references/text-optimization.md)
- [交互式操作写作规范](references/interaction-writing.md)
- [分支逻辑写作规范](references/branch-logic-writing.md)
