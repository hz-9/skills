# Prisma Client 设置

为 Prisma 的标准 SQL 提供者工作流生成和实例化 Prisma Client。对于 MongoDB，请遵循 `references/mongodb.md` 中的提供者特定说明，而不是复制下面的 SQL 适配器示例。

## 1. 安装依赖

```bash
npm install prisma --save-dev
npm install @prisma/client
```

## 2. 添加 generator 块

在 `prisma/schema.prisma` 中：

```prisma
generator client {
  provider = "prisma-client"
  output   = "../generated"
}
```

`prisma-client` 需要显式的 `output` 路径，并且默认不会生成到 `node_modules` 中。

## 3. 生成 Prisma Client

```bash
npx prisma generate
```

每次 schema 更改后重新运行 `prisma generate` 以保持客户端同步。

## 4. 实例化 Prisma Client

```typescript
import { PrismaClient } from '../generated/client'
import { PrismaPg } from '@prisma/adapter-pg'

const adapter = new PrismaPg({ connectionString: process.env.DATABASE_URL })
const prisma = new PrismaClient({ adapter })
```

如果你更改了 generator 的 `output`，请更新导入路径以匹配。对于 SQL 提供者工作流，将 `PrismaPg` 替换为你的数据库对应的适配器。

## 5. 使用单例实例

每个 `PrismaClient` 实例都会创建一个连接池。在每个应用进程中重用单个实例，以避免耗尽数据库连接。
