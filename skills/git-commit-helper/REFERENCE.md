# Git Commit Helper Reference

## Usage

| Trigger | Description |
|---------|-------------|
| `Help me generate a commit message` | Basic usage |
| `Analyze changes, generate commit message` | Detailed analysis |

## Commit Types

| Type | Description | Example |
|------|-------------|---------|
| feat | New feature | feat: add user login |
| fix | Bug fix | fix: correct validation |
| docs | Documentation update | docs: update README |
| style | Code formatting | style: format code |
| refactor | Refactoring | refactor: simplify logic |
| perf | Performance optimization | perf: improve speed |
| test | Test related | test: add login tests |
| build | Build system | build: update config |
| ci | CI config | ci: add actions |
| chore | Other changes | chore: update deps |
| revert | Rollback | revert: revert feature |

## Commit Message Format

```
<type>(<scope>): <subject>

<body>

<footer>
```

### Short Version

```
feat: add user login feature
```

### Detailed Version

```
feat(auth): add user login feature

- Add login page with email/password form
- Implement JWT authentication
- Add login API endpoint

Closes #123
```
