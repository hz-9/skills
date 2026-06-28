---
name: prisma-database-setup
description: 配置 Prisma 与不同数据库提供者（PostgreSQL、MySQL、SQLite、MongoDB 等）的指南。在设置新项目、切换数据库或排查连接问题时使用。触发词为 "configure postgres"、"connect to mysql"、"setup mongodb"、"sqlite setup"。
license: MIT
metadata:
  author: prisma
  version: "7.6.0"
---

# Prisma 数据库设置

配置 Prisma ORM 与各种数据库提供者的综合指南。

## 何时使用

在以下情况参考本技能：
- 初始化新的 Prisma 项目
- 切换数据库提供者
- 配置连接字符串和环境变量
- 排查数据库连接问题
- 设置数据库特定功能
- 生成和实例化 Prisma Client

## 按优先级分类的规则类别

| 优先级 | 类别 | 影响 | 前缀 |
|--------|------|------|------|
| 1 | 提供者指南 | 关键 | 提供者名称 |
| 2 | Prisma Postgres | 高 | `prisma-postgres` |
| 3 | 客户端设置 | 关键 | `prisma-client-setup` |

## 系统前提条件

- **Node.js 20.19.0+**
- **TypeScript 5.4.0+**

## Bun 运行时

如果你使用 Bun，请使用 `bunx --bun prisma ...` 运行 Prisma CLI 命令，这样 Prisma 将使用 Bun 运行时而非回退到 Node.js。

## 支持的数据库

| 数据库 | 提供者字符串 | 说明 |
|--------|-------------|------|
| PostgreSQL | `postgresql` | 默认，完整功能支持 |
| MySQL | `mysql` | 广泛支持，部分 JSON 差异 |
| SQLite | `sqlite` | 本地文件存储，不支持枚举/标量列表 |
| MongoDB | `mongodb` | Mongo 特定工作流；不要应用 SQL 驱动适配器指南 |
| SQL Server | `sqlserver` | Microsoft 生态系统 |
| CockroachDB | `cockroachdb` | 分布式 SQL，兼容 PostgreSQL |
| Prisma Postgres | `postgresql` | 托管无服务器数据库 |

## 配置文件

你的配置形式取决于提供者和 Prisma 主版本：

1. **所有提供者** 都使用 **`prisma/schema.prisma`**。
2. **Prisma 7 SQL 设置** 通常使用 **`prisma.config.ts`** 配置数据源 URL。
3. **MongoDB 项目应保持在 Prisma 6.x**，在 schema 中保留 `url = env("DATABASE_URL")`，并继续使用经典的 MongoDB 设置。

## 驱动适配器

标准 SQL 工作流使用驱动适配器。为你的数据库选择适配器和驱动，并将适配器传递给 `PrismaClient`。

| 数据库 | 适配器 | JS 驱动 |
|--------|--------|---------|
| PostgreSQL | `@prisma/adapter-pg` | `pg` |
| CockroachDB | `@prisma/adapter-pg` | `pg` |
| Prisma Postgres（Node.js） | `@prisma/adapter-pg` | `pg` |
| Prisma Postgres（边缘/无服务器） | `@prisma/adapter-ppg` | `@prisma/ppg` |
| MySQL / MariaDB | `@prisma/adapter-mariadb` | `mariadb` |
| SQLite | `@prisma/adapter-better-sqlite3` | `better-sqlite3` |
| SQLite（Turso/LibSQL） | `@prisma/adapter-libsql` | `@libsql/client` |
| SQL Server | `@prisma/adapter-mssql` | `node-mssql` |

MongoDB 不应遵循 Prisma 7 SQL 适配器工作流。MongoDB 项目请使用最新的 Prisma 6.x 版本，不要为其安装 SQL 的 `@prisma/adapter-*` 包。

示例（PostgreSQL）：

```ts
import 'dotenv/config'
import { PrismaClient } from '../generated/client'
import { PrismaPg } from '@prisma/adapter-pg'

const adapter = new PrismaPg({ connectionString: process.env.DATABASE_URL })
const prisma = new PrismaClient({ adapter })
```

## Prisma Client 设置（必需）

必须安装并生成 Prisma Client 才能使用任何数据库。

1. 安装 Prisma CLI 和 Prisma Client：
   ```bash
   npm install prisma --save-dev
   npm install @prisma/client
   ```

1. 添加 generator 块（`prisma-client` 需要显式的 output 路径）：
   ```prisma
   generator client {
     provider = "prisma-client"
     output   = "../generated"
   }
   ```

1. 生成 Prisma Client：
   ```bash
   npx prisma generate
   ```

1. 对于 SQL 提供者，使用数据库特定的驱动适配器实例化 Prisma Client：
   ```typescript
   import { PrismaClient } from '../generated/client'
   import { PrismaPg } from '@prisma/adapter-pg'

   const adapter = new PrismaPg({ connectionString: process.env.DATABASE_URL })
   const prisma = new PrismaClient({ adapter })
   ```

1. 每次 schema 更改后重新运行 `prisma generate`。

## 快速参考

### PostgreSQL
```prisma
datasource db {
  provider = "postgresql"
}

generator client {
  provider = "prisma-client"
  output   = "../generated"
}
```

### MySQL
```prisma
datasource db {
  provider = "mysql"
}

generator client {
  provider = "prisma-client"
  output   = "../generated"
}
```

### SQLite
```prisma
datasource db {
  provider = "sqlite"
}

generator client {
  provider = "prisma-client"
  output   = "../generated"
}
```

### MongoDB
```prisma
datasource db {
  provider = "mongodb"
  url      = env("DATABASE_URL")
}

generator client {
  provider = "prisma-client-js"
}
```

对于 MongoDB，请保持在最新的 Prisma 6.x 版本，并将连接 URL 保留在 `schema.prisma` 中。不要将 MongoDB 项目迁移到 Prisma 7 SQL 适配器设置。

## 规则文件

查看各个规则文件以获取详细的设置说明：

```
references/postgresql.md
references/mysql.md
references/sqlite.md
references/mongodb.md
references/sqlserver.md
references/cockroachdb.md
references/prisma-postgres.md
references/prisma-client-setup.md
```

## 使用方法

选择数据库对应的提供者参考文件，然后应用 `references/prisma-client-setup.md` 完成客户端生成和适配器设置。对于 MongoDB，请使用 `references/mongodb.md`，而不是复制 SQL 适配器示例或 Prisma 7 配置模式。
