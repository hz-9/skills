---
name: skill-create
description: 参考 skill-evolve 的标准创建新的 agent 技能。当用户需要创建、编写或构建一个新技能时使用。
disable-model-invocation: true
---

# Skill Create

## Overview

从零创建 agent 技能。参考 skill-evolve 的标准模板创建 SKILL.md 及辅助目录，对不确定的决策通过 AskUserQuestion 向用户询问确认。创建完成后可交由 skill-evolve 进一步优化。

## Definitions

- <a id="标准模板结构"></a>**标准模板结构**：包含 Overview、Definitions、Prerequisites、Workflow、Rules、Examples、Review List、References 八个标准目录的结构；
- <a id="引用层次"></a>**引用层次**：SKILL.md 直接链接 `references/` 下文件为一层，`references/` 文件不应再链接外部资源；
- <a id="Secure-步骤"></a>**Secure 步骤**：Workflow 中固定出现的三个标准化步骤：前置检查（首个步骤）、复核检查（倒数第二个步骤）、成果输出（末尾步骤）；

## Prerequisites

- 已安装 `skill-evolve`（本技能依赖其 template.md 和 directory-structure.md）；
- 明确需要创建的技能要解决什么问题、在什么场景下触发；
- 了解该领域的相关知识。

## Workflow

0. **前置检查** — 确认 skill-evolve 的 template.md 和 directory-structure.md 可访问；
  - 判断 template.md 和 directory-structure.md 是否存在且可读取：
    - 是 -> 下一步；
    - 否 -> 报告缺失文件，终止流程；
  - 判断目标技能目录名是否已存在：
    - 是 -> 检查 SKILL.md 是否已存在：
      - 是 -> 通过 AskUserQuestion 提供选项，阻塞等待用户选择：
        - 覆盖现有文件 -> 覆盖后进入下一步；
        - 终止 -> 终止流程；
      - 否 -> 下一步；
    - 否 -> 下一步；
1. **收集需求** — 通过 AskUserQuestion 了解技能信息；
  - 通过 AskUserQuestion 提供选项，阻塞等待用户选择：
    - [动态选项，由 AI 根据需求生成最多 4 个问题] -> 记录回答，执行后进入下一步；
2. **创建目录结构** — 参照 [目录结构标准](../skill-evolve/references/directory-structure.md) 创建文件和文件夹；
  - 判断是否至少创建了 `SKILL.md`：
    - 是 -> 下一步；
    - 否 -> 创建 `SKILL.md`，执行后进入下一步；
3. **起草 SKILL.md** — 按模板组织内容；
  - 参照 [SKILL 模板](../skill-evolve/template.md) 按标准目录顺序组织内容；
  - description 须遵循 Rules 中的格式要求；
  - 每个目录写入引导语，帮助 AI 理解该目录用途；
  - 判断行数是否超过 300 行：
    - 是 -> 拆分到 `references/`，执行后进入下一步；
    - 否 -> 下一步；
4. **添加辅助目录** — 通过 AskUserQuestion 评估并创建辅助目录；
  - 若 `references/` 目录已在步骤 3 中因行数拆分而创建，跳过 `references/` 的判断；
  - 依次通过 AskUserQuestion 询问用户是否需要以下目录，逐一确认：
    - 是否需要 `references/` 目录：
      - 是 -> 创建 `references/` 目录，继续下一个判断；
      - 否 -> 跳过，继续下一个判断；
    - 是否需要 `scripts/` 目录：
      - 是 -> 创建 `scripts/` 目录，继续下一个判断；
      - 否 -> 跳过，继续下一个判断；
    - 是否需要 `assets/` 目录：
      - 是 -> 创建 `assets/` 目录，继续下一个判断；
      - 否 -> 跳过，继续下一个判断；
    - 是否需要 `schemas/` 目录：
      - 是 -> 创建 `schemas/` 目录，继续下一个判断；
      - 否 -> 跳过，继续下一个判断；
    - 是否需要 `tests/` 目录：
      - 是 -> 创建 `tests/` 目录，执行后进入下一步；
      - 否 -> 下一步；
5. **与用户复核** — 展示草稿并确认；
  - 通过 AskUserQuestion 提供选项，阻塞等待用户选择：
    - 无需修改，通过 -> 下一步；
    - 需要修改后复核通过 -> 根据反馈修改后返回步骤 5（同一轮内最多 3 次修改，超限后自动进入下一步）；
    - 不满意，重新起草 -> 返回步骤 3；
