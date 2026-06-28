# NestJS 框架文档

NestJS 是一个渐进式 Node.js 框架，用于构建高效、可靠且可扩展的服务端应用程序。它使用 TypeScript 构建，完全支持 TypeScript 和 JavaScript，结合了面向对象编程（OOP）、函数式编程（FP）和函数式响应式编程（FRP）的元素。在底层，NestJS 使用健壮的 HTTP 服务器框架，如 Express（默认）或 Fastify，在提供抽象层的同时直接向开发者暴露其 API。

该框架提供了受 Angular 启发的开箱即用应用程序架构，使开发者能够创建高度可测试、可扩展、松耦合且易于维护的应用程序。NestJS 利用依赖注入、装饰器、模块、守卫、拦截器和管道来有效组织代码。它支持多种微服务传输层，通过 TypeORM 和 Sequelize 无缝集成数据库，并为 GraphQL 和 OpenAPI 文档提供一流的支持。

## 核心构建块

### 创建基本应用

```typescript
import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';

async function bootstrap() {
 const app = await NestFactory.create(AppModule);
 await app.listen(process.env.PORT ?? 3000);
}
bootstrap();
```

### 控制器 - HTTP 请求处理

```typescript
import { Controller, Get, Post, Put, Delete, Body, Param, Query } from '@nestjs/common';
import { CreateCatDto, UpdateCatDto } from './dto';
import { CatsService } from './cats.service';

@Controller('cats')
export class CatsController {
 constructor(private catsService: CatsService) {}

 @Post()
 async create(@Body() createCatDto: CreateCatDto) {
 this.catsService.create(createCatDto);
 return { message: '猫已成功创建' };
 }

 @Get()
 async findAll(@Query('age') age?: number, @Query('breed') breed?: string) {
 return this.catsService.findAll({ age, breed });
 }

 @Get(':id')
 async findOne(@Param('id') id: string) {
 return this.catsService.findOne(id);
 }

 @Put(':id')
 async update(@Param('id') id: string, @Body() updateCatDto: UpdateCatDto) {
 return this.catsService.update(id, updateCatDto);
 }

 @Delete(':id')
 async remove(@Param('id') id: string) {
 await this.catsService.remove(id);
 return { message: '猫已成功删除' };
 }
}
```

### 提供者 - 业务逻辑和服务

```typescript
import { Injectable } from '@nestjs/common';
import { Cat } from './interfaces/cat.interface';

@Injectable()
export class CatsService {
 private readonly cats: Cat[] = [];

 create(cat: Cat): void {
 this.cats.push(cat);
 }

 findAll(filter?: { age?: number; breed?: string }): Cat[] {
 if (!filter) return this.cats;

 return this.cats.filter(cat => {
 if (filter.age && cat.age !== filter.age) return false;
 if (filter.breed && cat.breed !== filter.breed) return false;
 return true;
 });
 }

 findOne(id: string): Cat | undefined {
 return this.cats.find(cat => cat.id === id);
 }

 update(id: string, updateData: Partial): Cat {
 const catIndex = this.cats.findIndex(cat => cat.id === id);
 if (catIndex === -1) throw new Error('猫未找到');

 this.cats[catIndex] = { ...this.cats[catIndex], ...updateData };
 return this.cats[catIndex];
 }

 remove(id: string): void {
 const catIndex = this.cats.findIndex(cat => cat.id === id);
 if (catIndex === -1) throw new Error('猫未找到');
 this.cats.splice(catIndex, 1);
 }
}
```

### 模块 - 应用程序组织

```typescript
import { Module } from '@nestjs/common';
import { CatsController } from './cats.controller';
import { CatsService } from './cats.service';

@Module({
 controllers: [CatsController],
 providers: [CatsService],
 exports: [CatsService], // 使服务可被其他模块使用
})
export class CatsModule {}

// 根模块
import { Module } from '@nestjs/common';
import { CatsModule } from './cats/cats.module';
import { DogsModule } from './dogs/dogs.module';

@Module({
 imports: [CatsModule, DogsModule],
})
export class AppModule {}
```

## 中间件

### 基于类的中间件

