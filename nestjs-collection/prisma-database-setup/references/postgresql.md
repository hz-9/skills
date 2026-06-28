# PostgreSQL 设置

配置 Prisma 与 PostgreSQL。

## 前提条件

- PostgreSQL 数据库（本地或云端）
- 连接字符串

## 1. Schema 配置

在 `prisma/schema.prisma` 中：

```prisma
datasource db {
  provider = "postgresql"
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
DATABASE_URL="postgresql://user:password@localhost:5432/mydb?schema=public"
```

### 连接字符串格式

```
postgresql://用户名:密码@主机:端口/数据库?schema=模式名
```

- **用户名**：数据库用户
- **密码**：密码（如有特殊字符需 URL 编码）
- **主机**：主机名（localhost、IP 或域名）
- **端口**：端口（默认 5432）
- **数据库**：数据库名称
- **模式名**：模式名称（默认 `public`）

## 驱动适配器

使用驱动适配器进行标准 SQL 工作流。

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

## 常见问题

### "无法连接数据库服务器"
- 检查主机和端口
- 检查防火墙设置
- 确保数据库正在运行

### "认证失败"
- 检查用户名/密码
- 密码中的特殊字符需要进行 URL 编码

### "模式不存在"
- 确保 URL 中包含 `?schema=public`（或你的模式名）
