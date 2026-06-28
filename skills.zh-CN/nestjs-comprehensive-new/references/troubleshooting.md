# 故障排除指南

NestJS 应用程序的全面故障排除指南，涵盖来自 GitHub 和 Stack Overflow 的真实问题及解决方案。

## 诊断框架

遇到错误时，按以下流程排查：

### 环境检测

```bash
# 检查 NestJS 设置
test -f nest-cli.json && echo "检测到 NestJS CLI 项目"
grep -q "@nestjs/core" package.json && echo "已安装 NestJS 框架"

# 检测 NestJS 版本
grep "@nestjs/core" package.json | sed 's/.*"\([0-9\.]*\)".*/NestJS 版本：\1/'

# 检查 Prisma 设置
grep -q "@prisma/client" package.json && echo "检测到 Prisma ORM"
test -f prisma/schema.prisma && echo "找到 Prisma Schema"

# 检查认证
grep -q "@nestjs/passport" package.json && echo "检测到 Passport 认证"
grep -q "@nestjs/jwt" package.json && echo "检测到 JWT 认证"

# 分析模块结构
find src -name "*.module.ts" -type f | head -5 | xargs -I {} basename {} .module.ts
```

### 验证顺序

始终按以下顺序验证修复：

```bash
npm run build          # 1. 先类型检查
npm run test           # 2. 运行单元测试
npm run test:e2e       # 3. 运行 e2e 测试（如果需要）
```

---

## 常见 NestJS 问题

### 1. "Nest can't resolve dependencies of the [Service] (?)"

**频率**：最高（500+ GitHub issues）| **复杂度**：低-中

**真实案例**：GitHub #3186、#886、#2359 | SO 75483101

**解决方案**：
1. 检查 provider 是否在模块的 providers 数组中
2. 如果跨越边界，验证模块导出
3. 检查 provider 名称中的拼写错误（GitHub #598 - 误导性错误）
4. 检查 barrel 导出中的导入顺序（GitHub #9095）

```typescript
// 错误：模块中缺少 provider
@Module({
  providers: [UsersService], // 缺少 UserRepository！
})

// 正确
@Module({
  providers: [UsersService, UserRepository],
})
```

### 2. "Circular dependency detected"

**频率**：高 | **复杂度**：高

**解决方案**：
1. 在依赖关系的两侧都使用 forwardRef()
2. 将共享逻辑提取到第三个模块（推荐）
3. 考虑循环依赖是否表明设计缺陷
4. 注意：社区警告 forwardRef() 可能掩盖更深层次的问题

```typescript
// 临时修复
@Module({
  imports: [forwardRef(() => BModule)],
})

// 推荐修复：提取共享逻辑
@Module({})
class SharedModule {}

@Module({ imports: [SharedModule] })
class AModule {}

@Module({ imports: [SharedModule] })
class BModule {}
```

### 3. "Cannot test e2e because Nestjs doesn't resolve dependencies"

**频率**：高 | **复杂度**：中

**解决方案**：
1. 使用 @golevelup/ts-jest 的 createMock() 辅助函数
2. 在测试模块 providers 中模拟 JwtService
3. 在 Test.createTestingModule() 中导入所有必需的模块
4. 对于 Bazel 用户：需要特殊配置

### 4. "PrismaClientInitializationError — Prisma 连接失败"

**频率**：高 | **复杂度**：中

**解决方案**：
1. 检查 `DATABASE_URL` 环境变量是否正确配置
2. 确认数据库服务是否可达
3. 确保已运行 `prisma generate` 生成客户端
4. 验证适配器包是否与数据库匹配（如 `@prisma/adapter-pg` 对应 PostgreSQL）
5. 在 PrismaService 的 `onModuleInit` 中添加错误处理和重试逻辑

```typescript
@Injectable()
export class PrismaService extends PrismaClient implements OnModuleInit {
  async onModuleInit() {
    try {
      await this.$connect();
    } catch (error) {
      console.error('Prisma connection failed:', error);
      throw error;
    }
  }
}
```

### 5. "Prisma Migrate 冲突 — Migration "xxx" was already applied"

**频率**：中 | **复杂度**：中

**解决方案**：
1. 检查迁移目录和数据库中的迁移历史
2. 使用 `prisma migrate resolve --applied "migration_name"` 标记为已应用
3. 或使用 `prisma migrate resolve --rolled-back "migration_name"` 回滚
4. 在团队协作中确保迁移名称唯一

### 5. "Unknown authentication strategy 'jwt'"

**频率**：高 | **复杂度**：低

**解决方案**：
1. 从 'passport-jwt' 导入 Strategy 而不是 'passport-local'
2. 确保 JwtModule.secret 与 JwtStrategy.secretOrKey 匹配
3. 检查 Authorization header 中的 Bearer token 格式
4. 设置 JWT_SECRET 环境变量

```typescript
// 错误
import { Strategy } from 'passport-local';

// 正确
import { Strategy } from 'passport-jwt';
```

