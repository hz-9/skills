---
name: nestjs-3-4-websockets
description: 审查 NestJS WebSocket 网关与通信实现，涵盖 @WebSocketGateway、事件处理、房间管理和鉴权策略。当用户需要审查或开发实时通信功能时使用。
---

# NestJS 网络通信与 WebSockets

## Overview

当 AI 在 NestJS 项目中遇到 WebSocket 相关代码时，自动执行以下工作：审查 WebSocket 网关的配置和事件处理，检查房间管理和广播机制，评估连接鉴权和异常处理策略，并提供改进建议。

## Definitions

- <a id="目标代码"></a>**目标代码**：当前对话中 NestJS 的 WebSocket 网关实现代码或客户端通信代码。
- <a id="网关"></a>**网关**：使用 @WebSocketGateway 装饰器标记的类，处理 WebSocket 连接、事件收发和房间管理。
- <a id="WebSocket 异常过滤器"></a>**WebSocket 异常过滤器**：实现 WsExceptionFilter 接口的过滤器，专门处理 WebSocket 场景中的异常。
- <a id="是否分析完成"></a>**是否分析完成**：标记对目标代码的分析是否已得出完整结果。

## Prerequisites

- NestJS 项目环境（包含 @nestjs/websockets 和 @nestjs/platform-socket.io 依赖）；
- WebSocket 网关代码文件可访问；
- 了解 WebSocket 协议和 Socket.io 基本用法。

## Workflow

