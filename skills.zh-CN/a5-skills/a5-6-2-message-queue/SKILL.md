---
name: nestjs-6-2-message-queue
description: 审查 NestJS 消息队列与事件驱动架构的实现，涵盖 @MessagePattern、@EventPattern 和异步消息处理。当用户需要审查消息驱动代码或事件总线设计时使用。
---

# NestJS 消息队列与事件驱动

## Overview

审查微服务消息队列和事件驱动架构的实现，检查 @MessagePattern 和 @EventPattern 的使用，评估消息确认和重试策略，并提供改进建议。

## Definitions

- <a id="@EventPattern"></a>**@EventPattern**：微服务中处理事件消息的装饰器（发布-订阅模式，无需返回响应）。
- <a id="消息确认"></a>**消息确认**：使用 @MessagePattern 时客户端等待服务端响应的确认机制。

## Workflow

0. **前置检查**；1. **分析代码**；2. **逐项审查** — 检查消息确认、重试、死信队列；3. **提供修改建议**；4. **复核检查**；5. **成果输出**；

## Rules

- 交互环节使用 AskUserQuestion；消息策略标注为架构建议。

## Examples

### 对话交互示例

```markdown
用户 > 帮我检查消息队列代码
AI   > 触发 nestjs-6-2-message-queue 技能... 🟥 缺少错误重试机制，建议添加。
```

## References

- [NestJS Microservices](https://docs.nestjs.com/microservices/basics)
- [skill-evolve 模板](../../skill-evolve/template.md)
