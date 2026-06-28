---
title: Avoid Circular Dependencies
impact: CRITICAL
impactDescription: "#1 cause of runtime crashes"
tags: architecture, modules, dependencies
---

## Avoid Circular Dependencies

当模块 A 导入模块 B，而模块 B 又导入模块 A（直接或间接）时，就会发生循环依赖。NestJS 有时可以通过前向引用来解决这些问题，但这表明存在架构问题，应该避免。这是 NestJS 应用程序运行时崩溃的头号原因。

**Incorrect (circular module imports):**

```typescript
// users.module.ts
@Module({
  imports: [OrdersModule], // Orders needs Users, Users needs Orders = circular
  providers: [UsersService],
  exports: [UsersService],
})
export class UsersModule {}

// orders.module.ts
@Module({
  imports: [UsersModule], // Circular dependency!
  providers: [OrdersService],
  exports: [OrdersService],
})
export class OrdersModule {}
```

**Correct (extract shared logic or use events):**

```typescript
// Option 1: Extract shared logic to a third module
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

// Option 2: Use events for decoupled communication
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
    // React to user creation without direct dependency
  }
}
```

Reference: [NestJS Circular Dependency](https://docs.nestjs.com/fundamentals/circular-dependency)
