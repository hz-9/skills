---
name: nestjs-comprehensive
description: 全面的 NestJS 框架指南，包含 Drizzle ORM、TypeORM、Prisma 集成、40 条最佳实践规则、Sentry 监控、微服务、认证、测试和生产环境模式。适用于构建 NestJS 应用、实现 API、认证、数据库操作、错误监控或部署生产级服务器端应用。
allowed-tools: Read, Write, Edit, Glob, Grep, Bash
category: framework
version: "1.0.0"
---

# NestJS 综合指南

完整的 NestJS 框架资源，涵盖架构模式、40 条最佳实践规则、数据库集成（Drizzle ORM/TypeORM/Prisma/Mongoose）、Sentry 监控、微服务、认证、测试策略和生产部署。

## 何时使用

- 使用 NestJS 构建 REST API 或 GraphQL 服务器
- 使用 JWT/Passport 设置认证和授权
- 使用 Drizzle ORM、TypeORM、Prisma 或 Mongoose 实现数据库操作
- 使用 TCP/Redis 传输、Bull/BullMQ 队列创建微服务
- 编写单元测试、集成测试和 E2E 测试
- 使用 Sentry 设置错误监控和追踪
- 运行数据库迁移
- 优化性能和缓存
- 部署生产就绪的 NestJS 应用

## 目录

