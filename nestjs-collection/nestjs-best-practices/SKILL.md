---
name: nestjs-best-practices
description: NestJS best practices and architecture patterns for building production-ready applications. This skill should be used when writing, reviewing, or refactoring NestJS code to ensure proper patterns for modules, dependency injection, security, and performance.
license: MIT
metadata:
  author: Kadajett
  version: "1.1.0"
---

# NestJS Best Practices

涵盖 10 个类别共 40 条规则的 NestJS 应用程序最佳实践指南，按影响程度排序，以指导自动化重构和代码生成。

## When to Apply

在以下情况下参考这些指南：

- 编写新的 NestJS 模块、控制器或服务
- 实现认证和授权
- 审查代码以发现架构和安全问题
- 重构现有的 NestJS 代码库
- 优化性能或数据库查询
- 构建微服务架构

## Rule Categories by Priority

| Priority | Category | Impact | Prefix |
|----------|----------|--------|--------|
| 1 | Architecture | CRITICAL | `arch-` |
| 2 | Dependency Injection | CRITICAL | `di-` |
| 3 | Error Handling | HIGH | `error-` |
| 4 | Security | HIGH | `security-` |
| 5 | Performance | HIGH | `perf-` |
| 6 | Testing | MEDIUM-HIGH | `test-` |
| 7 | Database & ORM | MEDIUM-HIGH | `db-` |
| 8 | API Design | MEDIUM | `api-` |
| 9 | Microservices | MEDIUM | `micro-` |
| 10 | DevOps & Deployment | LOW-MEDIUM | `devops-` |

## Quick Reference

### 1. Architecture (CRITICAL)

- `arch-avoid-circular-deps` - 避免循环模块依赖
- `arch-feature-modules` - 按功能组织，而非技术层
- `arch-module-sharing` - 正确的模块导出/导入，避免重复的 provider
- `arch-single-responsibility` - 专注的服务，而非"上帝服务"
- `arch-use-repository-pattern` - 抽象数据库逻辑以提高可测试性
- `arch-use-events` - 事件驱动架构实现解耦

### 2. Dependency Injection (CRITICAL)

- `di-avoid-service-locator` - 避免服务定位器反模式
- `di-interface-segregation` - 接口隔离原则（ISP）
- `di-liskov-substitution` - 里氏替换原则（LSP）
- `di-prefer-constructor-injection` - 构造函数注入优于属性注入
- `di-scope-awareness` - 理解单例/请求/瞬态作用域
- `di-use-interfaces-tokens` - 为接口使用注入令牌

### 3. Error Handling (HIGH)

- `error-use-exception-filters` - 集中式异常处理
- `error-throw-http-exceptions` - 使用 NestJS HTTP 异常
- `error-handle-async-errors` - 正确处理异步错误

### 4. Security (HIGH)

- `security-auth-jwt` - 安全的 JWT 认证
- `security-validate-all-input` - 使用 class-validator 验证
- `security-use-guards` - 认证和授权守卫
- `security-sanitize-output` - 防止 XSS 攻击
- `security-rate-limiting` - 实现速率限制

### 5. Performance (HIGH)

- `perf-async-hooks` - 正确的异步生命周期钩子
- `perf-use-caching` - 实现缓存策略
- `perf-optimize-database` - 优化数据库查询
- `perf-lazy-loading` - 懒加载模块以加快启动速度

### 6. Testing (MEDIUM-HIGH)

- `test-use-testing-module` - 使用 NestJS 测试工具
- `test-e2e-supertest` - 使用 Supertest 进行 E2E 测试
- `test-mock-external-services` - 模拟外部依赖

### 7. Database & ORM (MEDIUM-HIGH)

- `db-use-transactions` - 事务管理
- `db-avoid-n-plus-one` - 避免 N+1 查询问题
- `db-use-migrations` - 使用迁移进行 Schema 更改

### 8. API Design (MEDIUM)

- `api-use-dto-serialization` - DTO 和响应序列化
- `api-use-interceptors` - 横切关注点
- `api-versioning` - API 版本控制策略
- `api-use-pipes` - 使用管道进行输入转换

### 9. Microservices (MEDIUM)

- `micro-use-patterns` - 消息和事件模式
- `micro-use-health-checks` - 用于编排的健康检查
- `micro-use-queues` - 后台作业处理

### 10. DevOps & Deployment (LOW-MEDIUM)

- `devops-use-config-module` - 环境配置
- `devops-use-logging` - 结构化日志
- `devops-graceful-shutdown` - 零停机部署

## How to Use

阅读单个规则文件以获取详细解释和代码示例：

```
rules/arch-avoid-circular-deps.md
rules/security-validate-all-input.md
rules/_sections.md
```

每个规则文件包含：
- 为什么重要的简要说明
- 带有解释的错误代码示例
- 带有解释的正确代码示例
- 额外的上下文和参考资料

## Full Compiled Document

完整指南（包含所有扩展规则）：`AGENTS.md`
