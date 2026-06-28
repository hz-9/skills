---
name: nestjs-comprehensive-new
description: 全面的 NestJS 框架指南，包含 Prisma ORM 集成、40 条最佳实践规则、认证、测试、微服务和生产环境模式。适用于构建 NestJS 应用、实现 API、认证、数据库操作或部署生产级服务器端应用。
allowed-tools: Read, Write, Edit, Glob, Grep, Bash
category: framework
version: "1.0.0"
---

# NestJS 综合指南

完整的 NestJS 框架资源，涵盖架构模式、40 条最佳实践规则、Prisma ORM 数据库集成、微服务、认证、测试策略和生产部署。

## 何时使用

- 使用 NestJS 构建 REST API 或 GraphQL 服务器
- 使用 JWT/Passport 设置认证和授权
- 使用 Prisma ORM 实现数据库操作
- 使用 TCP/Redis 传输、Bull/BullMQ 队列创建微服务
- 编写单元测试、集成测试和 E2E 测试
- 运行数据库迁移
- 优化性能和缓存
- 部署生产就绪的 NestJS 应用

### 触发场景：

- "构建一个 NestJS API"
- "为 NestJS 添加 JWT 认证"
- "将 Prisma 与 NestJS 集成"
- "使用 NestJS 创建微服务"
- "为 NestJS 模块编写测试"
- "修复 NestJS 中的循环依赖"
- "优化 NestJS 性能"
- "将 NestJS 部署到生产环境"

---

## 快速开始

### 8 步工作流

1. **初始化 Prisma**：`npx prisma init` → 配置 `prisma/schema.prisma` 中的 datasource
2. **定义模型**：在 `prisma/schema.prisma` 中定义数据模型
3. **创建 PrismaService**：封装 PrismaClient 作为 NestJS 提供者
4. **构建 CRUD 模块**：Controller → Service → 仓储模式
5. **添加验证**：使用 class-validator DTO 配合 ValidationPipe
6. **实现守卫**：创建 JWT/角色守卫用于路由保护
7. **编写测试**：使用 `@nestjs/testing` 配合模拟的 PrismaService
8. **运行迁移**：`npx prisma migrate dev --name init` → **验证 SQL** → `npx prisma migrate deploy`

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
└── prisma/
    ├── schema.prisma
    ├── migrations/
    └── seed.ts
```

**规则**：
- 将领域代码保留在功能模块内部
- 将跨切面的过滤器、装饰器、守卫和拦截器放在 `common/` 中
- 将 DTO 放在拥有它们的模块附近

---

## 核心架构

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
```

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

### 异常过滤器

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

### 配置和环境验证

```typescript
ConfigModule.forRoot({
  isGlobal: true,
  load: [configuration],
  validate: validateEnv,
});
```

### 生产环境默认值

- 启用结构化日志和请求关联 ID
- 当环境/配置无效时终止启动
- 对于数据库/缓存客户端，优先使用异步提供者初始化，并带有显式健康检查
- 将后台任务和事件消费者放在各自模块中
- 对于公共端点，显式启用速率限制、认证和审计日志

**详细参考**：[references/core-patterns.md](references/core-patterns.md)

---

## Prisma 集成速查

### PrismaService 模式

```typescript
import { Injectable, OnModuleInit, OnModuleDestroy } from '@nestjs/common';
import { PrismaClient } from '@prisma/client';

@Injectable()
export class PrismaService extends PrismaClient implements OnModuleInit, OnModuleDestroy {
  async onModuleInit() {
    await this.$connect();
  }

  async onModuleDestroy() {
    await this.$disconnect();
  }
}
```

### PrismaModule

```typescript
import { Global, Module } from '@nestjs/common';
import { PrismaService } from './prisma.service';

@Global()
@Module({
  providers: [PrismaService],
  exports: [PrismaService],
})
export class PrismaModule {}
```

### CRUD 示例

```typescript
@Injectable()
export class UsersService {
  constructor(private prisma: PrismaService) {}

  async findAll() {
    return this.prisma.user.findMany();
  }

  async create(data: CreateUserDto) {
    return this.prisma.user.create({ data });
  }

  async getById(id: string) {
    return this.prisma.user.findUniqueOrThrow({ where: { id } });
  }
}
```

