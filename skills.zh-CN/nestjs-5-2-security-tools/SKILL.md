---
name: nestjs-5-2-security-tools
description: 审查 NestJS 网络安全防御策略，涵盖 Helmet、CORS、CSRF、限流（Rate Limiting）和输入安全。当用户需要审查安全配置或加固 API 防护时使用。
---

# NestJS 网络安全防御策略

## Overview

当 AI 在 NestJS 项目中遇到网络安全相关代码时，自动执行以下工作：审查 Helmet、CORS、CSRF 等安全中间件的配置，检查 Rate Limiting 限流策略的合理性，评估整体安全防护的完整性，识别常见安全配置遗漏，并提供改进建议。

## Definitions

- <a id="目标代码"></a>**目标代码**：当前对话中 NestJS 项目 main.ts 的安全配置或安全中间件的实现代码。
- <a id="Helmet"></a>**Helmet**：通过设置 HTTP 安全头（Content-Security-Policy、X-Frame-Options 等）防御常见 Web 攻击的中间件。
- <a id="限流"></a>**限流**：使用 @nestjs/throttler 模块实现的请求频率限制，防止 API 被滥用或遭受 DDoS 攻击。
- <a id="是否分析完成"></a>**是否分析完成**：标记对目标代码的分析是否已得出完整结果。

## Prerequisites

- NestJS 项目环境；
- main.ts 或安全配置相关代码可访问；
- 了解常见的 Web 安全威胁（XSS、CSRF、点击劫持等）。

## Workflow

