# 测试指南

NestJS 应用程序的完整测试策略，包括使用 Jest 和 Supertest 的单元测试、集成测试和 E2E 测试。

## 测试设置

### 安装测试依赖

```bash
npm i -D @nestjs/testing jest ts-jest @types/jest supertest @types/supertest
```

### Jest 配置

```typescript
// jest.config.ts
export default {
  moduleFileExtensions: ['js', 'json', 'ts'],
  rootDir: 'src',
  testRegex: '.*\\.spec\\.ts$',
  transform: {
    '^.+\\.(t|j)s$': 'ts-jest',
  },
  collectCoverageFrom: ['**/*.(t|j)s'],
  coverageDirectory: '../coverage',
  testEnvironment: 'node',
};
```

---

## 单元测试

### 使用 Mocks 测试 Services

```typescript
// src/users/users.service.spec.ts
import { Test, TestingModule } from '@nestjs/testing';
import { UsersService } from './users.service';
import { UsersRepository } from './users.repository';
import { NotFoundException } from '@nestjs/common';

describe('UsersService', () => {
  let service: UsersService;
  let repo: jest.Mocked<UsersRepository>;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        UsersService,
        {
          provide: UsersRepository,
          useValue: {
            findById: jest.fn(),
            findAll: jest.fn(),
            create: jest.fn(),
            update: jest.fn(),
            delete: jest.fn(),
          },
        },
      ],
    }).compile();

    service = module.get<UsersService>(UsersService);
    repo = module.get(UsersRepository);
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });

  describe('findById', () => {
    it('should return user when found', async () => {
      const mockUser = { id: 1, name: 'John', email: 'john@example.com' };
      repo.findById.mockResolvedValue(mockUser);

      const result = await service.findById(1);

      expect(result).toEqual(mockUser);
      expect(repo.findById).toHaveBeenCalledWith(1);
    });

    it('should throw NotFoundException when user not found', async () => {
      repo.findById.mockResolvedValue(undefined);

      await expect(service.findById(1)).rejects.toThrow(NotFoundException);
    });
  });

  describe('create', () => {
    it('should create and return user', async () => {
      const dto = { name: 'John', email: 'john@example.com' };
      const mockUser = { id: 1, ...dto, createdAt: new Date() };
      repo.create.mockResolvedValue(mockUser);

      const result = await service.create(dto);

      expect(result).toEqual(mockUser);
      expect(repo.create).toHaveBeenCalledWith(dto);
    });
  });
});
```

### 测试 Controllers

```typescript
// src/users/users.controller.spec.ts
import { Test, TestingModule } from '@nestjs/testing';
import { UsersController } from './users.controller';
import { UsersService } from './users.service';

describe('UsersController', () => {
  let controller: UsersController;
  let service: UsersService;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      controllers: [UsersController],
      providers: [
        {
          provide: UsersService,
          useValue: {
            findById: jest.fn(),
            create: jest.fn(),
          },
        },
      ],
    }).compile();

    controller = module.get<UsersController>(UsersController);
    service = module.get<UsersService>(UsersService);
  });

  describe('getById', () => {
    it('should return user by id', async () => {
      const mockUser = { id: 1, name: 'John' };
      jest.spyOn(service, 'findById').mockResolvedValue(mockUser);

      const result = await controller.getById('1');

      expect(result).toEqual(mockUser);
    });
  });
});
```

---

## 集成测试

### 使用真实依赖进行测试

```typescript
// src/users/users.integration.spec.ts
import { Test, TestingModule } from '@nestjs/testing';
import { INestApplication } from '@nestjs/common';
import { UsersModule } from './users.module';
import { DatabaseModule } from '../db/database.module';

describe('UsersService Integration', () => {
  let app: INestApplication;
  let service: UsersService;

  beforeAll(async () => {
    const module: TestingModule = await Test.createTestingModule({
      imports: [DatabaseModule, UsersModule],
    }).compile();

    app = module.createNestApplication();
    await app.init();

    service = module.get<UsersService>(UsersService);
  });

  afterAll(async () => {
    await app.close();
  });

  it('should create and retrieve user', async () => {
    const dto = { name: 'John', email: 'john@example.com' };
    const created = await service.create(dto);

    expect(created).toBeDefined();
    expect(created.name).toBe(dto.name);

    const retrieved = await service.findById(created.id);
    expect(retrieved).toEqual(created);
  });
});
```

---

## E2E 测试

### 使用 Supertest 设置 E2E 测试

