---
description: 基于暂存内容创建分支、生成提交信息并推送，最终输出 PR 链接。
---

若检测到 nx + pnpm changeset monorepo（存在 `.changeset/` 目录），使用 SKILL: pnpm-changeset-workflow；否则使用 SKILL: git-workflow-enhanced。
