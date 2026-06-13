---
name: git-workflow-enhanced
description: Automate commit message generation via git-commit-helper → branch name extraction → branch creation → prepare-commit-msg hook management. Use when users want to start a new feature, create a branch, or initialize a commit environment.
---

# Git Workflow Enhanced

Automated workflow: commit message generation → branch extraction → branch creation → prepare-commit-msg hook management.

## Workflow

- [ ] Step 1: Call git-commit-helper to get commit message
- [ ] Step 2: Extract branch name from commit message
- [ ] Step 3: Create and switch branch
- [ ] Step 4: Detect prepare-commit-msg hook
- [ ] Step 5: If hook does not exist → auto-create
- [ ] Step 6: If hook exists → determine whether to skip

### Step 1: Call git-commit-helper to get commit message

View current changes:

```bash
git status
```

Analyze changes and generate commit message using [git-commit-helper](../git-commit-helper/SKILL.md). Stage all changes:

```bash
git add -A
```

Example output: `feat(auth): add user login with JWT authentication`

### Step 2: Extract branch name

Extract type + subject from message to form branch name:

```
feat(auth): add user login with JWT authentication
↓ type: feat | scope: auth | subject: add user login with JWT authentication
↓ feat/add-user-login-with-jwt-authentication
```

| Commit Message | Branch Name |
|---------------|--------|
| `feat(auth): add user login` | `feat/add-user-login` |
| `fix(utils): correct date formatting` | `fix/correct-date-formatting` |
| `docs: update API docs` | `docs/update-api-docs` |

### Step 3: Create and switch branch

```bash
git checkout -b <branch-name> 2>/dev/null || git checkout <branch-name>
```

### Step 4: Detect prepare-commit-msg hook

```bash
ls .git/hooks/prepare-commit-msg .husky/prepare-commit-msg 2>/dev/null
```

### Step 5: If not exists → auto-create

Create `.git/hooks/prepare-commit-msg` with the following content:

```bash
#!/bin/sh
COMMIT_MSG_FILE=$1; COMMIT_SOURCE=$2
if [ -z "$COMMIT_SOURCE" ]; then
  GENERATED_MSG=".git/LAST_GENERATED_COMMIT_MSG"
  [ -f "$GENERATED_MSG" ] && cat "$GENERATED_MSG" > "$COMMIT_MSG_FILE" && rm "$GENERATED_MSG"
fi
```

Grant execute permission and save commit message:

```bash
chmod +x .git/hooks/prepare-commit-msg
echo "<commit-message>" > .git/LAST_GENERATED_COMMIT_MSG
```

### Step 6: If exists → determine whether to skip

Read hook content and identify its purpose:

- **git cz only** (commitizen): Contains `exec < /dev/null`, `cz`, `commitizen` → **skip directly, no prompt**
- **Other purposes** → **Ask user**: "A prepare-commit-msg hook already exists. Skip it?"

## Output Summary

After completion, display the summary:

```
✅ Git Workflow Ready

Branch: feat/add-user-login-with-jwt-authentication
Commit: feat(auth): add user login with JWT authentication
Hook: Created / Skipped

Hint: Run git commit to auto-fill the commit message
```

## Advanced Features

- Branch conflict handling, hook management details: See [REFERENCE.md](REFERENCE.md)
