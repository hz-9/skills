# 错误处理

## 分支已存在

```bash
git checkout -b <branch-name> 2>/dev/null || git checkout <branch-name>
```

同时提示用户当前在已存在的分支上。

## 无效变更

如果 `git status` 显示无任何变更，提示用户：无变更可分析，无法生成 commit message 和分支名。

## Rebase 冲突

推送前发现本地落后于远端时执行 rebase：

```bash
git fetch origin <branch>
git rebase origin/<branch>
```

若 rebase 产生冲突：
- 暂停执行
- 告知用户冲突文件和冲突内容
- 提示用户手动解决冲突后执行 `git rebase --continue`，然后重新推送
