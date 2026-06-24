---
name: nestjs-5-1-authentication
description: 审查 NestJS 身份认证实现，涵盖 JWT 策略、Session 管理、OAuth2 集成和 @AuthGuard 使用。当用户需要审查认证流程或排查登录问题时使用。
---

# NestJS 身份认证与安全防护

## Overview

当 AI 在 NestJS 项目中遇到认证相关代码时，自动执行以下工作：审查 JWT 策略和 Passport 集成的正确性，检查认证守卫的实现和注册方式，评估 token 管理（Access Token / Refresh Token）的完整性，识别常见认证漏洞，并提供改进建议。

## Definitions

- <a id="目标代码"></a>**目标代码**：当前对话中 NestJS 的认证模块、Passport 策略或 AuthGuard 相关代码。
- <a id="JWT 策略"></a>**JWT 策略**：基于 @nestjs/passport 和 passport-jwt 实现的 JWT 验证策略，包含从请求中提取 token 和验证 payload 的逻辑。
- <a id="AuthGuard"></a>**AuthGuard**：@nestjs/passport 提供的内置守卫，自动调用 Passport 策略进行认证。
- <a id="是否分析完成"></a>**是否分析完成**：标记对目标代码的分析是否已得出完整结果。

## Prerequisites

- NestJS 项目环境（包含 @nestjs/passport、@nestjs/jwt、passport 依赖）；
- 认证模块或策略代码文件可访问；
- 了解 JWT、Passport 和 OAuth2 的基本概念。

## Workflow

