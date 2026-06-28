# prisma init

在当前目录中引导一个全新的 Prisma ORM 项目。

## 命令

```bash
prisma init [options]
```

## Bun 运行时

如果你使用 Bun，请使用 `bunx --bun` 运行 Prisma，这样它不会回退到 Node.js：

```bash
bunx --bun prisma init
```

## 创建的内容

- `prisma/schema.prisma` - 你的 Prisma schema 文件
- `prisma.config.ts` - Prisma CLI 的 TypeScript 配置
- `.env` - 环境变量（DATABASE_URL）
- `.gitignore` - 确保 `.env` 被忽略，并追加生成的客户端路径

## 选项

| 选项 | 描述 | 默认值 |
|--------|-------------|---------|
| `--datasource-provider` | 数据库提供者：`postgresql`、`mysql`、`sqlite`、`sqlserver`、`mongodb`、`cockroachdb` | `postgresql` |
| `--db` | 在 Prisma Data Platform 上配置一个完全托管的 Prisma Postgres 数据库 | - |
| `--url` | 定义自定义数据源 URL | - |
| `--generator-provider` | 定义要使用的 generator 提供者 | `prisma-client` |
| `--output` | 定义 Prisma Client generator 的输出路径 | - |
| `--preview-feature` | 定义要使用的预览功能 | - |
| `--with-model` | 在创建的 schema 文件中添加示例模型 | - |

## 示例

### 基本初始化

```bash
prisma init
```

创建一个 PostgreSQL 项目设置。

### SQLite 项目

```bash
prisma init --datasource-provider sqlite
```

### 带自定义 URL 的 MySQL

```bash
prisma init --datasource-provider mysql --url "mysql://user:password@localhost:3306/mydb"
```

### Prisma Postgres（云端）

```bash
prisma init --db
```

打开浏览器进行身份验证，创建云数据库实例。

### 添加示例模型

```bash
prisma init --with-model
```

在生成的 schema 中添加一个入门模型。

### 使用预览功能

```bash
prisma init --preview-feature relationJoins --preview-feature fullTextSearch
```

## 生成的 Schema

```prisma
generator client {
  provider = "prisma-client"
  output   = "../generated/prisma"
}

datasource db {
  provider = "postgresql"
}
```

## 生成的配置（Node.js 默认）

```typescript
// prisma.config.ts
import "dotenv/config";
import { defineConfig } from 'prisma/config'

export default defineConfig({
  schema: 'prisma/schema.prisma',
  migrations: {
    path: 'prisma/migrations',
  },
  datasource: {
    url: process.env['DATABASE_URL'],
  },
})
```

## 生成的配置（Bun）

```typescript
import { defineConfig, env } from 'prisma/config'

export default defineConfig({
  schema: 'prisma/schema.prisma',
  migrations: {
    path: 'prisma/migrations',
  },
  datasource: {
    url: env('DATABASE_URL'),
  },
})
```

## 初始化后的下一步

1. 在 `.env` 中配置 `DATABASE_URL`（并让 `prisma.config.ts` 读取它）
2. 在 `prisma/schema.prisma` 中定义你的模型
3. 运行 `prisma dev` 进行本地开发或连接到远程数据库
4. 运行 `prisma migrate dev` 创建迁移
5. 运行 `prisma generate` 生成 Prisma Client
6. 如果需要种子数据，显式运行 `prisma db seed`