```typescript
import { Injectable, NestMiddleware } from '@nestjs/common';
import { Request, Response, NextFunction } from 'express';

@Injectable()
export class LoggerMiddleware implements NestMiddleware {
 use(req: Request, res: Response, next: NextFunction) {
 console.log(`[${new Date().toISOString()}] ${req.method} ${req.path}`);
 next();
 }
}

// 在模块中应用
import { Module, NestModule, MiddlewareConsumer, RequestMethod } from '@nestjs/common';

@Module({
 imports: [CatsModule],
})
export class AppModule implements NestModule {
 configure(consumer: MiddlewareConsumer) {
 consumer
 .apply(LoggerMiddleware)
 .exclude(
 { path: 'cats', method: RequestMethod.GET },
 'cats/{*splat}',
 )
 .forRoutes(CatsController);
 }
}
```

### 函数式中间件

```typescript
import { Request, Response, NextFunction } from 'express';

export function logger(req: Request, res: Response, next: NextFunction) {
 console.log(`请求...`);
 next();
}

// 在模块中应用
consumer.apply(logger).forRoutes(CatsController);

// 全局中间件
const app = await NestFactory.create(AppModule);
app.use(logger);
await app.listen(3000);
```

## 异常过滤器

### 内置异常处理

```typescript
import { Controller, Get, Post, Body, HttpException, HttpStatus } from '@nestjs/common';

@Controller('cats')
export class CatsController {
 @Get()
 async findAll() {
 throw new HttpException('禁止访问', HttpStatus.FORBIDDEN);
 }

 @Post()
 async create(@Body() createCatDto: CreateCatDto) {
 throw new HttpException({
 status: HttpStatus.FORBIDDEN,
 error: '这是自定义消息',
 }, HttpStatus.FORBIDDEN);
 }
}
```

### 自定义异常过滤器

```typescript
import { ExceptionFilter, Catch, ArgumentsHost, HttpException } from '@nestjs/common';
import { Request, Response } from 'express';

@Catch(HttpException)
export class HttpExceptionFilter implements ExceptionFilter {
 catch(exception: HttpException, host: ArgumentsHost) {
 const ctx = host.switchToHttp();
 const response = ctx.getResponse();
 const request = ctx.getRequest();
 const status = exception.getStatus();

 response.status(status).json({
 statusCode: status,
 timestamp: new Date().toISOString(),
 path: request.url,
 message: exception.message,
 });
 }
}

// 应用到控制器或方法
import { UseFilters } from '@nestjs/common';

@Post()
@UseFilters(new HttpExceptionFilter())
async create(@Body() createCatDto: CreateCatDto) {
 throw new ForbiddenException();
}

// 全局异常过滤器
const app = await NestFactory.create(AppModule);
app.useGlobalFilters(new HttpExceptionFilter());

// 带依赖注入的全局过滤器
@Module({
 providers: [
 {
 provide: APP_FILTER,
 useClass: HttpExceptionFilter,
 },
 ],
})
export class AppModule {}
```

### 全捕获异常过滤器

```typescript
import { Catch, ArgumentsHost, HttpException, HttpStatus } from '@nestjs/common';
import { HttpAdapterHost } from '@nestjs/core';

@Catch()
export class AllExceptionsFilter implements ExceptionFilter {
 constructor(private readonly httpAdapterHost: HttpAdapterHost) {}

 catch(exception: unknown, host: ArgumentsHost): void {
 const { httpAdapter } = this.httpAdapterHost;
 const ctx = host.switchToHttp();

 const httpStatus = exception instanceof HttpException
 ? exception.getStatus()
 : HttpStatus.INTERNAL_SERVER_ERROR;

 const responseBody = {
 statusCode: httpStatus,
 timestamp: new Date().toISOString(),
 path: httpAdapter.getRequestUrl(ctx.getRequest()),
 message: exception instanceof Error ? exception.message : '内部服务器错误',
 };

 httpAdapter.reply(ctx.getResponse(), responseBody, httpStatus);
 }
}
```

## 管道

### 内置转换管道

```typescript
import { Controller, Get, Param, Query, ParseIntPipe, ParseUUIDPipe } from '@nestjs/common';

@Controller('cats')
export class CatsController {
 @Get(':id')
 async findOne(@Param('id', ParseIntPipe) id: number) {
 return this.catsService.findOne(id);
 }

 @Get('user/:uuid')
 async findByUser(@Param('uuid', ParseUUIDPipe) uuid: string) {
 return this.catsService.findByUser(uuid);
 }

 @Get()
 async findAll(@Query('page', ParseIntPipe) page: number) {
 return this.catsService.findAll(page);
 }
}
```

### 使用 class-validator 的验证管道

