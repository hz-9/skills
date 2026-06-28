# CockroachDB 设置

配置 Prisma 与 CockroachDB。

## 前提条件

- CockroachDB 集群

## 1. Schema 配置

在 `prisma/schema.prisma` 中：

```prisma
datasource db {
  provider = "cockroachdb"
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

## 3. 环境变量

在 `.env` 中：

```env
DATABASE_URL="postgresql://user:password@host:26257/db?sslmode=verify-full"
```

注意：CockroachDB 使用 PostgreSQL 线路协议，因此 URL 通常看起来像 postgresql，但 schema 中的提供者**必须**是 `cockroachdb`，以便正确处理 CRDB 的特定功能。

## 驱动适配器

使用驱动适配器进行标准 SQL 工作流。CockroachDB 兼容 PostgreSQL，因此使用 PostgreSQL 适配器。

1. 安装适配器和驱动：
   ```bash
   npm install @prisma/adapter-pg pg
   ```

2. 使用适配器实例化 Prisma Client：
   ```typescript
   import 'dotenv/config'
   import { PrismaClient } from '../generated/client'
   import { PrismaPg } from '@prisma/adapter-pg'

   const adapter = new PrismaPg({ connectionString: process.env.DATABASE_URL })
   const prisma = new PrismaClient({ adapter })
   ```

## ID 生成

CockroachDB 高效地使用 `BigInt` 或 `UUID` 作为 ID。

```prisma
model User {
  id BigInt @id @default(autoincrement()) // 使用 unique_rowid()
}
```

或者使用字符串 UUID：

```prisma
model User {
  id String @id @default(dbgenerated("gen_random_uuid()")) @db.Uuid
}
```

## 常见问题

### Schema 逆向工程
始终使用 `provider = "cockroachdb"` 以确保在 `db pull` 期间正确的类型映射。
