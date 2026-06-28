# NestJS 测试模式

使用 Drizzle ORM 的 NestJS 应用程序的单元测试和端到端测试模式。

## 服务单元测试

```typescript
import { Test, TestingModule } from '@nestjs/testing';
import { UsersService } from './users.service';
import { UserRepository } from './user.repository';

describe('UsersService', () => {
  let service: UsersService;
  let repository: jest.Mocked<UserRepository>;

  beforeEach(async () => {
    const mockRepository = {
      findAll: jest.fn(),
      findOne: jest.fn(),
      create: jest.fn(),
      update: jest.fn(),
      remove: jest.fn(),
    } as any;

    const module: TestingModule = await Test.createTestingModule({
      providers: [
        UsersService,
        {
          provide: UserRepository,
          useValue: mockRepository,
        },
      ],
    }).compile();

    service = module.get<UsersService>(UsersService);
    repository = module.get(UserRepository);
  });

  it('应返回所有用户', async () => {
    const expectedUsers = [{ id: 1, name: 'John', email: 'john@example.com' }];
    repository.findAll.mockResolvedValue(expectedUsers);

    const result = await service.findAll();
    expect(result).toEqual(expectedUsers);
    expect(repository.findAll).toHaveBeenCalled();
  });
});
```

## 使用 Drizzle 的端到端测试

```typescript
import { Test, TestingModule } from '@nestjs/testing';
import { INestApplication } from '@nestjs/common';
import * as request from 'supertest';
import { AppModule } from './../src/app.module';
import { DatabaseService } from '../src/db/database.service';
import { drizzle } from 'drizzle-orm/node-postgres';
import { migrate } from 'drizzle-orm/node-postgres/migrator';

describe('UsersController (e2e)', () => {
  let app: INestApplication;
  let db: DatabaseService;

  beforeAll(async () => {
    const moduleFixture: TestingModule = await Test.createTestingModule({
      imports: [AppModule],
    }).compile();

    app = moduleFixture.createNestApplication();
    db = moduleFixture.get<DatabaseService>(DatabaseService);

    // 运行迁移
    await migrate(db.database, { migrationsFolder: './drizzle' });

    await app.init();
  });

  afterAll(async () => {
    await app.close();
  });

  beforeEach(async () => {
    // 清理数据库
    await db.database.delete(users).execute();
  });

  it('/users (POST)', () => {
    const createUserDto = {
      name: '测试用户',
      email: 'test@example.com',
    };

    return request(app.getHttpServer())
      .post('/users')
      .send(createUserDto)
      .expect(201)
      .expect((res) => {
        expect(res.body).toMatchObject(createUserDto);
        expect(res.body).toHaveProperty('id');
      });
  });

  it('/users (GET)', async () => {
    // 先创建一个用户
    await db.database.insert(users).values({
      name: '测试用户',
      email: 'test@example.com',
    });

    return request(app.getHttpServer())
      .get('/users')
      .expect(200)
      .expect((res) => {
        expect(Array.isArray(res.body)).toBe(true);
        expect(res.body).toHaveLength(1);
      });
  });
});
```

## 测试最佳实践

1. **模拟外部依赖** - 使用 Jest 模拟仓库和服务
2. **在测试之间清理数据库** - 使用 `beforeEach` 重置状态
3. **在端到端测试中运行迁移** - 确保 schema 是最新的
4. **测试边界情况** - 错误场景和验证失败
5. **使用 supertest 进行 HTTP 断言** - 测试端点的简洁 API
