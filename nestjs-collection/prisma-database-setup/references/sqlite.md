# SQLite 设置

配置 Prisma 与 SQLite。

## 前提条件

- 无（基于文件）

## 1. Schema 配置

在 `prisma/schema.prisma` 中：

```prisma
datasource db {
  provider = "sqlite"
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
DATABASE_URL="file:./dev.db"
```

### 连接字符串格式

```
file:路径
```

- **路径**：数据库文件的相对路径。如有需要，请检查 `prisma.config.ts` 以确认你的应用如何解析它。

## 驱动适配器

使用驱动适配器进行标准 SQL 工作流。

1. 安装适配器和驱动：
   ```bash
   npm install @prisma/adapter-better-sqlite3 better-sqlite3
   ```

2. 使用适配器实例化 Prisma Client：
   ```typescript
   import { PrismaClient } from '../generated/client'
   import { PrismaBetterSqlite3 } from '@prisma/adapter-better-sqlite3'

   const adapter = new PrismaBetterSqlite3({
     url: process.env.DATABASE_URL ?? 'file:./dev.db',
   })

   const prisma = new PrismaClient({ adapter })
   ```

## 使用驱动适配器（LibSQL / Turso）

用于边缘兼容性或 Turso：

1. 安装：
   ```bash
   npm install @prisma/adapter-libsql @libsql/client
   ```

2. 实例化：
   ```typescript
   import { PrismaClient } from '../generated/client'
   import { PrismaLibSql } from '@prisma/adapter-libsql'

   const adapter = new PrismaLibSql({
     url: process.env.TURSO_DATABASE_URL,
     authToken: process.env.TURSO_AUTH_TOKEN,
   })
   const prisma = new PrismaClient({ adapter })
   ```

## 限制

- **不支持枚举**：SQLite 不支持枚举（Prisma 会 polyfill 或将其视为 String）。
- **不支持标量列表**：不能直接支持 `String[]`。
- **并发**：写操作会锁定文件。

## 常见问题

### "数据库文件未找到"
请确保 `DATABASE_URL` 中的路径相对于 Prisma 运行位置或 schema 文件的路径正确。`file:./dev.db` 会在 schema 旁边创建文件。
