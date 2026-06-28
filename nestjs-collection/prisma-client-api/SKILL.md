---
name: prisma-client-api
description: 涵盖模型查询、过滤器、操作符和客户端方法的 Prisma Client API 参考。在编写数据库查询、使用 CRUD 操作、过滤数据或配置 Prisma Client 时使用。触发词为 "prisma query"、"findMany"、"create"、"update"、"delete"、"$transaction"。
license: MIT
metadata:
  author: prisma
  version: "7.6.0"
---

# Prisma Client API 参考

Prisma Client 的完整 API 参考。本技能为当前 Prisma 项目提供模型查询、过滤、关系和客户端方法方面的指导。

## 何时使用

在以下情况参考本技能：
- 使用 Prisma Client 编写数据库查询
- 执行 CRUD 操作（创建、读取、更新、删除）
- 过滤和排序数据
- 处理关联关系
- 使用事务
- 配置客户端选项

## 按优先级分类的规则类别

| 优先级 | 类别 | 影响 | 前缀 |
|--------|------|------|------|
| 1 | 客户端构造 | 高 | `constructor` |
| 2 | 模型查询 | 关键 | `model-queries` |
| 3 | 查询形状 | 高 | `query-options` |
| 4 | 过滤 | 高 | `filters` |
| 5 | 关联关系 | 高 | `relations` |
| 6 | 事务 | 关键 | `transactions` |
| 7 | 原生 SQL | 关键 | `raw-queries` |
| 8 | 客户端方法 | 中 | `client-methods` |

## 快速参考

- `constructor` - `PrismaClient` 设置、适配器配置、日志记录和 SQL 注释插件
- `model-queries` - CRUD 操作和批量操作
- `query-options` - `select`、`include`、`omit`、排序、分页
- `filters` - 标量和逻辑过滤操作符
- `relations` - 关联读取和嵌套写入
- `transactions` - 数组和交互式事务模式
- `raw-queries` - `$queryRaw` 和 `$executeRaw` 安全使用
- `client-methods` - 生命周期方法、扩展和 `prisma-client` 的 `satisfies` 模式

## 客户端实例化

```typescript
import { PrismaClient } from '../generated/client'
import { PrismaPg } from '@prisma/adapter-pg'

const adapter = new PrismaPg({
  connectionString: process.env.DATABASE_URL
})

const prisma = new PrismaClient({ adapter })
```

## 模型查询方法

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

## 查询选项

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

## 客户端方法

| 方法 | 描述 |
|------|------|
| `$connect()` | 显式连接到数据库 |
| `$disconnect()` | 断开数据库连接 |
| `$transaction()` | 执行事务 |
| `$queryRaw()` | 执行原生 SQL 查询 |
| `$executeRaw()` | 执行原生 SQL 命令 |
| `$on()` | 订阅事件 |
| `$extends()` | 添加扩展 |

## 快速示例

### 查找记录

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

### 创建记录

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

### 更新记录

```typescript
const user = await prisma.user.update({
  where: { id: 1 },
  data: { name: 'Alice Smith' }
})
```

### 删除记录

```typescript
await prisma.user.delete({
  where: { id: 1 }
})
```

### 事务

```typescript
const [user, post] = await prisma.$transaction([
  prisma.user.create({ data: { email: 'alice@prisma.io' } }),
  prisma.post.create({ data: { title: 'Hello', authorId: 1 } })
])
```

## 规则文件

详细的 API 文档：

```
references/constructor.md        - PrismaClient 构造函数选项
references/model-queries.md      - CRUD 操作
references/query-options.md      - select、include、omit、where、orderBy
references/filters.md            - 过滤条件和操作符
references/relations.md          - 关联查询和嵌套操作
references/transactions.md       - 事务 API
references/raw-queries.md        - $queryRaw、$executeRaw
references/client-methods.md     - $connect、$disconnect、$on、$extends
```

## 过滤操作符

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

## 关联过滤操作符

| 操作符 | 描述 |
|--------|------|
| `some` | 至少一条关联记录匹配 |
| `every` | 所有关联记录都匹配 |
| `none` | 没有关联记录匹配 |
| `is` | 关联记录匹配（一对一） |
| `isNot` | 关联记录不匹配 |

## 资源

- [Prisma Client API 参考](https://www.prisma.io/docs/orm/reference/prisma-client-reference)
- [CRUD 操作](https://www.prisma.io/docs/orm/prisma-client/queries/crud)
- [过滤和排序](https://www.prisma.io/docs/orm/prisma-client/queries/filtering-and-sorting)

## 使用方法

从上方的类别表中选择类别，然后打开对应的参考文件查看实现细节和示例。
