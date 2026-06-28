# SQL Server 设置

配置 Prisma 与 Microsoft SQL Server。

## 前提条件

- SQL Server 2017、2019、2022 或 Azure SQL
- 已启用 TCP/IP

## 1. Schema 配置

在 `prisma/schema.prisma` 中：

```prisma
datasource db {
  provider = "sqlserver"
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
DATABASE_URL="sqlserver://localhost:1433;database=mydb;user=sa;password=Password123;encrypt=true;trustServerCertificate=true"
```

### 连接字符串格式

```
sqlserver://主机:端口;database=数据库;user=用户;password=密码;encrypt=true;trustServerCertificate=true
```

- **encrypt**：Azure 必需（true）。
- **trustServerCertificate**：对于自签名证书为 true（本地开发）。

## 驱动适配器

使用驱动适配器进行标准 SQL 工作流。

1. 安装适配器和驱动：
   ```bash
   npm install @prisma/adapter-mssql mssql
   ```

2. 使用适配器实例化 Prisma Client：
   ```typescript
   import 'dotenv/config'
   import { PrismaClient } from '../generated/client'
   import { PrismaMssql } from '@prisma/adapter-mssql'

   const adapter = new PrismaMssql({
     server: 'localhost',
     port: 1433,
     database: 'mydb',
     user: process.env.SQLSERVER_USER,
     password: process.env.SQLSERVER_PASSWORD,
     options: {
       encrypt: true,
       trustServerCertificate: true,
     },
   })

   const prisma = new PrismaClient({ adapter })
   ```

## 常见问题

### "用户登录失败"
- SQL Server 身份验证与 Windows 身份验证。Prisma 通常使用 SQL Server 身份验证（用户名/密码）。
- 确保在 SQL Server 配置管理器中启用了 TCP/IP。

### "找不到表"（dbo 模式）
Prisma 默认使用 `dbo` 模式。如果使用其他模式，请更新模型或连接字符串？SQL Server 提供者主要使用默认模式。
