---
name: nestjs-8-1-graphql-schema
description: 审查 NestJS GraphQL 模式驱动（Schema First / Code First）的实现，涵盖 SDL 定义、AutoSchema 和 Federation。当用户需要审查 GraphQL Schema 设计时使用。
---

# NestJS GraphQL 模式驱动与架构

## Overview

当 AI 在 NestJS 项目中遇到 GraphQL Schema 相关代码时，自动执行以下工作：审查 Schema First 和 Code First 两种模式的选择和配置，检查 @nestjs/graphql 模块集成，评估 Federation 架构的合理性，并提供改进建议。

## Definitions

- <a id="Schema First"></a>**Schema First**：先定义 GraphQL SDL（Schema Definition Language）文件，再由 NestJS 自动生成 TypeScript 类型的开发模式。
- <a id="Code First"></a>**Code First**：先使用装饰器（@ObjectType、@Field）在 TypeScript 中定义类型，再由 NestJS 自动生成 SDL 的开发模式。

## Prerequisites

- NestJS 项目环境（@nestjs/graphql、@nestjs/apollo 或 @nestjs/mercurius）；
- GraphQL 配置代码可访问。

## Workflow

0. **前置检查** — 确保目标代码和运行环境可达；
1. **分析代码** — 读取 GraphQL 模块配置和 Schema 定义；
2. **逐项审查** — 检查 GraphQLModule.forRoot 配置、模式生成方式选择、Federation 配置；
3. **提供修改建议**；
4. **复核检查**；
5. **成果输出**；

## Rules

- 交互环节使用 AskUserQuestion；模式选择标注为架构决策。

## Examples

### 对话交互示例

```markdown
用户 > 帮我检查 GraphQL 配置
AI   > 触发 nestjs-8-1-graphql-schema 技能...
审查结果：
- 🟩 GraphQLModule.forRoot 配置正确
- 🟥 Federation 缺少 @key 装饰器定义实体键
```

## References

- [NestJS GraphQL](https://docs.nestjs.com/graphql/quick-start)
- [skill-evolve 模板](../../skill-evolve/template.md)
