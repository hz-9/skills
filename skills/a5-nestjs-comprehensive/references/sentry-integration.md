# Sentry 集成指南

将 Sentry 错误监控和追踪集成到 NestJS 应用程序的完整指南。

## 概述

Sentry 为 NestJS 应用程序提供错误监控、分布式追踪、性能分析、结构化日志、指标、Cron 监控和 AI 监控。

## 4 阶段工作流

### 阶段 1：检测（Detect）

扫描项目以了解设置：

```bash
# 确认 NestJS 项目
grep -E '"@nestjs/core"' package.json 2>/dev/null

# 检查 NestJS 版本
node -e "console.log(require('./node_modules/@nestjs/core/package.json').version)" 2>/dev/null

# 检查现有 Sentry
grep -i sentry package.json 2>/dev/null
ls src/instrument.ts 2>/dev/null
grep -r "Sentry.init\|@sentry" src/main.ts src/instrument.ts 2>/dev/null

# 检查现有 Sentry DI wrapper
grep -rE "SENTRY.*TOKEN|SentryProxy|SentryService" src/ libs/ 2>/dev/null

# 检测 HTTP adapter（默认是 Express）
grep -E "FastifyAdapter|@nestjs/platform-fastify" package.json src/main.ts 2>/dev/null

# 检测 GraphQL
grep -E '"@nestjs/graphql"|"apollo-server"' package.json 2>/dev/null

# 检测微服务
grep '"@nestjs/microservices"' package.json 2>/dev/null

# 检测 WebSockets
grep -E '"@nestjs/websockets"|"socket.io"' package.json 2>/dev/null

# 检测任务队列/定时任务
grep -E '"@nestjs/bull"|"@nestjs/bullmq"|"@nestjs/schedule"|"bullmq"|"bull"' package.json 2>/dev/null

# 检测数据库
grep -E '"@prisma/client"|"typeorm"|"mongoose"|"pg"|"mysql2"' package.json 2>/dev/null

# 检测 AI 库
grep -E '"openai"|"@anthropic-ai"|"langchain"|"@langchain"|"@google/generative-ai"|"ai"' package.json 2>/dev/null
```

### 阶段 2：推荐（Recommend）

**始终推荐（核心覆盖）：**
- ✅ **错误监控** — 捕获未处理的异常
- ✅ **追踪** — 自动检测 middleware、guards、pipes、interceptors、filters 和 route handlers

**检测到后推荐：**
- ✅ **性能分析** — 对 CPU 性能重要的生产应用
- ✅ **日志** — 结构化 Sentry Logs + 可选的 console 捕获
- ✅ **Crons** — 检测到 `@nestjs/schedule`、Bull 或 BullMQ
- ✅ **指标** — 业务 KPI 或 SLO 追踪
- ✅ **AI 监控** — 检测到 OpenAI/Anthropic/LangChain 等

### 阶段 3：指导（Guide）

逐步实现 Sentry（参见以下各节）。

### 阶段 4：交叉链接（Cross-Link）

检查是否缺少配套前端的 Sentry 并推荐匹配的 skill。

---

## 安装

```bash
# 核心 SDK（始终必需 — 包含 @sentry/node）
npm install @sentry/nestjs

# 带性能分析支持（可选）
npm install @sentry/nestjs @sentry/profiling-node
```

> ⚠️ **不要将 `@sentry/node` 与 `@sentry/nestjs` 一起安装** — `@sentry/nestjs` 重新导出了 `@sentry/node` 的所有内容。

---

## 三文件设置模式

### 步骤 1：创建 `src/instrument.ts`

```typescript
import * as Sentry from "@sentry/nestjs";
// 可选：添加性能分析
// import { nodeProfilingIntegration } from "@sentry/profiling-node";

Sentry.init({
  dsn: process.env.SENTRY_DSN,
  environment: process.env.SENTRY_ENVIRONMENT ?? "production",
  release: process.env.SENTRY_RELEASE,
  sendDefaultPii: true,

  // 追踪 — 在高流量生产环境中降低到 0.1–0.2
  tracesSampleRate: 1.0,

  // 性能分析（需要 @sentry/profiling-node）
  // integrations: [nodeProfilingIntegration()],
  // profileSessionSampleRate: 1.0,
  // profileLifecycle: "trace",

  // 结构化日志（SDK ≥ 9.41.0）
  enableLogs: true,
});
```

