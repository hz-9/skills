# 参考文档

## 分支名称提炼细则

### 从 commit message 提取规则

commit message 格式：`<type>(<scope>): <subject>`

| 部分 | 提取方式 | 示例 |
|------|----------|------|
| type | 第一个 `/` 之前的词 | `feat` |
| scope | 括号内的内容（可选） | `auth` |
| subject | 冒号 + 空格之后的内容 | `add user login with JWT authentication` |

分支名拼接规则：
1. 取 type 作为前缀
2. 如果 scope 存在且有意义，可以加入路径：`type/scope-subject-kebab` 或 `type/subject-kebab`
3. subject 转为 kebab-case（小写 + 连字符）
4. 去掉无意义的冠词（a, an, the）
5. 总长度控制在 50 字符以内，过长则截断 subject

### 复杂度示例

| Commit Message | 分支名 |
|---------------|--------|
| `fix(parser): handle null pointer exception in JSON parser` | `fix/handle-null-pointer-in-json-parser` |
| `feat(api): add pagination support for user list endpoint` | `feat/add-pagination-for-user-list` |
| `refactor(core): extract logging module from main service` | `refactor/extract-logging-module` |
| `chore: update eslint config for typescript strict mode` | `chore/update-eslint-ts-strict` |
| `perf(db): optimize index strategy for order queries` | `perf/optimize-index-for-order-queries` |

### 自动推断示例

```
变更：添加了用户登录功能和 JWT 认证
→ 生成 message：feat(auth): add user login with JWT authentication
→ 分支：feat/add-user-login-with-jwt-authentication

变更：修复了日期格式化时区问题
→ 生成 message：fix(utils): correct date formatting in timezone conversion
→ 分支：fix/correct-date-formatting-in-timezone
```

## 错误处理

### 分支已存在

```bash
git checkout -b <branch-name> 2>/dev/null || git checkout <branch-name>
```

同时提示用户当前在已存在的分支上。

### 未暂存的变更

当存在未暂存变更时，提示用户：
- "检测到未暂存的变更，是否一起提交？"
- 确认 → `git add -A` 后继续
- 否 → `git add <specific-files>` 选择性暂存

### 无效变更

如果 `git diff` 和 `git diff --staged` 都无输出，提示用户：无变更可分析，无法生成 commit message 和分支名。

### Hook 创建失败

如果 `.git/hooks/` 目录不存在（如未初始化 git 仓库），提示用户先执行 `git init`。
