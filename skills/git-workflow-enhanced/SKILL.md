---
name: git-workflow-enhanced
description: Complete Git workflow automation including branch creation, commit message generation, and auto-commit following Conventional Commits specification. Use when the user wants to create feature branches, generate commit messages, or streamline Git operations.
---

# Git Workflow Enhanced

自动化 Git 工作流:智能分支创建 + Conventional Commits 生成 + 自动提交。

## 核心功能

| 功能 | 说明 | 触发语示例 |
|------|------|-----------|
| 分支创建 | 基于变更类型自动创建分支 | "创建分支"、"开始新功能" |
| Commit 生成 | 分析变更生成规范的 commit message | "生成 commit"、"分析变更" |
| 自动提交 | 完成分支创建和提交全流程 | "提交变更"、"完成开发" |

## 工作流程

### 完整工作流 (创建分支 + 生成 message + 提交)

```
Task Progress:
- [ ] Step 1: 分析当前变更
- [ ] Step 2: 确定分支类型和名称
- [ ] Step 3: 创建并切换分支
- [ ] Step 4: 生成 commit message
- [ ] Step 5: 提交变更
```

**执行步骤:**

1. **分析变更**
   ```bash
   git status
   git diff --staged
   git diff
   ```

2. **确定分支类型** (基于变更内容):
   - 新功能 → `feat/`
   - Bug 修复 → `fix/`
   - 文档更新 → `docs/`
   - 代码重构 → `refactor/`
   - 性能优化 → `perf/`
   - 测试相关 → `test/`
   - 构建配置 → `build/`
   - CI 配置 → `ci/`
   - 其他修改 → `chore/`

3. **生成分支名称**
   - 格式: `<type>/<short-description>`
   - 描述使用 kebab-case (小写+连字符)
   - 示例: `feat/add-user-login`, `fix/correct-validation`
   - 保持简短 (3-5 个词)

4. **创建并切换分支**
   ```bash
   git checkout -b <branch-name>
   ```

5. **生成 Commit Message** (遵循 Conventional Commits)
   
   格式:
   ```
   <type>(<scope>): <subject>
   
   <body>
   
   <footer>
   ```

   类型对照表:
   | 类型 | 说明 | 示例 |
   |------|------|------|
   | feat | 新功能 | feat: add user login |
   | fix | 修复 bug | fix: correct validation |
   | docs | 文档更新 | docs: update README |
   | style | 代码格式 | style: format code |
   | refactor | 重构 | refactor: simplify logic |
   | perf | 性能优化 | perf: improve speed |
   | test | 测试相关 | test: add login tests |
   | build | 构建系统 | build: update config |
   | ci | CI 配置 | ci: add actions |
   | chore | 其他修改 | chore: update deps |

   **最佳实践:**
   - subject 保持 50 字符以内
   - 使用动词开头 (add, fix, update, remove)
   - body 说明"做了什么"和"为什么"
   - 破坏性变更以 `BREAKING CHANGE:` 开头

6. **提交变更**
   ```bash
   git add -A
   git commit -m "<commit-message>"
   ```

### 仅创建分支

如果用户只需要创建分支:

1. 分析当前状态或询问分支用途
2. 确定分支类型和名称
3. 执行: `git checkout -b <branch-name>`
4. 确认分支创建成功: `git branch --show-current`

### 仅生成 Commit Message

如果用户已在目标分支:

1. 分析变更: `git diff --staged` 或 `git diff`
2. 确定 commit 类型和影响范围
3. 生成符合规范的 message
4. 显示给用户确认

## 智能分支命名

### 基于变更内容自动推断

分析 `git diff` 输出:

- 添加新路由/接口 → `feat/add-xxx-endpoint`
- 修复错误处理 → `fix/error-handling`
- 更新配置文件 → `chore/update-config`
- 添加测试用例 → `test/add-xxx-tests`
- 重构某个模块 → `refactor/xxx-module`

### 示例

```
变更: 添加了用户登录功能和 JWT 认证
→ 分支: feat/user-login-auth
→ Commit: feat(auth): add user login with JWT authentication

变更: 修复了日期格式化时区问题
→ 分支: fix/date-timezone-format
→ Commit: fix(utils): correct date formatting in timezone conversion

变更: 更新了 Docker 构建配置
→ 分支: chore/docker-build-config
→ Commit: build(docker): optimize multi-stage build configuration
```

## 错误处理

### 分支已存在

```bash
git checkout -b <branch-name> 2>/dev/null || git checkout <branch-name>
```

### 未暂存的变更

提醒用户:
- "检测到未暂存的变更,是否一起提交?"
- 如果确认: `git add -A`
- 如果否: `git add <specific-files>`

### 合并冲突风险

提交前检查:
```bash
git status --short
```

如果有冲突文件,提示用户先解决冲突。

## 输出格式

完成工作流后,显示摘要:

```markdown
## Git 工作流完成 ✅

**分支:** `feat/user-login-auth`
**Commit:** `feat(auth): add user login with JWT authentication`

### 变更摘要
- 添加了登录页面和表单验证
- 实现了 JWT token 生成和验证
- 添加了认证中间件

### 下一步建议
- 推送到远程: `git push origin feat/user-login-auth`
- 创建 PR: `gh pr create`
```

## 注意事项

1. **始终先分析变更** - 不要盲目生成
2. **分支名保持简短** - 3-5 个词,使用 kebab-case
3. **Commit message 全部使用英文** - 符合国际规范
4. **确认后再提交** - 重要操作需要用户确认
5. **处理边界情况** - 分支已存在、未暂存变更等

## 参考资源

- Conventional Commits 规范: https://www.conventionalcommits.org/
- Git 分支命名最佳实践: 保持语义化、一致性