0. **前置检查** — 确保目标代码和运行环境可达；
   - 判断目标代码是否存在且可读取：
     - 是 -> 下一步；
     - 否 -> 提示用户提供目标代码或文件路径，阻塞等待用户输入；
   - 初始化全局变量 [是否分析完成](#是否分析完成)：
     - 判断代码是否完整可解析：
       - 满足 -> 初始化变量为 true；
       - 不满足 -> 初始化变量为 false；

1. **分析 WebSocket 代码** — 读取并理解网关和事件处理；
   - 读取目标代码，识别以下核心要素：
     - @WebSocketGateway 装饰器的配置（namespace、port、cors）；
     - @SubscribeMessage 装饰的事件处理方法；
     - 使用 @WebSocketServer 注入的服务端实例；
     - 房间管理操作（joinRoom / leaveRoom）；
     - 网关中注入的其他服务；

2. **逐项审查** — 对照审查清单检查 WebSocket 代码质量；
   - 依次判断以下审查项是否通过：
     - 是否配置了 CORS（@WebSocketGateway 的 cors 选项避免跨域问题）：
       - 通过 -> 记录通过，继续下一个审查项；
       - 未通过 -> 记录“WebSocket 网关未配置 cors，可能在浏览器端出现跨域问题”，继续；
     - 连接和断开的生命周期钩子是否处理了必要的清理工作（handleConnection / handleDisconnect）：
       - 通过 -> 记录通过，继续下一个审查项；
       - 未通过 -> 记录“handleDisconnect 中缺少资源清理逻辑，可能导致连接泄漏”，继续；
     - 是否实现了 WebSocket 鉴权（在 handleConnection 中验证 token）：
       - 通过 -> 记录通过，继续下一个审查项；
       - 未通过 -> 记录“网关未实现连接鉴权，未授权客户端可以建立连接”，继续；
     - 事件处理器中错误是否被捕获（使用 WsException 或 try/catch）：
       - 通过 -> 记录通过，继续下一个审查项；
       - 未通过 -> 记录“事件处理器未捕获异常，可能导致客户端连接断开”，继续；
     - 是否使用了房间管理进行消息广播（避免向所有客户端发送消息）：
       - 通过 -> 记录通过，继续下一个审查项；
       - 未通过 -> 记录“建议使用 server.to(room).emit() 向特定房间广播替代全局广播”，继续；
   - 判断是否有任何问题记录：
     - 是 -> 汇总问题列表，进入下一步；
     - 否 -> 直接进入步骤 4（复核检查）；

3. **提供修改建议** — 对发现的问题给出具体修复方案；
   - 依次对每个问题提供修复建议；
   - 通过 AskUserQuestion 提供选项，阻塞等待用户选择：
     - 采纳全部建议 -> 生成修正后的代码，进入步骤 4；
     - 逐条确认 -> 逐条由用户决定采纳或忽略，全部确认后进入步骤 4；
     - 仅查看不修改 -> 不影响代码，直接进入步骤 4；

4. **复核检查** — 对照 [Review List](#review-list)，确认执行结果；
   - 判断 Review List 是否有内容：
     - 否 -> 直接进入下一步（成果输出）；
     - 是 -> 下一步；
   - 依次判断 [Review List](#review-list) 中每个检查项，是否通过：
     - 基于“复核检查示例”来显示输出内容；
   - 有任一检查失败，终止流程；
   - 全部通过后，进入下一步；

5. **成果输出** — 输出审查摘要，告知完成；
   - 输出结构化摘要表格（审查文件 / 审查项数 / 通过 / 发现问题 / 风险等级 / 已采纳建议）；
   - 告知审查完成；

## Rules

- **内容规范**
  - description 须遵循格式：第一句说明审查内容，第二句说明触发条件，使用第三人称，不超过 1024 字符；
  - 审查项须引用 NestJS 官方 WebSocket 文档；
  - SKILL.md 不超过 300 行；超过时拆分到 references/ 目录；
  - 引用层次不超过一层；
  - 保持术语一致，Definitions 中已定义术语在正文中通过锚点链接引用；
  - 删除任何时效性信息；

- **行为规范**
  - 审查时仅输出问题摘要和定位，不直接修改代码，除非用户通过 AskUserQuestion 明确要求；
  - 所有涉及代码修改的交互环节，必须使用 AskUserQuestion 工具；
  - 鉴权策略的具体实现（JWT / Session）标注为架构选择而非缺陷；

- **防御规范**
  - 如目标代码为空或不可读，直接报告并终止；
  - 房间广播优化建议仅在明确存在全局广播时提供，不强行要求使用房间；

- **验证规范**
  - Examples 内容必须自洽于 Rules；
  - Examples 必须包含复核检查示例；
  - 对话交互示例仅聚焦步骤 0~3（不含复核检查和成果输出）；

## Examples

### 对话交互示例

**示例：用户请求审查 WebSocket 网关**

```markdown
用户 > 帮我检查这个聊天网关的实现
AI   > 检测到用户需要 NestJS WebSocket 审查，触发 nestjs-3-4-websockets 技能
AI   > 正在分析网关代码...

审查结果：
- 🟥 @WebSocketGateway 未配置 cors 选项
- 🟩 handleDisconnect 中清理了用户房间
- 🟥 未在 handleConnection 中鉴权
- 🟩 事件错误使用了 WsException 处理
- 🟥 使用 server.emit 全局广播（应使用 room）

总评：3 个问题需要关注
用户 > 帮我添加鉴权和房间广播
AI   > 需要在 handleConnection 验证 token，并改用 to(room).emit。是否应用？
用户 > 全部采纳
```

### 复核检查示例

```markdown
AI > 进入复核检查，Review List 包含 5 个检查项，开始逐项验收：

**内容检查**
  - 🟩 审查项全部引用官方文档
  - 🟩 鉴权策略标注为架构选择

**行为检查**
  - 🟩 未直接修改用户代码
  - 🟩 使用了 AskUserQuestion

**验证检查**
  - 🟩 房间建议在全局广播时提供
  - 🟩 输出摘要完整

✅ 全部通过，进入成果输出。
```

### 成果输出示例

**审查结果示例：**

```markdown
| 维度 | 结果 |
| --- | --- |
| 审查文件 | src/chat/chat.gateway.ts |
| 审查项总数 | 6 项 |
| 通过 | 3 项 |
| 发现问题 | 3 项 |
| 风险等级 | 🟡 中 |
| 已采纳建议 | 3 条 |
```

## Review List

- **内容检查**
  - [ ] 审查项全部引用 NestJS 官方 WebSocket 文档
  - [ ] 鉴权策略标注为架构选择
- **行为检查**
  - [ ] 未直接修改用户代码（除非用户明确要求）
  - [ ] 所有交互环节使用了 AskUserQuestion
- **验证检查**
  - [ ] 目标代码为空或不可读时已正确终止
  - [ ] 房间广播在全局广播时提供建议
  - [ ] 输出摘要包含了文件路径、审查项数、发现问题和风险等级

## References

- [NestJS WebSocket 官方文档](https://docs.nestjs.com/websockets/gateways)
- [Socket.io 文档](https://socket.io/docs/v4/)
- [skill-evolve 模板](../../skill-evolve/template.md)
