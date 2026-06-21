---
name: nestjs-2-3-pipes-validation
description: 审查 NestJS 数据校验与转换管道的实现，涵盖内置管道、自定义管道和全局管道注册的最佳实践。当用户需要审查输入校验逻辑或开发 DTO 验证时使用。
---

# NestJS 数据校验与转换管道

## Overview

当 AI 在 NestJS 项目中遇到管道（Pipe）相关代码时，自动执行以下工作：审查管道的注册方式和作用范围，检查 class-validator / class-transformer 装饰器的使用规范性，评估自定义管道的实现质量，识别常见验证遗漏，并提供改进建议。

## Definitions

- <a id="目标代码"></a>**目标代码**：当前对话中 NestJS 的管道实现代码、DTO 定义或控制器参数验证代码。
- <a id="内置管道"></a>**内置管道**：NestJS 提供的 ValidationPipe、ParseIntPipe、ParseUUIDPipe、ParseBoolPipe、DefaultValuePipe 等开箱即用的管道。
- <a id="DTO"></a>**DTO**：数据传输对象，使用 class-validator 和 class-transformer 装饰器定义的数据校验规则类。
- <a id="是否分析完成"></a>**是否分析完成**：标记对目标代码的分析是否已得出完整结果。

## Prerequisites

- NestJS 项目环境；
- 包含管道、DTO 或参数验证的代码文件可访问；
- 了解 class-validator 和 class-transformer 的基本用法。

## Workflow

