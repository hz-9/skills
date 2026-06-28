# 部署指南

将 NestJS 应用部署到生产环境的完整指南。

---

## 第一阶段：部署前检查

### 步骤 1：运行验证

```bash
# 类型检查
npm run build

# 运行所有测试
npm run test
npm run test:e2e

# Lint 检查
npm run lint
```

### 步骤 2：环境变量

创建生产环境配置文件：

```bash
# .env.production
NODE_ENV=production
PORT=3000
DATABASE_URL=postgresql://user:password@host:5432/dbname
JWT_SECRET=your-super-secret-jwt-key-min-32-chars
SENTRY_DSN=https://key@o123456.ingest.sentry.io/123456
SENTRY_ENVIRONMENT=production
```

### 步骤 3：数据库迁移

```bash
# Prisma（推荐 — 生产环境）
npx prisma migrate deploy

# 检查迁移状态
npx prisma migrate status

# 如果迁移冲突，使用 resolve 命令
npx prisma migrate resolve --rolled-back "migration_name"
```

**关键提示**：
- 生产环境始终使用 `prisma migrate deploy`，不要使用 `prisma migrate dev`
- 在 CI/CD pipeline 中运行迁移，作为部署前步骤
- 迁移前确保已运行 `prisma generate` 更新客户端
- 使用 `prisma migrate status` 检查有无待处理迁移

---

## 第二阶段：生产构建

### 步骤 4：构建应用

```bash
# 将 TypeScript 构建为 JavaScript
npm run build

# 验证构建输出
ls -la dist/
```

### 步骤 5：优化构建

```json
// package.json
{
  "scripts": {
    "build": "nest build",
    "start:prod": "node dist/main"
  }
}
```

### 步骤 6：创建生产 Dockerfile

```dockerfile
# 构建阶段
FROM node:18-alpine AS builder

WORKDIR /app
COPY package*.json ./
RUN npm ci

COPY . .
RUN npm run build

# 生产阶段
FROM node:18-alpine

WORKDIR /app

# 仅复制生产文件
COPY package*.json ./
RUN npm ci --only=production

COPY --from=builder /app/dist ./dist

# 添加健康检查
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD wget -qO- http://localhost:3000/health || exit 1

EXPOSE 3000

CMD ["node", "dist/main"]
```

---

## 第三阶段：部署选项

### 选项 A：Docker 部署

```bash
# 构建 Docker 镜像
docker build -t my-nestjs-app:latest .

# 运行容器
docker run -d \
  --name nestjs-app \
  -p 3000:3000 \
  --env-file .env.production \
  my-nestjs-app:latest

# 查看日志
docker logs -f nestjs-app

# 健康检查
docker exec nestjs-app wget -qO- http://localhost:3000/health
```

### 选项 B：Node.js PM2 部署

```bash
# 全局安装 PM2
npm i -g pm2

# 启动应用
pm2 start dist/main.js --name "nestjs-app" -i max

# PM2 配置文件 (ecosystem.config.js)
module.exports = {
  apps: [{
    name: 'nestjs-app',
    script: 'dist/main.js',
    instances: 'max',
    exec_mode: 'cluster',
    env_production: {
      NODE_ENV: 'production',
      PORT: 3000,
    },
  }],
};

# 使用配置文件启动
pm2 start ecosystem.config.js --env production

# 保存 PM2 配置
pm2 save

# 设置 PM2 开机自启
pm2 startup
```

### 选项 C：Kubernetes 部署

```yaml
# k8s/deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nestjs-app
spec:
  replicas: 3
  selector:
    matchLabels:
      app: nestjs-app
  template:
    metadata:
      labels:
        app: nestjs-app
    spec:
      containers:
        - name: nestjs-app
          image: my-nestjs-app:latest
          ports:
            - containerPort: 3000
          envFrom:
            - secretRef:
                name: nestjs-secrets
          readinessProbe:
            httpGet:
              path: /health
              port: 3000
            initialDelaySeconds: 10
            periodSeconds: 5
          livenessProbe:
            httpGet:
              path: /health
              port: 3000
            initialDelaySeconds: 30
            periodSeconds: 10
          resources:
            requests:
              memory: "256Mi"
              cpu: "250m"
            limits:
              memory: "512Mi"
              cpu: "500m"
---
apiVersion: v1
kind: Service
metadata:
  name: nestjs-app
spec:
  selector:
    app: nestjs-app
  ports:
    - protocol: TCP
      port: 80
      targetPort: 3000
  type: LoadBalancer
```

### 选项 D：Serverless（AWS Lambda）

