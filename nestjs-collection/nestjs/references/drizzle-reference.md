### 安装 Drizzle 和 Gel 包

来源：https://orm.drizzle.team/docs/get-started/gel-new

安装必要的 Drizzle ORM 和 Gel 包，以及 Drizzle Kit 和 tsx 等开发依赖。

```bash
npm i drizzle-orm gel
npm i -D drizzle-kit tsx
```

```bash
yarn add drizzle-orm gel
yarn add -D drizzle-kit tsx
```

```bash
pnpm add drizzle-orm gel
pnpm add -D drizzle-kit tsx
```

```bash
bun add drizzle-orm gel
bun add -D drizzle-kit tsx
```

--------------------------------

### 使用 bun 安装 Drizzle ORM 和 Drizzle Kit

来源：https://orm.drizzle.team/docs/get-started/bun-sql-new

使用 Bun 运行时的包管理器安装 Drizzle ORM 和 Drizzle Kit，包括 Bun 的类型定义。

```bash
bun add drizzle-orm
bun add -D drizzle-kit @types/bun
```

--------------------------------

### 使用 npm 安装 Drizzle ORM 和 Drizzle Kit

来源：https://orm.drizzle.team/docs/get-started/bun-sql-new

使用 npm 安装数据库操作所需的 Drizzle ORM 包，以及用于 schema 管理和迁移的 Drizzle Kit。

```bash
npm i drizzle-orm
npm i -D drizzle-kit @types/bun
```

--------------------------------

### 使用 yarn 安装 Drizzle ORM 和 Drizzle Kit

来源：https://orm.drizzle.team/docs/get-started/bun-sql-new

使用 yarn 安装 Drizzle ORM 和 Drizzle Kit 包，包括 Bun 的类型定义。

```bash
yarn add drizzle-orm
yarn add -D drizzle-kit @types/bun
```

--------------------------------

### 使用 bun 安装 Drizzle 包

来源：https://orm.drizzle.team/docs/get-started/planetscale-new

安装必要的 Drizzle ORM 包、PlanetScale 数据库驱动、dotenv 用于环境变量管理，以及 Drizzle Kit 和 tsx 用于开发。

```bash
bun add drizzle-orm @planetscale/database dotenv
bun add -D drizzle-kit tsx
```

--------------------------------

### 使用 pnpm 安装 Drizzle ORM 和 Drizzle Kit

来源：https://orm.drizzle.team/docs/get-started/bun-sql-new

使用 pnpm 包管理器安装 Drizzle ORM、Drizzle Kit 以及 Bun 类型定义。

```bash
pnpm add drizzle-orm
pnpm add -D drizzle-kit @types/bun
```

--------------------------------

### 使用 pnpm 安装 Drizzle 包

来源：https://orm.drizzle.team/docs/get-started/planetscale-new

安装必要的 Drizzle ORM 包、PlanetScale 数据库驱动、dotenv 用于环境变量管理，以及 Drizzle Kit 和 tsx 用于开发。

```bash
pnpm add drizzle-orm @planetscale/database dotenv
pnpm add -D drizzle-kit tsx
```

--------------------------------

### 使用 npm 安装 Drizzle 包

来源：https://orm.drizzle.team/docs/get-started/planetscale-new

安装必要的 Drizzle ORM 包、PlanetScale 数据库驱动、dotenv 用于环境变量管理，以及 Drizzle Kit 和 tsx 用于开发。

```bash
npm i drizzle-orm @planetscale/database dotenv
npm i -D drizzle-kit tsx
```

--------------------------------

### 安装 Drizzle ORM 和 SQLite Cloud 驱动（bun）

来源：https://orm.drizzle.team/docs/get-started/sqlite-cloud-new

使用 bun 安装必要的 Drizzle ORM beta 包、SQLite Cloud 驱动、dotenv 用于环境变量管理，以及 Drizzle Kit 和 tsx 用于开发。

```bash
bun add drizzle-orm@beta @sqlitecloud/drivers dotenv
bun add -D drizzle-kit@beta tsx
```

--------------------------------

### 安装 Drizzle ORM 和 Supabase 依赖（bun）

来源：https://orm.drizzle.team/docs/get-started/supabase-new

使用 bun 安装必要的 Drizzle ORM、postgres 驱动、dotenv 用于环境变量管理，以及 drizzle-kit 和 tsx 等开发工具。

```bash
bun add drizzle-orm postgres dotenv
bun add -D drizzle-kit tsx
```

--------------------------------

### 使用 yarn 安装 Drizzle 包

来源：https://orm.drizzle.team/docs/get-started/planetscale-new

安装必要的 Drizzle ORM 包、PlanetScale 数据库驱动、dotenv 用于环境变量管理，以及 Drizzle Kit 和 tsx 用于开发。

```bash
yarn add drizzle-orm @planetscale/database dotenv
yarn add -D drizzle-kit tsx
```

--------------------------------

### 安装 Drizzle ORM 和 SQLite Cloud 驱动（npm）

来源：https://orm.drizzle.team/docs/get-started/sqlite-cloud-new

安装必要的 Drizzle ORM beta 包、SQLite Cloud 驱动、dotenv 用于环境变量管理，以及 Drizzle Kit 和 tsx 用于开发。

```bash
npm i drizzle-orm@beta @sqlitecloud/drivers dotenv
npm i -D drizzle-kit@beta tsx
```

--------------------------------

### 数据库连接设置（基本版）

来源：https://orm.drizzle.team/docs/get-started/postgresql-new

使用环境变量中的 DATABASE_URL 和 node-postgres 驱动初始化 Drizzle ORM 的 PostgreSQL 连接。

```typescript
import 'dotenv/config';
import { drizzle } from 'drizzle-orm/node-postgres';

const db = drizzle(process.env.DATABASE_URL!);
```

--------------------------------

### 安装 Drizzle ORM 和 Supabase 依赖（pnpm）

来源：https://orm.drizzle.team/docs/get-started/supabase-new

使用 pnpm 安装必要的 Drizzle ORM、postgres 驱动、dotenv 用于环境变量管理，以及 drizzle-kit 和 tsx 等开发工具。

```bash
pnpm add drizzle-orm postgres dotenv
pnpm add -D drizzle-kit tsx
```

--------------------------------

### 安装 Drizzle ORM 和 Supabase 依赖（npm）

来源：https://orm.drizzle.team/docs/get-started/supabase-new

使用 npm 安装必要的 Drizzle ORM、postgres 驱动、dotenv 用于环境变量管理，以及 drizzle-kit 和 tsx 等开发工具。

```bash
npm i drizzle-orm postgres dotenv
npm i -D drizzle-kit tsx
```

--------------------------------

### 安装 Drizzle ORM 和 SQLite Cloud 驱动（pnpm）

来源：https://orm.drizzle.team/docs/get-started/sqlite-cloud-new

使用 pnpm 安装必要的 Drizzle ORM beta 包、SQLite Cloud 驱动、dotenv 用于环境变量管理，以及 Drizzle Kit 和 tsx 用于开发。

```bash
pnpm add drizzle-orm@beta @sqlitecloud/drivers dotenv
pnpm add -D drizzle-kit@beta tsx
```

--------------------------------

