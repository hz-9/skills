# PrismaClient 构造函数

在实例化时配置 Prisma Client。

## 基本实例化

```typescript
import { PrismaClient } from '../generated/client'
import { PrismaPg } from '@prisma/adapter-pg'

const adapter = new PrismaPg({
  connectionString: process.env.DATABASE_URL
})

const prisma = new PrismaClient({ adapter })
```

## 构造函数选项

### adapter（SQL 提供者工作流必需）

驱动适配器实例：

```typescript
import { PrismaPg } from '@prisma/adapter-pg'

const adapter = new PrismaPg({
  connectionString: process.env.DATABASE_URL
})

const prisma = new PrismaClient({ adapter })
```

### accelerateUrl（适用于 Accelerate 用户）

```typescript
import { withAccelerate } from '@prisma/extension-accelerate'

const prisma = new PrismaClient({
  accelerateUrl: process.env.DATABASE_URL,  // prisma:// URL
}).$extends(withAccelerate())
```

### log

配置日志记录：

```typescript
const prisma = new PrismaClient({
  adapter,
  log: ['query', 'info', 'warn', 'error'],
})
```

#### 日志级别

| 级别 | 描述 |
|------|------|
| `query` | 所有 SQL 查询 |
| `info` | 信息性消息 |
| `warn` | 警告 |
| `error` | 错误 |

#### 日志输出到事件

```typescript
const prisma = new PrismaClient({
  adapter,
  log: [
    { level: 'query', emit: 'event' },
    { level: 'error', emit: 'stdout' },
  ],
})

prisma.$on('query', (e) => {
  console.log('查询：', e.query)
  console.log('持续时间：', e.duration, 'ms')
})
```

### errorFormat

控制错误格式：

```typescript
const prisma = new PrismaClient({
  adapter,
  errorFormat: 'pretty',  // 'pretty' | 'colorless' | 'minimal'
})
```

### comments

附加 SQL 注释插件以实现可观测性、追踪或查询洞察：

```typescript
import { PrismaClient } from '../generated/client'
import { PrismaPg } from '@prisma/adapter-pg'
import { prismaQueryInsights } from '@prisma/sqlcommenter-query-insights'
import { queryTags, withQueryTags } from '@prisma/sqlcommenter-query-tags'
import { traceContext } from '@prisma/sqlcommenter-trace-context'

const prisma = new PrismaClient({
  adapter: new PrismaPg(process.env.DATABASE_URL!),
  comments: [prismaQueryInsights(), traceContext(), queryTags()],
})

await withQueryTags({ route: '/api/users', requestId: 'req-123' }, () =>
  prisma.user.findMany(),
)
```

仅对 SQL 提供者使用 `comments`。这是在不更改查询调用的情况下添加追踪或查询形状元数据的简洁方式。

### transactionOptions

默认事务设置：

```typescript
const prisma = new PrismaClient({
  adapter,
  transactionOptions: {
    maxWait: 5000,      // 获取事务的最大等待时间（毫秒）
    timeout: 10000,     // 事务最大持续时间（毫秒）
    isolationLevel: 'Serializable',
  },
})
```

## 单例模式

防止在开发环境中创建多个客户端实例：

```typescript
// lib/prisma.ts
import { PrismaClient } from '../generated/client'
import { PrismaPg } from '@prisma/adapter-pg'

const globalForPrisma = globalThis as unknown as {
  prisma: PrismaClient | undefined
}

function createPrismaClient() {
  const adapter = new PrismaPg({
    connectionString: process.env.DATABASE_URL!
  })
  return new PrismaClient({ adapter })
}

export const prisma = globalForPrisma.prisma ?? createPrismaClient()

if (process.env.NODE_ENV !== 'production') {
  globalForPrisma.prisma = prisma
}
```

## Next.js 模式

```typescript
// lib/prisma.ts
import { PrismaClient } from '@/generated/client'
import { PrismaPg } from '@prisma/adapter-pg'

const createAdapter = () => new PrismaPg({
  connectionString: process.env.DATABASE_URL!
})

const prismaClientSingleton = () => {
  return new PrismaClient({ adapter: createAdapter() })
}

declare const globalThis: {
  prismaGlobal: ReturnType<typeof prismaClientSingleton>
} & typeof global

const prisma = globalThis.prismaGlobal ?? prismaClientSingleton()

export default prisma

if (process.env.NODE_ENV !== 'production') {
  globalThis.prismaGlobal = prisma
}
```

## 查询事件

监听查询事件：

```typescript
const prisma = new PrismaClient({
  adapter,
  log: [{ level: 'query', emit: 'event' }],
})

prisma.$on('query', (e) => {
  console.log('查询：', e.query)
  console.log('参数：', e.params)
  console.log('持续时间：', e.duration)
})
```

## 日志事件

```typescript
prisma.$on('info', (e) => console.log(e.message))
prisma.$on('warn', (e) => console.warn(e.message))
prisma.$on('error', (e) => console.error(e.message))
```
