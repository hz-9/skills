---
name: nestjs-1-1-cli-scaffolding
description: 审查 NestJS CLI 脚手架配置与项目生命周期管理，确保项目结构遵循官方规范。当用户需要审查项目初始化结构、nest-cli.json 配置、或 package.json 脚本时使用。
---

# NestJS CLI 脚手架与项目生命周期

## Overview

当 AI 在 NestJS 项目中遇到 CLI 配置或项目结构相关代码时，自动执行以下工作：审查项目初始化结构是否符合官方约定，验证 nest-cli.json 和 tsconfig 配置的完整性，检查生命周期钩子的使用方式，并提供改进建议。

## Definitions

- <a id="目标代码"></a>**目标代码**：当前对话中 NestJS 项目的 CLI 配置文件（nest-cli.json、tsconfig.json、tsconfig.build.json）或声明了生命周期钩子的类代码。
- <a id="脚手架配置"></a>**脚手架配置**：由 `nest new` 创建或手动维护的项目结构，包含 src/ 目录布局、nest-cli.json 编译器选项、package.json 脚本等。
- <a id="生命周期钩子"></a>**生命周期钩子**：NestJS 组件的 onModuleInit、onApplicationBootstrap、onModuleDestroy、beforeApplicationShutdown、onApplicationShutdown 五个接口方法。
- <a id="是否分析完成"></a>**是否分析完成**：标记对目标代码的分析是否已得出完整结果。

## Prerequisites

- NestJS 项目目录（package.json 中包含 @nestjs/core 依赖）；
- 目标配置文件或含生命周期钩子的代码文件可访问；
- 了解 NestJS CLI 命令的基本用法（nest new、nest generate 等）。

## Workflow