### 安装 Drizzle ORM 和 SQLite Cloud 驱动（yarn）

来源：https://orm.drizzle.team/docs/get-started/sqlite-cloud-new

使用 yarn 安装必要的 Drizzle ORM beta 包、SQLite Cloud 驱动、dotenv 用于环境变量管理，以及 Drizzle Kit 和 tsx 用于开发。

```bash
yarn add drizzle-orm@beta @sqlitecloud/drivers dotenv
yarn add -D drizzle-kit@beta tsx
```

--------------------------------

### 安装 Drizzle 包（bun）

来源：https://orm.drizzle.team/docs/get-started/vercel-new

使用 bun 安装必要的 Drizzle ORM 包和开发工具。包括核心 Drizzle ORM 库、Vercel Postgres 驱动、dotenv 用于环境变量管理，以及 Drizzle Kit 和 tsx 用于开发。

```bash
bun add drizzle-orm @vercel/postgres dotenv
bun add -D drizzle-kit tsx
```

--------------------------------

### 安装 Drizzle ORM 和 Supabase 依赖（yarn）

来源：https://orm.drizzle.team/docs/get-started/supabase-new

使用 yarn 安装必要的 Drizzle ORM、postgres 驱动、dotenv 用于环境变量管理，以及 drizzle-kit 和 tsx 等开发工具。

```bash
yarn add drizzle-orm postgres dotenv
yarn add -D drizzle-kit tsx
```

--------------------------------

### 初始化 Gel 项目

来源：https://orm.drizzle.team/docs/get-started/gel-new

初始化一个新的 Gel 项目。此命令用于设置 Gel 数据库项目的基本结构。

```bash
npx gel project init
```

```bash
yarn gel project init
```

```bash
pnpm gel project init
```

```bash
bunx gel project init
```

--------------------------------

### 安装 Drizzle ORM 和 TiDB Serverless 包（bun）

来源：https://orm.drizzle.team/docs/connect-tidb

使用 bun 安装必要的 Drizzle ORM 和 TiDB Serverless 包。同时安装 drizzle-kit 作为 schema 管理和迁移的开发依赖。

```bash
bun add drizzle-orm @tidbcloud/serverless
bun add -D drizzle-kit
```

--------------------------------

### PostgreSQL 连接 URL 示例

来源：https://orm.drizzle.team/docs/guides/postgresql-local-setup

这是 PostgreSQL 数据库连接 URL 的标准格式。将占位符替换为您的具体凭据和主机信息。

```sql
postgres://<用户>:<密码>@<主机>:<端口>/<数据库>
```

```sql
postgres://postgres:mypassword@localhost:5432/postgres
```

--------------------------------

### Drizzle Kit PostgreSQL 配置

来源：https://orm.drizzle.team/docs/get-started/bun-sql-new

Drizzle Kit 的配置文件，指定迁移输出目录、schema 文件位置、数据库方言（PostgreSQL）和数据库凭据。

```typescript
import 'dotenv/config';
import { defineConfig } from 'drizzle-kit';

export default defineConfig({
 out: './drizzle',
 schema: './src/db/schema.ts',
 dialect: 'postgresql',
 dbCredentials: {
 url: process.env.DATABASE_URL!,
 },
});
```

--------------------------------

### 安装 Drizzle ORM 和 Drizzle Kit 包

来源：https://orm.drizzle.team/docs/connect-cloudflare-d1

安装项目设置所需的 Drizzle ORM 和 Drizzle Kit 包。Drizzle ORM 用于数据库交互，而 Drizzle Kit 提供 schema 管理和迁移工具。

```npm
npm i drizzle-orm
npm i -D drizzle-kit
```

```yarn
yarn add drizzle-orm
yarn add -D drizzle-kit
```

```pnpm
pnpm add drizzle-orm
pnpm add -D drizzle-kit
```

```bun
bun add drizzle-orm
bun add -D drizzle-kit
```

--------------------------------

### 配置 MySQL 数据库 URL

来源：https://orm.drizzle.team/docs/guides/mysql-local-setup

这是 MySQL 连接 URL 的标准格式。将占位符替换为您的具体凭据和主机信息。提供的示例展示了如何为之前启动的 Docker 容器构建 URL。

```plaintext
mysql://<用户>:<密码>@<主机>:<端口>/<数据库>
```

```plaintext
mysql://root:mypassword@localhost:3306/mysql
```

--------------------------------

### 数据库连接设置（带配置）

来源：https://orm.drizzle.team/docs/get-started/postgresql-new

使用 PostgreSQL 连接初始化 Drizzle ORM，传递特定的 node-postgres 连接选项，如 SSL 配置。

```typescript
import 'dotenv/config';
import { drizzle } from 'drizzle-orm/node-postgres';

// 您可以指定 node-postgres 连接选项中的任何属性
const db = drizzle({
 connection: {
 connectionString: process.env.DATABASE_URL!,
 ssl: true
 }
});
```

--------------------------------

### 使用 npm/yarn/pnpm/bun 安装 Drizzle ORM 和 Drizzle Kit

来源：https://orm.drizzle.team/docs/get-started/bun-sqlite-new

安装 Drizzle ORM 和 Drizzle Kit 的命令，它们对 ORM 功能和 schema 管理至关重要。Drizzle Kit 在 TypeScript 项目中需要 `@types/bun`。

```npm
npm i drizzle-orm
npm i -D drizzle-kit @types/bun
```

```yarn
yarn add drizzle-orm
yarn add -D drizzle-kit @types/bun
```

```pnpm
pnpm add drizzle-orm
pnpm add -D drizzle-kit @types/bun
```

```bun
bun add drizzle-orm
bun add -D drizzle-kit @types/bun
```

--------------------------------

### 运行指定用户和数据库的 Docker 容器

来源：https://orm.drizzle.team/docs/guides/postgresql-local-setup

展示如何启动一个带有特定用户和数据库名称的 PostgreSQL 容器。如果未提供，则使用默认值。

```bash
docker run --name drizzle-postgres -e POSTGRES_USER=myuser -e POSTGRES_PASSWORD=mypassword -e POSTGRES_DB=mydatabase -d -p 5432:5432 postgres
```

--------------------------------

### 安装 Drizzle 包（npm）

来源：https://orm.drizzle.team/docs/get-started/vercel-new

使用 npm 安装必要的 Drizzle ORM 包和开发工具。包括核心 Drizzle ORM 库、Vercel Postgres 驱动、dotenv 用于环境变量管理，以及 Drizzle Kit 和 tsx 用于开发。

```bash
npm i drizzle-orm @vercel/postgres dotenv
npm i -D drizzle-kit tsx
```

--------------------------------

### Drizzle ORM 项目文件结构

来源：https://orm.drizzle.team/docs/get-started/bun-sql-new

使用 Bun SQL 的 Drizzle ORM 项目基本文件结构。展示了 schema 定义、迁移文件、配置文件和环境变量的位置。

```tree
📦
 ├ 📂 drizzle
 ├ 📂 src
 │ ├ 📂 db
 │ │ └ 📜 schema.ts
 │ └ 📜 index.ts
 ├ 📜 .env
 ├ 📜 drizzle.config.ts
 ├ 📜 package.json
 └ 📜 tsconfig.json
```

