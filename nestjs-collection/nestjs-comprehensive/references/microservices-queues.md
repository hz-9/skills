# 微服务与队列指南

使用 NestJS 构建微服务和后台任务处理的完整指南。

## 微服务架构

### 安装

```bash
npm i @nestjs/microservices
```

### TCP 传输

#### 微服务应用程序

```typescript
// src/main.ts
import { NestFactory } from '@nestjs/core';
import { MicroserviceOptions, Transport } from '@nestjs/microservices';
import { AppModule } from './app.module';

async function bootstrap() {
  const app = await NestFactory.createMicroservice<MicroserviceOptions>(
    AppModule,
    {
      transport: Transport.TCP,
      options: {
        host: '0.0.0.0',
        port: 3001,
      },
    },
  );

  await app.listen();
}
bootstrap();
```

#### 客户端配置

```typescript
// src/app.module.ts
import { Module, OnModuleInit } from '@nestjs/common';
import { ClientsModule, Transport, ClientProxy } from '@nestjs/microservices';

@Module({
  imports: [
    ClientsModule.register([
      {
        name: 'USERS_SERVICE',
        transport: Transport.TCP,
        options: { host: 'localhost', port: 3001 },
      },
    ]),
  ],
})
export class AppModule implements OnModuleInit {
  constructor(@Inject('USERS_SERVICE') private client: ClientProxy) {}

  async onModuleInit() {
    await this.client.connect();
  }
}
```

#### 消息模式（Message Pattern）

```typescript
// src/users/users.controller.ts
import { Controller } from '@nestjs/common';
import { MessagePattern, Payload } from '@nestjs/microservices';

@Controller()
export class UsersController {
  @MessagePattern('get_user')
  async getUser(@Payload() data: { id: number }) {
    return this.usersService.findById(data.id);
  }

  @MessagePattern('create_user')
  async createUser(@Payload() data: CreateUserDto) {
    return this.usersService.create(data);
  }
}
```

#### 事件模式（Event Pattern，Fire and Forget）

```typescript
import { EventPattern } from '@nestjs/microservices';

@EventPattern('user_created')
async handleUserCreated(data: any) {
  // 异步处理事件
  await this.emailService.sendWelcomeEmail(data.email);
}
```

### Redis 传输

```typescript
import { Transport } from '@nestjs/microservices';

{
  transport: Transport.REDIS,
  options: {
    url: 'redis://localhost:6379',
  },
}
```

### 健康检查

```typescript
// src/health/health.controller.ts
import { Controller, Get } from '@nestjs/common';
import {
  HealthCheck,
  HealthCheckService,
  TypeOrmHealthIndicator,
  HttpHealthIndicator,
} from '@nestjs/terminus';

@Controller('health')
export class HealthController {
  constructor(
    private health: HealthCheckService,
    private db: TypeOrmHealthIndicator,
    private http: HttpHealthIndicator,
  ) {}

  @Get()
  @HealthCheck()
  check() {
    return this.health.check([
      () => this.db.pingCheck('database'),
      () => this.http.pingCheck('external-api', 'https://api.example.com'),
    ]);
  }
}
```

---

## 后台任务处理

### Bull/BullMQ 集成

#### 安装

```bash
npm i @nestjs/bullmq bullmq
# 或
npm i @nestjs/bull bull
```

#### 模块配置

```typescript
// src/app.module.ts
import { BullModule } from '@nestjs/bullmq';

@Module({
  imports: [
    BullModule.forRoot({
      connection: {
        host: 'localhost',
        port: 6379,
      },
    }),
    BullModule.registerQueue({
      name: 'email-queue',
    }),
  ],
})
export class AppModule {}
```

#### 生产者（Producer）

```typescript
// src/email/email.service.ts
import { Injectable } from '@nestjs/common';
import { InjectQueue } from '@nestjs/bullmq';
import { Queue } from 'bullmq';

@Injectable()
export class EmailService {
  constructor(@InjectQueue('email-queue') private emailQueue: Queue) {}

  async sendWelcomeEmail(email: string) {
    await this.emailQueue.add('send-welcome', {
      email,
      template: 'welcome',
    });
  }

  async sendPasswordReset(email: string) {
    await this.emailQueue.add('send-password-reset', {
      email,
      template: 'password-reset',
    });
  }
}
```

#### 消费者（Processor）

```typescript
// src/email/email.processor.ts
import { Processor, WorkerHost } from '@nestjs/bullmq';
import { Job } from 'bullmq';

@Processor('email-queue')
export class EmailProcessor extends WorkerHost {
  async process(job: Job<any, any, string>): Promise<any> {
    switch (job.name) {
      case 'send-welcome':
        return this.sendWelcomeEmail(job.data.email);
      case 'send-password-reset':
        return this.sendPasswordReset(job.data.email);
      default:
        throw new Error(`Unknown job: ${job.name}`);
    }
  }

  private async sendWelcomeEmail(email: string) {
    // 发送欢迎邮件
    console.log(`Sending welcome email to ${email}`);
  }

  private async sendPasswordReset(email: string) {
    // 发送密码重置邮件
    console.log(`Sending password reset email to ${email}`);
  }
}
```

### 定时任务

#### 安装

```bash
npm i @nestjs/schedule
```

#### 配置

```typescript
import { ScheduleModule } from '@nestjs/schedule';

@Module({
  imports: [ScheduleModule.forRoot()],
})
```

#### Cron 任务

```typescript
import { Injectable } from '@nestjs/common';
import { Cron, CronExpression } from '@nestjs/schedule';

@Injectable()
export class ReportService {
  @Cron(CronExpression.EVERY_HOUR)
  async generateHourlyReport() {
    console.log('Generating hourly report...');
  }

  @Cron('0 0 * * *') // 每天午夜
  async generateDailyReport() {
    console.log('Generating daily report...');
  }
}
```

#### 间隔任务（Interval Jobs）

```typescript
import { Interval } from '@nestjs/schedule';

@Interval(10000) // 每 10 秒
async checkHealth() {
  console.log('Checking system health...');
}
```

#### 超时任务（Timeout Jobs）

```typescript
import { Timeout } from '@nestjs/schedule';

@Timeout(5000) // 5 秒后执行一次
async initialize() {
  console.log('Initializing...');
}
```

---

## 微服务最佳实践

### Message Pattern 与 Event Pattern 对比

- **Message Pattern**：请求/响应，期望返回回复
- **Event Pattern**：Fire and forget，不期望回复

### 微服务中的错误处理

```typescript
import { RpcException } from '@nestjs/microservices';

@MessagePattern('get_user')
async getUser(data: { id: number }) {
  const user = await this.usersService.findById(data.id);
  if (!user) {
    throw new RpcException('User not found');
  }
  return user;
}
```

### 重试逻辑

```typescript
BullModule.registerQueue({
  name: 'email-queue',
  defaultJobOptions: {
    attempts: 3,
    backoff: {
      type: 'exponential',
      delay: 1000,
    },
  },
}),
```

---

## 生产环境注意事项

- 为编排实现健康检查
- 为 Redis 使用连接池
- 监控队列大小和任务处理时间
- 为失败的任务实现死信队列（dead letter queues）
- 为任务处理添加指标和日志
- 使用优雅关闭以完成正在进行的任务
- 为消息处理实现幂等性
