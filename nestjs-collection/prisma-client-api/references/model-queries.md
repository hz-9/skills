# 模型查询

Prisma 模型的 CRUD 操作。

## 读取操作

### findUnique

通过唯一字段查找单条记录：

```typescript
const user = await prisma.user.findUnique({
  where: { id: 1 }
})

const user = await prisma.user.findUnique({
  where: { email: 'alice@prisma.io' }
})
```

#### 使用复合唯一键

```typescript
// 模型包含 @@unique([firstName, lastName])
const user = await prisma.user.findUnique({
  where: {
    firstName_lastName: {
      firstName: 'Alice',
      lastName: 'Smith'
    }
  }
})
```

### findUniqueOrThrow

与 findUnique 相同，但未找到时抛出异常：

```typescript
const user = await prisma.user.findUniqueOrThrow({
  where: { id: 1 }
})
// 如果未找到则抛出 PrismaClientKnownRequestError
```

### findFirst

查找第一条匹配的记录：

```typescript
const user = await prisma.user.findFirst({
  where: { role: 'ADMIN' },
  orderBy: { createdAt: 'desc' }
})
```

### findFirstOrThrow

```typescript
const user = await prisma.user.findFirstOrThrow({
  where: { role: 'ADMIN' }
})
```

### findMany

查找多条记录：

```typescript
const users = await prisma.user.findMany({
  where: { role: 'USER' },
  orderBy: { name: 'asc' },
  take: 10,
  skip: 0
})
```

## 创建操作

### create

创建单条记录：

```typescript
const user = await prisma.user.create({
  data: {
    email: 'alice@prisma.io',
    name: 'Alice'
  }
})
```

#### 带关联关系

```typescript
const user = await prisma.user.create({
  data: {
    email: 'alice@prisma.io',
    posts: {
      create: [
        { title: '第一篇文章' },
        { title: '第二篇文章' }
      ]
    }
  },
  include: { posts: true }
})
```

### createMany

创建多条记录：

```typescript
const result = await prisma.user.createMany({
  data: [
    { email: 'alice@prisma.io', name: 'Alice' },
    { email: 'bob@prisma.io', name: 'Bob' }
  ],
  skipDuplicates: true  // 跳过具有重复唯一字段的记录
})
// 返回 { count: 2 }
```

### createManyAndReturn

创建多条记录并返回它们：

```typescript
const users = await prisma.user.createManyAndReturn({
  data: [
    { email: 'alice@prisma.io', name: 'Alice' },
    { email: 'bob@prisma.io', name: 'Bob' }
  ]
})
// 返回已创建用户的数组
```

## 更新操作

### update

更新单条记录：

```typescript
const user = await prisma.user.update({
  where: { id: 1 },
  data: { name: 'Alice Smith' }
})
```

#### 原子操作

```typescript
const post = await prisma.post.update({
  where: { id: 1 },
  data: {
    views: { increment: 1 },
    likes: { decrement: 1 },
    score: { multiply: 2 },
    rating: { divide: 2 },
    version: { set: 5 }
  }
})
```

### updateMany

更新多条记录：

```typescript
const result = await prisma.user.updateMany({
  where: { role: 'USER' },
  data: { verified: true }
})
// 返回 { count: 42 }
```

### updateManyAndReturn

```typescript
const users = await prisma.user.updateManyAndReturn({
  where: { role: 'USER' },
  data: { verified: true }
})
// 返回已更新用户的数组
```

### upsert

更新或创建：

```typescript
const user = await prisma.user.upsert({
  where: { email: 'alice@prisma.io' },
  update: { name: 'Alice Smith' },
  create: { email: 'alice@prisma.io', name: 'Alice' }
})
```

## 删除操作

### delete

删除单条记录：

```typescript
const user = await prisma.user.delete({
  where: { id: 1 }
})
// 返回已删除的记录
```

### deleteMany

删除多条记录：

```typescript
const result = await prisma.user.deleteMany({
  where: { role: 'GUEST' }
})
// 返回 { count: 5 }

// 删除全部
const result = await prisma.user.deleteMany({})
```

## 聚合操作

### count

```typescript
const count = await prisma.user.count({
  where: { role: 'ADMIN' }
})
```

### aggregate

```typescript
const result = await prisma.post.aggregate({
  _avg: { views: true },
  _sum: { views: true },
  _min: { views: true },
  _max: { views: true },
  _count: { _all: true }
})
```

### groupBy

```typescript
const groups = await prisma.user.groupBy({
  by: ['country'],
  _count: { _all: true },
  _avg: { age: true },
  having: {
    age: { _avg: { gt: 30 } }
  }
})
```

## 返回类型

| 方法 | 返回类型 |
|------|---------|
| `findUnique` | 记录 \| null |
| `findUniqueOrThrow` | 记录（未找到则抛出异常） |
| `findFirst` | 记录 \| null |
| `findFirstOrThrow` | 记录（未找到则抛出异常） |
| `findMany` | 记录数组 |
| `create` | 记录 |
| `createMany` | { count: number } |
| `createManyAndReturn` | 记录数组 |
| `update` | 记录 |
| `updateMany` | { count: number } |
| `delete` | 记录 |
| `deleteMany` | { count: number } |
| `count` | number |
| `aggregate` | 聚合结果 |
| `groupBy` | 分组结果数组 |