--------------------------------

### 安装 Drizzle ORM 和 MySQL2 依赖（npm）

来源：https://orm.drizzle.team/docs/get-started/mysql-new

安装必要的 Drizzle ORM 包、mysql2 驱动、dotenv 用于环境变量管理，以及 drizzle-kit 和 tsx 用于开发。

```bash
npm i drizzle-orm mysql2 dotenv
npm i -D drizzle-kit tsx
```

--------------------------------

### 配置 Drizzle Kit

来源：https://orm.drizzle.team/docs/get-started/gel-new

设置 Drizzle Kit 配置文件。此 TypeScript 文件指定了 Drizzle Kit 的数据库方言和其他项目特定设置。

```typescript
import { defineConfig } from 'drizzle-kit';

export default defineConfig({
 dialect: 'gel',
});
```

--------------------------------

### 安装 Drizzle ORM 和 MySQL2 依赖（bun）

来源：https://orm.drizzle.team/docs/get-started/mysql-new

使用 Bun 安装必要的 Drizzle ORM 包、mysql2 驱动、dotenv 用于环境变量管理，以及 drizzle-kit 和 tsx 用于开发。

```bash
bun add drizzle-orm mysql2 dotenv
bun add -D drizzle-kit tsx
```

--------------------------------

### 安装 Drizzle 包（pnpm）

来源：https://orm.drizzle.team/docs/get-started/vercel-new

使用 pnpm 安装必要的 Drizzle ORM 包和开发工具。包括核心 Drizzle ORM 库、Vercel Postgres 驱动、dotenv 用于环境变量管理，以及 Drizzle Kit 和 tsx 用于开发。

```bash
pnpm add drizzle-orm @vercel/postgres dotenv
pnpm add -D drizzle-kit tsx
```

--------------------------------

### 设置 SQLite Cloud 连接字符串

来源：https://orm.drizzle.team/docs/get-started/sqlite-cloud-new

在 .env 文件中定义 SQLite Cloud 数据库连接字符串的环境变量。

```dotenv
SQLITE_CLOUD_CONNECTION_STRING=
```

--------------------------------

### 安装 Drizzle ORM 和依赖（bun）

来源：https://orm.drizzle.team/docs/get-started/turso-database-new

使用 bun 安装必要的 Drizzle ORM 包和开发工具。此命令包括 `drizzle-orm` 和 `drizzle-kit` 的 beta 版本，以及 `@tursodatabase/database`、`dotenv` 和 `tsx`。

```bash
bun add drizzle-orm@beta @tursodatabase/database dotenv
bun add -D drizzle-kit@beta tsx
```

--------------------------------

### 安装 Drizzle ORM 和依赖（bun）

来源：https://orm.drizzle.team/docs/get-started/d1-new

使用 bun 安装必要的 Drizzle ORM 包和开发工具。`drizzle-orm` 和 `dotenv` 用于运行时，而 `drizzle-kit` 和 `tsx` 用于开发。

```bash
bun add drizzle-orm dotenv
bun add -D drizzle-kit tsx
```

--------------------------------

### 安装 Drizzle ORM 和 Neon 包（bun）

来源：https://orm.drizzle.team/docs/get-started/neon-new

使用 bun 安装核心 Drizzle ORM 包、Neon serverless 驱动、dotenv 用于环境变量管理，以及 Drizzle Kit 和 tsx 等开发工具。

```bash
bun add drizzle-orm @neondatabase/serverless dotenv
bun add -D drizzle-kit tsx
```

--------------------------------

### 配置 Drizzle Kit

来源：https://orm.drizzle.team/docs/get-started/sqlite-cloud-new

设置 Drizzle Kit 配置文件，指定迁移输出目录、schema 文件位置、方言和数据库凭据。

```typescript
import 'dotenv/config';
import { defineConfig } from 'drizzle-kit';

export default defineConfig({
 out: './drizzle',
 schema: './src/db/schema.ts',
 dialect: 'sqlite',
 dbCredentials: {
 url: process.env.SQLITE_CLOUD_CONNECTION_STRING!,
 },
});
```

--------------------------------

### 数据库连接设置（使用连接池）

来源：https://orm.drizzle.team/docs/get-started/postgresql-new

使用 node-postgres Pool 管理 PostgreSQL 连接来初始化 Drizzle ORM，实现连接池功能。

```typescript
import 'dotenv/config';
import { drizzle } from "drizzle-orm/node-postgres";
import { Pool } from "pg";

const pool = new Pool({
 connectionString: process.env.DATABASE_URL!,
});
const db = drizzle({ client: pool });
```

--------------------------------

### 安装 Drizzle ORM 和 Neon Serverless 驱动（bun）

来源：https://orm.drizzle.team/docs/connect-neon

使用 bun 安装 Drizzle ORM 和 Neon serverless 驱动。同时安装 drizzle-kit 作为开发依赖。

```bash
bun add drizzle-orm @neondatabase/serverless
bun add -D drizzle-kit
```

--------------------------------

### 安装 Drizzle 包（yarn）

来源：https://orm.drizzle.team/docs/get-started/vercel-new

使用 yarn 安装必要的 Drizzle ORM 包和开发工具。包括核心 Drizzle ORM 库、Vercel Postgres 驱动、dotenv 用于环境变量管理，以及 Drizzle Kit 和 tsx 用于开发。

```bash
yarn add drizzle-orm @vercel/postgres dotenv
yarn add -D drizzle-kit tsx
```

--------------------------------

### 安装 Drizzle ORM 和 Neon Serverless 驱动（npm）

来源：https://orm.drizzle.team/docs/connect-neon

使用 npm 安装 Drizzle ORM 和 Neon serverless 驱动。同时安装 drizzle-kit 作为开发依赖。

```bash
npm i drizzle-orm @neondatabase/serverless
npm i -D drizzle-kit
```

--------------------------------

### 安装 Drizzle ORM 和 MySQL2 依赖（pnpm）

来源：https://orm.drizzle.team/docs/get-started/mysql-new

使用 pnpm 安装必要的 Drizzle ORM 包、mysql2 驱动、dotenv 用于环境变量管理，以及 drizzle-kit 和 tsx 用于开发。

```bash
pnpm add drizzle-orm mysql2 dotenv
pnpm add -D drizzle-kit tsx
```

--------------------------------

### 安装 Drizzle ORM 和依赖（npm）

来源：https://orm.drizzle.team/docs/get-started/turso-database-new

使用 npm 安装必要的 Drizzle ORM 包和开发工具。它包括 `drizzle-orm` 和 `drizzle-kit` 的 beta 版本，以及 `@tursodatabase/database`、`dotenv` 和 `tsx` 用于开发。

```bash
npm i drizzle-orm@beta @tursodatabase/database dotenv
npm i -D drizzle-kit@beta tsx
```

--------------------------------

### 安装 Drizzle ORM 和 TiDB Serverless 包（npm）

来源：https://orm.drizzle.team/docs/connect-tidb

使用 npm 安装必要的 Drizzle ORM 和 TiDB Serverless 包。同时安装 drizzle-kit 作为 schema 管理和迁移的开发依赖。

