---
name: nestjs-7-4-repl-monorepo
description: 审查 NestJS 交互式终端（REPL）和 Monorepo 编译控制，涵盖 NestJS REPL 使用和 tsconfig 配置优化。当用户需要审查项目编译配置或调试运行时状态时使用。
---

# NestJS 交互式终端与 Monorepo

## Overview

当 AI 在 NestJS 项目中遇到 REPL 或 Monorepo 配置代码时，自动执行以下工作：审查 REPL 启动配置的使用方式，检查 Monorepo 模式下 tsconfig 的项目引用配置，评估编译配置的合理性，并提供改进建议。

## Definitions

- <a id="目标代码"></a>**目标代码**：当前对话中 NestJS 的 REPL 启动代码或 Monorepo tsconfig 配置代码。
- <a id="REPL"></a>**REPL**：NestJS 的交互式终端（Read-Eval-Print-Loop），使用 repl() 函数启动，用于运行时调试。
- <a id="Monorepo"></a>**Monorepo**：NestJS 的多项目仓库模式，通过 tsconfig 的项目引用和 nest-cli 的 projects 配置管理。

## Prerequisites

- NestJS 项目环境；了解 TypeScript 项目引用配置。

## Workflow

0. **前置检查** — 确保目标代码存在且可读取；
1. **分析代码** — 读取 REPL 配置或 Monorepo tsconfig；
2. **逐项审查** — 检查 REPL 是否使用 bootstrap 函数包装、Monorepo 的 project 引用是否正确；
3. **提供修改建议** — 通过 AskUserQuestion 确认；
4. **复核检查**；
5. **成果输出**；

## Rules

- description 使用第三人称；交互环节使用 AskUserQuestion；

## Examples

### 对话交互示例

```markdown
用户 > 帮我检查 REPL 配置
AI   > 触发 nestjs-7-4-repl-monorepo 技能...
审查结果：
- 🟩 bootstrap 函数包装了 repl()
- 🟥 未添加 await app.close() 优雅退出
```

## References

- [NestJS REPL](https://docs.nestjs.com/fundamentals/repl)
- [NestJS Monorepo](https://docs.nestjs.com/cli/monorepo)
- [skill-evolve 模板](../../skill-evolve/template.md)
