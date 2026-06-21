---
name: nestjs-7-3-standalone-apps
description: 审查 NestJS 独立应用程序模式的实现，涵盖非 HTTP 应用、微服务客户端和 CLI 工具场景。当用户需要审查或开发独立 NestJS 应用时使用。
---

# NestJS 独立应用程序

## Overview

当 AI 在 NestJS 项目中遇到独立应用（Standalone Application）相关代码时，自动执行以下工作：审查 NestFactory.createApplicationContext 的使用方式，检查独立应用中的服务获取和模块加载，评估适用场景，并提供改进建议。

## Definitions

- <a id="目标代码"></a>**目标代码**：当前对话中 NestJS 的独立应用创建代码或使用独立应用的场景代码。
- <a id="独立应用"></a>**独立应用**：使用 NestFactory.createApplicationContext 创建的 NestJS 应用实例，不启动 HTTP 服务器，仅用于后台脚本。

## Prerequisites

- NestJS 项目环境；了解 DI 容器和模块系统。

## Workflow

0. **前置检查** — 确保目标代码和运行环境可达；
   - 判断目标代码是否存在且可读取：
     - 是 -> 下一步；
     - 否 -> 提示用户提供代码，阻塞等待用户输入；

1. **分析独立应用代码** — 读取并理解应用创建和服务获取逻辑；
   - 识别 app.get() 获取服务的方式；检查是否调用了 app.close() 释放资源；

2. **逐项审查** — 检查独立应用实现的正确性；
   - 判断 app.init() 或 app.close() 是否正确管理生命周期：
     - 通过 -> 记录通过；
     - 未通过 -> 记录“缺少 app.close() 可能导致资源泄露”；
   - 判断 get() 获取的服务是否存在于导入模块中：
     - 通过 -> 记录通过；
     - 未通过 -> 记录“服务未在模块中导出，无法从独立应用中获取”；
   - 判断是否有任何问题记录：
     - 是 -> 汇总问题列表，进入下一步；
     - 否 -> 直接进入步骤 4；

3. **提供修改建议** — 通过 AskUserQuestion 确认是否应用修改；
4. **复核检查** — 对照 Review List 逐项验收；
5. **成果输出** — 输出审查摘要表格；

## Rules

- **内容规范**
  - description 使用第三人称，不超过 1024 字符；SKILL.md 不超过 300 行；
- **行为规范**
  - 审查时仅输出问题摘要；交互环节使用 AskUserQuestion；
- **防御规范**
  - 如目标代码为空或不可读，直接报告并终止；

## Examples

### 对话交互示例

```markdown
用户 > 帮我检查这个独立应用
AI   > 触发 nestjs-7-3-standalone-apps 技能...
审查结果：
- 🟩 使用 createApplicationContext 正确创建
- 🟥 缺少 app.close()，可能导致进程无法退出
- 🟩 服务在模块中已导出
用户 > 帮我添加 app.close()
AI   > 是否应用修改？用户 > 是
```

### 复核检查示例

```markdown
AI > Review List 逐项验收... ✅ 全部通过。
```

### 成果输出示例

```markdown
| 维度 | 结果 |
| --- | --- |
| 审查文件 | scripts/seed.ts | 审查项总数 | 4 项 | 通过 | 3 项 | 发现问题 | 1 项 |
```

## Review List

- [ ] 缺少 app.close() 时已报告；[ ] 服务未导出时已报告；[ ] 输出摘要完整

## References

- [NestJS Standalone Apps](https://docs.nestjs.com/standalone-applications)
- [skill-evolve 模板](../../skill-evolve/template.md)