```bash
npm i drizzle-orm @tidbcloud/serverless
npm i -D drizzle-kit
```

--------------------------------

### 使用 Drizzle ORM 进行数据库播种和查询（TypeScript）

来源：https://orm.drizzle.team/docs/get-started/supabase-new

演示如何使用 Drizzle ORM 在 TypeScript 中与 PostgreSQL 数据库交互。包括插入新用户、查询所有用户、更新用户年龄和删除用户的操作。此示例假设存在 `usersTable` schema，并使用环境变量进行数据库连接。

```typescript
import 'dotenv/config';
import { drizzle } from 'drizzle-orm/postgres-js';
import { eq } from 'drizzle-orm';
import { usersTable } from './db/schema';

const db = drizzle(process.env.DATABASE_URL!);

async function main() {
 const user: typeof usersTable.$inferInsert = {
 name: 'John',
 age: 30,
 email: 'john@example.com',
 };

 await db.insert(usersTable).values(user);
 console.log('已创建新用户！')

 const users = await db.select().from(usersTable);
 console.log('从数据库中获取所有用户：', users)
 /*
 const users: {
 id: number;
 name: string;
 age: number;
 email: string;
 }[]
 */

 await db
 .update(usersTable)
 .set({
 age: 31,
 })
 .where(eq(usersTable.email, user.email));
 console.log('用户信息已更新！')

 await db.delete(usersTable).where(eq(usersTable.email, user.email));
 console.log('用户已删除！')
}

main();
```

--------------------------------

### 安装 Drizzle ORM 和 SQLite 包（bun）

来源：https://orm.drizzle.team/docs/get-started/sqlite-new

使用 bun 安装必要的 Drizzle ORM、libsql 客户端、dotenv 和开发包。此命令用于设置新项目或向现有项目添加依赖。

```bash
bun add drizzle-orm @libsql/client dotenv
bun add -D drizzle-kit tsx
```

--------------------------------

### 管理 Gel 迁移

来源：https://orm.drizzle.team/docs/get-started/gel-new

管理 Gel 数据库迁移的命令。'migration create' 生成迁移文件，'migration apply' 将待处理的迁移应用到数据库。

```bash
gel migration create
```

```bash
gel migration apply
```

--------------------------------

### 使用 Bun SQL 初始化 Drizzle ORM

来源：https://orm.drizzle.team/docs/get-started/bun-sql-new

使用环境变量中的连接 URL 初始化 Bun SQL 的 Drizzle ORM 实例。

```typescript
import 'dotenv/config';
import { drizzle } from 'drizzle-orm/bun-sql';

const db = drizzle(process.env.DATABASE_URL!);
```

--------------------------------

### 安装 Drizzle ORM 和 TiDB Serverless 包（pnpm）

来源：https://orm.drizzle.team/docs/connect-tidb

使用 pnpm 安装必要的 Drizzle ORM 和 TiDB Serverless 包。同时安装 drizzle-kit 作为 schema 管理和迁移的开发依赖。

```bash
pnpm add drizzle-orm @tidbcloud/serverless
pnpm add -D drizzle-kit
```

--------------------------------

### 安装 Drizzle 和 PGlite 包（npm, yarn, pnpm, bun）

来源：https://orm.drizzle.team/docs/get-started/pglite-new

提供使用不同包管理器安装必要的 Drizzle ORM 包、PGlite 驱动、dotenv 用于环境变量管理，以及 Drizzle Kit 和 tsx 用于开发的命令。

```bash
npm i drizzle-orm @electric-sql/pglite dotenv
npm i -D drizzle-kit tsx
```

```bash
yarn add drizzle-orm @electric-sql/pglite dotenv
yarn add -D drizzle-kit tsx
```

```bash
pnpm add drizzle-orm @electric-sql/pglite dotenv
pnpm add -D drizzle-kit tsx
```

```bash
bun add drizzle-orm @electric-sql/pglite dotenv
bun add -D drizzle-kit tsx
```

--------------------------------

### 初始化 Drizzle ORM 连接（异步）

来源：https://orm.drizzle.team/docs/get-started/supabase-new

使用 'postgres-js' 驱动和环境变量中的 DATABASE_URL 初始化异步 Drizzle ORM 连接。

```typescript
import { drizzle } from 'drizzle-orm'

async function main() {
 const db = drizzle('postgres-js', process.env.DATABASE_URL);
}

main();
```

--------------------------------

### 使用 drizzle-kit 生成和应用数据库迁移

来源：https://orm.drizzle.team/docs/get-started/bun-sql-new

根据 schema 更改生成 SQL 迁移文件，然后将这些迁移应用到数据库。此过程通过单独的命令管理。

```bash
npx drizzle-kit generate
```

```bash
npx drizzle-kit migrate
```

--------------------------------

### 安装 Drizzle ORM 和 MySQL2 依赖（yarn）

来源：https://orm.drizzle.team/docs/get-started/mysql-new

使用 Yarn 安装必要的 Drizzle ORM 包、mysql2 驱动、dotenv 用于环境变量管理，以及 drizzle-kit 和 tsx 用于开发。

```bash
yarn add drizzle-orm mysql2 dotenv
yarn add -D drizzle-kit tsx
```

--------------------------------

### 列出 Docker 镜像

来源：https://orm.drizzle.team/docs/guides/postgresql-local-setup

拉取镜像后，此命令列出系统上所有已下载的 Docker 镜像，以便您验证 PostgreSQL 镜像及其详细信息。

```bash
docker images
```

--------------------------------

### Turso CLI：认证和创建数据库

来源：https://orm.drizzle.team/docs/tutorials/drizzle-with-turso

与 Turso 服务进行认证并创建新数据库的命令。需要安装 Turso CLI。数据库名称 'drizzle-turso-db' 仅作示例使用。

```bash
turso auth signup
turso auth login
turso db create drizzle-turso-db
turso db show drizzle-turso-db
turso db tokens create drizzle-turso-db
```

--------------------------------

### 安装 Drizzle ORM 和 Neon 包（npm）

来源：https://orm.drizzle.team/docs/get-started/neon-new

使用 npm 安装核心 Drizzle ORM 包、Neon serverless 驱动、dotenv 用于环境变量管理，以及 Drizzle Kit 和 tsx 等开发工具。

```bash
npm i drizzle-orm @neondatabase/serverless dotenv
npm i -D drizzle-kit tsx
```

--------------------------------

### 启动 Netlify 开发服务器

来源：https://orm.drizzle.team/docs/tutorials/drizzle-with-netlify-edge-functions-neon

启动 Netlify dev 服务器，用于本地测试边缘函数和站点部署。此命令允许在本地模拟 Netlify 环境。

```bash
netlify dev
```

--------------------------------

### 安装 Drizzle ORM 和 Neon Serverless 驱动（pnpm）

来源：https://orm.drizzle.team/docs/connect-neon

使用 pnpm 安装 Drizzle ORM 和 Neon serverless 驱动。同时安装 drizzle-kit 作为开发依赖。

```bash
pnpm add drizzle-orm @neondatabase/serverless
pnpm add -D drizzle-kit
```

--------------------------------

### SQL 生成的迁移文件示例

