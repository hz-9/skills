# Reference

## Branch Name Extraction Details

### Extraction Rules from commit message

commit message format: `<type>(<scope>): <subject>`

| Part | Extraction Method | Example |
|------|----------|------|
| type | Word before first `/` | `feat` |
| scope | Content in parentheses (optional) | `auth` |
| subject | Content after `: ` | `add user login with JWT authentication` |

Branch name assembly rules:
1. Use type as prefix
2. If scope exists and is meaningful, it can be included: `type/scope-subject-kebab` or `type/subject-kebab`
3. Convert subject to kebab-case (lowercase + hyphens)
4. Remove meaningless articles (a, an, the)
5. Keep total length under 50 characters, truncate subject if too long

### Complexity Examples

| Commit Message | Branch Name |
|---------------|--------|
| `fix(parser): handle null pointer exception in JSON parser` | `fix/handle-null-pointer-in-json-parser` |
| `feat(api): add pagination support for user list endpoint` | `feat/add-pagination-for-user-list` |
| `refactor(core): extract logging module from main service` | `refactor/extract-logging-module` |
| `chore: update eslint config for typescript strict mode` | `chore/update-eslint-ts-strict` |
| `perf(db): optimize index strategy for order queries` | `perf/optimize-index-for-order-queries` |

### Auto-inference Examples

```
Changes: Added user login feature and JWT authentication
→ Generated message: feat(auth): add user login with JWT authentication
→ Branch: feat/add-user-login-with-jwt-authentication

Changes: Fixed date formatting timezone issue
→ Generated message: fix(utils): correct date formatting in timezone conversion
→ Branch: fix/correct-date-formatting-in-timezone
```

## Error Handling

### Branch Already Exists

```bash
git checkout -b <branch-name> 2>/dev/null || git checkout <branch-name>
```

Also prompt the user that they are on an existing branch.

### No Changes

If `git status` shows no changes, prompt the user: No changes to analyze, cannot generate commit message and branch name.

### Hook Creation Failed

If the `.git/hooks/` directory does not exist (e.g., git repository not initialized), prompt the user to run `git init` first.
