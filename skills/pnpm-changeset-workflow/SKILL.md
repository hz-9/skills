---
name: pnpm-changeset-workflow
description: Inherits the full release workflow from git-branch-prep and additionally generates pnpm changeset files based on commit messages. Use when needing to create a branch+changeset, start a new feature and generate change records, or complete the full "branch+commit+changeset" workflow in an nx + changeset monorepo.
---

# pnpm Changeset Workflow

Inherits the full release workflow from [git-branch-prep](../git-branch-prep/SKILL.md), with an additional changeset file generation step. Only applicable to monorepo repositories using nx + pnpm changeset.

## Overview

This skill is an extended version of git-branch-prep. On top of git-branch-prep's complete workflow of branch strategy, commit message generation, branch creation, hook management, and pushing, it additionally generates independent changeset files for each affected package. If not in an nx + changeset repository, use [git-branch-prep](../git-branch-prep/SKILL.md).

## Definitions

- **changeset file**: A Markdown file located in the `.changeset/` directory, describing the package change type and content, used by the changeset release flow to automatically calculate version numbers and generate changelogs
- **Affected packages**: Packages under the `packages/*/` directory that are involved in the current change, determined by `git diff` file paths and the `name` field in each package's `package.json`

## Prerequisites

- Same as [git-branch-prep](../git-branch-prep/SKILL.md) Prerequisites
- Project has pnpm changeset enabled (`.changeset/` directory and `@changesets/cli` exist)
- Project uses nx + changeset monorepo structure

## Workflow

Follows all steps from [git-branch-prep](../git-branch-prep/SKILL.md), inserting the changeset file generation step after its Step 1 (generate commit message), then passing to git-branch-prep's subsequent steps for branch decision, commit, and push.

```text
Task Progress:
- [ ] Step 1: Generate commit message (same as git-branch-prep Step 1)
- [ ] Step 2: Generate changeset file (this skill's extension)
- [ ] Step 3: Commit (including changeset file)
- [ ] Step 4: Refine branch name (same as git-branch-prep Step 2)
- [ ] Step 5: Ask about branch selection and push intent via AskUserQuestion (same as git-branch-prep Step 3)
- [ ] Step 6: Execute decisions and create PR link (same as git-branch-prep Step 4)
```

### Step 1: Base Flow

Execute [git-branch-prep](../git-branch-prep/SKILL.md) Step 1 to generate a commit message.

### Step 2: Generate Changeset File

Based on the commit message generated in Step 1, create independent `.changeset/<random-name>.md` files for each affected package.

#### Analyze Affected Packages

```bash
git diff --staged --name-only
```

Identify `packages/<name>/` directories from the changed file paths, and obtain the `name` field from each package's `package.json`.

#### Version Type Mapping

Map changeset version type based on commit message type:

| Commit Type | Changeset Version | Description |
|------------|---------------|------|
| feat | `minor` | New feature |
| fix | `patch` | Bug fix |
| Contains `BREAKING CHANGE:` or `!` | `major` | Breaking change |
| refactor / perf / docs / test / build / ci / chore | `patch` | Other changes |

#### Generate Changeset File

Create an independent file for each affected package, with a random English adjective+noun combination for the file name (ensuring uniqueness, avoiding manual naming conflicts):

```markdown
---
'@scope/package-name': minor
---

feat: add xxx support for something
```

- Summary uses the subject part of the commit message generated in Step 1
- If multiple packages are affected with different version types, create independent changeset files for each package
- File path: `.changeset/<random-adjective-noun>.md`

### Step 3: Commit (Including Changeset File)

Stage changeset files:

```bash
git add .changeset/
```

### Step 4-6: Branch Decision and Push

Execute [git-branch-prep](../git-branch-prep/SKILL.md) Steps 2 to 4, completing branch name refinement → AskUserQuestion → branch creation → commit (including changeset file) → push → PR link.

> Ensure the changeset file is staged (Step 3 completed) before committing, committing together with business changes.