来源：https://orm.drizzle.team/docs/tutorials/drizzle-with-turso

Drizzle Kit 为数据库迁移生成的 SQL 文件示例。包括 'posts' 和 'users' 的 CREATE TABLE 语句，定义了它们的列、约束、外键和唯一索引。

```sql
CREATE TABLE `posts` (
 `id` integer PRIMARY KEY NOT NULL,
 `title` text NOT NULL,
 `content` text NOT NULL,
 `user_id` integer NOT NULL,
 `created_at` text DEFAULT (CURRENT_TIMESTAMP) NOT NULL,
 `updated_at` integer,
 FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON UPDATE no action ON DELETE cascade
);
--> statement-breakpoint
CREATE TABLE `users` (
 `id` integer PRIMARY KEY NOT NULL,
 `name` text NOT NULL,
 `age` integer NOT NULL,
 `email` text NOT NULL
);
--> statement-breakpoint
CREATE UNIQUE INDEX `users_email_unique` ON `users` (`email`);
```

--------------------------------

### 使用 Bun 运行 TypeScript 脚本

来源：https://orm.drizzle.team/docs/get-started/bun-sql-new

使用 Bun 运行时环境执行 TypeScript 文件。此命令用于在设置数据库操作后运行主应用程序脚本。

```bash
bun src/index.ts
```

--------------------------------

### 初始化新的 Netlify 项目

来源：https://orm.drizzle.team/docs/tutorials/drizzle-with-netlify-edge-functions-neon

使用 Netlify CLI 初始化一个新的 Netlify 项目。此命令引导用户完成新站点的设置和部署选项的选择。

```bash
netlify init
```

--------------------------------

### 安装 Drizzle ORM 和 Neon 包（pnpm）

来源：https://orm.drizzle.team/docs/get-started/neon-new

使用 pnpm 安装核心 Drizzle ORM 包、Neon serverless 驱动、dotenv 用于环境变量管理，以及 Drizzle Kit 和 tsx 等开发工具。

```bash
pnpm add drizzle-orm @neondatabase/serverless dotenv
pnpm add -D drizzle-kit tsx
```

--------------------------------

### Drizzle Kit 生成的 Gel Schema

来源：https://orm.drizzle.team/docs/get-started/gel-new

从 Gel 数据库拉取后由 Drizzle Kit 生成的 schema 文件示例。它定义了一个包含 UUID、smallint 和 text 字段的 'users' 表。

```typescript
import { gelTable, uniqueIndex, uuid, smallint, text } from "drizzle-orm/gel-core"
import { sql } from "drizzle-orm"

export const users = gelTable("users", {
 id: uuid().default(sql`uuid_generate_v4()`).primaryKey().notNull(),
 age: smallint(),
 email: text().notNull(),
 name: text(),
}, (table) => [
 uniqueIndex("a8c6061c-f37f-11ef-9249-0d78f6c1807b;schemaconstr").using("btree", table.id.asc().nullsLast().op("uuid_ops")),
]);
```

--------------------------------

### 安装 Drizzle ORM 和 SQLite 包（pnpm）

来源：https://orm.drizzle.team/docs/get-started/sqlite-new

使用 pnpm 安装必要的 Drizzle ORM、libsql 客户端、dotenv 和开发包。此命令用于设置新项目或向现有项目添加依赖。

```bash
pnpm add drizzle-orm @libsql/client dotenv
pnpm add -D drizzle-kit tsx
```

--------------------------------

### 安装 Drizzle ORM 和 TiDB Serverless 包（yarn）

来源：https://orm.drizzle.team/docs/connect-tidb

使用 yarn 安装必要的 Drizzle ORM 和 TiDB Serverless 包。同时安装 drizzle-kit 作为 schema 管理和迁移的开发依赖。

```bash
yarn add drizzle-orm @tidbcloud/serverless
yarn add -D drizzle-kit
```

--------------------------------

### 安装 Drizzle ORM 和 Vercel Postgres 包

来源：https://orm.drizzle.team/docs/connect-vercel-postgres

使用 npm、yarn、pnpm 或 bun 安装 Drizzle ORM 和 Vercel Postgres 驱动。同时安装 drizzle-kit 作为开发依赖。

```npm
npm i drizzle-orm @vercel/postgres
npm i -D drizzle-kit
```

```yarn
yarn add drizzle-orm @vercel/postgres
yarn add -D drizzle-kit
```

```pnpm
pnpm add drizzle-orm @vercel/postgres
pnpm add -D drizzle-kit
```

```bun
bun add drizzle-orm @vercel/postgres
bun add -D drizzle-kit
```

--------------------------------

### 使用 Bun SQL 连接选项初始化 Drizzle ORM

来源：https://orm.drizzle.team/docs/get-started/bun-sql-new

使用 Bun SQL 的特定连接选项初始化 Drizzle ORM，允许配置连接对象。

```typescript
import 'dotenv/config';
import { drizzle } from 'drizzle-orm/bun-sql';

// 您可以指定 bun sql 连接选项中的任何属性
const db = drizzle({ connection: { url: process.env.DATABASE_URL! }});
```

--------------------------------

### 安装 Drizzle ORM 和依赖（pnpm）

来源：https://orm.drizzle.team/docs/get-started/d1-new

使用 pnpm 安装必要的 Drizzle ORM 包和开发工具。`drizzle-orm` 和 `dotenv` 用于运行时，而 `drizzle-kit` 和 `tsx` 用于开发。

```bash
pnpm add drizzle-orm dotenv
pnpm add -D drizzle-kit tsx
```

--------------------------------

### 安装 Drizzle ORM 和 Neon Serverless 驱动（yarn）

来源：https://orm.drizzle.team/docs/connect-neon

使用 yarn 安装 Drizzle ORM 和 Neon serverless 驱动。同时安装 drizzle-kit 作为开发依赖。

```bash
yarn add drizzle-orm @neondatabase/serverless
yarn add -D drizzle-kit
```

--------------------------------

### 安装 Drizzle ORM 和 SQLite 包（npm）

来源：https://orm.drizzle.team/docs/get-started/sqlite-new

使用 npm 安装必要的 Drizzle ORM、libsql 客户端、dotenv 和开发包。此命令用于设置新项目或向现有项目添加依赖。

```bash
npm i drizzle-orm @libsql/client dotenv
npm i -D drizzle-kit tsx
```

--------------------------------

### 安装 Drizzle ORM 和 libSQL 客户端包

来源：https://orm.drizzle.team/docs/connect-turso

为不同的包管理器安装必要的 Drizzle ORM 和 libSQL 客户端包。这是将 Drizzle 连接到 Turso Cloud 的第一步。

```npm
npm i drizzle-orm @libsql/client
npm i -D drizzle-kit
```

```yarn
yarn add drizzle-orm @libsql/client
yarn add -D drizzle-kit
```

```pnpm
pnpm add drizzle-orm @libsql/client
pnpm add -D drizzle-kit
```

```bun
bun add drizzle-orm @libsql/client
bun add -D drizzle-kit
```

--------------------------------

### 初始化 Drizzle ORM 连接（同步）

来源：https://orm.drizzle.team/docs/get-started/supabase-new

