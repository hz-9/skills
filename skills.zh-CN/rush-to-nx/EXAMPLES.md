# Rush.js → Nx 迁移示例

## 示例 1：从空目录开始完整迁移

```bash
# 假设原 Rush 仓库在 ~/projects/lint，包含 3 个包：
#   eslint-config/eslint-config-airbnb/
#   eslint-config/eslint-config-airbnb-ts/
#   prettier-config/prettier-config/

# 1. 创建新仓库
mkdir ~/projects/lint-nx && cd ~/projects/lint-nx
git init
git checkout -b master

# 2. 复制源码
rsync -av --exclude='node_modules' --exclude='common/temp' --exclude='.git' --exclude='common/autoinstallers' ~/projects/lint/ .

# 3. 重组目录
mkdir -p packages
mv eslint-config/eslint-config-airbnb packages/eslint-config-airbnb
mv eslint-config/eslint-config-airbnb-ts packages/eslint-config-airbnb-ts
mv prettier-config/prettier-config packages/prettier-config
rm -rf eslint-config prettier-config

# 4. 删除 Rush 痕迹
rm -rf common rush.json .rush

# 5. 初始化 Nx 配置（使用技能脚本）
# 创建 pnpm-workspace.yaml, nx.json, .changeset/config.json, package.json
# 创建 .husky/ hooks, commitlint.config.js, .lintstagedrc.json

# 6. 更新各包 repository 路径
# 在 packages/*/package.json 中，将 "repository" 指向新仓库

# 7. 创建 project.json（每个包一个）
# 确保 lint/build 命令的路径匹配包的实际目录结构

# 8. 安装并验证
pnpm install
pnpm nx run-many --target=lint --all
pnpm nx run-many --target=build --all
```

## 示例 2：日常发布流程

```bash
# 1. 创建 changeset（交互式）
pnpm changeset
# ? Which packages? → 选择变更的包
# ? Type of change? → major/minor/patch
# ? Summary → 输入 changelog 摘要

# 2. 执行发布
bash scripts/release.sh
```

## 示例 3：更新包内容后的 lint

```bash
# 对所有包执行 lint
pnpm nx run-many --target=lint --all

# 对特定包执行 lint
pnpm nx run-many --target=lint --projects=eslint-config-airbnb

# 影响分析（查看哪些包会受影响）
pnpm nx graph
```
