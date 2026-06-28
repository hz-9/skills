# prisma dev

启动一个用于开发的本地 Prisma Postgres 数据库。提供一个完全在本地机器上运行的 PostgreSQL 兼容数据库。

## 命令

```bash
prisma dev [options]
```

## 功能说明

- 启动本地 PostgreSQL 兼容数据库
- 在终端中或作为后台进程运行
- 非常适合开发和测试
- 可轻松迁移到生产环境中的 Prisma Postgres 云服务

## 选项

| 选项 | 描述 | 默认值 |
|--------|-------------|---------|
| `--name` / `-n` | 数据库实例的名称 | `default` |
| `--port` / `-p` | HTTP 服务器端口 | `51213` |
| `--db-port` / `-P` | 数据库服务器端口 | `51214` |
| `--shadow-db-port` | 影子数据库端口（用于迁移） | `51215` |
| `--detach` / `-d` | 在后台运行 | `false` |
| `--debug` | 启用调试日志 | `false` |

## 示例

### 启动本地数据库

```bash
prisma dev
```

交互模式下的键盘快捷键：
- `q` - 退出
- `h` - 显示 HTTP URL
- `t` - 显示 TCP URL

### 命名实例

```bash
prisma dev --name myproject
```

适用于多个项目。

### 后台模式

```bash
prisma dev --detach
```

释放终端供其他命令使用。

### 自定义端口

```bash
prisma dev --port 5000 --db-port 5432
```

## 实例管理

### 列出所有实例

```bash
prisma dev ls
```

显示所有本地 Prisma Postgres 实例及其状态。

### 启动现有实例

```bash
prisma dev start myproject
```

在后台启动之前创建的实例。

### 停止实例

```bash
prisma dev stop myproject
```

### 使用 glob 模式停止

```bash
prisma dev stop "myproject*"
```

停止所有匹配模式的实例。

### 删除实例

```bash
prisma dev rm myproject
```

从文件系统中删除实例数据。

### 强制删除（先停止）

```bash
prisma dev rm myproject --force
```

## 配置

配置你的 `prisma.config.ts` 以使用本地 Prisma Postgres：

```typescript
import 'dotenv/config'
import { defineConfig, env } from 'prisma/config'

export default defineConfig({
  schema: 'prisma/schema.prisma',
  migrations: {
    path: 'prisma/migrations',
  },
  datasource: {
    // 本地 Prisma Postgres URL（来自 prisma dev 输出）
    url: env('DATABASE_URL'),
  },
})
```

## 工作流

1. 启动本地数据库：
   ```bash
   prisma dev
   ```

2. 在另一个终端中，运行迁移：
   ```bash
   prisma migrate dev
   ```

3. 生成客户端：
   ```bash
   prisma generate
   ```

4. 运行你的应用程序

## 生产迁移

当准备进入生产环境时，切换到 Prisma Postgres 云服务：

```bash
prisma init --db
```

将你的 `DATABASE_URL` 更新为云连接字符串。
