# 保护分支处理

## 保护分支列表

dev、stage、staging、prod、master、main

## detached HEAD 检测

当 `git branch --show-current` 返回空时，执行以下步骤推断源头分支：

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

若 `SOURCE_BRANCH` 非空且在保护分支列表中，视为"源自保护分支"，必须创建新功能分支。

若 `SOURCE_BRANCH` 为空（无法推断源头），视为非保护分支处理。
