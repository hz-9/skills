# 数据库集成指南

将各种 ORMs 与 NestJS 集成的完整指南，包括 Drizzle ORM、TypeORM、Prisma 和 Mongoose。

## Drizzle ORM 集成

### 安装

```bash
npm i drizzle-orm pg
npm i -D drizzle-kit tsx
```

### 模式定义

```typescript
// src/db/schema.ts
import { pgTable, serial, text, timestamp } from 'drizzle-orm/pg-core';

export const users = pgTable('users', {
  id: serial('id').primaryKey(),
  name: text('name').notNull(),
  email: text('email').notNull().unique(),
  createdAt: timestamp('created_at').defaultNow(),
});

export const accounts = pgTable('accounts', {
  id: serial('id').primaryKey(),
  userId: integer('user_id').references(() => users.id),
  balance: decimal('balance').notNull(),
});
```

### DatabaseService Provider

```typescript
// src/db/database.service.ts
import { Injectable, OnModuleInit } from '@nestjs/common';
import { drizzle, NodePgDatabase } from 'drizzle-orm/node-postgres';
import { Pool } from 'pg';
import * as schema from './schema';

@Injectable()
export class DatabaseService implements OnModuleInit {
  public database: NodePgDatabase<typeof schema>;
  private pool: Pool;

  async onModuleInit() {
    this.pool = new Pool({
      connectionString: process.env.DATABASE_URL,
    });
    this.database = drizzle(this.pool, { schema });
  }

  async onModuleDestroy() {
    await this.pool.end();
  }
}
```

### Repository 模式

```typescript
// src/users/users.repository.ts
import { Injectable } from '@nestjs/common';
import { eq } from 'drizzle-orm';
import { DatabaseService } from '../db/database.service';
import { users, type User } from '../db/schema';

@Injectable()
export class UsersRepository {
  constructor(private db: DatabaseService) {}

  async findAll() {
    return this.db.database.select().from(users);
  }

  async findById(id: number) {
    return this.db.database.query.users.findFirst({
      where: eq(users.id, id),
    });
  }

  async create(data: typeof users.$inferInsert) {
    return this.db.database.insert(users).values(data).returning();
  }

  async update(id: number, data: Partial<typeof users.$inferInsert>) {
    return this.db.database
      .update(users)
      .set(data)
      .where(eq(users.id, id))
      .returning();
  }

  async delete(id: number) {
    return this.db.database
      .delete(users)
      .where(eq(users.id, id))
      .returning();
  }
}
```

### 数据库事务

```typescript
async transferFunds(fromId: number, toId: number, amount: number) {
  return this.db.database.transaction(async (tx) => {
    await tx.update(accounts)
      .set({ balance: sql`${accounts.balance} - ${amount}` })
      .where(eq(accounts.id, fromId));

    await tx.update(accounts)
      .set({ balance: sql`${accounts.balance} + ${amount}` })
      .where(eq(accounts.id, toId));
  });
}
```

### Migrations

```bash
# 生成 migration
npx drizzle-kit generate

# 验证生成的 SQL
# 运行 migration
npx drizzle-kit migrate
```

---

## TypeORM 集成

### 安装

```bash
npm i @nestjs/typeorm typeorm pg
```

### 模块配置

```typescript
// src/app.module.ts
import { TypeOrmModule } from '@nestjs/typeorm';
import { User } from './users/entities/user.entity';

@Module({
  imports: [
    TypeOrmModule.forRoot({
      type: 'postgres',
      url: process.env.DATABASE_URL,
      entities: [User],
      synchronize: false, // 生产环境中绝不使用
      logging: process.env.NODE_ENV === 'development',
    }),
    TypeOrmModule.forFeature([User]),
  ],
})
export class AppModule {}
```

### Entity 定义

```typescript
// src/users/entities/user.entity.ts
import { Entity, PrimaryGeneratedColumn, Column, CreateDateColumn } from 'typeorm';

@Entity('users')
export class User {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column()
  name: string;

  @Column({ unique: true })
  email: string;

  @CreateDateColumn({ name: 'created_at' })
  createdAt: Date;
}
```

### Repository 模式

```typescript
// src/users/users.service.ts
import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { User } from './entities/user.entity';

@Injectable()
export class UsersService {
  constructor(
    @InjectRepository(User)
    private usersRepository: Repository<User>,
  ) {}

  async findAll(): Promise<User[]> {
    return this.usersRepository.find();
  }

  async findById(id: string): Promise<User> {
    const user = await this.usersRepository.findOne({ where: { id } });
    if (!user) {
      throw new NotFoundException(`User with ID ${id} not found`);
    }
    return user;
  }

  async create(data: Partial<User>): Promise<User> {
    const user = this.usersRepository.create(data);
    return this.usersRepository.save(user);
  }
}
```

