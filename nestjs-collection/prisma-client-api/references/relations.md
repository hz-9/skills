# 关联查询

查询和修改关联记录。

## 包含关联

加载关联记录：

```typescript
const user = await prisma.user.findUnique({
  where: { id: 1 },
  include: {
    posts: true,
    profile: true
  }
})
```

### 带过滤条件的 include

```typescript
const user = await prisma.user.findUnique({
  where: { id: 1 },
  include: {
    posts: {
      where: { published: true },
      orderBy: { createdAt: 'desc' },
      take: 5,
      select: { id: true, title: true }
    }
  }
})
```

### 嵌套 include

```typescript
const user = await prisma.user.findUnique({
  where: { id: 1 },
  include: {
    posts: {
      include: {
        comments: {
          include: { author: true }
        }
      }
    }
  }
})
```

## 选择关联

```typescript
const user = await prisma.user.findUnique({
  where: { id: 1 },
  select: {
    name: true,
    posts: {
      select: { title: true }
    }
  }
})
```

## 嵌套写入

### 创建时包含关联

```typescript
const user = await prisma.user.create({
  data: {
    email: 'alice@prisma.io',
    posts: {
      create: [
        { title: '文章 1' },
        { title: '文章 2' }
      ]
    },
    profile: {
      create: { bio: '你好！' }
    }
  }
})
```

### 创建或连接

```typescript
const post = await prisma.post.create({
  data: {
    title: '新文章',
    author: {
      connectOrCreate: {
        where: { email: 'alice@prisma.io' },
        create: { email: 'alice@prisma.io', name: 'Alice' }
      }
    }
  }
})
```

### 连接已有记录

```typescript
const post = await prisma.post.create({
  data: {
    title: '新文章',
    author: {
      connect: { id: 1 }
    }
  }
})

// 外键简写
const post = await prisma.post.create({
  data: {
    title: '新文章',
    authorId: 1
  }
})
```

## 更新关联

### 更新关联记录

```typescript
const user = await prisma.user.update({
  where: { id: 1 },
  data: {
    posts: {
      update: {
        where: { id: 1 },
        data: { title: '已更新标题' }
      }
    }
  }
})
```

### 批量更新关联

```typescript
const user = await prisma.user.update({
  where: { id: 1 },
  data: {
    posts: {
      updateMany: {
        where: { published: false },
        data: { published: true }
      }
    }
  }
})
```

### Upsert 关联

```typescript
const user = await prisma.user.update({
  where: { id: 1 },
  data: {
    profile: {
      upsert: {
        create: { bio: '新简介' },
        update: { bio: '已更新简介' }
      }
    }
  }
})
```

### 断开关联

```typescript
// 一对一可选
const user = await prisma.user.update({
  where: { id: 1 },
  data: {
    profile: { disconnect: true }
  }
})

// 多对多
const post = await prisma.post.update({
  where: { id: 1 },
  data: {
    tags: {
      disconnect: [{ id: 1 }, { id: 2 }]
    }
  }
})
```

### 删除关联

```typescript
const user = await prisma.user.update({
  where: { id: 1 },
  data: {
    posts: {
      delete: { id: 1 }
    }
  }
})

// 批量删除
const user = await prisma.user.update({
  where: { id: 1 },
  data: {
    posts: {
      deleteMany: { published: false }
    }
  }
})
```

### Set（替换全部）

```typescript
// 替换所有关联记录
const post = await prisma.post.update({
  where: { id: 1 },
  data: {
    tags: {
      set: [{ id: 1 }, { id: 2 }]
    }
  }
})
```

## 关联过滤

### some

至少一条匹配：

```typescript
const users = await prisma.user.findMany({
  where: {
    posts: { some: { published: true } }
  }
})
```

### every

全部匹配：

```typescript
const users = await prisma.user.findMany({
  where: {
    posts: { every: { published: true } }
  }
})
```

### none

没有匹配：

```typescript
const users = await prisma.user.findMany({
  where: {
    posts: { none: { published: true } }
  }
})
```

### is / isNot（一对一）

```typescript
const users = await prisma.user.findMany({
  where: {
    profile: { is: { country: 'USA' } }
  }
})
```

## 关联计数

```typescript
const users = await prisma.user.findMany({
  select: {
    name: true,
    _count: {
      select: { posts: true, followers: true }
    }
  }
})
// { name: 'Alice', _count: { posts: 5, followers: 100 } }
```

### 过滤计数关联

```typescript
const users = await prisma.user.findMany({
  select: {
    name: true,
    _count: {
      select: {
        posts: { where: { published: true } }
      }
    }
  }
})
```
