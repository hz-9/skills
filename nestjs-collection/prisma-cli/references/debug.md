# prisma debug

打印有助于调试和错误报告的信息。

## 命令

```bash
prisma debug [options]
```

## 功能说明

输出关于你的 Prisma 环境的详细信息，包括：
- Prisma CLI 版本
- Prisma Client 版本（如果已安装）
- 引擎二进制文件（Query Engine、Migration Engine 等）
- 平台信息（操作系统、架构）
- Node.js 版本
- 配置的数据源提供者

## 选项

| 选项 | 描述 |
|--------|-------------|
| `--schema` | schema 文件路径 |
| `--config` | Prisma 配置文件的自定义路径 |

## 示例输出

```
prisma               : 7.3.0
@prisma/client       : 7.3.0
Operating System     : darwin
Architecture         : arm64
Node.js              : v20.10.0
TypeScript           : 5.3.3
Query Compiler       : enabled
PSL                  : ...
Schema Engine        : ...
```

## 何时使用

- **故障排除**：检查版本不匹配
- **报告问题**：在 GitHub 问题中包含环境信息
- **验证安装**：确保已下载正确的二进制文件
