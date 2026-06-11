---
name: git-commit-helper
description: Generate Git commit messages following the Conventional Commits specification. Use when users request help writing commit messages, viewing staged changes, generating PR descriptions, or mentioning "commit" or "commit message".
---

# Git Commit Helper

Intelligently generate Git commit messages following the Conventional Commits specification. All generated prompts are in English.

## Usage

| Trigger Phrase | Description |
|--------|------|
| `帮我生成 commit message` | Basic usage |
| `分析变更，生成 commit message` | Detailed analysis |
| `为这次变更生成 PR 描述` | PR description |

## Commit Types

| Type | Description | Example |
|------|------|------|
| feat | New Feature | feat: add user login |
| fix | Bug Fix | fix: correct validation |
| docs | Documentation | docs: update README |
| style | Code Style | style: format code |
| refactor | Refactor | refactor: simplify logic |
| perf | Performance | perf: improve speed |
| test | Testing | test: add login tests |
| build | Build System | build: update config |
| ci | CI Configuration | ci: add actions |
| chore | Maintenance | chore: update deps |
| revert | Revert | revert: revert feature |

## Commit Message Format

```
<type>(<scope>): <subject>

<body>

<footer>
```

### Examples

**Short version:**
```
feat: add user login feature
```

**Detailed version:**
```
feat(auth): add user login feature

- Add login page with email/password form
- Implement JWT authentication
- Add login API endpoint

Closes #123
```

## PR Description Format

```markdown
## Pull Request

### Change Summary
[One-line description]

### Changes
- ✅ [Specific change 1]
- ✅ [Specific change 2]

### Test Plan
- [ ] [Test item 1]
- [ ] [Test item 2]

### Related Issues
Closes #xxx
```

## Best Practices

- Keep subject within 50 characters
- Start with a verb (add, fix, update, remove)
- Body explains "what was done" and "why"
- Breaking changes start with `BREAKING CHANGE:`
- Reference related Issues

## Workflow

1. Run `git diff --staged` or `git diff` to view changes
2. Analyze the change type and scope
3. Generate commit message following Conventional Commits specification
4. If there are breaking changes, add `BREAKING CHANGE:` explanation
5. Automatically reference related Issues (if any)
