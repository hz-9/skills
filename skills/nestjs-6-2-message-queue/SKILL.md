---
name: nestjs-6-2-message-queue
description: Review NestJS message queue and event-driven architecture implementation, covering @MessagePattern, @EventPattern, and asynchronous message handling. Use this when users need to review message-driven code or event bus design.
---

# NestJS Message Queue & Event-Driven Architecture

## Overview

Review microservice message queue and event-driven architecture implementation, check the usage of @MessagePattern and @EventPattern, evaluate message acknowledgment and retry strategies, and provide improvement suggestions.

## Definitions

- <a id="eventpattern"></a>**@EventPattern**: Decorator for handling event messages in microservices (publish-subscribe pattern, no response required).
- <a id="message-acknowledgment"></a>**Message Acknowledgment**: The acknowledgment mechanism where a client waits for the server's response when using @MessagePattern.

## Workflow

0. **Pre-check**; 1. **Analyze code**; 2. **Item-by-item review** — Check message acknowledgment, retry, dead letter queue; 3. **Provide modification suggestions**; 4. **Review check**; 5. **Output results**;

## Rules

- Interaction steps use AskUserQuestion; message strategy should be marked as architectural suggestion.

## Examples

### Conversation Interaction Example

```markdown
User > Help me check the message queue code
AI   > Triggered nestjs-6-2-message-queue skill... 🟥 Missing error retry mechanism, recommend adding.
```

## References

- [NestJS Microservices](https://docs.nestjs.com/microservices/basics)
- [skill-evolve Template](../../skill-evolve/template.md)
