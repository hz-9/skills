# prisma mcp

启动 Prisma 的 MCP 服务器，用于 AI 开发工具。

## 命令

```bash
prisma mcp
```

## 功能说明

- 为你的 Prisma 项目启动一个 Model Context Protocol (MCP) 服务器
- 向兼容的 AI 工具暴露 Prisma schema 和数据库上下文
- 帮助 AI 助手理解模型、生成查询和建议迁移

## 用法

```bash
prisma mcp
```

## 典型用例

- 将 Prisma 连接到 ChatGPT、Claude 或其他支持 MCP 的工具
- 让 AI 助手访问你的 Prisma schema 结构
- 帮助 AI 代理在项目上下文中提出查询、schema 更新和迁移步骤

## 注意事项

- 在包含 Prisma schema 和 `prisma.config.ts` 的项目目录中运行此命令
- 该命令与 Prisma Studio 分开，不会打开浏览器 UI
- MCP 服务器包装了 Prisma CLI 命令。对于 `migrate dev` 或 `migrate reset` 等命令的确切行为，请遵循底层 CLI 命令文档，而不是仅依赖 MCP 工具描述。

## 参考

- [Prisma CLI `mcp` 命令](https://docs.prisma.io/docs/cli/mcp)
- [Prisma MCP 服务器](https://www.prisma.io/docs/ai/tools/chatgpt)