0. **前置检查** — 确保目标代码和运行环境可达；
   - 判断目标代码是否存在且可读取：
     - 是 -> 下一步；
     - 否 -> 提示用户提供目标代码或文件路径，阻塞等待用户输入；
   - 初始化全局变量 [是否分析完成](#是否分析完成)：
     - 判断代码是否完整可解析：
       - 满足 -> 初始化变量为 true；
       - 不满足 -> 初始化变量为 false；

1. **分析安全代码** — 读取并理解安全中间件配置；
   - 读取目标代码，识别以下核心要素：
     - Helmet 中间件的注册和配置选项；
     - CORS 配置（origin、methods、credentials 等）；
     - CSRF 保护的实现方式；
     - ThrottlerModule 的配置（ttl、limit、storage）；

2. **逐项审查** — 对照审查清单检查安全配置完整性；
   - 依次判断以下审查项是否通过：
     - 是否注册了 Helmet 中间件（设置安全 HTTP 头防御 XSS 等攻击）：
       - 通过 -> 记录通过，继续下一个审查项；
       - 未通过 -> 记录“缺少 Helmet 中间件，建议添加 helmet 安全头”，继续；
     - CORS 是否配置了具体的允许来源（避免使用通配符 `*`）：
       - 通过 -> 记录通过，继续下一个审查项；
       - 未通过 -> 记录“CORS 使用通配符 *，建议限制为具体的允许来源”，继续；
     - 是否配置了 CSRF 保护（针对 cookie 认证的应用）：
       - 通过 -> 记录通过，继续下一个审查项；
       - 未通过 -> 记录“缺少 CSRF 保护，建议添加 @nestjs/csurf 或 csurf 中间件”，继续；
     - ThrottlerModule 是否已注册且配置了合理的限流参数：
       - 通过 -> 记录通过，继续下一个审查项；
       - 未通过 -> 记录“缺少限流配置，建议添加 @nestjs/throttler 防止滥用”，继续；
     - 是否处理了请求体大小限制（body-parser 或 Fastify 的 bodyLimit）：
       - 通过 -> 记录通过，继续下一个审查项；
       - 未通过 -> 记录“请求体大小未限制，建议设置 bodyParser 的 limit 选项”，继续；
   - 判断是否有任何问题记录：
     - 是 -> 汇总问题列表，进入下一步；
     - 否 -> 直接进入步骤 4（复核检查）；

3. **提供修改建议** — 对发现的问题给出具体修复方案；
   - 依次对每个问题提供修复建议；
   - 通过 AskUserQuestion 提供选项，阻塞等待用户选择：
     - 采纳全部建议 -> 生成修正后的配置代码，进入步骤 4；
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
  - 审查项须引用 OWASP 安全最佳实践和 NestJS 官方文档；
  - SKILL.md 不超过 300 行；超过时拆分到 references/ 目录；
  - 引用层次不超过一层；
  - 保持术语一致，Definitions 中已定义术语在正文中通过锚点链接引用；
  - 删除任何时效性信息；

- **行为规范**
  - 审查时仅输出问题摘要和定位，不直接修改代码，除非用户通过 AskUserQuestion 明确要求；
  - 所有涉及代码修改的交互环节，必须使用 AskUserQuestion 工具；
  - 安全配置审查项（Helmet、CSRF）标注为推荐，CORS 通配符和请求体大小标注为建议；

- **防御规范**
  - 如目标代码为空或不可读，直接报告并终止；
  - CSRF 必要性仅对 cookie 认证的应用标注为必须，token 认证的应用标注为可选；

- **验证规范**
  - Examples 内容必须自洽于 Rules；
  - Examples 必须包含复核检查示例；
  - 对话交互示例仅聚焦步骤 0~3（不含复核检查和成果输出）；

## Examples

### 对话交互示例

**示例：用户请求审查安全配置**

```markdown
用户 > 帮我检查项目的安全配置是否完善
AI   > 检测到用户需要 NestJS 网络安全审查，触发 nestjs-5-2-security-tools 技能
AI   > 正在分析安全配置...

审查结果：
- 🟥 未注册 Helmet 中间件
- 🟥 CORS 配置为 origin: '*'，建议限制为具体域名
- 🟩 CSRF 保护已配置（使用 JWT token 认证，非必需）
- 🟥 未配置限流，缺少 @nestjs/throttler
- 🟩 请求体大小已限制为 1MB

总评：3 个问题需要关注
用户 > 帮我添加 Helmet 和限流配置
AI   > 添加 app.use(helmet()) 和 ThrottlerModule。是否应用修改？
用户 > 全部采纳
```

### 复核检查示例

```markdown
AI > 进入复核检查，Review List 包含 5 个检查项，开始逐项验收：

**内容检查**
  - 🟩 审查项全部引用 OWASP 最佳实践
  - 🟩 CSRF 标注依赖认证方式

**行为检查**
  - 🟩 未直接修改用户代码
  - 🟩 使用了 AskUserQuestion

**验证检查**
  - 🟩 CSRF 必要性标注了依赖上下文
  - 🟩 输出摘要完整

✅ 全部通过，进入成果输出。
```

### 成果输出示例

**审查结果示例：**

```markdown
| 维度 | 结果 |
| --- | --- |
| 审查文件 | src/main.ts |
| 审查项总数 | 7 项 |
| 通过 | 4 项 |
| 发现问题 | 3 项 |
| 风险等级 | 🔴 高 |
| 已采纳建议 | 2 条 |
| 已忽略/仅查看 | 1 条 |
```

## Review List

- **内容检查**
  - [ ] 审查项全部引用 NestJS 官方安全文档和 OWASP 最佳实践
  - [ ] CSRF 根据认证方式标注为必须或可选
- **行为检查**
  - [ ] 未直接修改用户代码（除非用户明确要求）
  - [ ] 所有交互环节使用了 AskUserQuestion
- **验证检查**
  - [ ] 目标代码为空或不可读时已正确终止
  - [ ] CSRF 必要性标注了上下文依赖
  - [ ] 输出摘要包含了文件路径、审查项数、发现问题和风险等级

## References

- [NestJS 安全官方文档](https://docs.nestjs.com/security/helmet)
- [NestJS CORS 配置](https://docs.nestjs.com/security/cors)
- [NestJS 限流](https://docs.nestjs.com/security/rate-limiting)
- [OWASP 安全最佳实践](https://owasp.org/)
- [skill-evolve 模板](../../skill-evolve/template.md)