### 步骤 2：在 `src/main.ts` 中首先导入

```typescript
// instrument.ts 必须是最第一个导入 — 在 NestJS 或任何其他模块之前
import "./instrument";

import { NestFactory } from "@nestjs/core";
import { AppModule } from "./app.module";

async function bootstrap() {
  const app = await NestFactory.create(AppModule);

  // 启用优雅关闭 — 在 SIGTERM/SIGINT 时刷新 Sentry 事件
  app.enableShutdownHooks();

  await app.listen(3000);
}
bootstrap();
```

> **为什么首先？** OpenTelemetry 必须在 `http`、`express`、数据库驱动等模块加载之前对它们进行 monkey-patch。

### 步骤 3：在 `src/app.module.ts` 中注册

```typescript
import { Module } from "@nestjs/common";
import { APP_FILTER } from "@nestjs/core";
import { SentryModule, SentryGlobalFilter } from "@sentry/nestjs/setup";
import { AppController } from "./app.controller";
import { AppService } from "./app.service";

@Module({
  imports: [
    SentryModule.forRoot(), // 全局注册 SentryTracingInterceptor
  ],
  controllers: [AppController],
  providers: [
    AppService,
    {
      provide: APP_FILTER,
      useClass: SentryGlobalFilter, // 捕获所有未处理的异常
    },
  ],
})
export class AppModule {}
```

**每个部分的作用：**
- `SentryModule.forRoot()` — 将 `SentryTracingInterceptor` 注册为全局 `APP_INTERCEPTOR`
- `SentryGlobalFilter` — 在 HTTP、GraphQL 和 RPC 上下文中捕获异常

> ⚠️ **不要重复注册 `SentryModule.forRoot()`。** 重复注册会导致每个 span 被拦截两次。

> ⚠️ **两个入口点，不同的导入：**
> - `@sentry/nestjs` → SDK 初始化、capture APIs、decorators
> - `@sentry/nestjs/setup` → NestJS DI 构造（`SentryModule`、`SentryGlobalFilter`）

---

## ESM 设置（Node ≥ 18.19.0）

```javascript
// instrument.mjs
import * as Sentry from "@sentry/nestjs";

Sentry.init({
  dsn: process.env.SENTRY_DSN,
  tracesSampleRate: 1.0,
});
```

```json
{
  "scripts": {
    "start": "node --import ./instrument.mjs -r ts-node/register src/main.ts"
  }
}
```

---

## 异常过滤器选项

### 选项 A：没有现有全局过滤器 — 使用 `SentryGlobalFilter`（推荐）

已在上面的步骤 3 中涵盖。

### 选项 B：现有自定义全局过滤器 — 添加 decorator

```typescript
import { Catch, ExceptionFilter, ArgumentsHost } from "@nestjs/common";
import { SentryExceptionCaptured } from "@sentry/nestjs";

@Catch()
export class YourExistingFilter implements ExceptionFilter {
  @SentryExceptionCaptured()
  catch(exception: unknown, host: ArgumentsHost): void {
    // 你现有的错误处理继续不变
  }
}
```

### 选项 C：特定异常类型 — 手动捕获

```typescript
import { ArgumentsHost, Catch } from "@nestjs/common";
import { BaseExceptionFilter } from "@nestjs/core";
import * as Sentry from "@sentry/nestjs";

@Catch(ExampleException)
export class ExampleExceptionFilter extends BaseExceptionFilter {
  catch(exception: ExampleException, host: ArgumentsHost) {
    Sentry.captureException(exception);
    super.catch(exception, host);
  }
}
```

### 选项 D：微服务 RPC 异常

```typescript
import { Catch, RpcExceptionFilter, ArgumentsHost } from "@nestjs/common";
import { Observable, throwError } from "rxjs";
import { RpcException } from "@nestjs/microservices";
import * as Sentry from "@sentry/nestjs";

@Catch(RpcException)
export class SentryRpcFilter implements RpcExceptionFilter<RpcException> {
  catch(exception: RpcException, host: ArgumentsHost): Observable<any> {
    Sentry.captureException(exception);
    return throwError(() => exception.getError());
  }
}
```

---

## Decorators

### `@SentryTraced(op?)` — 检测任何方法

