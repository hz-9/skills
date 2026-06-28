# Prisma Postgres 设置

配置 Prisma 与 Prisma Postgres（托管服务）。

## 概述

Prisma Postgres 是一个为 Prisma 优化的无服务器托管 PostgreSQL 数据库。

## 通过 CLI 设置

你可以直接通过 CLI 配置 Prisma Postgres 实例：

```bash
prisma init --db
```

这将：
1. 让你登录 Prisma Data Platform。
2. 创建一个新的项目和数据库实例。
3. 使用连接字符串更新你的 `.env` 文件。

## 连接字符串

对于 Prisma CLI 流程和 Accelerate 风格的使用，你可能会看到 `prisma+postgres://` URL。

对于在 Node.js 中使用驱动适配器的 Prisma Client，建议使用 Prisma Postgres 控制面板中的直接 TCP 连接字符串：

```env
DATABASE_URL="postgres://identifier:key@db.prisma.io:5432/postgres?sslmode=require"
```

## 1. Schema 配置

在 `prisma/schema.prisma` 中：

```prisma
datasource db {
  provider = "postgresql" // 使用 postgresql 提供者
}

generator client {
  provider = "prisma-client"
  output   = "../generated"
}
```

## 2. Config 配置

在 `prisma.config.ts` 中：

```typescript
import { defineConfig, env } from 'prisma/config'

export default defineConfig({
  schema: 'prisma/schema.prisma',
  datasource: {
    url: env('DATABASE_URL'),
  },
})
```

## 驱动适配器

在标准 SQL 工作流中为 Prisma Postgres 使用驱动适配器。

### 推荐用于标准 Node.js 应用

1. 安装适配器和驱动：
   ```bash
   npm install @prisma/adapter-pg pg
   ```

2. 使用 Prisma Console 提供的直接 TCP 连接字符串：
   ```typescript
   import 'dotenv/config'
   import { PrismaClient } from '../generated/client'
   import { PrismaPg } from '@prisma/adapter-pg'

   const adapter = new PrismaPg({ connectionString: process.env.DATABASE_URL })
   const prisma = new PrismaClient({ adapter })
   ```

`PrismaPg` 也接受直接传入连接字符串：

```typescript
const adapter = new PrismaPg(process.env.DATABASE_URL!)
const prisma = new PrismaClient({ adapter })
```

对于 PostgreSQL 预处理语句命名，可以将适配器选项作为第二个参数传入：

```typescript
import { createHash } from 'node:crypto'

const adapter = new PrismaPg(process.env.DATABASE_URL!, {
  statementNameGenerator: ({ sql }) =>
    `prisma_${createHash('sha1').update(sql).digest('hex').slice(0, 16)}`,
})
```

### 边缘/无服务器选项

仅当你在 Workers 或 Edge Functions 等环境中需要 HTTP/WebSocket 传输时，才使用 Prisma Postgres 无服务器驱动：

```bash
npm install @prisma/adapter-ppg @prisma/ppg
```

```typescript
import { PrismaClient } from '../generated/client'
import { PrismaPostgresAdapter } from '@prisma/adapter-ppg'

const prisma = new PrismaClient({
  adapter: new PrismaPostgresAdapter({
    connectionString: process.env.PRISMA_DIRECT_TCP_URL,
  }),
})
```

此无服务器驱动是基于 HTTP/WebSocket 的边缘和无服务器运行时的专用路径，不是标准 Node.js 应用的默认推荐。

## 特性

- **无服务器**：可缩放到零。
- **缓存**：集成查询缓存（Accelerate）。
- **实时**：数据库事件（Pulse）。

## 与 Prisma Client 配合使用

在实例化 Prisma Client 时，使用上面展示的 Prisma Postgres 适配器。