```typescript
// serverless.ts
import { Handler, Context } from 'aws-lambda';
import { ExpressAdapter } from '@nestjs/platform-express';
import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';
import express from 'express';
import serverlessExpress from '@vendia/serverless-express';

let cachedServer: Handler;

async function bootstrap(): Promise<Handler> {
  const expressApp = express();
  const adapter = new ExpressAdapter(expressApp);
  const app = await NestFactory.create(AppModule, adapter);
  await app.init();
  return serverlessExpress({ app: expressApp });
}

export const handler: Handler = async (event: any, context: Context) => {
  if (!cachedServer) {
    cachedServer = await bootstrap();
  }
  return cachedServer(event, context, {});
};
```

---

## 第四阶段：生产配置

### 步骤 7：启用生产特性

```typescript
// src/main.ts
import * as compression from 'compression';
import * as helmet from 'helmet';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);

  if (process.env.NODE_ENV === 'production') {
    // 安全响应头
    app.use(helmet());

    // 压缩
    app.use(compression());

    // 速率限制
    // （在 ThrottlerModule 中配置）
  }

  app.enableShutdownHooks();
  await app.listen(process.env.PORT || 3000);
}
bootstrap();
```

### 步骤 8：配置日志

```typescript
import { Logger } from '@nestjs/common';

const logger = new Logger('Bootstrap');

async function bootstrap() {
  const app = await NestFactory.create(AppModule);

  if (process.env.NODE_ENV === 'production') {
    // 结构化日志
    app.useLogger(new CustomLogger());
  }

  await app.listen(process.env.PORT);
  logger.log(`Application started on port ${process.env.PORT}`);
}
```

### 步骤 9：健康检查

```typescript
// src/health/health.controller.ts
import { Controller, Get } from '@nestjs/common';
import {
  HealthCheck,
  HealthCheckService,
  TypeOrmHealthIndicator,
} from '@nestjs/terminus';

@Controller('health')
export class HealthController {
  constructor(
    private health: HealthCheckService,
    private db: TypeOrmHealthIndicator,
  ) {}

  @Get()
  @HealthCheck()
  check() {
    return this.health.check([
      () => this.db.pingCheck('database'),
    ]);
  }

  @Get('ready')
  readiness() {
    return this.health.check([
      () => this.db.pingCheck('database'),
    ]);
  }
}
```

---

## 第五阶段：监控与可观测性

### 步骤 10：启用 Sentry

```typescript
// src/instrument.ts
import * as Sentry from "@sentry/nestjs";

Sentry.init({
  dsn: process.env.SENTRY_DSN,
  environment: process.env.SENTRY_ENVIRONMENT ?? "production",
  release: process.env.SENTRY_RELEASE,
  tracesSampleRate: 0.1, // 生产环境降低采样率
  enableLogs: true,
});
```

### 步骤 11：添加指标

```typescript
// 使用 @nestjs/prometheus 获取指标
import { PrometheusModule } from '@willsoto/nestjs-prometheus';

@Module({
  imports: [PrometheusModule.register()],
})
export class AppModule {}
```

---

## 第六阶段：零停机部署

### 步骤 12：优雅关闭

```typescript
// 已在 main.ts 中启用
app.enableShutdownHooks();

// 在服务中处理关闭
@Injectable()
export class DatabaseService implements OnModuleDestroy {
  async onModuleDestroy() {
    await this.connection.close();
  }
}
```

### 步骤 13：蓝绿部署

```bash
# 并行部署新版本与旧版本
docker run -d --name nestjs-v2 -p 3001:3000 my-nestjs-app:v2

# 测试新版本
curl http://localhost:3001/health

# 切换流量（使用负载均衡器）
# 然后移除旧版本
docker stop nestjs-v1
```

---

## 部署清单

### 部署前
- [ ] 所有测试通过
- [ ] 构建成功
- [ ] 数据库迁移就绪
- [ ] 环境变量已配置
- [ ] Sentry DSN 已配置
- [ ] Docker 镜像已构建并测试

### 部署中
- [ ] 数据库迁移已应用
- [ ] 新版本已部署
- [ ] 健康检查通过
- [ ] Sentry 事件正常上报
- [ ] 日志正常输出

### 部署后
- [ ] 监控错误率
- [ ] 检查响应时间
- [ ] 验证数据库连接
- [ ] 测试关键用户流程
- [ ] 监控内存使用
- [ ] 检查 Sentry 是否有新错误

---

## 回滚策略

```bash
# Docker 回滚
docker stop nestjs-app
docker run -d --name nestjs-app -p 3000:3000 my-nestjs-app:previous-version

# PM2 回滚
pm2 restart nestjs-app --update-env

# Kubernetes 回滚
kubectl rollout undo deployment/nestjs-app
```