### 多个数据库连接

```typescript
TypeOrmModule.forRoot({
  name: 'usersConnection',
  type: 'postgres',
  url: process.env.USERS_DATABASE_URL,
  entities: [User],
}),

TypeOrmModule.forRoot({
  name: 'ordersConnection',
  type: 'postgres',
  url: process.env.ORDERS_DATABASE_URL,
  entities: [Order],
}),

// 使用方式
@InjectRepository(User, 'usersConnection')
private usersRepository: Repository<User>,
```

---

## Prisma 集成

### 安装

```bash
npm i @prisma/client
npm i -D prisma
npx prisma init
```

### 模式定义

```prisma
// prisma/schema.prisma
generator client {
  provider = "prisma-client-js"
}

datasource db {
  provider = "postgresql"
  url      = env("DATABASE_URL")
}

model User {
  id        Int      @id @default(autoincrement())
  name      String
  email     String   @unique
  createdAt DateTime @default(now()) @map("created_at")

  @@map("users")
}
```

### PrismaService

```typescript
// src/prisma/prisma.service.ts
import { Injectable, OnModuleInit, OnModuleDestroy } from '@nestjs/common';
import { PrismaClient } from '@prisma/client';

@Injectable()
export class PrismaService extends PrismaClient implements OnModuleInit, OnModuleDestroy {
  async onModuleInit() {
    await this.$connect();
  }

  async onModuleDestroy() {
    await this.$disconnect();
  }
}
```

### 在 Services 中使用

```typescript
// src/users/users.service.ts
import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';

@Injectable()
export class UsersService {
  constructor(private prisma: PrismaService) {}

  async findAll() {
    return this.prisma.user.findMany();
  }

  async findById(id: number) {
    const user = await this.prisma.user.findUnique({ where: { id } });
    if (!user) {
      throw new NotFoundException(`User with ID ${id} not found`);
    }
    return user;
  }

  async create(data: { name: string; email: string }) {
    return this.prisma.user.create({ data });
  }
}
```

### Migrations

```bash
# 生成 migration
npx prisma migrate dev

# 应用 migrations
npx prisma migrate deploy
```

---

## Mongoose 集成

### 安装

```bash
npm i @nestjs/mongoose mongoose
```

### 模块配置

```typescript
// src/app.module.ts
import { MongooseModule } from '@nestjs/mongoose';

@Module({
  imports: [
    MongooseModule.forRoot(process.env.MONGODB_URI),
  ],
})
export class AppModule {}
```

### 模式定义

```typescript
// src/users/schemas/user.schema.ts
import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document } from 'mongoose';

@Schema({ timestamps: true })
export class User extends Document {
  @Prop({ required: true })
  name: string;

  @Prop({ required: true, unique: true })
  email: string;
}

export const UserSchema = SchemaFactory.createForClass(User);
```

### 在 Services 中使用

```typescript
// src/users/users.service.ts
import { Injectable } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model } from 'mongoose';
import { User } from './schemas/user.schema';

@Injectable()
export class UsersService {
  constructor(@InjectModel(User) private userModel: Model<User>) {}

  async findAll(): Promise<User[]> {
    return this.userModel.find().exec();
  }

  async findById(id: string): Promise<User> {
    const user = await this.userModel.findById(id).exec();
    if (!user) {
      throw new NotFoundException(`User with ID ${id} not found`);
    }
    return user;
  }

  async create(data: { name: string; email: string }): Promise<User> {
    const createdUser = new this.userModel(data);
    return createdUser.save();
  }
}
```

---

## 数据库最佳实践

### 事务管理

- 保持事务简短
- 避免嵌套事务
- 实现正确的错误处理和回滚
- 适当使用隔离级别

### 防止 N+1 查询

```typescript
// 错误：N+1 查询
const users = await this.usersRepository.findAll();
for (const user of users) {
  user.orders = await this.ordersRepository.findByUserId(user.id);
}

// 正确：Eager loading 或 DataLoader
const users = await this.usersRepository.findAllWithOrders();
```

### 连接池

```typescript
// TypeORM
TypeOrmModule.forRoot({
  // ...
  extra: {
    max: 20, // 最大池大小
    idleTimeoutMillis: 30000,
    connectionTimeoutMillis: 2000,
  },
})
```

### Migration 策略

- 始终使用 migrations 进行模式更改
- 绝不在生产环境中自动同步
- 在生产之前在 staging 中测试 migrations
- 将 migration 文件保留在版本控制中
