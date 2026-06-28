# 代码审查检查清单

用于审查 NestJS 应用程序的综合检查清单。

---

## 模块架构与依赖注入

- [ ] 所有 Service 都正确使用了 `@Injectable()` 装饰器
- [ ] Provider 已列在 Module 的 providers 数组中
- [ ] 其他 Module 需要时正确导出了 Provider
- [ ] Module 之间没有循环依赖（检查 `forwardRef` 的使用）
- [ ] Module 边界遵循领域/特性分离原则
- [ ] 自定义 Provider 使用了正确的注入令牌（避免使用字符串令牌）
- [ ] Module 按特性组织，而非按技术层组织
- [ ] 共享功能已提取到共享 Module 中
- [ ] 全局 Module 使用了 `@Global()` 装饰器标记

**常见问题**：
- Module 的 providers 数组中缺少 Provider
- 导出了 Module 而非 Service
- 循环依赖表明架构设计不佳
- Service Locator 反模式

---

## 测试与 Mock

- [ ] 测试 Module 使用了最小化、专注的 Provider Mock
- [ ] TypeORM Repository 使用 `getRepositoryToken(Entity)` 进行 Mock
- [ ] 单元测试中不包含实际的数据库依赖
- [ ] 测试中所有异步操作都正确使用了 await
- [ ] JwtService 和外部依赖已适当 Mock
- [ ] 测试覆盖率达到了项目阈值
- [ ] 成功和失败场景都已测试
- [ ] E2E 测试使用了与生产环境相同的全局 Pipe/Filter
- [ ] 测试之间清理了测试数据

**常见问题**：
- 忘记 Mock 依赖
- 未对异步操作使用 await
- 测试实现细节而非行为
- 测试之间共享状态

---

## 数据库集成（TypeORM 重点）

- [ ] 实体装饰器使用了正确的语法（`@Column()` 而非 `@Column('description')`）
- [ ] 连接错误不会导致整个应用程序崩溃
- [ ] 多个数据库连接使用了命名连接
- [ ] 数据库连接具有适当的错误处理和重试逻辑
- [ ] 实体已在 `TypeOrmModule.forFeature()` 中正确注册
- [ ] 使用 Migration 进行 Schema 变更（生产环境中不使用 synchronize）
- [ ] 多步骤操作使用了事务
- [ ] 避免了 N+1 查询问题（使用关联或 DataLoader）
- [ ] 频繁查询的字段已添加数据库索引

**常见问题**：
- 装饰器语法错误
- 缺少实体注册
- 生产环境中启用自动同步
- N+1 查询问题
- 连接池耗尽

---

## 认证与安全（JWT + Passport）

- [ ] JWT Strategy 从 'passport-jwt' 导入而非 'passport-local'
- [ ] JwtModule 的 secret 与 JwtStrategy 的 secretOrKey 完全匹配
- [ ] Authorization 请求头遵循 'Bearer [token]' 格式
- [ ] Token 过期时间适合使用场景
- [ ] JWT_SECRET 环境变量已正确配置
- [ ] 密码使用 bcrypt 进行哈希（最低 cost factor 为 10）
- [ ] 所有端点都使用 class-validator 进行输入验证
- [ ] 响应中不返回敏感字段（密码、令牌）
- [ ] 公共端点已实现速率限制
- [ ] CORS 已针对前端域正确配置

**常见问题**：
- 导入了错误的 Passport Strategy
- JWT secret 不匹配
- 缺少 Token 过期时间
- 硬编码的 secret
- 返回了密码哈希值

---

## 请求生命周期与中间件

- [ ] 中间件执行顺序遵循：中间件 → Guards → Interceptors → Pipes
- [ ] Guards 正确保护路由并返回布尔值或抛出异常
- [ ] Interceptors 正确处理异步操作
- [ ] 异常过滤器正确捕获并转换错误
- [ ] Pipes 使用 class-validator 装饰器验证 DTO
- [ ] 全局验证 Pipe 配置了 whitelist 和 transform
- [ ] API 之间的错误响应保持一致
- [ ] 实现了请求关联 ID 用于日志记录

**常见问题**：
- 装饰器顺序错误（例如 @SentryCron 在 @Cron 之前）
- 公共端点缺少验证
- 错误响应格式不一致
- 未在 Interceptors 中处理异步错误

---

## 性能与优化

- [ ] 对耗时操作实现了缓存
- [ ] 数据库查询避免了 N+1 问题（使用 DataLoader 模式）
- [ ] 数据库连接配置了连接池
- [ ] 防止了内存泄漏（在 `onModuleDestroy()` 中清理事件监听器）
- [ ] 生产环境启用了压缩中间件
- [ ] 大数据集实现了响应分页
- [ ] 大文件响应使用了流式传输
- [ ] 重量级 Module 使用了懒加载
- [ ] 生产环境配置了 Sentry 监控

**常见问题**：
- N+1 查询问题
- 缺少缓存失效机制
- 事件监听器导致的内存泄漏
- 生产环境缺少压缩
- 缺少分页

---

## 代码质量

- [ ] 启用了 TypeScript 严格模式
- [ ] 未使用 `any` 类型（或通过注释说明了理由）
- [ ] 命名约定一致
- [ ] 变量和函数名称有意义
- [ ] 代码遵循项目风格指南
- [ ] 生产代码中没有 console.log（使用 Logger）
- [ ] 错误消息不会泄露敏感信息
- [ ] 注释解释了"为什么"而非"是什么"
- [ ] 已删除死代码（未使用的导入、函数）

---

## 文档

- [ ] API 端点已记录文档（Swagger/OpenAPI）
- [ ] 复杂业务逻辑在注释中有说明
- [ ] 环境变量已有文档记录
- [ ] README 中包含设置说明
- [ ] 架构决策已有文档记录（ADRs）

---

## 安全检查清单

- [ ] 没有硬编码的 secret
- [ ] 启动时验证环境变量
- [ ] 生产环境启用 HTTPS
- [ ] CORS 已正确配置
- [ ] 已实现速率限制
- [ ] 输入已清洗和验证
- [ ] 输出已清洗（XSS 防护）
- [ ] 防止 SQL 注入（使用 ORM/参数化查询）
- [ ] 文件上传已验证（类型、大小、扩展名）
- [ ] 依赖已更新（无已知漏洞）
