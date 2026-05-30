---
name: pnpm-changeset-workflow
description: monorepo 中自动分析变更、创建分支、生成独立 changeset 文件并提交。当用户要求创建分支+changeset、开始新功能并生成变更记录、或需要完成"分支+提交+changeset"全流程时使用。
---

# pnpm Changeset 工作流

自动化 monorepo 中的 Git 分支创建 + Conventional Commits 提交 + pnpm changeset 多包独立文件生成。

## 工作流程

```text
Task Progress:
- [ ] Step 1: 分析当前变更与影响包
- [ ] Step 2: 确定分支类型并创建分支
- [ ] Step 3: 为每个影响包创建独立 changeset 文件
- [ ] Step 4: 生成 commit message 并提交
```

### Step 1: 分析变更

```bash
git status
git diff --staged
git diff
```

收集：变更文件列表、涉及哪些 `packages/*/` 目录、每个包的 `package.json` 中的 `name` 字段。

### Step 2: 创建分支

根据变更内容确定分支类型：

| 变更类型 | 前缀 |
|---------|------|
| 新功能/规则 | `feat/` |
| Bug 修复 | `fix/` |
| 文档更新 | `docs/` |
| 代码重构 | `refactor/` |
| 性能优化 | `perf/` |
| 测试相关 | `test/` |
| 构建/依赖配置 | `build/` |
| CI 配置 | `ci/` |
| 其他 | `chore/` |

分支名格式：`<type>/<short-kebab-description>`（3-5 个词）

### Step 3: 创建 changeset 文件

为每个受影响的包创建独立 `.changeset/<random-name>.md` 文件：

```markdown
---
'@scope/package-name': minor
---

feat: add xxx support for something
```

- 文件名使用随机英文形容词+名词组合（如 `curly-boxes-type.md`）
- Summary 必须使用 conventional commits 前缀（feat/fix/refactor/docs/test 等）
- 版本类型判断：
  - 新增规则/功能 → `minor`
  - Bug 修复 → `patch`
  - 破坏性变更 → `major`

### Step 4: 提交

1. 生成 commit message，格式：

   ```
   <type>: <subject>

   <body (可选，每行 ≤ 100 字符)>
   ```

2. 执行：
   ```bash
   git add -A
   git commit -m "<message>"
   ```

## 注意事项

- **commitlint 约束**：body 每行不得超过 100 字符（`body-max-line-length`），subject 不超过 72 字符
- **changeset 文件名**：必须随机唯一，避免手动命名冲突
- **未暂存变更**：如果 `git diff` 有未暂存内容，提醒用户是否一并提交
- **分支已存在**：如果分支已存在，切换到该分支而非新建