通过显式创建 postgres 客户端并将其传递给 Drizzle 实例，初始化同步 Drizzle ORM 连接。

```typescript
import { drizzle } from 'drizzle-orm/postgres-js'
import postgres from 'postgres'

async function main() {
 const client = postgres(process.env.DATABASE_URL)
 const db = drizzle({ client });
}

main();
```

--------------------------------

### 安装 Drizzle ORM 和依赖（npm）

来源：https://orm.drizzle.team/docs/get-started/d1-new

使用 npm 安装必要的 Drizzle ORM 包和开发工具。`drizzle-orm` 和 `dotenv` 用于运行时，而 `drizzle-kit` 和 `tsx` 用于开发。

```bash
npm i drizzle-orm dotenv
npm i -D drizzle-kit tsx
```

--------------------------------

### 使用 SingleStore 初始化 Drizzle（基本版）

来源：https://orm.drizzle.team/docs/get-started/singlestore-new

使用环境变量中的 DATABASE_URL 初始化 Drizzle ORM 与 SingleStore 数据库的连接。

```typescript
import 'dotenv/config';
import { drizzle } from "drizzle-orm/singlestore";

const db = drizzle(process.env.DATABASE_URL);
```

--------------------------------

### 环境变量设置

来源：https://orm.drizzle.team/docs/get-started/vercel-new

在 `.env` 文件中定义数据库连接 URL。对于 Vercel Postgres，将变量命名为 `POSTGRES_URL` 至关重要。该值可从 Vercel Postgres 存储选项卡获取。

```dotenv
POSTGRES_URL=
```

--------------------------------

### .env 中的数据库连接 URL

来源：https://orm.drizzle.team/docs/get-started/bun-sql-new

在 .env 文件中指定数据库连接字符串，Drizzle ORM 将使用它来连接数据库。

```dotenv
DATABASE_URL=
```

--------------------------------

### 安装 Drizzle ORM 和依赖（yarn）

来源：https://orm.drizzle.team/docs/get-started/d1-new

使用 yarn 安装必要的 Drizzle ORM 包和开发工具。`drizzle-orm` 和 `dotenv` 用于运行时，而 `drizzle-kit` 和 `tsx` 用于开发。

```bash
yarn add drizzle-orm dotenv
yarn add -D drizzle-kit tsx
```

--------------------------------

### 安装 Drizzle ORM 和 Neon 包（yarn）

来源：https://orm.drizzle.team/docs/get-started/neon-new

使用 yarn 安装核心 Drizzle ORM 包、Neon serverless 驱动、dotenv 用于环境变量管理，以及 Drizzle Kit 和 tsx 等开发工具。

```bash
yarn add drizzle-orm @neondatabase/serverless dotenv
yarn add -D drizzle-kit tsx
```

--------------------------------

### 启动 PostgreSQL Docker 容器

来源：https://orm.drizzle.team/docs/guides/postgresql-local-setup

此命令启动一个名为 'drizzle-postgres' 的新 PostgreSQL 容器。它设置密码，以分离模式运行，并将容器的 5432 端口映射到主机。

```bash
docker run --name drizzle-postgres -e POSTGRES_PASSWORD=mypassword -d -p 5432:5432 postgres
```

--------------------------------

### 使用 tsx 命令运行 TypeScript 文件

来源：https://orm.drizzle.team/docs/get-started/gel-new

本节提供了在不同包管理器（npm, yarn, pnpm, bun）下使用 'tsx' 工具执行 TypeScript 文件的命令。这是一种无需完整 TypeScript 编译步骤即可运行脚本的便捷方式。确保您的项目中已安装 'tsx'。

```bash
npx tsx src/index.ts
```

```bash
yarn tsx src/index.ts
```

```bash
pnpm tsx src/index.ts
```

```bash
bunx tsx src/index.ts
```

--------------------------------

### 安装 Drizzle ORM 和 AWS SDK for PostgreSQL（bun）

来源：https://orm.drizzle.team/docs/connect-aws-data-api-pg

使用 bun 安装 Drizzle ORM 包和 AWS SDK RDS Data 客户端。同时安装 drizzle-kit 作为 schema 管理的开发依赖。

```bash
bun add drizzle-orm @aws-sdk/client-rds-data
bun add -D drizzle-kit
```

--------------------------------

### 使用现有 PlanetScale 客户端初始化 Drizzle ORM

来源：https://orm.drizzle.team/docs/get-started/planetscale-new

通过提供现有的 PlanetScale 客户端实例来初始化 Drizzle ORM 实例。这允许对客户端配置进行更多控制。

```typescript
import { drizzle } from "drizzle-orm/planetscale-serverless";
import { Client } from "@planetscale/database";

const client = new Client({
 host: process.env.DATABASE_HOST!,
 username: process.env.DATABASE_USERNAME!,
 password: process.env.DATABASE_PASSWORD!,
});

const db = drizzle({ client: client });
```

--------------------------------

### 为 SQLite 配置 Drizzle Kit

来源：https://orm.drizzle.team/docs/get-started/bun-sqlite-new

为 Drizzle Kit 设置 drizzle.config.ts 文件。指定迁移输出目录、schema 文件位置、方言（sqlite）和数据库凭据。

```typescript
import 'dotenv/config';
import { defineConfig } from 'drizzle-kit';

export default defineConfig({
 out: './drizzle',
 schema: './src/db/schema.ts',
 dialect: 'sqlite',
 dbCredentials: {
 url: process.env.DB_FILE_NAME!,
 },
});
```

--------------------------------

### 安装 Drizzle ORM 和 SQLite 包（yarn）

来源：https://orm.drizzle.team/docs/get-started/sqlite-new

使用 yarn 安装必要的 Drizzle ORM、libsql 客户端、dotenv 和开发包。此命令用于设置新项目或向现有项目添加依赖。

```bash
yarn add drizzle-orm @libsql/client dotenv
yarn add -D drizzle-kit tsx
```

--------------------------------

### 安装 Drizzle ORM 和依赖（pnpm）

来源：https://orm.drizzle.team/docs/get-started/turso-database-new

使用 pnpm 安装必要的 Drizzle ORM 包和开发工具。此命令将 `drizzle-orm` 和 `drizzle-kit` 的 beta 版本，以及 `@tursodatabase/database`、`dotenv` 和 `tsx` 添加到项目的依赖中。

```bash
pnpm add drizzle-orm@beta @tursodatabase/database dotenv
pnpm add -D drizzle-kit@beta tsx
```

--------------------------------

### 安装 Drizzle ORM 和 AWS SDK for PostgreSQL（npm）

来源：https://orm.drizzle.team/docs/connect-aws-data-api-pg

使用 npm 安装 Drizzle ORM 包和 AWS SDK RDS Data 客户端。同时安装 drizzle-kit 作为 schema 管理的开发依赖。

```bash
npm i drizzle-orm @aws-sdk/client-rds-data
npm i -D drizzle-kit
```

--------------------------------

### 使用 PlanetScale Serverless 驱动初始化 Drizzle ORM

来源：https://orm.drizzle.team/docs/get-started/planetscale-new

使用 PlanetScale serverless 驱动初始化 Drizzle ORM 实例。它从环境变量中读取连接详情。

