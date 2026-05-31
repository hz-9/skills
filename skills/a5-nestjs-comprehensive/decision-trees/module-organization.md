# 模块组织决策树

有效组织 NestJS 模块的决策树。

```
功能复杂度：
│
├─ 是否是简单的 CRUD 操作？
│  ├─ 是 → 单模块模式
│  │   └─ 结构：
│  │      ├── feature.controller.ts
│  │      ├── feature.service.ts
│  │      ├── feature.module.ts
│  │      └── dto/
│  │          ├── create-feature.dto.ts
│  │          └── update-feature.dto.ts
│  │
│  └─ 否 → 是否是领域特定逻辑？
│     ├─ 是 → 领域模块 + 基础设施
│     │   └─ 结构：
│     │      ├── domain/
│     │      │   ├── entities/
│     │      │   ├── value-objects/
│     │      │   └── services/
│     │      ├── infrastructure/
│     │      │   ├── repositories/
│     │      │   └── external-services/
│     │      └── feature.module.ts
│     │
│     └─ 否 → 是否在功能间共享？
│        ├─ 是 → 共享/公共模块
│        │   └─ 结构：
│        │      ├── common/
│        │      │   ├── guards/
│        │      │   ├── interceptors/
│        │      │   ├── filters/
│        │      │   └── pipes/
│        │      └── shared.module.ts
│        │       （如果全局使用则标记为 @Global()）
│        │
│        └─ 否 → 是否是外部 API 集成？
│           ├─ 是 → 客户端模块
│           │   └─ 结构：
│           │      ├── client/
│           │      │   ├── api-client.service.ts
│           │      │   ├── dto/
│           │      │   └── interfaces/
│           │      └── external-api.module.ts
│           │
│           └─ 否 → 是否是微服务？
│              ├─ 是 → 独立的 NestJS 应用
│              │   └─ 结构：
│              │      ├── src/
│              │      │   ├── main.ts（微服务）
│              │      │   ├── app.module.ts
│              │      │   └── features/
│              │      └── Dockerfile
│              │
│              └─ 否 → 是否是后台任务/队列？
│                 └─ 带处理器的独立模块
│                    └─ 结构：
│                       ├── jobs/
│                       │   ├── email.processor.ts
│                       │   └── report.processor.ts
│                       └── jobs.module.ts
```

## 模块组织模式

### 模式 1：功能模块（最常见）

```typescript
@Module({
  controllers: [UsersController],
  providers: [UsersService, UsersRepository],
  exports: [UsersService],
})
export class UsersModule {}
```

### 模式 2：共享模块

```typescript
@Global() // 无需导入即可全局使用
@Module({
  providers: [LoggerService, ConfigService],
  exports: [LoggerService, ConfigService],
})
export class SharedModule {}
```

### 模式 3：动态模块

```typescript
@Module({})
export class DatabaseModule {
  static forRoot(config: DatabaseConfig): DynamicModule {
    return {
      module: DatabaseModule,
      providers: [
        {
          provide: 'DATABASE_CONFIG',
          useValue: config,
        },
        DatabaseService,
      ],
      exports: [DatabaseService],
    };
  }
}
```

## 最佳实践

- **按功能组织**，而非按技术层
- **保持模块聚焦** - 单一职责
- **仅导出所需内容** - 最小化公共 API
- **使用共享模块**处理公共功能
- **避免循环依赖** - 提取到第三个模块
- **谨慎使用桶导出（barrel exports）** - 注意循环依赖
