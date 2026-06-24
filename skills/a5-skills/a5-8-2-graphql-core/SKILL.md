---
name: nestjs-8-2-graphql-core
description: Review NestJS GraphQL core component implementation, covering Resolver, InputType, custom scalars, and Apollo Federation integration. Use this when users need to review or develop GraphQL resolution layer.
---

# NestJS GraphQL Core Components

## Overview

When AI encounters GraphQL Resolver or type definition code in a NestJS project, it automatically performs the following: review the usage of @Resolver, @Query, @Mutation decorators, check InputType and ObjectType definitions, evaluate custom scalars and Federation entity resolution, and provide improvement suggestions.

## Definitions

- <a id="resolver"></a>**Resolver**: A GraphQL resolver class defined using the @Resolver decorator, containing @Query, @Mutation, @ResolveField methods.
- <a id="inputtype"></a>**InputType**: A GraphQL input type defined using the @InputType decorator, used for parameter validation in Mutations.

## Prerequisites

- NestJS project environment (@nestjs/graphql); GraphQL resolver code accessible.

## Workflow

0. **Pre-check**; 1. **Analyze code**; 2. **Item-by-item review**; 3. **Provide modification suggestions**; 4. **Review check**; 5. **Output results**;

## Rules

- Interaction steps use AskUserQuestion.

## Examples

### Conversation Interaction Example

```markdown
User > Help me check the Resolver implementation
AI   > Triggered nestjs-8-2-graphql-core skill... 🟥 @ResolveField missing parent type handling.
```

## References

- [NestJS GraphQL Resolvers](https://docs.nestjs.com/graphql/resolvers)
- [skill-evolve Template](../../skill-evolve/template.md)
