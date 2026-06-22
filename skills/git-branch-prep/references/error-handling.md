# Error Handling

## Branch Already Exists

```bash
git checkout -b <branch-name> 2>/dev/null || git checkout <branch-name>
```

Also notify the user that they are currently on an existing branch.

## Invalid Changes

If `git status` shows no changes, notify the user: No changes available for analysis, unable to generate commit message and branch name.

## Rebase Conflict

When the local branch is found to be behind the remote before pushing, execute rebase:

```bash
git fetch origin <branch>
git rebase origin/<branch>
```

If rebase produces conflicts:
- Pause execution
- Inform the user of the conflicting files and conflict content
- Prompt the user to resolve conflicts manually, then run `git rebase --continue`, and push again
