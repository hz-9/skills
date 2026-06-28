# ORM 选择决策树

为你的 NestJS 项目选择合适的 ORM 的决策树。

```
项目需求：
│
├─ 是否需要类型安全？
│  ├─ 是 → Prisma 或 Drizzle ORM
│  │  │
│  │  ├─ 是否偏好 schema-first 方式？
│  │  │  ├─ 是 → Prisma
│  │  │  │   └─ 优点：自动生成类型、出色的开发体验、迁移支持
│  │  │  │   └─ 缺点：对 SQL 控制较少、供应商锁定
│  │  │  │
│  │  │  └─ 否 → Drizzle ORM
│  │  │      └─ 优点：类 SQL API、完全控制、轻量级
│  │  │      └─ 缺点：手动定义 schema、生态系统较新
│  │  │
│  │  └─ 是否需要复杂关联？
│  │     ├─ 是 → Prisma（更好的关联处理）
│  │     └─ 否 → Drizzle ORM（更简单的查询）
│  │
│  └─ 否 → TypeORM 或 Mongoose
│     │
│     ├─ 使用 SQL 数据库？
│     │  ├─ 是 → TypeORM
│     │  │   └─ 优点：成熟、基于装饰器、支持多种数据库
│     │  │   └─ 缺点：运行时类型检查、包体积较大
│     │  │
│     │  └─ 否（MongoDB）→ Mongoose
│     │      └─ 优点：原生 MongoDB 支持、schema 验证
│     │      └─ 缺点：仅限 MongoDB、回调风格 API
│     │
│     └─ 使用 NoSQL 数据库？
│        └─ Mongoose
```

## 快速对比

| 特性 | Prisma | Drizzle ORM | TypeORM | Mongoose |
|---------|--------|-------------|---------|----------|
| 类型安全 | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐ |
| 学习曲线 | 简单 | 中等 | 中等 | 简单 |
| SQL 控制 | 低 | 高 | 高 | 不适用 |
| 迁移 | 优秀 | 良好 | 良好 | 不适用 |
| 性能 | 良好 | 优秀 | 良好 | 良好 |
| 数据库支持 | 5+ | PostgreSQL、MySQL、SQLite | 10+ | 仅 MongoDB |
| 社区 | 大型 | 增长中 | 大型 | 大型 |
| NestJS 集成 | 良好 | 良好 | 优秀 | 优秀 |

## 建议

### 选择 Prisma 的情况：
- 你想要出色的 TypeScript 集成
- 你需要自动生成的类型
- 你偏好 schema-first 开发
- 你的团队对 ORM 较新
- 你需要可靠的迁移

### 选择 Drizzle ORM 的情况：
- 你想要类 SQL 的查询 API
- 你需要细粒度控制
- 你偏好轻量级依赖
- 你在构建 PostgreSQL/MySQL 应用
- 你想要更好的性能

### 选择 TypeORM 的情况：
- 你需要多数据库支持
- 你偏好基于装饰器的实体
- 你有现有的 TypeORM 项目
- 你需要 active record 模式
- 你在使用遗留数据库

### 选择 Mongoose 的情况：
- 你在使用 MongoDB
- 你需要文档验证
- 你想要 schema 定义
- 你需要 MongoDB 特有功能
- 你的团队熟悉 MongoDB
