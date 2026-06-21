---
name: nestjs-9-2-openapi-swagger
description: 审查 NestJS OpenAPI/Swagger 文档生成与配置，涵盖 @nestjs/swagger 装饰器、DTO 映射和文档分组。当用户需要审查 API 文档配置或优化 Swagger 输出时使用。
---

# NestJS OpenAPI 标准自动化

## Overview

当 AI 在 NestJS 项目中遇到 Swagger 配置代码时，自动执行以下工作：审查 SwaggerModule.setup 配置和文档选项，检查 DTO 与 API 装饰器的一致性，评估文档分组和标签的完整性，并提供改进建议。

## Definitions

- <a id="SwaggerModule"></a>**SwaggerModule**：@nestjs/swagger 提供的主模块，通过 SwaggerModule.createDocument 和 SwaggerModule.setup 生成和挂载 API 文档。
- <a id="API 装饰器"></a>**API 装饰器**：@ApiTags、@ApiOperation、@ApiResponse、@ApiBearerAuth 等用于丰富 OpenAPI 文档的装饰器。

## Prerequisites

- NestJS 项目环境（@nestjs/swagger 依赖）；Swagger 配置代码可访问。

## Workflow

0. **前置检查** — 确保目标代码存在且可读取；
1. **分析代码** — 读取 Swagger 模块配置和 API 装饰器使用；
2. **逐项审查** — 检查 SwaggerModule.setup 配置、@ApiTags 分组、@ApiOperation 描述、@ApiResponse 响应定义、BearerAuth 配置；
3. **提供修改建议** — 通过 AskUserQuestion 确认；
4. **复核检查**；
5. **成果输出**；

## Rules

- 交互环节使用 AskUserQuestion；装饰器补充标注为文档完善建议。

## Examples

### 对话交互示例

```markdown
用户 > 帮我检查 Swagger 文档配置
AI   > 触发 nestjs-9-2-openapi-swagger 技能...
审查结果：
- 🟩 SwaggerModule.setup 配置在 /api 路径
- 🟥 DTO 属性缺少 @ApiProperty 装饰器，不会在文档中显示
- 🟩 @ApiTags 已按控制器分组
- 🟥 @ApiBearerAuth 未配置
用户 > 帮我添加 @ApiProperty 和 @ApiBearerAuth
AI   > 是否应用修改？用户 > 是
```

### 复核检查示例

```markdown
AI > 复核检查通过 ✅
```

### 成果输出示例

```markdown
| 审查文件 | src/main.ts | 审查项总数 | 6 项 | 通过 | 4 项 | 发现问题 | 2 项 |
```

## Review List

- [ ] @ApiProperty 缺失已报告；[ ] @ApiBearerAuth 缺失已报告；[ ] 输出摘要完整

## References

- [NestJS OpenAPI](https://docs.nestjs.com/openapi/introduction)
- [skill-evolve 模板](../../skill-evolve/template.md)
