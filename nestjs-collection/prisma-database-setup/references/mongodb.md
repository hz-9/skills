# MongoDB 设置

MongoDB 项目应保持在最新的 Prisma 6.x 版本。不要将 MongoDB 应用升级到 Prisma 7 的 SQL 客户端路径。

## 前提条件

- MongoDB 4.2+
- 副本集已配置（事务必需）
- 最新的 Prisma 6.x 版本，或团队指定的 Prisma 6 版本
- Node.js 20.19.0+
- TypeScript 5.4.0+

## 1. Schema 配置

使用标准的 Prisma 6 MongoDB 设置，搭配 `prisma-client-js`。

在 `prisma/schema.prisma` 中：

```prisma
datasource db {
  provider = "mongodb"
  url      = env("DATABASE_URL")
}

generator client {
  provider = "prisma-client-js"
}
```

### 驱动适配器

请**不要**在此处应用 Prisma 7 SQL 适配器设置。MongoDB 不使用 SQL 的 `@prisma/adapter-*` 包。

### ID 字段要求

MongoDB 模型**必须**使用 `@id` 和 `@map("_id")` 映射 `_id` 字段，通常为 `String` 类型，使用 `auto()` 和 `db.ObjectId`。

```prisma
model User {
  id    String @id @default(auto()) @map("_id") @db.ObjectId
  email String @unique
  name  String?
}
```

### 关联关系

MongoDB 中的关联关系要求 ID 为 `db.ObjectId` 类型。

```prisma
model Post {
  id       String @id @default(auto()) @map("_id") @db.ObjectId
  author   User   @relation(fields: [authorId], references: [id])
  authorId String @db.ObjectId
}
```

## 2. 环境变量

在 `.env` 中：

```env
DATABASE_URL="mongodb+srv://user:password@cluster.mongodb.net/mydb?retryWrites=true&w=majority"
```

## 迁移 vs 逆向工程

- **不支持迁移**：MongoDB 是无 schema 的。`prisma migrate` 命令**无法工作**。
- **db push**：使用 `prisma db push` 同步索引和约束。
- **db pull**：使用 `prisma db pull` 从现有数据生成 schema（采样方式）。

## 当前验证说明

- `prisma init --datasource-provider mongodb` 在 Prisma CLI 源码中仍然可用。
- Prisma 上游仓库仍然包含 MongoDB 的测试用例和测试数据。
- 本地验证表明 Prisma 7 仍可识别 MongoDB 输入，但生成的客户端路径不提供受支持的 MongoDB 升级路径。
- 本地验证表明 Prisma 6.x 与 `prisma-client-js`、`prisma db push` 和 `new PrismaClient()` 配合使用，可与 MongoDB 副本集端到端工作。

## 版本建议

- 对于 MongoDB，请保持在最新的可用 Prisma 6.x 版本。
- 在 Prisma 提供真正的 MongoDB 升级路径之前，将 Prisma 7 MongoDB 迁移尝试视为不受支持。

## 常见问题

### "不支持事务"
确保你的 MongoDB 实例是**副本集**。独立实例不支持事务。Atlas 集群默认为副本集。

### "无效的 ObjectID"
确保引用 ID 的字段使用了 `@db.ObjectId` 装饰，如果目标字段是 ObjectID 的话。