0. **前置检查** — 确保目标代码和运行环境可达；
   - 判断目标代码是否存在且可读取：
     - 是 -> 下一步；
     - 否 -> 提示用户提供目标代码或文件路径，阻塞等待用户输入；
   - 初始化全局变量 [是否分析完成](#是否分析完成)：
     - 判断代码是否完整可解析：
       - 满足 -> 初始化变量为 true；
       - 不满足 -> 初始化变量为 false；

1. **分析管道与验证代码** — 读取并理解验证逻辑和数据转换流程；
   - 读取目标代码，识别以下核心要素：
     - 管道的注册方式（全局 / 控制器 / 参数级）；
     - DTO 类中使用的 class-validator 装饰器（@IsString、@IsInt、@ValidateNested 等）；
     - 自定义管道的实现（实现 PipeTransform 接口）；
     - ValidationPipe 的配置选项（whitelist、transform、forbidNonWhitelisted 等）；

2. **逐项审查** — 对照审查清单检查管道和验证代码质量；
   - 依次判断以下审查项是否通过：
     - DTO 属性上是否缺少必要的验证装饰器（如 @IsOptional、@IsEmail 等）：
       - 通过 -> 记录通过，继续下一个审查项；
       - 未通过 -> 记录“缺少必要的验证装饰器，建议根据业务需求补充”，继续；
     - 是否启用了 ValidationPipe 的 whitelist（自动过滤未装饰的属性）：
       - 通过 -> 记录通过，继续下一个审查项；
       - 未通过 -> 记录“建议启用 whitelist: true 以防范未预期字段注入”，继续；
     - 是否启用了 ValidationPipe 的 transform（自动类型转换）：
       - 通过 -> 记录通过，继续下一个审查项；
       - 未通过 -> 记录“建议启用 transform: true 以自动执行类型转换”，继续；
     - 嵌套 DTO 是否使用了 @ValidateNested 装饰器：
       - 通过 -> 记录通过，继续下一个审查项；
       - 未通过 -> 记录“嵌套对象需使用 @ValidateNested() 和 @Type() 递归验证”，继续；
     - 自定义管道中 transform() 方法是否返回了正确类型：
       - 通过 -> 记录通过，继续下一个审查项；
       - 未通过 -> 记录“transform() 返回值类型与声明不一致，可能导致运行时类型错误”，继续；
     - 全局 ValidationPipe 是否在 main.ts 中正确注册：
       - 通过 -> 记录通过，继续下一个审查项；
       - 未通过 -> 记录“全局 ValidationPipe 推荐在 main.ts 中使用 app.useGlobalPipes()”，继续；
   - 判断是否有任何问题记录：
     - 是 -> 汇总问题列表，进入下一步；
     - 否 -> 直接进入步骤 4（复核检查）；

3. **提供修改建议** — 对发现的问题给出具体修复方案；
   - 依次对每个问题提供修复建议，包括正反对比示例；
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
  - 审查项须引用 NestJS 官方关于管道和验证的文档；
  - SKILL.md 不超过 300 行；超过时拆分到 references/ 目录；
  - 引用层次不超过一层；
  - 保持术语一致，Definitions 中已定义术语在正文中通过锚点链接引用；
  - 删除任何时效性信息；

- **行为规范**
  - 审查时仅输出问题摘要和定位，不直接修改代码，除非用户通过 AskUserQuestion 明确要求；
  - 所有涉及代码修改的交互环节，必须使用 AskUserQuestion 工具；
  - ValidationPipe 配置建议（whitelist、transform）标注为推荐而非强制；

- **防御规范**
  - 如目标代码为空或不可读，直接报告并终止；
  - class-validator 装饰器缺失仅在 DTO 类型明确时报告，不确定时标注为需手动确认；

- **验证规范**
  - Examples 内容必须自洽于 Rules；
  - Examples 必须包含复核检查示例；
  - 对话交互示例仅聚焦步骤 0~3（不含复核检查和成果输出）；

## Examples

### 对话交互示例

**示例：用户请求审查 DTO 验证配置**

```markdown
用户 > 帮我检查这个 CreateUserDto 的验证配置
AI   > 检测到用户需要 NestJS 管道与验证审查，触发 nestjs-2-3-pipes-validation 技能
AI   > 正在分析 DTO 代码...

审查结果：
- 🟩 核心字段已使用 @IsString、@IsEmail 等装饰器
- 🟥 缺少 whitelist: true 配置，未装饰的属性会被保留
- 🟩 transform: true 已启用，类型会自动转换
- 🟥 嵌套的 ProfileDto 未使用 @ValidateNested() 和 @Type()
- 🟩 全局 ValidationPipe 已在 main.ts 注册

总评：2 个问题需要关注
用户 > 帮我加上 whitelist 和嵌套验证
AI   > 已生成修改方案，是否要应用？  用户 > 全部采纳
```

### 复核检查示例

```markdown
AI > 进入复核检查，Review List 包含 6 个检查项，开始逐项验收：

**内容检查**
  - 🟩 审查项全部引用官方管道文档
  - 🟩 ValidationPipe 配置标注为推荐

**行为检查**
  - 🟩 未直接修改用户代码
  - 🟩 使用了 AskUserQuestion

**验证检查**
  - 🟩 DTO 装饰器缺失在类型明确时才报告
  - 🟩 输出摘要完整

✅ 全部通过，进入成果输出。
```

### 成果输出示例

**审查结果示例：**

```markdown
| 维度 | 结果 |
| --- | --- |
| 审查文件 | src/user/dto/create-user.dto.ts |
| 审查项总数 | 8 项 |
| 通过 | 6 项 |
| 发现问题 | 2 项 |
| 风险等级 | 🟡 中 |
| 已采纳建议 | 2 条 |
```

## Review List

- **内容检查**
  - [ ] 审查项全部引用 NestJS 官方管道和验证文档
  - [ ] ValidationPipe 配置标注为推荐而非强制
- **行为检查**
  - [ ] 未直接修改用户代码（除非用户明确要求）
  - [ ] 所有交互环节使用了 AskUserQuestion
- **验证检查**
  - [ ] 目标代码为空或不可读时已正确终止
  - [ ] DTO 装饰器缺失仅在类型明确时报告
  - [ ] 输出摘要包含了文件路径、审查项数、发现问题和风险等级

## References

- [NestJS 管道官方文档](https://docs.nestjs.com/pipes)
- [NestJS ValidationPipe](https://docs.nestjs.com/techniques/validation)
- [class-validator 文档](https://github.com/typestack/class-validator)
- [skill-evolve 模板](../../skill-evolve/template.md)
