import { Injectable } from '@nestjs/common';
import { DatabaseService } from '../db/database.service';
import { accounts, sql, eq } from '../db/schema';

/**
 * 数据库事务示例
 *
 * 演示：
 * - 基本事务
 * - 带回滚的事务
 * - 嵌套操作
 */
@Injectable()
export class TransactionService {
  constructor(private db: DatabaseService) {}

  /**
   * 在账户之间转账
   * 演示：原子事务，失败时回滚
   */
  async transferFunds(
    fromId: number,
    toId: number,
    amount: number,
  ): Promise<void> {
    return this.db.database.transaction(async (tx) => {
      // 从源账户扣款
      const [fromAccount] = await tx
        .select()
        .from(accounts)
        .where(eq(accounts.id, fromId));

      if (fromAccount.balance < amount) {
        throw new Error('Insufficient funds');
      }

      await tx
        .update(accounts)
        .set({ balance: sql`${accounts.balance} - ${amount}` })
        .where(eq(accounts.id, fromId));

      // 向目标账户入账
      await tx
        .update(accounts)
        .set({ balance: sql`${accounts.balance} + ${amount}` })
        .where(eq(accounts.id, toId));
    });
  }

  /**
   * 创建订单并进行库存检查
   * 演示：多表事务
   */
  async createOrder(userId: number, productId: number, quantity: number) {
    return this.db.database.transaction(async (tx) => {
      // 检查库存
      const [product] = await tx
        .select()
        .from(products)
        .where(eq(products.id, productId));

      if (product.stock < quantity) {
        throw new Error('Insufficient inventory');
      }

      // 减少库存
      await tx
        .update(products)
        .set({ stock: sql`${products.stock} - ${quantity}` })
        .where(eq(products.id, productId));

      // 创建订单
      const [order] = await tx
        .insert(orders)
        .values({
          userId,
          productId,
          quantity,
          status: 'pending',
        })
        .returning();

      return order;
    });
  }
}

// 示例所需的 Schema 导入
import { products, orders } from '../db/schema';
