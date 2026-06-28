# prisma db pull

内省现有数据库并更新你的 Prisma schema 以反映其结构。

## 命令

```bash
prisma db pull [options]
```

## 功能说明

- 连接到你的数据库
- 读取数据库 schema（表、列、关系、索引）
- 使用相应的 Prisma 模型更新 `schema.prisma`
- 对于 MongoDB，通过采样数据来推断 schema

## 选项

| 选项 | 描述 |
|--------|-------------|
| `--force` | 忽略当前 Prisma schema 文件 |
| `--print` | 将内省后的 Prisma schema 打印到标准输出 |
| `--schema` | Prisma schema 的自定义路径 |
| `--config` | Prisma 配置文件的自定义路径 |
| `--url` | 覆盖 Prisma 配置文件中的数据源 URL |
| `--composite-type-depth` | 指定内省复合类型的深度（默认：-1 表示无限，0 表示关闭） |
| `--schemas` | 指定要内省的数据库 schema |
| `--local-d1` | 从本地 Cloudflare D1 数据库生成 Prisma schema |

## 示例

### 基本内省

```bash
prisma db pull
```

### 预览而不写入

```bash
prisma db pull --print
```

将 schema 输出到终端供审查。

### 强制覆盖

```bash
prisma db pull --force
```

替换 schema 文件，丢失所有手动自定义内容。

## 前提条件

在 `prisma.config.ts` 中配置数据库连接：

```typescript
import 'dotenv/config'
import { defineConfig, env } from 'prisma/config'

export default defineConfig({
  schema: 'prisma/schema.prisma',
  datasource: {
    url: env('DATABASE_URL'),
  },
})
```

## 工作流

### 从现有数据库开始

1. 初始化 Prisma：
   ```bash
   prisma init
   ```

2. 配置数据库 URL

3. 拉取 schema：
   ```bash
   prisma db pull
   ```

4. 审查并自定义生成的 schema

5. 生成客户端：
   ```bash
   prisma generate
   ```

### 同步来自数据库的更改

当数据库变更在 Prisma 之外进行时：

```bash
prisma db pull
prisma generate
```

## 生成的 Schema 示例

数据库表变为 Prisma 模型：

```sql
-- 数据库表
CREATE TABLE users (
  id SERIAL PRIMARY KEY,
  email VARCHAR(255) UNIQUE NOT NULL,
  name VARCHAR(100)
);

CREATE TABLE posts (
  id SERIAL PRIMARY KEY,
  title VARCHAR(255) NOT NULL,
  author_id INTEGER REFERENCES users(id)
);
```

变为：

```prisma
model users {
  id    Int     @id @default(autoincrement())
  email String  @unique @db.VarChar(255)
  name  String? @db.VarChar(100)
  posts posts[]
}

model posts {
  id        Int    @id @default(autoincrement())
  title     String @db.VarChar(255)
  author_id Int?
  users     users? @relation(fields: [author_id], references: [id])
}
```

## 内省后清理

在 `db pull` 之后，考虑：

1. **将模型重命名**为 PascalCase：
   ```prisma
   model User {  // 原为：users
     @@map("users")
   }
   ```

2. **将字段重命名**为 camelCase：
   ```prisma
   authorId Int? @map("author_id")
   ```

3. **添加关系名称**以提高清晰度：
   ```prisma
   author User? @relation("PostAuthor", fields: [authorId], references: [id])
   ```

4. **添加文档注释**：
   ```prisma
   /// 用户账户信息
   model User {
     /// 用于认证的主邮箱
     email String @unique
   }
   ```

## MongoDB 内省

对于 MongoDB，`db pull` 会采样文档来推断 schema：

```bash
prisma db pull
```

由于 MongoDB 是无 schema 的，可能需要手动调整。

## 警告

`db pull` 会覆盖你的 schema 文件。始终：
- 在拉取前提交当前 schema
- 先使用 `--print` 预览
- 备份你想要保留的自定义内容
