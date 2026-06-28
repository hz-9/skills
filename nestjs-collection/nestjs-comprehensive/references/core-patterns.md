# 核心架构模式

NestJS 核心架构模式完整指南，包括模块组织、Controllers、Providers、DTOs、Guards、Interceptors、Pipes 以及项目结构。

## 项目结构

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

### 组织规则

- 将领域代码保留在功能模块内部
- 将跨切面的 filters、decorators、guards 和 interceptors 放在 `common/` 中
- 将 DTOs 放在拥有它们的模块附近

## 启动与全局配置

```typescript
import { NestFactory } from '@nestjs/core';
import { ValidationPipe, ClassSerializerInterceptor } from '@nestjs/common';
import { Reflector } from '@nestjs/core';
import { AppModule } from './app.module';
import { HttpExceptionFilter } from './common/filters/http-exception.filter';

async function bootstrap() {
  const app = await NestFactory.create(AppModule, { bufferLogs: true });

  // 全局验证管道
  app.useGlobalPipes(
    new ValidationPipe({
      whitelist: true,
      forbidNonWhitelisted: true,
      transform: true,
      transformOptions: { enableImplicitConversion: true },
    }),
  );

  // 全局序列化拦截器
  app.useGlobalInterceptors(new ClassSerializerInterceptor(app.get(Reflector)));

  // 全局异常过滤器
  app.useGlobalFilters(new HttpExceptionFilter());

  const port = process.env.PORT ?? 3000;
  await app.listen(port);
  console.log(`Application is running on: http://localhost:${port}`);
}
bootstrap();
```

### 关键点

- 在公共 API 上始终启用 `whitelist` 和 `forbidNonWhitelisted`
- 优先使用一个全局验证管道，而不是在每个路由上重复配置验证
- 为零停机部署启用优雅关闭：`app.enableShutdownHooks()`

## 模块组织

### 功能模块模式

```typescript
import { Module } from '@nestjs/common';
import { UsersController } from './users.controller';
import { UsersService } from './users.service';
import { UsersRepository } from './users.repository';

@Module({
  controllers: [UsersController],
  providers: [UsersService, UsersRepository],
  exports: [UsersService], // 仅导出其他模块需要的内容
})
export class UsersModule {}
```

### 模块指南

- Controllers 应保持精简：解析 HTTP 输入、调用 provider、返回响应 DTOs
- 将业务逻辑放在可注入的 services 中，而不是 controllers 中
- 仅导出其他模块真正需要的 providers
- 按功能组织，而非按技术层组织

## Controllers

```typescript
import {
  Controller,
  Get,
  Post,
  Patch,
  Delete,
  Param,
  Body,
  ParseUUIDPipe,
} from '@nestjs/common';
import { UsersService } from './users.service';
import { CreateUserDto } from './dto/create-user.dto';
import { UpdateUserDto } from './dto/update-user.dto';

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

  @Patch(':id')
  update(@Param('id', ParseUUIDPipe) id: string, @Body() dto: UpdateUserDto) {
    return this.usersService.update(id, dto);
  }

  @Delete(':id')
  delete(@Param('id', ParseUUIDPipe) id: string) {
    return this.usersService.delete(id);
  }
}
```

## Services 与 Repository 模式

```typescript
import { Injectable } from '@nestjs/common';
import { UsersRepository } from './users.repository';
import { CreateUserDto } from './dto/create-user.dto';
import { UpdateUserDto } from './dto/update-user.dto';

@Injectable()
export class UsersService {
  constructor(private readonly usersRepo: UsersRepository) {}

  async create(dto: CreateUserDto) {
    return this.usersRepo.create(dto);
  }

  async getById(id: string) {
    const user = await this.usersRepo.findById(id);
    if (!user) {
      throw new NotFoundException(`User with ID ${id} not found`);
    }
    return user;
  }

  async update(id: string, dto: UpdateUserDto) {
    return this.usersRepo.update(id, dto);
  }

