# 缓存策略决策树

选择合适缓存方案的决策树。

```
数据特征：
│
├─ 数据是否是用户特定的？
│  └─ 是 → Redis + 用户键前缀
│     ├─ 键模式：user:{userId}:{cacheKey}
│     ├─ TTL：5-30 分钟（基于数据变化频率）
│     ├─ 失效策略：用户数据变更时
│     └─ 适用于：用户资料、偏好设置、仪表盘
│     │
│     └─ 实现方式：
│        └─ CacheModule + Redis store
│           └─ key: `user:${userId}:${resource}`
│
├─ 数据是否是全局/共享的？
│  └─ 是 → 内存缓存 + TTL
│     ├─ 使用：@nestjs/cache-manager
│     ├─ TTL：1-60 分钟（基于更新频率）
│     ├─ 失效策略：基于时间或手动
│     └─ 适用于：配置、查找表、静态数据
│     │
│     └─ 实现方式：
│        └─ CacheInterceptor + @CacheTTL()
│
├─ 是否是数据库查询结果？
│  └─ 是 → 查询结果缓存
│     ├─ 使用：Prisma 查询结果缓存或手动缓存（如 Redis）
│     ├─ TTL：1-10 分钟
│     ├─ 失效策略：表变更时
│     └─ 适用于：昂贵查询、报表、分析
│     │
│     └─ 实现方式：
│        └─ 手动缓存 + service 层
│           └─ 检查缓存 → 查询数据库 → 缓存结果
│
├─ 是否是静态资源？
│  └─ 是 → CDN + 缓存头
│     ├─ 使用：AWS CloudFront、Cloudflare
│     ├─ TTL：数小时到数天
│     ├─ 失效策略：缓存失效 API
│     └─ 适用于：图片、JS/CSS 包、视频
│     │
│     └─ 实现方式：
│        └─ 设置 Cache-Control 头
│           └─ public, max-age=31536000（1年）
│
└─ 是否是计算值？
   └─ 是 → 记忆化装饰器
      ├─ 使用：自定义装饰器或 memoizee 库
      ├─ TTL：函数调用生命周期或基于时间
      ├─ 失效策略：参数变更时
      └─ 适用于：昂贵计算、数据转换
      │
      └─ 实现方式：
         └─ 在方法上使用 @Memoize() 装饰器
```

## 快速对比

| 策略 | 速度 | 可扩展性 | 复杂度 | 适用于 |
|----------|-------|-------------|------------|----------|
| Redis | 快 | ⭐⭐⭐⭐⭐ | 中等 | 用户数据、分布式 |
| 内存缓存 | 最快 | ⭐⭐ | 低 | 全局数据、单实例 |
| 查询缓存 | 快 | ⭐⭐⭐⭐ | 低 | 数据库查询、报表 |
| CDN | 快 | ⭐⭐⭐⭐⭐ | 低 | 静态资源、媒体 |
| 记忆化 | 最快 | ⭐⭐ | 低 | 计算值、函数 |

## 缓存模式

### 模式 1：Cache-Aside（最常见）

```typescript
async getData(key: string) {
  // 1. 检查缓存
  const cached = await this.cache.get(key);
  if (cached) return cached;

  // 2. 查询数据源
  const data = await this.repository.find();

  // 3. 缓存结果
  await this.cache.set(key, data, 300); // 5 分钟

  return data;
}
```

### 模式 2：Write-Through

```typescript
async updateData(key: string, data: any) {
  // 1. 更新数据源
  await this.repository.update(key, data);

  // 2. 更新缓存
  await this.cache.set(key, data, 300);

  return data;
}
```

### 模式 3：缓存失效

```typescript
async invalidateUserCache(userId: string) {
  const keys = await this.cache.keys(`user:${userId}:*`);
  await Promise.all(keys.map(key => this.cache.del(key)));
}
```

## TTL 指南

| 数据类型 | 推荐 TTL | 失效策略 |
|-----------|-----------------|----------------------|
| 用户会话 | 30 分钟 | 登出时 |
| 用户资料 | 5 分钟 | 资料更新时 |
| 产品目录 | 1 小时 | 产品变更时 |
| 配置 | 24 小时 | 配置变更时 |
| 分析数据 | 10 分钟 | 基于时间 |
| 静态资源 | 1 年 | 基于版本 |
| 计算值 | 1 分钟 | 参数变更时 |

## 最佳实践

- **始终设置 TTL**：防止缓存雪崩
- **一致使用缓存键**：`resource:id:attribute`
- **实现缓存预热**：启动时预填充缓存
- **监控命中率**：跟踪缓存效率
- **为缓存未命中做计划**：优雅降级
- **主动失效优于过期**：尽可能手动失效
- **避免缓存敏感数据**：密码、Token