```typescript
import { IsString, IsInt, Min, Max } from 'class-validator';

export class CreateCatDto {
 @IsString()
 name: string;

 @IsInt()
 @Min(0)
 @Max(30)
 age: number;

 @IsString()
 breed: string;
}

// 应用验证管道
import { Controller, Post, Body, UsePipes, ValidationPipe } from '@nestjs/common';

@Controller('cats')
export class CatsController {
 @Post()
 @UsePipes(new ValidationPipe())
 async create(@Body() createCatDto: CreateCatDto) {
 return this.catsService.create(createCatDto);
 }
}

// 全局验证管道
async function bootstrap() {
 const app = await NestFactory.create(AppModule);
 app.useGlobalPipes(new ValidationPipe({
 whitelist: true,
 forbidNonWhitelisted: true,
 transform: true,
 }));
 await app.listen(3000);
}

// 带依赖注入
@Module({
 providers: [
 {
 provide: APP_PIPE,
 useClass: ValidationPipe,
 },
 ],
})
export class AppModule {}
```

### 自定义转换管道

```typescript
import { PipeTransform, Injectable, ArgumentMetadata, BadRequestException } from '@nestjs/common';

@Injectable()
export class ParseIntPipe implements PipeTransform {
 transform(value: string, metadata: ArgumentMetadata): number {
 const val = parseInt(value, 10);
 if (isNaN(val)) {
 throw new BadRequestException('验证失败（需要数字字符串）');
 }
 return val;
 }
}

@Get(':id')
async findOne(@Param('id', new ParseIntPipe()) id: number) {
 return this.catsService.findOne(id);
}
```

### 使用 Zod 的 Schema 验证

```typescript
import { PipeTransform, ArgumentMetadata, BadRequestException } from '@nestjs/common';
import { ZodSchema } from 'zod';

export class ZodValidationPipe implements PipeTransform {
 constructor(private schema: ZodSchema) {}

 transform(value: unknown, metadata: ArgumentMetadata) {
 try {
 const parsedValue = this.schema.parse(value);
 return parsedValue;
 } catch (error) {
 throw new BadRequestException('验证失败');
 }
 }
}

// 定义 schema
import { z } from 'zod';

export const createCatSchema = z.object({
 name: z.string(),
 age: z.number().min(0).max(30),
 breed: z.string(),
}).required();

export type CreateCatDto = z.infer;

// 在控制器中使用
@Post()
@UsePipes(new ZodValidationPipe(createCatSchema))
async create(@Body() createCatDto: CreateCatDto) {
 return this.catsService.create(createCatDto);
}
```

## 守卫

### 认证守卫

```typescript
import { Injectable, CanActivate, ExecutionContext, UnauthorizedException } from '@nestjs/common';
import { Observable } from 'rxjs';

@Injectable()
export class AuthGuard implements CanActivate {
 canActivate(context: ExecutionContext): boolean | Promise | Observable {
 const request = context.switchToHttp().getRequest();
 const token = request.headers.authorization;

 if (!token) {
 throw new UnauthorizedException('未提供令牌');
 }

 try {
 // 在此处验证令牌逻辑
 const user = this.validateToken(token);
 request.user = user;
 return true;
 } catch (error) {
 throw new UnauthorizedException('无效的令牌');
 }
 }

 private validateToken(token: string) {
 // 令牌验证逻辑
 return { id: '123', username: 'john' };
 }
}

// 应用守卫
import { Controller, Get, UseGuards } from '@nestjs/common';

@Controller('cats')
@UseGuards(AuthGuard)
export class CatsController {
 @Get()
 findAll() {
 return this.catsService.findAll();
 }
}
```

### 基于角色的授权守卫

```typescript
import { Injectable, CanActivate, ExecutionContext } from '@nestjs/common';
import { Reflector } from '@nestjs/core';

// 自定义装饰器
export const Roles = Reflector.createDecorator();

@Injectable()
export class RolesGuard implements CanActivate {
 constructor(private reflector: Reflector) {}

 canActivate(context: ExecutionContext): boolean {
 const roles = this.reflector.get(Roles, context.getHandler());
 if (!roles) {
 return true;
 }

 const request = context.switchToHttp().getRequest();
 const user = request.user;

 return this.matchRoles(roles, user.roles);
 }

 private matchRoles(requiredRoles: string[], userRoles: string[]): boolean {
 return requiredRoles.some(role => userRoles.includes(role));
 }
}

// 在控制器中使用
@Post()
@Roles(['admin'])
@UseGuards(RolesGuard)
async create(@Body() createCatDto: CreateCatDto) {
 return this.catsService.create(createCatDto);
}

// 带依赖注入的全局守卫
@Module({
 providers: [
 {
 provide: APP_GUARD,
 useClass: RolesGuard,
 },
 ],
})
export class AppModule {}
```

