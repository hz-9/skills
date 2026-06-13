---
name: git-commit-helper
description: 遵循 Conventional Commits 规范生成 Git commit message。当用户请求帮助编写 commit message、查看暂存变更，或提及 "commit" 或 "commit message" 时使用。
---

# Skill Name: Git Commit Helper

## Description

智能生成遵循 Conventional Commits 规范的 Git commit message。生成的提示词全部使用英文。

## Prerequisites

- Git 2.0+
- 当前在 Git 仓库目录中
- 存在已暂存（staged）或未暂存的变更

## Workflow

1. 执行 `git diff --staged` 或 `git diff` 查看变更
2. 分析变更类型和影响范围
3. 根据 [Conventional Commits](references/conventional-commits.md) 规范生成 commit message
4. 自动关联相关 Issue（如有）

## Rules

- subject 保持在 50 字符以内
- 使用动词开头（add, fix, update, remove）
- body 说明"做了什么"和"为什么"
- 破坏性变更以 `BREAKING CHANGE:` 或 `!` 标记
- 采用英文的提交信息；
- 保持简洁，不过度生成内容
- 禁止包含 `[skip ci]` 等 CI 跳过标记
- 关联相关 Issue（如有）

## Examples

> 用户: "帮我生成 commit message"
> AI: 执行 `git diff --staged` 查看变更后，生成：
>
> ```
> feat(auth): add user login feature
>
> - Add login page with email/password form
> - Implement JWT authentication
>
> Closes #123
> ```

> 用户: "分析变更，生成 commit message"
> AI: 详细分析后生成：
>
> ```
> fix: correct validation error in form submission
>
> - Fix regex pattern for email validation
> - Add proper error handling for empty fields
> ```

## References

- Conventional Commits 规范详情：参见 [conventional-commits.md](references/conventional-commits.md)
