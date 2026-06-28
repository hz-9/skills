# NestJS 模式

使用 Drizzle ORM 进行 NestJS 开发的详细代码模式。

## 核心架构

### 模块结构
```typescript
import { Module } from '@nestjs/common';

@Module({
  imports: [/* 其他模块 */],
  controllers: [/* 控制器 */],
  providers: [/* 提供者 */],
  exports: [/* 导出的提供者 */],
})
export class FeatureModule {}
```

### 控制器模式
```typescript
import { Controller, Get, Post, Body, Param, Query } from '@nestjs/common';

@Controller('users')
export class UsersController {
  @Get()
  findAll(@Query() query: any) {
    return '返回所有用户';
  }

  @Get(':id')
  findOne(@Param('id') id: string) {
    return `返回用户 #${id}`;
  }

  @Post()
  create(@Body() createUserDto: any) {
    return '创建用户';
  }
}
```

### 带依赖注入的服务
```typescript
import { Injectable } from '@nestjs/common';

@Injectable()
export class UsersService {
  constructor(/* 注入依赖 */) {}

  findAll() {
    return '用户服务逻辑';
  }
}
```

## 使用 Drizzle 的数据库集成

### 安装
```bash
# 使用 npm
npm install drizzle-orm pg
npm install -D drizzle-kit tsx @types/pg

# 使用 yarn
yarn add drizzle-orm pg
yarn add -D drizzle-kit tsx @types/pg
```

### 配置
```typescript
// drizzle.config.ts
import 'dotenv/config';
import { defineConfig } from 'drizzle-kit';

export default defineConfig({
  out: './drizzle',
  schema: './src/db/schema.ts',
  dialect: 'postgresql',
  dbCredentials: {
    url: process.env.DATABASE_URL!,
  },
});
```

### 数据库 Schema
```typescript
// src/db/schema.ts
import { pgTable, serial, text, timestamp } from 'drizzle-orm/pg-core';

export const users = pgTable('users', {
  id: serial('id').primaryKey(),
  name: text('name').notNull(),
  email: text('email').notNull().unique(),
  createdAt: timestamp('created_at').defaultNow(),
});
```

### 数据库服务
```typescript
// src/db/database.service.ts
import { Injectable } from '@nestjs/common';
import { drizzle } from 'drizzle-orm/node-postgres';
import { Pool } from 'pg';
import * as schema from './schema';

@Injectable()
export class DatabaseService {
  private db: ReturnType<typeof drizzle>;

  constructor() {
    const pool = new Pool({
      connectionString: process.env.DATABASE_URL,
    });
    this.db = drizzle(pool, { schema });
  }

  get database() {
    return this.db;
  }
}
```

### 使用 Drizzle 的用户仓库
```typescript
// src/users/user.repository.ts
import { Injectable } from '@nestjs/common';
import { DatabaseService } from '../db/database.service';
import { users } from '../db/schema';
import { eq } from 'drizzle-orm';

@Injectable()
export class UserRepository {
  constructor(private db: DatabaseService) {}

  async findAll() {
    return this.db.database.select().from(users);
  }

  async findOne(id: number) {
    const result = await this.db.database
      .select()
      .from(users)
      .where(eq(users.id, id))
      .limit(1);
    return result[0];
  }

  async create(data: typeof users.$inferInsert) {
    const result = await this.db.database
      .insert(users)
      .values(data)
      .returning();
    return result[0];
  }

  async update(id: number, data: Partial<typeof users.$inferInsert>) {
    const result = await this.db.database
      .update(users)
      .set(data)
      .where(eq(users.id, id))
      .returning();
    return result[0];
  }

  async remove(id: number) {
    const result = await this.db.database
      .delete(users)
      .where(eq(users.id, id))
      .returning();
    return result[0];
  }
}
```

### 完整的用户模块
```typescript
// src/users/users.module.ts
import { Module } from '@nestjs/common';
import { UsersController } from './users.controller';
import { UsersService } from './users.service';
import { UserRepository } from './user.repository';
import { DatabaseService } from '../db/database.service';

@Module({
  controllers: [UsersController],
  providers: [UsersService, UserRepository, DatabaseService],
  exports: [UsersService],
})
export class UsersModule {}
```

### 用户服务实现
```typescript
// src/users/users.service.ts
import { Injectable } from '@nestjs/common';
import { UserRepository } from './user.repository';
import { User } from './interfaces/user.interface';

@Injectable()
export class UsersService {
  constructor(private userRepository: UserRepository) {}

  async findAll(): Promise<User[]> {
    return this.userRepository.findAll();
  }

  async findOne(id: number): Promise<User> {
    const user = await this.userRepository.findOne(id);
    if (!user) {
      throw new Error('用户未找到');
    }
    return user;
  }

  async create(userData: Partial<User>): Promise<User> {
    return this.userRepository.create(userData);
  }

  async update(id: number, userData: Partial<User>): Promise<User> {
    await this.findOne(id); // 验证用户存在
    return this.userRepository.update(id, userData);
  }

  async remove(id: number): Promise<User> {
    await this.findOne(id); // 验证用户存在
    return this.userRepository.remove(id);
  }
}
```

## 认证与授权

### JWT 认证守卫
```typescript
import { Injectable, CanActivate, ExecutionContext } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';

@Injectable()
export class JwtAuthGuard implements CanActivate {
  constructor(private jwtService: JwtService) {}

  canActivate(context: ExecutionContext) {
    const request = context.switchToHttp().getRequest();
    const token = request.headers.authorization?.split(' ')[1];

    if (!token) {
      return false;
    }

    try {
      const decoded = this.jwtService.verify(token);
      request.user = decoded;
      return true;
    } catch {
      return false;
    }
  }
}
```

### 基于角色的守卫
```typescript
import { Injectable, CanActivate, ExecutionContext } from '@nestjs/common';
import { Reflector } from '@nestjs/core';