## 拦截器

### 日志拦截器

```typescript
import { Injectable, NestInterceptor, ExecutionContext, CallHandler } from '@nestjs/common';
import { Observable } from 'rxjs';
import { tap } from 'rxjs/operators';

@Injectable()
export class LoggingInterceptor implements NestInterceptor {
 intercept(context: ExecutionContext, next: CallHandler): Observable {
 const request = context.switchToHttp().getRequest();
 const { method, url } = request;
 const now = Date.now();

 console.log(`[${method}] ${url} - 开始`);

 return next.handle().pipe(
 tap(() => {
 console.log(`[${method}] ${url} - 完成，耗时 ${Date.now() - now}ms`);
 }),
 );
 }
}

@UseInterceptors(LoggingInterceptor)
@Controller('cats')
export class CatsController {}
```

### 响应转换拦截器

```typescript
import { Injectable, NestInterceptor, ExecutionContext, CallHandler } from '@nestjs/common';
import { Observable } from 'rxjs';
import { map } from 'rxjs/operators';

export interface Response<T> {
 data: T;
 timestamp: string;
 path: string;
}

@Injectable()
export class TransformInterceptor<T> implements NestInterceptor<T, Response<T>> {
 intercept(context: ExecutionContext, next: CallHandler): Observable<Response<T>> {
 const request = context.switchToHttp().getRequest();

 return next.handle().pipe(
 map(data => ({
 data,
 timestamp: new Date().toISOString(),
 path: request.url,
 })),
 );
 }
}

// 结果：GET /cats 返回 { data: [...], timestamp: "...", path: "/cats" }
```

### 缓存拦截器

```typescript
import { Injectable, NestInterceptor, ExecutionContext, CallHandler } from '@nestjs/common';
import { Observable, of } from 'rxjs';

@Injectable()
export class CacheInterceptor implements NestInterceptor {
 private cache = new Map<string, any>();

 intercept(context: ExecutionContext, next: CallHandler): Observable<any> {
 const request = context.switchToHttp().getRequest();
 const cacheKey = `${request.method}:${request.url}`;

 if (this.cache.has(cacheKey)) {
 console.log('返回缓存的响应');
 return of(this.cache.get(cacheKey));
 }

 return next.handle().pipe(
 tap(response => {
 this.cache.set(cacheKey, response);
 }),
 );
 }
}
```

### 超时拦截器

```typescript
import { Injectable, NestInterceptor, ExecutionContext, CallHandler, RequestTimeoutException } from '@nestjs/common';
import { Observable, throwError, TimeoutError } from 'rxjs';
import { catchError, timeout } from 'rxjs/operators';

@Injectable()
export class TimeoutInterceptor implements NestInterceptor {
 intercept(context: ExecutionContext, next: CallHandler): Observable<any> {
 return next.handle().pipe(
 timeout(5000),
 catchError(err => {
 if (err instanceof TimeoutError) {
 return throwError(() => new RequestTimeoutException('请求超时'));
 }
 return throwError(() => err);
 }),
 );
 }
}
```

## 依赖注入

### 构造器注入

```typescript
@Injectable()
export class CatsService {
 constructor(
 private readonly dogsService: DogsService,
 private readonly configService: ConfigService,
 ) {}

 async findAll() {
 const config = this.configService.get('database');
 return this.catsRepository.find();
 }
}
```

### 带令牌的自定义提供者

```typescript
const CONNECTION = 'DATABASE_CONNECTION';

@Module({
 providers: [
 {
 provide: CONNECTION,
 useValue: {
 host: 'localhost',
 port: 5432,
 database: 'test',
 },
 },
 ],
})
export class DatabaseModule {}

// 注入自定义提供者
@Injectable()
export class CatsRepository {
 constructor(@Inject(CONNECTION) private connection: any) {}
}
```

### 工厂提供者

```typescript
@Module({
 providers: [
 {
 provide: 'DATABASE_CONNECTION',
 useFactory: async (configService: ConfigService) => {
 const config = configService.get('database');
 const connection = await createConnection(config);
 return connection;
 },
 inject: [ConfigService],
 },
 ],
})
export class DatabaseModule {}
```

### 异步提供者

```typescript
@Module({
 providers: [
 {
 provide: 'ASYNC_CONNECTION',
 useFactory: async () => {
 const connection = await createAsyncConnection();
 return connection;
 },
 },
 ],
})
export class AppModule {}
```

### 带条件逻辑的类提供者

