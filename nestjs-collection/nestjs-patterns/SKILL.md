---
name: nestjs-patterns
description: 用于模块、控制器、提供者、DTO 验证、守卫、拦截器、配置和生产级 TypeScript 后端的 NestJS 架构模式。
origin: ECC
---

# NestJS 开发模式

用于模块化 TypeScript 后端的生产级 NestJS 模式。

## 何时激活

- 构建 NestJS API 或服务
- 组织模块、控制器和提供者
- 添加 DTO 验证、守卫、拦截器或异常过滤器
- 配置环境感知设置和数据库集成
- 测试 NestJS 单元或 HTTP 端点

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

- 将领域代码保持在功能模块内部。
- 将横切关注点的过滤器、装饰器、守卫和拦截器放在 `common/` 中。
- 将 DTO 放在所属模块附近。

## 启动与全局验证

```ts
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

- 始终在公共 API 上启用 `whitelist` 和 `forbidNonWhitelisted`。
- 优先使用一个全局验证管道，而不是在每个路由重复配置验证。

## 模块、控制器和提供者

```ts
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

- 控制器应保持精简：解析 HTTP 输入，调用提供者，返回响应 DTO。
- 将业务逻辑放在可注入的服务中，而不是控制器中。
- 只导出其他模块真正需要的提供者。

## DTO 和验证

```ts
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

- 使用 `class-validator` 验证每个请求 DTO。
- 使用专用的响应 DTO 或序列化器，而不是直接返回 ORM 实体。
- 避免泄露内部字段，如密码哈希、令牌或审计列。

## 认证、守卫和请求上下文

```ts
@UseGuards(JwtAuthGuard, RolesGuard)
@Roles('admin')
@Get('admin/report')
getAdminReport(@Req() req: AuthenticatedRequest) {
  return this.reportService.getForUser(req.user.id);
}
```

- 保持认证策略和守卫在模块级别，除非它们确实是共享的。
- 在守卫中编码粗粒度的访问规则，然后在服务中进行资源特定的授权。
- 对已认证的请求对象，优先使用显式的请求类型。

## 异常过滤器和错误格式

```ts
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

- 在整个 API 中保持一致的错误格式。
- 对预期的客户端错误抛出框架异常；对非预期的失败进行日志记录并在中心位置包装。

## 配置和环境验证

```ts
ConfigModule.forRoot({
  isGlobal: true,
  load: [configuration],
  validate: validateEnv,
});
```

- 在启动时验证环境变量，而不是在第一次请求时延迟验证。
- 通过类型化的辅助函数或配置服务访问配置。
- 在配置工厂中分离开发/预发布/生产环境的关注点，而不是在功能代码中分支。

## 持久化和事务

- 保持存储库 / ORM 代码位于使用领域语言表达的提供者之后。
- 对于 Prisma 或 TypeORM，在拥有工作单元的服务中隔离事务工作流。
- 不要让控制器直接协调多步骤写入操作。

## 测试

```ts
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

- 使用模拟依赖关系隔离测试提供者。
- 为守卫、验证管道和异常过滤器添加请求级别的测试。
- 在测试中复用与生产环境相同的全局管道/过滤器。

## 生产环境默认配置

- 启用结构化日志和请求关联 ID。
- 在环境变量/配置无效时终止，而不是部分启动。
- 优先使用带显式健康检查的异步提供者初始化数据库/缓存客户端。
- 将后台任务和事件消费者放在各自的模块中，而不是放在 HTTP 控制器内。
- 对公共端点明确配置速率限制、认证和审计日志。
