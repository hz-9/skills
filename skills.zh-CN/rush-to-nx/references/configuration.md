# 关键决策点与配置清单

## 1. 目录结构

| 原 Rush 结构 | 建议 Nx 结构 |
|---|---|
| `eslint-config/eslint-config-airbnb/` | `packages/eslint-config-airbnb/` |
| `apps/web-app/` | `apps/web-app/` |
| `libraries/shared-utils/` | `packages/shared-utils/` |

Rush 强制 `projectFolderMinDepth=2`，Nx 无此限制。建议统一用 `packages/`。

## 2. 发布流程

每次发布流程：

```bash
# 1. 记录变更（交互式选择版本类型和 changelog）
pnpm changeset

# 2. 执行发布
bash scripts/release.sh
```

`release.sh` 自动完成：
1. 记录当前各包版本快照
2. 执行 `pnpm changeset version` 应用版本 bump
3. 更新 lockfile
4. 检测哪些包版本发生变化
5. git commit（message: `chore: version bump`）
6. 为每个变化的包创建独立 tag（格式：`@scope/pkg@x.y.z`）
7. `pnpm changeset publish` 发布到 npm
8. git push + git push --tags

> **注意**：`release.sh` 中使用 temp 文件（非 `declare -A`）记录版本快照，兼容 macOS 默认 bash。

## 3. 版本策略

- 包在 0.x.x 阶段：`feat` → minor, `fix` → patch
- 包在 >=1.0.0：`feat` → minor, `fix` → patch, breaking → major
- Changesets `updateInternalDependencies: "patch"` 确保内部消费者自动 patch bump
- 新增包首次 changeset 时，Changesets 会询问是否设置初始版本

## 4. 何时不适用此方案

- 需要热修复分支管理（Rush hotfix）
- 需要强制依赖版本一致性（Rush ensureConsistentVersions）
- 超大规模 monorepo（> 100 包）
- 已有稳固的 Rush 流水线且团队熟悉

## 配置清单

迁移完成后，逐项确认：

- [ ] `pnpm-workspace.yaml` 已配置
- [ ] `nx.json` 已配置
- [ ] `.changeset/config.json` 已配置
- [ ] 每个包有 `project.json`
- [ ] `.husky/commit-msg` 和 `.husky/pre-commit` 已配置
- [ ] `commitlint.config.js` 已创建
- [ ] `.lintstagedrc.json` 已创建
- [ ] `.gitignore` 已更新（移除 Rush，添加 Nx）
- [ ] `.prettierrc.js` 插件路径已更新
- [ ] `.prettierignore` 已更新（移除 Rush 路径，添加 Nx 路径）
- [ ] `.npmrc` 已创建
- [ ] CI/CD 已更新（`actions-rush` → `pnpm/action-setup`）
- [ ] `.vscode/settings.json` 已清理
- [ ] 各包 `repository.directory` 已更新（`category/package` → `packages/package`）
- [ ] 非 Rush 配置文件已保留（`.markdownlint.json`, `.nvmrc` 等）
- [ ] Rush 运行时文件已清理（`*.lint.log`, `.rush/` 目录）
- [ ] `rush.json` 已删除
- [ ] `common/` 目录已删除（确认无需要保留的内容）