```typescript
const configServiceProvider = {
 provide: ConfigService,
 useClass: process.env.NODE_ENV === 'development'
 ? DevelopmentConfigService
 : ProductionConfigService,
};

@Module({
 providers: [configServiceProvider],
})
export class AppModule {}
```

## 数据库集成

### TypeORM 设置

```typescript
import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';

@Module({
 imports: [
 TypeOrmModule.forRoot({
 type: 'postgres',
 host: 'localhost',
 port: 5432,
 username: 'postgres',
 password: 'password',
 database: 'nest_db',
 entities: [__dirname + '/**/*.entity{.ts,.js}'],
 synchronize: true, // 不要在生产中使用
 logging: true,
 }),
 ],
})
export class AppModule {}
```

### 实体定义

```typescript
import { Entity, Column, PrimaryGeneratedColumn, CreateDateColumn, UpdateDateColumn, OneToMany } from 'typeorm';
import { Photo } from '../photos/photo.entity';

@Entity('users')
export class User {
 @PrimaryGeneratedColumn('uuid')
 id: string;

 @Column({ unique: true })
 email: string;

 @Column()
 firstName: string;

 @Column()
 lastName: string;

 @Column({ default: true })
 isActive: boolean;

 @CreateDateColumn()
 createdAt: Date;

 @UpdateDateColumn()
 updatedAt: Date;

 @OneToMany(() => Photo, photo => photo.user)
 photos: Photo[];
}
```

### 仓库模式

```typescript
import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { User } from './user.entity';

@Injectable()
export class UsersService {
 constructor(
 @InjectRepository(User)
 private usersRepository: Repository<User>,
 ) {}

 async findAll(): Promise<User[]> {
 return this.usersRepository.find({ relations: ['photos'] });
 }

 async findOne(id: string): Promise<User> {
 const user = await this.usersRepository.findOne({
 where: { id },
 relations: ['photos'],
 });
 if (!user) throw new NotFoundException('用户未找到');
 return user;
 }

 async create(userData: CreateUserDto): Promise<User> {
 const user = this.usersRepository.create(userData);
 return this.usersRepository.save(user);
 }

 async update(id: string, updateData: UpdateUserDto): Promise<User> {
 await this.usersRepository.update(id, updateData);
 return this.findOne(id);
 }

 async remove(id: string): Promise<void> {
 const result = await this.usersRepository.delete(id);
 if (result.affected === 0) {
 throw new NotFoundException('用户未找到');
 }
 }
}

@Module({
 imports: [TypeOrmModule.forFeature([User])],
 providers: [UsersService],
 controllers: [UsersController],
 exports: [UsersService],
})
export class UsersModule {}
```

### 数据库事务

```typescript
import { DataSource } from 'typeorm';

@Injectable()
export class UsersService {
 constructor(
 @InjectRepository(User) private usersRepository: Repository<User>,
 private dataSource: DataSource,
 ) {}

 async createUserWithPhotos(userData: CreateUserDto, photos: CreatePhotoDto[]) {
 const queryRunner = this.dataSource.createQueryRunner();
 await queryRunner.connect();
 await queryRunner.startTransaction();

 try {
 const user = await queryRunner.manager.save(User, userData);

 for (const photoData of photos) {
 await queryRunner.manager.save(Photo, { ...photoData, user });
 }

 await queryRunner.commitTransaction();
 return user;
 } catch (err) {
 await queryRunner.rollbackTransaction();
 throw err;
 } finally {
 await queryRunner.release();
 }
 }
}
```

### 异步配置

```typescript
TypeOrmModule.forRootAsync({
 imports: [ConfigModule],
 useFactory: (configService: ConfigService) => ({
 type: 'postgres',
 host: configService.get('DB_HOST'),
 port: configService.get('DB_PORT'),
 username: configService.get('DB_USERNAME'),
 password: configService.get('DB_PASSWORD'),
 database: configService.get('DB_NAME'),
 entities: [__dirname + '/**/*.entity{.ts,.js}'],
 synchronize: configService.get('DB_SYNC') === 'true',
 }),
 inject: [ConfigService],
})
```

## 测试

### 使用模拟对象的单元测试