```typescript
// test/users.e2e-spec.ts
import { Test, TestingModule } from '@nestjs/testing';
import { INestApplication, ValidationPipe } from '@nestjs/common';
import * as request from 'supertest';
import { UsersModule } from '../src/users/users.module';
import { DatabaseModule } from '../src/db/database.module';

describe('UsersController (e2e)', () => {
  let app: INestApplication;

  beforeAll(async () => {
    const moduleFixture: TestingModule = await Test.createTestingModule({
      imports: [DatabaseModule, UsersModule],
    }).compile();

    app = moduleFixture.createNestApplication();

    // 应用全局 pipes 以匹配生产配置
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

  describe('POST /users', () => {
    it('should create a new user', () => {
      return request(app.getHttpServer())
        .post('/users')
        .send({ name: 'John', email: 'john@example.com' })
        .expect(201)
        .expect((res) => {
          expect(res.body.id).toBeDefined();
          expect(res.body.name).toBe('John');
          expect(res.body.password).toBeUndefined(); // 确保不返回密码
        });
    });

    it('should reject invalid email', () => {
      return request(app.getHttpServer())
        .post('/users')
        .send({ name: 'John', email: 'invalid-email' })
        .expect(400);
    });

    it('should reject missing name', () => {
      return request(app.getHttpServer())
        .post('/users')
        .send({ email: 'john@example.com' })
        .expect(400);
    });
  });

  describe('GET /users/:id', () => {
    it('should return user by id', async () => {
      // 先创建用户
      const created = await request(app.getHttpServer())
        .post('/users')
        .send({ name: 'John', email: 'john@example.com' })
        .expect(201);

      const userId = created.body.id;

      return request(app.getHttpServer())
        .get(`/users/${userId}`)
        .expect(200)
        .expect((res) => {
          expect(res.body.id).toBe(userId);
        });
    });

    it('should return 404 for non-existent user', () => {
      return request(app.getHttpServer())
        .get('/users/999999')
        .expect(404);
    });
  });
});
```

### 测试受保护的端点

```typescript
describe('Authenticated Endpoints', () => {
  let authToken: string;

  beforeAll(async () => {
    // 登录获取 token
    const response = await request(app.getHttpServer())
      .post('/auth/login')
      .send({ email: 'admin@example.com', password: 'password123' });

    authToken = response.body.access_token;
  });

  it('should access protected endpoint with valid token', () => {
    return request(app.getHttpServer())
      .get('/admin/report')
      .set('Authorization', `Bearer ${authToken}`)
      .expect(200);
  });

  it('should reject request without token', () => {
    return request(app.getHttpServer())
      .get('/admin/report')
      .expect(401);
  });

  it('should reject request with invalid token', () => {
    return request(app.getHttpServer())
      .get('/admin/report')
      .set('Authorization', 'Bearer invalid-token')
      .expect(401);
  });
});
```

---

## 模拟外部服务

### 模拟 JwtService

```typescript
import { JwtService } from '@nestjs/jwt';

const mockJwtService = {
  sign: jest.fn().mockReturnValue('fake-jwt-token'),
  verify: jest.fn().mockReturnValue({ sub: 1, email: 'test@example.com' }),
};

{
  provide: JwtService,
  useValue: mockJwtService,
}
```

### 模拟 PrismaService

```typescript
import { DeepMockProxy, mockDeep } from 'jest-mock-extended';
import { PrismaClient } from '@prisma/client';
import { PrismaService } from './prisma.service';

{
  provide: PrismaService,
  useValue: mockDeep<PrismaClient>(),
}
```

### 使用 @golevelup/ts-jest

```bash
npm i -D @golevelup/ts-jest
```

```typescript
import { createMock } from '@golevelup/ts-jest';
import { UsersRepository } from './users.repository';

const mockRepo = createMock<UsersRepository>();
mockRepo.findById.mockResolvedValue({ id: 1, name: 'John' });
```

---

## 测试最佳实践

- 使用模拟的依赖项隔离测试 providers
- 为 guards、validation pipes 和 exception filters 添加请求级别测试
- 在测试中重用与生产环境相同的全局 pipes/filters
- 模拟外部依赖（数据库、APIs、services）
- 保持测试简洁最小化
- 使用描述性的测试名称
- 测试成功和失败两种场景
- 所有 async 操作必须正确 await

## 验证顺序

按以下顺序运行测试：
1. **类型检查**：`npm run build` 或 `tsc --noEmit`
2. **单元测试**：`npm run test`
3. **集成测试**：`npm run test:integration`
4. **E2E 测试**：`npm run test:e2e`
