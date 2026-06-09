# Issue 追踪器：GitHub

该仓库的 Issue 和 PRD 以 GitHub Issue 的形式存在。所有操作使用 `gh` CLI。

## 约定

- **创建 Issue**：`gh issue create --title "..." --body "..."`。多行正文使用 heredoc。
- **读取 Issue**：`gh issue view <number> --comments`，使用 `jq` 过滤评论并同时获取标签。
- **列出 Issue**：`gh issue list --state open --json number,title,body,labels,comments --jq '[.[] | {number, title, body, labels: [.labels[].name], comments: [.comments[].body]}]'` 并配合适当的 `--label` 和 `--state` 过滤条件。
- **评论 Issue**：`gh issue comment <number> --body "..."`
- **添加/移除标签**：`gh issue edit <number> --add-label "..."` / `--remove-label "..."`
- **关闭**：`gh issue close <number> --comment "..."`

从 `git remote -v` 推断仓库——`gh` 在克隆目录内运行时会自动执行此操作。

## 当技能说"发布到 Issue 追踪器"

创建一个 GitHub Issue。

## 当技能说"获取相关的工单"

运行 `gh issue view <number> --comments`。
