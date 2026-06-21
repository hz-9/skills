---
name: nestjs-6-1-transporters
description: Review NestJS microservice transport protocol selection and configuration, covering TCP, Redis, RabbitMQ, Kafka, and gRPC transporters. Use this when users need to review microservice configuration or choose transport strategies.
---

# NestJS Microservice Transport Protocols

## Overview

When AI encounters microservice transport configuration code in a NestJS project, it automatically performs the following: review the correctness of transporter selection and configuration, check the matching of client and server microservice settings, evaluate transport layer security and reliability, and provide improvement suggestions.

## Definitions

- <a id="transporter"></a>**Transporter**: The transport layer implementation of NestJS microservices, including TCP, Redis, RabbitMQ, Kafka, NATS, gRPC, MQTT.
- <a id="messagepattern"></a>**@MessagePattern**: Decorator for handling request-response messages in microservices.

## Prerequisites

- NestJS project environment (@nestjs/microservices);
- Microservice transporter configuration code accessible.

## Workflow

0. **Pre-check** — Ensure target code exists and is readable;
1. **Analyze configuration** — Read microservice transporter configuration and server/client code;
2. **Item-by-item review** — Check if transporter selection fits the scenario, if client and server configurations match, and if error handling is complete;
3. **Provide modification suggestions** — Confirm via AskUserQuestion;
4. **Review check**;
5. **Output results**;

## Rules

- description uses third person; interaction steps use AskUserQuestion; transporter selection should be marked as architectural suggestion.

## Examples

### Conversation Interaction Example

```markdown
User > Help me check the microservice configuration
AI   > Triggered nestjs-6-1-transporters skill...
Review Results:
- 🟩 TCP transporter configuration is correct
- 🟥 Redis transport port does not match server
- 🟩 Service uses @MessagePattern to handle messages
User > Help me fix the port
```

## References

- [NestJS Microservices](https://docs.nestjs.com/microservices/basics)
- [skill-evolve Template](../../skill-evolve/template.md)
