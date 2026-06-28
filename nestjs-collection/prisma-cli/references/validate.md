# prisma validate

验证你的 Prisma schema 文件。

## 命令

```bash
prisma validate [options]
```

## 功能说明

- 解析 `schema.prisma` 文件
- 检查语法错误
- 验证模型定义、关系和类型
- 报告任何错误或警告，但不生成代码

## 选项

| 选项 | 描述 |
|--------|-------------|
| `--schema` | schema 文件路径 |
| `--config` | Prisma 配置文件的自定义路径 |

## 示例

### 验证默认 schema

```bash
prisma validate
```

### 验证特定 schema

```bash
prisma validate --schema=./custom/schema.prisma
```

### 在 CI 中使用

在 CI 流水线中运行 `validate`，以便尽早捕获 schema 错误：

```yaml
- name: 验证 Schema
  run: npx prisma validate
```

## 常见错误

- 缺少 `@relation` 字段
- 无效的类型
- 重复的模型名称
- 语法错误（缺少花括号等）