```typescript
import { Injectable } from "@nestjs/common";
import { SentryTraced } from "@sentry/nestjs";

@Injectable()
export class OrderService {
  @SentryTraced("order.process")
  async processOrder(orderId: string): Promise<void> {
    // 自动包装在 Sentry span 中
  }

  @SentryTraced()  // 默认为 op: "function"
  async fetchInventory() { /* ... */ }
}
```

### `@SentryCron(slug, config?)` — 监控定时任务

```typescript
import { Injectable } from "@nestjs/common";
import { Cron } from "@nestjs/schedule";
import { SentryCron } from "@sentry/nestjs";

@Injectable()
export class ReportService {
  @Cron("0 * * * *")
  @SentryCron("hourly-report", {
    // @SentryCron 必须放在 @Cron 之后
    schedule: { type: "crontab", value: "0 * * * *" },
    checkinMargin: 2,
    maxRuntime: 10,
    timezone: "UTC",
  })
  async generateReport() {
    // 在启动/成功/失败时自动发送 check-in
  }
}
```

### 后台任务作用域隔离

```typescript
import * as Sentry from "@sentry/nestjs";
import { Injectable } from "@nestjs/common";
import { Cron, CronExpression } from "@nestjs/schedule";

@Injectable()
export class JobService {
  @Cron(CronExpression.EVERY_HOUR)
  handleCron() {
    Sentry.withIsolationScope(() => {
      Sentry.setTag("job", "hourly-sync");
      this.doWork();
    });
  }
}
```

将 `withIsolationScope` 应用于：`@Cron()`、`@Interval()`、`@OnEvent()`、`@Processor()` 以及任何在请求生命周期之外的代码。

---

## 使用 Sentry DI Wrappers

一些 NestJS 项目为了可测试性将 Sentry 包装在 dependency injection token 之后。

```typescript
import { Controller, Inject } from "@nestjs/common";
import { SENTRY_PROXY_TOKEN, type SentryProxyService } from "./sentry-proxy";

@Controller("orders")
export class OrderController {
  constructor(
    @Inject(SENTRY_PROXY_TOKEN) private readonly sentry: SentryProxyService,
    private readonly orderService: OrderService,
  ) {}

  @Post()
  async createOrder(@Body() dto: CreateOrderDto) {
    return this.sentry.startSpan(
      { name: "createOrder", op: "http" },
      async () => this.orderService.create(dto),
    );
  }
}
```

**直接导入 `@sentry/nestjs` 仍然正确的场景：**
- `instrument.ts` — 始终使用 `import * as Sentry from "@sentry/nestjs"` 进行 `Sentry.init()`
- 在 DI container 之外运行的独立脚本和异常过滤器

---

## 配置参考

### 关键 `Sentry.init()` 选项

| 选项 | 类型 | 默认值 | 用途 |
|--------|------|---------|---------|
| `dsn` | `string` | — | 如果为空则 SDK 禁用；环境变量：`SENTRY_DSN` |
| `environment` | `string` | `"production"` | 例如 `"staging"` |
| `release` | `string` | — | 例如 `"myapp@1.0.0"` |
| `sendDefaultPii` | `boolean` | `false` | 包含 IP 地址和请求 headers |
| `tracesSampleRate` | `number` | — | 事务采样率 |
| `tracesSampler` | `function` | — | 自定义每个事务采样 |
| `tracePropagationTargets` | `Array<string|RegExp>` | — | 传播 headers 的 URLs |
| `profileSessionSampleRate` | `number` | — | 连续性能分析率（SDK ≥ 10.27.0） |
| `profileLifecycle` | `"trace"\|"manual"` | `"trace"` | 自动或手动性能分析 |
| `enableLogs` | `boolean` | `false` | 发送结构化日志（SDK ≥ 9.41.0） |
| `ignoreErrors` | `Array<string|RegExp>` | `[]` | 要抑制的错误消息模式 |
| `ignoreTransactions` | `Array<string|RegExp>` | `[]` | 要抑制的事务名称模式 |
| `beforeSend` | `function` | — | 修改或丢弃错误事件的钩子 |
| `beforeSendTransaction` | `function` | — | 修改或丢弃事务事件的钩子 |
| `beforeSendLog` | `function` | — | 修改或丢弃日志事件的钩子 |
| `debug` | `boolean` | `false` | 详细 SDK 调试输出 |
| `maxBreadcrumbs` | `number` | `100` | 每个事件的最大 breadcrumbs 数 |

