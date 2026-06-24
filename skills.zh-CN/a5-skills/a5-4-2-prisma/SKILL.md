---
name: nestjs-4-2-prisma
description: 审查 NestJS 中 Prisma ORM 集成实践，涵盖 Schema 设计、PrismaClient 管理、迁移与查询优化。当用户需要审查 Prisma 集成代码或优化数据库查询时使用。
---

# NestJS Prisma ORM 实践

## Overview

当 AI 在 NestJS 项目中遇到 Prisma 相关代码时，自动执行以下工作：审查 Prisma Schema 设计的规范性，检查 PrismaClient 实例管理和模块注入方式，评估查询优化策略，识别常见 Prisma 集成陷阱，并提供改进建议。

## Definitions

- <a id="目标代码"></a>**目标代码**：当前对话中 NestJS 项目的 Prisma Schema 文件、PrismaService 或数据库操作代码。
- <a id="PrismaService"></a>**PrismaService**：PrismaClient 在 NestJS 中的封装服务，通常继承 PrismaClient 并实现 OnModuleInit 生命周期钩子。
- <a id="Schema 定义"></a>**Schema 定义**：prisma/schema.prisma 文件中定义的 datasource、generator、model 和 enum。
- <a id="是否分析完成"></a>**是否分析完成**：标记对目标代码的分析是否已得出完整结果。

## Prerequisites

- NestJS 项目环境（包含 @prisma/client 和 prisma 依赖）；
- Prisma Schema 或服务代码文件可访问；
- 了解 Prisma ORM 的基本概念（模式、迁移、查询）。

## Workflow