### 6. "ActorModule exporting itself instead of ActorService"

**频率**：中 | **复杂度**：低

**解决方案**：
1. 从 exports 数组导出 SERVICE 而不是 MODULE
2. 常见错误：exports: [ActorModule] → exports: [ActorService]
3. 检查所有模块导出是否存在此模式
4. 使用 nest info 命令验证

```typescript
// 错误
@Module({
  exports: [ActorModule],
})

// 正确
@Module({
  exports: [ActorService],
})
```

### 7. "secretOrPrivateKey must have a value" (JWT)

**频率**：高 | **复杂度**：低

**解决方案**：
1. 在环境变量中设置 JWT_SECRET
2. 检查 ConfigModule 在 JwtModule 之前加载
3. 验证 .env 文件是否在正确的位置
4. 使用 ConfigService 进行动态配置

### 8. 版本特定回归（Regressions）

**频率**：低 | **复杂度**：中

**解决方案**：
1. 检查 GitHub issues 中你的特定版本
2. 尝试降级到之前的稳定版本
3. 更新到最新的 patch 版本
4. 使用最小复现报告回归问题

### 9. "Nest can't resolve dependencies of the UserController (?, +)"

**频率**：高 | **复杂度**：低

**解决方案**：
1. "?" 表示该位置缺少 provider
2. 计算构造函数参数以识别缺少哪个
3. 将缺少的 service 添加到模块 providers
4. 检查 service 是否正确装饰了 @Injectable()

### 10. "Nest can't resolve dependencies of the Repository" (测试)

**频率**：中 | **复杂度**：中

**解决方案**：
1. 使用 getRepositoryToken(Entity) 作为 provider token
2. 在测试模块中模拟 DataSource
3. 提供测试数据库连接
4. 考虑完全模拟 repository

```typescript
{
  provide: getRepositoryToken(User),
  useValue: mockUserRepository,
}
```

### 11. "Unauthorized 401 (Missing credentials)" 与 Passport JWT

**频率**：高 | **复杂度**：低

**解决方案**：
1. 验证 Authorization header 格式："Bearer [token]"
2. 检查 token 过期（测试时使用更长的过期时间）
3. 在不使用 nginx/proxy 的情况下测试以隔离问题
4. 使用 jwt.io 解码并验证 token 结构

### 12. 生产环境中的内存泄漏

**频率**：低 | **复杂度**：高

**解决方案**：
1. 使用 node --inspect 和 Chrome DevTools 进行性能分析
2. 在 onModuleDestroy() 中移除事件监听器
3. 正确关闭数据库连接
4. 随时间监控堆快照

```typescript
@Injectable()
export class EventService implements OnModuleDestroy {
  onModuleDestroy() {
    // 清理事件监听器
    this.eventEmitter.removeAllListeners();
  }
}
```

### 13. "Nest 无法在测试中解析 PrismaService 的依赖"

**频率**：中 | **复杂度**：中

**解决方案**：
1. 在测试模块的 providers 中模拟 PrismaService
2. 使用 `mockDeep<PrismaClient>()` 完整模拟 Prisma Client API
3. 在 `beforeEach` 中重置所有 mock 调用计数

```typescript
import { mockDeep, DeepMockProxy } from 'jest-mock-extended';

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
```

### 14. Prisma 多个数据库连接

**频率**：低 | **复杂度**：中

**解决方案**：
1. 创建多个 PrismaService 实例，分别注入不同的连接配置
2. 使用不同的注入 token 区分不同数据库连接
3. 或者使用 Prisma 的 `$extends` 扩展不同数据源的行为

```typescript
@Injectable()
export class PrimaryDatabaseService extends PrismaClient {
  constructor() {
    super({ datasourceUrl: process.env.PRIMARY_DATABASE_URL });
  }
}

@Injectable()
export class SecondaryDatabaseService extends PrismaClient {
  constructor() {
    super({ datasourceUrl: process.env.SECONDARY_DATABASE_URL });
  }
}
```

### 15. Prisma Schema 验证失败

**频率**：中 | **复杂度**：低

**解决方案**：
1. 运行 `prisma validate` 检查 schema 语法
2. 运行 `prisma format` 自动格式化 schema
3. 检查 generator 块中的 provider 名称（Prisma 7 使用 `prisma-client`，Prisma 6 使用 `prisma-client-js`）
4. 验证 datasource provider 字符串是否正确

### 16. "PrismaClientKnownRequestError — 唯一约束冲突"

**频率**：高 | **复杂度**：低

**解决方案**：
1. 检查代码是否尝试创建重复记录
2. 使用 `upsert` 替代 `create` 避免冲突
3. 捕获 `PrismaClientKnownRequestError` 并检查 `error.code === 'P2002'`

```typescript
try {
  await prisma.user.create({ data: { email: 'alice@prisma.io' } });
} catch (error) {
  if (error instanceof PrismaClientKnownRequestError && error.code === 'P2002') {
    throw new ConflictException('User with this email already exists');
  }
  throw error;
}
```

