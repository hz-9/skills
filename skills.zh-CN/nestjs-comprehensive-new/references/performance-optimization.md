# 性能优化指南

优化 NestJS 应用程序性能的完整指南，包括缓存、数据库优化和请求处理。

## 缓存策略

### 内置缓存管理器

#### 安装

```bash
npm i cache-manager
npm i -D @types/cache-manager
```

#### 配置

```typescript
import { CacheModule } from '@nestjs/cache-manager';
import * as redisStore from 'cache-manager-redis-store';

@Module({
  imports: [
    CacheModule.register({
      store: redisStore,
      host: 'localhost',
      port: 6379,
      ttl: 60, // 默认 TTL：60 秒
    }),
  ],
})
export class AppModule {}
```

### 缓存拦截器（Cache Interceptor）

```typescript
import { Controller, Get, Param, UseInterceptors, CacheInterceptor } from '@nestjs/common';

@Controller('users')
@UseInterceptors(CacheInterceptor)
export class UsersController {
  @Get(':id')
  @CacheTTL(300) // 覆盖 TTL 为 5 分钟
  async getUser(@Param('id') id: string) {
    return this.usersService.findById(id);
  }
}
```

### 手动缓存

```typescript
import { Injectable, Inject, CACHE_MANAGER } from '@nestjs/common';
import { Cache } from 'cache-manager';

@Injectable()
export class UsersService {
  constructor(
    @Inject(CACHE_MANAGER) private cacheManager: Cache,
    private usersRepository: UsersRepository,
  ) {}

  async findById(id: string) {
    const cacheKey = `user:${id}`;
    const cached = await this.cacheManager.get(cacheKey);

    if (cached) {
      return cached;
    }

    const user = await this.usersRepository.findById(id);
    await this.cacheManager.set(cacheKey, user, 300); // 缓存 5 分钟

    return user;
  }

  async clearCache(id: string) {
    await this.cacheManager.del(`user:${id}`);
  }
}
```

### Redis 分布式缓存

```typescript
import { createClient } from 'redis';

const redisClient = createClient({
  url: process.env.REDIS_URL,
});

await redisClient.connect();

CacheModule.registerAsync({
  useFactory: async () => ({
    store: redisStore,
    host: process.env.REDIS_HOST,
    port: parseInt(process.env.REDIS_PORT),
    ttl: 60,
  }),
});
```

---

## 数据库优化

### 避免 N+1 查询问题

#### 问题：N+1 查询

```typescript
// 错误：N+1 查询
const users = await this.usersRepository.findAll();
for (const user of users) {
  user.orders = await this.ordersRepository.findByUserId(user.id);
}
```

#### 解决方案：Eager Loading（Prisma include）

```typescript
const users = await prisma.user.findMany({
  include: { orders: true },
});

// 或使用 select 只选择所需字段
const usersWithOrders = await prisma.user.findMany({
  select: {
    id: true,
    name: true,
    orders: { select: { id: true, amount: true } },
  },
});
```

#### 解决方案：DataLoader 模式

```typescript
import DataLoader from 'dataloader';

@Injectable()
export class OrdersLoader {
  private loader: DataLoader<string, Order[]>;

  constructor(private ordersRepository: OrdersRepository) {
    this.loader = new DataLoader(async (userIds: string[]) => {
      const orders = await this.ordersRepository.findByUserIds(userIds);
      return userIds.map((id) => orders.filter((o) => o.userId === id));
    });
  }

  async getOrdersForUser(userId: string): Promise<Order[]> {
    return this.loader.load(userId);
  }
}
```

### 数据库索引（Prisma Schema）

```prisma
model User {
  id        String   @id @default(cuid())
  email     String   @unique // 自动创建唯一索引
  status    String
  createdAt DateTime @default(now())

  @@index([status, createdAt]) // 复合索引
}
```

### 查询优化