@Injectable()
export class RolesGuard implements CanActivate {
  constructor(private reflector: Reflector) {}

  canActivate(context: ExecutionContext): boolean {
    const requiredRoles = this.reflector.get<string[]>('roles', context.getHandler());
    if (!requiredRoles) {
      return true;
    }

    const { user } = context.switchToHttp().getRequest();
    return requiredRoles.some((role) => user.roles?.includes(role));
  }
}
```

## 使用管道的验证

### 验证管道
```typescript
import { PipeTransform, Injectable, ArgumentMetadata, BadRequestException } from '@nestjs/common';
import { validate } from 'class-validator';
import { plainToClass } from 'class-transformer';

@Injectable()
export class ValidationPipe implements PipeTransform {
  async transform(value: any, { metatype }: ArgumentMetadata) {
    if (!metatype || !this.toValidate(metatype)) {
      return value;
    }

    const object = plainToClass(metatype, value);
    const errors = await validate(object);

    if (errors.length > 0) {
      throw new BadRequestException(errors);
    }

    return value;
  }

  private toValidate(metatype: Function): boolean {
    const types: Function[] = [String, Boolean, Number, Array, Object];
    return !types.includes(metatype);
  }
}
```

## 异常处理

### 全局异常过滤器
```typescript
import { ExceptionFilter, Catch, ArgumentsHost, HttpException } from '@nestjs/common';
import { Request, Response } from 'express';

@Catch(HttpException)
export class HttpExceptionFilter implements ExceptionFilter {
  catch(exception: HttpException, host: ArgumentsHost) {
    const ctx = host.switchToHttp();
    const response = ctx.getResponse<Response>();
    const request = ctx.getRequest<Request>();
    const status = exception.getStatus();

    response.status(status).json({
      statusCode: status,
      timestamp: new Date().toISOString(),
      path: request.url,
      message: exception.message,
    });
  }
}
```

## 配置管理

### 环境配置
```typescript
// src/config/configuration.ts
export default () => ({
  database: {
    url: process.env.DATABASE_URL,
  },
  jwt: {
    secret: process.env.JWT_SECRET || 'default-secret',
    expiresIn: process.env.JWT_EXPIRES_IN || '24h',
  },
  app: {
    port: parseInt(process.env.PORT, 10) || 3000,
  },
});
```

## 高级模式

### 自定义装饰器
```typescript
import { createParamDecorator, ExecutionContext } from '@nestjs/common';

export const User = createParamDecorator(
  (data: string, ctx: ExecutionContext) => {
    const request = ctx.switchToHttp().getRequest();
    const user = request.user;

    return data ? user?.[data] : user;
  },
);
```

### 日志拦截器
```typescript
import { Injectable, NestInterceptor, ExecutionContext, CallHandler } from '@nestjs/common';
import { Observable } from 'rxjs';
import { tap } from 'rxjs/operators';

@Injectable()
export class LoggingInterceptor implements NestInterceptor {
  intercept(context: ExecutionContext, next: CallHandler): Observable<any> {
    const request = context.switchToHttp().getRequest();
    const { method, url } = request;
    const now = Date.now();

    console.log(`[${method}] ${url} - 开始`);

    return next
      .handle()
      .pipe(
        tap(() => console.log(`[${method}] ${url} - 结束 ${Date.now() - now}ms`)),
      );
  }
}
```

## 微服务

### TCP 微服务
```typescript
// main.ts
import { NestFactory } from '@nestjs/core';
import { Transport, MicroserviceOptions } from '@nestjs/microservices';
import { AppModule } from './app.module';

async function bootstrap() {
  const app = await NestFactory.createMicroservice<MicroserviceOptions>(
    AppModule,
    {
      transport: Transport.TCP,
      options: {
        host: 'localhost',
        port: 8877,
      },
    },
  );
  await app.listen();
}
bootstrap();
```

## GraphQL 集成

### 使用 Drizzle 的 GraphQL 解析器
```typescript
import { Resolver, Query, Mutation, Args } from '@nestjs/graphql';
import { UserRepository } from './user.repository';

@Resolver(() => User)
export class UsersResolver {
  constructor(private userRepository: UserRepository) {}

  @Query(() => [User])
  async users() {
    return this.userRepository.findAll();
  }

  @Mutation(() => User)
  async createUser(@Args('input') input: CreateUserInput) {
    return this.userRepository.create(input);
  }
}
```

## Drizzle 的常用模式

### 事务
```typescript
async transferFunds(fromId: number, toId: number, amount: number) {
  return this.db.database.transaction(async (tx) => {
    // 从账户扣款
    await tx
      .update(accounts)
      .set({ balance: sql`${accounts.balance} - ${amount}` })
      .where(eq(accounts.id, fromId));

    // 向账户入款
    await tx
      .update(accounts)
      .set({ balance: sql`${accounts.balance} + ${amount}` })
      .where(eq(accounts.id, toId));
  });
}
```

### 软删除
```typescript
export const users = pgTable('users', {
  id: serial('id').primaryKey(),
  name: text('name').notNull(),
  email: text('email').notNull().unique(),
  deletedAt: timestamp('deleted_at'),
});

async softDelete(id: number) {
  return this.db.database
    .update(users)
    .set({ deletedAt: new Date() })
    .where(eq(users.id, id));
}
```

### 带关联的复杂查询
```typescript
async getUsersWithPosts() {
  return this.db.database
    .select()
    .from(users)
    .leftJoin(posts, eq(posts.userId, users.id));
}
```