  async delete(id: string) {
    return this.usersRepo.delete(id);
  }
}
```

## DTOs 与验证

```typescript
import { IsEmail, IsString, Length, IsOptional, IsEnum } from 'class-validator';

export enum UserRole {
  ADMIN = 'admin',
  USER = 'user',
  MODERATOR = 'moderator',
}

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

export class UpdateUserDto {
  @IsOptional()
  @IsEmail()
  email?: string;

  @IsOptional()
  @IsString()
  @Length(2, 80)
  name?: string;
}
```

### 验证规则

- 使用 `class-validator` 验证每个请求 DTO
- 使用专用的响应 DTOs 或 serializers，而不是直接返回 ORM entities
- 避免泄露内部字段，如密码哈希、tokens 或审计列

## 认证、Guards 与请求上下文

```typescript
import { UseGuards, Get, Req } from '@nestjs/common';
import { JwtAuthGuard } from '../common/guards/jwt-auth.guard';
import { RolesGuard } from '../common/guards/roles.guard';
import { Roles } from '../common/decorators/roles.decorator';

interface AuthenticatedRequest extends Request {
  user: {
    id: string;
    email: string;
    roles: string[];
  };
}

@UseGuards(JwtAuthGuard, RolesGuard)
@Roles('admin')
@Get('admin/report')
getAdminReport(@Req() req: AuthenticatedRequest) {
  return this.reportService.getForUser(req.user.id);
}
```

### Guard 指南

- 除非 auth strategies 和 guards 真正共享，否则将它们保留在模块局部
- 在 guards 中编码粗略的访问规则，然后在 services 中进行资源特定的授权
- 优先为已认证的请求对象使用显式的请求类型

## 异常过滤器

```typescript
import {
  Catch,
  ArgumentsHost,
  ExceptionFilter,
  HttpException,
} from '@nestjs/common';
import { Request, Response } from 'express';

@Catch()
export class HttpExceptionFilter implements ExceptionFilter {
  catch(exception: unknown, host: ArgumentsHost) {
    const ctx = host.switchToHttp();
    const response = ctx.getResponse<Response>();
    const request = ctx.getRequest<Request>();

    if (exception instanceof HttpException) {
      const status = exception.getStatus();
      const errorResponse = exception.getResponse();

      return response.status(status).json({
        statusCode: status,
        timestamp: new Date().toISOString(),
        path: request.url,
        error: errorResponse,
      });
    }

    // 处理意外错误
    console.error('Unhandled exception:', exception);

    return response.status(500).json({
      statusCode: 500,
      timestamp: new Date().toISOString(),
      path: request.url,
      error: 'Internal server error',
    });
  }
}
```

### 错误处理规则

- 在整个 API 中保持一致的错误信封格式
- 对预期的客户端错误抛出框架异常
- 集中记录和包装意外失败

## 配置与环境验证

```typescript
import { ConfigModule } from '@nestjs/config';
import { configuration } from './config/configuration';
import { validateEnv } from './config/validation';

// 在 AppModule 中
@Module({
  imports: [
    ConfigModule.forRoot({
      isGlobal: true,
      load: [configuration],
      validate: validateEnv,
    }),
    // ... 其他模块
  ],
})
export class AppModule {}
```

### 配置规则

- 在启动时验证 env，而不是在第一次请求时惰性验证
- 通过类型化 helpers 或 config services 访问配置
- 在 config factories 中拆分 dev/staging/prod 关注点，而不是在功能代码中到处分支

## 请求生命周期

执行顺序：**Middleware → Guards → Interceptors (before) → Pipes → Route handler → Interceptors (after) → Filters**

## 生产默认值

- 启用结构化日志记录和请求关联 ID
- 在无效的 env/config 时终止而不是部分启动
- 对带有显式健康检查的 DB/cache 客户端优先使用 async provider 初始化
- 将后台任务和事件消费者放在它们自己的模块中，而不是 HTTP controllers 内部
- 为公共端点显式启用 rate limiting、auth 和审计日志
