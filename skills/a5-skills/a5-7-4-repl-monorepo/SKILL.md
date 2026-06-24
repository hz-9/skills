---
name: nestjs-7-4-repl-monorepo
description: Review NestJS interactive terminal (REPL) and Monorepo compilation control, covering NestJS REPL usage and tsconfig configuration optimization. Use this when users need to review project compilation configuration or debug runtime state.
---

# NestJS Interactive Terminal & Monorepo

## Overview

When AI encounters REPL or Monorepo configuration code in a NestJS project, it automatically performs the following: review the usage of REPL startup configuration, check the project reference configuration in tsconfig for Monorepo mode, evaluate the reasonableness of compilation configuration, and provide improvement suggestions.

## Definitions

- <a id="target-code"></a>**Target Code**: The NestJS REPL startup code or Monorepo tsconfig configuration code from the current conversation.
- <a id="repl"></a>**REPL**: NestJS interactive terminal (Read-Eval-Print-Loop), started using the repl() function, used for runtime debugging.
- <a id="monorepo"></a>**Monorepo**: NestJS multi-project repository mode, managed through tsconfig project references and nest-cli projects configuration.

## Prerequisites

- NestJS project environment; understanding of TypeScript project reference configuration.

## Workflow

0. **Pre-check** — Ensure target code exists and is readable;
1. **Analyze code** — Read REPL configuration or Monorepo tsconfig;
2. **Item-by-item review** — Check if REPL uses bootstrap function wrapping, if Monorepo project references are correct;
3. **Provide modification suggestions** — Confirm via AskUserQuestion;
4. **Review check**;
5. **Output results**;

## Rules

- description uses third person; interaction steps use AskUserQuestion;

## Examples

### Conversation Interaction Example

```markdown
User > Help me check the REPL configuration
AI   > Triggered nestjs-7-4-repl-monorepo skill...
Review Results:
- 🟩 bootstrap function wraps repl()
- 🟥 Missing await app.close() for graceful shutdown
```

## References

- [NestJS REPL](https://docs.nestjs.com/fundamentals/repl)
- [NestJS Monorepo](https://docs.nestjs.com/cli/monorepo)
- [skill-evolve Template](../../skill-evolve/template.md)
