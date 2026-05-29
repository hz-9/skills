# Skills Collection

每个技能是一个自包含的目录，遵循 [agent-skills 规范](https://agentskills.io)。

## 技能列表

| 技能名称 | 描述 |
|---------|------|
| [rush-to-nx](./skills/rush-to-nx/SKILL.md) | 将 Rush.js monorepo 迁移到 Nx + pnpm workspace + Changesets |

## 安装

### 方式一：npx skills（推荐）

```bash
# 安装所有技能
npx skills add hz-9/skills

# 仅安装指定技能
npx skills add hz-9/skills --skill rush-to-nx
```

### 方式二：手动复制

```bash
# 将需要的技能复制到 Qoder 用户技能目录
cp -r skills/<skill-name> ~/.qoder/skills/<skill-name>
```

### 方式三：使用安装脚本

```bash
# 安装所有技能
bash scripts/install.sh

# 安装指定技能
bash scripts/install.sh rush-to-nx
```

## 创建新技能

参考 [templates/SKILL.md](./templates/SKILL.md) 创建新技能：

```bash
cp -r templates skills/<your-skill-name>
# 编辑 skills/<your-skill-name>/SKILL.md
```

### SKILL.md 规范

- `name` 字段必须与目录名一致（kebab-case）
- `description` 简要描述技能功能及调用时机
- 正文提供完整的使用指南、步骤和示例
- 长文档请拆分到 `REFERENCE.md`、`EXAMPLES.md` 中

## 许可证

MIT