```typescript
import { Test, TestingModule } from '@nestjs/testing';
import { CatsController } from './cats.controller';
import { CatsService } from './cats.service';

describe('CatsController', () => {
 let catsController: CatsController;
 let catsService: CatsService;

 beforeEach(async () => {
 const module: TestingModule = await Test.createTestingModule({
 controllers: [CatsController],
 providers: [CatsService],
 }).compile();

 catsService = module.get(CatsService);
 catsController = module.get(CatsController);
 });

 describe('findAll', () => {
 it('应返回猫的数组', async () => {
 const result = [{ name: '测试猫', age: 2, breed: '波斯猫' }];
 jest.spyOn(catsService, 'findAll').mockImplementation(() => Promise.resolve(result));

 expect(await catsController.findAll()).toBe(result);
 });
 });

 describe('create', () => {
 it('应创建一只猫', async () => {
 const catDto = { name: '新猫', age: 1, breed: '暹罗猫' };
 jest.spyOn(catsService, 'create').mockImplementation(() => Promise.resolve(catDto));

 expect(await catsController.create(catDto)).toEqual(catDto);
 });
 });
});
```

### 使用提供者覆盖的测试

```typescript
describe('CatsController', () => {
 let controller: CatsController;

 const mockCatsService = {
 findAll: jest.fn(() => [{ name: '测试', age: 2, breed: '波斯猫' }]),
 findOne: jest.fn((id) => ({ id, name: '测试', age: 2, breed: '波斯猫' })),
 create: jest.fn((dto) => ({ id: '123', ...dto })),
 };

 beforeEach(async () => {
 const module: TestingModule = await Test.createTestingModule({
 controllers: [CatsController],
 providers: [CatsService],
 })
 .overrideProvider(CatsService)
 .useValue(mockCatsService)
 .compile();

 controller = module.get(CatsController);
 });

 it('应被定义', () => {
 expect(controller).toBeDefined();
 });
});
```

### 端到端测试

```typescript
import { Test, TestingModule } from '@nestjs/testing';
import { INestApplication } from '@nestjs/common';
import * as request from 'supertest';
import { AppModule } from './../src/app.module';

describe('CatsController (e2e)', () => {
 let app: INestApplication;

 beforeAll(async () => {
 const moduleFixture: TestingModule = await Test.createTestingModule({
 imports: [AppModule],
 }).compile();

 app = moduleFixture.createNestApplication();
 await app.init();
 });

 afterAll(async () => {
 await app.close();
 });

 it('/cats (GET)', () => {
 return request(app.getHttpServer())
 .get('/cats')
 .expect(200)
 .expect((res) => {
 expect(Array.isArray(res.body)).toBe(true);
 });
 });

 it('/cats (POST)', () => {
 return request(app.getHttpServer())
 .post('/cats')
 .send({ name: '测试猫', age: 2, breed: '波斯猫' })
 .expect(201)
 .expect((res) => {
 expect(res.body).toHaveProperty('id');
 expect(res.body.name).toBe('测试猫');
 });
 });

 it('/cats/:id (GET)', () => {
 return request(app.getHttpServer())
 .get('/cats/123')
 .expect(200)
 .expect((res) => {
 expect(res.body).toHaveProperty('id', '123');
 });
 });
});
```

### 使用仓库模拟对象的测试

```typescript
describe('UsersService', () => {
 let service: UsersService;
 let repository: Repository<User>;

 const mockRepository = {
 find: jest.fn(),
 findOne: jest.fn(),
 create: jest.fn(),
 save: jest.fn(),
 update: jest.fn(),
 delete: jest.fn(),
 };

 beforeEach(async () => {
 const module: TestingModule = await Test.createTestingModule({
 providers: [
 UsersService,
 {
 provide: getRepositoryToken(User),
 useValue: mockRepository,
 },
 ],
 }).compile();

 service = module.get(UsersService);
 repository = module.get<Repository<User>>(getRepositoryToken(User));
 });

 it('应查找所有用户', async () => {
 const users = [{ id: '1', email: 'test@example.com' }];
 mockRepository.find.mockResolvedValue(users);

 expect(await service.findAll()).toEqual(users);
 expect(repository.find).toHaveBeenCalled();
 });
});
```

## 微服务

### TCP 微服务设置

```typescript
import { NestFactory } from '@nestjs/core';
import { Transport, MicroserviceOptions } from '@nestjs/microservices';
import { AppModule } from './app.module';

async function bootstrap() {
 const app = await NestFactory.createMicroservice(
 AppModule,
 {
 transport: Transport.TCP,
 options: {
 host: '127.0.0.1',
 port: 8877,
 },
 },
 );
 await app.listen();
}
bootstrap();
```

### 消息模式处理器

