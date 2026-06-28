# 客户端方法

Prisma Client 实例方法。

## $connect()

显式连接到数据库：

```typescript
const prisma = new PrismaClient({ adapter })

// 显式连接
await prisma.$connect()
```

### 何时使用

通常不需要——Prisma 会在首次查询时自动连接。用于以下情况：
- 启动时快速失败
- 健康检查
- 预建立连接

```typescript
async function main() {
  try {
    await prisma.$connect()
    console.log('数据库已连接')
  } catch (e) {
    console.error('连接失败：', e)
    process.exit(1)
  }
}
```

## $disconnect()

关闭数据库连接：

```typescript
await prisma.$disconnect()
```

### 优雅关闭

```typescript
process.on('beforeExit', async () => {
  await prisma.$disconnect()
})

// 或使用 SIGTERM
process.on('SIGTERM', async () => {
  await prisma.$disconnect()
  process.exit(0)
})
```

### 在测试中使用

```typescript
afterAll(async () => {
  await prisma.$disconnect()
})
```

## $on()

订阅事件：

### 查询事件

```typescript
const prisma = new PrismaClient({
  adapter,
  log: [{ level: 'query', emit: 'event' }]
})

prisma.$on('query', (e) => {
  console.log('查询：', e.query)
  console.log('参数：', e.params)
  console.log('持续时间：', e.duration, 'ms')
})
```

### 日志事件

```typescript
const prisma = new PrismaClient({
  adapter,
  log: [
    { level: 'info', emit: 'event' },
    { level: 'warn', emit: 'event' },
    { level: 'error', emit: 'event' }
  ]
})

prisma.$on('info', (e) => console.log(e.message))
prisma.$on('warn', (e) => console.warn(e.message))
prisma.$on('error', (e) => console.error(e.message))
```

## $extends()

添加扩展以实现自定义行为：

### 添加自定义方法

```typescript
const prisma = new PrismaClient({ adapter }).$extends({
  client: {
    $log: (message: string) => console.log(message)
  }
})

prisma.$log('Hello!')
```

### 添加模型方法

```typescript
const prisma = new PrismaClient({ adapter }).$extends({
  model: {
    user: {
      async findByEmail(email: string) {
        return prisma.user.findUnique({ where: { email } })
      }
    }
  }
})

const user = await prisma.user.findByEmail('alice@prisma.io')
```

### 查询扩展

```typescript
const prisma = new PrismaClient({ adapter }).$extends({
  query: {
    user: {
      async findMany({ args, query }) {
        // 添加默认过滤条件
        args.where = { ...args.where, deletedAt: null }
        return query(args)
      }
    }
  }
})
```

### 结果扩展

```typescript
const prisma = new PrismaClient({ adapter }).$extends({
  result: {
    user: {
      fullName: {
        needs: { firstName: true, lastName: true },
        compute(user) {
          return `${user.firstName} ${user.lastName}`
        }
      }
    }
  }
})

const user = await prisma.user.findFirst()
console.log(user.fullName) // 计算字段
```

### 链式扩展

```typescript
const prisma = new PrismaClient({ adapter })
  .$extends(loggingExtension)
  .$extends(softDeleteExtension)
  .$extends(computedFieldsExtension)
```

## $transaction()

详见 `transactions.md`。

## $queryRaw() / $executeRaw()

详见 `raw-queries.md`。

## 类型工具

### Prisma 命名空间

```typescript
import { Prisma } from '../generated/client'

// 输入类型
type UserCreateInput = Prisma.UserCreateInput
type UserWhereInput = Prisma.UserWhereInput

// 输出类型
type User = Prisma.UserGetPayload<{}>
type UserWithPosts = Prisma.UserGetPayload<{
  include: { posts: true }
}>
```

### 使用 satisfies 的类型安全查询片段

类型安全的查询片段：

```typescript
import { Prisma } from '../generated/client'

const userSelect = {
  id: true,
  email: true,
  name: true
} satisfies Prisma.UserSelect

const user = await prisma.user.findUnique({
  where: { id: 1 },
  select: userSelect
})
```

使用 `prisma-client` 生成器时，使用 TypeScript 的 `satisfies` 实现类型化查询片段。在 `prisma-client-js` 的旧示例中，你可能仍然会看到使用 `Prisma.validator()` 的写法。
