---
name: nestjs-4-3-mongoose
description: 审查 NestJS 中 Mongoose/MongoDB 集成实践，涵盖 Schema 定义、模型注册、虚拟字段和聚合管道。当用户需要审查 Mongoose 集成或开发 MongoDB 数据层时使用。
---

# NestJS 非关系型数据库应用（Mongoose）

## Overview

当 AI 在 NestJS 项目中遇到 Mongoose 相关代码时，自动执行以下工作：审查 Schema 定义和模型注册的正确性，检查 Mongoose 模块配置，评估虚拟属性和中间件钩子的使用，识别常见查询和索引问题，并提供改进建议。

## Definitions

- <a id="目标代码"></a>**目标代码**：当前对话中 NestJS 的 Mongoose Schema 定义、模型注入或数据库操作代码。
- <a id="Mongoose Schema"></a>**Mongoose Schema**：使用 @Schema 装饰器定义的 MongoDB 文档结构，包含字段类型、验证规则和索引。
- <a id="模型注入"></a>**模型注入**：通过 @InjectModel 装饰器在服务中注入特定 Mongoose 模型实例的方式。
- <a id="是否分析完成"></a>**是否分析完成**：标记对目标代码的分析是否已得出完整结果。

## Prerequisites

- NestJS 项目环境（包含 @nestjs/mongoose、mongoose 依赖）；
- Mongoose Schema 定义或模型操作代码可访问；
- 了解 MongoDB 和 Mongoose 的基本概念。

## Workflow

