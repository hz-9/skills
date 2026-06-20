---
name: skill-create
description: 创建新的 agent 技能，包含合适的结构、渐进式信息揭示和打包的资源。当用户想要创建、编写或构建一个新技能时使用。
disable-model-invocation: true
---

# 编写技能

## Overview

从零创建新的 agent 技能。按标准模板结构组织内容、打包目录结构和参考文档。创建完成后可交由 `skill-evolve` 进一步优化。

## Definitions

- **标准模板结构**：由 skill-evolve 维护的 SKILL.md 标准结构，包含 Overview、Definitions、Prerequisites、Workflow、Rules、Examples、Review List、References 八个目录；
- **引用层次**：SKILL.md 直接链接 `references/` 下文件为一层，`references/` 文件不应再链接外部资源；

## Prerequisites

- 已安装 `skill-evolve`（本技能依赖其 template.md 和 directory-structure.md）；
- 明确技能要解决什么问题、在什么场景下触发；
- 了解该领域的相关知识。

## Workflow

0. **前置检查** — 确保创建条件已满足；
    - 判断目标技能目录名是否已存在：
        - 是 -> 检查 SKILL.md 是否已存在：
            - 是 -> 通过 AskUserQuestion 提供选项（覆盖现有文件 / 终止），阻塞等待用户选择；
            - 否 -> 下一步；
        - 否 -> 下一步；
    - 判断 `template.md` 是否可访问：
        - 是 -> 下一步；
        - 否 -> 报告“模板文件不可访问”，终止流程；

1. **收集需求** — 通过 AskUserQuestion 了解技能信息；
    - 向用户提出最多 4 个问题（技能任务/领域、具体用例、是否需要脚本、参考资料、与其他技能的关系）；
    - 阻塞等待用户回答；

2. **创建目录结构** — 参照 [目录结构标准](../skill-evolve/references/directory-structure.md) 创建文件和文件夹；
    - 判断是否至少创建了 `SKILL.md`：
        - 是 -> 下一步；
        - 否 -> 创建 `SKILL.md`；

3. **起草 SKILL.md** — 按模板组织内容；
    - 参照 [SKILL 模板](../skill-evolve/template.md) 按标准目录顺序组织内容；
    - description 须遵循 [Rules](#rules) 中的格式要求；
    - 每个目录写入引导语，帮助 AI 理解该目录用途；
    - 判断行数是否超过 300 行：
        - 是 -> 拆分到 `references/`；
        - 否 -> 下一步；

4. **添加辅助目录** — 评估并创建辅助目录；
    - 依次判断是否需要以下目录：
        - `references/`：非模板标准但有用的内容移入此处；
        - `scripts/`：确定性操作、重复生成的代码、需显式错误处理的逻辑；
        - `assets/`：模板、图片等静态资源；
        - `schemas/`：需与其他技能传递数据的场景；
        - `tests/`：工程化测试场景；

5. **与用户复核** — 展示草稿并确认；
    - 通过 AskUserQuestion 提供选项（无需修改，通过 / 需要修改后复核通过 / 不满意，重新起草），阻塞等待用户选择；
    - 用户选择“需要修改” -> 根据反馈修改后返回步骤 5；
    - 用户选择“不满意，重新起草” -> 返回步骤 3；
    - 用户选择“通过” -> 下一步；

6. **复核检查** — 对照 [Review List](#review-list)，确认创建结果；
    - 判断 Review List 是否有内容：
        - 否 -> 直接进入下一步（成果输出）；
        - 是 -> 下一步；
    - 依次判断 [Review List](#review-list) 中每个检查项，是否通过：
        - 基于“复核检查示例”来显示输出内容；
        - 有任一检查失败 -> 终止流程；
        - 全部通过 -> 下一步；

7. **成果输出** — 输出创建总结，告知完成；
    - 输出结构化摘要（行数、覆盖目录、辅助目录等）；
    - 告知创建完成；

## Rules

### 内容规范

- description 须遵循格式：第一句说明技能能力，第二句说明触发条件（“当...时使用”），使用第三人称，不超过 1024 字符；
- SKILL.md 不超过 300 行；
- 引用层次不超过一层（SKILL.md 链接 `references/` 下文件为一层，`references/` 不应再链接外部资源）；
- 删除任何时效性信息；
- 保持术语一致；
- 包含具体示例且示例数值与规则一致；

### 交互规范

- 所有涉及用户抉择的交互环节，**必须**使用 `AskUserQuestion` 工具，禁止以纯文本追问代替；将问题与选项结构化传入 AskUserQuestion，每次调用不超过 4 个问题；

### 自洽性规范

- Review List 检查项必须覆盖 Rules 中所有约束性规则，确保 Rules 与 Review List 一一对应；

## Examples

### 对话交互示例

**示例：AI 根据触发条件自动唤起**

```markdown
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
AI   > 复核检查：参照 Review List 逐项确认 ✓
      技能创建完成！
```

### 复核检查示例

```markdown
AI > 进入复核检查，参照 Review List 逐项确认：

- name 字段：skill-create ✅
- description 格式：符合“当...时使用”规范 ✅
- 结构对齐：所有标准目录齐备 ✅
- 行数 150（<300，无需拆分）✅
- 示例已使用 ```markdown 代码块包裹 ✅
- 交互规范：使用 AskUserQuestion ✅
- …（剩余检查项已逐项通过，此处仅展示关键项）

✅ 全部通过，技能创建完成。
```

### 成果输出示例

```markdown
| 维度 | 说明 |
|------|------|
| 创建文件 | SKILL.md |
| 结构 | 对齐标准模板所有目录 |
| 行数 | 150 行（<300） |
| 辅助目录 | references/、scripts/ |
| description 格式 | 包含“当...时使用” |
| 交互范式 | 使用 AskUserQuestion |
| 分支格式 | 是 -> / 否 -> 完整 |
```

### 执行成功示例

```markdown
| 维度 | 说明 |
|------|------|
| 创建文件 | SKILL.md |
| 结构 | 对齐标准模板所有目录 |
| 行数 | 85 行（<300） |
| 辅助目录 | 无 |
```

## Review List

完成创建后，验证以下内容：

- **元数据检查**
  - [ ] name 字段：存在且内容正确，与 SKILL.md 所在目录名一致
  - [ ] description 格式：包含触发条件（“当...时使用”）、使用第三人称、不超过 1024 字符
- **内容质量检查**
  - [ ] SKILL.md 不超过 300 行
  - [ ] 无时效性信息（日期、版本号等均已清除）
  - [ ] 内容质量：术语一致，包含具体示例且示例数值与规则一致
  - [ ] 示例格式：所有示例已由 ```markdown 代码块包裹
- **引用检查**
  - [ ] 引用层次不超过一层
  - [ ] 无死链
- **完整性检查**
  - [ ] 所有标准目录齐全（Overview、Definitions、Prerequisites、Workflow、Rules、Examples、Review List、References）
  - [ ] Secure 步骤完整（前置检查、复核检查、成果输出）
  - [ ] 交互规范：所有用户抉择交互使用 AskUserQuestion，禁止纯文本追问
  - [ ] 自洽性：Review List 检查项与 Rules 约束规则一一对应，不遗漏

## References

- [SKILL 目录结构](../skill-evolve/references/directory-structure.md)
- [SKILL 模板](../skill-evolve/template.md)
