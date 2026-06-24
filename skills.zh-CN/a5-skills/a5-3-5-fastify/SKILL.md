---
name: nestjs-3-5-fastify
description: 审查 NestJS Fastify 平台适配与迁移，涵盖平台替换、中间件兼容性和性能差异处理。当用户需要审查 Fastify 集成或从 Express 迁移时使用。
---

# NestJS 服务器模型转换（Fastify）

## Overview

当 AI 在 NestJS 项目中遇到 Fastify 平台相关代码时，自动执行以下工作：审查 FastifyAdapter 的配置和平台适配，检查 Express 特有 API 的兼容性处理，评估性能优化配置，识别迁移过程中的常见问题，并提供改进建议。

## Definitions

- <a id="目标代码"></a>**目标代码**：当前对话中 NestJS 的 Fastify 适配器配置、平台相关代码或迁移配置代码。
- <a id="FastifyAdapter"></a>**FastifyAdapter**：NestJS 用于替换默认 Express 的 Fastify 平台适配器，在 NestFactory.create 时注入。
- <a id="平台差异"></a>**平台差异**：Express 和 Fastify 在中间件格式、请求/响应对象、文件上传、序列化等方面的差异。
- <a id="是否分析完成"></a>**是否分析完成**：标记对目标代码的分析是否已得出完整结果。

## Prerequisites

- NestJS 项目环境（包含 @nestjs/platform-fastify 依赖）；
- Fastify 适配配置或相关代码可访问；
- 了解 Express 和 Fastify 的基本差异。

## Workflow

0. **前置检查** — 确保目标代码和运行环境可达；
   - 判断目标代码是否存在且可读取：
     - 是 -> 下一步；
     - 否 -> 提示用户提供目标代码或文件路径，阻塞等待用户输入；
   - 初始化全局变量 [是否分析完成](#是否分析完成)：
     - 判断代码是否完整可解析：
       - 满足 -> 初始化变量为 true；
       - 不满足 -> 初始化变量为 false；

1. **分析 Fastify 代码** — 读取并理解平台适配和配置；
   - 读取目标代码，识别以下核心要素：
     - FastifyAdapter 的创建和配置（NestFactory.create 时传递）；
     - Fastify 特有的配置项（bodyLimit、maxParamLength 等）；
     - 使用的中间件是否依赖 Express 特有的 API（req、res）；
     - 文件上传的处理方式（fastify-multipart vs multer）；
     - 序列化配置（Fastify 的 schema serializer）；

2. **逐项审查** — 对照审查清单检查 Fastify 适配代码质量；
   - 依次判断以下审查项是否通过：
     - 是否使用了 @nestjs/platform-fastify 及其对应包（替换了 @nestjs/platform-express）：
       - 通过 -> 记录通过，继续下一个审查项；
       - 未通过 -> 记录“Fastify 平台需要安装 @nestjs/platform-fastify”，继续；
     - 是否检查了项目中使用的中间件与 Fastify 的兼容性（Fastify 中间件接口与 Express 不同）：
       - 通过 -> 记录通过，继续下一个审查项；
       - 未通过 -> 记录“部分中间件依赖 Express API，需检查 Fastify 兼容性”，继续；
     - 文件上传是否迁移到了 fastify-multipart（multer 在 Fastify 下不可用）：
       - 通过 -> 记录通过，继续下一个审查项；
       - 未通过 -> 记录“Fastify 下文件上传需使用 fastify-multipart 替代 multer”，继续；
     - Fastify 的 bodyLimit 是否配置且合理（避免请求体大小限制不当）：
       - 通过 -> 记录通过，继续下一个审查项；
       - 未通过 -> 记录“建议配置 bodyLimit 以控制请求体大小”，继续；
     - 是否处理了 Fastify 与 Express 在响应序列化上的差异（如 Fastify 默认不转换对象）：
       - 通过 -> 记录通过，继续下一个审查项；
       - 未通过 -> 记录“Fastify 与 Express 序列化行为不同，需显式配置”，继续；
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
  - 审查项须引用 NestJS 官方 Fastify 适配文档；
  - SKILL.md 不超过 300 行；超过时拆分到 references/ 目录；
  - 引用层次不超过一层；
  - 保持术语一致，Definitions 中已定义术语在正文中通过锚点链接引用；
  - 删除任何时效性信息；

- **行为规范**
  - 审查时仅输出问题摘要和定位，不直接修改代码，除非用户通过 AskUserQuestion 明确要求；
  - 所有涉及代码修改的交互环节，必须使用 AskUserQuestion 工具；
  - Fastify 迁移建议（Express 到 Fastify）标注为性能优化建议而非强制迁移要求；

- **防御规范**
  - 如目标代码为空或不可读，直接报告并终止；
  - 中间件兼容性仅在可识别为 Express 特有 API 时报告，通用中间件不触发告警；

- **验证规范**
  - Examples 内容必须自洽于 Rules；
  - Examples 必须包含复核检查示例；
  - 对话交互示例仅聚焦步骤 0~3（不含复核检查和成果输出）；

## Examples

### 对话交互示例

**示例：用户请求审查 Fastify 迁移**

```markdown
用户 > 帮我检查项目中是否有 Express 特有的代码阻碍 Fastify 迁移
AI   > 检测到用户需要 NestJS Fastify 审查，触发 nestjs-3-5-fastify 技能
AI   > 正在分析项目代码...

审查结果：
- 🟩 @nestjs/platform-fastify 已安装
- 🟥 helmet 中间件使用了 Express 特有 API，需要替换
- 🟩 bodyLimit 配置为 1MB，合理
- 🟥 文件上传使用了 @UseInterceptors(FileInterceptor)（multer，Fastify 不兼容）
- 🟩 未发现序列化差异问题

总评：2 个问题需要关注
用户 > 帮我修复兼容性问题
AI   > helmet 需要替换为 @fastify/helmet，文件上传需改用 fastify-multipart。是否应用？
用户 > 全部采纳
```

### 复核检查示例

```markdown
AI > 进入复核检查，Review List 包含 5 个检查项，开始逐项验收：

**内容检查**
  - 🟩 审查项全部引用官方文档
  - 🟩 迁移建议标注为性能优化

**行为检查**
  - 🟩 未直接修改用户代码
  - 🟩 使用了 AskUserQuestion

**验证检查**
  - 🟩 中间件报告在 Express 特有时触发
  - 🟩 输出摘要完整

✅ 全部通过，进入成果输出。
```

### 成果输出示例

**审查结果示例：**

```markdown
| 维度 | 结果 |
| --- | --- |
| 审查文件 | src/main.ts、src/common/middleware/ |
| 审查项总数 | 6 项 |
| 通过 | 4 项 |
| 发现问题 | 2 项 |
| 风险等级 | 🟡 中 |
| 已采纳建议 | 2 条 |
```

## Review List

- **内容检查**
  - [ ] 审查项全部引用 NestJS 官方 Fastify 适配文档
  - [ ] 迁移建议标注为性能优化而非强制要求
- **行为检查**
  - [ ] 未直接修改用户代码（除非用户明确要求）
  - [ ] 所有交互环节使用了 AskUserQuestion
- **验证检查**
  - [ ] 目标代码为空或不可读时已正确终止
  - [ ] 中间件兼容性仅在 Express 特有 API 时报告
  - [ ] 输出摘要包含了文件路径、审查项数、发现问题和风险等级

## References

- [NestJS Fastify 适配官方文档](https://docs.nestjs.com/techniques/performance)
- [Fastify 官方文档](https://www.fastify.io/)
- [skill-evolve 模板](../../skill-evolve/template.md)