0. **前置检查** — 确保目标代码和运行环境可达；
   - 判断目标代码是否存在且可读取：
     - 是 -> 下一步；
     - 否 -> 提示用户提供目标代码或文件路径，阻塞等待用户输入；
   - 初始化全局变量 [是否分析完成](#是否分析完成)：
     - 判断代码是否完整可解析：
       - 满足 -> 初始化变量为 true；
       - 不满足 -> 初始化变量为 false；

1. **分析 Prisma 代码** — 读取并理解 Schema 定义和数据库操作；
   - 读取目标代码，识别以下核心要素：
     - Prisma Schema 中的 model 定义和关系声明；
     - PrismaService 的实现方式（继承 PrismaClient + onModuleInit）；
     - 服务中的 Prisma 查询方法（findMany、create、update 等）；
     - PrismaModule 中 PrismaService 的提供和导出方式；

2. **逐项审查** — 对照审查清单检查 Prisma 代码质量；
   - 依次判断以下审查项是否通过：
     - PrismaService 是否正确实现了 OnModuleInit 生命周期钩子（连接管理）：
       - 通过 -> 记录通过，继续下一个审查项；
       - 未通过 -> 记录“PrismaService 未实现 onModuleInit，数据库连接可能在首次使用前未建立”，继续；
     - PrismaService 是否作为全局单例提供（避免多次创建 PrismaClient 实例）：
       - 通过 -> 记录通过，继续下一个审查项；
       - 未通过 -> 记录“PrismaService 建议设为全局单例以复用数据库连接”，继续；
     - Schema 中 model 关系的 @relation 是否配置了 onDelete 级联行为：
       - 通过 -> 记录通过，继续下一个审查项；
       - 未通过 -> 记录“关系缺少 onDelete 级联配置，可能导致外键约束错误”，继续；
     - 查询是否使用了 select 或 include 限制返回数据量（避免返回整个对象图）：
       - 通过 -> 记录通过，继续下一个审查项；
       - 未通过 -> 记录“建议使用 select 指定返回字段以减少数据量”，继续；
     - 是否有 N+1 查询风险（循环中逐条查询数据库）：
       - 通过 -> 记录通过，继续下一个审查项；
       - 未通过 -> 记录“检测到潜在的 N+1 查询问题，建议使用 include 预加载或批量查询”，继续；
     - Prisma 迁移配置是否正确（是否使用 prisma migrate）：
       - 通过 -> 记录通过，继续下一个审查项；
       - 未通过 -> 记录“迁移策略不明确，建议使用 prisma migrate 管理 Schema 变更”，继续；
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
  - 审查项须引用 Prisma 和 NestJS 官方文档；
  - SKILL.md 不超过 300 行；超过时拆分到 references/ 目录；
  - 引用层次不超过一层；
  - 保持术语一致，Definitions 中已定义术语在正文中通过锚点链接引用；
  - 删除任何时效性信息；

- **行为规范**
  - 审查时仅输出问题摘要和定位，不直接修改代码，除非用户通过 AskUserQuestion 明确要求；
  - 所有涉及代码修改的交互环节，必须使用 AskUserQuestion 工具；
  - 查询优化建议（select、include）标注为推荐而非强制；

- **防御规范**
  - 如目标代码为空或不可读，直接报告并终止；
  - N+1 查询仅在循环查询明确可见时报告，动态查询标注为需手动确认；

- **验证规范**
  - Examples 内容必须自洽于 Rules；
  - Examples 必须包含复核检查示例；
  - 对话交互示例仅聚焦步骤 0~3（不含复核检查和成果输出）；

## Examples

### 对话交互示例

**示例：用户请求审查 Prisma Schema 和查询**

```markdown
用户 > 帮我检查 Prisma 集成有没有问题
AI   > 检测到用户需要 NestJS Prisma 审查，触发 nestjs-4-2-prisma 技能
AI   > 正在分析 Prisma 代码...

审查结果：
- 🟩 PrismaService 实现了 onModuleInit 建立连接
- 🟩 PrismaService 在 PrismaModule 中设为全局模块
- 🟥 User 和 Post 的关系缺少 onDelete: Cascade
- 🟥 getUserPosts 方法在循环中逐条查询，存在 N+1 风险
- 🟩 Schema 中 model 定义完整

总评：2 个问题需要关注
用户 > 帮我修复 N+1 查询
AI   > 可以使用 include: { posts: true } 一次加载关联数据。是否应用？
用户 > 是
```

### 复核检查示例

```markdown
AI > 进入复核检查，Review List 包含 6 个检查项，开始逐项验收：

**内容检查**
  - 🟩 审查项全部引用官方文档
  - 🟩 查询建议标注为推荐

**行为检查**
  - 🟩 未直接修改用户代码
  - 🟩 使用了 AskUserQuestion

**验证检查**
  - 🟩 N+1 在明确时报告
  - 🟩 输出摘要完整

✅ 全部通过，进入成果输出。
```

### 成果输出示例

**审查结果示例：**

```markdown
| 维度 | 结果 |
| --- | --- |
| 审查文件 | prisma/schema.prisma、src/prisma/prisma.service.ts |
| 审查项总数 | 7 项 |
| 通过 | 5 项 |
| 发现问题 | 2 项 |
| 风险等级 | 🟡 中 |
| 已采纳建议 | 1 条 |
| 已忽略/仅查看 | 1 条 |
```

## Review List

- **内容检查**
  - [ ] 审查项全部引用 Prisma 和 NestJS 官方文档
  - [ ] 查询优化建议标注为推荐而非强制
- **行为检查**
  - [ ] 未直接修改用户代码（除非用户明确要求）
  - [ ] 所有交互环节使用了 AskUserQuestion
- **验证检查**
  - [ ] 目标代码为空或不可读时已正确终止
  - [ ] N+1 查询仅在明确可见时报告
  - [ ] 输出摘要包含了文件路径、审查项数、发现问题和风险等级

## References

- [NestJS Prisma 集成文档](https://docs.nestjs.com/recipes/prisma)
- [Prisma 官方文档](https://www.prisma.io/docs)
- [skill-evolve 模板](../../skill-evolve/template.md)
