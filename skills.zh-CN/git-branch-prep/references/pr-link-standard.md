# PR 链接规范

## 从 git push 输出提取

推送成功后，从 `git push` 输出中提取 PR 创建链接：

```
remote: Create a pull request for 'feat/xxx' on GitHub by visiting:
remote:      https://github.com/org/repo/pull/new/feat/xxx
```

正则匹配 `remote:.*(https://github.com/.*/pull/new/.*)` 提取链接。

## 基于远端地址构建 PR 链接

若无法从 push 输出提取（如未推送或推送失败），可通过 `git remote get-url origin` 获取远端地址，再构建 PR 链接。

### 提取仓库信息

```bash
REMOTE_URL=$(git remote get-url origin)
# 从 git@github.com:hz-9/skills.git 或 https://github.com/hz-9/skills.git 中提取 owner/repo
OWNER_REPO=$(echo "$REMOTE_URL" | sed 's|.*github.com[\/:]||' | sed 's|\.git$||')
```

### 构建 PR 链接

为当前分支 `<branch>` 生成合并分支的 PR 链接, origin 存在以下哪些分支，才显示对应行：

| 合并目标 | PR 链接格式 | 说明 |
|---------|-------------|------|
| dev | `<a href="https://github.com/{OWNER_REPO}/compare/dev...{branch}?expand=1">创建 PR</a>` | 日常开发合入 |
| stage | `<a href="https://github.com/{OWNER_REPO}/compare/stage...{branch}?expand=1">创建 PR</a>` | 预发布环境合入 |
| staging | `<a href="https://github.com/{OWNER_REPO}/compare/staging...{branch}?expand=1">创建 PR</a>` | 预发布环境合入 |
| prod | `<a href="https://github.com/{OWNER_REPO}/compare/prod...{branch}?expand=1">创建 PR</a>` | 生产环境合入 |
| master | `<a href="https://github.com/{OWNER_REPO}/compare/master...{branch}?expand=1">创建 PR</a>` | 生产环境合入 |

> 优先从 `git push` 输出中提取 PR 链接（有上游提示），其次使用此方法构建通用链接。
