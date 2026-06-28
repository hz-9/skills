# MySQL 设置

配置 Prisma 与 MySQL（或 MariaDB）。

## 前提条件

- MySQL 或 MariaDB 数据库
- 连接字符串

## 1. Schema 配置

在 `prisma/schema.prisma` 中：

```prisma
datasource db {
  provider = "mysql"
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
DATABASE_URL="mysql://user:password@localhost:3306/mydb"
```

### 连接字符串格式

```
mysql://用户名:密码@主机:端口/数据库
```

- **用户名**：数据库用户
- **密码**：密码
- **主机**：主机名
- **端口**：端口（默认 3306）
- **数据库**：数据库名称

## 驱动适配器

使用驱动适配器进行标准 SQL 工作流。

1. 安装适配器和驱动：
   ```bash
   npm install @prisma/adapter-mariadb mariadb
   ```

2. 使用适配器实例化 Prisma Client：
   ```typescript
   import 'dotenv/config'
   import { PrismaClient } from '../generated/client'
   import { PrismaMariaDb } from '@prisma/adapter-mariadb'

   const adapter = new PrismaMariaDb({
     host: 'localhost',
     port: 3306,
     connectionLimit: 5,
     user: process.env.MYSQL_USER,
     password: process.env.MYSQL_PASSWORD,
     database: process.env.MYSQL_DATABASE,
   })

   const prisma = new PrismaClient({ adapter })
   ```

### 文本协议选项

如果你需要 MariaDB 驱动的文本协议而非默认的二进制 `execute()` 路径，请显式启用 `useTextProtocol`：

```typescript
import { PrismaClient } from '../generated/client'
import { PrismaMariaDb } from '@prisma/adapter-mariadb'

const adapter = new PrismaMariaDb(process.env.DATABASE_URL!, {
  useTextProtocol: true,
})

const prisma = new PrismaClient({ adapter })
```

仅当你确实需要为你的 MariaDB 设置使用文本协议兼容性时，才使用此选项。

## PlanetScale 设置

PlanetScale 使用 MySQL，但由于不支持外键约束，需要特定设置。

在 `prisma/schema.prisma` 中：

```prisma
datasource db {
  provider     = "mysql"
  relationMode = "prisma" // 在 Prisma 中模拟外键
}
```

## 常见问题

### "连接过多"
MySQL 有连接数限制。在 URL 中调整连接池大小：
```env
DATABASE_URL="mysql://...?connection_limit=5"
```

### JSON 支持
MySQL 5.7+ 支持 JSON。MariaDB 10.2+ 支持 JSON（作为带检查约束的 LONGTEXT 别名）。Prisma 可处理此问题，但请验证你的版本。
