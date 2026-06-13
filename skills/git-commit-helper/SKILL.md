---
name: git-commit-helper
description: Generate Git commit messages following the Conventional Commits specification. Use when users request help writing commit messages, viewing staged changes, or mentioning "commit" or "commit message".
---

# Skill Name: Git Commit Helper

## Description

Intelligently generate Git commit messages following the Conventional Commits specification. All generated prompts are in English.

## Prerequisites

- Git 2.0+
- Currently in a Git repository directory
- Has staged or unstaged changes

## Workflow

1. Run `git diff --staged` or `git diff` to view changes
2. Analyze the change type and scope
3. Generate commit message following the [Conventional Commits](references/conventional-commits.md) specification
4. Automatically reference related Issues (if any)

## Rules

- Keep subject within 50 characters
- Start with a verb (add, fix, update, remove)
- Body explains "what was done" and "why"
- Breaking changes are marked with `BREAKING CHANGE:` or `!`
- Use English for commit messages
- Keep it concise, do not over-generate content
- Do NOT include CI skip markers such as `[skip ci]`
- Reference related Issues (if any)

## Examples

> User: "Help me generate a commit message"
> AI: Run `git diff --staged` to view changes, then generate:
>
> ```
> feat(auth): add user login feature
>
> - Add login page with email/password form
> - Implement JWT authentication
>
> Closes #123
> ```

> User: "Analyze changes, generate commit message"
> AI: After detailed analysis, generate:
>
> ```
> fix: correct validation error in form submission
>
> - Fix regex pattern for email validation
> - Add proper error handling for empty fields
> ```

## References

- Conventional Commits specification details: see [conventional-commits.md](references/conventional-commits.md)
