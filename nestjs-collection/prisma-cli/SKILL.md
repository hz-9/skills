---
name: prisma-cli
description: Prisma CLI 命令参考，涵盖所有可用命令、选项和使用模式。在运行 Prisma CLI 命令、设置项目、生成客户端、运行迁移、管理数据库或启动 Prisma 的 MCP 服务器时使用。触发关键词："prisma init", "prisma generate", "prisma migrate", "prisma db", "prisma studio", "prisma mcp"。
license: MIT
metadata:
  author: prisma
  version: "7.6.0"
---

# Prisma CLI 参考

所有 Prisma CLI 命令的完整参考。本技能提供关于命令用法、选项和当前 Prisma 版本最佳实践的指导。

## 何时使用

在以下情况下参考本技能：
- 设置新的 Prisma 项目（`prisma init`）
- 生成 Prisma Client（`prisma generate`）
- 运行数据库迁移（`prisma migrate`）
- 管理数据库状态（`prisma db push/pull`）
- 使用本地开发数据库（`prisma dev`）
- 调试 Prisma 问题（`prisma debug`）

## 规则分类（按优先级）

| 优先级 | 分类 | 影响 | 前缀 |
|----------|----------|--------|--------|
| 1 | 设置 | 高 | `init` |
| 2 | 生成 | 高 | `generate` |
| 3 | 开发 | 高 | `dev` |
| 4 | 数据库操作 | 高 | `db-` |
| 5 | 迁移 | 关键 | `migrate-` |
| 6 | 工具 | 中 | `studio`, `validate`, `format`, `debug`, `mcp` |

## 命令分类

| 分类 | 命令 | 用途 |
|----------|----------|---------|
| 设置 | `init` | 引导新的 Prisma 项目 |
| 生成 | `generate` | 生成 Prisma Client |
| 验证 | `validate`, `format` | Schema 验证和格式化 |
| 开发 | `dev` | 用于开发的本地 Prisma Postgres |
| 数据库操作 | `db pull`, `db push`, `db seed`, `db execute` | 直接数据库操作 |
| 迁移 | `migrate dev`, `migrate deploy`, `migrate reset`, `migrate status`, `migrate diff`, `migrate resolve` | Schema 迁移 |
| 工具 | `studio`, `mcp`, `version`, `debug` | 开发和 AI 工具 |

## 快速参考

### 项目设置

```bash
# 初始化新项目（创建 prisma/ 文件夹和 prisma.config.ts）
prisma init

# 使用特定数据库初始化
prisma init --datasource-provider postgresql
prisma init --datasource-provider mysql
prisma init --datasource-provider sqlite

# 使用 Prisma Postgres（云端）初始化
prisma init --db

# 使用示例模型初始化
prisma init --with-model
```

### 客户端生成

```bash
# 生成 Prisma Client
prisma generate

# 开发模式下的监听模式
prisma generate --watch

# 仅生成指定的 generator
prisma generate --generator client
```

### Bun 运行时

使用 Bun 时，始终添加 `--bun` 标志，以便 Prisma 使用 Bun 运行时运行（否则由于 CLI shebang，它会回退到 Node.js）：

```bash
bunx --bun prisma init
bunx --bun prisma generate
```

### 本地开发数据库

```bash
# 启动本地 Prisma Postgres
prisma dev

# 使用指定名称启动
prisma dev --name myproject

# 在后台启动（分离模式）
prisma dev --detach

# 列出所有本地实例
prisma dev ls

# 停止实例
prisma dev stop myproject

# 删除实例数据
prisma dev rm myproject
```

### 数据库操作

```bash
# 从现有数据库拉取 Schema
prisma db pull

# 推送 Schema 到数据库（无迁移）
prisma db push

# 填充数据库
prisma db seed

# 执行原生 SQL
prisma db execute --file ./script.sql
```

### 迁移（开发环境）

```bash
# 创建并应用迁移
prisma migrate dev

# 创建带有名称的迁移
prisma migrate dev --name add_users_table

# 仅创建迁移但不应用
prisma migrate dev --create-only

# 重置数据库并应用所有迁移
prisma migrate reset
```

### 迁移（生产环境）

```bash
# 应用待处理的迁移（CI/CD）
prisma migrate deploy

# 检查迁移状态
prisma migrate status

# 比较 schema 并生成差异
prisma migrate diff --from-config-datasource --to-schema schema.prisma --script
```

### 工具命令

```bash
# 打开 Prisma Studio（数据库 GUI）
prisma studio

# 启动 Prisma 的 MCP 服务器（用于 AI 工具）
prisma mcp

# 显示版本信息
prisma version
prisma -v

# 调试信息
prisma debug

# 验证 schema
prisma validate

# 格式化 schema
prisma format
```

## 当前 Prisma CLI 设置

### 新配置文件

使用 `prisma.config.ts` 进行 CLI 配置：

```typescript
import 'dotenv/config'
import { defineConfig, env } from 'prisma/config'

export default defineConfig({
  schema: 'prisma/schema.prisma',
  migrations: {
    path: 'prisma/migrations',
    seed: 'tsx prisma/seed.ts',
  },
  datasource: {
    url: env('DATABASE_URL'),
  },
})
```

### 当前命令行为

- 在 `migrate dev`、`db push` 或其他 schema 同步操作后，当需要新的客户端输出时，显式运行 `prisma generate`
- 在 `migrate dev` 或 `migrate reset` 后，当需要种子数据时，显式运行 `prisma db seed`
- 对原生 SQL 脚本使用 `prisma db execute --file ...`

### 环境变量

在 `prisma.config.ts` 中显式加载环境变量，通常使用 `dotenv`：

```typescript
// prisma.config.ts
import 'dotenv/config'
```

## 规则文件

有关详细命令文档，请参阅各个规则文件：

```
references/init.md           - 项目初始化
references/generate.md       - 客户端生成
references/dev.md            - 本地开发数据库
references/db-pull.md        - 数据库内省
references/db-push.md        - Schema 推送
references/db-seed.md        - 数据库填充
references/db-execute.md     - 原生 SQL 执行
references/migrate-dev.md    - 开发迁移
references/migrate-deploy.md - 生产迁移
references/migrate-reset.md  - 数据库重置
references/migrate-status.md - 迁移状态
references/migrate-resolve.md - 迁移解决
references/migrate-diff.md   - Schema 差异比较
references/studio.md         - 数据库 GUI
references/mcp.md            - Prisma MCP 服务器
references/validate.md       - Schema 验证
references/format.md         - Schema 格式化
references/debug.md          - 调试信息
```

## 如何使用

使用上面的命令分类进行导航，然后打开你需要的特定命令参考文件。
