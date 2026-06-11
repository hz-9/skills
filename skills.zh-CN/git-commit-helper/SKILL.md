---
name: git-commit-helper
description: 遵循 Conventional Commits 规范生成 Git commit message。当用户请求帮助编写 commit message、查看暂存变更、生成 PR 描述，或提及 "commit" 或 "commit message" 时使用。
---

# Git Commit Helper

智能生成 Git commit message，遵循 Conventional Commits 规范。生成的提示词，全部使用英文。

## 使用方式

| 触发语 | 说明 |
|--------|------|
| `帮我生成 commit message` | 基础使用 |
| `分析变更，生成 commit message` | 详细分析 |
| `为这次变更生成 PR 描述` | PR 描述 |

## Commit 类型

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
| revert | 回滚 | revert: revert feature |

## Commit Message 格式

```
<type>(<scope>): <subject>

<body>

<footer>
```

### 示例

**简短版本:**
```
feat: add user login feature
```

**详细版本:**
```
feat(auth): add user login feature

- Add login page with email/password form
- Implement JWT authentication
- Add login API endpoint

Closes #123
```

## PR 描述格式

```markdown
## Pull Request

### 变更概述
[一句话描述]

### 变更内容
- ✅ [具体变更 1]
- ✅ [具体变更 2]

### 测试计划
- [ ] [测试项 1]
- [ ] [测试项 2]

### 相关 Issue
Closes #xxx
```

## 最佳实践

- subject 保持在 50 字符以内
- 使用动词开头（add, fix, update, remove）
- body 说明"做了什么"和"为什么"
- 破坏性变更以 `BREAKING CHANGE:` 开头
- 关联相关 Issue

## 工作流程

1. 执行 `git diff --staged` 或 `git diff` 查看变更
2. 分析变更类型和影响范围
3. 根据 Conventional Commits 规范生成 commit message
4. 如有破坏性变更，添加 `BREAKING CHANGE:` 说明
5. 自动关联相关 Issue（如有）
