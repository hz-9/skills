# 快速入门工作流

快速上手 NestJS 的分步工作流。

## 第一阶段：项目初始化

### 步骤 1：创建 NestJS 项目

```bash
# 使用 NestJS CLI
npm i -g @nestjs/cli
nest new project-name

# 或使用 npm
npm init nest-app project-name
```

### 步骤 2：安装核心依赖

```bash
# 核心验证和转换
npm i class-validator class-transformer

# 配置
npm i @nestjs/config

# 数据库（选择其一）
npm install prisma --save-dev && npm install @prisma/client
# 或
npm install prisma --save-dev && npm install @prisma/client
# 或
npx prisma init                         # Prisma

# 认证
npm i @nestjs/jwt @nestjs/passport passport passport-jwt
```

### 步骤 3：配置 TypeScript

```json
// tsconfig.json
{
  "compilerOptions": {
    "module": "commonjs",
    "declaration": true,
    "removeComments": true,
    "emitDecoratorMetadata": true,
    "experimentalDecorators": true,
    "allowSyntheticDefaultImports": true,
    "target": "ES2021",
    "sourceMap": true,
    "outDir": "./dist",
    "baseUrl": "./",
    "strict": true,
    "skipLibCheck": true
  }
}
```

---

## 第二阶段：项目结构

### 步骤 4：创建目录结构

```bash
mkdir -p src/{common/{filters,guards,interceptors,pipes},config,modules/{auth,users}}
```

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
└── modules/
    ├── auth/
    └── users/
```

---

## 第三阶段：引导应用

### 步骤 5：配置引导程序

```typescript
// src/main.ts
import { NestFactory } from '@nestjs/core';
import { ValidationPipe, ClassSerializerInterceptor } from '@nestjs/common';
import { Reflector } from '@nestjs/core';
import { AppModule } from './app.module';

async function bootstrap() {
  const app = await NestFactory.create(AppModule, { bufferLogs: true });

  // 全局验证
  app.useGlobalPipes(
    new ValidationPipe({
      whitelist: true,
      forbidNonWhitelisted: true,
      transform: true,
      transformOptions: { enableImplicitConversion: true },
    }),
  );

  // 全局序列化
  app.useGlobalInterceptors(new ClassSerializerInterceptor(app.get(Reflector)));

  // 如需则启用 CORS
  app.enableCors({
    origin: process.env.FRONTEND_URL,
    credentials: true,
  });

  // 优雅关闭
  app.enableShutdownHooks();

  const port = process.env.PORT ?? 3000;
  await app.listen(port);
  console.log(`Application running on: http://localhost:${port}`);
}
bootstrap();
```

### 步骤 6：配置环境

```typescript
// src/config/configuration.ts
export default () => ({
  port: parseInt(process.env.PORT, 10) || 3000,
  database: {
    url: process.env.DATABASE_URL,
  },
  jwt: {
    secret: process.env.JWT_SECRET,
    expiresIn: process.env.JWT_EXPIRES_IN || '1h',
  },
});

// src/config/validation.ts
import { plainToClass } from 'class-transformer';
import { IsNumber, IsString, validateSync } from 'class-validator';

export class EnvironmentVariables {
  @IsNumber()
  PORT: number;

  @IsString()
  DATABASE_URL: string;

  @IsString()
  JWT_SECRET: string;
}

export function validateEnv(config: Record<string, unknown>) {
  const validatedConfig = plainToClass(EnvironmentVariables, config, {
    enableImplicitConversion: true,
  });

  const errors = validateSync(validatedConfig, { skipMissingProperties: false });
  if (errors.length > 0) {
    throw new Error(errors.toString());
  }

  return validatedConfig;
}
```

---

## 第四阶段：创建第一个模块

### 步骤 7：生成模块

```bash
nest generate module users
nest generate controller users
nest generate service users
```

### 步骤 8：定义 DTO

```typescript
// src/modules/users/dto/create-user.dto.ts
import { IsEmail, IsString, Length } from 'class-validator';

export class CreateUserDto {
  @IsEmail()
  email!: string;

  @IsString()
  @Length(2, 80)
  name!: string;
}
```

### 步骤 9：创建 Service

```typescript
// src/modules/users/users.service.ts
import { Injectable } from '@nestjs/common';
import { CreateUserDto } from './dto/create-user.dto';

@Injectable()
export class UsersService {
  private users: any[] = []; // 替换为数据库

  async create(dto: CreateUserDto) {
    const user = { id: Date.now(), ...dto };
    this.users.push(user);
    return user;
  }

  async findAll() {
    return this.users;
  }
}
```

### 步骤 10：创建 Controller

```typescript
// src/modules/users/users.controller.ts
import { Controller, Get, Post, Body } from '@nestjs/common';
import { UsersService } from './users.service';
import { CreateUserDto } from './dto/create-user.dto';

@Controller('users')
export class UsersController {
  constructor(private readonly usersService: UsersService) {}

  @Get()
  findAll() {
    return this.usersService.findAll();
  }

  @Post()
  create(@Body() dto: CreateUserDto) {
    return this.usersService.create(dto);
  }
}
```

---

## 第五阶段：添加数据库

### 步骤 11：配置数据库（Prisma 示例）

```bash
# 安装 Prisma
npm install prisma --save-dev
npm install @prisma/client

# 初始化 Prisma（创建 prisma/schema.prisma 和 prisma.config.ts）
npx prisma init --datasource-provider postgresql
```

```prisma
// prisma/schema.prisma
generator client {
  provider = "prisma-client"
  output   = "../generated"
}

datasource db {
  provider = "postgresql"
  url      = env("DATABASE_URL")
}

model User {
  id        String   @id @default(cuid())
  email     String   @unique
  name      String
  createdAt DateTime @default(now())
}
```

### 步骤 12：生成 Prisma Client 并运行迁移

```bash
# 生成 Prisma Client
npx prisma generate

# 创建并应用迁移
npx prisma migrate dev --name init
```

---

## 第六阶段：添加认证

### 步骤 13：配置 JWT

```typescript
// src/modules/auth/auth.module.ts
import { Module } from '@nestjs/common';
import { JwtModule } from '@nestjs/jwt';
import { ConfigModule, ConfigService } from '@nestjs/config';

@Module({
  imports: [
    JwtModule.registerAsync({
      imports: [ConfigModule],
      useFactory: async (configService: ConfigService) => ({
        secret: configService.get<string>('JWT_SECRET'),
        signOptions: { expiresIn: '1h' },
      }),
      inject: [ConfigService],
    }),
  ],
})
export class AuthModule {}
```

---

## 第七阶段：测试应用

### 步骤 14：运行开发服务器

```bash
npm run start:dev
```

### 步骤 15：测试接口

```bash
# 创建用户
curl -X POST http://localhost:3000/users \
  -H "Content-Type: application/json" \
  -d '{"name":"John","email":"john@example.com"}'

# 获取所有用户
curl http://localhost:3000/users
```

---

## 后续步骤

- 添加 Sentry 监控：参见 [references/sentry-integration.md](../references/sentry-integration.md)
- 实现完整认证：参见 [references/authentication-security.md](../references/authentication-security.md)
- 添加测试：参见 [references/testing-guide.md](../references/testing-guide.md)
- 优化性能：参见 [references/performance-optimization.md](../references/performance-optimization.md)
- 部署到生产环境：参见 [deployment-guide.md](deployment-guide.md)
