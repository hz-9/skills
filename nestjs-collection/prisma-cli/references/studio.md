# prisma studio

打开一个可视化数据库浏览器，用于查看和编辑数据。

## 命令

```bash
prisma studio [options]
```

## 功能说明

- 启动基于 Web 的数据库 GUI
- 查看所有模型和记录
- 创建、更新和删除记录
- 过滤和排序数据
- 导航关系

## 选项

| 选项 | 描述 | 默认值 |
|--------|-------------|---------|
| `--port` / `-p` | Studio 启动端口 | `5555` |
| `--browser` / `-b` | 打开 Studio 的浏览器 | 系统默认 |
| `--config` | Prisma 配置文件的自定义路径 | - |
| `--url` | 数据库连接字符串（覆盖 Prisma 配置中的连接字符串） | - |

## 示例

### 打开 Studio

```bash
prisma studio
```

在 http://localhost:5555 打开

### 自定义端口

```bash
prisma studio --port 3000
```

### 指定浏览器

```bash
prisma studio --browser firefox
```

### 不打开浏览器

```bash
BROWSER=none prisma studio
```

适用于远程服务器。

## 功能

### 查看记录

- 以表格格式查看所有记录
- 大数据集的分页
- 列排序

### 过滤数据

- 按任何字段过滤
- 支持多个条件
- 关系过滤

### 编辑记录

- 点击内联编辑
- 添加新记录
- 删除记录（需确认）

### 导航关系

- 点击关系查看相关记录
- 查看关联项的数量
- 跟随关系链接

## 最新 Studio 功能

近期 Prisma Studio 版本增加了更丰富的编辑器工作流：

- 多单元格选择和编辑
- 全表搜索和更直观的过滤
- 命令面板快捷键
- 深色模式
- 将选择内容复制为 Markdown
- 反向关系导航
- SQL 工作流，包括原生 SQL 查询

一些最新版本还提供了 AI 辅助的 SQL 编写功能。请将这些视为交互式 Studio 功能，而不是替代已提交的迁移或应用程序查询。

## 使用场景

- **开发环境**：快速数据检查
- **调试**：检查数据状态
- **测试**：验证种子数据
- **演示**：向利益相关者展示数据

## 限制

- 仅限开发工具
- 不适用于生产环境
- 仅限于已配置的数据库
- Prisma 7 中的 Prisma Studio 目前主要支持 PostgreSQL、MySQL 和 SQLite
- 对于可重现的应用程序逻辑，建议使用 Prisma Client 和已提交的 SQL 脚本

## 常见工作流

1. 运行迁移：
   ```bash
   prisma migrate dev
   ```

2. 填充数据：
   ```bash
   prisma db seed
   ```

3. 打开 Studio 验证：
   ```bash
   prisma studio
   ```

4. 必要时进行手动编辑

## 安全说明

Studio 提供直接的数据库访问。仅应在以下环境运行：
- 本地开发机器
- 安全的内部网络
- 切勿公开暴露
