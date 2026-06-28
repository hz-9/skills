# Drizzle 迁移

使用 Drizzle ORM 的 NestJS 数据库迁移模式。

## 生成迁移

```bash
npx drizzle-kit generate
```

## 运行迁移

```typescript
// src/migrations/migration.service.ts
import { Injectable } from '@nestjs/common';
import { migrate } from 'drizzle-orm/node-postgres/migrator';
import { DatabaseService } from '../db/database.service';

@Injectable()
export class MigrationService {
  constructor(private db: DatabaseService) {}

  async runMigrations() {
    try {
      await migrate(this.db.database, { migrationsFolder: './drizzle' });
      console.log('迁移成功完成');
    } catch (error) {
      console.error('迁移失败：', error);
      throw error;
    }
  }
}
```

## 迁移最佳实践

1. **迁移前始终备份** - 保护生产数据
2. **先在本地测试迁移** - 及早发现问题
3. **使迁移可逆** - 尽可能使用 `down` 迁移
4. **保持迁移小而精简** - 便于调试和回滚
5. **对迁移进行版本控制** - 在 git 中跟踪 schema 变更
