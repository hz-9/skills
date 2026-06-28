# Branch Name Derivation Rules

## Extraction Rules from Commit Message

Commit message format: `<type>(<scope>): <subject>`

| Part    | Extraction Method     | Example                                  |
| ------- | --------------------- | ---------------------------------------- |
| type    | Word before the first `/` | `feat`                                   |
| scope   | Content inside parentheses (optional) | `auth`                                   |
| subject | Content after colon + space | `add user login with JWT authentication` |

Branch name concatenation rules:

1. Use type as prefix
2. Convert subject to kebab-case (lowercase + hyphens)
3. Remove meaningless articles (a, an, the)
4. Total length limited to 50 characters, truncate subject if too long

## Complexity Examples

| Commit Message                                              | Branch Name                              |
| ----------------------------------------------------------- | ---------------------------------------- |
| `fix(parser): handle null pointer exception in JSON parser` | `fix/handle-null-pointer-in-json-parser` |
| `feat(api): add pagination support for user list endpoint`  | `feat/add-pagination-for-user-list`      |
| `refactor(core): extract logging module from main service`  | `refactor/extract-logging-module`        |
| `chore: update eslint config for typescript strict mode`    | `chore/update-eslint-ts-strict`          |
| `perf(db): optimize index strategy for order queries`       | `perf/optimize-index-for-order-queries`  |

## Auto Inference Examples

``` markdown
Changes: Added user login functionality and JWT authentication
→ Generated message: feat(auth): add user login with JWT authentication
→ Branch: feat/add-user-login-with-jwt-authentication

Changes: Fixed date formatting timezone issue
→ Generated message: fix(utils): correct date formatting in timezone conversion
→ Branch: fix/correct-date-formatting-in-timezone
```
