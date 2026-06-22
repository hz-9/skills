# 分支名称提炼规则

## 从 commit message 提取规则

commit message 格式：`<type>(<scope>): <subject>`

| 部分    | 提取方式              | 示例                                     |
| ------- | --------------------- | ---------------------------------------- |
| type    | 第一个 `/` 之前的词   | `feat`                                   |
| scope   | 括号内的内容（可选）  | `auth`                                   |
| subject | 冒号 + 空格之后的内容 | `add user login with JWT authentication` |

分支名拼接规则：

1. 取 type 作为前缀
2. subject 转为 kebab-case（小写 + 连字符）
3. 去掉无意义的冠词（a, an, the）
4. 总长度控制在 50 字符以内，过长则截断 subject

## 复杂度示例

| Commit Message                                              | 分支名                                   |
| ----------------------------------------------------------- | ---------------------------------------- |
| `fix(parser): handle null pointer exception in JSON parser` | `fix/handle-null-pointer-in-json-parser` |
| `feat(api): add pagination support for user list endpoint`  | `feat/add-pagination-for-user-list`      |
| `refactor(core): extract logging module from main service`  | `refactor/extract-logging-module`        |
| `chore: update eslint config for typescript strict mode`    | `chore/update-eslint-ts-strict`          |
| `perf(db): optimize index strategy for order queries`       | `perf/optimize-index-for-order-queries`  |

## 自动推断示例

``` markdown
变更：添加了用户登录功能和 JWT 认证
→ 生成 message：feat(auth): add user login with JWT authentication
→ 分支：feat/add-user-login-with-jwt-authentication

变更：修复了日期格式化时区问题
→ 生成 message：fix(utils): correct date formatting in timezone conversion
→ 分支：fix/correct-date-formatting-in-timezone
```
