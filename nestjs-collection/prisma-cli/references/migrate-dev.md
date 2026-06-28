# prisma migrate dev

在开发期间创建并应用迁移。需要影子数据库。

## 命令

```bash
prisma migrate dev [options]
```

## 功能说明

1. 在影子数据库中运行现有迁移以检测漂移
2. 应用任何待处理的迁移
3. 根据 schema 变更生成新的迁移
4. 将新迁移应用到开发数据库
5. 更新 `_prisma_migrations` 表

## 选项

| 选项 | 描述 |
|--------|-------------|
| `--name` / `-n` | 为迁移命名 |
| `--create-only` | 创建新迁移但不应用它 |
| `--schema` | Prisma schema 的自定义路径 |
| `--config` | Prisma 配置文件的自定义路径 |
| `--url` | 覆盖 Prisma 配置文件中的数据源 URL |

### 后续命令

- 当需要刷新客户端输出时，显式运行 `prisma generate`
- 当需要种子数据时，显式运行 `prisma db seed`

注意：Prisma CLI 帮助文档（7.6.0 版本）仍声称 `migrate dev` 会"触发 generators"，但在临时 Prisma 7.6.0 项目中的本地验证并未生成客户端文件。当需要在磁盘上生成构建产物时，请将 `prisma generate` 视为显式的后续步骤。

## 示例

### 创建并应用迁移

```bash
prisma migrate dev
```

如果 schema 有变更，会提示输入迁移名称。

### 命名迁移

```bash
prisma migrate dev --name add_users_table
```

### 仅创建不应用

```bash
prisma migrate dev --create-only
```

适用于在应用前审查迁移 SQL。

### 完整工作流

```bash
prisma migrate dev --name my_migration
prisma generate
prisma db seed
```

## 迁移文件

创建在 `prisma/migrations/` 目录中：

```
prisma/migrations/
├── 20240115120000_add_users_table/
│   └── migration.sql
├── 20240116090000_add_posts/
│   └── migration.sql
└── migration_lock.toml
```

## Schema 漂移检测

如果 `migrate dev` 检测到漂移（手动数据库更改或已编辑的迁移），它会提示重置：

```
检测到漂移：你的数据库 schema 不同步。

是否要重置数据库？所有数据都将丢失。
```

## 何时使用

- 本地开发
- 添加新模型/字段
- 更改关系
- 创建索引

## 何时不使用

- 生产环境部署（使用 `migrate deploy`）
- CI/CD 流水线（使用 `migrate deploy`）
- MongoDB（改用 `db push`）

## 常见模式

### Schema 更改后

```prisma
// schema.prisma - 添加新字段
model User {
  id        Int      @id @default(autoincrement())
  email     String   @unique
  name      String?
  createdAt DateTime @default(now())  // 新字段
}
```

```bash
prisma migrate dev --name add_created_at
```

### 处理数据丢失警告

当迁移会导致数据丢失时：

```bash
prisma migrate dev --name remove_field
# 警告：你将删除数据...
# 接受方式：--accept-data-loss
```

## 影子数据库

`migrate dev` 需要一个影子数据库用于漂移检测。在 `prisma.config.ts` 中配置：

```typescript
export default defineConfig({
  datasource: {
    url: env('DATABASE_URL'),
    shadowDatabaseUrl: env('SHADOW_DATABASE_URL'),
  },
})
```

对于本地 Prisma Postgres（`prisma dev`），影子数据库会自动处理。
