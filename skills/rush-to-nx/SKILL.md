---
name: rush-to-nx
description: Migrate Rush.js monorepo to Nx + pnpm workspace + Changesets. Use when a user needs to migrate a Rush.js project to the Nx ecosystem, create a new Nx monorepo, or configure a Changesets release pipeline.
---

# Rush.js → Nx + Changesets Migration Skill

## Quick Start

```bash
# 1. Analyze existing Rush project structure
cat rush.json | jq '.projects[] | {packageName, projectFolder}'

# 2. Create new repository and initialize base configuration
mkdir my-repo-nx && cd my-repo-nx
pnpm init
pnpm add -D -w nx @changesets/cli @changesets/changelog-git husky lint-staged prettier

# 3. Copy source code, reorganize directory structure
rsync -av --exclude='node_modules' --exclude='common' --exclude='.git' /path/to/rush-repo/ .
mkdir -p packages
# Reorganize Rush's category/package structure into packages/

# 4. Install dependencies and verify
pnpm install
pnpm nx run-many --target=lint --all
```

## Workflow

### Migration Process (8 Steps)

1. **Analyze** — Identify Rush project count, dependency relationships, and custom commands
2. **Initialize** — Create `pnpm-workspace.yaml`, `nx.json`, `.changeset/config.json`, root `package.json`
3. **Copy Source** — rsync to new repository, reorganize directory into `packages/`
4. **Create project.json** — Create Nx project.json for each package, specify build and lint commands
5. **Migrate Git Hooks** — Create `.husky/` (commit-msg + pre-commit) and `commitlint.config.js`
6. **Update Configuration** — `.gitignore`, `.prettierrc.js`, `.npmrc`, `.vscode/settings.json`
7. **Update CI/CD** — `actions-rush` → `pnpm/action-setup`
8. **Verify** — `pnpm install && pnpm nx run-many --target=build --all`

### Release Process

```bash
# Record changes (interactive)
pnpm changeset

# Execute release (version bump → commit → tag → publish → push)
bash scripts/release.sh
```

## Detailed Reference

- Complete migration steps + key decision points: see [REFERENCE.md](REFERENCE.md)
- Release script example: see [scripts/release.sh](scripts/release.sh)
- Complete migration example: see [EXAMPLES.md](EXAMPLES.md)
