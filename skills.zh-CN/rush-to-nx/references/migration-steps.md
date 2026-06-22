# 迁移步骤

## 迁移前后对比

| 维度 | 迁移前 | 迁移后 |
|------|--------|--------|
| Monorepo 工具 | Rush.js | Nx |
| 包管理器 | Rush 内置 pnpm | 原生 pnpm |
| 工作空间定义 | `rush.json` + `common/config/rush/` | `pnpm-workspace.yaml` |
| 任务编排 | `rush build`, `rush lint` | `nx run-many --target=build` |
| 版本管理 | `rush change` + `rush version` | Changesets (`pnpm changeset`) |
| 发布 | `rush publish` | Changesets (`pnpm changeset publish`) |
| Git hooks | `common/git-hooks/` + Rush autoinstaller | `.husky/` |
| 提交规范 | `rush-commitlint` autoinstaller | `commitlint.config.js` + husky |
| 格式化 | `rush-prettier` autoinstaller | `.husky/pre-commit` + lint-staged |
| CI/CD | `actions-rush` GitHub Action | `pnpm/action-setup` |

## 适合迁移的场景

- 包数量不多（< 20），依赖关系简单
- 版本发布不频繁
- 团队熟悉 pnpm 而非 Rush 生态
- 不需要 Rush 特有功能（hotfix 分支、版本策略等）

## 第 1 步：分析现有仓库结构

```bash
# 了解 Rush 项目结构和依赖关系
ls -la rush.json
cat rush.json | jq '.projects[] | {packageName, projectFolder}'
```

关键信息：
- 有多少个项目？哪些需要发布？
- 项目间的 `workspace:*` 依赖关系？
- 有无自定义 Rush 命令（commitlint、prettier 等）？
- CI/CD 配置方式？

## 第 2 步：初始化 Nx workspace

创建以下文件：

**pnpm-workspace.yaml**
```yaml
packages:
  - 'packages/*'
```

**.npmrc**
```ini
registry=https://registry.npmmirror.com/
shamefully-hoist=true
strict-peer-dependencies=false
```

**根 package.json**
```json
{
  "name": "my-repo-nx",
  "private": true,
  "scripts": {
    "nx": "nx",
    "build": "nx run-many --target=build --all",
    "lint": "nx run-many --target=lint --all",
    "format": "prettier --write \"**/*.{js,ts,json,css,md}\"",
    "format:check": "prettier --check \"**/*.{js,ts,json,css,md}\"",
    "prepare": "husky",
    "changeset": "changeset",
    "version": "changeset version",
    "publish": "changeset publish",
    "ci:version": "changeset version && pnpm install --lockfile-only"
  },
  "devDependencies": {
    "@changesets/cli": "^2.27.1",
    "@changesets/changelog-git": "^0.2.1",
    "@commitlint/cli": "^19.2.2",
    "@commitlint/config-conventional": "^19.2.2",
    "@trivago/prettier-plugin-sort-imports": "^4.3.0",
    "eslint": "^8.2.0",
    "husky": "^9.0.11",
    "lint-staged": "^15.2.2",
    "nx": "19.0.0",
    "prettier": "^3.2.5",
    "pretty-quick": "^4.0.0",
    "typescript": "^5.0.0"
  },
  "engines": {
    "node": ">=18.15.0 <19.0.0 || >=20.9.0 <21.0.0"
  },
  "packageManager": "pnpm@8.15.9"
}
```

**nx.json**
```json
{
  "$schema": "./node_modules/nx/schemas/nx-schema.json",
  "defaultBase": "master",
  "targetDefaults": {
    "build": { "dependsOn": ["^build"], "inputs": ["production", "^production"] },
    "lint": { "inputs": ["default", "{workspaceRoot}/.eslintrc*", "{workspaceRoot}/.eslintignore"] }
  },
  "namedInputs": {
    "default": ["{projectRoot}/**/*"],
    "production": ["default"]
  }
}
```

**.changeset/config.json**
```json
{
  "$schema": "https://unpkg.com/@changesets/config@3.0.0/schema.json",
  "changelog": "@changesets/changelog-git",
  "commit": false,
  "fixed": [],
  "linked": [],
  "access": "public",
  "baseBranch": "master",
  "updateInternalDependencies": "patch",
  "ignore": []
}
```

> `@changesets/changelog-git` 使用 git log 消息作为 changelog，格式简洁无 hash 前缀。如需 conventional commit 格式，可改用 `@changesets/changelog-gfm`。

## 第 3 步：复制源码包

```bash
# 从 Rush 仓库复制包到新仓库（排除 node_modules、Rush 缓存和运行时文件）
rsync -av --exclude='node_modules' \
  --exclude='common/temp' --exclude='common/autoinstallers' \
  --exclude='.git' --exclude='*.lint.log' \
  --exclude='.DS_Store' \
  /path/to/rush-repo/ /path/to/nx-repo/

# 删除 .rush 临时目录
rm -rf packages/*/.rush

# 重组目录（Rush 常用 category/package 两层结构）
mkdir -p packages
mv category-a/package-a packages/package-a
mv category-b/package-b packages/package-b
rm -rf category-a category-b
```