```typescript
import { Controller } from '@nestjs/common';
import { MessagePattern, Payload, Ctx, NatsContext } from '@nestjs/microservices';

@Controller()
export class MathController {
 @MessagePattern({ cmd: 'sum' })
 accumulate(@Payload() data: number[]): number {
 return (data || []).reduce((a, b) => a + b, 0);
 }

 @MessagePattern({ cmd: 'multiply' })
 multiply(@Payload() data: { a: number; b: number }): number {
 return data.a * data.b;
 }
}
```

### 事件模式处理器

```typescript
@Controller()
export class NotificationsController {
 @EventPattern('user_created')
 async handleUserCreated(@Payload() data: CreateUserEvent) {
 console.log('新用户已创建：', data);
 // 发送欢迎邮件
 await this.emailService.sendWelcome(data.email);
 }

 @EventPattern('order_placed')
 async handleOrderPlaced(@Payload() data: OrderPlacedEvent) {
 console.log('订单已下达：', data);
 // 处理订单
 await this.orderService.process(data);
 }
}
```

### 微服务客户端

```typescript
import { Module } from '@nestjs/common';
import { ClientsModule, Transport } from '@nestjs/microservices';

@Module({
 imports: [
 ClientsModule.register([
 {
 name: 'MATH_SERVICE',
 transport: Transport.TCP,
 options: {
 host: '127.0.0.1',
 port: 8877,
 },
 },
 ]),
 ],
 controllers: [AppController],
})
export class AppModule {}

// 在控制器中使用
import { Controller, Get, Inject } from '@nestjs/common';
import { ClientProxy } from '@nestjs/microservices';
import { Observable } from 'rxjs';

@Controller()
export class AppController {
 constructor(@Inject('MATH_SERVICE') private client: ClientProxy) {}

 @Get('sum')
 accumulate(): Observable<number> {
 const pattern = { cmd: 'sum' };
 const payload = [1, 2, 3, 4, 5];
 return this.client.send<number>(pattern, payload);
 }

 @Get('notify')
 async notify() {
 this.client.emit('user_created', { id: '123', email: 'user@example.com' });
 return { message: '通知已发送' };
 }
}
```

### Redis 传输

```typescript
// 微服务
const app = await NestFactory.createMicroservice(
 AppModule,
 {
 transport: Transport.REDIS,
 options: {
 host: 'localhost',
 port: 6379,
 },
 },
);

// 客户端
ClientsModule.register([
 {
 name: 'REDIS_SERVICE',
 transport: Transport.REDIS,
 options: {
 host: 'localhost',
 port: 6379,
 },
 },
])
```

## GraphQL

### Apollo GraphQL 设置

```typescript
import { Module } from '@nestjs/common';
import { GraphQLModule } from '@nestjs/graphql';
import { ApolloDriver, ApolloDriverConfig } from '@nestjs/apollo';
import { join } from 'path';

@Module({
 imports: [
 GraphQLModule.forRoot<ApolloDriverConfig>({
 driver: ApolloDriver,
 autoSchemaFile: join(process.cwd(), 'src/schema.gql'),
 sortSchema: true,
 playground: true,
 }),
 ],
})
export class AppModule {}
```

### GraphQL 解析器（Code First）

```typescript
import { Resolver, Query, Mutation, Args, ID } from '@nestjs/graphql';
import { ObjectType, Field, Int } from '@nestjs/graphql';

@ObjectType()
export class Cat {
 @Field(() => ID)
 id: string;

 @Field()
 name: string;

 @Field(() => Int)
 age: number;

 @Field()
 breed: string;
}

@Resolver(() => Cat)
export class CatsResolver {
 constructor(private catsService: CatsService) {}

 @Query(() => [Cat], { name: 'cats' })
 async findAll() {
 return this.catsService.findAll();
 }

 @Query(() => Cat, { name: 'cat' })
 async findOne(@Args('id', { type: () => ID }) id: string) {
 return this.catsService.findOne(id);
 }

 @Mutation(() => Cat)
 async createCat(
 @Args('name') name: string,
 @Args('age', { type: () => Int }) age: number,
 @Args('breed') breed: string,
 ) {
 return this.catsService.create({ name, age, breed });
 }

 @Mutation(() => Boolean)
 async removeCat(@Args('id', { type: () => ID }) id: string) {
 await this.catsService.remove(id);
 return true;
 }
}
```

### GraphQL 输入类型

```typescript
import { InputType, Field, Int } from '@nestjs/graphql';

@InputType()
export class CreateCatInput {
 @Field()
 name: string;

 @Field(() => Int)
 age: number;

 @Field()
 breed: string;
}

@Mutation(() => Cat)
async createCat(@Args('input') input: CreateCatInput) {
 return this.catsService.create(input);
}
```