0. **前置检查** — 确保目标代码和运行环境可达；
   - 判断目标代码是否存在且可读取：
     - 是 -> 下一步；
     - 否 -> 提示用户提供目标代码或文件路径，阻塞等待用户输入；
   - 初始化全局变量 [是否分析完成](#是否分析完成)：
     - 判断代码是否完整可解析：
       - 满足 -> 初始化变量为 true；
       - 不满足 -> 初始化变量为 false；

1. **分析认证代码** — 读取并理解认证流程和策略实现；
   - 读取目标代码，识别以下核心要素：
     - Passport 策略的实现（JwtStrategy 等）和配置（secretOrKey、jwtFromRequest）；
     - JwtModule 的注册配置（secret、signOptions）；
     - AuthGuard(@nestjs/passport) 的使用方式和自定义守卫；
     - 认证控制器的路由设计（login、register、refresh）；
     - Refresh Token 的实现（如有）；

2. **逐项审查** — 对照审查清单检查认证代码质量；
   - 依次判断以下审查项是否通过：
     - JWT secret 是否使用环境变量管理（而非硬编码在代码中）：
       - 通过 -> 记录通过，继续下一个审查项；
       - 未通过 -> 记录“JWT secret 硬编码在代码中，建议使用环境变量”，继续；
     - JWT token 是否设置了合理的过期时间（expiresIn，避免过长或过短）：
       - 通过 -> 记录通过，继续下一个审查项；
       - 未通过 -> 记录“JWT 过期时间不合理，建议根据安全策略调整”，继续；
     - 是否实现了 Refresh Token 机制（避免 Access Token 过期后频繁要求重新登录）：
       - 通过 -> 记录通过，继续下一个审查项；
       - 未通过 -> 记录“缺少 Refresh Token 机制，用户体验可能受影响”，继续；
     - Passport 策略的 validate 方法是否验证了用户是否存在（不依赖 token 本身的有效性）：
       - 通过 -> 记录通过，继续下一个审查项；
       - 未通过 -> 记录“validate 方法未验证用户状态，已删除的用户仍可使用旧 token”，继续；
     - 登录路由是否包含请求频率限制（防止暴力破解）：
       - 通过 -> 记录通过，继续下一个审查项；
       - 未通过 -> 记录“登录路由缺少频率限制，建议添加 @nestjs/throttler”，继续；
     - 密码是否使用了哈希存储（如 bcrypt）而非明文：
       - 通过 -> 记录通过，继续下一个审查项；
       - 未通过 -> 记录“密码以明文存储，存在严重安全风险”，继续；
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
  - 审查项须引用 NestJS 官方认证文档和安全最佳实践；
  - SKILL.md 不超过 300 行；超过时拆分到 references/ 目录；
  - 引用层次不超过一层；
  - 保持术语一致，Definitions 中已定义术语在正文中通过锚点链接引用；
  - 删除任何时效性信息；

- **行为规范**
  - 审查时仅输出问题摘要和定位，不直接修改代码，除非用户通过 AskUserQuestion 明确要求；
  - 所有涉及代码修改的交互环节，必须使用 AskUserQuestion 工具；
  - 安全相关审查项（密码哈希、secret 管理）标注为强制性而非建议性；

- **防御规范**
  - 如目标代码为空或不可读，直接报告并终止；
  - Refresh Token 机制标注为增强体验建议而非必需；

- **验证规范**
  - Examples 内容必须自洽于 Rules；
  - Examples 必须包含复核检查示例；
  - 对话交互示例仅聚焦步骤 0~3（不含复核检查和成果输出）；

## Examples

### 对话交互示例

**示例：用户请求审查认证实现**

```markdown
用户 > 帮我检查这个 JWT 认证的安全性
AI   > 检测到用户需要 NestJS 身份认证审查，触发 nestjs-5-1-authentication 技能
AI   > 正在分析认证代码...

审查结果：
- 🟥 JWT secret 硬编码在代码中，建议使用环境变量
- 🟩 token 过期时间设置为 15 分钟，合理
- 🟥 缺少 Refresh Token 机制
- 🟩 validate 方法验证了用户是否存在
- 🟥 密码使用明文存储，存在严重安全风险

总评：3 个问题需要关注
用户 > 帮我修复 secret 硬编码和密码存储问题
AI   > secret 改用 ConfigService 读取，密码改用 bcrypt 哈希。是否应用修改？
用户 > 全部采纳
```

### 复核检查示例

```markdown
AI > 进入复核检查，Review List 包含 6 个检查项，开始逐项验收：

**内容检查**
  - 🟩 审查项全部引用官方文档
  - 🟩 安全项标注为强制性

**行为检查**
  - 🟩 未直接修改用户代码
  - 🟩 使用了 AskUserQuestion

**验证检查**
  - 🟩 Refresh Token 标注为建议
  - 🟩 输出摘要完整

✅ 全部通过，进入成果输出。
```

### 成果输出示例

**审查结果示例：**

```markdown
| 维度 | 结果 |
| --- | --- |
| 审查文件 | src/auth/auth.module.ts、src/auth/jwt.strategy.ts |
| 审查项总数 | 8 项 |
| 通过 | 5 项 |
| 发现问题 | 3 项 |
| 风险等级 | 🔴 高 |
| 已采纳建议 | 2 条 |
| 已忽略/仅查看 | 1 条 |
```

## Review List

- **内容检查**
  - [ ] 审查项全部引用 NestJS 官方认证文档和安全最佳实践
  - [ ] 安全相关审查项（密码哈希、secret 管理）标注为强制性
- **行为检查**
  - [ ] 未直接修改用户代码（除非用户明确要求）
  - [ ] 所有交互环节使用了 AskUserQuestion
- **验证检查**
  - [ ] 目标代码为空或不可读时已正确终止
  - [ ] Refresh Token 标注为增强体验建议
  - [ ] 输出摘要包含了文件路径、审查项数、发现问题和风险等级

## References

- [NestJS 认证官方文档](https://docs.nestjs.com/security/authentication)
- [NestJS Passport 集成](https://docs.nestjs.com/recipes/passport)
- [JWT 官方文档](https://jwt.io/)
- [skill-evolve 模板](../../skill-evolve/template.md)
