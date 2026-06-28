# prisma migrate reset

重置你的数据库并重新应用所有迁移。

## 命令

```bash
prisma migrate reset [options]
```

## 功能说明

1. **删除**数据库（如果可能）或删除所有数据/表
2. **重新创建**数据库
3. **应用** `prisma/migrations/` 中的所有迁移
4. 到此为止 - 如果需要，请显式运行种子和生成命令

**警告：所有数据都将丢失。**

## 选项

| 选项 | 描述 |
|--------|-------------|
| `--force` / `-f` | 跳过确认提示 |
| `--schema` | schema 文件路径 |
| `--config` | Prisma 配置文件的自定义路径 |

## 示例

### 基本重置

```bash
prisma migrate reset
```

在交互式终端中会提示确认。

### 强制重置（CI/自动化）

```bash
prisma migrate reset --force
```

### 使用自定义 schema

```bash
prisma migrate reset --schema=./custom/schema.prisma
```

## 何时使用

- **开发环境**：当你想要重新开始时
- **测试**：在测试套件前重置测试数据库
- **漂移恢复**：当数据库不同步且无法迁移时

## 后续步骤

在重置后，当需要刷新客户端输出或种子数据时，显式运行 `prisma generate` 和 `prisma db seed`。

## 配置

在 `prisma.config.ts` 中配置种子脚本，然后在重置后显式运行它：

```typescript
export default defineConfig({
  migrations: {
    seed: 'tsx prisma/seed.ts',
  },
})
```

典型工作流：

```bash
prisma migrate reset --force
prisma generate
prisma db seed
```
