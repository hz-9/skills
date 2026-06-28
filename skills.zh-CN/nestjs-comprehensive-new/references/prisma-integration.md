# Prisma 集成指南

融合 Prisma CLI 命令、Client API 参考和数据库设置的综合指南。

> **版本**：本文档基于 Prisma 7.6.0。如果你的项目使用 Prisma 6.x，请注意 generator 名称为 `prisma-client-js` 而非 `prisma-client`。

---

## 第一部分：Prisma 数据库设置

### 支持的数据库

| 数据库 | 提供者字符串 | 适配器 | JS 驱动 |
|--------|-------------|--------|---------|
| PostgreSQL | `postgresql` | `@prisma/adapter-pg` | `pg` |
| MySQL | `mysql` | `@prisma/adapter-mariadb` | `mariadb` |
| SQLite | `sqlite` | `@prisma/adapter-better-sqlite3` | `better-sqlite3` |
| MongoDB | `mongodb` | —（见注意事项） | — |
| SQL Server | `sqlserver` | `@prisma/adapter-mssql` | `node-mssql` |
| CockroachDB | `cockroachdb` | `@prisma/adapter-pg` | `pg` |
| Prisma Postgres | `postgresql` | `@prisma/adapter-pg` / `@prisma/adapter-ppg` | `pg` / `@prisma/ppg` |

> **MongoDB 注意事项**：MongoDB 不应遵循 Prisma 7 SQL 适配器工作流。请使用最新的 Prisma 6.x 版本 + `prisma-client-js` generator，不要安装 `@prisma/adapter-*` 包。

### 系统前提条件

- **Node.js 20.19.0+**
- **TypeScript 5.4.0+**

### 配置文件

Prisma 7 使用两种配置文件：

1. **`prisma/schema.prisma`** — 数据模型定义（所有提供者通用）
2. **`prisma.config.ts`** — CLI 配置（Prisma 7 新增）

```typescript
// prisma.config.ts
import 'dotenv/config'
import { defineConfig, env } from 'prisma/config'

export default defineConfig({
  schema: 'prisma/schema.prisma',
  migrations: {
    path: 'prisma/migrations',
    seed: 'tsx prisma/seed.ts',
  },
  datasource: {
    url: env('DATABASE_URL'),
  },
})
```

### Prisma Client 设置流程

1. 安装依赖：
   ```bash
   npm install prisma --save-dev
   npm install @prisma/client
   ```

2. 在 `prisma/schema.prisma` 中添加 generator 块：
   ```prisma
   generator client {
     provider = "prisma-client"
     output   = "../generated"
   }
   ```

3. 生成 Prisma Client：
   ```bash
   npx prisma generate
   ```

4. 对于 SQL 提供者，使用驱动适配器实例化：
   ```typescript
   import { PrismaClient } from '../generated/client'
   import { PrismaPg } from '@prisma/adapter-pg'

   const adapter = new PrismaPg({ connectionString: process.env.DATABASE_URL })
   const prisma = new PrismaClient({ adapter })
   ```

5. 每次 schema 更改后重新运行 `prisma generate`。

### 各提供者配置示例

**PostgreSQL：**
```prisma
datasource db {
  provider = "postgresql"
}

generator client {
  provider = "prisma-client"
  output   = "../generated"
}
```

**MySQL：**
```prisma
datasource db {
  provider = "mysql"
}
```

**SQLite：**
```prisma
datasource db {
  provider = "sqlite"
}
```

**MongoDB（Prisma 6.x）：**
```prisma
datasource db {
  provider = "mongodb"
  url      = env("DATABASE_URL")
}

generator client {
  provider = "prisma-client-js"
}
```

---

## 第二部分：Prisma CLI 命令参考

### Bun 运行时

使用 Bun 时，始终添加 `--bun` 标志：

```bash
bunx --bun prisma init
bunx --bun prisma generate
```

### 项目设置

```bash
# 初始化新项目
prisma init

# 使用特定数据库
prisma init --datasource-provider postgresql
prisma init --datasource-provider mysql
prisma init --datasource-provider sqlite

# 使用 Prisma Postgres（云端）
prisma init --db

# 使用示例模型
prisma init --with-model
```

### 客户端生成

```bash
# 生成 Prisma Client
prisma generate

# 监听模式（开发）
prisma generate --watch

# 仅生成指定 generator
prisma generate --generator client
```

### 本地开发数据库

```bash
# 启动本地 Prisma Postgres
prisma dev

# 指定名称
prisma dev --name myproject

# 后台运行
prisma dev --detach

# 列出/停止/删除实例
prisma dev ls
prisma dev stop myproject
prisma dev rm myproject
```

### 数据库操作