### 环境变量

| 变量 | 映射到 | 说明 |
|----------|---------|-------|
| `SENTRY_DSN` | `dsn` | 如果 `init()` 未传递 `dsn` 则使用 |
| `SENTRY_RELEASE` | `release` | 也可从 git SHA 自动检测 |
| `SENTRY_ENVIRONMENT` | `environment` | 回退到 `"production"` |
| `SENTRY_AUTH_TOKEN` | CLI/source maps | 用于 source map 上传 |
| `SENTRY_ORG` | CLI/source maps | 组织 slug |
| `SENTRY_PROJECT` | CLI/source maps | 项目 slug |

### 自动启用的集成

当检测到相应的包时，这些集成会自动激活：

| 集成 | 说明 |
|-------------|-------|
| `httpIntegration` | 传出 HTTP 调用 |
| `expressIntegration` | Express adapter（默认 NestJS） |
| `nestIntegration` | NestJS 生命周期 |
| `onUncaughtExceptionIntegration` | 未捕获的异常 |
| `onUnhandledRejectionIntegration` | 未处理的 promise 拒绝 |
| `openAIIntegration` | OpenAI SDK（安装时） |
| `anthropicAIIntegration` | Anthropic SDK（安装时） |
| `langchainIntegration` | LangChain（安装时） |
| `graphqlIntegration` | GraphQL（当存在 `graphql` 包时） |
| `postgresIntegration` | `pg` 驱动 |
| `mysqlIntegration` | `mysql` / `mysql2` |
| `mongoIntegration` | MongoDB / Mongoose |
| `redisIntegration` | `ioredis` / `redis` |

### 需要手动设置的集成

| 集成 | 何时添加 | 代码 |
|-------------|-------------|------|
| `nodeProfilingIntegration` | 需要性能分析时 | `import { nodeProfilingIntegration } from "@sentry/profiling-node"` |
| `prismaIntegration` | 使用 Prisma ORM 时 | `integrations: [Sentry.prismaIntegration()]` |
| `consoleLoggingIntegration` | 捕获 console 输出时 | `integrations: [Sentry.consoleLoggingIntegration()]` |
| `localVariablesIntegration` | 捕获局部变量值时 | `integrations: [Sentry.localVariablesIntegration()]` |

---

## 验证

测试 Sentry 是否正在接收事件：

```typescript
// 添加一个测试端点（生产前移除）
import { Controller, Get } from "@nestjs/common";
import * as Sentry from "@sentry/nestjs";

@Controller()
export class DebugController {
  @Get("/debug-sentry")
  triggerError() {
    throw new Error("My first Sentry error from NestJS!");
  }

  @Get("/debug-sentry-span")
  triggerSpan() {
    return Sentry.startSpan({ op: "test", name: "NestJS Test Span" }, () => {
      return { status: "span created" };
    });
  }
}
```

或者在不崩溃的情况下发送测试消息：

```typescript
import * as Sentry from "@sentry/nestjs";
Sentry.captureMessage("NestJS Sentry SDK test");
```

如果没有出现任何内容：
1. 在 `Sentry.init()` 中设置 `debug: true` — 将 SDK 内部信息打印到 stdout
2. 验证运行中的进程是否设置了 `SENTRY_DSN` 环境变量
3. 确认 `import "./instrument"` 是 `main.ts` 中的**第一行**
4. 确认 `SentryModule.forRoot()` 已在 `AppModule` 中导入
5. 检查 DSN 格式：`https://<key>@o<org>.ingest.sentry.io/<project>`

---

## 版本要求

| 功能 | 最低 SDK 版本 |
|---------|---------------------|
| `@sentry/nestjs` 包 | 8.0.0 |
| `@SentryTraced` decorator | 8.15.0 |
| `@SentryCron` decorator | 8.16.0 |
| Event Emitter 自动检测 | 8.39.0 |
| `SentryGlobalFilter`（统一） | 8.40.0 |
| `Sentry.logger` API（`enableLogs`） | 9.41.0 |
| `profileSessionSampleRate` | 10.27.0 |
| Node.js 要求 | ≥ 18 |
| ESM `--import` 的 Node.js | ≥ 18.19.0 |
| NestJS 兼容性 | 8.x – 11.x |