0. **前置检查** — 确保目标代码和运行环境可达；
   - 判断目标代码是否存在且可读取：
     - 是 -> 下一步；
     - 否 -> 提示用户提供目标代码或文件路径，阻塞等待用户输入；
   - 初始化全局变量 [是否分析完成](#是否分析完成)：
     - 判断代码是否完整可解析：
       - 满足 -> 初始化变量为 true；
       - 不满足 -> 初始化变量为 false；

1. **分析项目配置** — 读取 CLI 配置和项目结构；
   - 读取项目中以下配置文件（如可访问）：
     - `nest-cli.json` — 检查 compilerOptions、entryFile、sourceRoot 等字段；
     - `tsconfig.json` / `tsconfig.build.json` — 检查 strict、装饰器支持等 TypeScript 选项；
     - `package.json` — 检查 scripts（build、start、start:dev）和依赖版本；
   - 识别 src/ 目录下的核心文件：main.ts、app.module.ts、app.controller.ts、app.service.ts；

2. **审查脚手架配置质量** — 对照官方规范逐项检查配置；
   - 依次判断以下审查项是否通过：
     - nest-cli.json 中 compilerOptions 是否配置了 deleteOutDir：
       - 通过 -> 记录通过，继续下一个审查项；
       - 未通过 -> 记录“缺少 deleteOutDir，可能导致构建输出目录残留旧文件”；
     - 是否启用了 TypeScript strict 模式：
       - 通过 -> 记录通过，继续下一个审查项；
       - 未通过 -> 记录“推荐启用 strict 模式以提升类型安全性”；
     - package.json 中 build 脚本是否包含 nest build：
       - 通过 -> 记录通过，继续下一个审查项；
       - 未通过 -> 记录“build 脚本缺少 nest build，可能导致构建不一致”；
     - src/ 目录结构是否符合官方约定（main.ts + app.module.ts）：
       - 通过 -> 记录通过，继续下一个审查项；
       - 未通过 -> 记录“src/ 结构偏离官方约定，可能影响 nest generate 生成”；

3. **审查生命周期钩子用法** — 检查生命周期接口实现；
   - 判断目标代码中是否包含生命周期钩子：
     - 是 -> 读取并分析钩子实现；
     - 否 -> 跳过本步骤，进入下一步；
   - 依次判断以下审查项是否通过：
     - 非必要场景是否在 onModuleInit 中执行异步操作（如数据库连接）：
       - 通过 -> 记录通过，继续下一个审查项；
       - 未通过 -> 记录“建议将异步初始化移至 onApplicationBootstrap”，继续；
     - 是否在 onModuleDestroy 中正确清理资源：
       - 通过 -> 记录通过，继续下一个审查项；
       - 未通过 -> 记录“缺少 onModuleDestroy 清理逻辑，可能导致资源泄露”，继续；
     - 判断是否有任何问题记录：
       - 是 -> 汇总问题列表，进入下一步；
       - 否 -> 直接进入步骤 5（复核检查）；

4. **提供修改建议** — 对发现的问题给出具体修复方案；
   - 依次对每个问题提供修复建议；
   - 通过 AskUserQuestion 提供选项，阻塞等待用户选择：
     - 采纳全部建议 -> 生成修正后的配置或代码，进入步骤 5；
     - 逐条确认 -> 逐条由用户决定采纳或忽略，全部确认后进入步骤 5；
     - 仅查看不修改 -> 不影响代码，直接进入步骤 5；

5. **复核检查** — 对照 [Review List](#review-list)，确认执行结果；
   - 判断 Review List 是否有内容：
     - 否 -> 直接进入下一步（成果输出）；
     - 是 -> 下一步；
   - 依次判断 [Review List](#review-list) 中每个检查项，是否通过：
     - 基于“复核检查示例”来显示输出内容；
   - 有任一检查失败，终止流程；
   - 全部通过后，进入下一步；

6. **成果输出** — 输出审查摘要，告知完成；
   - 输出结构化摘要表格（审查文件 / 审查项数 / 通过 / 发现问题 / 风险等级 / 已采纳建议）；
   - 告知审查完成；

## Rules

- **内容规范**
  - description 须遵循格式：第一句说明审查内容，第二句说明触发条件（"当用户需要…时使用"），使用第三人称，不超过 1024 字符；
  - 审查项须引用 NestJS 官方文档或社区公认最佳实践；
  - SKILL.md 不超过 300 行；超过时拆分到 references/ 目录；
  - 引用层次不超过一层（SKILL.md 可引用 references/，但 references/ 不引用外部资源）；
  - 保持术语一致，Definitions 中已定义术语在正文中通过锚点链接 `[术语](#锚点)` 引用；
  - 删除任何时效性信息（具体版本号、API 弃用日期等）；

- **行为规范**
  - 审查时仅输出问题摘要和定位，不直接修改代码，除非用户通过 AskUserQuestion 明确要求；
  - 所有涉及代码修改的交互环节，必须使用 AskUserQuestion 工具，禁止以纯文本追问代替；
  - 反模式判断须提供正反对比说明；

- **防御规范**
  - 如目标代码为空或不可读，直接报告并终止，不臆测分析；
  - NestJS 版本兼容性问题在报告中标注风险等级，不强行推荐特定写法；

- **验证规范**
  - Examples 内容必须自洽于 Rules；
  - Examples 必须包含复核检查示例；
  - 对话交互示例仅聚焦步骤 0~4（不含复核检查和成果输出）；

## Examples

### 对话交互示例

**示例：用户请求审查 NestJS 项目配置**

```markdown
用户 > 帮我看看这个 nest-cli.json 和项目结构有没有问题
AI   > 检测到用户需要 NestJS CLI 脚手架审查，触发 nestjs-1-1-cli-scaffolding 技能
AI   > 正在分析项目配置...
AI   > 发现以下配置文件的审查结果：

nest-cli.json：
  - 🟩 compilerOptions.deleteOutDir 已配置
  - 🟩 sourceRoot 指向 src/

tsconfig.json：
  - 🟥 strict 未启用（推荐启用）
  - 🟩 experimentalDecorators 已配置

package.json：
  - 🟩 build 脚本使用 nest build
  - 🟥 start:dev 缺少 --watch 标志

src/ 目录结构：
  - 🟩 包含 main.ts 和 app.module.ts
  - 🟩 模块组织符合官方约定

总评：2 个问题需要关注，是否需要我逐条给出修复建议？
用户 > 好的，请逐条给出建议
AI   > 1. strict 未启用 — 在 tsconfig.json compilerOptions 中添加 "strict": true
      2. start:dev 缺少 --watch — 修改为 "start:dev": "nest start --watch"
      是否要应用这些修改？
用户 > 先看看就好，不修改
AI   > 已记录，最终报告中将包含这两个建议项
```

### 复核检查示例

```markdown
AI > 进入复核检查，Review List 包含 6 个检查项，开始逐项验收：

**内容检查**
  - 🟩 审查项全部引用官方规范
  - 🟩 正反对比说明完整

**行为检查**
  - 🟩 未直接修改用户代码
  - 🟩 交互环节使用了 AskUserQuestion

**验证检查**
  - 🟩 已检查目标代码可读性（不可读时已终止）
  - 🟥 配置兼容性问题未标注风险等级

**！！！以下检查项未通过！！！**
  - 🟥 配置兼容性问题未标注风险等级

终止流程，建议人工检查处理后重新执行。
```

### 成果输出示例

**审查结果示例：**

```markdown
| 维度 | 结果 |
| --- | --- |
| 审查文件 | nest-cli.json、tsconfig.json、package.json |
| 审查项总数 | 10 项 |
| 通过 | 8 项 |
| 发现问题 | 2 项 |
| 风险等级 | 🟡 中 |
| 已采纳建议 | 0 条 |
| 已忽略/仅查看 | 2 条 |
```

## Review List

- **内容检查**
  - [ ] 审查项全部引用 NestJS 官方规范或公认最佳实践，无主观意见
  - [ ] 对反模式提供了正反对比说明
- **行为检查**
  - [ ] 未直接修改用户代码（除非用户明确要求）
  - [ ] 所有交互环节使用了 AskUserQuestion
- **验证检查**
  - [ ] 目标代码为空或不可读时已正确终止
  - [ ] 配置兼容性问题已标注风险等级
  - [ ] 输出摘要包含了文件路径、审查项数、发现问题和风险等级

## References

- [NestJS CLI 官方文档](https://docs.nestjs.com/cli/overview)
- [NestJS 项目结构](https://docs.nestjs.com/first-steps)
- [NestJS 生命周期事件](https://docs.nestjs.com/fundamentals/lifecycle-events)
- [skill-evolve 模板](../../skill-evolve/template.md)
