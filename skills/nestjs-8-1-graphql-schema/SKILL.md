---
name: nestjs-8-1-graphql-schema
description: Review NestJS GraphQL schema-driven (Schema First / Code First) implementation, covering SDL definition, AutoSchema, and Federation. Use this when users need to review GraphQL Schema design.
---

# NestJS GraphQL Schema-Driven Architecture

## Overview

When AI encounters GraphQL Schema-related code in a NestJS project, it automatically performs the following: review the selection and configuration of Schema First and Code First approaches, check @nestjs/graphql module integration, evaluate the reasonableness of Federation architecture, and provide improvement suggestions.

## Definitions

- <a id="schema-first"></a>**Schema First**: A development approach where GraphQL SDL (Schema Definition Language) files are defined first, then NestJS automatically generates TypeScript types.
- <a id="code-first"></a>**Code First**: A development approach where types are defined in TypeScript using decorators (@ObjectType, @Field) first, then NestJS automatically generates SDL.

## Prerequisites

- NestJS project environment (@nestjs/graphql, @nestjs/apollo or @nestjs/mercurius);
- GraphQL configuration code accessible.

## Workflow

0. **Pre-check** — Ensure target code and runtime environment are reachable;
1. **Analyze code** — Read GraphQL module configuration and Schema definitions;
2. **Item-by-item review** — Check GraphQLModule.forRoot configuration, schema generation approach selection, Federation configuration;
3. **Provide modification suggestions**;
4. **Review check**;
5. **Output results**;

## Rules

- Interaction steps use AskUserQuestion; schema approach selection should be marked as architectural decision.

## Examples

### Conversation Interaction Example

```markdown
User > Help me check the GraphQL configuration
AI   > Triggered nestjs-8-1-graphql-schema skill...
Review Results:
- 🟩 GraphQLModule.forRoot configuration is correct
- 🟥 Federation missing @key decorator for entity key definition
```

## References

- [NestJS GraphQL](https://docs.nestjs.com/graphql/quick-start)
- [skill-evolve Template](../../skill-evolve/template.md)
