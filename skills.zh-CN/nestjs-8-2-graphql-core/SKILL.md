---
name: nestjs-8-2-graphql-core
description: 审查 NestJS GraphQL 核心组件的实现，涵盖 Resolver、InputType、自定义标量和 Apollo Federation 集成。当用户需要审查或开发 GraphQL 解析层时使用。
---

# NestJS GraphQL 核心组件

## Overview

当 AI 在 NestJS 项目中遇到 GraphQL Resolver 或类型定义代码时，自动执行以下工作：审查 @Resolver、@Query、@Mutation 装饰器的使用，检查 InputType 和 ObjectType 定义，评估自定义标量和 Federation 实体解析，并提供改进建议。

## Definitions

- <a id="Resolver"></a>**Resolver**：使用 @Resolver 装饰器定义的 GraphQL 解析器类，包含 @Query、@Mutation、@ResolveField 方法。
- <a id="InputType"></a>**InputType**：使用 @InputType 装饰器定义的 GraphQL 输入类型，用于 Mutation 的参数验证。

## Prerequisites

- NestJS 项目环境（@nestjs/graphql）；GraphQL 解析器代码可访问。

## Workflow

0. **前置检查**；1. **分析代码**；2. **逐项审查**；3. **提供修改建议**；4. **复核检查**；5. **成果输出**；

## Rules

- 交互环节使用 AskUserQuestion。

## Examples

### 对话交互示例

```markdown
用户 > 帮我检查 Resolver 实现
AI   > 触发 nestjs-8-2-graphql-core 技能... 🟥 @ResolveField 缺少 parent 类型处理。
```

## References

- [NestJS GraphQL Resolvers](https://docs.nestjs.com/graphql/resolvers)
- [skill-evolve 模板](../../skill-evolve/template.md)
