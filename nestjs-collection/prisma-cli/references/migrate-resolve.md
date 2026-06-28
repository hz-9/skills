# prisma migrate resolve

解决数据库迁移问题，例如失败的迁移或基线化。

## 命令

```bash
prisma migrate resolve [options]
```

## 功能说明

更新 `_prisma_migrations` 表以手动更改迁移的状态。这是一个恢复工具。

## 选项

你必须提供 `--applied` 或 `--rolled-back` 中的一个（且仅一个）。

| 选项 | 描述 |
|--------|-------------|
| `--applied <name>` | 将迁移标记为**已应用**（成功） |
| `--rolled-back <name>` | 将迁移标记为**已回滚**（已忽略/失败） |
| `--schema` | schema 文件路径 |
| `--config` | Prisma 配置文件的自定义路径 |

## 示例

### 标记为已应用（基线化）

如果你有现有表并想初始化迁移而不运行 SQL：

```bash
prisma migrate resolve --applied 20240101000000_initial_migration
```

这告诉 Prisma"假定此迁移已运行过"。

### 标记为已回滚（修复失败）

如果迁移失败（例如语法错误），并且你已修复 SQL 或想重试：

```bash
prisma migrate resolve --rolled-back 20240115120000_failed_migration
```

这告诉 Prisma"忘记这次迁移的运行，让我重新尝试应用它"。

## 使用场景

1. **基线化**：在现有生产数据库上采用 Prisma Migrate。
2. **失败的迁移**：从生产环境中失败的 `migrate deploy` 中恢复。
3. **热修复**：协调手动数据库更改（较少见）。

## 参考

- [基线化](https://www.prisma.io/docs/guides/database/developing-with-prisma-migrate/baselining)
- [故障排除](https://www.prisma.io/docs/guides/database/production-troubleshooting)