```typescript
import { drizzle } from "drizzle-orm/planetscale-serverless";

const db = drizzle({ connection: {
 host: process.env.DATABASE_HOST!,
 username: process.env.DATABASE_USERNAME!,
 password: process.env.DATABASE_PASSWORD!,
}});
```

--------------------------------

### 运行应用程序

来源：https://orm.drizzle.team/docs/tutorials/drizzle-with-nile

此命令使用 `tsx` 启动 Node.js web 应用程序，允许您测试已实现的 API 端点。

```bash
npx tsx src/app.ts
```

--------------------------------

### 安装 Drizzle ORM 和 PostgreSQL 依赖（bun）

来源：https://orm.drizzle.team/docs/get-started/nile-new

使用 bun 安装核心 Drizzle ORM 包、PostgreSQL 的 'pg' 驱动、'dotenv' 用于环境变量管理，以及 'drizzle-kit'、'tsx' 和 '@types/pg' 等开发依赖。

```bash
bun add drizzle-orm pg dotenv
bun add -D drizzle-kit tsx @types/pg
```

--------------------------------

### 使用多个配置文件推送迁移（bun）

来源：https://orm.drizzle.team/docs/drizzle-kit-push

使用 bun 和多个 Drizzle Kit 配置文件推送数据库迁移的示例。

```bash
bunx drizzle-kit push --config=drizzle-dev.config.ts
bunx drizzle-kit push --config=drizzle-prod.config.ts
```

--------------------------------

### PlanetScale 数据库连接变量

来源：https://orm.drizzle.team/docs/get-started/planetscale-new

定义连接到 PlanetScale 数据库所需的环境变量。包括主机、用户名和密码。

```env
DATABASE_HOST=
DATABASE_USERNAME=
DATABASE_PASSWORD=
```

--------------------------------

### Drizzle ORM 配置示例（TypeScript）

来源：https://orm.drizzle.team/docs/drizzle-kit-migrate

提供一个 Drizzle ORM 的 TypeScript 配置文件示例。它指定了数据库方言、schema 位置、凭据以及迁移表/schema 设置。此文件对于定义数据库连接和迁移策略至关重要。

```typescript
import { defineConfig } from "drizzle-kit";

export default defineConfig({
 dialect: "postgresql",
 schema: "./src/schema.ts",
 dbCredentials: {
 url: "postgresql://user:password@host:port/dbname"
 },
 migrations: {
 table: 'journal',
 schema: 'drizzle',
 },
});
```

--------------------------------

### 安装 Drizzle ORM 和依赖（yarn）

来源：https://orm.drizzle.team/docs/get-started/turso-database-new

使用 yarn 安装所需的 Drizzle ORM 包和开发工具。此命令确保 `drizzle-orm` 和 `drizzle-kit` 的 beta 版本，以及 `@tursodatabase/database`、`dotenv` 和 `tsx` 被包含在项目依赖中。

```bash
yarn add drizzle-orm@beta @tursodatabase/database dotenv
yarn add -D drizzle-kit@beta tsx
```

--------------------------------

### Drizzle ORM 的 SQL 迁移文件示例

来源：https://orm.drizzle.team/docs/tutorials/drizzle-with-neon

说明 Drizzle Kit 生成的 SQL 迁移文件的结构。此示例展示了两个表 'posts_table' 和 'users_table' 的创建，包括主键、约束和外键关系。

```sql
CREATE TABLE IF NOT EXISTS "posts_table" (
 "id" serial PRIMARY KEY NOT NULL,
 "title" text NOT NULL,
 "content" text NOT NULL,
 "user_id" integer NOT NULL,
 "created_at" timestamp DEFAULT now() NOT NULL,
 "updated_at" timestamp NOT NULL
);
--> statement-breakpoint
CREATE TABLE IF NOT EXISTS "users_table" (
 "id" serial PRIMARY KEY NOT NULL,
 "name" text NOT NULL,
 "age" integer NOT NULL,
 "email" text NOT NULL,
 CONSTRAINT "users_table_email_unique" UNIQUE("email")
);
--> statement-breakpoint
DO $$ BEGIN
 ALTER TABLE "posts_table" ADD CONSTRAINT "posts_table_user_id_users_table_id_fk" FOREIGN KEY ("user_id") REFERENCES "public"."users_table"("id") ON DELETE cascade ON UPDATE no action;
EXCEPTION
 WHEN duplicate_object THEN null;
END $$;
```

--------------------------------

### 安装 postgres 包（bun）

来源：https://orm.drizzle.team/docs/tutorials/drizzle-with-supabase

使用 bun 安装 postgres 包，这是一个 Drizzle ORM 可以使用的 Node.js PostgreSQL 驱动。

```bash
bun add postgres
```

--------------------------------

### 安装 `@libsql/client` 包

来源：https://orm.drizzle.team/docs/tutorials/drizzle-with-turso

安装 '@libsql/client' 包，这是与 libSQL 兼容数据库（如 Turso）交互的官方驱动。此客户端使 Drizzle ORM 能够与数据库通信。

```npm
npm i @libsql/client
```

```yarn
yarn add @libsql/client
```

```pnpm
pnpm add @libsql/client
```

```bun
bun add @libsql/client
```

--------------------------------

### 使用现有驱动初始化 Drizzle 连接

来源：https://orm.drizzle.team/docs/get-started/turso-database-new

演示当您已有现有数据库客户端实例时如何初始化 Drizzle ORM。这对于将 Drizzle 集成到预先配置的数据库连接或自定义驱动设置中非常有用。

```typescript
import 'dotenv/config';
import { Database } from '@tursodatabase/database';
import { drizzle } from 'drizzle-orm/tursodatabase/database';

const client = new Database(process.env.DB_FILE_NAME!);
const db = drizzle({ client });
```

--------------------------------

### 安装 Drizzle 和 Gel 包（bun）

来源：https://orm.drizzle.team/docs/get-started-gel

为 bun 项目安装必要的 Drizzle ORM 和 Gel 包。包括 Drizzle Kit 的开发依赖。

```bash
bun add drizzle-orm gel
bun add -D drizzle-kit
```

--------------------------------

### 安装 Drizzle ORM 和 PostgreSQL 依赖（npm）

来源：https://orm.drizzle.team/docs/get-started/nile-new

安装核心 Drizzle ORM 包、PostgreSQL 的 'pg' 驱动、'dotenv' 用于环境变量管理，以及 'drizzle-kit'、'tsx' 和 '@types/pg' 等开发依赖。

```bash
npm i drizzle-orm pg dotenv
npm i -D drizzle-kit tsx @types/pg
```

--------------------------------

### Drizzle Kit 生成迁移过程

来源：https://orm.drizzle.team/docs/drizzle-kit-generate

`drizzle-kit generate` 过程的视觉表示，概述了从读取迁移文件夹到生成 SQL 文件的步骤。

```ascii-art
┌────────────────────────┐
│ $ drizzle-kit generate │
└─┬──────────────────────┘
 │
 └ 1. 读取之前的迁移文件夹
 2. 查找当前和之前 schema 之间的差异
 3. 如果需要，提示开发者进行重命名
 ┌ 4. 生成 SQL 迁移并持久化到文件
 │ ┌─┴───────────────────────────────────────┐
 │ 📂 drizzle
 │ ├ 📂 _meta
 │ └ 📜 0000_premium_mister_fear.sql
 v
```

