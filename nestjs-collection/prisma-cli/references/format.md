# prisma format

格式化你的 Prisma schema 文件。

## 命令

```bash
prisma format [options]
```

## 功能说明

- 修复格式（缩进、间距）
- 添加缺失的反向关系（例如，添加关系的另一侧）
- 添加缺失的关系参数（例如 `fields`、`references`）
- 排序字段和属性（有主见）

## 选项

| 选项 | 描述 |
|--------|-------------|
| `--schema` | schema 文件路径 |
| `--config` | Prisma 配置文件的自定义路径 |

## 示例

### 格式化默认 schema

```bash
prisma format
```

### 格式化特定 schema

```bash
prisma format --schema=./custom/schema.prisma
```

## 行为

`prisma format` 会原地修改文件。它相当于"Prisma schema 的 Prettier"，但还具有语义理解能力，可以修复/添加缺失的 schema 定义。

## 在编辑器中使用

大多数 Prisma 编辑器扩展（VS Code、WebStorm）会在保存时自动运行 `prisma format`。该命令在以下情况下很有用：
- CI 流水线（检查格式）
- 基于 CLI 的工作流
- 修复大型 schema 重构
