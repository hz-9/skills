# Protected Branch Handling

## Protected Branch List

dev, stage, staging, prod, master, main

## Detached HEAD Detection

When `git branch --show-current` returns empty, follow the steps below to infer the source branch:

```bash
HEAD_COMMIT=$(git log --oneline -1 --format="%H")
SOURCE_BRANCH=$(git branch -a --contains "$HEAD_COMMIT" \
  | grep -v 'HEAD detached' \
  | grep -v 'HEAD detached at' \
  | head -1 \
  | sed 's/^[ *]*//' \
  | sed 's|^remotes/[^/]*/||' \
  | sed 's|refs/heads/||' \
  | sed 's|refs/remotes/[^/]*/||')
```

If `SOURCE_BRANCH` is non-empty and is in the protected branch list, it is considered "originating from a protected branch" and a new feature branch must be created.

If `SOURCE_BRANCH` is empty (unable to infer the source branch), it is treated as non-protected branch handling.