0. **前置检查** — 确保目标代码和运行环境可达；
   - 判断目标代码是否存在且可读取：
     - 是 -> 下一步；
     - 否 -> 提示用户提供目标代码或文件路径，阻塞等待用户输入；
   - 初始化全局变量 [是否分析完成](#是否分析完成)：
     - 判断代码是否完整可解析：
       - 满足 -> 初始化变量为 true；
       - 不满足 -> 初始化变量为 false；

1. **分析 Mongoose 代码** — 读取并理解 Schema 定义和数据库操作；
   - 读取目标代码，识别以下核心要素：
     - @Schema 装饰器的配置（timestamps、collection、validateBeforeSave 等）；
     - Schema 字段的类型定义和验证装饰器（@Prop）；
     - @InjectModel 在服务中注入模型的方式；
     - MongooseModule 的配置（forRoot / forFeature）；
     - 查询方法（find、aggregate、populate 等）；

2. **逐项审查** — 对照审查清单检查 Mongoose 代码质量；
   - 依次判断以下审查项是否通过：
     - Schema 是否启用了 timestamps（自动管理 createdAt / updatedAt）：
       - 通过 -> 记录通过，继续下一个审查项；
       - 未通过 -> 记录“建议启用 timestamps: true 以自动管理时间戳字段”，继续；
     - 频繁查询的字段是否添加了数据库索引（@Prop({ index: true })）：
       - 通过 -> 记录通过，继续下一个审查项；
       - 未通过 -> 记录“频繁查询字段缺少索引，可能导致查询性能问题”，继续；
     - @Prop 中的类型定义是否使用了 Mongoose 类型（如 Schema.Types.ObjectId 引用）：
       - 通过 -> 记录通过，继续下一个审查项；
       - 未通过 -> 记录“引用字段的类型定义不准确，建议使用 ref 和 type 指明引用关系”，继续；
     - 虚拟属性（Virtual）是否用于计算字段而非存储在数据库中：
       - 通过 -> 记录通过，继续下一个审查项；
       - 未通过 -> 记录“可在 Schema 中使用虚拟属性替代存储冗余数据”，继续；
     - 聚合管道（Aggregation Pipeline）中是否包含 $match 阶段作为第一步（减少处理文档数）：
       - 通过 -> 记录通过，继续下一个审查项；
       - 未通过 -> 记录“聚合管道的第一个阶段建议使用 $match 过滤以减少处理量”，继续；
     - MongooseModule.forFeature 是否正确导入了对应的 Schema：
       - 通过 -> 记录通过，继续下一个审查项；
       - 未通过 -> 记录“模型未在 forFeature 中注册，服务中无法注入”，继续；
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
  - 审查项须引用 Mongoose 和 NestJS 官方文档；
  - SKILL.md 不超过 300 行；超过时拆分到 references/ 目录；
  - 引用层次不超过一层；
  - 保持术语一致，Definitions 中已定义术语在正文中通过锚点链接引用；
  - 删除任何时效性信息；

- **行为规范**
  - 审查时仅输出问题摘要和定位，不直接修改代码，除非用户通过 AskUserQuestion 明确要求；
  - 所有涉及代码修改的交互环节，必须使用 AskUserQuestion 工具；
  - 索引和虚拟属性建议标注为推荐而非强制；

- **防御规范**
  - 如目标代码为空或不可读，直接报告并终止；
  - 聚合管道优化建议仅在管道阶段序列明确时提供；

- **验证规范**
  - Examples 内容必须自洽于 Rules；
  - Examples 必须包含复核检查示例；
  - 对话交互示例仅聚焦步骤 0~3（不含复核检查和成果输出）；

## Examples

### 对话交互示例

**示例：用户请求审查 Mongoose Schema 定义**

```markdown
用户 > 帮我检查这个 Mongoose Schema 配置
AI   > 检测到用户需要 NestJS Mongoose 审查，触发 nestjs-4-3-mongoose 技能
AI   > 正在分析 Schema 和模型代码...

审查结果：
- 🟥 @Schema 未启用 timestamps，缺少自动时间戳管理
- 🟩 @Prop 字段类型定义正确
- 🟥 email 字段频繁查询但缺少索引
- 🟩 聚合管道第一步正确使用 $match
- 🟩 MongooseModule.forFeature 注册了对应的 Schema

总评：2 个问题需要关注
用户 > 帮我添加 timestamps 和索引
AI   > 在 @Schema({ timestamps: true }) 和 @Prop({ index: true, unique: true }) 上修改。是否应用？
用户 > 全部采纳
```

### 复核检查示例

```markdown
AI > 进入复核检查，Review List 包含 5 个检查项，开始逐项验收：

**内容检查**
  - 🟩 审查项全部引用官方文档
  - 🟩 索引建议标注为推荐

**行为检查**
  - 🟩 未直接修改用户代码
  - 🟩 使用了 AskUserQuestion

**验证检查**
  - 🟩 聚合建议在管道明确时提供
  - 🟩 输出摘要完整

✅ 全部通过，进入成果输出。
```

### 成果输出示例

**审查结果示例：**

```markdown
| 维度 | 结果 |
| --- | --- |
| 审查文件 | src/user/schemas/user.schema.ts |
| 审查项总数 | 7 项 |
| 通过 | 5 项 |
| 发现问题 | 2 项 |
| 风险等级 | 🟡 中 |
| 已采纳建议 | 2 条 |
```

## Review List

- **内容检查**
  - [ ] 审查项全部引用 Mongoose 和 NestJS 官方文档
  - [ ] 索引和虚拟属性建议标注为推荐而非强制
- **行为检查**
  - [ ] 未直接修改用户代码（除非用户明确要求）
  - [ ] 所有交互环节使用了 AskUserQuestion
- **验证检查**
  - [ ] 目标代码为空或不可读时已正确终止
  - [ ] 聚合管道优化在阶段序列明确时提供
  - [ ] 输出摘要包含了文件路径、审查项数、发现问题和风险等级

## References

- [NestJS Mongoose 集成文档](https://docs.nestjs.com/techniques/mongodb)
- [Mongoose 官方文档](https://mongoosejs.com/)
- [skill-evolve 模板](../../skill-evolve/template.md)
