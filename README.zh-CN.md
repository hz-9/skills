# Skills Collection

每个技能是一个自包含的目录，遵循 [agent-skills 规范](https://agentskills.io)。

## Skills

| 技能名称 | 描述 |
|---------|------|
| [git-commit-helper](./skills/git-commit-helper/SKILL.md) | 遵循 Conventional Commits 规范智能生成 Git commit message |
| [grill-me](./skills/grill-me/SKILL.md) | 持续追问拷问计划与设计，遍历决策树每个分支 |
| [grill-with-docs](./skills/grill-with-docs/SKILL.md) | 结合领域模型挑战方案，即时更新文档与 ADR |
| [pnpm-changeset-workflow](./skills/pnpm-changeset-workflow/SKILL.md) | pnpm monorepo 变更集文件自动生成与提交 |
| [rush-to-nx](./skills/rush-to-nx/SKILL.md) | 将 Rush.js monorepo 迁移到 Nx + pnpm workspace + Changesets |
| [write-a-skill](./skills/write-a-skill/SKILL.md) | 创建符合规范的 agent 技能，含结构和资源打包 |
| [zoom-out](./skills/zoom-out/SKILL.md) | 缩小视角，获取代码模块地图和高层次上下文 |

### 安装方式

#### npx skills

```bash
# 安装所有技能
npx skills add hz-9/skills

# 仅安装指定技能
npx skills add hz-9/skills --skill git-commit-helper
npx skills add hz-9/skills --skill grill-me
npx skills add hz-9/skills --skill grill-with-docs
npx skills add hz-9/skills --skill pnpm-changeset-workflow
npx skills add hz-9/skills --skill rush-to-nx
npx skills add hz-9/skills --skill write-a-skill
npx skills add hz-9/skills --skill zoom-out
```

#### 使用脚本安装

支持环境变量 `SKILLS_DIR` 覆盖目标路径（默认 `~/.qoder/skills`）。

```bash
bash scripts/install-skills.sh
```

一行命令（无需克隆仓库）：

```bash
bash <(curl -s https://raw.githubusercontent.com/hz-9/skills/master/scripts/install-skills.sh)

# 指定自定义目录：
SKILLS_DIR=~/.qoder/skills bash <(curl -s https://raw.githubusercontent.com/hz-9/skills/master/scripts/install-skills.sh)
```

### 已废弃

| 技能名称 | 描述 |
|---------|------|
| [git-workflow-enhanced](./deprecated/skills/git-workflow-enhanced/SKILL.md) | 全自动 Git 工作流：commit message → 分支 → prepare-commit-msg 钩子 |

## Commands

仓库的 [commands/](./commands/) 目录下提供可复用的 Qoder 命令。命令是 `.md` 文件，可通过 Qoder 的命令面板调用。

| 命令 | 描述 |
|------|------|
| [git-ship](./commands/git-ship.md) | 基于暂存内容创建分支、生成提交信息并推送，最终输出 PR 链接 |

#### 使用脚本安装

支持环境变量 `COMMANDS_DIR` 覆盖目标路径（默认 `~/.agents/commands`）。

```bash
bash scripts/install-commands.sh
```

一行命令（无需克隆仓库）：

```bash
bash <(curl -s https://raw.githubusercontent.com/hz-9/skills/master/scripts/install-commands.sh)

# 指定自定义目录：
COMMANDS_DIR=~/.qoder/commands bash <(curl -s https://raw.githubusercontent.com/hz-9/skills/master/scripts/install-commands.sh)
```

## Step - 2：文档同步

确保当前 `skills` 文件夹下的技能项与 README.zh-CN.md 文档的 `Skills` 二级标题下的内容保持一致：
- 缺失的 Skill 新增到表格和 `安装脚本` 当中；
- 废弃的 Skill 移动到 `Skills - 已废弃` 标题下，并在 `安装脚本` 中移除；
- 更新的 Skill 可通过修改表格中的内容；

确保当前 `commands` 文件夹下的技能项与 README.zh-CN.md 文档的 `Commands` 二级标题下的内容保持一致：
- 缺失的 Command 新增到表格和 `安装脚本` 当中；
- 废弃的 Command 移动到 `Commands - 已废弃` 标题下，并在 `安装脚本` 中移除；
- 更新的 Command 可通过修改表格中的内容；

## Step - 3：中英文同步

将 README.zh-CN.md 翻译为英文，同步到 README.md ，以保证相同的目录和内容。

## 许可证

MIT