```bash
# 从现有数据库拉取 Schema
prisma db pull

# 推送 Schema 到数据库（无迁移）
prisma db push

# 填充数据库
prisma db seed

# 执行原生 SQL
prisma db execute --file ./script.sql
```

### 迁移（开发环境）

```bash
# 创建并应用迁移
prisma migrate dev

# 创建带有名称的迁移
prisma migrate dev --name add_users_table

# 仅创建迁移但不应用
prisma migrate dev --create-only

# 重置数据库并应用所有迁移
prisma migrate reset
```

### 迁移（生产环境）

```bash
# 应用待处理的迁移（CI/CD）
prisma migrate deploy

# 检查迁移状态
prisma migrate status

# 比较 schema 并生成差异
prisma migrate diff --from-config-datasource --to-schema schema.prisma --script
```

### 工具命令

```bash
# 打开 Prisma Studio（数据库 GUI）
prisma studio

# 启动 Prisma MCP 服务器（用于 AI 工具）
prisma mcp

# 版本信息
prisma version
prisma -v

# 调试信息
prisma debug

# 验证 schema
prisma validate

# 格式化 schema
prisma format
```

### 当前命令行为说明

- 在 `migrate dev`、`db push` 或其他 schema 同步操作后，显式运行 `prisma generate` 以更新客户端
- 在 `migrate dev` 或 `migrate reset` 后，显式运行 `prisma db seed` 以填充种子数据
- 对原生 SQL 脚本使用 `prisma db execute --file ...`

---

## 第三部分：Prisma Client API

### 客户端实例化

```typescript
import { PrismaClient } from '../generated/client'
import { PrismaPg } from '@prisma/adapter-pg'

const adapter = new PrismaPg({
  connectionString: process.env.DATABASE_URL
})

const prisma = new PrismaClient({ adapter })
```

### 模型查询方法

| 方法 | 描述 |
|------|------|
| `findUnique()` | 通过唯一字段查找单条记录 |
| `findUniqueOrThrow()` | 查找单条记录，未找到则抛出错误 |
| `findFirst()` | 查找第一条匹配的记录 |
| `findFirstOrThrow()` | 查找第一条记录，未找到则抛出错误 |
| `findMany()` | 查找多条记录 |
| `create()` | 创建一条新记录 |
| `createMany()` | 创建多条记录 |
| `createManyAndReturn()` | 创建多条记录并返回它们 |
| `update()` | 更新一条记录 |
| `updateMany()` | 更新多条记录 |
| `updateManyAndReturn()` | 更新多条记录并返回它们 |
| `upsert()` | 更新或创建记录 |
| `delete()` | 删除一条记录 |
| `deleteMany()` | 删除多条记录 |
| `count()` | 统计匹配的记录数 |
| `aggregate()` | 聚合值（求和、平均值等） |
| `groupBy()` | 分组和聚合 |

### 查询选项

| 选项 | 描述 |
|------|------|
| `where` | 过滤条件 |
| `select` | 要包含的字段 |
| `include` | 要加载的关联 |
| `omit` | 要排除的字段 |
| `orderBy` | 排序方式 |
| `take` | 限制结果数量 |
| `skip` | 跳过结果数量（分页） |
| `cursor` | 基于游标的分页 |
| `distinct` | 仅返回唯一值 |

### 过滤操作符

| 操作符 | 描述 |
|--------|------|
| `equals` | 精确匹配 |
| `not` | 不等于 |
| `in` | 在数组中 |
| `notIn` | 不在数组中 |
| `lt`, `lte` | 小于 |
| `gt`, `gte` | 大于 |
| `contains` | 字符串包含 |
| `startsWith` | 字符串开头匹配 |
| `endsWith` | 字符串结尾匹配 |
| `mode` | 大小写敏感 |

### 关联过滤操作符

| 操作符 | 描述 |
|--------|------|
| `some` | 至少一条关联记录匹配 |
| `every` | 所有关联记录都匹配 |
| `none` | 没有关联记录匹配 |
| `is` | 关联记录匹配（一对一） |
| `isNot` | 关联记录不匹配 |

### 客户端方法

| 方法 | 描述 |
|------|------|
| `$connect()` | 显式连接到数据库 |
| `$disconnect()` | 断开数据库连接 |
| `$transaction()` | 执行事务 |
| `$queryRaw()` | 执行原生 SQL 查询 |
| `$executeRaw()` | 执行原生 SQL 命令 |
| `$on()` | 订阅事件 |
| `$extends()` | 添加扩展 |

### 快速示例

**查找记录：**
```typescript
// 通过唯一字段查找
const user = await prisma.user.findUnique({
  where: { email: 'alice@prisma.io' }
})

// 带过滤条件查找
const users = await prisma.user.findMany({
  where: { role: 'ADMIN' },
  orderBy: { createdAt: 'desc' },
  take: 10
})
```

