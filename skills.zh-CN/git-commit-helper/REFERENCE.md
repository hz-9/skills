# Git Commit Helper Reference

## 使用方式

| 触发语 | 说明 |
|--------|------|
| `帮我生成 commit message` | 基础使用 |
| `分析变更，生成 commit message` | 详细分析 |

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

### 简短版本

```
feat: add user login feature
```

### 详细版本

```
feat(auth): add user login feature

- Add login page with email/password form
- Implement JWT authentication
- Add login API endpoint

Closes #123
```