--------------------------------

### 安装 Drizzle ORM 和 mysql2 驱动

来源：https://orm.drizzle.team/docs/get-started-singlestore

使用 npm、yarn、pnpm 或 bun 安装必要的 Drizzle ORM 包和用于 SingleStore 集成的 `mysql2` 驱动。

```npm
npm i drizzle-orm mysql2
npm i -D drizzle-kit
```

```yarn
yarn add drizzle-orm mysql2
yarn add -D drizzle-kit
```

```pnpm
pnpm add drizzle-orm mysql2
pnpm add -D drizzle-kit
```

```bun
bun add drizzle-orm mysql2
bun add -D drizzle-kit
```

--------------------------------

### 启动 MySQL Docker 容器

来源：https://orm.drizzle.team/docs/guides/mysql-local-setup

此命令以分离模式启动一个名为 'drizzle-mysql' 的 MySQL 容器。它设置 root 密码，将主机的 3306 端口映射到容器的 3306 端口以便外部访问，并使用 'mysql' 镜像。可选的环境变量可以在容器创建时创建数据库和用户。

```bash
docker run --name drizzle-mysql -e MYSQL_ROOT_PASSWORD=mypassword -d -p 3306:3306 mysql
```

```bash
docker ps
```

--------------------------------

### 初始化 Supabase 项目

来源：https://orm.drizzle.team/docs/tutorials/drizzle-with-supabase-edge-functions

在本地初始化一个新的 Supabase 项目。此命令会创建一个包含 Supabase 项目配置文件的 'supabase' 文件夹。

```bash
supabase init
```

--------------------------------

### 安装 Drizzle ORM 和 PostgreSQL 依赖（pnpm）

来源：https://orm.drizzle.team/docs/get-started/nile-new

使用 pnpm 安装核心 Drizzle ORM 包、PostgreSQL 的 'pg' 驱动、'dotenv' 用于环境变量管理，以及 'drizzle-kit'、'tsx' 和 '@types/pg' 等开发依赖。

```bash
pnpm add drizzle-orm pg dotenv
pnpm add -D drizzle-kit tsx @types/pg
```

--------------------------------

### 设置 Bun:SQLite 数据库连接变量

来源：https://orm.drizzle.team/docs/get-started/bun-sqlite-new

在 .env 文件中定义 Bun:SQLite 的数据库文件名。此变量用于配置 Drizzle ORM 的数据库连接字符串。

```env
DB_FILE_NAME=mydb.sqlite
```

--------------------------------

### 安装 Neon Serverless 驱动

来源：https://orm.drizzle.team/docs/tutorials/drizzle-with-neon

安装 Neon serverless 驱动，这是将 Drizzle ORM 连接到 Neon Postgres 数据库所必需的。支持多种包管理器。

```npm
npm i @neondatabase/serverless
```

```yarn
yarn add @neondatabase/serverless
```

```pnpm
pnpm add @neondatabase/serverless
```

```bun
bun add @neondatabase/serverless
```

--------------------------------

### 安装 Express 包

来源：https://orm.drizzle.team/docs/tutorials/drizzle-with-nile

使用常见的包管理器安装 'express' 包，这是一个最小且灵活的 Node.js web 应用程序框架。

```npm
npm i express
```

```yarn
yarn add express
```

```pnpm
pnpm add express
```

```bun
bun add express
```

--------------------------------

### Drizzle 配置文件

来源：https://orm.drizzle.team/docs/get-started/vercel-new

设置 `drizzle.config.ts` 文件，Drizzle Kit 使用该文件进行数据库操作。它指定了迁移输出目录（`out`）、schema 文件位置（`schema`）、数据库方言（`dialect`）和凭据（包括来自环境变量的 `POSTGRES_URL`）。

```typescript
import 'dotenv/config';
import { defineConfig } from 'drizzle-kit';

export default defineConfig({
 out: './drizzle',
 schema: './src/db/schema.ts',
 dialect: 'postgresql',
 dbCredentials: {
 url: process.env.POSTGRES_URL!,
 },
});
```

--------------------------------

### 在 TypeScript 中初始化 Drizzle ORM 数据库连接

来源：https://orm.drizzle.team/docs/get-started/gel-new

此代码片段演示了如何使用 Drizzle ORM 和 'gel' 客户端初始化数据库连接。它需要 'drizzle-orm/gel' 和 'gel' 包。输出是一个配置好的 Drizzle 数据库实例。

```typescript
import { drizzle } from "drizzle-orm/gel";
import { createClient } from "gel";

const gelClient = createClient();
const db = drizzle({ client: gelClient });
```

--------------------------------

### 使用 bun 安装 Drizzle ORM 和 Drizzle Kit

来源：https://orm.drizzle.team/docs/connect-bun-sqlite

使用 Bun 运行时安装 Drizzle ORM 和 Drizzle Kit。Bun 为包安装和 JavaScript 执行提供了快速替代方案。

```bash
bun add drizzle-orm
bun add -D drizzle-kit
```

--------------------------------

### 使用连接选项初始化 SingleStore 驱动

来源：https://orm.drizzle.team/docs/get-started-singlestore

通过提供连接选项（包括数据库 URI）来初始化 Drizzle ORM 的 SingleStore 驱动，并展示了一个示例查询。

```typescript
import { drizzle } from "drizzle-orm/singlestore";

// 您可以指定 mysql2 连接选项中的任何属性
const db = drizzle({ connection:{ uri: process.env.DATABASE_URL }});

const response = await db.select().from(...)
```

--------------------------------

### 初始化 Drizzle ORM 连接（Supabase 连接池模式）

来源：https://orm.drizzle.team/docs/get-started/supabase-new

为 Supabase 初始化启用了 'Transaction' 连接池模式的 Drizzle ORM 连接，禁用 'prepare' 因为此配置不支持。

```typescript
import { drizzle } from 'drizzle-orm/postgres-js'
import postgres from 'postgres'

async function main() {
 // 禁用预取，因为 "Transaction" 连接池模式不支持
 const client = postgres(process.env.DATABASE_URL, { prepare: false })
 const db = drizzle({ client });
}

main();
```

--------------------------------

### 拉取 PostgreSQL Docker 镜像

来源：https://orm.drizzle.team/docs/guides/postgresql-local-setup

此命令从 Docker Hub 拉取最新的 PostgreSQL Docker 镜像。您也可以使用标签指定特定版本，例如 `postgres:15`。

```bash
docker pull postgres
```

```bash
docker pull postgres:15
```

--------------------------------

### 安装 Drizzle ORM 和 PostgreSQL 依赖（yarn）

来源：https://orm.drizzle.team/docs/get-started/nile-new

使用 yarn 安装核心 Drizzle ORM 包、PostgreSQL 的 'pg' 驱动、'dotenv' 用于环境变量管理，以及 'drizzle-kit'、'tsx' 和 '@types/pg' 等开发依赖。

```bash
yarn add drizzle-orm pg dotenv
yarn add -D drizzle-kit tsx @types/pg
```
