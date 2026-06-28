import { Controller, Post, Body, Inject } from "@nestjs/common";
import { SENTRY_PROXY_TOKEN, type SentryProxyService } from "./sentry-proxy";
import { OrderService } from "./order.service";
import { CreateOrderDto } from "./dto/create-order.dto";

/**
 * Sentry DI Wrapper 模式
 *
 * 一些 NestJS 项目会将 Sentry 包装在依赖注入令牌背后
 * 以提高可测试性和解耦。此示例展示了如何使用
 * 注入的 Service 进行所有运行时 Sentry 调用。
 *
 * 重要提示：不要在 Controller/Service 中直接导入 @sentry/nestjs
 * 请改用注入的代理。
 */

@Controller("orders")
export class OrderController {
  constructor(
    @Inject(SENTRY_PROXY_TOKEN)
    private readonly sentry: SentryProxyService,
    private readonly orderService: OrderService,
  ) {}

  /**
   * 通过 DI 包装器创建订单并使用 Sentry 链路追踪
   */
  @Post()
  async createOrder(@Body() dto: CreateOrderDto) {
    // 使用注入的 sentry 代理进行链路追踪
    return this.sentry.startSpan(
      { name: "createOrder", op: "http" },
      async () => {
        const order = await this.orderService.create(dto);

        // 通过代理添加标签
        this.sentry.setTag("order_id", order.id);
        this.sentry.setTag("user_id", order.userId);

        return order;
      },
    );
  }
}

/**
 * Sentry 代理 Service 示例
 *
 * 这是应该在共享模块中提供的包装 Service。
 */
import { Injectable } from "@nestjs/common";
import * as Sentry from "@sentry/nestjs";

export const SENTRY_PROXY_TOKEN = Symbol("SENTRY_PROXY_TOKEN");

@Injectable()
export class SentryProxyServiceImpl implements SentryProxyService {
  /**
   * 使用 Sentry 链路追踪创建 span
   */
  async startSpan<T>(
    options: { name: string; op?: string },
    callback: () => Promise<T>,
  ): Promise<T> {
    return Sentry.startSpan(
      {
        name: options.name,
        op: options.op || "function",
      },
      async () => callback(),
    );
  }

  /**
   * 在当前作用域上设置标签
   */
  setTag(key: string, value: string): void {
    Sentry.setTag(key, value);
  }

  /**
   * 捕获异常
   */
  captureException(error: Error): void {
    Sentry.captureException(error);
  }

  /**
   * 添加 breadcrumb
   */
  addBreadcrumb(message: string, category: string): void {
    Sentry.addBreadcrumb({
      message,
      category,
      level: "info",
      timestamp: Date.now() / 1000,
    });
  }
}

/**
 * Sentry 代理 Service 的接口定义
 */
export interface SentryProxyService {
  startSpan<T>(
    options: { name: string; op?: string },
    callback: () => Promise<T>,
  ): Promise<T>;
  setTag(key: string, value: string): void;
  captureException(error: Error): void;
  addBreadcrumb(message: string, category: string): void;
}

/**
 * 提供 Sentry 代理的 Module
 */
import { Module, Global } from "@nestjs/common";

@Global() // 全局可用
@Module({
  providers: [
    {
      provide: SENTRY_PROXY_TOKEN,
      useClass: SentryProxyServiceImpl,
    },
  ],
  exports: [SENTRY_PROXY_TOKEN],
})
export class SentryProxyModule {}
