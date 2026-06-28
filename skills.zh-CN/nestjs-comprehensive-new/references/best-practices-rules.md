# NestJS 最佳实践 - 40 条规则

NestJS 应用程序的综合最佳实践指南。包含 10 个类别的 40 条规则，按影响程度优先级排序，以指导自动重构和代码生成。

## 按优先级排序的规则类别

| 优先级 | 类别 | 影响 | 前缀 | 数量 |
|----------|----------|--------|--------|-------|
| 1 | Architecture | CRITICAL | `arch-` | 6 |
| 2 | Dependency Injection | CRITICAL | `di-` | 6 |
| 3 | Error Handling | HIGH | `error-` | 3 |
| 4 | Security | HIGH | `security-` | 5 |
| 5 | Performance | HIGH | `perf-` | 4 |
| 6 | Testing | MEDIUM-HIGH | `test-` | 3 |
| 7 | Database & ORM | MEDIUM-HIGH | `db-` | 3 |
| 8 | API Design | MEDIUM | `api-` | 4 |
| 9 | Microservices | MEDIUM | `micro-` | 3 |
| 10 | DevOps & Deployment | LOW-MEDIUM | `devops-` | 3 |

---

## 优先级 1：架构（CRITICAL）

### arch-avoid-circular-deps

**问题**：循环模块依赖会导致运行时错误并使代码难以维护。

**解决方案**：
- 使用 `forwardRef()` 作为临时修复
- 将共享逻辑提取到第三个模块（推荐）
- 考虑循环依赖是否表明设计缺陷

```typescript
// 错误：循环依赖
@Module({ imports: [BModule] })
class AModule {}

@Module({ imports: [AModule] })
class BModule {}

// 正确：提取共享逻辑
@Module({})
class SharedModule {
  // 共享逻辑放在这里
}

@Module({ imports: [SharedModule] })
class AModule {}

@Module({ imports: [SharedModule] })
class BModule {}
```

### arch-feature-modules

按功能组织，而非按技术层组织。

```text
// 正确：基于功能
src/
├── users/
│   ├── users.controller.ts
│   ├── users.service.ts
│   └── users.module.ts
├── orders/
│   ├── orders.controller.ts
│   ├── orders.service.ts
│   └── orders.module.ts

// 错误：基于层
src/
├── controllers/
├── services/
├── modules/
```

### arch-module-sharing

正确的模块导出/导入，避免重复的 providers。

```typescript
// 正确：显式导出
@Module({
  providers: [UsersService],
  exports: [UsersService], // 仅导出需要的内容
})

// 错误：导出模块本身
@Module({
  exports: [UsersModule], // 错误！
})
```

### arch-single-responsibility

专注的 services 优于"上帝 services"。每个 service 应该只有一个单一职责。

### arch-use-repository-pattern

抽象数据库逻辑以提高可测试性。

```typescript
// 正确：Repository 模式
@Injectable()
class UsersRepository {
  async findById(id: string) { /* ... */ }
}

@Injectable()
class UsersService {
  constructor(private repo: UsersRepository) {}
}
```

### arch-use-events

使用 `@nestjs/event-emitter` 实现事件驱动架构以解耦。

---

## 优先级 2：依赖注入（CRITICAL）

### di-avoid-service-locator

避免 service locator 反模式。使用构造函数注入代替。

```typescript
// 错误：Service locator
class BadService {
  constructor(private injector: Injector) {}

  getUsers() {
    const usersService = this.injector.get(UsersService);
    return usersService.findAll();
  }
}

// 正确：构造函数注入
class GoodService {
  constructor(private usersService: UsersService) {}
}
```

### di-interface-segregation

接口隔离原则（ISP）。许多特定于客户端的接口优于一个通用接口。

### di-liskov-substitution

里氏替换原则（LSP）。子类型必须能够替换它们的基类型。

### di-prefer-constructor-injection

构造函数注入优于属性注入。

```typescript
// 正确：构造函数注入
@Injectable()
class UserService {
  constructor(private repo: UserRepository) {}
}

// 错误：属性注入
@Injectable()
class UserService {
  @Inject(UserRepository)
  repo!: UserRepository;
}
```

### di-scope-awareness

理解 singleton/request/transient 作用域。

### di-use-interfaces-tokens

为接口使用 injection tokens。

