# prisma migrate diff

比较数据库 schema 并生成差异（SQL 或摘要）。

## 命令

```bash
prisma migrate diff [options]
```

## 功能说明

- 比较两个源（`--from-...` 和 `--to-...`）
- 源可以是：
    - 空（`empty`）
    - Schema 文件（`schema`）
    - 迁移目录（`migrations`）
    - 数据库 URL（`url`）或已配置的数据源（`config-datasource`）
- 输出差异：
    - 人类可读的摘要（默认）
    - SQL 脚本（`--script`）

## 选项

| 选项 | 描述 |
|--------|-------------|
| `--script` | 将 SQL 脚本渲染到标准输出 |
| `--exit-code` | 检测到变更时退出码为 2，无变更时为 0，错误时为 1 |
| `--config` | Prisma 配置文件的自定义路径 |

### 源（必须提供一个 `from` 和一个 `to`）

- `--from-empty`、`--to-empty`
- `--from-schema <path>`、`--to-schema <path>`
- `--from-migrations <path>`、`--to-migrations <path>`
- `--from-url <url>`、`--to-url <url>`
- `--from-config-datasource`、`--to-config-datasource`（使用 `prisma.config.ts`）

## 示例

### 为 schema 变更生成 SQL

比较当前生产数据库与本地 schema：

```bash
prisma migrate diff \
  --from-url "$PROD_DB_URL" \
  --to-schema ./prisma/schema.prisma \
  --script
```

### 审查待处理迁移

比较数据库状态与迁移目录：

```bash
prisma migrate diff \
  --from-config-datasource \
  --to-migrations ./prisma/migrations
```

### 创建基线迁移

比较空状态与当前 schema：

```bash
prisma migrate diff \
  --from-empty \
  --to-schema ./prisma/schema.prisma \
  --script > prisma/migrations/0_init/migration.sql
```

### 检查漂移（CI）

检查数据库是否与 schema 匹配：

```bash
prisma migrate diff \
  --from-config-datasource \
  --to-schema ./prisma/schema.prisma \
  --exit-code
```

## 使用场景

- **正向生成迁移**：无需 `migrate dev` 即可创建 SQL。
- **漂移检测**：检查数据库是否同步。
- **基线化**：从现有数据库创建初始迁移。
- **调试**：了解 `migrate dev` 会做什么。
