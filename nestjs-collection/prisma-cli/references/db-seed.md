# prisma db seed

运行你的数据库种子脚本来填充数据。

## 命令

```bash
prisma db seed [options]
```

## 功能说明

- 执行你配置的种子脚本
- 用初始/测试数据填充数据库
- 独立运行（在 v7 中不会由迁移自动执行）

## 选项

| 选项 | 描述 |
|--------|-------------|
| `--config` | Prisma 配置文件的自定义路径 |
| `--` | 向种子脚本传递自定义参数 |

## 配置

在 `prisma.config.ts` 中配置种子脚本：

```typescript
import 'dotenv/config'
import { defineConfig, env } from 'prisma/config'

export default defineConfig({
  schema: 'prisma/schema.prisma',
  migrations: {
    path: 'prisma/migrations',
    seed: 'tsx prisma/seed.ts',  // 你的种子命令
  },
  datasource: {
    url: env('DATABASE_URL'),
  },
})
```

### 常见的种子命令

```typescript
// 使用 tsx 的 TypeScript
seed: 'tsx prisma/seed.ts'

// 使用 ts-node 的 TypeScript
seed: 'ts-node prisma/seed.ts'

// JavaScript
seed: 'node prisma/seed.js'
```

## 种子脚本示例

```typescript
// prisma/seed.ts
import { PrismaClient } from '../generated/client'

const prisma = new PrismaClient()

async function main() {
  // 创建用户
  const alice = await prisma.user.upsert({
    where: { email: 'alice@prisma.io' },
    update: {},
    create: {
      email: 'alice@prisma.io',
      name: 'Alice',
      posts: {
        create: {
          title: 'Hello World',
          published: true,
        },
      },
    },
  })

  const bob = await prisma.user.upsert({
    where: { email: 'bob@prisma.io' },
    update: {},
    create: {
      email: 'bob@prisma.io',
      name: 'Bob',
    },
  })

  console.log({ alice, bob })
}

main()
  .then(async () => {
    await prisma.$disconnect()
  })
  .catch(async (e) => {
    console.error(e)
    await prisma.$disconnect()
    process.exit(1)
  })
```

## 示例

### 运行种子

```bash
prisma db seed
```

### 使用自定义参数

```bash
prisma db seed -- --environment development
```

`--` 之后的参数会传递给你的种子脚本。

## 当前工作流

在需要种子数据时，在迁移之后显式运行种子：

```bash
prisma migrate dev --name init
prisma generate
prisma db seed  # 必须显式运行
```

## 幂等种子

使用 `upsert` 使种子脚本可重复运行：

```typescript
// 好：可以多次运行
await prisma.user.upsert({
  where: { email: 'alice@prisma.io' },
  update: {},  // 不改变已有数据
  create: { email: 'alice@prisma.io', name: 'Alice' },
})

// 坏：第二次运行会失败
await prisma.user.create({
  data: { email: 'alice@prisma.io', name: 'Alice' },
})
```

## 常见模式

### 开发环境重置

```bash
prisma migrate reset --force
prisma db seed
```

### 条件种子

```typescript
// prisma/seed.ts
const count = await prisma.user.count()
if (count === 0) {
  // 仅在数据库为空时填充
  await seedUsers()
}
```

### 环境特定种子

```typescript
// prisma/seed.ts
const env = process.env.NODE_ENV || 'development'

if (env === 'development') {
  await seedDevData()
} else if (env === 'test') {
  await seedTestData()
}
```

## 最佳实践

1. 使用 `upsert` 实现幂等种子
2. 保持种子脚本聚焦且精简
3. 使用逼真但虚假的数据
4. 记录所需的种子数据
5. 将种子脚本纳入版本控制
