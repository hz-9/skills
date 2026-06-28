# 过滤条件和操作符

`where` 子句的过滤操作符。

## 相等性

```typescript
// 精确匹配（隐式）
where: { email: 'alice@prisma.io' }

// 显式相等
where: { email: { equals: 'alice@prisma.io' } }

// 不等于
where: { email: { not: 'alice@prisma.io' } }
```

## 比较

```typescript
// 大于
where: { age: { gt: 18 } }

// 大于或等于
where: { age: { gte: 18 } }

// 小于
where: { age: { lt: 65 } }

// 小于或等于
where: { age: { lte: 65 } }

// 组合
where: { age: { gte: 18, lte: 65 } }
```

## 列表

```typescript
// 在数组中
where: { role: { in: ['ADMIN', 'MODERATOR'] } }

// 不在数组中
where: { role: { notIn: ['GUEST', 'BANNED'] } }
```

## 字符串过滤

```typescript
// 包含
where: { email: { contains: 'prisma' } }

// 以...开头
where: { email: { startsWith: 'alice' } }

// 以...结尾
where: { email: { endsWith: '@prisma.io' } }

// 不区分大小写（某些数据库的默认行为）
where: { 
  email: { 
    contains: 'PRISMA',
    mode: 'insensitive' 
  } 
}
```

## 空值检查

```typescript
// 为空
where: { deletedAt: null }

// 不为空
where: { deletedAt: { not: null } }

// 使用 isSet（用于可选字段）
where: { middleName: { isSet: true } }
```

## 逻辑操作符

### AND（隐式）

```typescript
// 多个条件 = AND
where: {
  email: { contains: '@prisma.io' },
  role: 'ADMIN'
}
```

### AND（显式）

```typescript
where: {
  AND: [
    { email: { contains: '@prisma.io' } },
    { role: 'ADMIN' }
  ]
}
```

### OR

```typescript
where: {
  OR: [
    { email: { contains: '@gmail.com' } },
    { email: { contains: '@prisma.io' } }
  ]
}
```

### NOT

```typescript
where: {
  NOT: {
    role: 'GUEST'
  }
}

// 多个 NOT 条件
where: {
  NOT: [
    { role: 'GUEST' },
    { verified: false }
  ]
}
```

### 组合使用

```typescript
where: {
  AND: [
    { verified: true },
    {
      OR: [
        { role: 'ADMIN' },
        { role: 'MODERATOR' }
      ]
    }
  ],
  NOT: { deletedAt: { not: null } }
}
```

## 关联过滤操作符

### some

至少一条关联记录匹配：

```typescript
// 拥有至少一篇已发布文章的用户
where: {
  posts: {
    some: { published: true }
  }
}
```

### every

所有关联记录都匹配：

```typescript
// 所有文章都已发布的用户
where: {
  posts: {
    every: { published: true }
  }
}
```

### none

没有关联记录匹配：

```typescript
// 没有已发布文章的用户
where: {
  posts: {
    none: { published: true }
  }
}
```

### is / isNot（一对一）

```typescript
// 资料所在国家为美国的用户
where: {
  profile: {
    is: { country: 'USA' }
  }
}

// 没有资料的用户
where: {
  profile: {
    isNot: null
  }
}
```

## 数组字段过滤

用于 `String[]` 等字段：

```typescript
// 包含元素
where: { tags: { has: 'typescript' } }

// 包含部分元素
where: { tags: { hasSome: ['typescript', 'javascript'] } }

// 包含所有元素
where: { tags: { hasEvery: ['typescript', 'prisma'] } }

// 为空
where: { tags: { isEmpty: true } }
```

## JSON 过滤

```typescript
// 基于路径的过滤
where: {
  metadata: {
    path: ['settings', 'theme'],
    equals: 'dark'
  }
}

// JSON 中的字符串包含
where: {
  metadata: {
    path: ['bio'],
    string_contains: 'developer'
  }
}
```

## 全文搜索

```typescript
// 需要 @@fulltext 索引
where: {
  content: {
    search: 'prisma database'
  }
}
```
