# Skills Collection

每个技能是一个自包含的目录，遵循 [agent-skills 规范](https://agentskills.io)。

## 技能列表

| 技能名称 | 描述 |
|---------|------|
| [git-commit-helper](./skills/git-commit-helper/SKILL.md) | 遵循 Conventional Commits 规范智能生成 Git commit message |
| [git-workflow-enhanced](./skills/git-workflow-enhanced/SKILL.md) | 全自动 Git 工作流：commit message → 分支 → prepare-commit-msg 钩子 |
| [grill-me](./skills/grill-me/SKILL.md) | 持续追问拷问计划与设计，遍历决策树每个分支 |
| [grill-with-docs](./skills/grill-with-docs/SKILL.md) | 结合领域模型挑战方案，即时更新文档与 ADR |
| [pnpm-changeset-workflow](./skills/pnpm-changeset-workflow/SKILL.md) | pnpm monorepo 变更集文件自动生成与提交 |
| [rush-to-nx](./skills/rush-to-nx/SKILL.md) | 将 Rush.js monorepo 迁移到 Nx + pnpm workspace + Changesets |
| [write-a-skill](./skills/write-a-skill/SKILL.md) | 创建符合规范的 agent 技能，含结构和资源打包 |
| [zoom-out](./skills/zoom-out/SKILL.md) | 缩小视角，获取代码模块地图和高层次上下文 |

## 安装

### 方式一：npx skills（推荐）

```bash
# 安装所有技能
npx skills add hz-9/skills

# 仅安装指定技能
npx skills add hz-9/skills --skill git-commit-helper
npx skills add hz-9/skills --skill git-workflow-enhanced
npx skills add hz-9/skills --skill grill-me
npx skills add hz-9/skills --skill grill-with-docs
npx skills add hz-9/skills --skill pnpm-changeset-workflow
npx skills add hz-9/skills --skill rush-to-nx
npx skills add hz-9/skills --skill write-a-skill
npx skills add hz-9/skills --skill zoom-out
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
bash scripts/install.sh git-commit-helper
bash scripts/install.sh git-workflow-enhanced
bash scripts/install.sh grill-me
bash scripts/install.sh grill-with-docs
bash scripts/install.sh pnpm-changeset-workflow
bash scripts/install.sh rush-to-nx
bash scripts/install.sh write-a-skill
bash scripts/install.sh zoom-out
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
