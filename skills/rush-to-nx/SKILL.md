---
name: rush-to-nx
description: 将 Rush.js monorepo 迁移到 Nx + pnpm workspace + Changesets。当用户需要将 Rush.js 项目迁移到 Nx 生态、创建新的 Nx monorepo、或配置 Changesets 发布流程时使用。
---

# Rush.js → Nx + Changesets 迁移技能

## 快速开始

```bash
# 1. 分析现有 Rush 项目结构
cat rush.json | jq '.projects[] | {packageName, projectFolder}'

# 2. 创建新仓库并初始化基础配置
mkdir my-repo-nx && cd my-repo-nx
pnpm init
pnpm add -D -w nx @changesets/cli @changesets/changelog-git husky lint-staged prettier

# 3. 复制源码，重组目录
rsync -av --exclude='node_modules' --exclude='common' --exclude='.git' /path/to/rush-repo/ .
mkdir -p packages
# 将 Rush 的 category/package 结构重组为 packages/

# 4. 安装依赖并验证
pnpm install
pnpm nx run-many --target=lint --all
```

## 工作流程

### 迁移流程（8 步）

1. **分析** — 明确 Rush 项目数量、依赖关系、自定义命令
2. **初始化** — 创建 `pnpm-workspace.yaml`、`nx.json`、`.changeset/config.json`、根 `package.json`
3. **复制源码** — rsync 到新仓库，重组目录为 `packages/`
4. **创建 project.json** — 每个包创建 Nx project.json，注明构建和 lint 命令
5. **迁移 Git hooks** — 创建 `.husky/`（commit-msg + pre-commit）和 `commitlint.config.js`
6. **更新配置** — `.gitignore`、`.prettierrc.js`、`.npmrc`、`.vscode/settings.json`
7. **更新 CI/CD** — `actions-rush` → `pnpm/action-setup`
8. **验证** — `pnpm install && pnpm nx run-many --target=build --all`

### 发布流程

```bash
# 记录变更（交互式）
pnpm changeset

# 执行发布（版本 bump → commit → tag → publish → push）
bash scripts/release.sh
```

## 详细参考

- 完整迁移步骤 + 关键决策点：参见 [REFERENCE.md](REFERENCE.md)
- 发布脚本示例：参见 [scripts/release.sh](scripts/release.sh)
- 完整迁移示例：参见 [EXAMPLES.md](EXAMPLES.md)
