import { Injectable } from "@nestjs/common";
import { SentryTraced, SentryCron } from "@sentry/nestjs";
import * as Sentry from "@sentry/nestjs";
import { Cron, CronExpression } from "@nestjs/schedule";

/**
 * Sentry 装饰器示例
 *
 * 演示：
 * - 使用 @SentryTraced 进行方法插桩
 * - 使用 @SentryCron 进行定时任务监控
 * - 使用 Sentry.withIsolationScope 处理后台任务
 */

@Injectable()
export class OrderService {
  /**
   * @SentryTraced - 自动将方法包装在 Sentry span 中
   * 自定义操作名称以提高链路追踪的清晰度
   */
  @SentryTraced("order.process")
  async processOrder(orderId: string): Promise<void> {
    // 此方法会自动包装在 Sentry span 中
    // 性能和错误都会被捕获
    console.log(`Processing order: ${orderId}`);

    // 添加自定义标签以便过滤
    Sentry.setTag("order_id", orderId);

    // 添加 breadcrumb 用于调试上下文
    Sentry.addBreadcrumb({
      category: "order",
      message: `Processing order ${orderId}`,
      level: "info",
    });

    // 模拟订单处理
    await this.validateOrder(orderId);
    await this.chargePayment(orderId);
    await this.updateInventory(orderId);
  }

  /**
   * @SentryTraced 不设置自定义 op - 默认使用 "function"
   */
  @SentryTraced()
  async fetchInventory(): Promise<any> {
    return { stock: 100 };
  }

  /**
   * 手动创建 span 以获得更多控制权
   */
  async createOrderWithSpan(orderData: any) {
    return Sentry.startSpan(
      {
        name: "createOrder",
        op: "order.create",
        attributes: {
          "order.items": orderData.items.length,
        },
      },
      async (span) => {
        // 此处可以访问 span 上下文
        span.setAttribute("order.total", orderData.total);

        const order = await this.saveOrder(orderData);

        // 更新 span 状态
        span.setAttribute("order.id", order.id);

        return order;
      },
    );
  }

  /**
   * @SentryCron - 监控定时任务
   * 重要提示：@SentryCron 必须放在 @Cron 之后
   */
  @Cron(CronExpression.EVERY_HOUR)
  @SentryCron("hourly-report", {
    schedule: { type: "crontab", value: "0 * * * *" },
    checkinMargin: 2, // 标记为错过之前的分钟数
    maxRuntime: 10, // 最大运行时间（分钟）
    timezone: "UTC",
  })
  async generateHourlyReport() {
    console.log("Generating hourly report...");
    // 在开始/成功/失败时自动发送 check-in
  }

  /**
   * 使用隔离作用域的后台任务
   * 防止任务执行之间的上下文交叉污染
   */
  @Cron(CronExpression.EVERY_10_MINUTES)
  handlePeriodicCleanup() {
    // 使用隔离作用域包装以防止上下文泄露
    Sentry.withIsolationScope(() => {
      Sentry.setTag("job", "cleanup");

      try {
        this.performCleanup();
        Sentry.setTag("job.status", "success");
      } catch (error) {
        Sentry.captureException(error);
        Sentry.setTag("job.status", "failed");
        throw error;
      }
    });
  }

  // 私有辅助方法

  private async validateOrder(orderId: string) {
    // 验证订单逻辑
  }

  private async chargePayment(orderId: string) {
    // 支付处理逻辑
  }

  private async updateInventory(orderId: string) {
    // 库存更新逻辑
  }

  private async saveOrder(orderData: any) {
    // 保存订单到数据库
    return { id: "123", ...orderData };
  }

  private performCleanup() {
    // 清理逻辑
  }
}