**创建记录：**
```typescript
const user = await prisma.user.create({
  data: {
    email: 'alice@prisma.io',
    name: 'Alice',
    posts: {
      create: { title: 'Hello World' }
    }
  },
  include: { posts: true }
})
```

**更新记录：**
```typescript
const user = await prisma.user.update({
  where: { id: 1 },
  data: { name: 'Alice Smith' }
})
```

**删除记录：**
```typescript
await prisma.user.delete({
  where: { id: 1 }
})
```

**事务：**
```typescript
// 数组事务
const [user, post] = await prisma.$transaction([
  prisma.user.create({ data: { email: 'alice@prisma.io' } }),
  prisma.post.create({ data: { title: 'Hello', authorId: 1 } })
])

// 交互式事务
await prisma.$transaction(async (tx) => {
  const from = await tx.account.update({
    where: { id: fromId },
    data: { balance: { decrement: amount } },
  })

  const to = await tx.account.update({
    where: { id: toId },
    data: { balance: { increment: amount } },
  })

  if (from.balance < 0) throw new Error('Insufficient funds')
})
```

**原生 SQL：**
```typescript
// 查询
const users = await prisma.$queryRaw`SELECT * FROM "User" WHERE email = ${email}`

// 执行
await prisma.$executeRaw`UPDATE "User" SET name = ${name} WHERE id = ${id}`
```

---

## 第四部分：NestJS + Prisma 最佳实践

### PrismaService 模式

推荐将 PrismaClient 封装为 NestJS 服务，管理连接生命周期：

```typescript
import { Injectable, OnModuleInit, OnModuleDestroy } from '@nestjs/common';
import { PrismaClient } from '@prisma/client';

@Injectable()
export class PrismaService extends PrismaClient implements OnModuleInit, OnModuleDestroy {
  async onModuleInit() {
    await this.$connect();
  }

  async onModuleDestroy() {
    await this.$disconnect();
  }
}
```

### PrismaModule

使用 `@Global()` 确保全局单例：

```typescript
import { Global, Module } from '@nestjs/common';
import { PrismaService } from './prisma.service';

@Global()
@Module({
  providers: [PrismaService],
  exports: [PrismaService],
})
export class PrismaModule {}
```

如需可配置化方式（参考 A5 框架的 ConfigurableModuleBuilder 模式）：

```typescript
import { ConfigurableModuleBuilder } from '@nestjs/common';

export interface PrismaModuleOptions {
  datasourceUrl?: string;
}

export const { ConfigurableModuleClass, MODULE_OPTIONS_TOKEN } =
  new ConfigurableModuleBuilder<PrismaModuleOptions>()
    .setClassMethodName('forRoot')
    .build();
```

### Repository 模式

```typescript
@Injectable()
export class UserRepository {
  constructor(private prisma: PrismaService) {}

  async findAll() {
    return this.prisma.user.findMany({
      include: { posts: true },
    });
  }

  async findById(id: string) {
    return this.prisma.user.findUnique({
      where: { id },
      include: { posts: true },
    });
  }

  async create(data: Prisma.UserCreateInput) {
    return this.prisma.user.create({ data });
  }
}
```

### N+1 查询预防

```typescript
// ❌ 错误：N+1 查询
const users = await prisma.user.findMany(); // 1 query
for (const user of users) {
  const posts = await prisma.post.findMany({ where: { authorId: user.id } }); // N queries
}

// ✅ 正确：使用 include
const users = await prisma.user.findMany({
  include: { posts: true }, // 1 query with JOIN
});

// ✅ 正确：使用 select 只获取需要的字段
const users = await prisma.user.findMany({
  select: {
    id: true,
    name: true,
    posts: { select: { title: true } },
  },
});
```

### Schema 设计原则

- **索引**：在频繁查询的字段和关联外键上添加索引 `@@index([field])`
- **级联删除**：使用 `onDelete: Cascade` 维护引用完整性
- **关系模式**：明确指定 `fields` 和 `references`
- **枚举**：使用 `enum` 定义固定选项而非字符串

### 迁移策略

```bash
# 开发环境：创建并应用迁移
npx prisma migrate dev --name add_users_table

# CI/CD：自动应用待处理迁移
npx prisma migrate deploy

# 生产问题：检查迁移状态
npx prisma migrate status

# 回滚：使用迁移名称回退
npx prisma migrate resolve --rolled-back "20240320000000_add_users_table"
```

### 资源

- [Prisma 文档](https://www.prisma.io/docs)
- [Prisma Client API 参考](https://www.prisma.io/docs/orm/reference/prisma-client-reference)
- [Prisma CLI 参考](https://www.prisma.io/docs/orm/reference/prisma-cli-reference)
- [NestJS + Prisma 集成](https://docs.nestjs.com/recipes/prisma)
