# prisma db push

将 schema 变更直接推送到数据库，而不创建迁移。适合原型开发。

## 命令

```bash
prisma db push [options]
```

## 功能说明

- 将你的 Prisma schema 同步到数据库
- 如果数据库不存在则创建
- **不**创建迁移文件
- **不**跟踪迁移历史

## 选项

| 选项 | 描述 |
|--------|-------------|
| `--force-reset` | 在推送前强制重置数据库 |
| `--accept-data-loss` | 忽略数据丢失警告 |
| `--schema` | Prisma schema 的自定义路径 |
| `--config` | Prisma 配置文件的自定义路径 |
| `--url` | 覆盖 Prisma 配置文件中的数据源 URL |

### 后续命令

- 当需要刷新客户端输出时，显式运行 `prisma generate`

## 示例

### 基本推送

```bash
prisma db push
```

### 接受数据丢失

```bash
prisma db push --accept-data-loss
```

当更改会删除数据时（删除列等）需要此选项。

### 强制重置

```bash
prisma db push --force-reset
```

完全重置数据库并应用 schema。

### 完整工作流

```bash
prisma db push
prisma generate
```

## 何时使用

- **原型开发** - 快速 schema 迭代
- **本地开发** - 快速 schema 更改
- **MongoDB** - 主要工作流（不支持迁移）
- **测试** - 设置测试数据库

## 何时不使用

- **生产环境** - 使用 `migrate deploy`
- **团队协作** - 使用迁移来跟踪变更
- **需要回滚时** - 迁移提供历史记录

## 与 migrate dev 的对比

| 特性 | db push | migrate dev |
|---------|---------|-------------|
| 创建迁移文件 | 否 | 是 |
| 跟踪历史 | 否 | 是 |
| 需要影子数据库 | 否 | 是 |
| 速度 | 更快 | 较慢 |
| 回滚能力 | 否 | 是 |
| 最适合 | 原型开发 | 开发环境 |

## MongoDB 工作流

MongoDB 不支持迁移。请专门使用 `db push`：

```bash
# MongoDB 的 Schema 更改
prisma db push
prisma generate
```

## 常见模式

### 原型开发工作流

```bash
# 进行 schema 更改
# ...

# 推送到数据库
prisma db push

# 生成客户端
prisma generate

# 测试你的更改
# 根据需要重复
```

### 重置并重新开始

```bash
prisma db push --force-reset
prisma db seed
```

### 处理冲突

如果 `db push` 无法安全地应用更改：

```
Error: 以下更改无法应用：
  - 移除 `email` 字段会导致数据丢失
  
使用 --accept-data-loss 继续
```

判断数据丢失是否可接受，然后：

```bash
prisma db push --accept-data-loss
```

## 过渡到迁移

当准备进入生产环境时，切换到迁移：

```bash
# 从当前 schema 创建基线迁移
prisma migrate dev --name init
```

然后对未来的更改使用 `migrate dev`。