1. [快速开始](#3-快速开始)
2. [核心架构](#4-核心架构)
3. [最佳实践（40 条规则）](#5-最佳实践40-条规则)
4. [认证与安全](#6-认证与安全)
5. [数据库集成](#7-数据库集成)
6. [测试](#8-测试)
7. [微服务与队列](#9-微服务与队列)
8. [性能优化](#10-性能优化)
9. [Sentry 集成](#11-sentry-集成)
10. [故障排除](#12-故障排除)
11. [决策树](#13-决策树)
12. [代码审查清单](#14-代码审查清单)
13. [成功指标](#15-成功指标)
14. [参考资料](#16-参考资料)
15. [示例](#17-示例)
16. [工作流](#18-工作流)
17. [检查清单](#19-检查清单)

---

## 1. 概述

本综合指南将 NestJS 框架模式、最佳实践和生产就绪解决方案整合为单一资源。涵盖：

- **核心架构**：模块组织、控制器、提供者、DTO、守卫、拦截器、管道
- **40 条最佳实践规则**：按 10 个类别优先排序（架构、依赖注入、错误处理、安全、性能、测试、数据库、API 设计、微服务、DevOps）
- **数据库集成**：Drizzle ORM、TypeORM、Prisma、Mongoose，包含事务和迁移
- **认证与安全**：JWT、Passport、守卫、输入验证、速率限制
- **测试**：使用 Jest 和 Supertest 进行单元、集成、E2E 测试
- **微服务**：TCP/Redis 传输、消息模式、健康检查、Bull/BullMQ
- **Sentry 集成**：错误监控、追踪、性能分析、日志、指标、定时任务
- **性能**：缓存、数据库优化、请求处理、N+1 解决方案
- **故障排除**：来自 GitHub 和 Stack Overflow 的 39 个真实问题

---

## 2. 何时使用

### 激活此技能的条件：

- 编写新的 NestJS 模块、控制器或服务
- 实现认证和授权
- 审查代码中的架构和安全问题
- 重构现有的 NestJS 代码库
- 优化性能或数据库查询
- 构建微服务架构
- 使用 Sentry 设置错误监控
- 运行数据库迁移
- 添加 DTO 验证、守卫、拦截器或异常过滤器
- 配置环境感知设置
- 测试 NestJS 单元或 HTTP 端点
- 部署到生产环境

### 触发场景：

- "构建一个 NestJS API"
- "为 NestJS 添加 JWT 认证"
- "将 Drizzle ORM/TypeORM/Prisma 与 NestJS 集成"
- "为 NestJS 设置 Sentry 监控"
- "使用 NestJS 创建微服务"
- "为 NestJS 模块编写测试"
- "修复 NestJS 中的循环依赖"
- "优化 NestJS 性能"
- "为 NestJS 添加缓存"
- "将 NestJS 部署到生产环境"

---

## 3. 快速开始

### 8 步工作流

1. **安装依赖**：`npm i drizzle-orm pg && npm i -D drizzle-kit tsx`（适用于 Drizzle）
   - 或：`npm i @nestjs/typeorm typeorm pg`（适用于 TypeORM）
   - 或：`npm i @nestjs/mongoose mongoose`（适用于 Mongoose）
   - 或：`npx prisma init`（适用于 Prisma）

2. **定义模式**：创建 `src/db/schema.ts` 并定义表/实体

3. **创建 DatabaseService**：将数据库客户端作为 NestJS 提供者注入

4. **构建 CRUD 模块**：控制器 → 服务 → 仓储模式

5. **添加验证**：使用 class-validator DTO 配合 ValidationPipe

6. **实现守卫**：创建 JWT/角色守卫用于路由保护

7. **编写测试**：使用 `@nestjs/testing` 配合模拟的仓储

8. **运行迁移**：`npx drizzle-kit generate` → **验证 SQL** → `npx drizzle-kit migrate`

### 项目结构

```text
src/
├── app.module.ts
├── main.ts
├── common/
│   ├── filters/
│   ├── guards/
│   ├── interceptors/
│   └── pipes/
├── config/
│   ├── configuration.ts
│   └── validation.ts
├── modules/
│   ├── auth/
│   │   ├── auth.controller.ts
│   │   ├── auth.module.ts
│   │   ├── auth.service.ts
│   │   ├── dto/
│   │   ├── guards/
│   │   └── strategies/
│   └── users/
│       ├── dto/
│       ├── entities/
│       ├── users.controller.ts
│       ├── users.module.ts
│       └── users.service.ts
└── prisma/ or database/
```

**规则**：
- 将领域代码保留在功能模块内部
- 将跨切面的过滤器、装饰器、守卫和拦截器放在 `common/` 中
- 将 DTO 放在拥有它们的模块附近

---

## 4. 核心架构

### 启动和全局验证

```typescript
async function bootstrap() {
  const app = await NestFactory.create(AppModule, { bufferLogs: true });

  app.useGlobalPipes(
    new ValidationPipe({
      whitelist: true,
      forbidNonWhitelisted: true,
      transform: true,
      transformOptions: { enableImplicitConversion: true },
    }),
  );

  app.useGlobalInterceptors(new ClassSerializerInterceptor(app.get(Reflector)));
  app.useGlobalFilters(new HttpExceptionFilter());

  await app.listen(process.env.PORT ?? 3000);
}
bootstrap();
```

**要点**：
- 在公共 API 上始终启用 `whitelist` 和 `forbidNonWhitelisted`
- 优先使用一个全局验证管道，而不是在每个路由上重复验证配置
- 当环境/配置无效时终止启动，而不是部分启动

### 模块、控制器和提供者

```typescript
@Module({
  controllers: [UsersController],
  providers: [UsersService],
  exports: [UsersService],
})
export class UsersModule {}

@Controller('users')
export class UsersController {
  constructor(private readonly usersService: UsersService) {}

  @Get(':id')
  getById(@Param('id', ParseUUIDPipe) id: string) {
    return this.usersService.getById(id);
  }

  @Post()
  create(@Body() dto: CreateUserDto) {
    return this.usersService.create(dto);
  }
}

@Injectable()
export class UsersService {
  constructor(private readonly usersRepo: UsersRepository) {}

  async create(dto: CreateUserDto) {
    return this.usersRepo.create(dto);
  }
}
```

**规则**：
- 控制器应保持精简：解析 HTTP 输入、调用提供者、返回响应 DTO
- 将业务逻辑放在可注入的服务中，而不是控制器中
- 仅导出其他模块真正需要的提供者

### DTO 和验证

```typescript
export class CreateUserDto {
  @IsEmail()
  email!: string;

  @IsString()
  @Length(2, 80)
  name!: string;

  @IsOptional()
  @IsEnum(UserRole)
  role?: UserRole;
}
```

**规则**：
- 使用 `class-validator` 验证每个请求 DTO
- 使用专用的响应 DTO 或序列化器，而不是直接返回 ORM 实体
- 避免泄露内部字段，如密码哈希、令牌或审计列

### 认证、守卫和请求上下文

```typescript
@UseGuards(JwtAuthGuard, RolesGuard)
@Roles('admin')
@Get('admin/report')
getAdminReport(@Req() req: AuthenticatedRequest) {
  return this.reportService.getForUser(req.user.id);
}
```

**规则**：
- 除非认证策略和守卫真正共享，否则保持模块局部
- 在守卫中编码粗粒度访问规则，然后在服务中进行资源特定的授权
- 对于已认证的请求对象，优先使用显式请求类型

### 异常过滤器和错误格式

```typescript
@Catch()
export class HttpExceptionFilter implements ExceptionFilter {
  catch(exception: unknown, host: ArgumentsHost) {
    const response = host.switchToHttp().getResponse<Response>();
    const request = host.switchToHttp().getRequest<Request>();

    if (exception instanceof HttpException) {
      return response.status(exception.getStatus()).json({
        path: request.url,
        error: exception.getResponse(),
      });
    }

    return response.status(500).json({
      path: request.url,
      error: 'Internal server error',
    });
  }
}
```

**规则**：
- 在整个 API 中保持一致的错误信封格式
- 对于预期的客户端错误抛出框架异常；在中心位置记录并包装意外故障

### 配置和环境验证

```typescript
ConfigModule.forRoot({
  isGlobal: true,
  load: [configuration],
  validate: validateEnv,
});
```

**规则**：
- 在启动时验证环境变量，而不是在第一次请求时延迟验证
- 将配置访问放在类型化助手或配置服务后面
- 在配置工厂中拆分开发/预发/生产环境的关注点，而不是在功能代码中到处分支

### 持久化和事务

- 将仓储/ORM 代码放在使用领域语言的提供者后面
- 对于 Prisma 或 TypeORM，将事务性工作流隔离在拥有工作单元的的服务中
- 不要让控制器直接协调多步写入操作

### 生产环境默认值

- 启用结构化日志和请求关联 ID
- 当环境/配置无效时终止启动，而不是部分启动
- 对于数据库/缓存客户端，优先使用异步提供者初始化，并带有显式健康检查
- 将后台任务和事件消费者放在它们自己的模块中，而不是放在 HTTP 控制器内
- 对于公共端点，显式启用速率限制、认证和审计日志

---

## 5. 最佳实践（40 条规则）

### 按优先级分类的规则

| 优先级 | 类别 | 影响 | 前缀 | 数量 |
|--------|------|------|------|------|
| 1 | 架构 | 关键 | `arch-` | 6 |
| 2 | 依赖注入 | 关键 | `di-` | 6 |
| 3 | 错误处理 | 高 | `error-` | 3 |
| 4 | 安全 | 高 | `security-` | 5 |
| 5 | 性能 | 高 | `perf-` | 4 |
| 6 | 测试 | 中高 | `test-` | 3 |
| 7 | 数据库与 ORM | 中高 | `db-` | 3 |
| 8 | API 设计 | 中 | `api-` | 4 |
| 9 | 微服务 | 中 | `micro-` | 3 |
| 10 | DevOps 与部署 | 低中 | `devops-` | 3 |

### 1. 架构（关键）- arch-*

- `arch-avoid-circular-deps` - 避免模块间的循环依赖
- `arch-feature-modules` - 按功能组织，而非按技术层组织
- `arch-module-sharing` - 正确的模块导出/导入，避免重复的提供者
- `arch-single-responsibility` - 专注的服务，避免"上帝服务"
- `arch-use-repository-pattern` - 抽象数据库逻辑以提高可测试性
- `arch-use-events` - 使用事件驱动架构实现解耦

### 2. 依赖注入（关键）- di-*

- `di-avoid-service-locator` - 避免服务定位器反模式
- `di-interface-segregation` - 接口隔离原则（ISP）
- `di-liskov-substitution` - 里氏替换原则（LSP）
- `di-prefer-constructor-injection` - 优先使用构造函数注入而非属性注入
- `di-scope-awareness` - 理解单例/请求/瞬态作用域
- `di-use-interfaces-tokens` - 对接口使用注入令牌

### 3. 错误处理（高）- error-*

- `error-use-exception-filters` - 集中化异常处理
- `error-throw-http-exceptions` - 使用 NestJS HTTP 异常
- `error-handle-async-errors` - 正确处理异步错误

### 4. 安全（高）- security-*

- `security-auth-jwt` - 安全的 JWT 认证
- `security-validate-all-input` - 使用 class-validator 进行验证
- `security-use-guards` - 认证和授权守卫
- `security-sanitize-output` - 防止 XSS 攻击
- `security-rate-limiting` - 实现速率限制

### 5. 性能（高）- perf-*

- `perf-async-hooks` - 正确的异步生命周期钩子
- `perf-use-caching` - 实现缓存策略
- `perf-optimize-database` - 优化数据库查询
- `perf-lazy-loading` - 延迟加载模块以加快启动速度

### 6. 测试（中高）- test-*

- `test-use-testing-module` - 使用 NestJS 测试工具
- `test-e2e-supertest` - 使用 Supertest 进行 E2E 测试
- `test-mock-external-services` - 模拟外部依赖

### 7. 数据库与 ORM（中高）- db-*

- `db-use-transactions` - 事务管理
- `db-avoid-n-plus-one` - 避免 N+1 查询问题
- `db-use-migrations` - 使用迁移进行模式变更

### 8. API 设计（中）- api-*

- `api-use-dto-serialization` - DTO 和响应序列化
- `api-use-interceptors` - 跨切面关注点
- `api-versioning` - API 版本控制策略
- `api-use-pipes` - 使用管道进行输入转换

### 9. 微服务（中）- micro-*

- `micro-use-patterns` - 消息和事件模式
- `micro-use-health-checks` - 用于编排的健康检查
- `micro-use-queues` - 后台任务处理

### 10. DevOps 与部署（低中）- devops-*

- `devops-use-config-module` - 环境配置
- `devops-use-logging` - 结构化日志
- `devops-graceful-shutdown` - 零停机部署

**参考**：查看 [references/best-practices-rules.md](references/best-practices-rules.md) 获取每条规则的详细解释和代码示例。

---

## 6. 认证与安全

### JWT 认证守卫

```typescript
@Injectable()
export class JwtAuthGuard implements CanActivate {
  constructor(private jwtService: JwtService) {}

  canActivate(context: ExecutionContext) {
    const token = context.switchToHttp().getRequest()
      .headers.authorization?.split(' ')[1];
    if (!token) return false;
    try {
      const decoded = this.jwtService.verify(token);
      context.switchToHttp().getRequest().user = decoded;
      return true;
    } catch {
      return false;
    }
  }
}
```

### 安全最佳实践

- **验证所有输入**：使用全局 `ValidationPipe` 配合 class-validator
- **实现速率限制**：防止暴力攻击
- **使用守卫**：JWT/角色守卫用于路由保护
- **清理输出**：防止 XSS 攻击
- **保护 JWT**：正确的密钥管理、令牌过期
- **绝不硬编码密钥**：使用环境变量存储 DATABASE_URL、JWT_SECRET

**参考**：查看 [references/authentication-security.md](references/authentication-security.md) 获取完整的认证实现。

---

## 7. 数据库集成

### Drizzle ORM

```typescript
// src/db/schema.ts
export const users = pgTable('users', {
  id: serial('id').primaryKey(),
  name: text('name').notNull(),
  email: text('email').notNull().unique(),
  createdAt: timestamp('created_at').defaultNow(),
});

// Repository pattern
@Injectable()
export class UserRepository {
  constructor(private db: DatabaseService) {}

  async findAll() {
    return this.db.database.select().from(users);
  }

  async create(data: typeof users.$inferInsert) {
    return this.db.database.insert(users).values(data).returning();
  }
}
```

### 数据库事务

```typescript
async transferFunds(fromId: number, toId: number, amount: number) {
  return this.db.database.transaction(async (tx) => {
    await tx.update(accounts)
      .set({ balance: sql`${accounts.balance} - ${amount}` })
      .where(eq(accounts.id, fromId));
    await tx.update(accounts)
      .set({ balance: sql`${accounts.balance} + ${amount}` })
      .where(eq(accounts.id, toId));
  });
}
```

### 支持的 ORM

- **Drizzle ORM**：类型安全的查询构建器，使用 drizzle-kit 进行迁移
- **TypeORM**：实体装饰器、仓储模式、多数据库支持
- **Prisma**：类型安全的客户端、迁移、强 TypeScript 集成
- **Mongoose**：MongoDB 模式装饰器、模型注入

**参考**：查看 [references/database-integration.md](references/database-integration.md) 获取完整的 ORM 集成指南。

---

## 8. 测试

### 使用模拟进行单元测试

```typescript
describe('UsersService', () => {
  let service: UsersService;
  let repo: jest.Mocked<UserRepository>;

  beforeEach(async () => {
    const module = await Test.createTestingModule({
      providers: [
        UsersService,
        { provide: UserRepository, useValue: { findAll: jest.fn(), create: jest.fn() } },
      ],
    }).compile();
    service = module.get(UsersService);
    repo = module.get(UserRepository);
  });

  it('should create user', async () => {
    const dto = { name: 'John', email: 'john@example.com' };
    repo.create.mockResolvedValue({ id: 1, ...dto, createdAt: new Date() });
    expect(await service.create(dto)).toMatchObject(dto);
  });
});
```

### E2E 测试

```typescript
describe('UsersController', () => {
  let app: INestApplication;

  beforeAll(async () => {
    const moduleRef = await Test.createTestingModule({
      imports: [UsersModule],
    }).compile();

    app = moduleRef.createNestApplication();
    app.useGlobalPipes(new ValidationPipe({ whitelist: true, transform: true }));
    await app.init();
  });
});
```

**测试策略**：
- 使用模拟的依赖项隔离测试提供者
- 为守卫、验证管道和异常过滤器添加请求级别的测试
- 在测试中复用与生产环境相同的全局管道/过滤器
- 模拟外部依赖（JwtService、数据库、外部 API）

**验证顺序**：类型检查 → 单元测试 → 集成测试 → E2E 测试

**参考**：查看 [references/testing-guide.md](references/testing-guide.md) 获取完整的测试策略。

---

## 9. 微服务与队列

### 微服务传输

- 使用 TCP/Redis 传输进行服务间通信
- 消息模式用于请求/响应
- 事件模式用于发送后遗忘

### 后台任务处理

- 使用 Bull/BullMQ 进行任务队列
- 使用 `@nestjs/schedule` 进行定时任务
- 用于编排的健康检查

### 健康检查

- 实现健康检查端点用于编排
- 监控数据库连接性
- 检查外部服务可用性

**参考**：查看 [references/microservices-queues.md](references/microservices-queues.md) 获取微服务模式。

---

## 10. 性能优化

### 缓存策略

- 使用内置缓存管理器进行响应缓存
- 为昂贵操作实现缓存拦截器
- 根据数据易变性配置 TTL
- 使用 Redis 进行分布式缓存

### 数据库优化

- 使用 DataLoader 模式解决 N+1 查询问题
- 在频繁查询的字段上实现适当的索引
- 对于复杂查询使用查询构建器而非 ORM 方法
- 在开发中启用查询日志以进行分析

### 请求处理

- 实现压缩中间件
- 对大响应使用流式传输
- 配置适当的速率限制
- 启用集群以利用多核

**参考**：查看 [references/performance-optimization.md](references/performance-optimization.md) 获取优化技术。

---

## 11. Sentry 集成

### 4 阶段工作流

**阶段 1：检测** - 扫描项目以了解设置
**阶段 2：推荐** - 基于检测结果建议功能
**阶段 3：指导** - 逐步实现 Sentry
**阶段 4：交叉链接** - 检查是否有配套的前端

### 三文件设置模式

#### 步骤 1：创建 `src/instrument.ts`

```typescript
import * as Sentry from "@sentry/nestjs";

Sentry.init({
  dsn: process.env.SENTRY_DSN,
  environment: process.env.SENTRY_ENVIRONMENT ?? "production",
  release: process.env.SENTRY_RELEASE,
  sendDefaultPii: true,
  tracesSampleRate: 1.0,
  enableLogs: true,
});
```

#### 步骤 2：在 `src/main.ts` 中最先导入

```typescript
// instrument.ts 必须是第一个导入
import "./instrument";

import { NestFactory } from "@nestjs/core";
import { AppModule } from "./app.module";

async function bootstrap() {
  const app = await NestFactory.create(AppModule);
  app.enableShutdownHooks();
  await app.listen(3000);
}
bootstrap();
```

#### 步骤 3：在 `src/app.module.ts` 中注册

```typescript
import { Module } from "@nestjs/common";
import { APP_FILTER } from "@nestjs/core";
import { SentryModule, SentryGlobalFilter } from "@sentry/nestjs/setup";

@Module({
  imports: [SentryModule.forRoot()],
  providers: [
    {
      provide: APP_FILTER,
      useClass: SentryGlobalFilter,
    },
  ],
})
export class AppModule {}
```

### 关键配置

| 选项 | 默认值 | 用途 |
|------|--------|------|
| `dsn` | — | 如果为空则 SDK 禁用；环境变量：`SENTRY_DSN` |
| `environment` | `"production"` | 例如 `"staging"` |
| `tracesSampleRate` | — | 事务采样率 |
| `enableLogs` | `false` | 发送结构化日志（SDK ≥ 9.41.0） |
| `profileSessionSampleRate` | — | 持续性能分析采样率（SDK ≥ 10.27.0） |

### 装饰器

- `@SentryTraced(op?)` - 为任何方法添加 instrumentation
- `@SentryCron(slug, config?)` - 监控定时任务
- `Sentry.withIsolationScope()` - 防止后台任务中的交叉污染

**参考**：查看 [references/sentry-integration.md](references/sentry-integration.md) 获取完整的 Sentry 设置指南。

---

## 12. 故障排除

### 常见 NestJS 问题

1. **"Nest can't resolve dependencies of the [Service] (?)"**
   - 检查提供者是否在模块的 providers 数组中
   - 如果跨越边界，验证模块导出
   - 检查提供者名称是否有拼写错误

2. **"Circular dependency detected"**
   - 在依赖的两端都使用 forwardRef()
   - 将共享逻辑提取到第三个模块（推荐）
   - 考虑循环依赖是否表明设计缺陷

3. **"Unknown authentication strategy 'jwt'"**
   - 从 'passport-jwt' 导入 Strategy，而不是 'passport-local'
   - 确保 JwtModule.secret 与 JwtStrategy.secretOrKey 匹配
   - 设置 JWT_SECRET 环境变量

4. **"secretOrPrivateKey must have a value"**
   - 在环境变量中设置 JWT_SECRET
   - 检查 ConfigModule 在 JwtModule 之前加载
   - 使用 ConfigService 进行动态配置

5. **"[TypeOrmModule] Unable to connect to the database"**
   - 检查实体配置
   - 对于多个数据库：使用命名连接
   - 实现连接错误处理

6. **"ActorModule exporting itself instead of ActorService"**
   - 从 exports 数组中导出服务而不是模块
   - 常见错误：exports: [ActorModule] → exports: [ActorService]

### 常见 Sentry 问题

| 问题 | 解决方案 |
|------|----------|
| 事件未出现 | 设置 `debug: true`，验证 `SENTRY_DSN`，检查 `instrument.ts` 是否最先导入 |
| 自动 instrumentation 未生效 | `instrument.ts` 必须是 `main.ts` 中的**第一个导入** |
| 重复 span | `SentryModule.forRoot()` 在多个模块中注册 |
| 后台任务事件混合 | 将任务体包装在 `Sentry.withIsolationScope(() => { ... })` 中 |
| Prisma span 缺失 | 添加 `integrations: [Sentry.prismaIntegration()]` |

**参考**：查看 [references/troubleshooting.md](references/troubleshooting.md) 获取 39 个详细问题解决方案。

---

## 13. 决策树

### 选择数据库 ORM

```
项目需求：
├─ 需要迁移？ → TypeORM 或 Prisma
├─ NoSQL 数据库？ → Mongoose
├─ 类型安全优先？ → Prisma
├─ 复杂关系？ → TypeORM
└─ 现有数据库？ → TypeORM（更好的遗留支持）
```

### 模块组织策略

```
功能复杂度：
├─ 简单 CRUD → 单个模块，包含控制器 + 服务
├─ 领域逻辑 → 分离领域模块 + 基础设施
├─ 共享逻辑 → 创建带有导出的共享模块
├─ 微服务 → 带有消息模式的独立应用
└─ 外部 API → 创建带有 HttpModule 的客户端模块
```

### 测试策略选择

```
所需测试类型：
├─ 业务逻辑 → 使用模拟的单元测试
├─ API 契约 → 使用测试数据库的集成测试
├─ 用户流程 → 使用 Supertest 的 E2E 测试
├─ 性能 → 使用 k6 或 Artillery 进行负载测试
└─ 安全 → OWASP ZAP 或安全中间件测试
```

### 认证方法

```
安全需求：
├─ 无状态 API → JWT 配合刷新令牌
├─ 基于会话 → Express 会话配合 Redis
├─ OAuth/社交登录 → Passport 配合提供者策略
├─ 多租户 → JWT 配合租户声明
└─ 微服务 → 使用 mTLS 的服务间认证
```

### 缓存策略

```
数据特征：
├─ 用户特定 → Redis 配合用户键前缀
├─ 全局数据 → 带 TTL 的内存缓存
├─ 数据库结果 → 查询结果缓存
├─ 静态资源 → CDN 配合缓存头
└─ 计算值 → 记忆化装饰器
```

**参考**：查看 [decision-trees/](decision-trees/) 目录获取详细的决策树。

---

## 14. 代码审查清单

### 模块架构与依赖注入
- [ ] 所有服务都正确使用 @Injectable() 装饰
- [ ] 提供者在模块的 providers 数组中列出，并在需要时导出
- [ ] 模块之间没有循环依赖（检查 forwardRef 的使用）
- [ ] 模块边界遵循领域/功能分离
- [ ] 自定义提供者使用正确的注入令牌（避免使用字符串令牌）

### 测试与模拟
- [ ] 测试模块使用最小、专注的提供者模拟
- [ ] TypeORM 仓储使用 getRepositoryToken(Entity) 进行模拟
- [ ] 单元测试中没有实际的数据库依赖
- [ ] 测试中所有异步操作都正确等待
- [ ] JwtService 和外部依赖都进行了适当的模拟

### 数据库集成（TypeORM 重点）
- [ ] 实体装饰器使用正确的语法（@Column() 而非 @Column('description')）
- [ ] 连接错误不会导致整个应用崩溃
- [ ] 多个数据库连接使用命名连接
- [ ] 数据库连接具有适当的错误处理和重试逻辑
- [ ] 实体在 TypeOrmModule.forFeature() 中正确注册

### 认证与安全（JWT + Passport）
- [ ] JWT Strategy 从 'passport-jwt' 导入而非 'passport-local'
- [ ] JwtModule 密钥与 JwtStrategy secretOrKey 完全匹配
- [ ] 授权头遵循 'Bearer [token]' 格式
- [ ] 令牌过期时间适合用例
- [ ] JWT_SECRET 环境变量已正确配置

### 请求生命周期与中间件
- [ ] 中间件执行顺序遵循：中间件 → 守卫 → 拦截器 → 管道
- [ ] 守卫正确保护路由并返回布尔值/抛出异常
- [ ] 拦截器正确处理异步操作
- [ ] 异常过滤器正确捕获并转换错误
- [ ] 管道使用 class-validator 装饰器验证 DTO

### 性能与优化
- [ ] 为昂贵操作实现了缓存
- [ ] 数据库查询避免 N+1 问题（使用 DataLoader 模式）
- [ ] 为数据库连接配置了连接池
- [ ] 防止内存泄漏（清理事件监听器）
- [ ] 生产环境启用了压缩中间件

**参考**：查看 [checklists/code-review.md](checklists/code-review.md) 获取完整清单。

---

## 15. 成功指标

- ✅ 问题已正确识别并在模块结构中定位
- ✅ 解决方案遵循 NestJS 架构模式
- ✅ 所有测试通过（单元、集成、E2E）
- ✅ 没有引入循环依赖
- ✅ 性能指标保持或提升
- ✅ 代码遵循既定的项目约定
- ✅ 实现了适当的错误处理
- ✅ 应用了安全最佳实践
- ✅ 为 API 变更更新了文档

---

## 16. 参考资料

每个主题的详细文档：

- [references/core-patterns.md](references/core-patterns.md) - 核心架构模式
- [references/best-practices-rules.md](references/best-practices-rules.md) - 40 条最佳实践规则
- [references/database-integration.md](references/database-integration.md) - 数据库集成（Drizzle/TypeORM/Prisma/Mongoose）
- [references/authentication-security.md](references/authentication-security.md) - 认证与安全
- [references/testing-guide.md](references/testing-guide.md) - 完整测试指南
- [references/microservices-queues.md](references/microservices-queues.md) - 微服务与队列
- [references/performance-optimization.md](references/performance-optimization.md) - 性能优化
- [references/sentry-integration.md](references/sentry-integration.md) - Sentry 集成
- [references/troubleshooting.md](references/troubleshooting.md) - 故障排除指南

---

## 17. 示例

常见模式的代码示例：

- [examples/crud-with-drizzle.ts](examples/crud-with-drizzle.ts) - 使用 Drizzle ORM 的完整 CRUD
- [examples/jwt-auth-guard.ts](examples/jwt-auth-guard.ts) - JWT 认证守卫
- [examples/database-transactions.ts](examples/database-transactions.ts) - 数据库事务
- [examples/unit-testing-mocks.ts](examples/unit-testing-mocks.ts) - 使用模拟的单元测试
- [examples/bootstrap-config.ts](examples/bootstrap-config.ts) - 启动配置
- [examples/exception-filter.ts](examples/exception-filter.ts) - 异常过滤器
- [examples/sentry-instrument.ts](examples/sentry-instrument.ts) - Sentry 三文件设置
- [examples/sentry-decorators.ts](examples/sentry-decorators.ts) - Sentry 装饰器
- [examples/sentry-di-wrapper.ts](examples/sentry-di-wrapper.ts) - Sentry DI 包装器

---

## 18. 工作流

逐步工作流指南：

- [workflows/quick-start.md](workflows/quick-start.md) - 快速开始工作流
- [workflows/environment-detection.md](workflows/environment-detection.md) - 环境检测
- [workflows/validation-process.md](workflows/validation-process.md) - 验证流程
- [workflows/deployment-guide.md](workflows/deployment-guide.md) - 部署指南

---

## 19. 检查清单

质量保证检查清单：

- [checklists/code-review.md](checklists/code-review.md) - 代码审查清单
- [checklists/security-checklist.md](checklists/security-checklist.md) - 安全检查清单
- [checklists/production-ready.md](checklists/production-ready.md) - 生产就绪清单
- [checklists/success-metrics.md](checklists/success-metrics.md) - 成功指标清单

---

## 约束和警告

- **必须使用 DTO**：始终使用带有 class-validator 的 DTO，绝不接受原始对象
- **事务**：保持事务简短；避免嵌套事务
- **守卫顺序**：JWT 守卫必须在角色守卫之前运行
- **环境变量**：绝不硬编码 DATABASE_URL 或 JWT_SECRET
- **迁移**：在部署之前，模式变更后运行迁移生成
- **循环依赖**：谨慎使用 `forwardRef()`；优先重构模块
- **Sentry**：`instrument.ts` 必须是 `main.ts` 中的第一个导入
- **Sentry**：不要重复注册 `SentryModule.forRoot()`

---

## 快速参考模式

### 自定义装饰器模式

```typescript
export const Auth = (...roles: Role[]) =>
  applyDecorators(
    UseGuards(JwtAuthGuard, RolesGuard),
    Roles(...roles),
  );
```

### 依赖注入令牌

```typescript
export const CONFIG_OPTIONS = Symbol('CONFIG_OPTIONS');

@Module({
  providers: [
    {
      provide: CONFIG_OPTIONS,
      useValue: { apiUrl: 'https://api.example.com' }
    }
  ]
})
```

### 全局模块模式

```typescript
@Global()
@Module({
  providers: [GlobalService],
  exports: [GlobalService],
})
export class GlobalModule {}
```

### 动态模块模式

```typescript
@Module({})
export class ConfigModule {
  static forRoot(options: ConfigOptions): DynamicModule {
    return {
      module: ConfigModule,
      providers: [
        {
          provide: 'CONFIG_OPTIONS',
          useValue: options,
        },
      ],
    };
  }
}
```
