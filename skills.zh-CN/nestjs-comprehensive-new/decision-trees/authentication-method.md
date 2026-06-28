# 认证方法决策树

选择合适认证方法的决策树。

```
安全需求：
│
├─ 构建无状态 API？
│  └─ JWT + Refresh Tokens
│     ├─ 优点：可扩展、无服务器状态、移动端友好
│     ├─ 缺点：Token 撤销较麻烦、载荷较大
│     ├─ 适用于：REST API、移动应用、SPA
│     └─ 实现方式：
│        ├── Access token（短效：15分钟）
│        ├── Refresh token（长效：7天）
│        └── 将 refresh tokens 存储在数据库中以便撤销
│
├─ 需要基于会话的认证？
│  └─ Express Sessions + Redis
│     ├─ 优点：易于撤销、服务端控制
│     ├─ 缺点：需要会话存储、扩展性较差
│     ├─ 适用于：传统 Web 应用、管理后台
│     └─ 实现方式：
│        ├── express-session 中间件
│        ├── Redis 用于会话存储
│        └── 基于 Cookie 的会话 ID
│
├─ 需要 OAuth/社交登录？
│  └─ Passport + Provider Strategies
│     ├─ 优点：用户便利、可信提供商
│     ├─ 缺点：第三方依赖、提供商锁定
│     ├─ 适用于：消费级应用、B2C 平台
│     └─ 实现方式：
│        ├── @nestjs/passport
│        ├── passport-google-oauth20（或其他提供商）
│        └── 将社交账号关联到本地用户
│
├─ 构建多租户应用？
│  └─ JWT + Tenant Claims
│     ├─ 优点：租户隔离、单一认证流程
│     ├─ 缺点：复杂的 Token 管理、租户路由
│     ├─ 适用于：SaaS 平台、B2B 应用
│     └─ 实现方式：
│        ├── 在 JWT payload 中包含租户 ID
│        ├── 特定租户的 guards
│        └── 基于子域名或路径的路由
│
└─ 构建微服务？
   └─ 服务间认证使用 mTLS
      ├─ 优点：强安全性、双向认证
      ├─ 缺点：证书管理复杂
      ├─ 适用于：内部服务、高安全性应用
      └─ 实现方式：
         ├── 每个服务的 TLS 证书
         ├── 证书验证中间件
         └── 用于外部流量的 API 网关
```

## 快速对比

| 方法 | 可扩展性 | 安全性 | 复杂度 | 适用于 |
|--------|-------------|----------|------------|----------|
| JWT | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ | 中等 | API、SPA、移动端 |
| Sessions | ⭐⭐⭐ | ⭐⭐⭐⭐ | 低 | Web 应用、管理后台 |
| OAuth | ⭐⭐⭐⭐ | ⭐⭐⭐⭐ | 高 | 消费级应用 |
| 多租户 JWT | ⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | 高 | SaaS、B2B |
| mTLS | ⭐⭐⭐ | ⭐⭐⭐⭐⭐ | 非常高 | 微服务 |

## JWT 实现模式

```typescript
// Auth 模块设置
@Module({
  imports: [
    JwtModule.registerAsync({
      useFactory: (config: ConfigService) => ({
        secret: config.get('JWT_SECRET'),
        signOptions: { expiresIn: '15m' }, // Access token
      }),
    }),
  ],
})

// Refresh token 策略
async login(user: User) {
  const payload = { sub: user.id, email: user.email };
  return {
    access_token: this.jwtService.sign(payload),
    refresh_token: this.jwtService.sign(payload, {
      expiresIn: '7d',
    }),
  };
}
```

## 安全最佳实践

- **JWT**：使用强密钥（至少 32 字符）、短过期时间
- **Sessions**：使用安全 Cookie、仅 HTTPS、httpOnly 标志
- **OAuth**：验证 state 参数、校验 ID tokens
- **mTLS**：定期轮换证书、使用短期证书
- **所有方法**：实现速率限制、监控失败尝试