```typescript
export const UserRepository = Symbol('UserRepository');

@Module({
  providers: [
    { provide: UserRepository, useClass: UsersRepositoryImpl },
  ],
})
```

---

## 优先级 3：错误处理（HIGH）

### error-use-exception-filters

使用全局异常过滤器进行集中式异常处理。

### error-throw-http-exceptions

使用 NestJS HTTP 异常（`NotFoundException`、`BadRequestException` 等）。

### error-handle-async-errors

正确处理 async 错误。在 async 操作中始终使用 try-catch 或适当的错误处理。

---

## 优先级 4：安全（HIGH）

### security-auth-jwt

安全的 JWT 认证，包含正确的 secret 管理和 token 过期。

### security-validate-all-input

使用全局 ValidationPipe 和 class-validator 进行验证。

### security-use-guards

为受保护的路由使用认证和授权 guards。

### security-sanitize-output

通过清理输出和不返回敏感字段来防止 XSS 攻击。

### security-rate-limiting

实施 rate limiting 以防止暴力攻击。

---

## 优先级 5：性能（HIGH）

### perf-async-hooks

正确的 async 生命周期钩子（`onModuleInit`、`onModuleDestroy`）。

### perf-use-caching

使用 `@nestjs/cache-manager` 实现缓存策略。

### perf-optimize-database

优化数据库查询，使用索引，避免 N+1 问题。

### perf-lazy-loading

使用动态导入延迟加载模块以加快启动速度。

---

## 优先级 6：测试（MEDIUM-HIGH）

### test-use-testing-module

使用 NestJS 测试工具（`@nestjs/testing`）。

### test-e2e-supertest

使用 Supertest 进行 E2E 测试。

### test-mock-external-services

模拟外部依赖（数据库、APIs、services）。

---

## 优先级 7：数据库与 ORM（MEDIUM-HIGH）

### db-use-transactions

使用 Prisma 的 `$transaction` 进行多步操作的事务管理。

```typescript
await prisma.$transaction(async (tx) => {
  await tx.account.update({
    where: { id: fromId },
    data: { balance: { decrement: amount } },
  });

  await tx.account.update({
    where: { id: toId },
    data: { balance: { increment: amount } },
  });
});
```

### db-avoid-n-plus-one

使用 Prisma 的 `include` 或 `select` 进行 eager loading，避免 N+1 查询问题。

```typescript
// ❌ 错误：N+1
const users = await prisma.user.findMany();
for (const user of users) {
  const posts = await prisma.post.findMany({ where: { authorId: user.id } });
}

// ✅ 正确：使用 include
const users = await prisma.user.findMany({
  include: { posts: true },
});
```

### db-use-migrations

使用 Prisma Migrate 进行模式更改，绝不在生产环境中自动同步。

```bash
# 开发：创建并应用迁移
npx prisma migrate dev --name description

# 生产：部署待处理迁移
npx prisma migrate deploy

# 检查状态
npx prisma migrate status
```

---

## 优先级 8：API 设计（MEDIUM）

### api-use-dto-serialization

DTO 和响应序列化以实现一致的 API 响应。

### api-use-interceptors

使用 interceptors 处理跨切面关注点（日志、缓存、转换）。

### api-versioning

API 版本控制策略（URL 版本控制、header 版本控制）。

### api-use-pipes

使用 pipes 进行输入转换（验证、转换）。

---

## 优先级 9：微服务（MEDIUM）

### micro-use-patterns

微服务通信的消息和事件模式。

### micro-use-health-checks

用于编排和监控的健康检查。

### micro-use-queues

使用 Bull/BullMQ 进行后台任务处理。

---

## 优先级 10：DevOps 与部署（LOW-MEDIUM）

### devops-use-config-module

使用 `@nestjs/config` 进行环境配置。

### devops-use-logging

带有请求关联 ID 的结构化日志。

### devops-graceful-shutdown

使用优雅关闭实现零停机部署。

```typescript
async function bootstrap() {
  const app = await NestFactory.create(AppModule);
  app.enableShutdownHooks(); // 启用优雅关闭
  await app.listen(3000);
}
```

---

## 如何使用

在以下场景应用这些规则：
- 编写新的 NestJS 模块、controllers 或 services
- 实现认证和授权
- 审查代码中的架构和安全问题
- 重构现有的 NestJS 代码库
- 优化性能或数据库查询
