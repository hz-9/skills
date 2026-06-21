---
name: nestjs-9-1-cqrs
description: Review NestJS CQRS architectural pattern implementation, covering Command/Query bus, event sourcing, and Sagas orchestration. Use this when users need to review CQRS logic or design event-driven architecture.
---

# NestJS CQRS Architecture Pattern

## Overview

When AI encounters CQRS-related code in a NestJS project, it automatically performs the following: review the separation design of Command and Query, check @nestjs/cqrs module integration, evaluate Saga orchestration and event sourcing strategies, and provide improvement suggestions.

## Definitions

- <a id="command"></a>**Command**: A command object implementing the ICommand interface, dispatched through CommandBus and handled by CommandHandler.
- <a id="query"></a>**Query**: A query object implementing the IQuery interface, dispatched through QueryBus and handled by QueryHandler.
- <a id="event"></a>**Event**: An event object implementing the IEvent interface, published through EventBus and handled by EventsHandler.

## Prerequisites

- NestJS project environment (@nestjs/cqrs dependency); CQRS-related code accessible.

## Workflow

0. **Pre-check**; 1. **Analyze code**; 2. **Item-by-item review** — Check Command/Query separation, Saga orchestration, event sourcing;
3. **Provide modification suggestions**; 4. **Review check**; 5. **Output results**;

## Rules

- Interaction steps use AskUserQuestion; CQRS applicability should be marked as architectural decision.

## Examples

### Conversation Interaction Example

```markdown
User > Help me check the CQRS implementation
AI   > Triggered nestjs-9-1-cqrs skill...
Review Results:
- 🟩 Command and Query correctly separated
- 🟩 @CommandHandler registered correctly
- 🟥 Saga missing @Saga decorator
User > Help me add @Saga
```

## References

- [NestJS CQRS](https://docs.nestjs.com/recipes/cqrs)
- [skill-evolve Template](../../skill-evolve/template.md)
