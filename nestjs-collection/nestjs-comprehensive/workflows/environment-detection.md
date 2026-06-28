# 环境检测工作流

用于检测和适配现有 NestJS 项目设置的工作流。

## 检测阶段

### 步骤 1：检测 NestJS 项目

```bash
# 检查是否为 NestJS 项目
test -f nest-cli.json && echo "NestJS CLI project detected"
grep -q "@nestjs/core" package.json && echo "NestJS framework installed"
test -f tsconfig.json && echo "TypeScript configuration found"

# 检测 NestJS 版本
grep "@nestjs/core" package.json | sed 's/.*"\([0-9\.]*\)".*/NestJS version: \1/'
```

### 步骤 2：检测数据库设置

```bash
# TypeORM
grep -q "@nestjs/typeorm" package.json && echo "TypeORM integration detected"

# Mongoose
grep -q "@nestjs/mongoose" package.json && echo "Mongoose integration detected"

# Prisma
grep -q "@prisma/client" package.json && echo "Prisma ORM detected"

# Drizzle ORM
grep -q "drizzle-orm" package.json && echo "Drizzle ORM detected"

# PostgreSQL
grep -q '"pg"' package.json && echo "PostgreSQL driver detected"

# MySQL
grep -q '"mysql2"' package.json && echo "MySQL driver detected"

# MongoDB
grep -q '"mongoose"' package.json && echo "MongoDB detected"
```

### 步骤 3：检测认证

```bash
# Passport
grep -q "@nestjs/passport" package.json && echo "Passport authentication detected"

# JWT
grep -q "@nestjs/jwt" package.json && echo "JWT authentication detected"

# Local Strategy
grep -q "passport-local" package.json && echo "Local strategy detected"

# JWT Strategy
grep -q "passport-jwt" package.json && echo "JWT strategy detected"
```

### 步骤 4：检测 HTTP 适配器

```bash
# Fastify
grep -E "FastifyAdapter|@nestjs/platform-fastify" package.json src/main.ts && echo "Fastify adapter detected"

# Express（默认）
echo "Express adapter (default)"
```

### 步骤 5：检测 GraphQL

```bash
grep -E '"@nestjs/graphql"|"apollo-server"' package.json && echo "GraphQL detected"
```

### 步骤 6：检测微服务

```bash
grep '"@nestjs/microservices"' package.json && echo "Microservices detected"
grep '"@nestjs/bull"|"@nestjs/bullmq"' package.json && echo "Bull/BullMQ queues detected"
grep '"@nestjs/schedule"' package.json && echo "Scheduled jobs detected"
```

### 步骤 7：检测 WebSockets

```bash
grep -E '"@nestjs/websockets"|"socket.io"' package.json && echo "WebSockets detected"
```

### 步骤 8：检测 Sentry

```bash
# 检查现有 Sentry
grep -i sentry package.json && echo "Sentry already installed"
ls src/instrument.ts && echo "Sentry instrument file exists"
grep -r "Sentry.init" src/main.ts src/instrument.ts && echo "Sentry initialized"

# 检查 Sentry DI 包装器
grep -rE "SENTRY.*TOKEN|SentryProxy|SentryService" src/ libs/ && echo "Sentry DI wrapper detected"
```

### 步骤 9：分析模块结构

```bash
# 列出模块
find src -name "*.module.ts" -type f | head -10

# 统计控制器数量
find src -name "*.controller.ts" -type f | wc -l

# 统计服务数量
find src -name "*.service.ts" -type f | wc -l
```

### 步骤 10：检测测试设置

```bash
# Jest
test -f jest.config.js || test -f jest.config.ts && echo "Jest configured"

# 测试脚本
grep -q '"test"' package.json && echo "Test script found"
grep -q '"test:e2e"' package.json && echo "E2E test script found"
```

---

## 适配策略

### 策略 1：匹配现有模块模式

```typescript
// 如果项目使用 repository 模式
@Injectable()
export class UsersService {
  constructor(private repo: UsersRepository) {}
}

// 如果项目使用 active record 模式
@Injectable()
export class UsersService {
  constructor(@InjectRepository(User) private repo: Repository<User>) {}
}
```

### 策略 2：遵循已建立的测试模式

```typescript
// 如果项目使用 Jest mocks
{
  provide: UsersService,
  useValue: { findAll: jest.fn() },
}

// 如果项目使用 @golevelup/ts-jest
const mockService = createMock<UsersService>();
```

### 策略 3：遵循数据库策略

```typescript
// Repository 模式
@Injectable()
class UsersRepository {
  async findById(id: string) { /* ... */ }
}

// Active record 模式
const user = await User.findOne({ where: { id } });
```

### 策略 4：使用现有的认证 Guards

```typescript
// 如果项目已有现有 guards
@UseGuards(ExistingJwtGuard, RolesGuard)
@Get('protected')
async getProtected() { /* ... */ }
```

---

## 检测命令汇总

```bash
# 完整检测脚本
echo "=== NestJS Project Detection ==="
test -f nest-cli.json && echo "✓ CLI project"
grep -q "@nestjs/core" package.json && echo "✓ Framework installed"
grep "@nestjs/core" package.json | sed 's/.*"\([0-9\.]*\)".*/Version: \1/'

echo "=== Database ==="
grep -q "@nestjs/typeorm" package.json && echo "✓ TypeORM"
grep -q "@nestjs/mongoose" package.json && echo "✓ Mongoose"
grep -q "@prisma/client" package.json && echo "✓ Prisma"
grep -q "drizzle-orm" package.json && echo "✓ Drizzle"

echo "=== Authentication ==="
grep -q "@nestjs/passport" package.json && echo "✓ Passport"
grep -q "@nestjs/jwt" package.json && echo "✓ JWT"

echo "=== Features ==="
grep -q "@nestjs/graphql" package.json && echo "✓ GraphQL"
grep -q "@nestjs/microservices" package.json && echo "✓ Microservices"
grep -q "@nestjs/schedule" package.json && echo "✓ Scheduled Jobs"
grep -q "@nestjs/bull" package.json && echo "✓ Bull Queues"

echo "=== Monitoring ==="
grep -q "@sentry/nestjs" package.json && echo "✓ Sentry"

echo "=== Testing ==="
test -f jest.config.ts && echo "✓ Jest configured"
```

---

## 安全注意事项

- **避免 watch/serve 进程**：仅使用一次性诊断
- **不要修改 package.json**：仅读取，未经确认不要安装软件包
- **保留现有模式**：适配现有代码风格，不要强制引入新模式
- **变更前先测试**：在做出更改之前始终运行现有测试
