# 验证流程工作流

完整的验证工作流，确保 NestJS 代码质量和正确性。

## 验证顺序

始终按以下顺序进行验证：

1. **类型检查** - 首先捕获类型错误
2. **单元测试** - 测试独立组件
3. **集成测试** - 测试组件间交互
4. **E2E 测试** - 测试完整的用户流程

---

## 第一阶段：类型检查

### 步骤 1：运行 TypeScript 编译器

```bash
# 检查类型错误而不输出文件
npm run build
# 或
npx tsc --noEmit
```

### 步骤 2：修复类型错误

常见类型错误及解决方案：

```typescript
// 错误：Property 'xyz' does not exist on type 'User'
// 修复：向实体添加属性或使用类型断言
interface UserWithProfile extends User {
  profile: Profile;
}

// 错误：Type 'string' is not assignable to type 'number'
// 修复：解析或转换类型
const numValue = parseInt(stringValue, 10);

// 错误：Argument of type 'X' is not assignable to parameter of type 'Y'
// 修复：检查接口兼容性或使用正确的类型
```

### 步骤 3：验证装饰器类型

```typescript
// 确保装饰器具有正确的类型
@Get(':id') // 路由模式必须是字符串
getById(@Param('id', ParseUUIDPipe) id: string) { /* ... */ }

// DTO 验证类型必须匹配
@IsEmail()
email: string; // 必须是 string，不能是 number
```

---

## 第二阶段：单元测试

### 步骤 4：运行单元测试

```bash
npm run test
# 或
npx jest
```

### 步骤 5：检查测试覆盖率

```bash
npm run test -- --coverage
```

### 步骤 6：修复失败的测试

```typescript
// 常见问题：Mock 未返回正确的类型
{
  provide: UsersService,
  useValue: {
    findById: jest.fn().mockResolvedValue({ id: 1, name: 'John' }),
  },
}

// 常见问题：异步未等待
it('should create user', async () => {
  const result = await service.create(dto); // 不要忘记 await
  expect(result).toBeDefined();
});
```

### 步骤 7：验证 Mock 设置

```typescript
// 确保所有依赖都被 mock
beforeEach(async () => {
  const module: TestingModule = await Test.createTestingModule({
    providers: [
      UsersService,
      {
        provide: UsersRepository,
        useValue: {
          findById: jest.fn(),
          create: jest.fn(),
          // Mock 服务使用的所有方法
        },
      },
    ],
  }).compile();
});
```

---

## 第三阶段：集成测试

### 步骤 8：运行集成测试

```bash
npm run test:integration
# 或
npx jest --config jest-integration.config.ts
```

### 步骤 9：验证数据库连接

```typescript
// 确保测试数据库已配置
beforeAll(async () => {
  const module: TestingModule = await Test.createTestingModule({
    imports: [
      TypeOrmModule.forRoot({
        type: 'postgres',
        url: process.env.TEST_DATABASE_URL,
        entities: [User],
        synchronize: true, // 测试中可以
      }),
      UsersModule,
    ],
  }).compile();
});

afterAll(async () => {
  // 清理数据库
  await connection.close();
});
```

### 步骤 10：测试真实交互

```typescript
it('should create and retrieve user', async () => {
  const dto = { name: 'John', email: 'john@example.com' };
  const created = await service.create(dto);

  expect(created.id).toBeDefined();
  expect(created.name).toBe(dto.name);

  const retrieved = await service.findById(created.id);
  expect(retrieved).toEqual(created);
});
```

---

## 第四阶段：E2E 测试

### 步骤 11：运行 E2E 测试

```bash
npm run test:e2e
# 或
npx jest --config test/jest-e2e.json
```

### 步骤 12：验证应用引导

```typescript
beforeAll(async () => {
  const moduleFixture: TestingModule = await Test.createTestingModule({
    imports: [AppModule],
  }).compile();

  app = moduleFixture.createNestApplication();

  // 应用与生产环境相同的配置
  app.useGlobalPipes(
    new ValidationPipe({
      whitelist: true,
      forbidNonWhitelisted: true,
      transform: true,
    }),
  );

  await app.init();
});

afterAll(async () => {
  await app.close();
});
```

### 步骤 13：测试 API 端点

```typescript
describe('POST /users', () => {
  it('should create user with valid data', () => {
    return request(app.getHttpServer())
      .post('/users')
      .send({ name: 'John', email: 'john@example.com' })
      .expect(201)
      .expect((res) => {
        expect(res.body.id).toBeDefined();
        expect(res.body.name).toBe('John');
        expect(res.body.password).toBeUndefined();
      });
  });

  it('should reject invalid email', () => {
    return request(app.getHttpServer())
      .post('/users')
      .send({ name: 'John', email: 'invalid' })
      .expect(400);
  });
});
```

---

## 第五阶段：额外检查

### 步骤 14：代码 Lint 检查

```bash
npm run lint
# 或
npx eslint src/
```

### 步骤 15：检查循环依赖

```bash
npm run build
# 注意输出中的循环依赖警告
```

### 步骤 16：验证环境变量

```bash
# 确保所有必需的环境变量已设置
echo $DATABASE_URL
echo $JWT_SECRET
echo $PORT
```

### 步骤 17：测试配置验证

```typescript
// 启动应用并验证配置验证是否正常工作
// 如果缺少必需的环境变量应该会失败
```

---

## 验证清单

### 提交代码前

- [ ] 类型检查通过（`npm run build` 或 `tsc --noEmit`）
- [ ] 所有单元测试通过（`npm run test`）
- [ ] 所有集成测试通过（`npm run test:integration`）
- [ ] 所有 E2E 测试通过（`npm run test:e2e`）
- [ ] Lint 检查通过（`npm run lint`）
- [ ] 无循环依赖
- [ ] 测试覆盖率达到阈值（如果已配置）
- [ ] 无 TypeScript `any` 类型（如果启用了严格模式）
- [ ] 所有 DTO 使用 class-validator 装饰器
- [ ] 所有 provider 已在模块中注册
- [ ] 环境变量已验证

### 部署到生产环境前

- [ ] 上述所有验证检查通过
- [ ] 构建成功（`npm run build`）
- [ ] 生产环境变量已配置
- [ ] 数据库迁移已应用
- [ ] Sentry 监控已启用
- [ ] 健康检查正常工作
- [ ] 速率限制已启用
- [ ] CORS 配置正确
- [ ] 日志已为生产环境配置

---

## 持续集成

### GitHub Actions 示例

```yaml
name: CI

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest

    services:
      postgres:
        image: postgres:14
        env:
          POSTGRES_PASSWORD: postgres
        ports:
          - 5432:5432

    steps:
      - uses: actions/checkout@v3

      - name: Setup Node.js
        uses: actions/setup-node@v3
        with:
          node-version: '18'
          cache: 'npm'

      - name: Install dependencies
        run: npm ci

      - name: Typecheck
        run: npx tsc --noEmit

      - name: Lint
        run: npm run lint

      - name: Run tests
        run: npm run test
        env:
          DATABASE_URL: postgresql://postgres:postgres@localhost:5432/test

      - name: Run E2E tests
        run: npm run test:e2e
        env:
          DATABASE_URL: postgresql://postgres:postgres@localhost:5432/test
```
