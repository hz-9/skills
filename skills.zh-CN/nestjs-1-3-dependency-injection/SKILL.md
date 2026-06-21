---
name: nestjs-1-3-dependency-injection
description: 审查 NestJS 依赖注入体系的使用，涵盖 @Injectable、自定义提供者、工厂模式及注入范围控制。当用户需要审查依赖注入配置或排查注入异常时使用。
---

# NestJS 依赖注入与提供者

## Overview

当 AI 在 NestJS 项目中遇到依赖注入相关代码时，自动执行以下工作：审查 @Injectable 装饰器的使用规范性，检查自定义提供者的配置正确性，评估注入范围选择是否合理，排查常见的注入异常模式。

## Definitions

- <a id="目标代码"></a>**目标代码**：当前对话中 NestJS 的 Provider、Service 或工厂函数的代码或文件路径。
- <a id="提供者分类"></a>**提供者分类**：NestJS 支持的提供者类型，包括 useValue（值提供者）、useClass（类提供者）、useFactory（工厂提供者）和 useExisting（别名提供者）。
- <a id="注入作用域"></a>**注入作用域**：NestJS 的 DEFAULT（单例）、REQUEST（每个请求新建）和 TRANSIENT（每次注入新建）三种作用域。
- <a id="是否分析完成"></a>**是否分析完成**：标记对目标代码的分析是否已得出完整结果。

## Prerequisites

- NestJS 项目环境；
- 包含 Provider 声明或注入的代码文件可访问；
- 了解依赖注入的基本概念（构造函数注入、属性注入）。

## Workflow

