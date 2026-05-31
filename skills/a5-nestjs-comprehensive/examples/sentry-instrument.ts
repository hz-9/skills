/**
 * Sentry 三文件配置模式
 *
 * 这是 NestJS + Sentry 集成的推荐配置方式。
 * 重要提示：instrument.ts 必须是 main.ts 中的第一个导入
 */

// ===== 文件 1：src/instrument.ts =====
// 此文件必须最先导入，在任何其他模块之前
import * as Sentry from "@sentry/nestjs";
// 可选：添加性能分析
// import { nodeProfilingIntegration } from "@sentry/profiling-node";

Sentry.init({
  dsn: process.env.SENTRY_DSN,
  environment: process.env.SENTRY_ENVIRONMENT ?? "production",
  release: process.env.SENTRY_RELEASE,
  sendDefaultPii: true,

  // 链路追踪 — 在高流量生产环境中建议降低到 0.1-0.2
  tracesSampleRate: 1.0,

  // 性能分析（需要 @sentry/profiling-node）
  // integrations: [nodeProfilingIntegration()],
  // profileSessionSampleRate: 1.0,
  // profileLifecycle: "trace",

  // 结构化日志（SDK >= 9.41.0）
  enableLogs: true,
});

// ===== 文件 2：src/main.ts =====
// instrument.ts 必须是最靠前的导入
import "./instrument";

import { NestFactory } from "@nestjs/core";
import { AppModule } from "./app.module";

async function bootstrap() {
  const app = await NestFactory.create(AppModule);

  // 启用优雅关闭 — 在收到 SIGTERM/SIGINT 信号时刷新 Sentry 事件
  app.enableShutdownHooks();

  await app.listen(3000);
}
bootstrap();

// ===== 文件 3：src/app.module.ts =====
import { Module } from "@nestjs/common";
import { APP_FILTER } from "@nestjs/core";
import { SentryModule, SentryGlobalFilter } from "@sentry/nestjs/setup";

@Module({
  imports: [
    SentryModule.forRoot(), // 全局注册 SentryTracingInterceptor
  ],
  providers: [
    {
      provide: APP_FILTER,
      useClass: SentryGlobalFilter, // 捕获所有未处理的异常
    },
  ],
})
export class AppModule {}