## 第 4 步：为每个包创建 project.json

```json
{
  "name": "@scope/package-name",
  "$schema": "../../node_modules/nx/schemas/project-schema.json",
  "sourceRoot": "{projectRoot}",
  "projectType": "library",
  "targets": {
    "build": {
      "executor": "nx:run-commands",
      "options": {
        "command": "echo 'No build needed'",
        "cwd": "{projectRoot}"
      }
    },
    "lint": {
      "executor": "nx:run-commands",
      "options": {
        "command": "eslint --fix ./src/**/*.js",
        "cwd": "{projectRoot}"
      }
    }
  },
  "tags": ["scope:package"]
}
```

如果包有内部依赖，添加 `implicitDependencies`：
```json
{
  "implicitDependencies": ["@scope/dependency-name"]
}
```

> **注意**：每个包的 `package.json` 中的 `lint`/`build` 命令路径必须与包的实际目录结构一致。如果包没有 `src/` 目录，请相应调整路径（如 `./profile/**/*.js`）。

## 第 5 步：迁移 Git hooks

移除以 Rush 的 `common/git-hooks/` 和 `common/autoinstallers/`，创建 husky hooks：

```bash
# 创建 .husky/ 目录和默认 hook
npx husky init   # 会自动在 package.json 添加 "prepare": "husky"

# commit-msg hook
cat > .husky/commit-msg << 'EOF'
npx --no -- commitlint --edit $1
EOF

# pre-commit hook
cat > .husky/pre-commit << 'EOF'
npx --no -- lint-staged
EOF

chmod +x .husky/commit-msg .husky/pre-commit
```

`npx husky init` 会自动在 `package.json` 中添加 `"prepare": "husky"` 脚本。这样每次 `pnpm install` 时，husky 会自动激活 Git hooks。

创建 `commitlint.config.js`：
```js
module.exports = {
  extends: ['@commitlint/config-conventional'],
  rules: {
    'scope-enum': [2, 'always', ['pkg-a', 'pkg-b', 'all']],
  },
}
```

创建 `.lintstagedrc.json`：
```json
{
  "*.{js,jsx,ts,tsx}": ["prettier --write", "eslint --fix"],
  "*.{json,css,md}": ["prettier --write"]
}
```

> **Prettier vs ESLint 解析规则**：Prettier 从项目根目录向上查找配置（根 `.prettierrc.js` 生效于全局），而 ESLint 从文件所在目录向上查找（每个包可以有自己的 `eslintrc` 配置）。

## 第 6 步：更新配置文件

**更新 .gitignore** — 移除 Rush 条目，添加 Nx 条目：
```
# Rush 相关（移除）
- common/deploy/
- common/temp/
- **/.rush/temp/

# Nx 相关（添加）
+ .nx/
+ nx-cloud.env
```

**更新 .prettierrc.js** — 将 Rush autoinstaller 路径改为 npm 包名：
```js
// 迁移前
plugins: ['./common/autoinstallers/rush-prettier/node_modules/...']

// 迁移后
plugins: ['@trivago/prettier-plugin-sort-imports']
```

**更新 .prettierignore** — 替换 Rush 路径为 Nx 路径：
```
# Rush 相关（移除）
- common/deploy/
- common/temp/
- common/autoinstallers/*/.npmrc
- **/.rush/temp/
- /eslint-config/*/dist
- /eslint-config/*/lib
- /eslint-config/*/temp

# Nx 相关（添加）
+ .nx/
+ /packages/*/dist
+ /packages/*/lib
+ /packages/*/temp
+ .changeset/
```

**更新各包 repository.directory** — 反映新的目录结构：
```json
// 迁移前
"repository": {
  "directory": "category-name/package-name"
}

// 迁移后
"repository": {
  "directory": "packages/package-name"
}
```

**保留非 Rush 配置文件** — 这些文件与 Rush 无关，无需删除：
- `.markdownlint.json` — markdown lint 配置
- `.nvmrc` — Node.js 版本管理
- `.editorconfig` — 编辑器配置（如存在）

**更新 .vscode/settings.json** — 移除 Rush 路径引用：
```json
// 移除
"eslint.nodePath": "common/autoinstallers/rush-eslint"
```

## 第 7 步：更新 CI/CD

```yaml
# 迁移前 (Rush)
- name: RushJS Helper
  uses: advancedcsg-open/actions-rush@v1.6.2

# 迁移后 (pnpm + Nx)
- name: Setup pnpm
  uses: pnpm/action-setup@v4
  with:
    version: 8
- name: Install dependencies
  run: pnpm install --frozen-lockfile
- run: pnpm nx run-many --target=build --all
```

## 第 8 步：安装依赖并验证

```bash
pnpm install
pnpm nx run-many --target=lint --all
pnpm nx run-many --target=build --all
pnpm nx graph
```

> 第一次 `pnpm install` 时，`prepare` 脚本会自动运行 `npx husky init` 激活 Git hooks，并在 `.husky/` 下生成 `_` 标记文件。这是 husky v9 的正常行为，无需手动处理。