**详细参考**：[references/prisma-integration.md](references/prisma-integration.md)

---

## 最佳实践（40 条规则）

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

查看 [rules/](rules/) 目录获取每条规则的详细说明和代码示例（含错误/正确做法对比）。

查看 [references/best-practices-rules.md](references/best-practices-rules.md) 获取编译版本。

---

## 认证与安全

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
- **绝不硬编码密钥**：使用环境变量存储 DATABASE_URL、JWT_SECRET

**详细参考**：[references/authentication-security.md](references/authentication-security.md)

---

## 测试

### 使用模拟进行单元测试

```typescript
describe('UsersService', () => {
  let service: UsersService;
  let prisma: DeepMockProxy<PrismaClient>;

  beforeEach(async () => {
    const module = await Test.createTestingModule({
      providers: [
        UsersService,
        { provide: PrismaService, useValue: mockDeep<PrismaClient>() },
      ],
    }).compile();
    service = module.get(UsersService);
    prisma = module.get(PrismaService);
  });

  it('should create user', async () => {
    const dto = { name: 'John', email: 'john@example.com' };
    prisma.user.create.mockResolvedValue({ id: '1', ...dto, createdAt: new Date() });
    expect(await service.create(dto)).toMatchObject(dto);
  });
});
```

**验证顺序**：类型检查 → 单元测试 → 集成测试 → E2E 测试

**详细参考**：[references/testing-guide.md](references/testing-guide.md)

---

## 微服务与队列

- **微服务传输**：使用 TCP/Redis 传输进行服务间通信；消息模式用于请求/响应；事件模式用于发送后遗忘
- **后台任务**：使用 Bull/BullMQ 进行任务队列；使用 `@nestjs/schedule` 进行定时任务
- **健康检查**：实现健康检查端点用于编排；监控数据库连接性

**详细参考**：[references/microservices-queues.md](references/microservices-queues.md)

---

## 性能优化

- **缓存策略**：使用内置缓存管理器进行响应缓存；根据数据易变性配置 TTL；使用 Redis 进行分布式缓存
- **数据库优化**：使用 Prisma 的 `select`/`include` 预防 N+1 查询；在频繁查询的字段上实现索引；在开发中启用查询日志
- **请求处理**：实现压缩中间件；配置适当的速率限制；启用集群以利用多核

**详细参考**：[references/performance-optimization.md](references/performance-optimization.md)

---

## Sentry 集成（可选）

> **注意**：Sentry 集成是可选的。使用前请先确认用户是否需要 Sentry 监控。

Sentry 为 NestJS 应用提供错误监控、分布式追踪和性能分析。

**4 阶段工作流**：检测 → 推荐 → 指导 → 交叉链接
**三文件设置**：`src/instrument.ts` → `src/main.ts`（最先导入） → `src/app.module.ts`（注册 SentryModule）

**详细参考**：[references/sentry-integration.md](references/sentry-integration.md)

---

## 错误诊断 — 当用户遇到错误时

### 环境检测

遇到错误时，首先检测项目环境：

```bash
# 检查 NestJS 设置
test -f nest-cli.json && echo "检测到 NestJS CLI 项目"
grep -q "@nestjs/core" package.json && echo "已安装 NestJS 框架"

# 检测 NestJS 版本
grep "@nestjs/core" package.json | sed 's/.*"\([0-9\.]*\)".*/NestJS 版本：\1/'

# 检查 Prisma 设置
grep -q "@prisma/client" package.json && echo "检测到 Prisma"
test -f prisma/schema.prisma && echo "找到 Prisma Schema"

# 检查认证
grep -q "@nestjs/passport" package.json && echo "检测到 Passport 认证"
grep -q "@nestjs/jwt" package.json && echo "检测到 JWT 认证"
```

### 验证顺序

始终按以下顺序验证修复：

1. **类型检查**：`npm run build`
2. **单元测试**：`npm run test`
3. **集成测试**：`npm run test:e2e`

### 常见问题快速入口

