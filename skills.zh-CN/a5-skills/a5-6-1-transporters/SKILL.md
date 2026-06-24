---
name: nestjs-6-1-transporters
description: 审查 NestJS 微服务传输协议的选择与配置，涵盖 TCP、Redis、RabbitMQ、Kafka 和 gRPC 传输器。当用户需要审查微服务配置或选择传输策略时使用。
---

# NestJS 微服务传输协议

## Overview

当 AI 在 NestJS 项目中遇到微服务传输配置代码时，自动执行以下工作：审查传输器的选择和配置正确性，检查微服务客户端和服务端的设置匹配，评估传输层安全性和可靠性，并提供改进建议。

## Definitions

- <a id="传输器"></a>**传输器**：NestJS 微服务的传输层实现，包括 TCP、Redis、RabbitMQ、Kafka、NATS、gRPC、MQTT。
- <a id="@MessagePattern"></a>**@MessagePattern**：微服务中处理请求-响应消息的装饰器。

## Prerequisites

- NestJS 项目环境（@nestjs/microservices）；
- 微服务传输器配置代码可访问。

## Workflow

0. **前置检查** — 确保目标代码存在且可读取；
1. **分析配置** — 读取微服务传输器配置和服务端/客户端代码；
2. **逐项审查** — 检查传输器选择是否适合场景、客户端服务端配置是否匹配、错误处理是否完善；
3. **提供修改建议** — 通过 AskUserQuestion 确认；
4. **复核检查**；
5. **成果输出**；

## Rules

- description 使用第三人称；交互环节使用 AskUserQuestion；传输器选择标注为架构建议。

## Examples

### 对话交互示例

```markdown
用户 > 帮我检查微服务配置
AI   > 触发 nestjs-6-1-transporters 技能...
审查结果：
- 🟩 TCP 传输器配置正确
- 🟥 Redis 传输端口与服务端不匹配
- 🟩 服务使用 @MessagePattern 处理消息
用户 > 帮我修正端口
```

## References

- [NestJS Microservices](https://docs.nestjs.com/microservices/basics)
- [skill-evolve 模板](../../skill-evolve/template.md)