## OpenAPI/Swagger 文档

### 基本 Swagger 设置

```typescript
import { NestFactory } from '@nestjs/core';
import { SwaggerModule, DocumentBuilder } from '@nestjs/swagger';
import { AppModule } from './app.module';

async function bootstrap() {
 const app = await NestFactory.create(AppModule);

 const config = new DocumentBuilder()
 .setTitle('猫 API')
 .setDescription('猫 API 文档')
 .setVersion('1.0')
 .addTag('cats')
 .addBearerAuth()
 .build();

 const documentFactory = () => SwaggerModule.createDocument(app, config);
 SwaggerModule.setup('api', app, documentFactory);

 await app.listen(3000);
}
bootstrap();
// 访问地址：http://localhost:3000/api
```

### API 装饰器

```typescript
import { ApiTags, ApiOperation, ApiResponse, ApiProperty, ApiBearerAuth } from '@nestjs/swagger';

export class CreateCatDto {
 @ApiProperty({ example: '毛毛', description: '猫的名称' })
 name: string;

 @ApiProperty({ example: 3, description: '猫的年龄' })
 age: number;

 @ApiProperty({ example: '波斯猫', description: '猫的品种' })
 breed: string;
}

@ApiTags('cats')
@Controller('cats')
export class CatsController {
 @Post()
 @ApiOperation({ summary: '创建一只新猫' })
 @ApiResponse({ status: 201, description: '猫已成功创建。', type: Cat })
 @ApiResponse({ status: 400, description: '错误的请求。' })
 @ApiBearerAuth()
 async create(@Body() createCatDto: CreateCatDto) {
 return this.catsService.create(createCatDto);
 }

 @Get()
 @ApiOperation({ summary: '获取所有猫' })
 @ApiResponse({ status: 200, description: '返回所有猫。', type: [Cat] })
 async findAll() {
 return this.catsService.findAll();
 }
}
```

## 配置

### 环境配置

```typescript
import { Module } from '@nestjs/common';
import { ConfigModule, ConfigService } from '@nestjs/config';

@Module({
 imports: [
 ConfigModule.forRoot({
 isGlobal: true,
 envFilePath: ['.env.local', '.env'],
 ignoreEnvFile: process.env.NODE_ENV === 'production',
 }),
 ],
})
export class AppModule {}

// 在服务中使用
@Injectable()
export class AppService {
 constructor(private configService: ConfigService) {}

 getDatabaseConfig() {
 return {
 host: this.configService.get('DB_HOST'),
 port: this.configService.get('DB_PORT'),
 };
 }
}
```

### 自定义配置文件

```typescript
export default () => ({
 port: parseInt(process.env.PORT, 10) || 3000,
 database: {
 host: process.env.DATABASE_HOST || 'localhost',
 port: parseInt(process.env.DATABASE_PORT, 10) || 5432,
 username: process.env.DATABASE_USERNAME,
 password: process.env.DATABASE_PASSWORD,
 },
 jwt: {
 secret: process.env.JWT_SECRET,
 expiresIn: '7d',
 },
});

// 在模块中导入
import configuration from './config/configuration';

@Module({
 imports: [
 ConfigModule.forRoot({
 load: [configuration],
 }),
 ],
})
export class AppModule {}

// 访问嵌套配置
const dbHost = this.configService.get('database.host');
```

## 总结

NestJS 提供了一个全面的框架，用于构建可扩展的服务端应用程序，重点关注可维护性和可测试性。该框架的模块化架构，结合依赖注入和装饰器，使开发者能够有效地组织应用程序。核心构建块包括用于处理 HTTP 请求的控制器、用于业务逻辑的提供者、用于组织的模块以及用于请求处理的中间件。守卫、拦截器和管道等高级功能实现了横切关注点，如认证、日志、验证和转换。

该框架在企业级应用中表现出色，支持多传输层的微服务架构、通过 TypeORM 和 Sequelize 的数据库集成、GraphQL API 开发以及全面的测试工具。NestJS 基于装饰器的方法和 TypeScript 支持提供了出色的开发者体验，兼具类型安全和 IDE 集成。框架的可扩展性允许集成各种库和工具，同时保持清晰的架构原则。无论是构建 REST API、GraphQL 服务、微服务还是 WebSocket 应用程序，NestJS 都提供了生产级应用所需的工具和模式，包括适当的错误处理、验证、日志记录以及通过 OpenAPI/Swagger 集成的文档。