| 问题 | 快速诊断 |
|------|---------|
| "Nest can't resolve dependencies" | 检查 providers 数组、模块导出、拼写错误 |
| "Circular dependency detected" | 使用 `forwardRef()` 或提取共享模块 |
| "Unknown authentication strategy 'jwt'" | 从 'passport-jwt' 导入 Strategy |
| Prisma 连接错误 | 检查 DATABASE_URL、`prisma generate` 是否运行 |
| "secretOrPrivateKey must have a value" | 设置 JWT_SECRET 环境变量 |

**详细问题排查**：[references/troubleshooting.md](references/troubleshooting.md)

---

## 决策树

- [decision-trees/authentication-method.md](decision-trees/authentication-method.md) - 认证方法选择
- [decision-trees/caching-strategy.md](decision-trees/caching-strategy.md) - 缓存策略选择
- [decision-trees/module-organization.md](decision-trees/module-organization.md) - 模块组织策略
- [decision-trees/testing-strategy.md](decision-trees/testing-strategy.md) - 测试策略选择

---

## 代码审查清单

- [checklists/code-review.md](checklists/code-review.md) - 代码审查清单
- [checklists/security-checklist.md](checklists/security-checklist.md) - 安全检查清单
- [checklists/production-ready.md](checklists/production-ready.md) - 生产就绪清单
- [checklists/success-metrics.md](checklists/success-metrics.md) - 成功指标清单

---

## 参考资料

- [references/core-patterns.md](references/core-patterns.md) - 核心架构模式
- [references/prisma-integration.md](references/prisma-integration.md) - Prisma 集成指南（设置/CLI/Client API/最佳实践）
- [references/best-practices-rules.md](references/best-practices-rules.md) - 40 条最佳实践规则
- [references/authentication-security.md](references/authentication-security.md) - 认证与安全
- [references/testing-guide.md](references/testing-guide.md) - 完整测试指南
- [references/microservices-queues.md](references/microservices-queues.md) - 微服务与队列
- [references/performance-optimization.md](references/performance-optimization.md) - 性能优化
- [references/sentry-integration.md](references/sentry-integration.md) - Sentry 集成（可选）
- [references/troubleshooting.md](references/troubleshooting.md) - 故障排除指南

## 示例

- [examples/crud-with-prisma.ts](examples/crud-with-prisma.ts) - 使用 Prisma 的完整 CRUD
- [examples/jwt-auth-guard.ts](examples/jwt-auth-guard.ts) - JWT 认证守卫
- [examples/unit-testing-mocks.ts](examples/unit-testing-mocks.ts) - 使用模拟的单元测试
- [examples/bootstrap-config.ts](examples/bootstrap-config.ts) - 启动配置
- [examples/exception-filter.ts](examples/exception-filter.ts) - 异常过滤器
- [examples/sentry-instrument.ts](examples/sentry-instrument.ts) - Sentry 三文件设置（可选）
- [examples/sentry-decorators.ts](examples/sentry-decorators.ts) - Sentry 装饰器（可选）
- [examples/sentry-di-wrapper.ts](examples/sentry-di-wrapper.ts) - Sentry DI 包装器（可选）

## 工作流

- [workflows/quick-start.md](workflows/quick-start.md) - 快速开始工作流
- [workflows/environment-detection.md](workflows/environment-detection.md) - 环境检测
- [workflows/validation-process.md](workflows/validation-process.md) - 验证流程
- [workflows/deployment-guide.md](workflows/deployment-guide.md) - 部署指南

---

## 约束和警告

- **必须使用 DTO**：始终使用带有 class-validator 的 DTO，绝不接受原始对象
- **事务**：保持事务简短；避免嵌套事务；使用 `prisma.$transaction` 进行多步操作
- **守卫顺序**：JWT 守卫必须在角色守卫之前运行
- **环境变量**：绝不硬编码 DATABASE_URL 或 JWT_SECRET
- **迁移**：在部署之前，schema 变更后运行 `prisma migrate dev` 生成迁移，CI/CD 中使用 `prisma migrate deploy`
- **循环依赖**：谨慎使用 `forwardRef()`；优先重构模块
- **Sentry**（可选）：`instrument.ts` 必须是 `main.ts` 中的第一个导入；不要重复注册 `SentryModule.forRoot()`
- **Prisma Client**：每次 schema 变更后运行 `prisma generate`；使用 `prisma-client` generator（Prisma 7）而非 `prisma-client-js`（Prisma 6）

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
