---
name: skill-create
description: 参考 skill-evolve 的标准创建新的 agent 技能。当用户需要创建、编写或构建一个新技能时使用。
disable-model-invocation: true
---

# Skill Create

## Overview

从零创建 agent 技能。**参考 skill-evolve 的标准创建一个 SKILL，有什么不确定的事情，都向用户进行询问，有什么未知的信息和定位，都向用户进行询问。**

## Definitions

暂无内容

## Prerequisites

暂无内容

## Workflow

0. **前置检查** — 确认 skill-evolve 的 template.md 和 directory-structure.md 可访问：
    - 是 -> 下一步；
    - 否 -> 报告缺失文件，终止流程；
1. **创建技能** — 参照 template.md 和 directory-structure.md 创建目录结构和 SKILL.md。创建过程中遇到任何不确定的决策，通过 AskUserQuestion 向用户询问；
2. **复核检查** — 对照 [Review List](#review-list)，确认执行结果：
    - 判断 Review List 是否有内容：
        - 否 -> 直接进入下一步（成果输出）；
        - 是 -> 逐项验收：
            - 全部通过 -> 下一步；
            - 存在未通过项 -> 终止流程；
3. **成果输出** — 输出结构化摘要，告知创建完成。

## Rules

- 创建过程中任何不确定的事情（技能名称、描述内容、是否需要辅助目录、内容取舍等），**必须**使用 AskUserQuestion 向用户询问，禁止自行假设。

## Examples

暂无内容

## Review List

暂无内容

## References

- [SKILL 模板](../skill-evolve/template.md)
- [SKILL 目录结构](../skill-evolve/references/directory-structure.md)
