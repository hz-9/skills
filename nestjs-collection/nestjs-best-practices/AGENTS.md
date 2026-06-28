# NestJS 最佳实践

**版本 1.1.0**
NestJS 最佳实践
2026 年 1 月

> **注意：**
> 本文档主要为 AI 代理和 LLM 在维护、生成或重构 NestJS 代码库时提供参考。
> 人类开发者也可能发现它有用，但这里的指南是针对 AI 辅助工作流中的自动化和一致性进行了优化。

---

## 摘要

NestJS 应用程序的全面最佳实践和架构指南，专为 AI 代理和大语言模型设计。包含 10 个类别的 40 条规则，按影响优先级从关键（架构、依赖注入）到增量（DevOps 模式）排序。每条规则包含详细解释、错误与正确实现的真实示例，以及具体的指标数据，用于指导自动化重构和代码生成。

---

## 目录

1. [架构](#1-architecture) — **关键**
   - 1.1 [避免循环依赖](#11-avoid-circular-dependencies)
   - 1.2 [按功能模块组织](#12-organize-by-feature-modules)
   - 1.3 [使用正确的模块共享模式](#13-use-proper-module-sharing-patterns)
   - 1.4 [服务单一职责](#14-single-responsibility-for-services)
   - 1.5 [使用事件驱动架构实现解耦](#15-use-event-driven-architecture-for-decoupling)
   - 1.6 [使用 Repository 模式进行数据访问](#16-use-repository-pattern-for-data-access)
2. [依赖注入](#2-dependency-injection) — **关键**
   - 2.1 [避免服务定位器反模式](#21-avoid-service-locator-anti-pattern)
   - 2.2 [应用接口隔离原则](#22-apply-interface-segregation-principle)
   - 2.3 [遵循里氏替换原则](#23-honor-liskov-substitution-principle)
   - 2.4 [优先使用构造函数注入](#24-prefer-constructor-injection)
   - 2.5 [理解 Provider 作用域](#25-understand-provider-scopes)
   - 2.6 [为接口使用注入令牌](#26-use-injection-tokens-for-interfaces)
3. [错误处理](#3-error-handling) — **高**
   - 3.1 [正确处理异步错误](#31-handle-async-errors-properly)
   - 3.2 [从服务中抛出 HTTP 异常](#32-throw-http-exceptions-from-services)
   - 3.3 [使用异常过滤器处理错误](#33-use-exception-filters-for-error-handling)
4. [安全](#4-security) — **高**
   - 4.1 [实现安全的 JWT 认证](#41-implement-secure-jwt-authentication)
   - 4.2 [实现速率限制](#42-implement-rate-limiting)
   - 4.3 [对输出进行清理以防止 XSS](#43-sanitize-output-to-prevent-xss)
   - 4.4 [使用 Guards 进行认证和授权](#44-use-guards-for-authentication-and-authorization)
   - 4.5 [使用 DTO 和 Pipes 验证所有输入](#45-validate-all-input-with-dtos-and-pipes)
5. [性能](#5-performance) — **高**
   - 5.1 [正确使用异步生命周期钩子](#51-use-async-lifecycle-hooks-correctly)
   - 5.2 [为大型模块使用懒加载](#52-use-lazy-loading-for-large-modules)
   - 5.3 [优化数据库查询](#53-optimize-database-queries)
   - 5.4 [策略性地使用缓存](#54-use-caching-strategically)
6. [测试](#6-testing) — **中高**
   - 6.1 [使用 Supertest 进行 E2E 测试](#61-use-supertest-for-e2e-testing)
   - 6.2 [在测试中模拟外部服务](#62-mock-external-services-in-tests)
   - 6.3 [使用 Testing Module 进行单元测试](#63-use-testing-module-for-unit-tests)
7. [数据库与 ORM](#7-database-orm) — **中高**
   - 7.1 [避免 N+1 查询问题](#71-avoid-n-1-query-problems)
   - 7.2 [使用数据库迁移](#72-use-database-migrations)
   - 7.3 [对多步操作使用事务](#73-use-transactions-for-multi-step-operations)
8. [API 设计](#8-api-design) — **中**
   - 8.1 [使用 DTO 和序列化处理 API 响应](#81-use-dtos-and-serialization-for-api-responses)
   - 8.2 [使用拦截器处理横切关注点](#82-use-interceptors-for-cross-cutting-concerns)
   - 8.3 [使用 Pipes 进行输入转换](#83-use-pipes-for-input-transformation)
   - 8.4 [对破坏性变更使用 API 版本控制](#84-use-api-versioning-for-breaking-changes)
9. [微服务](#9-microservices) — **中**
   - 9.1 [为微服务实现健康检查](#91-implement-health-checks-for-microservices)
   - 9.2 [正确使用消息和事件模式](#92-use-message-and-event-patterns-correctly)
   - 9.3 [使用消息队列处理后台任务](#93-use-message-queues-for-background-jobs)
10. [DevOps 与部署](#10-devops-deployment) — **低中**
   - 10.1 [实现优雅关闭](#101-implement-graceful-shutdown)
   - 10.2 [使用 ConfigModule 进行环境配置](#102-use-configmodule-for-environment-configuration)
   - 10.3 [使用结构化日志](#103-use-structured-logging)

---

## 1. 架构

**章节影响：关键**

### 1.1 避免循环依赖

**影响：关键** — "运行时崩溃的头号原因"

循环依赖发生在模块 A 导入模块 B，而模块 B 又导入模块 A 时（直接或传递依赖）。NestJS 有时可以通过前向引用来解决这些问题，但这表明存在架构问题，应当避免。这是 NestJS 应用程序运行时崩溃的头号原因。

**错误做法（循环模块导入）：**

```typescript
// users.module.ts
@Module({
  imports: [OrdersModule], // Orders 需要 Users，Users 需要 Orders = 循环
  providers: [UsersService],
  exports: [UsersService],
})
export class UsersModule {}

// orders.module.ts
@Module({
  imports: [UsersModule], // 循环依赖！
  providers: [OrdersService],
  exports: [OrdersService],
})
export class OrdersModule {}
```

**正确做法（提取共享逻辑或使用事件）：**

```typescript
// 选项 1：将共享逻辑提取到第三个模块
// shared.module.ts
@Module({
  providers: [SharedService],
  exports: [SharedService],
})
export class SharedModule {}

// users.module.ts
@Module({
  imports: [SharedModule],
  providers: [UsersService],
})
export class UsersModule {}

// orders.module.ts
@Module({
  imports: [SharedModule],
  providers: [OrdersService],
})
export class OrdersModule {}

// 选项 2：使用事件进行解耦通信
// users.service.ts
@Injectable()
export class UsersService {
  constructor(private eventEmitter: EventEmitter2) {}

  async createUser(data: CreateUserDto) {
    const user = await this.userRepo.save(data);
    this.eventEmitter.emit('user.created', user);
    return user;
  }
}

// orders.service.ts
@Injectable()
export class OrdersService {
  @OnEvent('user.created')
  handleUserCreated(user: User) {
    // 响应用户创建，无需直接依赖
  }
}
```

参考: [NestJS 循环依赖](https://docs.nestjs.com/fundamentals/circular-dependency)

---

### 1.2 按功能模块组织

**影响：关键** — "3-5 倍更快的上手和开发速度"

将应用程序组织为功能模块，每个模块封装相关的功能。每个功能模块应自包含，拥有自己的 controllers、services、entities 和 DTOs。避免按技术层组织（所有 controllers 放在一起，所有 services 放在一起）。这可以使上手和功能开发速度提升 3-5 倍。

**错误做法（技术层组织）：**

```typescript
// 技术层组织（反模式）
src/
├── controllers/
│   ├── users.controller.ts
│   ├── orders.controller.ts
│   └── products.controller.ts
├── services/
│   ├── users.service.ts
│   ├── orders.service.ts
│   └── products.service.ts
├── entities/
│   ├── user.entity.ts
│   ├── order.entity.ts
│   └── product.entity.ts
└── app.module.ts  // 直接导入所有内容
```

**正确做法（功能模块组织）：**

```typescript
// 功能模块组织
src/
├── users/
│   ├── dto/
│   │   ├── create-user.dto.ts
│   │   └── update-user.dto.ts
│   ├── entities/
│   │   └── user.entity.ts
│   ├── users.controller.ts
│   ├── users.service.ts
│   ├── users.repository.ts
│   └── users.module.ts
├── orders/
│   ├── dto/
│   ├── entities/
│   ├── orders.controller.ts
│   ├── orders.service.ts
│   └── orders.module.ts
├── shared/
│   ├── guards/
│   ├── interceptors/
│   ├── filters/
│   └── shared.module.ts
└── app.module.ts

// users.module.ts
@Module({
  imports: [TypeOrmModule.forFeature([User])],
  controllers: [UsersController],
  providers: [UsersService, UsersRepository],
  exports: [UsersService], // 只导出其他模块需要的内容
})
export class UsersModule {}

// app.module.ts
@Module({
  imports: [
    ConfigModule.forRoot(),
    TypeOrmModule.forRoot(),
    UsersModule,
    OrdersModule,
    SharedModule,
  ],
})
export class AppModule {}
```

参考: [NestJS 模块](https://docs.nestjs.com/modules)

---

### 1.3 使用正确的模块共享模式

**影响：关键** — 防止重复实例、内存泄漏和状态不一致

NestJS 模块默认是单例的。当一个服务从模块中正确导出并在其他模块中导入时，将共享同一个实例。然而，在多个模块中提供同一个服务会创建独立的实例，导致内存浪费、状态不一致和令人困惑的行为。始终将服务封装在专用模块中，显式导出，并在需要的地方导入模块。

**错误做法（在多个模块中提供服务）：**

```typescript
// StorageService 直接在多个模块中提供 - 错误
// storage.service.ts
@Injectable()
export class StorageService {
  private cache = new Map(); // 每个实例有独立的状态！

  store(key: string, value: any) {
    this.cache.set(key, value);
  }
}

// app.module.ts
@Module({
  providers: [StorageService], // 实例 #1
  controllers: [AppController],
})
export class AppModule {}

// videos.module.ts
@Module({
  providers: [StorageService], // 实例 #2 - 与 AppModule 不同！
  controllers: [VideosController],
})
export class VideosModule {}

// 问题：
// 1. 存在两个独立的 StorageService 实例
// 2. VideosModule 中的 cache.set() 不会影响 AppModule 的缓存
// 3. 重复实例浪费内存
// 4. 状态不同步时调试极其困难
```

**正确做法（带导出的专用模块）：**

```typescript
// storage/storage.module.ts
@Module({
  providers: [StorageService],
  exports: [StorageService], // 对导入者可用
})
export class StorageModule {}

// videos/videos.module.ts
@Module({
  imports: [StorageModule], // 导入模块，而不是服务
  controllers: [VideosController],
  providers: [VideosService],
})
export class VideosModule {}

// channels/channels.module.ts
@Module({
  imports: [StorageModule], // 共享同一个实例
  controllers: [ChannelsController],
  providers: [ChannelsService],
})
export class ChannelsModule {}

// app.module.ts
@Module({
  imports: [
    StorageModule, // 仅在 AppModule 本身需要使用 StorageService 时
    VideosModule,
    ChannelsModule,
  ],
})
export class AppModule {}

// 现在所有模块共享同一个 StorageService 实例
```

**何时使用 @Global()（谨慎使用）：**

```typescript
// 仅用于真正的横切关注点
@Global()
@Module({
  providers: [ConfigService, LoggerService],
  exports: [ConfigService, LoggerService],
})
export class CoreModule {}

// 在 AppModule 中导入一次
@Module({
  imports: [CoreModule], // 全局注册，随处可用
})
export class AppModule {}

// 其他模块不需要导入 CoreModule
@Module({
  controllers: [UsersController],
  providers: [UsersService], // 无需导入即可注入 ConfigService
})
export class UsersModule {}

// 警告：不要把所有东西都设成全局！
// - 隐藏依赖（看不出模块需要什么导入）
// - 使测试更困难
// - 保留给：配置、日志、数据库连接
```

**模块重新导出模式：**

```typescript
// common.module.ts - 共享工具
@Module({
  providers: [DateService, ValidationService],
  exports: [DateService, ValidationService],
})
export class CommonModule {}

// core.module.ts - 为方便重新导出公共模块
@Module({
  imports: [CommonModule, DatabaseModule],
  exports: [CommonModule, DatabaseModule], // 为消费者重新导出
})
export class CoreModule {}

// feature.module.ts - 导入 CoreModule，获得两者
@Module({
  imports: [CoreModule], // 获得 CommonModule + DatabaseModule
  controllers: [FeatureController],
})
export class FeatureModule {}
```

参考: [NestJS 模块](https://docs.nestjs.com/modules#shared-modules)

---

### 1.4 服务单一职责

**影响：关键** — "可测试性提升 40% 以上"

每个服务应具有单一、明确的责任。避免处理多个不相关关注的"上帝服务"。如果服务名称包含"And"或处理多个领域概念，则很可能违反了单一职责原则。这可以降低复杂性并使可测试性提升 40% 以上。

**错误做法（上帝服务反模式）：**

```typescript
// 上帝服务反模式
@Injectable()
export class UserAndOrderService {
  constructor(
    private userRepo: UserRepository,
    private orderRepo: OrderRepository,
    private mailer: MailService,
    private payment: PaymentService,
  ) {}

  async createUser(dto: CreateUserDto) {
    const user = await this.userRepo.save(dto);
    await this.mailer.sendWelcome(user);
    return user;
  }

  async createOrder(userId: string, dto: CreateOrderDto) {
    const order = await this.orderRepo.save({ userId, ...dto });
    await this.payment.charge(order);
    await this.mailer.sendOrderConfirmation(order);
    return order;
  }

  async calculateOrderStats(userId: string) {
    // 统计逻辑混入其中
  }

  async validatePayment(orderId: string) {
    // 支付逻辑混入其中
  }
}
```

**正确做法（聚焦单一职责的服务）：**

```typescript
// 聚焦单一职责的服务
@Injectable()
export class UsersService {
  constructor(private userRepo: UserRepository) {}

  async create(dto: CreateUserDto): Promise<User> {
    return this.userRepo.save(dto);
  }

  async findById(id: string): Promise<User> {
    return this.userRepo.findOneOrFail({ where: { id } });
  }
}

@Injectable()
export class OrdersService {
  constructor(private orderRepo: OrderRepository) {}

  async create(userId: string, dto: CreateOrderDto): Promise<Order> {
    return this.orderRepo.save({ userId, ...dto });
  }

  async findByUser(userId: string): Promise<Order[]> {
    return this.orderRepo.find({ where: { userId } });
  }
}

@Injectable()
export class OrderStatsService {
  constructor(private orderRepo: OrderRepository) {}

  async calculateForUser(userId: string): Promise<OrderStats> {
    // 专注的统计计算
  }
}

// 在 Controller 或专用的编排器中进行编排
@Controller('orders')
export class OrdersController {
  constructor(
    private orders: OrdersService,
    private payment: PaymentService,
    private notifications: NotificationService,
  ) {}

  @Post()
  async create(@CurrentUser() user: User, @Body() dto: CreateOrderDto) {
    const order = await this.orders.create(user.id, dto);
    await this.payment.charge(order);
    await this.notifications.sendOrderConfirmation(order);
    return order;
  }
}
```

参考: [NestJS Providers](https://docs.nestjs.com/providers)

---

### 1.5 使用事件驱动架构实现解耦

**影响：中高** — 支持异步处理和模块化

使用 `@nestjs/event-emitter` 实现服务内事件，使用消息代理实现服务间通信。事件允许模块在无需直接依赖的情况下响应变化，从而提高模块化程度并支持异步处理。

**错误做法（直接服务耦合）：**

```typescript
// 直接服务耦合
@Injectable()
export class OrdersService {
  constructor(
    private inventoryService: InventoryService,
    private emailService: EmailService,
    private analyticsService: AnalyticsService,
    private notificationService: NotificationService,
    private loyaltyService: LoyaltyService,
  ) {}

  async createOrder(dto: CreateOrderDto): Promise<Order> {
    const order = await this.repo.save(dto);

    // 紧密耦合 - OrdersService 知道所有消费者
    await this.inventoryService.reserve(order.items);
    await this.emailService.sendConfirmation(order);
    await this.analyticsService.track('order_created', order);
    await this.notificationService.push(order.userId, 'Order placed');
    await this.loyaltyService.addPoints(order.userId, order.total);

    // 添加新行为需要修改此服务
    return order;
  }
}
```

**正确做法（事件驱动解耦）：**

```typescript
// 使用 EventEmitter 进行解耦
import { EventEmitter2 } from '@nestjs/event-emitter';

// 定义事件
export class OrderCreatedEvent {
  constructor(
    public readonly orderId: string,
    public readonly userId: string,
    public readonly items: OrderItem[],
    public readonly total: number,
  ) {}
}

// 服务发送事件
@Injectable()
export class OrdersService {
  constructor(
    private eventEmitter: EventEmitter2,
    private repo: Repository<Order>,
  ) {}

  async createOrder(dto: CreateOrderDto): Promise<Order> {
    const order = await this.repo.save(dto);

    // 发送事件 - 无需知道消费者
    this.eventEmitter.emit(
      'order.created',
      new OrderCreatedEvent(order.id, order.userId, order.items, order.total),
    );

    return order;
  }
}

// 在独立模块中的监听器
@Injectable()
export class InventoryListener {
  @OnEvent('order.created')
  async handleOrderCreated(event: OrderCreatedEvent): Promise<void> {
    await this.inventoryService.reserve(event.items);
  }
}

@Injectable()
export class EmailListener {
  @OnEvent('order.created')
  async handleOrderCreated(event: OrderCreatedEvent): Promise<void> {
    await this.emailService.sendConfirmation(event.orderId);
  }
}

@Injectable()
export class AnalyticsListener {
  @OnEvent('order.created')
  async handleOrderCreated(event: OrderCreatedEvent): Promise<void> {
    await this.analyticsService.track('order_created', {
      orderId: event.orderId,
      total: event.total,
    });
  }
}
```

参考: [NestJS 事件](https://docs.nestjs.com/techniques/events)

---

### 1.6 使用 Repository 模式进行数据访问

**影响：高** — 将业务逻辑与数据库解耦

创建自定义 Repository 来封装复杂查询和数据库逻辑。这可以使服务专注于业务逻辑，通过 mock repository 使测试更简单，并允许在更改数据库实现时不影响业务代码。

**错误做法（服务中包含复杂查询）：**

```typescript
// 服务中包含复杂查询
@Injectable()
export class UsersService {
  constructor(
    @InjectRepository(User) private repo: Repository<User>,
  ) {}

  async findActiveWithOrders(minOrders: number): Promise<User[]> {
    // 复杂查询逻辑与业务逻辑混合
    return this.repo
      .createQueryBuilder('user')
      .leftJoinAndSelect('user.orders', 'order')
      .where('user.isActive = :active', { active: true })
      .andWhere('user.deletedAt IS NULL')
      .groupBy('user.id')
      .having('COUNT(order.id) >= :min', { min: minOrders })
      .orderBy('user.createdAt', 'DESC')
      .getMany();
  }

  // 服务变得臃肿，充满查询逻辑
}
```

**正确做法（封装查询的自定义 Repository）：**

```typescript
// 封装查询的自定义 Repository
@Injectable()
export class UsersRepository {
  constructor(
    @InjectRepository(User) private repo: Repository<User>,
  ) {}

  async findById(id: string): Promise<User | null> {
    return this.repo.findOne({ where: { id } });
  }

  async findByEmail(email: string): Promise<User | null> {
    return this.repo.findOne({ where: { email } });
  }

  async findActiveWithMinOrders(minOrders: number): Promise<User[]> {
    return this.repo
      .createQueryBuilder('user')
      .leftJoinAndSelect('user.orders', 'order')
      .where('user.isActive = :active', { active: true })
      .andWhere('user.deletedAt IS NULL')
      .groupBy('user.id')
      .having('COUNT(order.id) >= :min', { min: minOrders })
      .orderBy('user.createdAt', 'DESC')
      .getMany();
  }

  async save(user: User): Promise<User> {
    return this.repo.save(user);
  }
}

// 仅包含业务逻辑的干净服务
@Injectable()
export class UsersService {
  constructor(private usersRepo: UsersRepository) {}

  async getActiveUsersWithOrders(): Promise<User[]> {
    return this.usersRepo.findActiveWithMinOrders(1);
  }

  async create(dto: CreateUserDto): Promise<User> {
    const existing = await this.usersRepo.findByEmail(dto.email);
    if (existing) {
      throw new ConflictException('Email already registered');
    }

    const user = new User();
    user.email = dto.email;
    user.name = dto.name;
    return this.usersRepo.save(user);
  }
}
```

参考: [Repository 模式](https://martinfowler.com/eaaCatalog/repository.html)

---

## 2. 依赖注入

**章节影响：关键**

### 2.1 避免服务定位器反模式

**影响：高** — 隐藏依赖并破坏可测试性

避免使用 `ModuleRef.get()` 或全局容器在运行时解析依赖。这会隐藏依赖，使代码更难测试，并破坏依赖注入的优势。应使用构造函数注入。

**错误做法（服务定位器反模式）：**

```typescript
// 使用 ModuleRef 动态获取依赖
@Injectable()
export class OrdersService {
  constructor(private moduleRef: ModuleRef) {}

  async createOrder(dto: CreateOrderDto): Promise<Order> {
    // 依赖被隐藏 - 构造函数中不可见
    const usersService = this.moduleRef.get(UsersService);
    const inventoryService = this.moduleRef.get(InventoryService);
    const paymentService = this.moduleRef.get(PaymentService);

    const user = await usersService.findOne(dto.userId);
    // ... 其余逻辑
  }
}

// 全局单例容器
class ServiceContainer {
  private static instance: ServiceContainer;
  private services = new Map<string, any>();

  static getInstance(): ServiceContainer {
    if (!this.instance) {
      this.instance = new ServiceContainer();
    }
    return this.instance;
  }

  get<T>(key: string): T {
    return this.services.get(key);
  }
}
```

**正确做法（显式依赖的构造函数注入）：**

```typescript
// 使用构造函数注入 - 依赖是显式的
@Injectable()
export class OrdersService {
  constructor(
    private usersService: UsersService,
    private inventoryService: InventoryService,
    private paymentService: PaymentService,
  ) {}

  async createOrder(dto: CreateOrderDto): Promise<Order> {
    const user = await this.usersService.findOne(dto.userId);
    const inventory = await this.inventoryService.check(dto.items);
    // 依赖清晰且可测试
  }
}

// 易于使用 mock 进行测试
describe('OrdersService', () => {
  let service: OrdersService;

  beforeEach(async () => {
    const module = await Test.createTestingModule({
      providers: [
        OrdersService,
        { provide: UsersService, useValue: mockUsersService },
        { provide: InventoryService, useValue: mockInventoryService },
        { provide: PaymentService, useValue: mockPaymentService },
      ],
    }).compile();

    service = module.get(OrdersService);
  });
});

// 有效：用于动态实例化的工厂模式
@Injectable()
export class HandlerFactory {
  constructor(private moduleRef: ModuleRef) {}

  getHandler(type: string): Handler {
    switch (type) {
      case 'email':
        return this.moduleRef.get(EmailHandler);
      case 'sms':
        return this.moduleRef.get(SmsHandler);
      default:
        return this.moduleRef.get(DefaultHandler);
    }
  }
}
```

参考: [NestJS 模块引用](https://docs.nestjs.com/fundamentals/module-ref)

---

### 2.2 应用接口隔离原则

**影响：高** — 降低耦合，提升可测试性 30-50%

客户端不应被迫依赖它们不使用的接口。在 NestJS 中，这意味着保持接口小而精，专注于特定的能力，而不是创建捆绑了不相关方法的"胖"接口。当一个服务只需要发送邮件时，它不应该依赖一个还包含短信、推送通知和日志的接口。将大型接口拆分为基于角色的接口。

**错误做法（强制未使用依赖的胖接口）：**

```typescript
// 胖接口 - 强制所有消费者依赖所有内容
interface NotificationService {
  sendEmail(to: string, subject: string, body: string): Promise<void>;
  sendSms(phone: string, message: string): Promise<void>;
  sendPush(userId: string, notification: PushPayload): Promise<void>;
  sendSlack(channel: string, message: string): Promise<void>;
  logNotification(type: string, payload: any): Promise<void>;
  getDeliveryStatus(id: string): Promise<DeliveryStatus>;
  retryFailed(id: string): Promise<void>;
  scheduleNotification(dto: ScheduleDto): Promise<string>;
}

// 消费者只需要邮件，但为了测试必须 mock 所有内容
@Injectable()
export class OrdersService {
  constructor(
    private notifications: NotificationService, // 依赖 8 个方法，只用 1 个
  ) {}

  async confirmOrder(order: Order): Promise<void> {
    await this.notifications.sendEmail(
      order.customer.email,
      'Order Confirmed',
      `Your order ${order.id} has been confirmed.`,
    );
  }
}

// 测试很痛苦 - 必须 mock 未使用的方法
const mockNotificationService = {
  sendEmail: jest.fn(),
  sendSms: jest.fn(),           // 从未使用，但必需
  sendPush: jest.fn(),          // 从未使用，但必需
  sendSlack: jest.fn(),         // 从未使用，但必需
  logNotification: jest.fn(),   // 从未使用，但必需
  getDeliveryStatus: jest.fn(), // 从未使用，但必需
  retryFailed: jest.fn(),       // 从未使用，但必需
  scheduleNotification: jest.fn(), // 从未使用，但必需
};
```

**正确做法（按能力隔离的接口）：**

```typescript
// 隔离的接口 - 每个专注于一项能力
interface EmailSender {
  sendEmail(to: string, subject: string, body: string): Promise<void>;
}

interface SmsSender {
  sendSms(phone: string, message: string): Promise<void>;
}

interface PushSender {
  sendPush(userId: string, notification: PushPayload): Promise<void>;
}

interface NotificationLogger {
  logNotification(type: string, payload: any): Promise<void>;
}

interface NotificationScheduler {
  scheduleNotification(dto: ScheduleDto): Promise<string>;
}

// 实现可以实现多个接口
@Injectable()
export class NotificationService implements EmailSender, SmsSender, PushSender {
  async sendEmail(to: string, subject: string, body: string): Promise<void> {
    // 邮件实现
  }

  async sendSms(phone: string, message: string): Promise<void> {
    // 短信实现
  }

  async sendPush(userId: string, notification: PushPayload): Promise<void> {
    // 推送实现
  }
}

// 或者独立的实现
@Injectable()
export class SendGridEmailService implements EmailSender {
  async sendEmail(to: string, subject: string, body: string): Promise<void> {
    // SendGrid 特定实现
  }
}

// 消费者只依赖它需要的内容
@Injectable()
export class OrdersService {
  constructor(
    @Inject(EMAIL_SENDER) private emailSender: EmailSender, // 最小依赖
  ) {}

  async confirmOrder(order: Order): Promise<void> {
    await this.emailSender.sendEmail(
      order.customer.email,
      'Order Confirmed',
      `Your order ${order.id} has been confirmed.`,
    );
  }
}

// 测试很简单 - 只 mock 使用的内容
const mockEmailSender: EmailSender = {
  sendEmail: jest.fn(),
};

// 使用令牌的模块注册
export const EMAIL_SENDER = Symbol('EMAIL_SENDER');
export const SMS_SENDER = Symbol('SMS_SENDER');

@Module({
  providers: [
    { provide: EMAIL_SENDER, useClass: SendGridEmailService },
    { provide: SMS_SENDER, useClass: TwilioSmsService },
  ],
  exports: [EMAIL_SENDER, SMS_SENDER],
})
export class NotificationModule {}
```

**需要时组合接口：**

```typescript
// 有时消费者确实需要多种能力
interface EmailAndSmsSender extends EmailSender, SmsSender {}

// 或使用交叉类型
type MultiChannelSender = EmailSender & SmsSender & PushSender;

// 真正需要多通道的消费者
@Injectable()
export class AlertService {
  constructor(
    @Inject(MULTI_CHANNEL_SENDER)
    private sender: EmailSender & SmsSender,
  ) {}

  async sendCriticalAlert(user: User, message: string): Promise<void> {
    await Promise.all([
      this.sender.sendEmail(user.email, 'Critical Alert', message),
      this.sender.sendSms(user.phone, message),
    ]);
  }
}
```

参考: [接口隔离原则](https://en.wikipedia.org/wiki/Interface_segregation_principle)

---

### 2.3 遵循里氏替换原则

**影响：高** — 确保实现在不破坏调用方的情况下真正可互换

子类型必须能够替换其基类型而不改变程序的正确性。在 NestJS 的依赖注入中，这意味着接口或抽象类的任何实现都必须完全遵循约定。测试中使用的 mock 支付服务必须像真实的支付服务一样行为（返回相似的形状，以相同方式处理错误）。违反 LSP 会在交换实现时导致微妙的错误。

**错误做法（实现违反约定）：**

```typescript
// 具有明确约定的基础接口
interface PaymentGateway {
  /**
   * Charges the specified amount.
   * @returns PaymentResult on success
   * @throws PaymentFailedException on payment failure
   */
  charge(amount: number, currency: string): Promise<PaymentResult>;
}

// 生产实现 - 遵循约定
@Injectable()
export class StripeService implements PaymentGateway {
  async charge(amount: number, currency: string): Promise<PaymentResult> {
    const response = await this.stripe.charges.create({ amount, currency });
    return { success: true, transactionId: response.id, amount };
  }
}

// 违反 LSP 的 mock - 不同的行为！
@Injectable()
export class MockPaymentService implements PaymentGateway {
  async charge(amount: number, currency: string): Promise<PaymentResult> {
    // 违反 1：对有效输入抛出异常（约定说返回 PaymentResult）
    if (amount > 1000) {
      throw new Error('Mock does not support large amounts');
    }

    // 违反 2：返回 null 而不是 PaymentResult
    if (currency !== 'USD') {
      return null as any; // 真实服务会正确转换或拒绝
    }

    // 违反 3：缺少必需字段
    return { success: true } as PaymentResult; // 缺少 transactionId！
  }
}

// 消费者信任约定
@Injectable()
export class OrdersService {
  constructor(@Inject(PAYMENT_GATEWAY) private payment: PaymentGateway) {}

  async checkout(order: Order): Promise<void> {
    const result = await this.payment.charge(order.total, order.currency);
    // 使用 MockPaymentService 时会失败：
    await this.saveTransaction(result.transactionId); // undefined！
    await this.sendReceipt(result); // 可能是 null！
  }
}
```

**正确做法（遵循约定的实现）：**

```typescript
// 带有文档化行为的明确定义的接口
interface PaymentGateway {
  /**
   * Charges the specified amount.
   * @param amount - Amount in smallest currency unit (cents)
   * @param currency - ISO 4217 currency code
   * @returns PaymentResult with transactionId, success status, and amount
   * @throws PaymentFailedException if charge is declined
   * @throws InvalidCurrencyException if currency is not supported
   */
  charge(amount: number, currency: string): Promise<PaymentResult>;

  /**
   * Refunds a previous charge.
   * @throws TransactionNotFoundException if transactionId is invalid
   */
  refund(transactionId: string, amount?: number): Promise<RefundResult>;
}

// 生产实现
@Injectable()
export class StripeService implements PaymentGateway {
  async charge(amount: number, currency: string): Promise<PaymentResult> {
    try {
      const response = await this.stripe.charges.create({ amount, currency });
      return {
        success: true,
        transactionId: response.id,
        amount: response.amount,
      };
    } catch (error) {
      if (error.type === 'card_error') {
        throw new PaymentFailedException(error.message);
      }
      throw error;
    }
  }

  async refund(transactionId: string, amount?: number): Promise<RefundResult> {
    // 实现...
  }
}

// 遵循 LSP 的 mock - 相同的约定，相同的行为形状
@Injectable()
export class MockPaymentService implements PaymentGateway {
  private transactions = new Map<string, PaymentResult>();

  async charge(amount: number, currency: string): Promise<PaymentResult> {
    // 遵循约定：像真实服务一样验证货币
    if (!['USD', 'EUR', 'GBP'].includes(currency)) {
      throw new InvalidCurrencyException(`Unsupported currency: ${currency}`);
    }

    // 为特定测试场景模拟拒绝
    if (amount === 99999) {
      throw new PaymentFailedException('Card declined (test scenario)');
    }

    // 返回与生产相同的形状
    const result: PaymentResult = {
      success: true,
      transactionId: `mock_${Date.now()}_${Math.random().toString(36)}`,
      amount,
    };

    this.transactions.set(result.transactionId, result);
    return result;
  }

  async refund(transactionId: string, amount?: number): Promise<RefundResult> {
    // 遵循约定：如果未找到交易则抛出异常
    if (!this.transactions.has(transactionId)) {
      throw new TransactionNotFoundException(transactionId);
    }

    return {
      success: true,
      refundId: `refund_${transactionId}`,
      amount: amount ?? this.transactions.get(transactionId)!.amount,
    };
  }
}

// 消费者可以安全地交换实现
@Injectable()
export class OrdersService {
  constructor(@Inject(PAYMENT_GATEWAY) private payment: PaymentGateway) {}

  async checkout(order: Order): Promise<Order> {
    try {
      const result = await this.payment.charge(order.total, order.currency);
      // 同时适用于 StripeService 和 MockPaymentService
      order.transactionId = result.transactionId;
      order.status = 'paid';
      return order;
    } catch (error) {
      if (error instanceof PaymentFailedException) {
        order.status = 'payment_failed';
        return order;
      }
      throw error;
    }
  }
}
```

**测试 LSP 合规性：**

```typescript
// 任何实现都必须通过的共享测试套件
function testPaymentGatewayContract(
  createGateway: () => PaymentGateway,
) {
  describe('PaymentGateway contract', () => {
    let gateway: PaymentGateway;

    beforeEach(() => {
      gateway = createGateway();
    });

    it('返回所有必需字段的 PaymentResult', async () => {
      const result = await gateway.charge(1000, 'USD');
      expect(result).toHaveProperty('success');
      expect(result).toHaveProperty('transactionId');
      expect(result).toHaveProperty('amount');
      expect(typeof result.transactionId).toBe('string');
    });

    it('对不支持的货币抛出 InvalidCurrencyException', async () => {
      await expect(gateway.charge(1000, 'INVALID'))
        .rejects.toThrow(InvalidCurrencyException);
    });

    it('对无效退款抛出 TransactionNotFoundException', async () => {
      await expect(gateway.refund('nonexistent'))
        .rejects.toThrow(TransactionNotFoundException);
    });
  });
}

// 对所有实现运行
describe('StripeService', () => {
  testPaymentGatewayContract(() => new StripeService(mockStripeClient));
});

describe('MockPaymentService', () => {
  testPaymentGatewayContract(() => new MockPaymentService());
});
```

参考: [里氏替换原则](https://en.wikipedia.org/wiki/Liskov_substitution_principle)

---

### 2.4 优先使用构造函数注入

**影响：关键** — 实现正确 DI 和测试的必要条件

始终使用构造函数注入而非属性注入。构造函数注入使依赖显式化，启用 TypeScript 类型检查，确保实例化时依赖可用，并提高可测试性。这是实现正确 DI、测试和 TypeScript 支持的必要条件。

**错误做法（隐藏依赖的属性注入）：**

```typescript
// 属性注入 - 除非必要，否则避免
@Injectable()
export class UsersService {
  @Inject()
  private userRepo: UserRepository; // 隐藏的依赖

  @Inject('CONFIG')
  private config: ConfigType; // 也是隐藏的

  async findAll() {
    return this.userRepo.find();
  }
}

// 问题：
// 1. 构造函数中看不到依赖
// 2. 在测试中可以无依赖实例化服务
// 3. TypeScript 无法在实例化时强制执行依赖类型
```

**正确做法（显式依赖的构造函数注入）：**

```typescript
// 构造函数注入 - 显式且可测试
@Injectable()
export class UsersService {
  constructor(
    private readonly userRepo: UserRepository,
    @Inject('CONFIG') private readonly config: ConfigType,
  ) {}

  async findAll(): Promise<User[]> {
    return this.userRepo.find();
  }
}

// 测试很直接
describe('UsersService', () => {
  let service: UsersService;
  let mockRepo: jest.Mocked<UserRepository>;

  beforeEach(() => {
    mockRepo = {
      find: jest.fn(),
      save: jest.fn(),
    } as any;

    service = new UsersService(mockRepo, { dbUrl: 'test' });
  });

  it('应该找到所有用户', async () => {
    mockRepo.find.mockResolvedValue([{ id: '1', name: 'Test' }]);
    const result = await service.findAll();
    expect(result).toHaveLength(1);
  });
});

// 仅对可选的依赖使用属性注入
@Injectable()
export class LoggingService {
  @Optional()
  @Inject('ANALYTICS')
  private analytics?: AnalyticsService;

  log(message: string) {
    console.log(message);
    this.analytics?.track('log', message); // 可选增强
  }
}
```

参考: [NestJS Providers](https://docs.nestjs.com/providers)

---

### 2.5 理解 Provider 作用域

**影响：关键** — 防止数据泄漏和性能问题

NestJS 有三种 provider 作用域：DEFAULT（单例）、REQUEST（每个请求一个实例）和 TRANSIENT（每次注入一个新实例）。大多数 provider 应为单例。请求作用域的 provider 具有性能影响，因为它们会在依赖树中向上冒泡。理解作用域可以防止内存泄漏和不正确的数据共享。

**错误做法（错误的作用域使用）：**

```typescript
// 不需要时使用请求作用域（性能影响）
@Injectable({ scope: Scope.REQUEST })
export class UsersService {
  // 这会为每个请求创建新实例
  // 所有依赖也会变为请求作用域
  async findAll() {
    return this.userRepo.find();
  }
}

// 带有可变请求状态的单例
@Injectable() // 默认：单例
export class RequestContextService {
  private userId: string; // 危险：在所有请求间共享！

  setUser(userId: string) {
    this.userId = userId; // 覆盖所有并发请求的值
  }

  getUser() {
    return this.userId; // 返回错误的用户！
  }
}
```

**正确做法（每种用例的合适作用域）：**

```typescript
// 无状态服务的单例（默认，最常见）
@Injectable()
export class UsersService {
  constructor(private readonly userRepo: UserRepository) {}

  async findById(id: string): Promise<User> {
    return this.userRepo.findOne({ where: { id } });
  }
}

// 仅在需要请求上下文时使用请求作用域
@Injectable({ scope: Scope.REQUEST })
export class RequestContextService {
  private userId: string;

  setUser(userId: string) {
    this.userId = userId;
  }

  getUser(): string {
    return this.userId;
  }
}

// 更好：使用 NestJS 内置的请求上下文
import { REQUEST } from '@nestjs/core';
import { Request } from 'express';

@Injectable({ scope: Scope.REQUEST })
export class AuditService {
  constructor(@Inject(REQUEST) private request: Request) {}

  log(action: string) {
    console.log(`User ${this.request.user?.id} performed ${action}`);
  }
}

// 最佳：使用 ClsModule 实现异步上下文（无作用域冒泡）
import { ClsService } from 'nestjs-cls';

@Injectable() // 保持单例！
export class AuditService {
  constructor(private cls: ClsService) {}

  log(action: string) {
    const userId = this.cls.get('userId');
    console.log(`User ${userId} performed ${action}`);
  }
}
```

参考: [NestJS 注入作用域](https://docs.nestjs.com/fundamentals/injection-scopes)

---

### 2.6 为接口使用注入令牌

**影响：高** — 在运行时实现基于接口的 DI

TypeScript 接口在编译时被擦除，不能用作注入令牌。当你想要注入接口的实现时，使用字符串令牌、符号或抽象类。这允许为测试或不同环境交换实现。

**错误做法（接口不能用作令牌）：**

```typescript
// 接口不能用作注入令牌
interface PaymentGateway {
  charge(amount: number): Promise<PaymentResult>;
}

@Injectable()
export class StripeService implements PaymentGateway {
  charge(amount: number) { /* ... */ }
}

@Injectable()
export class OrdersService {
  // 这行不通 - PaymentGateway 在运行时不存在
  constructor(private payment: PaymentGateway) {}
}
```

**正确做法（符号令牌或抽象类）：**

```typescript
// 选项 1：字符串/符号令牌（最灵活）
export const PAYMENT_GATEWAY = Symbol('PAYMENT_GATEWAY');

export interface PaymentGateway {
  charge(amount: number): Promise<PaymentResult>;
}

@Injectable()
export class StripeService implements PaymentGateway {
  async charge(amount: number): Promise<PaymentResult> {
    // Stripe 实现
  }
}

@Injectable()
export class MockPaymentService implements PaymentGateway {
  async charge(amount: number): Promise<PaymentResult> {
    return { success: true, id: 'mock-id' };
  }
}

// 模块注册
@Module({
  providers: [
    {
      provide: PAYMENT_GATEWAY,
      useClass: process.env.NODE_ENV === 'test'
        ? MockPaymentService
        : StripeService,
    },
  ],
  exports: [PAYMENT_GATEWAY],
})
export class PaymentModule {}

// 注入
@Injectable()
export class OrdersService {
  constructor(
    @Inject(PAYMENT_GATEWAY) private payment: PaymentGateway,
  ) {}

  async createOrder(dto: CreateOrderDto) {
    await this.payment.charge(dto.amount);
  }
}

// 选项 2：抽象类（携带运行时类型信息）
export abstract class PaymentGateway {
  abstract charge(amount: number): Promise<PaymentResult>;
}

@Injectable()
export class StripeService extends PaymentGateway {
  async charge(amount: number): Promise<PaymentResult> {
    // 实现
  }
}

// 使用抽象类不需要 @Inject
@Injectable()
export class OrdersService {
  constructor(private payment: PaymentGateway) {}
}
```

参考: [NestJS 自定义 Providers](https://docs.nestjs.com/fundamentals/custom-providers)

---

## 3. 错误处理

**章节影响：高**

### 3.1 正确处理异步错误

**影响：高** — 防止未处理的 rejection 导致进程崩溃

NestJS 会自动捕获异步路由处理器的错误，但来自后台任务、事件处理器和手动创建的 Promise 的错误可能会使应用程序崩溃。始终显式处理异步错误，并使用全局处理器作为安全网。

**错误做法（fire-and-forget 无错误处理）：**

```typescript
// Fire-and-forget 无错误处理
@Injectable()
export class UsersService {
  async createUser(dto: CreateUserDto): Promise<User> {
    const user = await this.repo.save(dto);

    // Fire and forget - 如果失败，错误未处理！
    this.emailService.sendWelcome(user.email);

    return user;
  }
}

// 事件处理器中未处理的 Promise
@Injectable()
export class OrdersService {
  @OnEvent('order.created')
  handleOrderCreated(event: OrderCreatedEvent) {
    // 返回了一个 Promise 但没有 await！
    this.processOrder(event);
    // 错误会导致进程崩溃
  }

  private async processOrder(event: OrderCreatedEvent): Promise<void> {
    await this.inventoryService.reserve(event.items);
    await this.notificationService.send(event.userId);
  }
}

// 定时任务中缺少 try-catch
@Cron('0 0 * * *')
async dailyCleanup(): Promise<void> {
  await this.cleanupService.run();
  // 如果抛出错误，没有错误处理
}
```

**正确做法（显式的异步错误处理）：**

```typescript
// 使用显式 catch 处理 fire-and-forget
@Injectable()
export class UsersService {
  private readonly logger = new Logger(UsersService.name);

  async createUser(dto: CreateUserDto): Promise<User> {
    const user = await this.repo.save(dto);

    // 显式捕获并记录错误
    this.emailService.sendWelcome(user.email).catch((error) => {
      this.logger.error('Failed to send welcome email', error.stack);
      // 可选：加入重试队列
    });

    return user;
  }
}

// 正确处理异步事件处理器
@Injectable()
export class OrdersService {
  private readonly logger = new Logger(OrdersService.name);

  @OnEvent('order.created')
  async handleOrderCreated(event: OrderCreatedEvent): Promise<void> {
    try {
      await this.processOrder(event);
    } catch (error) {
      this.logger.error('Failed to process order', { event, error });
      // 不要重新抛出 - 会导致进程崩溃
      await this.deadLetterQueue.add('order.created', event);
    }
  }
}

// 安全的定时任务
@Injectable()
export class CleanupService {
  private readonly logger = new Logger(CleanupService.name);

  @Cron('0 0 * * *')
  async dailyCleanup(): Promise<void> {
    try {
      await this.cleanupService.run();
      this.logger.log('Daily cleanup completed');
    } catch (error) {
      this.logger.error('Daily cleanup failed', error.stack);
      // 告警或重试逻辑
    }
  }
}

// main.ts 中的全局未处理 rejection 处理器
async function bootstrap() {
  const app = await NestFactory.create(AppModule);
  const logger = new Logger('Bootstrap');

  process.on('unhandledRejection', (reason, promise) => {
    logger.error('Unhandled Rejection at:', promise, 'reason:', reason);
  });

  process.on('uncaughtException', (error) => {
    logger.error('Uncaught Exception:', error);
    process.exit(1);
  });

  await app.listen(3000);
}
```

参考: [Node.js 未处理 Rejections](https://nodejs.org/api/process.html#event-unhandledrejection)

---

### 3.2 从服务中抛出 HTTP 异常

**影响：高** — 保持控制器精简并简化错误处理

在 HTTP 应用中，从服务中抛出 `HttpException` 子类是允许的（通常更可取）。这可以使控制器保持精简，并允许服务传达适当的错误状态。对于真正与层无关的服务，使用映射到 HTTP 状态码的领域异常。

**错误做法（返回错误对象而不是抛出异常）：**

```typescript
// 返回错误对象而不是抛出异常
@Injectable()
export class UsersService {
  async findById(id: string): Promise<{ user?: User; error?: string }> {
    const user = await this.repo.findOne({ where: { id } });
    if (!user) {
      return { error: 'User not found' }; // 控制器必须检查这个
    }
    return { user };
  }
}

@Controller('users')
export class UsersController {
  @Get(':id')
  async findOne(@Param('id') id: string) {
    const result = await this.usersService.findById(id);
    if (result.error) {
      throw new NotFoundException(result.error);
    }
    return result.user;
  }
}
```

**正确做法（从服务直接抛出异常）：**

```typescript
// 从服务直接抛出异常
@Injectable()
export class UsersService {
  constructor(private readonly repo: UserRepository) {}

  async findById(id: string): Promise<User> {
    const user = await this.repo.findOne({ where: { id } });
    if (!user) {
      throw new NotFoundException(`User #${id} not found`);
    }
    return user;
  }

  async create(dto: CreateUserDto): Promise<User> {
    const existing = await this.repo.findOne({
      where: { email: dto.email },
    });
    if (existing) {
      throw new ConflictException('Email already registered');
    }
    return this.repo.save(dto);
  }

  async update(id: string, dto: UpdateUserDto): Promise<User> {
    const user = await this.findById(id); // 如果未找到则抛出异常
    Object.assign(user, dto);
    return this.repo.save(user);
  }
}

// 控制器保持精简
@Controller('users')
export class UsersController {
  @Get(':id')
  findOne(@Param('id') id: string): Promise<User> {
    return this.usersService.findById(id);
  }

  @Post()
  create(@Body() dto: CreateUserDto): Promise<User> {
    return this.usersService.create(dto);
  }
}

// 对于与层无关的服务，使用领域异常
export class EntityNotFoundException extends Error {
  constructor(
    public readonly entity: string,
    public readonly id: string,
  ) {
    super(`${entity} with ID "${id}" not found`);
  }
}

// 在异常过滤器中映射到 HTTP
@Catch(EntityNotFoundException)
export class EntityNotFoundFilter implements ExceptionFilter {
  catch(exception: EntityNotFoundException, host: ArgumentsHost) {
    const ctx = host.switchToHttp();
    const response = ctx.getResponse<Response>();

    response.status(404).json({
      statusCode: 404,
      message: exception.message,
      entity: exception.entity,
      id: exception.id,
    });
  }
}
```

参考: [NestJS 异常过滤器](https://docs.nestjs.com/exception-filters)

---

### 3.3 使用异常过滤器处理错误

**影响：高** — 一致、集中化的错误处理

永远不要在控制器中捕获异常并手动格式化错误响应。使用 NestJS 异常过滤器在应用程序中一致地处理错误。为特定错误类型创建自定义异常过滤器，并为未处理的异常创建全局过滤器。

**错误做法（控制器中的手动错误处理）：**

```typescript
// 控制器中的手动错误处理
@Controller('users')
export class UsersController {
  @Get(':id')
  async findOne(@Param('id') id: string, @Res() res: Response) {
    try {
      const user = await this.usersService.findById(id);
      if (!user) {
        return res.status(404).json({
          statusCode: 404,
          message: 'User not found',
        });
      }
      return res.json(user);
    } catch (error) {
      console.error(error);
      return res.status(500).json({
        statusCode: 500,
        message: 'Internal server error',
      });
    }
  }
}
```

**正确做法（一致处理的异常过滤器）：**

```typescript
// 使用内置和自定义异常
@Controller('users')
export class UsersController {
  @Get(':id')
  async findOne(@Param('id') id: string): Promise<User> {
    const user = await this.usersService.findById(id);
    if (!user) {
      throw new NotFoundException(`User #${id} not found`);
    }
    return user;
  }
}

// 自定义领域异常
export class UserNotFoundException extends NotFoundException {
  constructor(userId: string) {
    super({
      statusCode: 404,
      error: 'Not Found',
      message: `User with ID "${userId}" not found`,
      code: 'USER_NOT_FOUND',
    });
  }
}

// 领域错误的自定义异常过滤器
@Catch(DomainException)
export class DomainExceptionFilter implements ExceptionFilter {
  catch(exception: DomainException, host: ArgumentsHost) {
    const ctx = host.switchToHttp();
    const response = ctx.getResponse<Response>();
    const request = ctx.getRequest<Request>();

    const status = exception.getStatus?.() || 400;

    response.status(status).json({
      statusCode: status,
      code: exception.code,
      message: exception.message,
      timestamp: new Date().toISOString(),
      path: request.url,
    });
  }
}

// 未处理错误的全局异常过滤器
@Catch()
export class AllExceptionsFilter implements ExceptionFilter {
  constructor(private readonly logger: Logger) {}

  catch(exception: unknown, host: ArgumentsHost) {
    const ctx = host.switchToHttp();
    const response = ctx.getResponse<Response>();
    const request = ctx.getRequest<Request>();

    const status =
      exception instanceof HttpException
        ? exception.getStatus()
        : HttpStatus.INTERNAL_SERVER_ERROR;

    const message =
      exception instanceof HttpException
        ? exception.message
        : 'Internal server error';

    this.logger.error(
      `${request.method} ${request.url}`,
      exception instanceof Error ? exception.stack : exception,
    );

    response.status(status).json({
      statusCode: status,
      message,
      timestamp: new Date().toISOString(),
      path: request.url,
    });
  }
}

// 在 main.ts 中全局注册
app.useGlobalFilters(
  new AllExceptionsFilter(app.get(Logger)),
  new DomainExceptionFilter(),
);

// 或通过模块注册
@Module({
  providers: [
    {
      provide: APP_FILTER,
      useClass: AllExceptionsFilter,
    },
  ],
})
export class AppModule {}
```

参考: [NestJS 异常过滤器](https://docs.nestjs.com/exception-filters)

---

## 4. 安全

**章节影响：高**

### 4.1 实现安全的 JWT 认证

**影响：关键** — 对安全 API 至关重要

使用 `@nestjs/jwt` 配合 `@nestjs/passport` 进行认证。安全存储密钥，使用适当的令牌生命周期，实现刷新令牌，并正确验证令牌。切勿在 JWT 负载中暴露敏感数据。

**错误做法（不安全的 JWT 实现）：**

```typescript
// 硬编码密钥
@Module({
  imports: [
    JwtModule.register({
      secret: 'my-secret-key', // 在代码中暴露
      signOptions: { expiresIn: '7d' }, // 太长
    }),
  ],
})
export class AuthModule {}

// 在 JWT 中存储敏感数据
async login(user: User): Promise<{ accessToken: string }> {
  const payload = {
    sub: user.id,
    email: user.email,
    password: user.password, // 永远不要包含密码！
    ssn: user.ssn, // 永远不要包含敏感数据！
    isAdmin: user.isAdmin, // 如果不验证则可能被篡改
  };
  return { accessToken: this.jwtService.sign(payload) };
}

// 跳过令牌验证
@Injectable()
export class JwtStrategy extends PassportStrategy(Strategy) {
  constructor() {
    super({
      jwtFromRequest: ExtractJwt.fromAuthHeaderAsBearerToken(),
      secretOrKey: 'my-secret',
    });
  }

  async validate(payload: any): Promise<any> {
    return payload; // 未验证用户是否存在
  }
}
```

**正确做法（带刷新令牌的安全 JWT）：**

```typescript
// 安全的 JWT 配置
@Module({
  imports: [
    JwtModule.registerAsync({
      imports: [ConfigModule],
      inject: [ConfigService],
      useFactory: (config: ConfigService) => ({
        secret: config.get<string>('JWT_SECRET'),
        signOptions: {
          expiresIn: '15m', // 短生命周期的访问令牌
          issuer: config.get<string>('JWT_ISSUER'),
          audience: config.get<string>('JWT_AUDIENCE'),
        },
      }),
    }),
    PassportModule.register({ defaultStrategy: 'jwt' }),
  ],
})
export class AuthModule {}

// 最小 JWT 负载
@Injectable()
export class AuthService {
  async login(user: User): Promise<TokenResponse> {
    // 只包含必要的非敏感数据
    const payload: JwtPayload = {
      sub: user.id,
      email: user.email,
      roles: user.roles,
      iat: Math.floor(Date.now() / 1000),
    };

    const accessToken = this.jwtService.sign(payload);
    const refreshToken = await this.createRefreshToken(user.id);

    return { accessToken, refreshToken, expiresIn: 900 };
  }

  private async createRefreshToken(userId: string): Promise<string> {
    const token = randomBytes(32).toString('hex');
    const hashedToken = await bcrypt.hash(token, 10);

    await this.refreshTokenRepo.save({
      userId,
      token: hashedToken,
      expiresAt: new Date(Date.now() + 7 * 24 * 60 * 60 * 1000), // 7 天
    });

    return token;
  }
}

// 带验证的正确 JWT 策略
@Injectable()
export class JwtStrategy extends PassportStrategy(Strategy) {
  constructor(
    private config: ConfigService,
    private usersService: UsersService,
  ) {
    super({
      jwtFromRequest: ExtractJwt.fromAuthHeaderAsBearerToken(),
      secretOrKey: config.get<string>('JWT_SECRET'),
      ignoreExpiration: false,
      issuer: config.get<string>('JWT_ISSUER'),
      audience: config.get<string>('JWT_AUDIENCE'),
    });
  }

  async validate(payload: JwtPayload): Promise<User> {
    // 验证用户仍然存在且活跃
    const user = await this.usersService.findById(payload.sub);

    if (!user || !user.isActive) {
      throw new UnauthorizedException('User not found or inactive');
    }

    // 验证令牌不是在密码更改前签发的
    if (user.passwordChangedAt) {
      const tokenIssuedAt = new Date(payload.iat * 1000);
      if (tokenIssuedAt < user.passwordChangedAt) {
        throw new UnauthorizedException('Token invalidated by password change');
      }
    }

    return user;
  }
}
```

参考: [NestJS 认证](https://docs.nestjs.com/security/authentication)

---

### 4.2 实现速率限制

**影响：高** — 防止滥用并确保公平的资源使用

使用 `@nestjs/throttler` 限制每个客户端的请求速率。为不同端点应用不同的限制——认证端点更严格，读操作更宽松。考虑在集群部署中使用 Redis 实现分布式速率限制。

**错误做法（敏感端点无速率限制）：**

```typescript
// 敏感端点无速率限制
@Controller('auth')
export class AuthController {
  @Post('login')
  async login(@Body() dto: LoginDto): Promise<TokenResponse> {
    // 攻击者可以暴力破解凭据
    return this.authService.login(dto);
  }

  @Post('forgot-password')
  async forgotPassword(@Body() dto: ForgotPasswordDto): Promise<void> {
    // 可能被滥用来向用户发送垃圾邮件
    return this.authService.sendResetEmail(dto.email);
  }
}

// 所有端点相同的限制
@UseGuards(ThrottlerGuard)
@Controller('api')
export class ApiController {
  @Get('public-data')
  async getPublic() {} // 应该允许更多请求

  @Post('process-payment')
  async payment() {} // 应该更严格
}
```

**正确做法（配置了多限制和端点特定限制的 throttler）：**

```typescript
// 全局配置带有多重限制的 throttler
import { ThrottlerModule, ThrottlerGuard } from '@nestjs/throttler';

@Module({
  imports: [
    ThrottlerModule.forRoot([
      {
        name: 'short',
        ttl: 1000, // 1 秒
        limit: 3, // 每秒 3 个请求
      },
      {
        name: 'medium',
        ttl: 10000, // 10 秒
        limit: 20, // 每 10 秒 20 个请求
      },
      {
        name: 'long',
        ttl: 60000, // 1 分钟
        limit: 100, // 每分钟 100 个请求
      },
    ]),
  ],
  providers: [
    {
      provide: APP_GUARD,
      useClass: ThrottlerGuard,
    },
  ],
})
export class AppModule {}

// 按端点覆盖限制
@Controller('auth')
export class AuthController {
  @Post('login')
  @Throttle({ short: { limit: 5, ttl: 60000 } }) // 每分钟 5 次尝试
  async login(@Body() dto: LoginDto): Promise<TokenResponse> {
    return this.authService.login(dto);
  }

  @Post('forgot-password')
  @Throttle({ short: { limit: 3, ttl: 3600000 } }) // 每小时 3 次
  async forgotPassword(@Body() dto: ForgotPasswordDto): Promise<void> {
    return this.authService.sendResetEmail(dto.email);
  }
}

// 跳过某些路由的限流
@Controller('health')
export class HealthController {
  @Get()
  @SkipThrottle()
  check(): string {
    return 'OK';
  }
}

// 按用户类型的自定义限流
@Injectable()
export class CustomThrottlerGuard extends ThrottlerGuard {
  protected async getTracker(req: Request): Promise<string> {
    // 如果已认证使用用户 ID，否则使用 IP
    return req.user?.id || req.ip;
  }

  protected async getLimit(context: ExecutionContext): Promise<number> {
    const request = context.switchToHttp().getRequest();

    // 已认证用户有更高的限制
    if (request.user) {
      return request.user.isPremium ? 1000 : 200;
    }

    return 50; // 匿名用户
  }
}
```

参考: [NestJS 速率限制](https://docs.nestjs.com/security/rate-limiting)

---

### 4.3 对输出进行清理以防止 XSS

**影响：高** — XSS 漏洞可能危及用户会话和数据

虽然 NestJS API 通常返回 JSON（浏览器不会执行），但在渲染 HTML、存储用户内容或前端框架不当处理 API 响应时，仍然存在 XSS 风险。在存储前对用户生成的内容进行清理，并使用正确的 Content-Type 头。

**错误做法（存储未经清理的原始 HTML）：**

```typescript
// 存储来自用户的原始 HTML
@Injectable()
export class CommentsService {
  async create(dto: CreateCommentDto): Promise<Comment> {
    // 用户可以注入：<script>steal(document.cookie)</script>
    return this.repo.save({
      content: dto.content, // 原始，未经清理
      authorId: dto.authorId,
    });
  }
}

// 返回未经清理的 HTML
@Controller('pages')
export class PagesController {
  @Get(':slug')
  @Header('Content-Type', 'text/html')
  async getPage(@Param('slug') slug: string): Promise<string> {
    const page = await this.pagesService.findBySlug(slug);
    // 如果 page.content 包含用户输入，可能存在 XSS
    return `<html><body>${page.content}</body></html>`;
  }
}

// 在错误中反射用户输入
@Get(':id')
async findOne(@Param('id') id: string): Promise<User> {
  const user = await this.repo.findOne({ where: { id } });
  if (!user) {
    // 如果 id 包含恶意内容且错误被渲染，存在 XSS
    throw new NotFoundException(`User ${id} not found`);
  }
  return user;
}
```

**正确做法（清理内容并使用正确的头部）：**

```typescript
// 存储前清理 HTML 内容
import * as sanitizeHtml from 'sanitize-html';

@Injectable()
export class CommentsService {
  private readonly sanitizeOptions: sanitizeHtml.IOptions = {
    allowedTags: ['b', 'i', 'em', 'strong', 'a', 'p', 'br'],
    allowedAttributes: {
      a: ['href', 'title'],
    },
    allowedSchemes: ['http', 'https', 'mailto'],
  };

  async create(dto: CreateCommentDto): Promise<Comment> {
    return this.repo.save({
      content: sanitizeHtml(dto.content, this.sanitizeOptions),
      authorId: dto.authorId,
    });
  }
}

// 使用验证管道去除 HTML
import { Transform } from 'class-transformer';

export class CreatePostDto {
  @IsString()
  @MaxLength(1000)
  @Transform(({ value }) => sanitizeHtml(value, { allowedTags: [] }))
  title: string;

  @IsString()
  @Transform(({ value }) =>
    sanitizeHtml(value, {
      allowedTags: ['p', 'br', 'b', 'i', 'a'],
      allowedAttributes: { a: ['href'] },
    }),
  )
  content: string;
}

// 设置正确的 Content-Type 头
@Controller('api')
export class ApiController {
  @Get('data')
  @Header('Content-Type', 'application/json')
  async getData(): Promise<DataResponse> {
    // JSON 响应 - 浏览器不会执行脚本
    return this.service.getData();
  }
}

// 清理错误消息
@Get(':id')
async findOne(@Param('id', ParseUUIDPipe) id: string): Promise<User> {
  const user = await this.repo.findOne({ where: { id } });
  if (!user) {
    // UUID 验证确保格式安全
    throw new NotFoundException('User not found');
  }
  return user;
}

// 使用 Helmet 设置 CSP 头
import helmet from 'helmet';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);

  app.use(
    helmet({
      contentSecurityPolicy: {
        directives: {
          defaultSrc: ["'self'"],
          scriptSrc: ["'self'"],
          styleSrc: ["'self'", "'unsafe-inline'"],
          imgSrc: ["'self'", 'data:', 'https:'],
        },
      },
    }),
  );

  await app.listen(3000);
}
```

参考: [OWASP XSS 防护](https://cheatsheetseries.owasp.org/cheatsheets/Cross_Site_Scripting_Prevention_Cheat_Sheet.html)

---

### 4.4 使用 Guards 进行认证和授权

**影响：高** — 在处理器执行前强制执行访问控制

Guards 根据认证状态、角色、权限或其他条件决定是否应处理请求。它们在中间件之后、管道和拦截器之前运行，因此非常适合访问控制。使用 guards 而不是在控制器中进行手动检查。

**错误做法（每个处理器中的手动认证检查）：**

```typescript
// 每个处理器中的手动认证检查
@Controller('admin')
export class AdminController {
  @Get('users')
  async getUsers(@Request() req) {
    if (!req.user) {
      throw new UnauthorizedException();
    }
    if (!req.user.roles.includes('admin')) {
      throw new ForbiddenException();
    }
    return this.adminService.getUsers();
  }

  @Delete('users/:id')
  async deleteUser(@Request() req, @Param('id') id: string) {
    if (!req.user) {
      throw new UnauthorizedException();
    }
    if (!req.user.roles.includes('admin')) {
      throw new ForbiddenException();
    }
    return this.adminService.deleteUser(id);
  }
}
```

**正确做法（带声明式装饰器的 guards）：**

```typescript
// JWT 认证 Guard
@Injectable()
export class JwtAuthGuard implements CanActivate {
  constructor(
    private jwtService: JwtService,
    private reflector: Reflector,
  ) {}

  async canActivate(context: ExecutionContext): Promise<boolean> {
    // 检查 @Public() 装饰器
    const isPublic = this.reflector.getAllAndOverride<boolean>('isPublic', [
      context.getHandler(),
      context.getClass(),
    ]);
    if (isPublic) return true;

    const request = context.switchToHttp().getRequest();
    const token = this.extractToken(request);

    if (!token) {
      throw new UnauthorizedException('No token provided');
    }

    try {
      request.user = await this.jwtService.verifyAsync(token);
      return true;
    } catch {
      throw new UnauthorizedException('Invalid token');
    }
  }

  private extractToken(request: Request): string | undefined {
    const [type, token] = request.headers.authorization?.split(' ') ?? [];
    return type === 'Bearer' ? token : undefined;
  }
}

// 角色 Guard
@Injectable()
export class RolesGuard implements CanActivate {
  constructor(private reflector: Reflector) {}

  canActivate(context: ExecutionContext): boolean {
    const requiredRoles = this.reflector.getAllAndOverride<Role[]>('roles', [
      context.getHandler(),
      context.getClass(),
    ]);

    if (!requiredRoles) return true;

    const { user } = context.switchToHttp().getRequest();
    return requiredRoles.some((role) => user.roles?.includes(role));
  }
}

// 装饰器
export const Public = () => SetMetadata('isPublic', true);
export const Roles = (...roles: Role[]) => SetMetadata('roles', roles);

// 全局注册 guards
@Module({
  providers: [
    { provide: APP_GUARD, useClass: JwtAuthGuard },
    { provide: APP_GUARD, useClass: RolesGuard },
  ],
})
export class AppModule {}

// 干净的控制器
@Controller('admin')
@Roles(Role.Admin) // 应用于所有路由
export class AdminController {
  @Get('users')
  getUsers(): Promise<User[]> {
    return this.adminService.getUsers();
  }

  @Delete('users/:id')
  deleteUser(@Param('id') id: string): Promise<void> {
    return this.adminService.deleteUser(id);
  }

  @Public() // 覆盖：无需认证
  @Get('health')
  health() {
    return { status: 'ok' };
  }
}
```

参考: [NestJS Guards](https://docs.nestjs.com/guards)

---

### 4.5 使用 DTO 和 Pipes 验证所有输入

**影响：高** — 防御攻击的第一道防线

始终使用 DTO 上的 class-validator 装饰器和全局 ValidationPipe 验证传入数据。永远不要相信用户输入。在处理之前验证所有请求体、查询参数和路由参数。

**错误做法（信任未经验证的原始输入）：**

```typescript
// 信任未经验证的原始输入
@Controller('users')
export class UsersController {
  @Post()
  create(@Body() body: any) {
    // body 可能包含任何内容 - SQL 注入、XSS 等
    return this.usersService.create(body);
  }

  @Get()
  findAll(@Query() query: any) {
    // query.limit 可能是 "'; DROP TABLE users; --"
    return this.usersService.findAll(query.limit);
  }
}

// 无验证装饰器的 DTO
export class CreateUserDto {
  name: string;    // 无验证
  email: string;   // 可能是 "not-an-email"
  age: number;     // 可能是 "abc" 或 -999
}
```

**正确做法（带全局 ValidationPipe 的已验证 DTO）：**

```typescript
// 在 main.ts 中启用全局 ValidationPipe
async function bootstrap() {
  const app = await NestFactory.create(AppModule);

  app.useGlobalPipes(
    new ValidationPipe({
      whitelist: true,              // 去除未知属性
      forbidNonWhitelisted: true,   // 遇到未知属性时抛出错误
      transform: true,              // 自动转换为 DTO 类型
      transformOptions: {
        enableImplicitConversion: true,
      },
    }),
  );

  await app.listen(3000);
}

// 创建经过良好验证的 DTO
import {
  IsString,
  IsEmail,
  IsInt,
  Min,
  Max,
  IsOptional,
  MinLength,
  MaxLength,
  Matches,
  IsNotEmpty,
} from 'class-validator';
import { Transform, Type } from 'class-transformer';

export class CreateUserDto {
  @IsString()
  @IsNotEmpty()
  @MinLength(2)
  @MaxLength(100)
  @Transform(({ value }) => value?.trim())
  name: string;

  @IsEmail()
  @Transform(({ value }) => value?.toLowerCase().trim())
  email: string;

  @IsInt()
  @Min(0)
  @Max(150)
  age: number;

  @IsString()
  @MinLength(8)
  @MaxLength(100)
  @Matches(/^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)/, {
    message: 'Password must contain uppercase, lowercase, and number',
  })
  password: string;
}

// 带默认值和转换的查询 DTO
export class FindUsersQueryDto {
  @IsOptional()
  @IsString()
  @MaxLength(100)
  search?: string;

  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  @Max(100)
  limit: number = 20;

  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(0)
  offset: number = 0;
}

// 参数验证
export class UserIdParamDto {
  @IsUUID('4')
  id: string;
}

@Controller('users')
export class UsersController {
  @Post()
  create(@Body() dto: CreateUserDto): Promise<User> {
    // dto 保证有效
    return this.usersService.create(dto);
  }

  @Get()
  findAll(@Query() query: FindUsersQueryDto): Promise<User[]> {
    // query.limit 是数字，query.search 已清理
    return this.usersService.findAll(query);
  }

  @Get(':id')
  findOne(@Param() params: UserIdParamDto): Promise<User> {
    // params.id 是有效的 UUID
    return this.usersService.findById(params.id);
  }
}
```

参考: [NestJS 验证](https://docs.nestjs.com/techniques/validation)

---

## 5. 性能

**章节影响：高**

### 5.1 正确使用异步生命周期钩子

**影响：高** — 不当的异步处理会阻塞应用程序启动

NestJS 生命周期钩子（`onModuleInit`、`onApplicationBootstrap` 等）支持异步操作。然而，误用它们可能阻塞应用程序启动或导致竞态条件。理解生命周期顺序并适当使用钩子。

**错误做法（fire-and-forget 异步无 await）：**

```typescript
// Fire-and-forget 异步无 await
@Injectable()
export class DatabaseService implements OnModuleInit {
  onModuleInit() {
    // 这确实运行但不阻塞 - 在数据库准备好之前应用就启动了！
    this.connect();
  }

  private async connect() {
    await this.pool.connect();
    console.log('Database connected');
  }
}

// 构造函数中的繁重阻塞操作
@Injectable()
export class ConfigService {
  private config: Config;

  constructor() {
    // 同步阻塞整个模块实例化
    this.config = fs.readFileSync('config.json');
  }
}
```

**正确做法（从异步钩子返回 Promise）：**

```typescript
// 从异步钩子返回 Promise
@Injectable()
export class DatabaseService implements OnModuleInit {
  private pool: Pool;

  async onModuleInit(): Promise<void> {
    // NestJS 等待此操作完成后再继续
    await this.pool.connect();
    console.log('Database connected');
  }

  async onModuleDestroy(): Promise<void> {
    // 关闭时清理资源
    await this.pool.end();
    console.log('Database disconnected');
  }
}

// 对跨模块依赖使用 onApplicationBootstrap
@Injectable()
export class CacheWarmerService implements OnApplicationBootstrap {
  constructor(
    private cache: CacheService,
    private products: ProductsService,
  ) {}

  async onApplicationBootstrap(): Promise<void> {
    // 所有模块都已初始化，可以安全地预热缓存
    const products = await this.products.findPopular();
    await this.cache.warmup(products);
  }
}

// 在异步钩子中执行繁重初始化，而非构造函数
@Injectable()
export class ConfigService implements OnModuleInit {
  private config: Config;

  constructor() {
    // 保持构造函数同步且快速
  }

  async onModuleInit(): Promise<void> {
    // 在生命周期钩子中进行异步加载
    this.config = await this.loadConfig();
  }

  private async loadConfig(): Promise<Config> {
    const file = await fs.promises.readFile('config.json');
    return JSON.parse(file.toString());
  }

  get<T>(key: string): T {
    return this.config[key];
  }
}

// 在 main.ts 中启用关闭钩子
async function bootstrap() {
  const app = await NestFactory.create(AppModule);
  app.enableShutdownHooks(); // 启用 SIGTERM/SIGINT 处理
  await app.listen(3000);
}
```

参考: [NestJS 生命周期事件](https://docs.nestjs.com/fundamentals/lifecycle-events)

---

### 5.2 为大型模块使用懒加载

**影响：中** — 改善大型应用程序的启动时间

NestJS 支持懒加载模块，延迟初始化直到首次使用。这对于某些功能很少使用的大型应用程序、冷启动时间重要的无服务器部署或某些模块具有繁重初始化成本时非常有价值。

**错误做法（急切加载所有内容）：**

```typescript
// 在大型应用中急切加载所有内容
@Module({
  imports: [
    UsersModule,
    OrdersModule,
    PaymentsModule,
    ReportsModule, // 繁重，很少使用
    AnalyticsModule, // 繁重，很少使用
    AdminModule, // 只有管理员使用
    LegacyModule, // 迁移模块，很少使用
    BulkImportModule, // 每月使用一次
  ],
})
export class AppModule {}

// 所有模块在启动时初始化，即使从未使用
// 无服务器环境中冷启动慢
// 未使用的模块浪费内存
```

**正确做法（懒加载很少使用的模块）：**

```typescript
// 对可选模块使用 LazyModuleLoader
import { LazyModuleLoader } from '@nestjs/core';

@Injectable()
export class ReportsService {
  constructor(private lazyModuleLoader: LazyModuleLoader) {}

  async generateReport(type: string): Promise<Report> {
    // 仅在需要时加载模块
    const { ReportsModule } = await import('./reports/reports.module');
    const moduleRef = await this.lazyModuleLoader.load(() => ReportsModule);

    const reportsService = moduleRef.get(ReportsGeneratorService);
    return reportsService.generate(type);
  }
}

// 带缓存的懒加载管理功能
@Injectable()
export class AdminService {
  private adminModule: ModuleRef | null = null;

  constructor(private lazyModuleLoader: LazyModuleLoader) {}

  private async getAdminModule(): Promise<ModuleRef> {
    if (!this.adminModule) {
      const { AdminModule } = await import('./admin/admin.module');
      this.adminModule = await this.lazyModuleLoader.load(() => AdminModule);
    }
    return this.adminModule;
  }

  async runAdminTask(task: string): Promise<void> {
    const moduleRef = await this.getAdminModule();
    const taskRunner = moduleRef.get(AdminTaskRunner);
    await taskRunner.run(task);
  }
}

// 可重用的懒加载器服务
@Injectable()
export class ModuleLoaderService {
  private loadedModules = new Map<string, ModuleRef>();

  constructor(private lazyModuleLoader: LazyModuleLoader) {}

  async load<T>(
    key: string,
    importFn: () => Promise<{ default: Type<T> } | Type<T>>,
  ): Promise<ModuleRef> {
    if (!this.loadedModules.has(key)) {
      const module = await importFn();
      const moduleType = 'default' in module ? module.default : module;
      const moduleRef = await this.lazyModuleLoader.load(() => moduleType);
      this.loadedModules.set(key, moduleRef);
    }
    return this.loadedModules.get(key)!;
  }
}

// 启动后在后台预加载模块
@Injectable()
export class ModulePreloader implements OnApplicationBootstrap {
  constructor(private lazyModuleLoader: LazyModuleLoader) {}

  async onApplicationBootstrap(): Promise<void> {
    setTimeout(async () => {
      await this.preloadModule(() => import('./reports/reports.module'));
    }, 5000); // 启动后 5 秒
  }

  private async preloadModule(importFn: () => Promise<any>): Promise<void> {
    try {
      const module = await importFn();
      const moduleType = module.default || Object.values(module)[0];
      await this.lazyModuleLoader.load(() => moduleType);
    } catch (error) {
      console.warn('Failed to preload module', error);
    }
  }
}
```

参考: [NestJS 懒加载模块](https://docs.nestjs.com/fundamentals/lazy-loading-modules)

---

### 5.3 优化数据库查询

**影响：高** — 数据库查询通常是最大的延迟来源

只选择需要的列，使用适当的索引，避免过度获取关联，并在设计数据访问时考虑查询性能。大多数 API 慢速问题都追溯到低效的数据库查询。

**错误做法（过度获取数据和缺少索引）：**

```typescript
// 只需要几个字段时查询所有内容
@Injectable()
export class UsersService {
  async findAllEmails(): Promise<string[]> {
    const users = await this.repo.find();
    // 获取所有用户的所有列
    return users.map((u) => u.email);
  }

  async getUserSummary(id: string): Promise<UserSummary> {
    const user = await this.repo.findOne({
      where: { id },
      relations: ['posts', 'posts.comments', 'posts.comments.author', 'followers'],
    });
    // 过度获取庞大的关联树
    return { name: user.name, postCount: user.posts.length };
  }
}

// 频繁查询的列上没有索引
@Entity()
export class Order {
  @Column()
  userId: string; // 无索引 - 每次查找全表扫描

  @Column()
  status: string; // 无索引 - 状态过滤慢
}
```

**正确做法（使用适当索引只选择需要的数据）：**

```typescript
// 只选择需要的列
@Injectable()
export class UsersService {
  async findAllEmails(): Promise<string[]> {
    const users = await this.repo.find({
      select: ['email'], // 只获取 email 列
    });
    return users.map((u) => u.email);
  }

  // 对复杂查询使用 QueryBuilder
  async getUserSummary(id: string): Promise<UserSummary> {
    return this.repo
      .createQueryBuilder('user')
      .select('user.name', 'name')
      .addSelect('COUNT(post.id)', 'postCount')
      .leftJoin('user.posts', 'post')
      .where('user.id = :id', { id })
      .groupBy('user.id')
      .getRawOne();
  }

  // 仅在需要时获取关联
  async getFullProfile(id: string): Promise<User> {
    return this.repo.findOne({
      where: { id },
      relations: ['posts'], // 只获取直接关联
      select: {
        id: true,
        name: true,
        email: true,
        posts: {
          id: true,
          title: true,
        },
      },
    });
  }
}

// 在频繁查询的列上添加索引
@Entity()
@Index(['userId'])
@Index(['status'])
@Index(['createdAt'])
@Index(['userId', 'status']) // 常见查询模式的复合索引
export class Order {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column()
  userId: string;

  @Column()
  status: string;

  @CreateDateColumn()
  createdAt: Date;
}

// 始终对大数据集进行分页
@Injectable()
export class OrdersService {
  async findAll(page = 1, limit = 20): Promise<PaginatedResult<Order>> {
    const [items, total] = await this.repo.findAndCount({
      skip: (page - 1) * limit,
      take: limit,
      order: { createdAt: 'DESC' },
    });

    return {
      items,
      meta: {
        page,
        limit,
        total,
        totalPages: Math.ceil(total / limit),
      },
    };
  }
}
```

参考: [TypeORM 查询生成器](https://typeorm.io/select-query-builder)

---

### 5.4 策略性地使用缓存

**影响：高** — 显著降低数据库负载和响应时间

对昂贵操作、频繁访问的数据和外部 API 调用实施缓存。使用 NestJS CacheModule 配合适当的 TTL 和缓存失效策略。不要缓存所有内容——集中在高影响区域。

**错误做法（无缓存或缓存所有内容）：**

```typescript
// 对昂贵、重复的查询无缓存
@Injectable()
export class ProductsService {
  async getPopular(): Promise<Product[]> {
    // 每次请求都运行复杂的聚合查询
    return this.productsRepo
      .createQueryBuilder('p')
      .leftJoin('p.orders', 'o')
      .select('p.*, COUNT(o.id) as orderCount')
      .groupBy('p.id')
      .orderBy('orderCount', 'DESC')
      .limit(20)
      .getMany();
  }
}

// 不加区分地缓存所有内容
@Injectable()
export class UsersService {
  @CacheKey('users')
  @CacheTTL(3600)
  @UseInterceptors(CacheInterceptor)
  async findAll(): Promise<User[]> {
    // 如果数据频繁变化，缓存用户列表 1 小时是错误的
    return this.usersRepo.find();
  }
}
```

**正确做法（带正确失效的策略性缓存）：**

```typescript
// 设置缓存模块
@Module({
  imports: [
    CacheModule.registerAsync({
      imports: [ConfigModule],
      inject: [ConfigService],
      useFactory: (config: ConfigService) => ({
        stores: [
          new KeyvRedis(config.get('REDIS_URL')),
        ],
        ttl: 60 * 1000, // 默认 60 秒
      }),
    }),
  ],
})
export class AppModule {}

// 用于精细控制的手动缓存
@Injectable()
export class ProductsService {
  constructor(
    @Inject(CACHE_MANAGER) private cache: Cache,
    private productsRepo: ProductRepository,
  ) {}

  async getPopular(): Promise<Product[]> {
    const cacheKey = 'products:popular';

    // 先尝试缓存
    const cached = await this.cache.get<Product[]>(cacheKey);
    if (cached) return cached;

    // 缓存未命中 - 查询并缓存
    const products = await this.fetchPopularProducts();
    await this.cache.set(cacheKey, products, 5 * 60 * 1000); // 5 分钟 TTL
    return products;
  }

  // 变更时使缓存失效
  async updateProduct(id: string, dto: UpdateProductDto): Promise<Product> {
    const product = await this.productsRepo.save({ id, ...dto });
    await this.cache.del('products:popular'); // 失效
    return product;
  }
}

// 基于装饰器的缓存，带自动拦截器
@Controller('categories')
@UseInterceptors(CacheInterceptor)
export class CategoriesController {
  @Get()
  @CacheTTL(30 * 60 * 1000) // 30 分钟 - 类别很少变化
  findAll(): Promise<Category[]> {
    return this.categoriesService.findAll();
  }

  @Get(':id')
  @CacheTTL(60 * 1000) // 1 分钟
  @CacheKey('category')
  findOne(@Param('id') id: string): Promise<Category> {
    return this.categoriesService.findOne(id);
  }
}

// 基于事件的缓存失效
@Injectable()
export class CacheInvalidationService {
  constructor(@Inject(CACHE_MANAGER) private cache: Cache) {}

  @OnEvent('product.created')
  @OnEvent('product.updated')
  @OnEvent('product.deleted')
  async invalidateProductCaches(event: ProductEvent) {
    await Promise.all([
      this.cache.del('products:popular'),
      this.cache.del(`product:${event.productId}`),
    ]);
  }
}
```

参考: [NestJS 缓存](https://docs.nestjs.com/techniques/caching)

---

## 6. 测试

**章节影响：中高**

### 6.1 使用 Supertest 进行 E2E 测试

**影响：高** — 验证完整的请求/响应周期

端到端测试使用 Supertest 对 NestJS 应用程序发起真实的 HTTP 请求。它们测试完整的堆栈，包括中间件、guards、pipes 和拦截器。E2E 测试能捕获单元测试遗漏的集成问题。

**错误做法（无正确的 E2E 设置或清理）：**

```typescript
// 仅对控制器进行单元测试
describe('UsersController', () => {
  it('should return users', async () => {
    const service = { findAll: jest.fn().mockResolvedValue([]) };
    const controller = new UsersController(service as any);

    const result = await controller.findAll();

    expect(result).toEqual([]);
    // 未测试：路由、guards、pipes、序列化
  });
});

// 无正确设置/清理的 E2E 测试
describe('Users API', () => {
  it('should create user', async () => {
    const app = await NestFactory.create(AppModule);
    // 未正确初始化
    // 测试后无清理
    // 命中真实数据库
  });
});
```

**正确做法（使用 Supertest 的正确 E2E 设置）：**

```typescript
// 正确的 E2E 测试设置
import { Test, TestingModule } from '@nestjs/testing';
import { INestApplication, ValidationPipe } from '@nestjs/common';
import * as request from 'supertest';
import { AppModule } from '../src/app.module';

describe('UsersController (e2e)', () => {
  let app: INestApplication;

  beforeAll(async () => {
    const moduleFixture: TestingModule = await Test.createTestingModule({
      imports: [AppModule],
    }).compile();

    app = moduleFixture.createNestApplication();

    // 应用与生产相同的配置
    app.useGlobalPipes(
      new ValidationPipe({
        whitelist: true,
        transform: true,
        forbidNonWhitelisted: true,
      }),
    );

    await app.init();
  });

  afterAll(async () => {
    await app.close();
  });

  describe('/users (POST)', () => {
    it('should create a user', () => {
      return request(app.getHttpServer())
        .post('/users')
        .send({ name: 'John', email: 'john@test.com' })
        .expect(201)
        .expect((res) => {
          expect(res.body).toHaveProperty('id');
          expect(res.body.name).toBe('John');
          expect(res.body.email).toBe('john@test.com');
        });
    });

    it('should return 400 for invalid email', () => {
      return request(app.getHttpServer())
        .post('/users')
        .send({ name: 'John', email: 'invalid-email' })
        .expect(400)
        .expect((res) => {
          expect(res.body.message).toContain('email');
        });
    });
  });

  describe('/users/:id (GET)', () => {
    it('should return 404 for non-existent user', () => {
      return request(app.getHttpServer())
        .get('/users/non-existent-id')
        .expect(404);
    });
  });
});

// 带认证的测试
describe('Protected Routes (e2e)', () => {
  let app: INestApplication;
  let authToken: string;

  beforeAll(async () => {
    const moduleFixture = await Test.createTestingModule({
      imports: [AppModule],
    }).compile();

    app = moduleFixture.createNestApplication();
    app.useGlobalPipes(new ValidationPipe({ whitelist: true }));
    await app.init();

    // 获取认证令牌
    const loginResponse = await request(app.getHttpServer())
      .post('/auth/login')
      .send({ email: 'test@test.com', password: 'password' });

    authToken = loginResponse.body.accessToken;
  });

  it('should return 401 without token', () => {
    return request(app.getHttpServer())
      .get('/users/me')
      .expect(401);
  });

  it('should return user profile with valid token', () => {
    return request(app.getHttpServer())
      .get('/users/me')
      .set('Authorization', `Bearer ${authToken}`)
      .expect(200)
      .expect((res) => {
        expect(res.body.email).toBe('test@test.com');
      });
  });
});

// E2E 测试的数据库隔离
describe('Orders API (e2e)', () => {
  let app: INestApplication;
  let dataSource: DataSource;

  beforeAll(async () => {
    const moduleFixture = await Test.createTestingModule({
      imports: [
        ConfigModule.forRoot({
          envFilePath: '.env.test', // 测试数据库配置
        }),
        AppModule,
      ],
    }).compile();

    app = moduleFixture.createNestApplication();
    dataSource = moduleFixture.get(DataSource);
    await app.init();
  });

  beforeEach(async () => {
    // 在测试之间清理数据库
    await dataSource.synchronize(true);
  });

  afterAll(async () => {
    await dataSource.destroy();
    await app.close();
  });
});
```

参考: [NestJS E2E 测试](https://docs.nestjs.com/fundamentals/testing#end-to-end-testing)

---

### 6.2 在测试中模拟外部服务

**影响：高** — 确保快速、可靠、确定性的测试

永远不要在单元测试中调用真实的外部服务（API、数据库、消息队列）。模拟它们以确保测试快速、确定性且不产生费用。使用逼真的 mock 数据并测试超时和错误等边界情况。

**错误做法（调用真实 API 和数据库）：**

```typescript
// 在测试中调用真实 API
describe('PaymentService', () => {
  it('should process payment', async () => {
    const service = new PaymentService(new StripeClient(realApiKey));
    // 命中真实的 Stripe API！
    const result = await service.charge('tok_visa', 1000);
    // 慢、花钱、不稳定
  });
});

// 使用真实数据库
describe('UsersService', () => {
  beforeEach(async () => {
    await connection.query('DELETE FROM users'); // 修改真实数据库
  });

  it('should create user', async () => {
    const user = await service.create({ email: 'test@test.com' });
    // 对共享数据库产生副作用
  });
});

// 不完整的 mock
const mockHttpService = {
  get: jest.fn().mockResolvedValue({ data: {} }),
  // 缺少错误场景，缺少其他方法
};
```

**正确做法（模拟所有外部依赖）：**

```typescript
// 正确模拟 HTTP 服务
describe('WeatherService', () => {
  let service: WeatherService;
  let httpService: jest.Mocked<HttpService>;

  beforeEach(async () => {
    const module = await Test.createTestingModule({
      providers: [
        WeatherService,
        {
          provide: HttpService,
          useValue: {
            get: jest.fn(),
            post: jest.fn(),
          },
        },
      ],
    }).compile();

    service = module.get(WeatherService);
    httpService = module.get(HttpService);
  });

  it('should return weather data', async () => {
    const mockResponse = {
      data: { temperature: 72, humidity: 45 },
      status: 200,
      statusText: 'OK',
      headers: {},
      config: {},
    };

    httpService.get.mockReturnValue(of(mockResponse));

    const result = await service.getWeather('NYC');

    expect(result).toEqual({ temperature: 72, humidity: 45 });
  });

  it('should handle API timeout', async () => {
    httpService.get.mockReturnValue(
      throwError(() => new Error('ETIMEDOUT')),
    );

    await expect(service.getWeather('NYC')).rejects.toThrow('Weather service unavailable');
  });

  it('should handle rate limiting', async () => {
    httpService.get.mockReturnValue(
      throwError(() => ({
        response: { status: 429, data: { message: 'Rate limited' } },
      })),
    );

    await expect(service.getWeather('NYC')).rejects.toThrow(TooManyRequestsException);
  });
});

// 模拟 Repository 而不是数据库
describe('UsersService', () => {
  let service: UsersService;
  let repo: jest.Mocked<Repository<User>>;

  beforeEach(async () => {
    const mockRepo = {
      find: jest.fn(),
      findOne: jest.fn(),
      save: jest.fn(),
      delete: jest.fn(),
      createQueryBuilder: jest.fn(),
    };

    const module = await Test.createTestingModule({
      providers: [
        UsersService,
        { provide: getRepositoryToken(User), useValue: mockRepo },
      ],
    }).compile();

    service = module.get(UsersService);
    repo = module.get(getRepositoryToken(User));
  });

  it('should find user by id', async () => {
    const mockUser = { id: '1', name: 'John', email: 'john@test.com' };
    repo.findOne.mockResolvedValue(mockUser);

    const result = await service.findById('1');

    expect(result).toEqual(mockUser);
    expect(repo.findOne).toHaveBeenCalledWith({ where: { id: '1' } });
  });
});

// 为复杂 SDK 创建 mock 工厂
function createMockStripe(): jest.Mocked<Stripe> {
  return {
    paymentIntents: {
      create: jest.fn(),
      retrieve: jest.fn(),
      confirm: jest.fn(),
      cancel: jest.fn(),
    },
    customers: {
      create: jest.fn(),
      retrieve: jest.fn(),
    },
  } as any;
}

// 为时间相关测试模拟时间
describe('TokenService', () => {
  beforeEach(() => {
    jest.useFakeTimers();
    jest.setSystemTime(new Date('2024-01-15'));
  });

  afterEach(() => {
    jest.useRealTimers();
  });

  it('should expire token after 1 hour', async () => {
    const token = await service.createToken();

    // 快进时间
    jest.advanceTimersByTime(61 * 60 * 1000);

    expect(await service.isValid(token)).toBe(false);
  });
});
```

参考: [Jest Mocking](https://jestjs.io/docs/mock-functions)

---

### 6.3 使用 Testing Module 进行单元测试

**影响：高** — 支持使用模拟依赖进行正确的隔离测试

使用 `@nestjs/testing` 模块创建带有模拟依赖的隔离测试环境。这确保测试运行快速，不依赖外部服务，并能正确隔离地测试业务逻辑。

**错误做法（绕过 DI 的手动实例化）：**

```typescript
// 无 DI 的手动实例化服务
describe('UsersService', () => {
  it('should create user', async () => {
    // 手动实例化绕过 DI
    const repo = new UserRepository(); // 真实 repo！
    const service = new UsersService(repo);

    const user = await service.create({ name: 'Test' });
    // 这会命中真实数据库！
  });
});

// 测试实现细节
describe('UsersController', () => {
  it('should call service', async () => {
    const service = { create: jest.fn() };
    const controller = new UsersController(service as any);

    await controller.create({ name: 'Test' });

    expect(service.create).toHaveBeenCalled(); // 测试实现，而非行为
  });
});
```

**正确做法（使用 Test.createTestingModule 配合模拟依赖）：**

```typescript
// 使用 Test.createTestingModule 进行正确的 DI
import { Test, TestingModule } from '@nestjs/testing';

describe('UsersService', () => {
  let service: UsersService;
  let repo: jest.Mocked<UserRepository>;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        UsersService,
        {
          provide: UserRepository,
          useValue: {
            save: jest.fn(),
            findOne: jest.fn(),
            find: jest.fn(),
          },
        },
      ],
    }).compile();

    service = module.get<UsersService>(UsersService);
    repo = module.get(UserRepository);
  });

  afterEach(() => {
    jest.clearAllMocks();
  });

  describe('create', () => {
    it('应该保存并返回用户', async () => {
      const dto = { name: 'John', email: 'john@test.com' };
      const expectedUser = { id: '1', ...dto };

      repo.save.mockResolvedValue(expectedUser);

      const result = await service.create(dto);

      expect(result).toEqual(expectedUser);
      expect(repo.save).toHaveBeenCalledWith(dto);
    });

    it('重复邮箱应抛出错误', async () => {
      repo.findOne.mockResolvedValue({ id: '1', email: 'test@test.com' });

      await expect(
        service.create({ name: 'Test', email: 'test@test.com' }),
      ).rejects.toThrow(ConflictException);
    });
  });

  describe('findById', () => {
    it('找到用户时应返回', async () => {
      const user = { id: '1', name: 'John' };
      repo.findOne.mockResolvedValue(user);

      const result = await service.findById('1');

      expect(result).toEqual(user);
    });

    it('未找到时应抛出 NotFoundException', async () => {
      repo.findOne.mockResolvedValue(null);

      await expect(service.findById('999')).rejects.toThrow(NotFoundException);
    });
  });
});

// 测试 Guards 和 Interceptors
describe('RolesGuard', () => {
  let guard: RolesGuard;
  let reflector: Reflector;

  beforeEach(async () => {
    const module = await Test.createTestingModule({
      providers: [RolesGuard, Reflector],
    }).compile();

    guard = module.get<RolesGuard>(RolesGuard);
    reflector = module.get<Reflector>(Reflector);
  });

  it('不需要角色时应允许通过', () => {
    const context = createMockExecutionContext({ user: { roles: [] } });
    jest.spyOn(reflector, 'getAllAndOverride').mockReturnValue(undefined);

    expect(guard.canActivate(context)).toBe(true);
  });

  it('管理员路由应允许管理员', () => {
    const context = createMockExecutionContext({ user: { roles: ['admin'] } });
    jest.spyOn(reflector, 'getAllAndOverride').mockReturnValue(['admin']);

    expect(guard.canActivate(context)).toBe(true);
  });
});

function createMockExecutionContext(request: Partial<Request>): ExecutionContext {
  return {
    switchToHttp: () => ({
      getRequest: () => request,
    }),
    getHandler: () => jest.fn(),
    getClass: () => jest.fn(),
  } as ExecutionContext;
}
```

参考: [NestJS 测试](https://docs.nestjs.com/fundamentals/testing)

---

## 7. 数据库与 ORM

**章节影响：中高**

### 7.1 避免 N+1 查询问题

**影响：高** — N+1 查询是最常见的性能杀手之一

当获取一个实体列表，然后为每个实体额外查询一次以加载相关数据时，就会发生 N+1 查询。使用带有 `relations` 的急切加载、查询构建器连接或 DataLoader 来高效地批量查询。

**错误做法（循环中的懒加载导致 N+1）：**

```typescript
// 循环中的懒加载导致 N+1
@Injectable()
export class OrdersService {
  async getOrdersWithItems(userId: string): Promise<Order[]> {
    const orders = await this.orderRepo.find({ where: { userId } });
    // 1 个订单查询

    for (const order of orders) {
      // N 个额外查询 - 每个订单一个！
      order.items = await this.itemRepo.find({ where: { orderId: order.id } });
    }

    return orders;
  }
}

// 访问懒加载关联但不加载
@Controller('users')
export class UsersController {
  @Get()
  async findAll(): Promise<User[]> {
    const users = await this.userRepo.find();
    // 如果 User.posts 是懒加载的，序列化会触发 N 个查询
    return users; // 每个 user.posts 访问 = 1 个查询
  }
}
```

**正确做法（使用 relations 进行急切加载）：**

```typescript
// 使用 relations 选项进行急切加载
@Injectable()
export class OrdersService {
  async getOrdersWithItems(userId: string): Promise<Order[]> {
    // 单次查询，使用 JOIN
    return this.orderRepo.find({
      where: { userId },
      relations: ['items', 'items.product'],
    });
  }
}

// 对复杂连接使用 QueryBuilder
@Injectable()
export class UsersService {
  async getUsersWithPostCounts(): Promise<UserWithPostCount[]> {
    return this.userRepo
      .createQueryBuilder('user')
      .leftJoin('user.posts', 'post')
      .select('user.id', 'id')
      .addSelect('user.name', 'name')
      .addSelect('COUNT(post.id)', 'postCount')
      .groupBy('user.id')
      .getRawMany();
  }

  async getActiveUsersWithPosts(): Promise<User[]> {
    return this.userRepo
      .createQueryBuilder('user')
      .leftJoinAndSelect('user.posts', 'post')
      .leftJoinAndSelect('post.comments', 'comment')
      .where('user.isActive = :active', { active: true })
      .andWhere('post.status = :status', { status: 'published' })
      .getMany();
  }
}

// 对特定字段使用查找选项
async getOrderSummaries(userId: string): Promise<OrderSummary[]> {
  return this.orderRepo.find({
    where: { userId },
    relations: ['items'],
    select: {
      id: true,
      total: true,
      status: true,
      items: {
        id: true,
        quantity: true,
        price: true,
      },
    },
  });
}

// 使用 DataLoader 进行 GraphQL 批量查询和缓存
import DataLoader from 'dataloader';

@Injectable({ scope: Scope.REQUEST })
export class PostsLoader {
  constructor(private postsService: PostsService) {}

  readonly batchPosts = new DataLoader<string, Post[]>(async (userIds) => {
    // 一次查询所有用户的帖子
    const posts = await this.postsService.findByUserIds([...userIds]);

    // 按 userId 分组
    const postsMap = new Map<string, Post[]>();
    for (const post of posts) {
      const userPosts = postsMap.get(post.userId) || [];
      userPosts.push(post);
      postsMap.set(post.userId, userPosts);
    }

    // 按输入顺序返回
    return userIds.map((id) => postsMap.get(id) || []);
  });
}

// 在 resolver 中
@ResolveField()
async posts(@Parent() user: User): Promise<Post[]> {
  // DataLoader 将多次调用批量为单个查询
  return this.postsLoader.batchPosts.load(user.id);
}

// 在开发中启用查询日志以检测 N+1
TypeOrmModule.forRoot({
  logging: ['query', 'error'],
  logger: 'advanced-console',
});
```

参考: [TypeORM 关联](https://typeorm.io/relations)

---

### 7.2 使用数据库迁移

**影响：高** — 支持安全、可重复的数据库模式更改

永远不要在生产中使用 `synchronize: true`。对所有模式更改使用迁移。迁移为数据库提供版本控制，支持安全回滚，并确保所有环境之间的一致性。

**错误做法（使用 synchronize 或手动 SQL）：**

```typescript
// 在生产中使用 synchronize
TypeOrmModule.forRoot({
  type: 'postgres',
  synchronize: true, // 生产环境危险！
  // 可能删除列、表或数据
});

// 生产中的手动 SQL
@Injectable()
export class DatabaseService {
  async addColumn(): Promise<void> {
    await this.dataSource.query('ALTER TABLE users ADD COLUMN age INT');
    // 无版本控制，无回滚，环境间不一致
  }
}

// 修改实体但不创建迁移
@Entity()
export class User {
  @Column()
  email: string;

  @Column() // 无迁移添加
  newField: string; // 如果 synchronize 为 false，会在生产中崩溃
}
```

**正确做法（对所有模式更改使用迁移）：**

```typescript
// 为迁移配置 TypeORM
// data-source.ts
export const dataSource = new DataSource({
  type: 'postgres',
  host: process.env.DB_HOST,
  port: parseInt(process.env.DB_PORT),
  username: process.env.DB_USERNAME,
  password: process.env.DB_PASSWORD,
  database: process.env.DB_NAME,
  entities: ['dist/**/*.entity.js'],
  migrations: ['dist/migrations/*.js'],
  synchronize: false, // 生产中始终为 false
  migrationsRun: true, // 启动时运行迁移
});

// app.module.ts
TypeOrmModule.forRootAsync({
  inject: [ConfigService],
  useFactory: (config: ConfigService) => ({
    type: 'postgres',
    host: config.get('DB_HOST'),
    synchronize: config.get('NODE_ENV') === 'development', // 仅在开发中
    migrations: ['dist/migrations/*.js'],
    migrationsRun: true,
  }),
});

// migrations/1705312800000-AddUserAge.ts
import { MigrationInterface, QueryRunner } from 'typeorm';

export class AddUserAge1705312800000 implements MigrationInterface {
  name = 'AddUserAge1705312800000';

  public async up(queryRunner: QueryRunner): Promise<void> {
    // 添加带默认值的列以处理现有行
    await queryRunner.query(`
      ALTER TABLE "users" ADD "age" integer DEFAULT 0
    `);

    // 为频繁查询的列添加索引
    await queryRunner.query(`
      CREATE INDEX "IDX_users_age" ON "users" ("age")
    `);
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    // 始终实现 down 以支持回滚
    await queryRunner.query(`DROP INDEX "IDX_users_age"`);
    await queryRunner.query(`ALTER TABLE "users" DROP COLUMN "age"`);
  }
}

// 安全的列重命名（两步）
export class RenameNameToFullName1705312900000 implements MigrationInterface {
  public async up(queryRunner: QueryRunner): Promise<void> {
    // 第 1 步：添加新列
    await queryRunner.query(`
      ALTER TABLE "users" ADD "full_name" varchar(255)
    `);

    // 第 2 步：复制数据
    await queryRunner.query(`
      UPDATE "users" SET "full_name" = "name"
    `);

    // 第 3 步：添加 NOT NULL 约束
    await queryRunner.query(`
      ALTER TABLE "users" ALTER COLUMN "full_name" SET NOT NULL
    `);

    // 第 4 步：删除旧列（确认应用程序工作正常后）
    await queryRunner.query(`
      ALTER TABLE "users" DROP COLUMN "name"
    `);
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`ALTER TABLE "users" ADD "name" varchar(255)`);
    await queryRunner.query(`UPDATE "users" SET "name" = "full_name"`);
    await queryRunner.query(`ALTER TABLE "users" DROP COLUMN "full_name"`);
  }
}
```

参考: [TypeORM 迁移](https://typeorm.io/migrations)

---

### 7.3 对多步操作使用事务

**影响：高** — 确保多步操作中的数据一致性

当多个数据库操作必须全部成功或全部失败时，将它们包装在事务中。这可以防止部分更新导致数据不一致。使用 TypeORM 的事务 API 或 DataSource 查询运行器处理复杂场景。

**错误做法（无事务的多重保存）：**

```typescript
// 无事务的多重保存
@Injectable()
export class OrdersService {
  async createOrder(userId: string, items: OrderItem[]): Promise<Order> {
    // 如果任何步骤失败，数据将不一致
    const order = await this.orderRepo.save({ userId, status: 'pending' });

    for (const item of items) {
      await this.orderItemRepo.save({ orderId: order.id, ...item });
      await this.inventoryRepo.decrement({ productId: item.productId }, 'stock', item.quantity);
    }

    await this.paymentService.charge(order.id);
    // 如果支付失败，订单和库存已被修改！

    return order;
  }
}
```

**正确做法（使用 DataSource.transaction 实现自动回滚）：**

```typescript
// 使用 DataSource.transaction() 实现自动回滚
@Injectable()
export class OrdersService {
  constructor(private dataSource: DataSource) {}

  async createOrder(userId: string, items: OrderItem[]): Promise<Order> {
    return this.dataSource.transaction(async (manager) => {
      // 所有操作使用同一个事务管理器
      const order = await manager.save(Order, { userId, status: 'pending' });

      for (const item of items) {
        await manager.save(OrderItem, { orderId: order.id, ...item });
        await manager.decrement(
          Inventory,
          { productId: item.productId },
          'stock',
          item.quantity,
        );
      }

      // 如果这里抛出异常，所有操作都会回滚
      await this.paymentService.chargeWithManager(manager, order.id);

      return order;
    });
  }
}

// 使用 QueryRunner 进行手动事务控制
@Injectable()
export class TransferService {
  constructor(private dataSource: DataSource) {}

  async transfer(fromId: string, toId: string, amount: number): Promise<void> {
    const queryRunner = this.dataSource.createQueryRunner();
    await queryRunner.connect();
    await queryRunner.startTransaction();

    try {
      // 扣减源账户
      await queryRunner.manager.decrement(
        Account,
        { id: fromId },
        'balance',
        amount,
      );

      // 验证资金充足
      const source = await queryRunner.manager.findOne(Account, {
        where: { id: fromId },
      });
      if (source.balance < 0) {
        throw new BadRequestException('Insufficient funds');
      }

      // 增加目标账户
      await queryRunner.manager.increment(
        Account,
        { id: toId },
        'balance',
        amount,
      );

      // 记录交易日志
      await queryRunner.manager.save(TransactionLog, {
        fromId,
        toId,
        amount,
        timestamp: new Date(),
      });

      await queryRunner.commitTransaction();
    } catch (error) {
      await queryRunner.rollbackTransaction();
      throw error;
    } finally {
      await queryRunner.release();
    }
  }
}

// 支持事务的 Repository 方法
@Injectable()
export class UsersRepository {
  constructor(
    @InjectRepository(User) private repo: Repository<User>,
    private dataSource: DataSource,
  ) {}

  async createWithProfile(
    userData: CreateUserDto,
    profileData: CreateProfileDto,
  ): Promise<User> {
    return this.dataSource.transaction(async (manager) => {
      const user = await manager.save(User, userData);
      await manager.save(Profile, { ...profileData, userId: user.id });
      return user;
    });
  }
}
```

参考: [TypeORM 事务](https://typeorm.io/transactions)

---

## 8. API 设计

**章节影响：中**

### 8.1 使用 DTO 和序列化处理 API 响应

**影响：中** — 响应 DTO 防止意外数据暴露并确保一致性

永远不要直接从控制器返回实体对象。使用响应 DTO 配合 class-transformer 的 `@Exclude()` 和 `@Expose()` 装饰器精确控制发送给客户端的数据。这可以防止意外暴露敏感字段，并提供稳定的 API 契约。

**错误做法（直接返回实体或手动解构）：**

```typescript
// 直接返回实体
@Controller('users')
export class UsersController {
  @Get(':id')
  async findOne(@Param('id') id: string): Promise<User> {
    return this.usersService.findById(id);
    // 返回：{ id, email, passwordHash, ssn, internalNotes, ... }
    // 暴露敏感数据！
  }
}

// 手动对象解构（容易出错）
@Get(':id')
async findOne(@Param('id') id: string) {
  const user = await this.usersService.findById(id);
  return {
    id: user.id,
    email: user.email,
    name: user.name,
    // 容易忘记排除敏感字段
    // 跨端点难以维护
  };
}
```

**正确做法（使用 class-transformer 配合 @Exclude 和响应 DTO）：**

```typescript
// 全局启用 class-transformer
async function bootstrap() {
  const app = await NestFactory.create(AppModule);
  app.useGlobalInterceptors(new ClassSerializerInterceptor(app.get(Reflector)));
  await app.listen(3000);
}

// 带序列化控制的实体
@Entity()
export class User {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column()
  email: string;

  @Column()
  name: string;

  @Column()
  @Exclude() // 绝不包含在响应中
  passwordHash: string;

  @Column({ nullable: true })
  @Exclude()
  ssn: string;

  @Column({ default: false })
  @Exclude({ toPlainOnly: true }) // 从响应中排除，允许在请求中包含
  isAdmin: boolean;

  @CreateDateColumn()
  createdAt: Date;

  @Column()
  @Exclude()
  internalNotes: string;
}

// 现在返回实体是安全的
@Controller('users')
export class UsersController {
  @Get(':id')
  async findOne(@Param('id') id: string): Promise<User> {
    return this.usersService.findById(id);
    // 返回：{ id, email, name, createdAt }
    // 敏感字段自动排除
  }
}

// 对于不同的响应形状，使用显式 DTO
export class UserResponseDto {
  @Expose()
  id: string;

  @Expose()
  email: string;

  @Expose()
  name: string;

  @Expose()
  @Transform(({ obj }) => obj.posts?.length || 0)
  postCount: number;

  constructor(partial: Partial<User>) {
    Object.assign(this, partial);
  }
}

export class UserDetailResponseDto extends UserResponseDto {
  @Expose()
  createdAt: Date;

  @Expose()
  @Type(() => PostResponseDto)
  posts: PostResponseDto[];
}

// 使用显式 DTO 的控制器
@Controller('users')
export class UsersController {
  @Get()
  @SerializeOptions({ type: UserResponseDto })
  async findAll(): Promise<UserResponseDto[]> {
    const users = await this.usersService.findAll();
    return users.map(u => plainToInstance(UserResponseDto, u));
  }

  @Get(':id')
  async findOne(@Param('id') id: string): Promise<UserDetailResponseDto> {
    const user = await this.usersService.findByIdWithPosts(id);
    return plainToInstance(UserDetailResponseDto, user, {
      excludeExtraneousValues: true,
    });
  }
}

// 条件序列化的分组
export class UserDto {
  @Expose()
  id: string;

  @Expose()
  name: string;

  @Expose({ groups: ['admin'] })
  email: string;

  @Expose({ groups: ['admin'] })
  createdAt: Date;

  @Expose({ groups: ['admin', 'owner'] })
  settings: UserSettings;
}

@Controller('users')
export class UsersController {
  @Get()
  @SerializeOptions({ groups: ['public'] })
  async findAllPublic(): Promise<UserDto[]> {
    // 返回：{ id, name }
  }

  @Get('admin')
  @UseGuards(AdminGuard)
  @SerializeOptions({ groups: ['admin'] })
  async findAllAdmin(): Promise<UserDto[]> {
    // 返回：{ id, name, email, createdAt }
  }

  @Get('me')
  @SerializeOptions({ groups: ['owner'] })
  async getProfile(@CurrentUser() user: User): Promise<UserDto> {
    // 返回：{ id, name, settings }
  }
}
```

参考: [NestJS 序列化](https://docs.nestjs.com/techniques/serialization)

---

### 8.2 使用拦截器处理横切关注点

**影响：中高** — 拦截器为横切逻辑提供干净的分离

拦截器可以转换响应、添加日志、处理缓存和测量性能，而不会污染业务逻辑。它们包装路由处理器的执行，让你可以访问请求和响应流。

**错误做法（每个方法中都包含日志和转换）：**

```typescript
// 每个控制器方法中都包含日志
@Controller('users')
export class UsersController {
  @Get()
  async findAll(): Promise<User[]> {
    const start = Date.now();
    this.logger.log('findAll called');

    const users = await this.usersService.findAll();

    this.logger.log(`findAll completed in ${Date.now() - start}ms`);
    return users;
  }

  @Get(':id')
  async findOne(@Param('id') id: string): Promise<User> {
    const start = Date.now();
    this.logger.log(`findOne called with id: ${id}`);

    const user = await this.usersService.findOne(id);

    this.logger.log(`findOne completed in ${Date.now() - start}ms`);
    return user;
  }
  // 每个方法都重复！
}

// 手动响应包装
@Get()
async findAll(): Promise<{ data: User[]; meta: Meta }> {
  const users = await this.usersService.findAll();
  return {
    data: users,
    meta: { timestamp: new Date(), count: users.length },
  };
}
```

**正确做法（使用拦截器处理横切关注点）：**

```typescript
// 日志拦截器
@Injectable()
export class LoggingInterceptor implements NestInterceptor {
  private readonly logger = new Logger('HTTP');

  intercept(context: ExecutionContext, next: CallHandler): Observable<any> {
    const request = context.switchToHttp().getRequest();
    const { method, url, body } = request;
    const now = Date.now();

    return next.handle().pipe(
      tap({
        next: (data) => {
          const response = context.switchToHttp().getResponse();
          this.logger.log(
            `${method} ${url} ${response.statusCode} - ${Date.now() - now}ms`,
          );
        },
        error: (error) => {
          this.logger.error(
            `${method} ${url} ${error.status || 500} - ${Date.now() - now}ms`,
            error.stack,
          );
        },
      }),
    );
  }
}

// 响应转换拦截器
@Injectable()
export class TransformInterceptor<T> implements NestInterceptor<T, Response<T>> {
  intercept(context: ExecutionContext, next: CallHandler): Observable<Response<T>> {
    return next.handle().pipe(
      map((data) => ({
        data,
        meta: {
          timestamp: new Date().toISOString(),
          path: context.switchToHttp().getRequest().url,
        },
      })),
    );
  }
}

// 超时拦截器
@Injectable()
export class TimeoutInterceptor implements NestInterceptor {
  intercept(context: ExecutionContext, next: CallHandler): Observable<any> {
    return next.handle().pipe(
      timeout(5000),
      catchError((err) => {
        if (err instanceof TimeoutError) {
          throw new RequestTimeoutException('Request timed out');
        }
        throw err;
      }),
    );
  }
}

// 全局或按控制器应用
@Module({
  providers: [
    { provide: APP_INTERCEPTOR, useClass: LoggingInterceptor },
    { provide: APP_INTERCEPTOR, useClass: TransformInterceptor },
  ],
})
export class AppModule {}

// 或按控制器应用
@Controller('users')
@UseInterceptors(LoggingInterceptor)
export class UsersController {
  @Get()
  async findAll(): Promise<User[]> {
    // 只包含干净的业务逻辑
    return this.usersService.findAll();
  }
}

// 带 TTL 的自定义缓存拦截器
@Injectable()
export class HttpCacheInterceptor implements NestInterceptor {
  constructor(
    private cacheManager: Cache,
    private reflector: Reflector,
  ) {}

  async intercept(context: ExecutionContext, next: CallHandler): Promise<Observable<any>> {
    const request = context.switchToHttp().getRequest();

    // 只缓存 GET 请求
    if (request.method !== 'GET') {
      return next.handle();
    }

    const cacheKey = this.generateKey(request);
    const ttl = this.reflector.get<number>('cacheTTL', context.getHandler()) || 300;

    const cached = await this.cacheManager.get(cacheKey);
    if (cached) {
      return of(cached);
    }

    return next.handle().pipe(
      tap((response) => {
        this.cacheManager.set(cacheKey, response, ttl);
      }),
    );
  }

  private generateKey(request: Request): string {
    return `cache:${request.url}:${JSON.stringify(request.query)}`;
  }
}

// 带自定义 TTL 的使用
@Get()
@SetMetadata('cacheTTL', 600)
@UseInterceptors(HttpCacheInterceptor)
async findAll(): Promise<User[]> {
  return this.usersService.findAll();
}

// 错误映射拦截器
@Injectable()
export class ErrorMappingInterceptor implements NestInterceptor {
  intercept(context: ExecutionContext, next: CallHandler): Observable<any> {
    return next.handle().pipe(
      catchError((error) => {
        if (error instanceof EntityNotFoundError) {
          throw new NotFoundException(error.message);
        }
        if (error instanceof QueryFailedError) {
          if (error.message.includes('duplicate')) {
            throw new ConflictException('Resource already exists');
          }
        }
        throw error;
      }),
    );
  }
}
```

参考: [NestJS 拦截器](https://docs.nestjs.com/interceptors)

---

### 8.3 使用 Pipes 进行输入转换

**影响：中** — Pipes 确保干净、经过验证的数据到达处理器

使用内置管道如 `ParseIntPipe`、`ParseUUIDPipe` 和 `DefaultValuePipe` 进行常见转换。为业务特定的转换创建自定义管道。管道将验证/转换逻辑与控制器分离。

**错误做法（处理器中的手动类型解析）：**

```typescript
// 处理器中的手动类型解析
@Controller('users')
export class UsersController {
  @Get(':id')
  async findOne(@Param('id') id: string): Promise<User> {
    // 在每个处理器中手动验证
    const uuid = id.trim();
    if (!isUUID(uuid)) {
      throw new BadRequestException('Invalid UUID');
    }
    return this.usersService.findOne(uuid);
  }

  @Get()
  async findAll(
    @Query('page') page: string,
    @Query('limit') limit: string,
  ): Promise<User[]> {
    // 手动解析和默认值
    const pageNum = parseInt(page) || 1;
    const limitNum = parseInt(limit) || 10;
    return this.usersService.findAll(pageNum, limitNum);
  }
}

// 无验证的类型强制转换
@Get()
async search(@Query('price') price: string): Promise<Product[]> {
  const priceNum = +price; // 如果无效则为 NaN，无错误
  return this.productsService.findByPrice(priceNum);
}
```

**正确做法（使用内置和自定义管道）：**

```typescript
// 使用内置管道进行常见转换
@Controller('users')
export class UsersController {
  @Get(':id')
  async findOne(@Param('id', ParseUUIDPipe) id: string): Promise<User> {
    // id 保证是有效的 UUID
    return this.usersService.findOne(id);
  }

  @Get()
  async findAll(
    @Query('page', new DefaultValuePipe(1), ParseIntPipe) page: number,
    @Query('limit', new DefaultValuePipe(10), ParseIntPipe) limit: number,
  ): Promise<User[]> {
    // 自动默认值和类型转换
    return this.usersService.findAll(page, limit);
  }

  @Get('by-status/:status')
  async findByStatus(
    @Param('status', new ParseEnumPipe(UserStatus)) status: UserStatus,
  ): Promise<User[]> {
    return this.usersService.findByStatus(status);
  }
}

// 业务逻辑的自定义管道
@Injectable()
export class ParseDatePipe implements PipeTransform<string, Date> {
  transform(value: string): Date {
    const date = new Date(value);
    if (isNaN(date.getTime())) {
      throw new BadRequestException('Invalid date format');
    }
    return date;
  }
}

@Get('reports')
async getReports(
  @Query('from', ParseDatePipe) from: Date,
  @Query('to', ParseDatePipe) to: Date,
): Promise<Report[]> {
  return this.reportsService.findBetween(from, to);
}

// 自定义转换管道
@Injectable()
export class NormalizeEmailPipe implements PipeTransform<string, string> {
  transform(value: string): string {
    if (!value) return value;
    return value.trim().toLowerCase();
  }
}

// 解析逗号分隔的值
@Injectable()
export class ParseArrayPipe implements PipeTransform<string, string[]> {
  transform(value: string): string[] {
    if (!value) return [];
    return value.split(',').map((v) => v.trim()).filter(Boolean);
  }
}

@Get('products')
async findProducts(
  @Query('ids', ParseArrayPipe) ids: string[],
  @Query('email', NormalizeEmailPipe) email: string,
): Promise<Product[]> {
  // ids 已经是数组，email 已规范化
  return this.productsService.findByIds(ids);
}

// 清理 HTML 输入
@Injectable()
export class SanitizeHtmlPipe implements PipeTransform<string, string> {
  transform(value: string): string {
    if (!value) return value;
    return sanitizeHtml(value, { allowedTags: [] });
  }
}

// 带转换的全局验证管道
app.useGlobalPipes(
  new ValidationPipe({
    whitelist: true, // 去除非 DTO 属性
    transform: true, // 自动转换为 DTO 类型
    transformOptions: {
      enableImplicitConversion: true, // 将查询字符串转换为数字
    },
    forbidNonWhitelisted: true, // 遇到额外属性时抛出错误
  }),
);

// 带转换装饰器的 DTO
export class FindProductsDto {
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  page?: number = 1;

  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  @Max(100)
  limit?: number = 10;

  @IsOptional()
  @Transform(({ value }) => value?.toLowerCase())
  @IsString()
  search?: string;

  @IsOptional()
  @Transform(({ value }) => value?.split(','))
  @IsArray()
  @IsString({ each: true })
  categories?: string[];
}

@Get()
async findAll(@Query() dto: FindProductsDto): Promise<Product[]> {
  // dto 已经过转换和验证
  return this.productsService.findAll(dto);
}

// 管道错误自定义
@Injectable()
export class CustomParseIntPipe extends ParseIntPipe {
  constructor() {
    super({
      exceptionFactory: (error) =>
        new BadRequestException(`${error} must be a valid integer`),
    });
  }
}

// 或在内置管道上使用选项
@Get(':id')
async findOne(
  @Param(
    'id',
    new ParseIntPipe({
      errorHttpStatusCode: HttpStatus.NOT_ACCEPTABLE,
      exceptionFactory: () => new NotAcceptableException('ID must be numeric'),
    }),
  )
  id: number,
): Promise<Item> {
  return this.itemsService.findOne(id);
}
```

参考: [NestJS Pipes](https://docs.nestjs.com/pipes)

---

### 8.4 对破坏性变更使用 API 版本控制

**影响：中** — 版本控制允许你在不破坏现有客户端的情况下演进 API

对 API 进行破坏性变更时，使用 NestJS 内置的版本控制。选择版本控制策略（URI、header 或媒体类型）并一致地应用。这样旧客户端可以继续工作，而新客户端可以使用更新的端点。

**错误做法（无版本控制的破坏性变更）：**

```typescript
// 无版本控制的破坏性变更
@Controller('users')
export class UsersController {
  @Get(':id')
  async findOne(@Param('id') id: string): Promise<User> {
    // 原始响应：{ id, name, email }
    // 后来改为：{ id, firstName, lastName, emailAddress }
    // 旧客户端崩溃！
    return this.usersService.findOne(id);
  }
}

// 路由中的手动版本控制
@Controller('v1/users')
export class UsersV1Controller {}

@Controller('v2/users')
export class UsersV2Controller {}
// 不一致、容易出错、难以维护
```

**正确做法（使用 NestJS 内置版本控制）：**

```typescript
// 在 main.ts 中启用版本控制
async function bootstrap() {
  const app = await NestFactory.create(AppModule);

  // URI 版本控制：/v1/users, /v2/users
  app.enableVersioning({
    type: VersioningType.URI,
    defaultVersion: '1',
  });

  // 或 header 版本控制：X-API-Version: 1
  app.enableVersioning({
    type: VersioningType.HEADER,
    header: 'X-API-Version',
    defaultVersion: '1',
  });

  // 或媒体类型：Accept: application/json;v=1
  app.enableVersioning({
    type: VersioningType.MEDIA_TYPE,
    key: 'v=',
    defaultVersion: '1',
  });

  await app.listen(3000);
}

// 版本特定的控制器
@Controller('users')
@Version('1')
export class UsersV1Controller {
  @Get(':id')
  async findOne(@Param('id') id: string): Promise<UserV1Response> {
    const user = await this.usersService.findOne(id);
    // V1 响应格式
    return {
      id: user.id,
      name: user.name,
      email: user.email,
    };
  }
}

@Controller('users')
@Version('2')
export class UsersV2Controller {
  @Get(':id')
  async findOne(@Param('id') id: string): Promise<UserV2Response> {
    const user = await this.usersService.findOne(id);
    // V2 响应格式，包含破坏性变更
    return {
      id: user.id,
      firstName: user.firstName,
      lastName: user.lastName,
      emailAddress: user.email,
      createdAt: user.createdAt,
    };
  }
}

// 按路由版本控制 - 不同路由使用不同版本
@Controller('users')
export class UsersController {
  @Get()
  @Version('1')
  findAllV1(): Promise<UserV1Response[]> {
    return this.usersService.findAllV1();
  }

  @Get()
  @Version('2')
  findAllV2(): Promise<UserV2Response[]> {
    return this.usersService.findAllV2();
  }

  @Get(':id')
  @Version(['1', '2']) // 同一处理器支持多个版本
  findOne(@Param('id') id: string): Promise<User> {
    return this.usersService.findOne(id);
  }

  @Post()
  @Version(VERSION_NEUTRAL) // 所有版本可用
  create(@Body() dto: CreateUserDto): Promise<User> {
    return this.usersService.create(dto);
  }
}

// 带版本特定逻辑的共享服务
@Injectable()
export class UsersService {
  async findOne(id: string, version: string): Promise<any> {
    const user = await this.repo.findOne({ where: { id } });

    if (version === '1') {
      return this.toV1Response(user);
    }
    return this.toV2Response(user);
  }

  private toV1Response(user: User): UserV1Response {
    return {
      id: user.id,
      name: `${user.firstName} ${user.lastName}`,
      email: user.email,
    };
  }

  private toV2Response(user: User): UserV2Response {
    return {
      id: user.id,
      firstName: user.firstName,
      lastName: user.lastName,
      emailAddress: user.email,
      createdAt: user.createdAt,
    };
  }
}

// 控制器提取版本
@Controller('users')
export class UsersController {
  @Get(':id')
  async findOne(
    @Param('id') id: string,
    @Headers('X-API-Version') version: string = '1',
  ): Promise<any> {
    return this.usersService.findOne(id, version);
  }
}

// 弃用策略 - 标记旧版本为已弃用
@Controller('users')
@Version('1')
@UseInterceptors(DeprecationInterceptor)
export class UsersV1Controller {
  // 所有 V1 路由将包含弃用警告
}

@Injectable()
export class DeprecationInterceptor implements NestInterceptor {
  intercept(context: ExecutionContext, next: CallHandler): Observable<any> {
    const response = context.switchToHttp().getResponse();
    response.setHeader('Deprecation', 'true');
    response.setHeader('Sunset', 'Sat, 1 Jan 2025 00:00:00 GMT');
    response.setHeader('Link', '</v2/users>; rel="successor-version"');

    return next.handle();
  }
}
```

参考: [NestJS 版本控制](https://docs.nestjs.com/techniques/versioning)

---

## 9. 微服务

**章节影响：中**

### 9.1 为微服务实现健康检查

**影响：中高** — 健康检查使编排器能够管理服务生命周期

使用 `@nestjs/terminus` 实现存活和就绪探针。存活检查决定服务是否应重启。就绪检查决定服务是否可以接受流量。适当的健康检查使 Kubernetes 和负载均衡器能够正确路由流量。

**错误做法（不检查依赖的简单 ping）：**

```typescript
// 不检查依赖的简单 ping
@Controller('health')
export class HealthController {
  @Get()
  check(): string {
    return 'OK'; // 服务可能不健康，但返回 OK
  }
}

// 阻塞在慢依赖上的健康检查
@Controller('health')
export class HealthController {
  @Get()
  async check(): Promise<string> {
    // 如果数据库慢，健康检查会超时
    await this.userRepo.findOne({ where: { id: '1' } });
    await this.redis.ping();
    await this.externalApi.healthCheck();
    return 'OK';
  }
}
```

**正确做法（使用 @nestjs/terminus 进行全面的健康检查）：**

```typescript
// 使用 @nestjs/terminus 进行全面的健康检查
import {
  HealthCheckService,
  HttpHealthIndicator,
  TypeOrmHealthIndicator,
  HealthCheck,
  DiskHealthIndicator,
  MemoryHealthIndicator,
} from '@nestjs/terminus';

@Controller('health')
export class HealthController {
  constructor(
    private health: HealthCheckService,
    private http: HttpHealthIndicator,
    private db: TypeOrmHealthIndicator,
    private disk: DiskHealthIndicator,
    private memory: MemoryHealthIndicator,
  ) {}

  // 存活探针 - 服务是否存活？
  @Get('live')
  @HealthCheck()
  liveness() {
    return this.health.check([
      // 仅基本检查
      () => this.memory.checkHeap('memory_heap', 200 * 1024 * 1024), // 200MB
    ]);
  }

  // 就绪探针 - 服务能否处理流量？
  @Get('ready')
  @HealthCheck()
  readiness() {
    return this.health.check([
      () => this.db.pingCheck('database'),
      () =>
        this.http.pingCheck('redis', 'http://redis:6379', { timeout: 1000 }),
      () =>
        this.disk.checkStorage('disk', { path: '/', thresholdPercent: 0.9 }),
    ]);
  }

  // 用于调试的深度健康检查
  @Get('deep')
  @HealthCheck()
  deepCheck() {
    return this.health.check([
      () => this.db.pingCheck('database'),
      () => this.memory.checkHeap('memory_heap', 200 * 1024 * 1024),
      () => this.memory.checkRSS('memory_rss', 300 * 1024 * 1024),
      () =>
        this.disk.checkStorage('disk', { path: '/', thresholdPercent: 0.9 }),
      () =>
        this.http.pingCheck('external-api', 'https://api.example.com/health'),
    ]);
  }
}

// 业务特定健康检查的自定义指示器
@Injectable()
export class QueueHealthIndicator extends HealthIndicator {
  constructor(private queueService: QueueService) {
    super();
  }

  async isHealthy(key: string): Promise<HealthIndicatorResult> {
    const queueStats = await this.queueService.getStats();

    const isHealthy = queueStats.failedCount < 100;
    const result = this.getStatus(key, isHealthy, {
      waiting: queueStats.waitingCount,
      active: queueStats.activeCount,
      failed: queueStats.failedCount,
    });

    if (!isHealthy) {
      throw new HealthCheckError('Queue unhealthy', result);
    }

    return result;
  }
}

// Redis 健康检查指示器
@Injectable()
export class RedisHealthIndicator extends HealthIndicator {
  constructor(@InjectRedis() private redis: Redis) {
    super();
  }

  async isHealthy(key: string): Promise<HealthIndicatorResult> {
    try {
      const pong = await this.redis.ping();
      return this.getStatus(key, pong === 'PONG');
    } catch (error) {
      throw new HealthCheckError('Redis check failed', this.getStatus(key, false));
    }
  }
}

// 使用自定义指示器
@Get('ready')
@HealthCheck()
readiness() {
  return this.health.check([
    () => this.db.pingCheck('database'),
    () => this.redis.isHealthy('redis'),
    () => this.queue.isHealthy('job-queue'),
  ]);
}

// 优雅关闭处理
@Injectable()
export class GracefulShutdownService implements OnApplicationShutdown {
  private isShuttingDown = false;

  isShutdown(): boolean {
    return this.isShuttingDown;
  }

  async onApplicationShutdown(signal: string): Promise<void> {
    this.isShuttingDown = true;
    console.log(`Shutting down on ${signal}`);

    // 等待处理中的请求
    await new Promise((resolve) => setTimeout(resolve, 5000));
  }
}

// 健康检查尊重关闭状态
@Get('ready')
@HealthCheck()
readiness() {
  if (this.shutdownService.isShutdown()) {
    throw new ServiceUnavailableException('Shutting down');
  }

  return this.health.check([
    () => this.db.pingCheck('database'),
  ]);
}
```

### Kubernetes 配置

```yaml
# 带探针的 Kubernetes 部署
apiVersion: apps/v1
kind: Deployment
metadata:
  name: api-service
spec:
  template:
    spec:
      containers:
        - name: api
          image: api-service:latest
          ports:
            - containerPort: 3000
          livenessProbe:
            httpGet:
              path: /health/live
              port: 3000
            initialDelaySeconds: 30
            periodSeconds: 10
            timeoutSeconds: 5
            failureThreshold: 3
          readinessProbe:
            httpGet:
              path: /health/ready
              port: 3000
            initialDelaySeconds: 5
            periodSeconds: 5
            timeoutSeconds: 3
            failureThreshold: 3
          startupProbe:
            httpGet:
              path: /health/live
              port: 3000
            initialDelaySeconds: 0
            periodSeconds: 5
            failureThreshold: 30
```

参考: [NestJS Terminus](https://docs.nestjs.com/recipes/terminus)

---

### 9.2 正确使用消息和事件模式

**影响：中** — 正确的模式确保可靠的微服务通信

NestJS 微服务支持两种通信模式：请求-响应（MessagePattern）和基于事件（EventPattern）。当你需要响应时使用 MessagePattern，对于 fire-and-forget 通知使用 EventPattern。理解两者的区别可以防止通信错误。

**错误做法（为用例使用了错误的模式）：**

```typescript
// 对 fire-and-forget 使用 @MessagePattern
@Controller()
export class NotificationsController {
  @MessagePattern('user.created')
  async handleUserCreated(data: UserCreatedEvent) {
    // 这会等待响应，阻塞发送方
    await this.emailService.sendWelcome(data.email);
    // 如果邮件失败，发送方会收到错误（耦合！）
  }
}

// 期望响应的 @EventPattern
@Controller()
export class OrdersController {
  @EventPattern('inventory.check')
  async checkInventory(data: CheckInventoryDto) {
    const available = await this.inventory.check(data);
    return available; // 这个返回值使用 @EventPattern 会被忽略！
  }
}

// 客户端中的紧密耦合
@Injectable()
export class UsersService {
  async createUser(dto: CreateUserDto): Promise<User> {
    const user = await this.repo.save(dto);

    // 阻塞直到通知服务响应
    await this.client.send('user.created', user).toPromise();
    // 如果通知服务宕机，用户创建失败！

    return user;
  }
}
```

**正确做法（MessagePattern 用于请求-响应，EventPattern 用于 fire-and-forget）：**

```typescript
// MessagePattern: 请求-响应（当你需要响应时）
@Controller()
export class InventoryController {
  @MessagePattern({ cmd: 'check_inventory' })
  async checkInventory(data: CheckInventoryDto): Promise<InventoryResult> {
    const result = await this.inventoryService.check(data.productId, data.quantity);
    return result; // 响应发送回调用方
  }
}

// 客户端期望响应
@Injectable()
export class OrdersService {
  async createOrder(dto: CreateOrderDto): Promise<Order> {
    // 检查库存 - 我们需要这个响应才能继续
    const inventory = await firstValueFrom(
      this.inventoryClient.send<InventoryResult>(
        { cmd: 'check_inventory' },
        { productId: dto.productId, quantity: dto.quantity },
      ),
    );

    if (!inventory.available) {
      throw new BadRequestException('Insufficient inventory');
    }

    return this.repo.save(dto);
  }
}

// EventPattern: Fire-and-Forget（用于通知、副作用）
@Controller()
export class NotificationsController {
  @EventPattern('user.created')
  async handleUserCreated(data: UserCreatedEvent): Promise<void> {
    // 不需要返回值 - 只处理事件
    await this.emailService.sendWelcome(data.email);
    await this.analyticsService.track('user_signup', data);
    // 如果失败，不会影响发送方
  }
}

// 客户端发送事件而不等待
@Injectable()
export class UsersService {
  async createUser(dto: CreateUserDto): Promise<User> {
    const user = await this.repo.save(dto);

    // Fire and forget - 不阻塞，不等待
    this.eventClient.emit('user.created', {
      userId: user.id,
      email: user.email,
      timestamp: new Date(),
    });

    return user; // 无论事件处理如何，用户创建成功
  }
}

// 关键事件的混合模式
@Injectable()
export class OrdersService {
  async createOrder(dto: CreateOrderDto): Promise<Order> {
    const order = await this.repo.save(dto);

    // 关键：库存预留（使用 MessagePattern）
    const reserved = await firstValueFrom(
      this.inventoryClient.send({ cmd: 'reserve_inventory' }, {
        orderId: order.id,
        items: dto.items,
      }),
    );

    if (!reserved.success) {
      await this.repo.delete(order.id);
      throw new BadRequestException('Could not reserve inventory');
    }

    // 非关键：通知（使用 EventPattern）
    this.eventClient.emit('order.created', {
      orderId: order.id,
      userId: dto.userId,
      total: dto.total,
    });

    return order;
  }
}

// 错误处理模式
// MessagePattern 错误传播到调用方
@MessagePattern({ cmd: 'get_user' })
async getUser(userId: string): Promise<User> {
  const user = await this.repo.findOne({ where: { id: userId } });
  if (!user) {
    throw new RpcException('User not found'); // 调用方接收
  }
  return user;
}

// EventPattern 错误应在本地处理
@EventPattern('order.created')
async handleOrderCreated(data: OrderCreatedEvent): Promise<void> {
  try {
    await this.processOrder(data);
  } catch (error) {
    // 记录并可能重试 - 不要抛出
    this.logger.error('Failed to process order event', error);
    await this.deadLetterQueue.add(data);
  }
}
```

参考: [NestJS 微服务](https://docs.nestjs.com/microservices/basics)

---

### 9.3 使用消息队列处理后台任务

**影响：中高** — 队列支持可靠的后台处理

使用 `@nestjs/bullmq` 进行后台任务处理。队列将长时间运行的任务与 HTTP 请求解耦，支持重试逻辑，并在工作节点之间分配工作负载。将它们用于邮件、文件处理、通知以及任何不应阻塞用户请求的任务。

**错误做法（HTTP 处理器中的长时间运行任务）：**

```typescript
// HTTP 处理器中的长时间运行任务
@Controller('reports')
export class ReportsController {
  @Post()
  async generate(@Body() dto: GenerateReportDto): Promise<Report> {
    // 这会阻塞请求可能数分钟
    const data = await this.fetchLargeDataset(dto);
    const report = await this.processData(data); // 慢！
    await this.sendEmail(dto.email, report); // 可能失败！
    return report; // 客户端超时
  }
}

// Fire-and-forget 无重试
@Injectable()
export class EmailService {
  async sendWelcome(email: string): Promise<void> {
    // 如果失败，邮件永远不会发送
    await this.mailer.send({ to: email, template: 'welcome' });
    // 无重试、无跟踪、无可见性
  }
}

// 使用 setInterval 进行定时任务
setInterval(async () => {
  await cleanupOldRecords();
}, 60000); // 无错误处理，内存泄漏
```

**正确做法（使用 BullMQ 进行后台处理）：**

```typescript
// 配置 BullMQ
import { BullModule } from '@nestjs/bullmq';

@Module({
  imports: [
    BullModule.forRoot({
      connection: {
        host: 'localhost',
        port: 6379,
      },
      defaultJobOptions: {
        removeOnComplete: 1000,
        removeOnFail: 5000,
        attempts: 3,
        backoff: {
          type: 'exponential',
          delay: 1000,
        },
      },
    }),
    BullModule.registerQueue(
      { name: 'email' },
      { name: 'reports' },
      { name: 'notifications' },
    ),
  ],
})
export class QueueModule {}

// 生产者：将任务添加到队列
@Injectable()
export class ReportsService {
  constructor(
    @InjectQueue('reports') private reportsQueue: Queue,
  ) {}

  async requestReport(dto: GenerateReportDto): Promise<{ jobId: string }> {
    // 立即返回，后台处理
    const job = await this.reportsQueue.add('generate', dto, {
      priority: dto.urgent ? 1 : 10,
      delay: dto.scheduledFor ? Date.parse(dto.scheduledFor) - Date.now() : 0,
    });

    return { jobId: job.id };
  }

  async getJobStatus(jobId: string): Promise<JobStatus> {
    const job = await this.reportsQueue.getJob(jobId);
    return {
      status: await job.getState(),
      progress: job.progress,
      result: job.returnvalue,
    };
  }
}

// 消费者：处理任务
@Processor('reports')
export class ReportsProcessor {
  private readonly logger = new Logger(ReportsProcessor.name);

  @Process('generate')
  async generateReport(job: Job<GenerateReportDto>): Promise<Report> {
    this.logger.log(`Processing report job ${job.id}`);

    // 更新进度
    await job.updateProgress(10);

    const data = await this.fetchData(job.data);
    await job.updateProgress(50);

    const report = await this.processData(data);
    await job.updateProgress(90);

    await this.saveReport(report);
    await job.updateProgress(100);

    return report;
  }

  @OnQueueActive()
  onActive(job: Job) {
    this.logger.log(`Processing job ${job.id}`);
  }

  @OnQueueCompleted()
  onCompleted(job: Job, result: any) {
    this.logger.log(`Job ${job.id} completed`);
  }

  @OnQueueFailed()
  onFailed(job: Job, error: Error) {
    this.logger.error(`Job ${job.id} failed: ${error.message}`);
  }
}

// 带重试的邮件队列
@Processor('email')
export class EmailProcessor {
  @Process('send')
  async sendEmail(job: Job<SendEmailDto>): Promise<void> {
    const { to, template, data } = job.data;

    try {
      await this.mailer.send({
        to,
        template,
        context: data,
      });
    } catch (error) {
      // BullMQ 将根据任务选项进行重试
      throw error;
    }
  }
}

// 使用方式
@Injectable()
export class NotificationService {
  constructor(@InjectQueue('email') private emailQueue: Queue) {}

  async sendWelcome(user: User): Promise<void> {
    await this.emailQueue.add(
      'send',
      {
        to: user.email,
        template: 'welcome',
        data: { name: user.name },
      },
      {
        attempts: 5,
        backoff: { type: 'exponential', delay: 5000 },
      },
    );
  }
}

// 定时任务
@Injectable()
export class ScheduledJobsService implements OnModuleInit {
  constructor(@InjectQueue('maintenance') private queue: Queue) {}

  async onModuleInit(): Promise<void> {
    // 每天午夜清理旧报告
    await this.queue.add(
      'cleanup',
      {},
      {
        repeat: { cron: '0 0 * * *' },
        jobId: 'daily-cleanup', // 防止重复
      },
    );

    // 每小时发送摘要
    await this.queue.add(
      'digest',
      {},
      {
        repeat: { every: 60 * 60 * 1000 },
        jobId: 'hourly-digest',
      },
    );
  }
}

@Processor('maintenance')
export class MaintenanceProcessor {
  @Process('cleanup')
  async cleanup(): Promise<void> {
    await this.cleanupOldReports();
    await this.cleanupExpiredSessions();
  }

  @Process('digest')
  async sendDigest(): Promise<void> {
    const users = await this.getUsersForDigest();
    for (const user of users) {
      await this.emailQueue.add('send', { to: user.email, template: 'digest' });
    }
  }
}

// 使用 Bull Board 进行队列监控
import { BullBoardModule } from '@bull-board/nestjs';
import { BullMQAdapter } from '@bull-board/api/bullMQAdapter';

@Module({
  imports: [
    BullBoardModule.forRoot({
      route: '/admin/queues',
      adapter: ExpressAdapter,
    }),
    BullBoardModule.forFeature({
      name: 'email',
      adapter: BullMQAdapter,
    }),
    BullBoardModule.forFeature({
      name: 'reports',
      adapter: BullMQAdapter,
    }),
  ],
})
export class AdminModule {}
```

参考: [NestJS 队列](https://docs.nestjs.com/techniques/queues)

---

## 10. DevOps 与部署

**章节影响：低中**

### 10.1 实现优雅关闭

**影响：中高** — 正确的关闭处理确保零停机部署

处理 SIGTERM 和 SIGINT 信号以优雅关闭 NestJS 应用程序。停止接受新请求，等待处理中的请求完成，关闭数据库连接，并清理资源。这可以防止部署期间的数据丢失和连接错误。

**错误做法（忽略关闭信号）：**

```typescript
// 忽略关闭信号
async function bootstrap() {
  const app = await NestFactory.create(AppModule);
  await app.listen(3000);
  // 应用在 SIGTERM 时立即崩溃
  // 处理中的请求失败
  // 数据库连接被突然关闭
}

// 无取消机制的长时间运行任务
@Injectable()
export class ProcessingService {
  async processLargeFile(file: File): Promise<void> {
    // 无法在关闭期间中断此操作
    for (let i = 0; i < file.chunks.length; i++) {
      await this.processChunk(file.chunks[i]);
      // 可能运行数分钟，阻塞关闭
    }
  }
}
```

**正确做法（启用关闭钩子并处理清理）：**

```typescript
// 在 main.ts 中启用关闭钩子
async function bootstrap() {
  const app = await NestFactory.create(AppModule);

  // 启用关闭钩子
  app.enableShutdownHooks();

  // 可选：添加强制关闭超时
  const server = await app.listen(3000);
  server.setTimeout(30000); // 30 秒超时

  // 处理优雅关闭
  const signals = ['SIGTERM', 'SIGINT'];
  signals.forEach((signal) => {
    process.on(signal, async () => {
      console.log(`Received ${signal}, starting graceful shutdown...`);

      // 停止接受新连接
      server.close(async () => {
        console.log('HTTP server closed');
        await app.close();
        process.exit(0);
      });

      // 超时后强制退出
      setTimeout(() => {
        console.error('Forced shutdown after timeout');
        process.exit(1);
      }, 30000);
    });
  });
}

// 用于清理的生命周期钩子
@Injectable()
export class DatabaseService implements OnApplicationShutdown {
  private readonly connections: Connection[] = [];

  async onApplicationShutdown(signal?: string): Promise<void> {
    console.log(`Database service shutting down on ${signal}`);

    // 优雅关闭所有连接
    await Promise.all(
      this.connections.map((conn) => conn.close()),
    );

    console.log('All database connections closed');
  }
}

// 带优雅关闭的队列处理器
@Injectable()
export class QueueService implements OnApplicationShutdown, OnModuleDestroy {
  private isShuttingDown = false;

  onModuleDestroy(): void {
    this.isShuttingDown = true;
  }

  async onApplicationShutdown(): Promise<void> {
    // 等待当前任务完成
    await this.queue.close();
  }

  async processJob(job: Job): Promise<void> {
    if (this.isShuttingDown) {
      throw new Error('Service is shutting down');
    }
    await this.doWork(job);
  }
}

// WebSocket 网关清理
@WebSocketGateway()
export class EventsGateway implements OnApplicationShutdown {
  @WebSocketServer()
  server: Server;

  async onApplicationShutdown(): Promise<void> {
    // 通知所有连接的客户端
    this.server.emit('shutdown', { message: 'Server is shutting down' });

    // 关闭所有连接
    this.server.disconnectSockets();
  }
}

// 健康检查集成
@Injectable()
export class ShutdownService {
  private isShuttingDown = false;

  startShutdown(): void {
    this.isShuttingDown = true;
  }

  isShutdown(): boolean {
    return this.isShuttingDown;
  }
}

@Controller('health')
export class HealthController {
  constructor(private shutdownService: ShutdownService) {}

  @Get('ready')
  @HealthCheck()
  readiness(): Promise<HealthCheckResult> {
    // 关闭期间返回 503 - k8s 停止发送流量
    if (this.shutdownService.isShutdown()) {
      throw new ServiceUnavailableException('Shutting down');
    }

    return this.health.check([
      () => this.db.pingCheck('database'),
    ]);
  }
}

// 与关闭集成
@Injectable()
export class AppShutdownService implements OnApplicationShutdown {
  constructor(private shutdownService: ShutdownService) {}

  async onApplicationShutdown(): Promise<void> {
    // 先标记为不健康
    this.shutdownService.startShutdown();

    // 等待 k8s 更新端点
    await this.sleep(5000);

    // 然后继续清理
  }
}

// 处理中请求的跟踪
@Injectable()
export class RequestTracker implements NestMiddleware, OnApplicationShutdown {
  private activeRequests = 0;
  private isShuttingDown = false;
  private shutdownPromise: Promise<void> | null = null;
  private resolveShutdown: (() => void) | null = null;

  use(req: Request, res: Response, next: NextFunction): void {
    if (this.isShuttingDown) {
      res.status(503).send('Service Unavailable');
      return;
    }

    this.activeRequests++;

    res.on('finish', () => {
      this.activeRequests--;
      if (this.isShuttingDown && this.activeRequests === 0 && this.resolveShutdown) {
        this.resolveShutdown();
      }
    });

    next();
  }

  async onApplicationShutdown(): Promise<void> {
    this.isShuttingDown = true;

    if (this.activeRequests > 0) {
      console.log(`Waiting for ${this.activeRequests} requests to complete`);
      this.shutdownPromise = new Promise((resolve) => {
        this.resolveShutdown = resolve;
      });

      // 带超时的等待
      await Promise.race([
        this.shutdownPromise,
        new Promise((resolve) => setTimeout(resolve, 30000)),
      ]);
    }

    console.log('All requests completed');
  }
}
```

参考: [NestJS 生命周期事件](https://docs.nestjs.com/fundamentals/lifecycle-events)

---

### 10.2 使用 ConfigModule 进行环境配置

**影响：低中** — 正确的配置防止部署失败

使用 `@nestjs/config` 进行基于环境的配置。在启动时验证配置，以便在配置错误时快速失败。使用命名空间配置以实现组织性和类型安全。

**错误做法（直接访问 process.env）：**

```typescript
// 直接访问 process.env
@Injectable()
export class DatabaseService {
  constructor() {
    // 无验证，可能在运行时失败
    this.connection = new Pool({
      host: process.env.DB_HOST,
      port: parseInt(process.env.DB_PORT), // 如果缺失则为 NaN
      password: process.env.DB_PASSWORD, // 如果缺失则为 undefined
    });
  }
}

// 分散的环境变量访问
@Injectable()
export class EmailService {
  sendEmail() {
    // 不同服务以不同方式访问环境变量
    const apiKey = process.env.SENDGRID_API_KEY || 'default';
    // 拼写错误不会被发现：process.env.SENDGRID_API_KY
  }
}
```

**正确做法（使用 @nestjs/config 配合验证）：**

```typescript
// 设置经过验证的配置
import { ConfigModule, ConfigService, registerAs } from '@nestjs/config';
import * as Joi from 'joi';

// config/database.config.ts
export const databaseConfig = registerAs('database', () => ({
  host: process.env.DB_HOST,
  port: parseInt(process.env.DB_PORT, 10),
  username: process.env.DB_USERNAME,
  password: process.env.DB_PASSWORD,
  database: process.env.DB_NAME,
}));

// config/app.config.ts
export const appConfig = registerAs('app', () => ({
  port: parseInt(process.env.PORT, 10) || 3000,
  environment: process.env.NODE_ENV || 'development',
  apiPrefix: process.env.API_PREFIX || 'api',
}));

// config/validation.schema.ts
export const validationSchema = Joi.object({
  NODE_ENV: Joi.string()
    .valid('development', 'production', 'test')
    .default('development'),
  PORT: Joi.number().default(3000),
  DB_HOST: Joi.string().required(),
  DB_PORT: Joi.number().default(5432),
  DB_USERNAME: Joi.string().required(),
  DB_PASSWORD: Joi.string().required(),
  DB_NAME: Joi.string().required(),
  JWT_SECRET: Joi.string().min(32).required(),
  REDIS_URL: Joi.string().uri().required(),
});

// app.module.ts
@Module({
  imports: [
    ConfigModule.forRoot({
      isGlobal: true, // 随处可用，无需导入
      load: [databaseConfig, appConfig],
      validationSchema,
      validationOptions: {
        abortEarly: true, // 在第一个错误时停止
        allowUnknown: true, // 允许其他环境变量
      },
    }),
    TypeOrmModule.forRootAsync({
      inject: [ConfigService],
      useFactory: (config: ConfigService) => ({
        type: 'postgres',
        host: config.get('database.host'),
        port: config.get('database.port'),
        username: config.get('database.username'),
        password: config.get('database.password'),
        database: config.get('database.database'),
        autoLoadEntities: true,
      }),
    }),
  ],
})
export class AppModule {}

// 类型安全的配置访问
export interface AppConfig {
  port: number;
  environment: 'development' | 'production' | 'test';
  apiPrefix: string;
}

export interface DatabaseConfig {
  host: string;
  port: number;
  username: string;
  password: string;
  database: string;
}

// 类型安全访问
@Injectable()
export class AppService {
  constructor(private config: ConfigService) {}

  getPort(): number {
    // 使用泛型实现类型安全
    return this.config.get<number>('app.port');
  }

  getDatabaseConfig(): DatabaseConfig {
    return this.config.get<DatabaseConfig>('database');
  }
}

// 直接注入命名空间配置
@Injectable()
export class DatabaseService {
  constructor(
    @Inject(databaseConfig.KEY)
    private dbConfig: ConfigType<typeof databaseConfig>,
  ) {
    // 完整的类型推断！
    const host = this.dbConfig.host; // string
    const port = this.dbConfig.port; // number
  }
}

// 环境文件支持
ConfigModule.forRoot({
  envFilePath: [
    `.env.${process.env.NODE_ENV}.local`,
    `.env.${process.env.NODE_ENV}`,
    '.env.local',
    '.env',
  ],
});

// .env.development
// DB_HOST=localhost
// DB_PORT=5432

// .env.production
// DB_HOST=prod-db.example.com
// DB_PORT=5432
```

参考: [NestJS 配置](https://docs.nestjs.com/techniques/configuration)

---

### 10.3 使用结构化日志

**影响：中高** — 结构化日志支持有效的调试和监控

在生产环境中使用具有结构化 JSON 输出的 NestJS Logger。包含上下文信息（请求 ID、用户 ID、操作）以跨服务跟踪请求。避免使用 console.log 并实施适当的日志级别。

**错误做法（在生产中使用 console.log）：**

```typescript
// 在生产中使用 console.log
@Injectable()
export class UsersService {
  async createUser(dto: CreateUserDto): Promise<User> {
    console.log('Creating user:', dto);
    // 非结构化，无级别，在生产日志中丢失

    try {
      const user = await this.repo.save(dto);
      console.log('User created:', user.id);
      return user;
    } catch (error) {
      console.log('Error:', error); // 使用 log 记录错误
      throw error;
    }
  }
}

// 记录敏感数据
console.log('Login attempt:', { email, password }); // 安全风险！

// 不一致的日志格式
logger.log('User ' + userId + ' created at ' + new Date());
// 难以解析，无结构
```

**正确做法（使用带上下文的结构化日志）：**

```typescript
// 在 main.ts 中配置日志记录器
async function bootstrap() {
  const app = await NestFactory.create(AppModule, {
    logger:
      process.env.NODE_ENV === 'production'
        ? ['error', 'warn', 'log']
        : ['error', 'warn', 'log', 'debug', 'verbose'],
  });
}

// 使用带上下文的 NestJS Logger
@Injectable()
export class UsersService {
  private readonly logger = new Logger(UsersService.name);

  async createUser(dto: CreateUserDto): Promise<User> {
    this.logger.log('Creating user', { email: dto.email });

    try {
      const user = await this.repo.save(dto);
      this.logger.log('User created', { userId: user.id });
      return user;
    } catch (error) {
      this.logger.error('Failed to create user', error.stack, {
        email: dto.email,
      });
      throw error;
    }
  }
}

// 用于 JSON 输出的自定义日志记录器
@Injectable()
export class JsonLogger implements LoggerService {
  log(message: string, context?: object): void {
    console.log(
      JSON.stringify({
        level: 'info',
        timestamp: new Date().toISOString(),
        message,
        ...context,
      }),
    );
  }

  error(message: string, trace?: string, context?: object): void {
    console.error(
      JSON.stringify({
        level: 'error',
        timestamp: new Date().toISOString(),
        message,
        trace,
        ...context,
      }),
    );
  }

  warn(message: string, context?: object): void {
    console.warn(
      JSON.stringify({
        level: 'warn',
        timestamp: new Date().toISOString(),
        message,
        ...context,
      }),
    );
  }

  debug(message: string, context?: object): void {
    console.debug(
      JSON.stringify({
        level: 'debug',
        timestamp: new Date().toISOString(),
        message,
        ...context,
      }),
    );
  }
}

// 使用 ClsModule 的请求上下文日志
import { ClsModule, ClsService } from 'nestjs-cls';

@Module({
  imports: [
    ClsModule.forRoot({
      global: true,
      middleware: {
        mount: true,
        generateId: true,
      },
    }),
  ],
})
export class AppModule {}

// 设置请求上下文的中间件
@Injectable()
export class RequestContextMiddleware implements NestMiddleware {
  constructor(private cls: ClsService) {}

  use(req: Request, res: Response, next: NextFunction): void {
    const requestId = req.headers['x-request-id'] || randomUUID();
    this.cls.set('requestId', requestId);
    this.cls.set('userId', req.user?.id);

    res.setHeader('x-request-id', requestId);
    next();
  }
}

// 包含请求上下文的日志记录器
@Injectable()
export class ContextLogger {
  constructor(private cls: ClsService) {}

  log(message: string, data?: object): void {
    console.log(
      JSON.stringify({
        level: 'info',
        timestamp: new Date().toISOString(),
        requestId: this.cls.get('requestId'),
        userId: this.cls.get('userId'),
        message,
        ...data,
      }),
    );
  }

  error(message: string, error: Error, data?: object): void {
    console.error(
      JSON.stringify({
        level: 'error',
        timestamp: new Date().toISOString(),
        requestId: this.cls.get('requestId'),
        userId: this.cls.get('userId'),
        message,
        error: error.message,
        stack: error.stack,
        ...data,
      }),
    );
  }
}

// 集成 Pino 实现高性能日志
import { LoggerModule } from 'nestjs-pino';

@Module({
  imports: [
    LoggerModule.forRoot({
      pinoHttp: {
        level: process.env.NODE_ENV === 'production' ? 'info' : 'debug',
        transport:
          process.env.NODE_ENV !== 'production'
            ? { target: 'pino-pretty' }
            : undefined,
        redact: ['req.headers.authorization', 'req.body.password'],
        serializers: {
          req: (req) => ({
            method: req.method,
            url: req.url,
            query: req.query,
          }),
          res: (res) => ({
            statusCode: res.statusCode,
          }),
        },
      },
    }),
  ],
})
export class AppModule {}

// 使用 Pino
@Injectable()
export class UsersService {
  constructor(private logger: PinoLogger) {
    this.logger.setContext(UsersService.name);
  }

  async findOne(id: string): Promise<User> {
    this.logger.info({ userId: id }, 'Finding user');
    // Pino 使用第一个参数作为数据，第二个作为消息
  }
}
```

参考: [NestJS 日志记录器](https://docs.nestjs.com/techniques/logger)

---

## 参考

- https://docs.nestjs.com
- https://github.com/nestjs/nest
- https://typeorm.io
- https://github.com/typestack/class-validator
- https://github.com/goldbergyoni/nodebestpractices

---

*由 build-agents.ts 于 2026-01-16 生成*
