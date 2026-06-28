# 事务

原子性地执行多个操作。

## 顺序事务

按顺序执行的操作数组：

```typescript
const [user, post] = await prisma.$transaction([
  prisma.user.create({ data: { email: 'alice@prisma.io' } }),
  prisma.post.create({ data: { title: 'Hello', authorId: 1 } })
])
```

### 全有或全无

如果任一操作失败，所有操作都将回滚：

```typescript
try {
  await prisma.$transaction([
    prisma.user.create({ data: { email: 'alice@prisma.io' } }),
    prisma.user.create({ data: { email: 'alice@prisma.io' } }) // 重复！
  ])
} catch (e) {
  // 两个操作都已回滚
}
```

## 交互式事务

用于复杂逻辑和依赖操作：

```typescript
await prisma.$transaction(async (tx) => {
  // 减少发送者余额
  const sender = await tx.account.update({
    where: { id: senderId },
    data: { balance: { decrement: amount } }
  })
  
  // 检查余额
  if (sender.balance < 0) {
    throw new Error('余额不足')
  }
  
  // 增加接收者余额
  await tx.account.update({
    where: { id: recipientId },
    data: { balance: { increment: amount } }
  })
})
```

### 事务选项

```typescript
await prisma.$transaction(
  async (tx) => {
    // 操作
  },
  {
    maxWait: 5000,    // 获取锁的最大等待时间（毫秒）
    timeout: 10000,   // 事务最大持续时间（毫秒）
    isolationLevel: 'Serializable'  // 隔离级别
  }
)
```

### 隔离级别

| 级别 | 描述 |
|------|------|
| `ReadUncommitted` | 最低隔离级别，可读取未提交的更改 |
| `ReadCommitted` | 仅读取已提交的更改 |
| `RepeatableRead` | 事务内读取一致 |
| `Serializable` | 最高隔离级别，串行化执行 |

## 嵌套写入

嵌套操作的自动事务：

```typescript
// 这自动是一个事务
const user = await prisma.user.create({
  data: {
    email: 'alice@prisma.io',
    posts: {
      create: [
        { title: '文章 1' },
        { title: '文章 2' }
      ]
    },
    profile: {
      create: { bio: '你好！' }
    }
  }
})
```

## 事务客户端

`tx` 参数是一个作用域限定在事务内的 Prisma Client：

```typescript
await prisma.$transaction(async (tx) => {
  // 使用 tx 而不是 prisma
  await tx.user.create({ ... })
  await tx.post.create({ ... })
  
  // 可以调用方法
  const count = await tx.user.count()
})
```

## 事务中的 OrThrow

与交互式事务一起使用：

```typescript
await prisma.$transaction(async (tx) => {
  // 如果未找到，抛出异常并回滚整个事务
  const user = await tx.user.findUniqueOrThrow({
    where: { id: 1 }
  })
  
  await tx.post.create({
    data: { title: '新文章', authorId: user.id }
  })
})
```

## 最佳实践

### 保持事务简短

```typescript
// 好——仅在事务中执行数据库操作
const data = prepareData() // 在事务外部
await prisma.$transaction(async (tx) => {
  await tx.user.create({ data })
})
```

### 处理错误

```typescript
try {
  await prisma.$transaction(async (tx) => {
    // 操作
  })
} catch (e) {
  if (e.code === 'P2002') {
    // 处理唯一约束冲突
  }
  throw e
}
```

### 使用适当的隔离级别

```typescript
// 默认值适用于大多数情况
await prisma.$transaction(async (tx) => {
  // 操作
})

// 对严格一致性使用 Serializable
await prisma.$transaction(
  async (tx) => { /* 操作 */ },
  { isolationLevel: 'Serializable' }
)
```

## 顺序事务 vs 交互式事务

| 特性 | 顺序事务 | 交互式事务 |
|------|---------|------------|
| 语法 | 数组 | 异步函数 |
| 依赖操作 | 否 | 是 |
| 条件逻辑 | 否 | 是 |
| 性能 | 更好 | 更灵活 |
| 使用场景 | 简单批处理 | 复杂逻辑 |
