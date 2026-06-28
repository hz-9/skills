# prisma db execute

对你的数据库执行原生命令（SQL）。

## 命令

```bash
prisma db execute [options]
```

## 功能说明

- 使用配置的数据源连接到你的数据库
- 通过文件（`--file`）或标准输入（`--stdin`）执行脚本
- 适用于运行原生 SQL、维护任务或应用 `migrate diff` 生成的差异
- 不支持 MongoDB

## 选项

| 选项 | 描述 |
|--------|-------------|
| `--file` | 包含要执行脚本的文件路径 |
| `--stdin` | 使用终端标准输入作为脚本 |
| `--config` | Prisma 配置文件的自定义路径 |

## 当前选项范围

`prisma db execute` 使用在 `prisma.config.ts` 中配置的数据源。如果需要对其他环境使用单独的配置文件，请使用 `--config`。

## 示例

### 从文件执行

```bash
prisma db execute --file ./script.sql
```

### 从标准输入执行

```bash
echo "TRUNCATE TABLE User;" | prisma db execute --stdin
```

### 执行 `migrate diff` 的输出

将 `migrate diff` 的输出直接通过管道发送到数据库：

```bash
prisma migrate diff \
  --from-empty \
  --to-schema prisma/schema.prisma \
  --script \
| prisma db execute --stdin
```

## 配置

使用 `prisma.config.ts` 中的 `datasource`：

```typescript
export default defineConfig({
  datasource: {
    url: env('DATABASE_URL'),
  },
})
```

## 使用场景

- **手动迁移**：应用原生 SQL 变更
- **数据维护**：清空表、清理数据
- **Schema 同步**：应用 `migrate diff` 脚本
- **调试**：运行测试查询（虽然通常不用于获取数据）

## 限制

- **不返回数据**：该命令报告成功/失败，而不是查询结果（行）。请使用 Prisma Client 或 `prisma studio` 查看数据。
- **仅限 SQL**：主要用于 SQL 数据库。
