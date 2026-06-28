import { Injectable } from '@nestjs/common';
import { eq } from 'drizzle-orm';
import { DatabaseService } from '../db/database.service';
import { users, type User, type InsertUser } from '../db/schema';

/**
 * Users Repository - 抽象数据库操作
 */
@Injectable()
export class UsersRepository {
  constructor(private db: DatabaseService) {}

  /**
   * 查询所有用户
   */
  async findAll(): Promise<User[]> {
    return this.db.database.select().from(users);
  }

  /**
   * 根据 ID 查询用户
   */
  async findById(id: number): Promise<User | undefined> {
    return this.db.database.query.users.findFirst({
      where: eq(users.id, id),
    });
  }

  /**
   * 根据邮箱查询用户
   */
  async findByEmail(email: string): Promise<User | undefined> {
    return this.db.database.query.users.findFirst({
      where: eq(users.email, email),
    });
  }

  /**
   * 创建新用户
   */
  async create(data: InsertUser): Promise<User> {
    const [user] = await this.db.database
      .insert(users)
      .values(data)
      .returning();
    return user;
  }

  /**
   * 根据 ID 更新用户
   */
  async update(id: number, data: Partial<InsertUser>): Promise<User> {
    const [user] = await this.db.database
      .update(users)
      .set(data)
      .where(eq(users.id, id))
      .returning();
    return user;
  }

  /**
   * 根据 ID 删除用户
   */
  async delete(id: number): Promise<User> {
    const [user] = await this.db.database
      .delete(users)
      .where(eq(users.id, id))
      .returning();
    return user;
  }

  /**
   * 查询用户及其订单（join 示例）
   */
  async findAllWithOrders() {
    return this.db.database
      .select()
      .from(users)
      .leftJoin(orders, eq(users.id, orders.userId));
  }
}

// join 示例所需的导入
import { orders } from '../db/schema';
