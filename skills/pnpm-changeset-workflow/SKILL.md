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
