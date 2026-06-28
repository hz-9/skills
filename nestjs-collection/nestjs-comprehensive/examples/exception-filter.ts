import {
  Catch,
  ArgumentsHost,
  ExceptionFilter,
  HttpException,
  Logger,
} from '@nestjs/common';
import { Request, Response } from 'express';

/**
 * HTTP 异常过滤器
 *
 * 在整个 API 中提供统一的错误响应格式
 * 记录所有异常以供监控
 */
@Catch()
export class HttpExceptionFilter implements ExceptionFilter {
  private readonly logger = new Logger(HttpExceptionFilter.name);

  catch(exception: unknown, host: ArgumentsHost) {
    const ctx = host.switchToHttp();
    const response = ctx.getResponse<Response>();
    const request = ctx.getRequest<Request>();

    // 记录异常
    this.logger.error(
      `Exception: ${request.method} ${request.url}`,
      exception instanceof Error ? exception.stack : undefined,
    );

    // 处理 HTTP 异常
    if (exception instanceof HttpException) {
      const status = exception.getStatus();
      const errorResponse = exception.getResponse();

      return response.status(status).json({
        statusCode: status,
        timestamp: new Date().toISOString(),
        path: request.url,
        error: this.formatErrorResponse(errorResponse),
      });
    }

    // 处理未知异常
    this.logger.error('Unknown exception:', exception);

    return response.status(500).json({
      statusCode: 500,
      timestamp: new Date().toISOString(),
      path: request.url,
      error: 'Internal server error',
    });
  }

  /**
   * 格式化错误响应以确保结构一致
   */
  private formatErrorResponse(errorResponse: any): any {
    // 如果已经是格式化好的对象，直接返回
    if (typeof errorResponse === 'object' && errorResponse !== null) {
      return errorResponse;
    }

    // 否则，包装为标准格式
    return {
      message: errorResponse,
    };
  }
}
