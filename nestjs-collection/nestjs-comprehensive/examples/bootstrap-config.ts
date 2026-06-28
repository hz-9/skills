import { NestFactory } from '@nestjs/core';
import { ValidationPipe, ClassSerializerInterceptor } from '@nestjs/common';
import { Reflector } from '@nestjs/core';
import { ConfigService } from '@nestjs/config';
import { AppModule } from './app.module';
import { HttpExceptionFilter } from './common/filters/http-exception.filter';
import { LoggingInterceptor } from './common/interceptors/logging.interceptor';

/**
 * 启动配置
 *
 * 演示：
 * - 全局 ValidationPipe 配置
 * - 全局拦截器
 * - 全局异常过滤器
 * - CORS 配置
 * - 优雅关闭
 * - 结构化日志
 */
async function bootstrap() {
  const app = await NestFactory.create(AppModule, {
    bufferLogs: true, // 在 Logger 就绪之前缓存日志
  });

  const configService = app.get(ConfigService);

  // ===== 全局验证 =====
  app.useGlobalPipes(
    new ValidationPipe({
      whitelist: true, // 剔除 DTO 中未定义的属性
      forbidNonWhitelisted: true, // 如果发现未白名单的属性则抛出错误
      transform: true, // 将请求体转换为 DTO 实例
      transformOptions: {
        enableImplicitConversion: true, // 启用隐式类型转换
      },
      disableErrorMessages: process.env.NODE_ENV === 'production', // 在生产环境中隐藏验证详情
    }),
  );

  // ===== 全局拦截器 =====
  app.useGlobalInterceptors(
    // 序列化拦截器 - 移除 class-transformer 标记为排除的字段
    new ClassSerializerInterceptor(app.get(Reflector)),
    // 日志拦截器 - 记录请求/响应
    new LoggingInterceptor(),
  );

  // ===== 全局异常过滤器 =====
  app.useGlobalFilters(
    new HttpExceptionFilter(), // 自定义异常过滤器，用于统一的错误响应
  );

  // ===== CORS 配置 =====
  app.enableCors({
    origin: configService.get<string>('FRONTEND_URL', 'http://localhost:3000'),
    credentials: true,
    methods: ['GET', 'POST', 'PUT', 'DELETE', 'PATCH'],
    allowedHeaders: ['Content-Type', 'Authorization'],
    exposedHeaders: ['X-Total-Count'],
  });

  // ===== 安全请求头 =====
  if (process.env.NODE_ENV === 'production') {
    app.use((req, res, next) => {
      res.setHeader('X-Content-Type-Options', 'nosniff');
      res.setHeader('X-Frame-Options', 'DENY');
      res.setHeader('X-XSS-Protection', '1; mode=block');
      next();
    });
  }

  // ===== 优雅关闭 =====
  app.enableShutdownHooks();

  // ===== 启动服务器 =====
  const port = configService.get<number>('PORT', 3000);
  await app.listen(port);

  console.log(`🚀 Application running on: http://localhost:${port}`);
  console.log(`📊 Environment: ${process.env.NODE_ENV || 'development'}`);
}

// 处理启动错误
bootstrap().catch((error) => {
  console.error('Failed to start application:', error);
  process.exit(1);
});
