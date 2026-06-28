# 查询选项

用于控制查询行为的选项。

## select

选择要返回的特定字段：

```typescript
const user = await prisma.user.findUnique({
  where: { id: 1 },
  select: {
    id: true,
    name: true,
    email: true,
    // password: false（通过不包含来排除）
  }
})
// 返回：{ id: 1, name: 'Alice', email: 'alice@prisma.io' }
```

### 选择关联字段

```typescript
const user = await prisma.user.findUnique({
  where: { id: 1 },
  select: {
    name: true,
    posts: {
      select: {
        title: true,
        published: true
      }
    }
  }
})
```

### 在 select 中使用 include

```typescript
const user = await prisma.user.findMany({
  select: {
    name: true,
    posts: {
      include: {
        comments: true
      }
    }
  }
})
```

### 选择关联数量

```typescript
const users = await prisma.user.findMany({
  select: {
    name: true,
    _count: {
      select: { posts: true }
    }
  }
})
// 返回：{ name: 'Alice', _count: { posts: 5 } }
```

## include

包含关联记录：

```typescript
const user = await prisma.user.findUnique({
  where: { id: 1 },
  include: {
    posts: true,
    profile: true
  }
})
```

### 带过滤条件的 include

```typescript
const user = await prisma.user.findUnique({
  where: { id: 1 },
  include: {
    posts: {
      where: { published: true },
      orderBy: { createdAt: 'desc' },
      take: 5
    }
  }
})
```

### 嵌套 include

```typescript
const user = await prisma.user.findUnique({
  where: { id: 1 },
  include: {
    posts: {
      include: {
        comments: {
          include: {
            author: true
          }
        }
      }
    }
  }
})
```

### 包含关联数量

```typescript
const users = await prisma.user.findMany({
  include: {
    _count: {
      select: { posts: true, followers: true }
    }
  }
})
```

## omit

排除特定字段：

```typescript
const user = await prisma.user.findUnique({
  where: { id: 1 },
  omit: {
    password: true
  }
})
// 返回除 password 之外的所有字段
```

### 在关联中使用 omit

```typescript
const users = await prisma.user.findMany({
  omit: { password: true },
  include: {
    posts: {
      omit: { content: true }
    }
  }
})
```

**注意：** 不能同时使用 `select` 和 `omit`。

## where

过滤记录：

```typescript
const users = await prisma.user.findMany({
  where: {
    email: { contains: '@prisma.io' },
    role: 'ADMIN'
  }
})
```

详细过滤操作符请参见 `filters.md`。

## orderBy

排序结果：

```typescript
// 单字段
const users = await prisma.user.findMany({
  orderBy: { name: 'asc' }
})

// 多字段
const users = await prisma.user.findMany({
  orderBy: [
    { role: 'desc' },
    { name: 'asc' }
  ]
})
```

### 按关联排序

```typescript
const users = await prisma.user.findMany({
  orderBy: {
    posts: { _count: 'desc' }
  }
})
```

### 空值处理

```typescript
const users = await prisma.user.findMany({
  orderBy: {
    name: { sort: 'asc', nulls: 'last' }
  }
})
```

## take & skip

分页：

```typescript
// 第一页
const users = await prisma.user.findMany({
  take: 10,
  skip: 0
})

// 第二页
const users = await prisma.user.findMany({
  take: 10,
  skip: 10
})
```

### 负数 take（反向）

```typescript
const lastUsers = await prisma.user.findMany({
  take: -10,
  orderBy: { id: 'asc' }
})
// 返回最后 10 个用户
```

## cursor

基于游标的分页：

```typescript
// 第一页
const firstPage = await prisma.user.findMany({
  take: 10,
  orderBy: { id: 'asc' }
})

// 使用游标获取下一页
const nextPage = await prisma.user.findMany({
  take: 10,
  skip: 1,  // 跳过游标记录
  cursor: { id: firstPage[firstPage.length - 1].id },
  orderBy: { id: 'asc' }
})
```

## distinct

返回唯一值：

```typescript
const cities = await prisma.user.findMany({
  distinct: ['city'],
  select: { city: true }
})
```

### 多个唯一字段

```typescript
const locations = await prisma.user.findMany({
  distinct: ['city', 'country']
})
```
