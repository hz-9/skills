# NestJS Best Practices

📖 [For Humans <3](https://kadajett.github.io/agent-nestjs-skills/)

一个用于创建和维护 NestJS 最佳实践的结构化仓库，针对 Agent 和 LLM 进行了优化。

## Installation

使用 [skills](https://github.com/vercel-labs/skills) 安装此技能：

```bash
# GitHub shorthand
npx skills add Kadajett/agent-nestjs-skills

# Install globally (available across all projects)
npx skills add Kadajett/agent-nestjs-skills --global

# Install for specific agents
npx skills add Kadajett/agent-nestjs-skills -a claude-code -a cursor
```

### Supported Agents

- Claude Code
- OpenCode
- Codex
- Cursor
- Antigravity
- Roo Code

## Structure

- `rules/` - 单个规则文件（每个规则一个文件）
  - `_sections.md` - 章节元数据（标题、影响、描述）
  - `_template.md` - 创建新规则的模板
  - `area-description.md` - 单个规则文件
- `scripts/` - 构建脚本和工具
- `metadata.json` - 文档元数据（版本、组织、摘要）
- __`AGENTS.md`__ - 编译输出（自动生成）

## Getting Started

1. 安装依赖：
   ```bash
   cd scripts && npm install
   ```

2. 从规则构建 AGENTS.md：
   ```bash
   npm run build
   # or
   ./scripts/build.sh
   ```

## Creating a New Rule

1. 复制 `rules/_template.md` 到 `rules/area-description.md`
2. 选择适当的领域前缀：
   - `arch-` 用于 Architecture（第 1 节）
   - `di-` 用于 Dependency Injection（第 2 节）
   - `error-` 用于 Error Handling（第 3 节）
   - `security-` 用于 Security（第 4 节）
   - `perf-` 用于 Performance（第 5 节）
   - `test-` 用于 Testing（第 6 节）
   - `db-` 用于 Database & ORM（第 7 节）
   - `api-` 用于 API Design（第 8 节）
   - `micro-` 用于 Microservices（第 9 节）
   - `devops-` 用于 DevOps & Deployment（第 10 节）
3. 填写 frontmatter 和内容
4. 确保有清晰的示例并包含解释
5. 运行构建脚本以重新生成 AGENTS.md

## Rule File Structure

每个规则文件应遵循以下结构：

```markdown
---
title: Rule Title Here
impact: MEDIUM
impactDescription: Optional description
tags: tag1, tag2, tag3
---

## Rule Title Here

Brief explanation of the rule and why it matters.

**Incorrect (description of what's wrong):**

```typescript
// Bad code example
```

**Correct (description of what's right):**

```typescript
// Good code example
```

Optional explanatory text after examples.

Reference: [NestJS Documentation](https://docs.nestjs.com)


## File Naming Convention

- 以 `_` 开头的文件是特殊的（构建时排除）
- 规则文件：`area-description.md`（例如 `arch-avoid-circular-deps.md`）
- 章节从文件名前缀自动推断
- 规则在每个章节内按标题字母顺序排序
- ID（如 1.1、1.2）在构建时自动生成

## Impact Levels

| Level | Description |
|-------|-------------|
| CRITICAL | 违反会导致运行时错误、安全漏洞或架构崩溃 |
| HIGH | 对可靠性、安全性或可维护性有显著影响 |
| MEDIUM-HIGH | 对质量和开发者体验有显著影响 |
| MEDIUM | 对代码质量和最佳实践有中等影响 |
| LOW-MEDIUM | 对一致性和可维护性的微小改进 |

## Scripts

- `npm run build`（在 scripts/ 目录中）- 将规则编译为 AGENTS.md

## Contributing

添加或修改规则时：

1. 为你的章节使用正确的文件名前缀
2. 遵循 `_template.md` 结构
3. 包含清晰的错误/正确示例及解释
4. 添加适当的标签
5. 运行构建脚本以重新生成 AGENTS.md
6. 规则会自动按标题排序 — 无需管理编号！

## Documentation Website

文档网站源代码位于 [`docs` 分支](https://github.com/Kadajett/agent-nestjs-skills/tree/docs/website)。这种分离使技能安装保持轻量，同时维护完整的文档站点。

要为网站做贡献：

```bash
git checkout docs
cd website
npm install
npm run dev
```

## Acknowledgments

- 受 [Vercel React Best Practices](https://github.com/vercel-labs/agent-skills) 技能结构的启发
- 兼容 [skills](https://github.com/vercel-labs/skills)，易于跨编码 Agent 安装

## Compatible Agents

这些 NestJS 技能适用于：

- [Claude Code](https://claude.ai/code) - Anthropic 的官方 CLI
- [AdaL](https://sylph.ai/adal) - 支持 MCP 的自我进化 AI 编码 Agent
