---
name: zoom-out
description: 让 agent 缩小视角，提供更广泛的上下文或更高层次的视角。当用户不熟悉某段代码或需要理解它如何融入全局时使用。
disable-model-invocation: true
---

# Zoom Out

## Overview

当 agent 对某段代码不熟悉时，触发 zoom-out 视角：向上抽象一层，生成相关模块与调用者的全局地图，使用项目领域术语表词汇，帮助理解代码在整体架构中的位置。

## Definitions

- **Zoom Out**：从当前代码片段向上抽象，展示模块间关系、调用链和架构角色的全景视角；
- **模块地图**：列出当前文件/模块的上下游依赖、调用者和被调用者的结构化视图。

## Prerequisites

- 当前项目有可浏览的代码库，agent 可访问相关源文件；
- 项目存在领域术语表或约定俗成的命名规范更佳，非必须。

## Workflow

1. 理解用户指定的目标代码（文件、函数、模块或代码片段）；
2. 向上抽象一层，识别目标代码所属的模块及其在架构中的角色；
3. 搜索并列出调用该模块的上游调用者，以及该模块依赖的下游模块；
4. 使用项目领域术语表词汇组织输出，生成模块地图；
5. 向用户呈现模块地图，说明目标代码如何融入全局。

## Rules

- 始终向上抽象一层，不深入到实现细节；
- 使用项目已有的领域术语，避免引入新术语；
- 若项目无领域术语表，根据代码命名惯例推断术语；
- 输出以结构化的地图形式呈现，而非长篇描述。

## Examples

### 对话交互示例

**示例：AI 根据用户请求触发 zoom-out**

```
用户 > 这段代码我不太熟悉，帮我 zoom out 一下

AI > 触发 zoom-out 视角，开始分析...

目标代码：UserAuthService.authenticate()
所属模块：auth（认证模块）

┌─────────────────────────────────────────┐
│              调用者                      │
│  LoginController (web/login)            │
│  ApiGateway (gateway/)                  │
│  SessionManager (core/session)          │
└──────────────┬──────────────────────────┘
               │
    UserAuthService.authenticate()
               │
┌──────────────┴──────────────────────────┐
│              依赖                       │
│  PasswordHasher (crypto/)               │
│  UserRepository (data/user)             │
│  TokenService (auth/token)              │
│  AuditLogger (core/logging)             │
└─────────────────────────────────────────┘

UserAuthService 位于 auth 模块，负责用户身份验证。
上游由 LoginController、ApiGateway 等入口调用；
下游依赖加密、数据访问和令牌服务。
```

### 执行成功示例

| 维度 | 说明 |
|------|------|
| 目标代码 | UserAuthService.authenticate() |
| 所属模块 | auth（认证模块） |
| 上游调用者 | 3 个（LoginController、ApiGateway、SessionManager） |
| 下游依赖 | 4 个（PasswordHasher、UserRepository、TokenService、AuditLogger） |
| 输出形式 | 结构化模块地图 |

## Review List

- [ ] 输出包含目标代码所属模块及架构角色
- [ ] 列出了上游调用者和下游依赖
- [ ] 使用了项目领域术语
- [ ] 输出为结构化地图形式，非长篇描述

## References

暂无（本技能无需外部参考文档）。