0. **前置检查** — 确保目标代码和运行环境可达；
   - 判断目标代码是否存在且可读取：
     - 是 -> 下一步；
     - 否 -> 提示用户提供目标代码或文件路径，阻塞等待用户输入；
   - 初始化全局变量 [是否分析完成](#是否分析完成)：
     - 判断代码是否完整可解析：
       - 满足 -> 初始化变量为 true；
       - 不满足 -> 初始化变量为 false；

1. **分析依赖注入代码** — 读取并理解提供者和注入关系；
   - 读取目标代码，识别以下核心要素：
     - @Injectable() 装饰器的使用位置；
     - 构造函数中的依赖注入参数；
     - @Module 中 providers 数组的配置方式；
     - 自定义提供者的类型（useValue / useClass / useFactory / useExisting）；
     - 注入作用域的设置（@Injectable({ scope: Scope.REQUEST }) 等）；

2. **逐项审查** — 对照审查清单检查依赖注入代码质量；
   - 依次判断以下审查项是否通过：
     - @Injectable() 是否出现在所有需要注入的类上（非 Controller 的提供者类）：
       - 通过 -> 记录通过，继续下一个审查项；
       - 未通过 -> 记录“缺少 @Injectable() 装饰器，类无法被注入系统识别”，继续；
     - 自定义 useFactory 是否具备对应的 inject 依赖数组：
       - 通过 -> 记录通过，继续下一个审查项；
       - 未通过 -> 记录“useFactory 缺少 inject 数组，依赖无法正确注入”，继续；
     - 注入作用域是否合理（避免不必要地使用 REQUEST 作用域导致性能下降）：
       - 通过 -> 记录通过，继续下一个审查项；
       - 未通过 -> 记录“REQUEST 作用域可能导致性能问题，确认是否需要每次新建实例”，继续；
     - 是否存在循环依赖（A 注入 B，B 注入 A）：
       - 通过 -> 记录通过，继续下一个审查项；
       - 未通过 -> 记录“检测到循环依赖，建议使用 forwardRef() 解决”，继续；
     - Provider 的 token 是否使用了字符串常量而非 Symbol 或类名（容易冲突）：
       - 通过 -> 记录通过，继续下一个审查项；
       - 未通过 -> 记录“建议使用类名或 Symbol 作为 Provider token 代替字符串”，继续；
     - 异步提供者中是否正确处理了异步初始化逻辑：
       - 通过 -> 记录通过，继续下一个审查项；
       - 未通过 -> 记录“异步提供者需返回 Promise，确保初始化完成后再注入”，继续；
   - 判断是否有任何问题记录：
     - 是 -> 汇总问题列表，进入下一步；
     - 否 -> 直接进入步骤 4（复核检查）；

3. **提供修改建议** — 对发现的问题给出具体修复方案；
   - 依次对每个问题提供修复建议，包括错误用法和正确用法对比；
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
  - 审查项须引用 NestJS 官方文档关于 DI 的标准；
  - SKILL.md 不超过 300 行；超过时拆分到 references/ 目录；
  - 引用层次不超过一层；
  - 保持术语一致，Definitions 中已定义术语在正文中通过锚点链接引用；
  - 删除任何时效性信息；

- **行为规范**
  - 审查时仅输出问题摘要和定位，不直接修改代码，除非用户通过 AskUserQuestion 明确要求；
  - 所有涉及代码修改的交互环节，必须使用 AskUserQuestion 工具；
  - 作用域建议标注为建议而非强制，提供性能影响说明；

- **防御规范**
  - 如目标代码为空或不可读，直接报告并终止；
  - 循环依赖检测仅基于可见的 import 关系，不可跨文件分析时标注为需要手动确认；

- **验证规范**
  - Examples 内容必须自洽于 Rules；
  - Examples 必须包含复核检查示例；
  - 对话交互示例仅聚焦步骤 0~3（不含复核检查和成果输出）；

## Examples

### 对话交互示例

**示例：用户请求审查依赖注入配置**

```markdown
用户 > 帮我检查这个模块的依赖注入配置
AI   > 检测到用户需要 NestJS 依赖注入审查，触发 nestjs-1-3-dependency-injection 技能
AI   > 正在分析 DI 配置...

审查结果：
- 🟩 UserService 上存在 @Injectable() 装饰器
- 🟥 CustomProvider 的 useFactory 缺少 inject 数组
- 🟩 默认使用 SINGLETON 作用域，性能良好
- 🟥 AuthModule 和 UserModule 之间存在循环依赖
- 🟩 Provider token 使用类名而非字符串

总评：2 个问题需要关注
用户 > 请帮我修复循环依赖问题
AI   > 建议在 AuthModule 中使用 forwardRef(() => UserModule)，
      同时在 UserModule 中使用 forwardRef(() => AuthModule)。
      是否要应用这个修改？
用户 > 是，请修改
```

### 复核检查示例

```markdown
AI > 进入复核检查，Review List 包含 6 个检查项，开始逐项验收：

**内容检查**
  - 🟩 审查项全部引用官方 DI 标准
  - 🟩 作用域建议标注为建议并附性能说明

**行为检查**
  - 🟩 未直接修改用户代码
  - 🟩 使用了 AskUserQuestion 确认修改

**验证检查**
  - 🟩 循环依赖标注为需手动确认
  - 🟩 输出摘要完整

✅ 全部通过，进入成果输出。
```

### 成果输出示例

**审查结果示例：**

```markdown
| 维度 | 结果 |
| --- | --- |
| 审查文件 | src/auth/auth.module.ts、src/user/user.module.ts |
| 审查项总数 | 8 项 |
| 通过 | 6 项 |
| 发现问题 | 2 项 |
| 风险等级 | 🔴 高 |
| 已采纳建议 | 1 条 |
| 已忽略/仅查看 | 1 条 |
```

## Review List

- **内容检查**
  - [ ] 审查项全部引用 NestJS 官方 DI 标准
  - [ ] 作用域建议标注为建议并提供性能影响说明
- **行为检查**
  - [ ] 未直接修改用户代码（除非用户明确要求）
  - [ ] 所有交互环节使用了 AskUserQuestion
- **验证检查**
  - [ ] 目标代码为空或不可读时已正确终止
  - [ ] 循环依赖不可跨文件分析时已标注需手动确认
  - [ ] 输出摘要包含了文件路径、审查项数、发现问题和风险等级

## References

- [NestJS 提供者官方文档](https://docs.nestjs.com/providers)
- [NestJS 自定义提供者](https://docs.nestjs.com/fundamentals/custom-providers)
- [NestJS 注入作用域](https://docs.nestjs.com/fundamentals/injection-scopes)
- [NestJS 循环依赖](https://docs.nestjs.com/fundamentals/circular-dependency)
- [skill-evolve 模板](../../skill-evolve/template.md)
