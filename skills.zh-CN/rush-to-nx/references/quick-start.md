# 快速开始

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
