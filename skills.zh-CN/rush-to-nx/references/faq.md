# 常见问题

## Nx 命令找不到

```bash
# nx 未全局安装时，使用 pnpm 前缀
pnpm nx run-many --target=lint --all
```

## Husky hooks 不执行

```bash
# 确保 prepare 脚本已执行
pnpm prepare    # 或 pnpm install
# .husky/_ 是 husky v9 的内部标记文件，无需手动处理
```

## Changesets changelog hash 前缀

`@changesets/cli/changelog`（默认）会产生 `dbece3b:` hash 前缀。切换为 `@changesets/changelog-git` 后去除 hash，使用 git log 消息格式。
