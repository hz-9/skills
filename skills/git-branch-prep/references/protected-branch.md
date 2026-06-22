# Protected Branch Handling

## Protected Branch List

dev, stage, staging, prod, master, main

## Detached HEAD Detection

When `git branch --show-current` returns empty, execute the following steps to infer the source branch:

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

If `SOURCE_BRANCH` is not empty and is in the protected branch list, it is considered "originating from a protected branch" and a new feature branch must be created.

If `SOURCE_BRANCH` is empty (cannot infer source), treat it as a non-protected branch.
