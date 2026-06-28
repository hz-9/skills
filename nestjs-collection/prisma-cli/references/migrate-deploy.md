# prisma migrate deploy

在生产/预演环境中应用待处理的迁移。

## 命令

```bash
prisma migrate deploy
```

## 功能说明

- 应用 `prisma/migrations/` 中所有待处理的迁移
- 更新 `_prisma_migrations` 表
- **不**生成新的迁移
- **不**运行种子脚本
- 对 CI/CD 和生产环境安全

## 选项

| 选项 | 描述 |
|--------|-------------|
| `--schema` | Prisma schema 的自定义路径 |
| `--config` | Prisma 配置文件的自定义路径 |

## 何时使用

- 生产环境部署
- 预演环境
- CI/CD 流水线
- 任何非开发环境

## 示例

### 基本部署

```bash
prisma migrate deploy
```

### 在 CI/CD 流水线中

```yaml
# GitHub Actions 示例
- name: 应用迁移
  run: npx prisma migrate deploy
  env:
    DATABASE_URL: ${{ secrets.DATABASE_URL }}
```

### Docker 部署

```dockerfile
# 在启动应用前运行迁移
CMD npx prisma migrate deploy && node dist/index.js
```

## 与 migrate dev 的对比

| 特性 | migrate dev | migrate deploy |
|---------|-------------|----------------|
| 创建迁移 | 是 | 否 |
| 应用迁移 | 是 | 是 |
| 检测漂移 | 是 | 否 |
| 提示输入 | 是 | 否 |
| 使用影子数据库 | 是 | 否 |
| 生产环境安全 | 否 | 是 |
| 出现问题时 | 提示重置 | 失败退出 |

## 生产工作流

1. **开发环境**：本地创建迁移
   ```bash
   prisma migrate dev --name add_feature
   ```

2. **提交**：将迁移文件纳入版本控制
   ```bash
   git add prisma/migrations
   git commit -m "添加功能迁移"
   ```

3. **部署**：在生产环境应用
   ```bash
   prisma migrate deploy
   ```

## 错误处理

### 迁移失败

如果迁移失败，`migrate deploy` 会以错误码退出。失败的迁移会在 `_prisma_migrations` 中被标记为失败。

修复方法：
1. 解决问题（修复 SQL、数据库状态等）
2. 标记为已解决：`prisma migrate resolve --applied <migration_name>`
3. 重新运行：`prisma migrate deploy`

### 先检查状态

```bash
prisma migrate status
```

在部署前显示待处理和已应用的迁移。

## 配置

确保 `prisma.config.ts` 中有生产数据库 URL：

```typescript
import 'dotenv/config'
import { defineConfig, env } from 'prisma/config'

export default defineConfig({
  datasource: {
    url: env('DATABASE_URL'),
  },
})
```

## 最佳实践

1. 在 CI 中，始终在 `migrate deploy` 之前运行 `migrate status`
2. 制定回滚计划（迁移前备份）
3. 先在预演环境测试迁移
4. 切勿在生产环境中使用 `migrate dev`