6. **复核检查** — 对照 [Review List](#review-list)，确认创建结果；
  - 判断 Review List 是否有内容：
    - 否 -> 直接进入下一步（成果输出）；
    - 是 -> 下一步；
  - 依次判断 [Review List](#review-list) 中每个检查项，是否通过：
    - 是 -> 继续下一个检查项；
    - 否 -> 记录失败检查项（基于“复核检查示例”显示输出内容），继续下一个检查项；
  - 判断是否有任一检查失败：
    - 是 -> 终止流程；
    - 否 -> 进入下一步（成果输出）；
7. **成果输出** — 输出结构化摘要，告知创建完成；
  - 输出结构化摘要（创建文件、行数、覆盖目录、辅助目录等）；
  - 告知用户创建完成；

## Rules

- description 须遵循格式：第一句说明技能能力，第二句说明触发条件（“当...时使用”），使用第三人称，不超过 1024 字符；
- SKILL.md 不超过 300 行，超过则拆分到 `references/`；
- 引用层次不超过一层（SKILL.md 链接 `references/` 下文件为一层，`references/` 不应再链接外部资源）；
- 删除任何时效性信息，保持术语一致；
- 包含具体示例且示例数值与规则一致；
- 所有涉及用户抉择的交互环节，**必须**使用 `AskUserQuestion` 工具，禁止以纯文本追问代替；将问题与选项结构化传入 AskUserQuestion，每次调用不超过 4 个问题；
- 创建过程中任何不确定的事情（技能名称、描述内容、是否需要辅助目录、内容取舍等），**必须**使用 AskUserQuestion 向用户询问，禁止自行假设；
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
AI   > 按模板结构起草 SKILL.md...
AI   > 请复核草稿，这覆盖了你的用例吗？
用户 > 看起来不错
```

### 复核检查示例

**复核检查全部通过示例**

```markdown
AI > 进入复核检查，参照 Review List 逐项确认：

- name 字段：skill-create ✅
- description 格式：符合“当...时使用”规范 ✅
- 结构对齐：所有标准目录齐备 ✅
- 行数 150（<300，无需拆分）✅
- 示例已使用 ```markdown 代码块包裹 ✅
- 交互规范：使用 AskUserQuestion ✅

✅ 全部通过，技能创建完成。
```

**复核检查失败终止示例**

```markdown
AI > 进入复核检查，Review List 包含 13 个检查项，开始逐项验收：

**元数据检查**
  - 🟩 name 字段：skill-create，与目录名一致
  - 🟥 description 格式：缺少“当...时使用”

**内容质量检查**
  - 🟩 SKILL.md 150 行（<300）
  - 🟥 示例未使用 ```markdown 代码块包裹

**！！！以下检查项未通过！！！**
  - 🟥 description 格式：缺少“当...时使用”
  - 🟥 示例格式：未使用 markdown 代码块包裹

终止流程，建议修正后重新执行。
```

（AI 运行时将逐项输出全部检查项结果）

### 成果输出示例

**创建结果示例**

```markdown
| 维度 | 说明 |
|------|------|
| 创建文件 | SKILL.md |
| 结构 | 对齐标准模板所有目录 |
| 行数 | 150 行（<300） |
| description 格式 | 包含“当...时使用” |
| 交互范式 | 使用 AskUserQuestion |
```

## Review List

完成创建后，验证以下内容：

- **元数据检查**
  - [ ] name 字段：存在且内容正确，与 SKILL.md 所在目录名一致
  - [ ] description 格式：第一句说明技能能力，第二句说明触发条件（“当...时使用”）、使用第三人称、不超过 1024 字符
- **内容质量检查**
  - [ ] SKILL.md 不超过 300 行
  - [ ] 无时效性信息（日期、版本号等均已清除）
  - [ ] 内容质量：术语一致，包含具体示例且示例数值与规则一致
  - [ ] 示例格式：所有示例已由 ```markdown 代码块包裹
- **引用检查**
  - [ ] 引用层次不超过一层
  - [ ] 无死链
- **自洽性检查**
  - [ ] 所有标准目录齐全（Overview、Definitions、Prerequisites、Workflow、Rules、Examples、Review List、References）
  - [ ] Secure 步骤完整（前置检查、复核检查、成果输出）
  - [ ] 交互规范：所有用户抉择交互使用 AskUserQuestion，禁止纯文本追问；每次 AskUserQuestion 调用不超过 4 个问题，问题与选项需结构化传入
  - [ ] 禁止自行假设：创建过程中任何不确定的事情必须通过 AskUserQuestion 向用户询问确认，禁止 AI 自行假设
  - [ ] 自洽性：Review List 检查项与 Rules 约束规则一一对应，不遗漏

## References

- [SKILL 目录结构](../skill-evolve/references/directory-structure.md)：定义技能目录结构标准和辅助目录规范
- [SKILL 模板](../skill-evolve/template.md)：技能标准模板，包含所有标准目录的职责说明和编写指引
