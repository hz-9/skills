# NestJS 技能工作流优化指南

## 概述

本文档概述了通过利用并行执行、子代理委派和依赖管理策略，使用 Drizzle ORM 构建 NestJS 应用程序的优化工作流。

## 关键优化原则

### 1. 并行执行策略

可以同时执行的任务：
- **包安装**：并行安装 NestJS、Drizzle、测试和开发依赖
- **模块脚手架**：同时为多个模块创建文件夹结构
- **接口/类型定义**：在设置数据库 schema 的同时定义 DTO 和接口
- **测试准备**：在编写实现代码的同时设置测试配置

### 2. 顺序依赖

必须按特定顺序执行的任务：
1. **项目设置**：`npm install → nest new → cd project → 安装额外的包`
2. **数据库设置**：`.env → drizzle.config.ts → schema → 迁移 → 数据库服务 → 仓库`
3. **功能开发**：`DTO → 仓库 → 服务 → 控制器 → 模块 → 守卫`
4. **测试**：`单元测试 → 集成测试 → 端到端测试`

## 优化工作流示例

### 工作流 1：使用 Drizzle ORM 的新 NestJS 项目

```yaml
阶段 1：并行设置（代理：2-3 个）
  代理 1：项目初始化
    - 创建 NestJS 项目
    - 安装核心依赖
    - 配置 TypeScript
    - 设置基本文件夹结构

  代理 2：数据库准备
    - 安装 Drizzle 包
    - 配置环境文件
    - 设置 drizzle.config.ts
    - 准备数据库连接

阶段 2：核心配置（顺序执行）
  - 数据库 schema 定义
  - 迁移生成
  - 数据库服务设置

阶段 3：并行功能开发（代理：2-4 个）
  代理 1：数据层
    - 仓库实现
    - 服务层逻辑
    - 数据层单元测试

  代理 2：API 层
    - 控制器实现
    - DTO 和验证
    - 路由保护

  代理 3：安全
    - 认证设置
    - 守卫实现
    - 安全中间件

  代理 4：文档
    - OpenAPI 装饰器
    - API 文档
    - README 生成

阶段 4：集成与测试（并行执行）
  - 集成测试
  - 端到端测试场景
  - 性能优化
```

### 工作流 2：添加新功能模块

```yaml
步骤 1：并行准备
  - 定义功能需求
  - 创建模块文件夹结构
  - 准备 DTO 和接口
  - 设置测试文件

步骤 2：数据层（数据库代理）
  - 创建/更新 schema
  - 生成迁移
  - 实现仓库
  - 编写仓库测试

步骤 3：业务逻辑（服务代理）
  - 实现服务方法
  - 添加业务验证
  - 处理事务
  - 编写单元测试

步骤 4：API 层（控制器代理）
  - 创建控制器端点
  - 添加验证管道
  - 实现守卫
  - 编写集成测试

步骤 5：安全集成（安全代理）
  - 添加路由保护
  - 实现基于角色的访问
  - 添加审计日志
  - 安全测试

步骤 6：文档（文档代理）
  - 添加 OpenAPI 装饰器
  - 更新 API 文档
  - 创建示例
  - 审查文档
```

## 子代理委派模式

### 何时委派给数据库代理
- 设置新的数据库连接
- 复杂的 schema 迁移
- 查询优化
- 事务管理
- 数据库测试设置

### 何时委派给安全代理
- 实现认证
- 设置授权
- 安全审计需求
- OAuth 集成
- 漏洞修复

### 何时委派给测试代理
- 创建全面的测试套件
- 测试基础设施设置
- CI/CD 测试集成
- 性能测试
- 测试数据管理

## 优化最佳实践

### 1. 依赖管理
```typescript
// 使用异步配置进行并行设置
@Module({
  imports: [
    ConfigModule.forRoot({ isGlobal: true }),
    DatabaseModule,
    AuthModule,
  ],
})
export class AppModule {}
```

### 2. 模块化架构
```typescript
// 保持模块独立以支持并行开发
@Module({
  imports: [DatabaseModule],
  controllers: [UsersController],
  providers: [UsersService, UsersRepository],
  exports: [UsersService],
})
export class UsersModule {}
```

### 3. 配置驱动的开发
```typescript
// 启用环境特定的并行开发
export default () => ({
  database: {
    url: process.env.DATABASE_URL,
    poolSize: parseInt(process.env.DB_POOL_SIZE) || 10,
  },
  features: {
    auth: process.env.ENABLE_AUTH === 'true',
    caching: process.env.ENABLE_CACHE === 'true',
  },
});
```

### 4. 测试驱动的并行开发
```typescript
// 在实现的同时编写测试
describe('UsersService', () => {
  // 测试设置可以与服务实现并行运行
  beforeEach(async () => {
    const module = await Test.createTestingModule({
      providers: [UsersService, MockRepository],
    }).compile();
  });
});
```

## 性能优化技术

### 1. 数据库优化
- 使用连接池
- 实现查询批处理
- 添加适当的索引
- 合理使用数据库事务

### 2. API 优化
- 实现缓存策略
- 使用分页
- 添加压缩中间件
- 优化序列化

### 3. 测试优化
- 并行测试执行
- 测试数据库复用
- 模拟外部服务
- 选择性测试运行

## 监控与反馈

### 1. 工作流指标
- 跟踪每个阶段的时间消耗
- 衡量并行执行效率
- 监控瓶颈
- 收集代理性能数据

### 2. 质量门禁
- 合并前进行代码审查
- 自动化测试
- 安全扫描
- 性能基准测试

## 结论

通过遵循这些优化工作流并利用专门的子代理，使用 Drizzle ORM 的 NestJS 开发可以显著加速，同时保持高代码质量和架构完整性。关键在于理解任务依赖关系、最大化并行执行，并将专业工作委派给专家子代理。
