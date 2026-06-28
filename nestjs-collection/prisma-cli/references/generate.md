# prisma generate

根据 Prisma schema 中的 generator 块生成资产，最常见的是 Prisma Client。

## 命令

```bash
prisma generate [options]
```

## Bun 运行时

如果你使用 Bun，请使用 `bunx --bun` 运行 Prisma，这样它不会回退到 Node.js：

```bash
bunx --bun prisma generate
```

## 功能说明

1. 读取你的 `schema.prisma` 文件
2. 根据你的模型生成定制的 Prisma Client
3. 输出到 generator 块中指定的目录

## 选项

| 选项 | 描述 |
|--------|-------------|
| `--schema` | Prisma schema 的自定义路径 |
| `--config` | Prisma 配置文件的自定义路径 |
| `--sql` | 生成类型化的 sql 模块 |
| `--watch` | 监听 Prisma schema 并在更改后重新运行 |
| `--generator` | 要使用的 generator（可多次提供） |
| `--no-hints` | 隐藏提示消息，但仍输出错误和警告 |
| `--require-models` | 不允许在没有模型的情况下生成客户端 |

## 示例

### 基本生成

```bash
prisma generate
```

### 监听模式（开发）

```bash
prisma generate --watch
```

在 `schema.prisma` 更改时自动重新生成。

### 指定 Generator

```bash
prisma generate --generator client
```

### 多个 Generator

```bash
prisma generate --generator client --generator zod_schemas
```

### 生成类型化 SQL

```bash
prisma generate --sql
```

## Schema 配置

```prisma
generator client {
  provider = "prisma-client"
  output   = "../generated"
}
```

### 当前 Generator 行为

- `prisma-client` 是标准 generator
- 使用 `prisma-client` 时，`output` 是必需的
- `prisma-client` 通过 `moduleFormat` 同时支持 ESM 和 CommonJS
- `compilerBuild` 支持 `fast` 和 `small` 查询编译器产物
- 使用 TypeScript `satisfies` 为 `prisma-client` 进行类型化查询片段
- 从生成输出路径导入 Prisma Client，例如：

```typescript
import { PrismaClient } from '../generated/prisma/client'
```

### 编译器构建调优

当你需要在产物大小与默认构建之间取舍时，使用 `compilerBuild`：

```prisma
generator client {
  provider      = "prisma-client"
  output        = "../generated"
  compilerBuild = "small"
}
```

- `fast` 是大多数目标的默认构建
- `small` 适用于大小受限的目标
- Prisma 默认将 `vercel-edge` 目标设为 `small`

## 常见模式

### Schema 更改后

```bash
prisma migrate dev --name my_migration
prisma generate
```

每当你在执行 schema 更改命令后需要刷新客户端代码时，运行 `prisma generate`。

### CI/CD 流水线

```bash
prisma generate
```

在构建应用程序之前运行。

### 多个 Generator

```prisma
generator client {
  provider = "prisma-client"
  output   = "../generated"
}

generator zod {
  provider = "zod-prisma-types"
  output   = "../generated/zod"
}
```

```bash
prisma generate  # 运行所有 generator
```

## 输出结构

运行 `prisma generate` 后，你的输出目录包含：

```
generated/
├── browser.ts
├── client.ts
├── commonInputTypes.ts
├── models/
├── enums.ts
├── models.ts
└── ...
```

导入客户端：

```typescript
import { PrismaClient, Prisma } from '../generated/prisma/client'
```

导入浏览器安全类型：

```typescript
import { Prisma } from '../generated/prisma/browser'
import { Role } from '../generated/prisma/enums'
import type { UserModel } from '../generated/prisma/models/User'
```
