---
name: nestjs-9-2-openapi-swagger
description: Review NestJS OpenAPI/Swagger documentation generation and configuration, covering @nestjs/swagger decorators, DTO mapping, and document grouping. Use this when users need to review API documentation configuration or optimize Swagger output.
---

# NestJS OpenAPI Standard Automation

## Overview

When AI encounters Swagger configuration code in a NestJS project, it automatically performs the following: review SwaggerModule.setup configuration and documentation options, check DTO and API decorator consistency, evaluate document grouping and tag completeness, and provide improvement suggestions.

## Definitions

- <a id="swaggermodule"></a>**SwaggerModule**: The main module provided by @nestjs/swagger, used to generate and mount API documentation via SwaggerModule.createDocument and SwaggerModule.setup.
- <a id="api-decorator"></a>**API Decorator**: Decorators such as @ApiTags, @ApiOperation, @ApiResponse, @ApiBearerAuth used to enrich OpenAPI documentation.

## Prerequisites

- NestJS project environment (@nestjs/swagger dependency); Swagger configuration code accessible.

## Workflow

0. **Pre-check** — Ensure target code exists and is readable;
1. **Analyze code** — Read Swagger module configuration and API decorator usage;
2. **Item-by-item review** — Check SwaggerModule.setup configuration, @ApiTags grouping, @ApiOperation description, @ApiResponse response definition, BearerAuth configuration;
3. **Provide modification suggestions** — Confirm via AskUserQuestion;
4. **Review check**;
5. **Output results**;

## Rules

- Interaction steps use AskUserQuestion; decorator supplementation should be marked as documentation improvement suggestion.

## Examples

### Conversation Interaction Example

```markdown
User > Help me check the Swagger documentation configuration
AI   > Triggered nestjs-9-2-openapi-swagger skill...
Review Results:
- 🟩 SwaggerModule.setup configured at /api path
- 🟥 DTO properties missing @ApiProperty decorator, won't show in documentation
- 🟩 @ApiTags grouped by controller
- 🟥 @ApiBearerAuth not configured
User > Help me add @ApiProperty and @ApiBearerAuth
AI   > Apply changes? User > Yes
```

### Review Check Example

```markdown
AI > Review check passed ✅
```

### Output Example

```markdown
| Reviewed File | src/main.ts | Total Review Items | 6 | Passed | 4 | Issues Found | 2 |
```

## Review List

- [ ] Reported when @ApiProperty missing; [ ] Reported when @ApiBearerAuth missing; [ ] Output summary is complete

## References

- [NestJS OpenAPI](https://docs.nestjs.com/openapi/introduction)
- [skill-evolve Template](../../skill-evolve/template.md)