## Rules

- Follow all Rules of [git-branch-prep](../git-branch-prep/SKILL.md)
- Changeset file names must be randomly unique to avoid manual naming conflicts
- Changeset version type must strictly correspond to the commit message type
- Remind user whether to commit unstaged changes together

## Examples

```
User> /git-ship

AI > Detected nx + changeset monorepo, triggering pnpm-changeset-workflow
     Current branch: main (protected branch)
     Changes:
       packages/auth/src/login.ts
       packages/auth/src/signup.ts
       packages/core/src/config.ts
     
     Affected packages: @scope/auth (feat→minor), @scope/core (feat→minor)
     
     Creating feature branch...

AI > ✅ Workflow complete

     Branch: feat/add-user-authentication
     Commit: feat(auth): add user authentication with JWT
     Changeset:
       .changeset/curly-boxes-type.md → @scope/auth: minor
       .changeset/flat-tigers-run.md → @scope/core: minor
     Pushed to: origin/feat/add-user-authentication
     PR: https://github.com/org/repo/pull/new/feat/...
```

## Review List

- [ ] Follows [git-branch-prep](../git-branch-prep/SKILL.md) Review List
- [ ] Changeset files generated independently for each affected package
- [ ] Version type correctly mapped to commit type
- [ ] Changeset file names are randomly unique

## References

- Base workflow: see [git-branch-prep](../git-branch-prep/SKILL.md)
- Commit message generation: see [git-commit-helper](../git-commit-helper/SKILL.md)
---
name: pnpm-changeset-workflow
description: Automatically analyze changes, create branches, generate independent changeset files, and commit in a monorepo. Use when the user requests branch+changeset creation, starting a new feature with change log generation, or needs to complete the full "branch+commit+changeset" workflow.
---

# pnpm Changeset Workflow

Automate Git branch creation + Conventional Commits + pnpm changeset multi-package independent file generation in a monorepo.

## Workflow

```text
Task Progress:
- [ ] Step 1: Analyze current changes and affected packages
- [ ] Step 2: Determine branch type and create branch
- [ ] Step 3: Create independent changeset files for each affected package
- [ ] Step 4: Generate commit message and commit
```

### Step 1: Analyze Changes

```bash
git status
git diff --staged
git diff
```

Collect: list of changed files, which `packages/*/` directories are involved, and the `name` field in each package's `package.json`.

### Step 2: Create Branch

Determine branch type based on the changes:

| Change Type | Prefix |
|-------------|--------|
| New feature/rule | `feat/` |
| Bug fix | `fix/` |
| Documentation update | `docs/` |
| Code refactoring | `refactor/` |
| Performance improvement | `perf/` |
| Test related | `test/` |
| Build/dependency config | `build/` |
| CI config | `ci/` |
| Other | `chore/` |

Branch name format: `<type>/<short-kebab-description>` (3-5 words)

### Step 3: Create Changeset Files

Create an independent `.changeset/<random-name>.md` file for each affected package:

```markdown
---
'@scope/package-name': minor
---

feat: add xxx support for something
```

- File name uses a random English adjective+noun combination (e.g., `curly-boxes-type.md`)
- Summary must use a conventional commits prefix (feat/fix/refactor/docs/test, etc.)
- Version type determination:
  - New rule/feature → `minor`
  - Bug fix → `patch`
  - Breaking change → `major`

### Step 4: Commit

1. Generate commit message, format:

   ```
   <type>: <subject>

   <body (optional, ≤ 100 characters per line)>
   ```

2. Execute:
   ```bash
   git add -A
   git commit -m "<message>"
   ```

## Notes

- **commitlint constraint**: body lines must not exceed 100 characters (`body-max-line-length`), subject must not exceed 72 characters
- **changeset file name**: must be randomly unique to avoid manual naming conflicts
- **unstaged changes**: if `git diff` shows unstaged content, ask the user whether to include them in the commit
- **branch already exists**: if the branch already exists, switch to it instead of creating a new one
