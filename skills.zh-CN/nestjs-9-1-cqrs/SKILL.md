---
name: nestjs-9-1-cqrs
description: 审查 NestJS CQRS 架构模式的实现，涵盖 Command/Query 总线、事件溯源和 Sagas 编排。当用户需要审查 CQRS 逻辑或设计事件驱动架构时使用。
---

# NestJS CQRS 架构模式

## Overview

当 AI 在 NestJS 项目中遇到 CQRS 相关代码时，自动执行以下工作：审查 Command 和 Query 的分离设计，检查 @nestjs/cqrs 模块的集成，评估 Saga 编排和事件溯源策略，并提供改进建议。

## Definitions

- <a id="Command"></a>**Command**：实现 ICommand 接口的命令对象，通过 CommandBus 分发，由 CommandHandler 处理。
- <a id="Query"></a>**Query**：实现 IQuery 接口的查询对象，通过 QueryBus 分发，由 QueryHandler 处理。
- <a id="Event"></a>**Event**：实现 IEvent 接口的事件对象，通过 EventBus 发布，由 EventsHandler 处理。

## Prerequisites

- NestJS 项目环境（@nestjs/cqrs 依赖）；CQRS 相关代码可访问。

## Workflow

0. **前置检查**；1. **分析代码**；2. **逐项审查** — 检查 Command/Query 分离、Saga 编排、事件溯源；
3. **提供修改建议**；4. **复核检查**；5. **成果输出**；

## Rules

- 交互环节使用 AskUserQuestion；CQRS 适用性标注为架构决策。

## Examples

### 对话交互示例

```markdown
用户 > 帮我检查 CQRS 实现
AI   > 触发 nestjs-9-1-cqrs 技能...
审查结果：
- 🟩 Command 和 Query 正确分离
- 🟩 @CommandHandler 注册正确
- 🟥 Saga 缺少 @Saga 装饰器
用户 > 帮我添加 @Saga
```

## References

- [NestJS CQRS](https://docs.nestjs.com/recipes/cqrs)
- [skill-evolve 模板](../../skill-evolve/template.md)
