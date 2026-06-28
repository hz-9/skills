# 原生查询

当 Prisma 的查询 API 不足以满足需求时，执行原生 SQL。

## $queryRaw

执行 SELECT 查询并获取类型化结果：

```typescript
const users = await prisma.$queryRaw`
  SELECT * FROM "User" WHERE email LIKE ${'%@prisma.io'}
`
```

### 带类型

```typescript
type User = { id: number; email: string; name: string | null }

const users = await prisma.$queryRaw<User[]>`
  SELECT id, email, name FROM "User" WHERE role = ${'ADMIN'}
`
```

### 动态表名/列名

使用 `Prisma.raw()` 处理标识符（对用户输入不安全）：

```typescript
import { Prisma } from '../generated/client'

const column = 'email'
const users = await prisma.$queryRaw`
  SELECT ${Prisma.raw(column)} FROM "User"
`
```

### 使用 Prisma.sql

动态构建查询：

```typescript
import { Prisma } from '../generated/client'

const email = 'alice@prisma.io'
const query = Prisma.sql`SELECT * FROM "User" WHERE email = ${email}`
const users = await prisma.$queryRaw(query)
```

### 拼接多个 SQL 片段

```typescript
import { Prisma } from '../generated/client'

const conditions = [
  Prisma.sql`role = ${'ADMIN'}`,
  Prisma.sql`verified = ${true}`
]

const users = await prisma.$queryRaw`
  SELECT * FROM "User" 
  WHERE ${Prisma.join(conditions, ' AND ')}
`
```

## $executeRaw

执行 INSERT、UPDATE、DELETE（返回受影响的行数）：

```typescript
const count = await prisma.$executeRaw`
  UPDATE "User" SET verified = true WHERE email LIKE ${'%@prisma.io'}
`
console.log(`已更新 ${count} 个用户`)
```

### 删除示例

```typescript
const deleted = await prisma.$executeRaw`
  DELETE FROM "User" WHERE "deletedAt" < ${thirtyDaysAgo}
`
```

### 插入示例

```typescript
const inserted = await prisma.$executeRaw`
  INSERT INTO "Log" (message, level, timestamp)
  VALUES (${message}, ${level}, ${new Date()})
`
```

## $queryRawUnsafe / $executeRawUnsafe

用于完全动态的查询（请谨慎使用！）：

```typescript
// ⚠️ SQL 注入风险——仅用于可信输入
const table = 'User'
const users = await prisma.$queryRawUnsafe(
  `SELECT * FROM "${table}" WHERE id = $1`,
  userId
)
```

### 参数化不安全查询

```typescript
const result = await prisma.$executeRawUnsafe(
  'UPDATE "User" SET name = $1 WHERE id = $2',
  'Alice',
  1
)
```

## SQL 注入防护

### 安全（参数化）

```typescript
// ✅ 用户输入已参数化
const email = userInput
const users = await prisma.$queryRaw`
  SELECT * FROM "User" WHERE email = ${email}
`
```

### 不安全（字符串拼接）

```typescript
// ❌ SQL 注入漏洞！
const email = userInput
const users = await prisma.$queryRawUnsafe(
  `SELECT * FROM "User" WHERE email = '${email}'`
)
```

## 数据库特定功能

### PostgreSQL

```typescript
// 数组操作
const users = await prisma.$queryRaw`
  SELECT * FROM "User" WHERE 'admin' = ANY(roles)
`

// JSON 操作
const users = await prisma.$queryRaw`
  SELECT * FROM "User" WHERE metadata->>'theme' = 'dark'
`
```

### MySQL

```typescript
// 全文搜索
const posts = await prisma.$queryRaw`
  SELECT * FROM Post WHERE MATCH(title, content) AGAINST(${searchTerm})
`
```

## 事务中的原生查询

```typescript
await prisma.$transaction(async (tx) => {
  await tx.$executeRaw`UPDATE "Account" SET balance = balance - ${amount} WHERE id = ${senderId}`
  await tx.$executeRaw`UPDATE "Account" SET balance = balance + ${amount} WHERE id = ${recipientId}`
})
```

## 结果处理

### BigInt 处理

PostgreSQL 对 COUNT 返回 BigInt：

```typescript
const result = await prisma.$queryRaw<[{ count: bigint }]>`
  SELECT COUNT(*) as count FROM "User"
`
const count = Number(result[0].count)
```

### 日期处理

```typescript
type Result = { createdAt: Date }
const users = await prisma.$queryRaw<Result[]>`
  SELECT "createdAt" FROM "User"
`
// createdAt 已经是 Date 对象
```