### 17. Prisma 查询性能问题 — N+1 查询

**频率**：高 | **复杂度**：中

**解决方案**：
1. 使用 `include` 一次性加载关联数据，避免循环查询
2. 使用 `select` 只选择需要的字段减少数据传输
3. 启用 Prisma 查询日志分析性能瓶颈
4. 在频繁查询的字段上添加数据库索引

```typescript
// ❌ 错误：每次循环都查询关联
const users = await prisma.user.findMany();
for (const user of users) {
  const posts = await prisma.post.findMany({ where: { authorId: user.id } });
}

// ✅ 正确：使用 include 一次加载
const users = await prisma.user.findMany({
  include: { posts: true },
});
```

| 问题 | 解决方案 |
|-------|----------|
| 事件未出现 | 设置 `debug: true`，验证 `SENTRY_DSN`，检查 `instrument.ts` 是否首先导入 |
| DSN 格式错误 | 格式：`https://<key>@o<org>.ingest.sentry.io/<project>` |
| 异常未捕获 | 确保通过 `AppModule` 中的 `APP_FILTER` 注册了 `SentryGlobalFilter` |
| 自动检测未工作 | `instrument.ts` 必须是 `main.ts` 中的**第一个导入** |
| 性能分析未启动 | 需要 `tracesSampleRate > 0` + `profileSessionSampleRate > 0` + 安装 `@sentry/profiling-node` |
| `enableLogs` 未工作 | 需要 SDK ≥ 9.41.0 |
| 未显示任何追踪 | 验证 `tracesSampleRate` 已设置（不是 `undefined`） |
| 事务过多 | 降低 `tracesSampleRate` 或使用 `tracesSampler` 丢弃健康检查 |
| Fastify + GraphQL 问题 | 已知边缘情况 — GraphQL 优先使用 Express |
| 后台任务事件混合 | 将任务体包装在 `Sentry.withIsolationScope(() => { ... })` 中 |
| Prisma spans 缺失 | 在 `Sentry.init()` 中添加 `integrations: [Sentry.prismaIntegration()]` |
| ESM 语法错误 | 设置 `registerEsmLoaderHooks: false` |
| `SentryModule` 破坏检测 | 必须从 `@sentry/nestjs/setup` 导入，绝不能从 `@sentry/nestjs` 导入 |
| RPC 异常未捕获 | 添加专用的 `SentryRpcExceptionFilter` |
| WebSocket 异常未捕获 | 在 gateway handlers 上使用 `@SentryExceptionCaptured()` |
| `@SentryCron` 未触发 | Decorator 顺序很重要 — `@SentryCron` 必须放在 `@Cron` 之后 |
| TypeScript 路径别名问题 | 确保 `tsconfig.json` 中配置了 `paths` |
| `import * as Sentry` ESLint 错误 | 使用命名导入或项目的 DI proxy |
| `profilesSampleRate` 与 `profileSessionSampleRate` | 使用 `profileSessionSampleRate` + `profileLifecycle: "trace"`（SDK 10.x） |
| 每个请求出现重复 spans | 在多个模块中注册了 `SentryModule.forRoot()` |
| 配置属性未被识别 | 将新的 SDK 选项添加到配置类型定义中 |

---

## 常见陷阱

### 循环依赖
- 通过将共享逻辑提取到第三个模块来避免
- 仅将 `forwardRef()` 用作临时修复
- 考虑重新设计模块边界

### 数据库连接问题
- 始终在启动时验证连接
- 实现重试逻辑
- 使用健康检查监控状态
- 绝不在生产环境中自动同步模式

### JWT 认证问题
- 使用强 secrets（最少 32 个字符）
- 将 JwtModule secret 与 JwtStrategy secretOrKey 匹配
- 正确格式化 Authorization headers
- 设置适当的 token 过期时间

### 测试问题
- 模拟所有外部依赖
- 使用正确的 injection tokens
- 在测试中应用与生产环境相同的全局 pipes
- 在测试之间清理测试数据

### Sentry 问题
- 始终首先导入 `instrument.ts`
- 绝不重复注册 `SentryModule.forRoot()`
- 使用正确的导入（`@sentry/nestjs/setup` 用于 DI constructs）
- 使用 `withIsolationScope()` 包装后台任务

---

## 调试检查清单

- [ ] 检查 NestJS 版本兼容性
- [ ] 验证所有 providers 已在模块中注册
- [ ] 检查循环依赖
- [ ] 验证环境变量已设置
- [ ] 确保 DTOs 使用正确的 decorators
- [ ] 验证数据库连接
- [ ] 检查 JWT 配置
- [ ] 检查模块导入和导出
- [ ] 使用 Sentry `debug: true` 进行测试
- [ ] 验证 `instrument.ts` 是第一个导入
- [ ] 检查重复的 Sentry 注册
- [ ] 查看错误日志以寻找线索