```typescript
// 使用 Prisma 的 select 精确控制返回字段
const users = await prisma.user.findMany({
  where: { status: 'active' },
  select: {
    id: true,
    name: true,
    email: true,
    orders: {
      select: { id: true, amount: true },
      orderBy: { createdAt: 'desc' },
      take: 10,
    },
  },
  orderBy: { createdAt: 'desc' },
});

// 复杂查询使用 $queryRaw
const results = await prisma.$queryRaw`
  SELECT u.*, COUNT(o.id) as order_count
  FROM "User" u
  LEFT JOIN "Order" o ON o."authorId" = u.id
  WHERE u.status = ${status}
  GROUP BY u.id
  ORDER BY u."createdAt" DESC
  LIMIT 10
`;
```

### 连接池

通过 Prisma Client 的 `datasourceUrl` 配置连接池参数（PostgreSQL 驱动层面配置）：

```typescript
// PrismaClient 实例化
const prisma = new PrismaClient({
  datasourceUrl: process.env.DATABASE_URL,
});

// 或在数据库连接字符串中配置连接池
// postgresql://user:password@host:port/db?connection_limit=20&pool_timeout=30
```

**提示**：Prisma 7 在 `prisma.config.ts` 中通过 `datasource.url` 管理连接；生产环境建议启用连接池以减少频繁连接开销。

---

## 请求处理

### 压缩中间件（Compression Middleware）

```bash
npm i compression
npm i -D @types/compression
```

```typescript
import * as compression from 'compression';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);
  app.use(compression());
  await app.listen(3000);
}
```

### 大响应流式传输

```typescript
import { Controller, Get, Res } from '@nestjs/common';
import { Response } from 'express';
import { createReadStream } from 'fs';

@Get('export')
exportData(@Res() res: Response) {
  const stream = createReadStream('large-file.csv');
  res.setHeader('Content-Type', 'text/csv');
  stream.pipe(res);
}
```

### 限流（Rate Limiting）

```bash
npm i @nestjs/throttler
```

```typescript
import { ThrottlerModule } from '@nestjs/throttler';

@Module({
  imports: [
    ThrottlerModule.forRoot([
      {
        ttl: 60000, // 1 分钟
        limit: 100, // 每分钟 100 个请求
      },
    ]),
  ],
})
```

### 多核利用的集群模式（Clustering）

```bash
npm i cluster
```

```typescript
import * as cluster from 'cluster';
import * as os from 'os';

if (cluster.isMaster) {
  const numCPUs = os.cpus().length;
  for (let i = 0; i < numCPUs; i++) {
    cluster.fork();
  }
} else {
  // 启动 NestJS 应用程序
  bootstrap();
}
```

---

## 性能监控

### 生命周期 Async Hooks

```typescript
import { Injectable, OnModuleInit, OnModuleDestroy } from '@nestjs/common';

@Injectable()
export class DatabaseService implements OnModuleInit, OnModuleDestroy {
  async onModuleInit() {
    // 初始化连接池
    await this.initialize();
  }

  async onModuleDestroy() {
    // 清理资源
    await this.cleanup();
  }
}
```

### 延迟加载模块

```typescript
// 动态加载模块以加快启动速度
const module = await import('./heavy/heavy.module');
```

---

## 缓存策略决策树

```
数据特征：
├─ 用户特定数据 → 使用用户键前缀的 Redis
├─ 全局数据 → 带 TTL 的内存缓存
├─ 数据库结果 → 查询结果缓存
├─ 静态资源 → 带缓存 headers 的 CDN
└─ 计算值 → 备忘录 decorators
```

---

## 性能检查清单

- [ ] 为耗时操作实现缓存
- [ ] 使用 DataLoader 模式解决 N+1 查询问题
- [ ] 在频繁查询的字段上添加适当的索引
- [ ] 对复杂查询使用 query builder
- [ ] 启用压缩中间件
- [ ] 配置限流
- [ ] 启用集群模式以利用多核
- [ ] 监控响应时间并优化瓶颈
- [ ] 对大响应使用流式传输
- [ ] 配置连接池
- [ ] 在 onModuleDestroy() 中清理事件监听器
- [ ] 使用 node --inspect 和 Chrome DevTools 进行性能分析

---

## 生产默认值

- 启用结构化日志
- 实现请求关联 ID
- 对 DB/cache 客户端使用 async provider 初始化
- 添加显式健康检查
- 监控内存使用和 GC 模式
- 为外部服务配置适当的超时值
