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
2. subject 转为 kebab-case（小写 + 连字符）
3. 去掉无意义的冠词（a, an, the）
4. 总长度控制在 50 字符以内，过长则截断 subject

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

## 保护分支处理

### 保护分支列表

dev、stage、staging、prod、master

### detached HEAD 检测

当 `git branch --show-current` 返回空时，执行以下步骤推断源头分支：

```bash
HEAD_COMMIT=$(git log --oneline -1 --format="%H")
SOURCE_BRANCH=$(git branch -a --contains "$HEAD_COMMIT" | head -1 | sed 's/.*\///')
```

若 `SOURCE_BRANCH` 在保护分支列表中，视为"源自保护分支"，必须创建新功能分支。

## 错误处理

### 分支已存在

```bash
git checkout -b <branch-name> 2>/dev/null || git checkout <branch-name>
```

同时提示用户当前在已存在的分支上。

### 无效变更

如果 `git status` 显示无任何变更，提示用户：无变更可分析，无法生成 commit message 和分支名。

### Hook 创建失败

如果 `.git/hooks/` 目录不存在（如未初始化 git 仓库），提示用户先执行 `git init`。

### Rebase 冲突

推送前发现本地落后于远端时执行 rebase：

```bash
git fetch origin <branch>
git rebase origin/<branch>
```

若 rebase 产生冲突：
- 暂停执行
- 告知用户冲突文件和冲突内容
- 提示用户手动解决冲突后执行 `git rebase --continue`，然后重新推送

## PR 链接提取

推送成功后，从 `git push` 输出中提取 PR 创建链接：

```
remote: Create a pull request for 'feat/xxx' on GitHub by visiting:
remote:      https://github.com/org/repo/pull/new/feat/xxx
```

正则匹配 `remote:.*(https://github.com/.*/pull/new/.*)` 提取链接。
