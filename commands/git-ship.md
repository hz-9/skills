---
description: Create branches, generate commit messages, and push based on staged content, finally outputting a PR link.
---

## Definition

Protected branches: dev, stage, staging, prod, master

## Step 1: Determine Branch Strategy

1. If currently on a protected branch (including worktree detached HEAD originating from a protected branch):
   - Create a new feature branch based on the staged content

2. If currently on a valid non-protected branch:
   - Generate a new branch name based on the staged content, and prompt the user to choose: commit on the current branch, or create the new branch

## Step 2: Generate Commit Message

Use SKILL: git-commit-helper to generate the commit message, following these rules:

- Use English for the commit message
- Keep it concise, do not over-generate content
- Do NOT include CI skip markers such as `[skip ci]`

## Step 3: Commit

- If an interactive `prepare-commit-msg` hook is detected, ask the user before committing: what the hook does, whether it can be skipped, and how to skip it
- Execute the commit after confirmation

## Step 4: Push

1. If currently on a protected branch: do not push
2. If on a non-protected branch:
   - Check if the local branch is behind the remote; if so, rebase first then push
   - If rebase causes conflicts, pause and notify the user

## Step 5: Generate PR

- After pushing is complete, output the PR link
