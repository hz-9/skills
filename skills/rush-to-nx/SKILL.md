---
name: rush-to-nx
description: Migrate a Rush.js monorepo to Nx + pnpm workspace + Changesets. Use when the user needs to migrate a Rush.js project to the Nx ecosystem, create a new Nx monorepo, or configure a Changesets publishing workflow.
---

# Rush.js → Nx + Changesets Migration

## Overview

Automated migration of a Rush.js monorepo to Nx + pnpm workspace + Changesets: analyze existing structure → initialize Nx configuration → copy source and reorganize directories → create project.json → migrate Git hooks → update CI/CD → verify. Suitable for projects with few packages (<20) and teams seeking to move away from the Rush ecosystem toward standard pnpm+Nx tooling.

## Definitions

- **Rush.js**: Microsoft's monorepo management tool that uses `rush.json` to define project structure, with built-in pnpm and version publishing policies;
- **Nx**: A general-purpose monorepo build system providing task orchestration, caching, and dependency graph analysis;
- **Changesets**: A semantic versioning tool that records change intent via changeset files, automatically bumping versions, generating changelogs, and publishing to npm on execution.

## Prerequisites

- A local Rush.js monorepo repository exists (containing `rush.json`);
- Node.js >= 18.15.0, pnpm >= 8.15.9;
- Write access to the target directory, Git installed and configured;
- To create an Nx + Changesets project from scratch (non-migration), read the detailed steps first and adjust manually.

## Workflow

1. **Analyze** — Read `rush.json`, enumerate project count, `workspace:*` dependencies, and custom Rush commands, then present the analysis to the user;
2. **Initialize** — Create `pnpm-workspace.yaml`, `nx.json`, `.changeset/config.json`, root `package.json`, and `.npmrc` in the new repository, see [Migration Steps](references/migration-steps.md#step-2-initialize-nx-workspace);
3. **Copy Source** — rsync excluding node_modules/Rush cache and reorganize `category/package` into `packages/`, see [Migration Steps](references/migration-steps.md#step-3-copy-source-packages);
4. **Create project.json** — Create an Nx project.json per package with build/lint commands and implicit dependencies, see [Migration Steps](references/migration-steps.md#step-4-create-projectjson-for-each-package);
5. **Migrate Git Hooks** — Create `.husky/commit-msg`, `.husky/pre-commit`, `commitlint.config.js`, and `.lintstagedrc.json`, see [Migration Steps](references/migration-steps.md#step-5-migrate-git-hooks);
6. **Update Configuration** — Update `.gitignore`, `.prettierrc.js`, `.prettierignore`, each package's `repository.directory`, and `.vscode/settings.json`, see [Migration Steps](references/migration-steps.md#step-6-update-configuration-files);
7. **Update CI/CD** — `actions-rush` → `pnpm/action-setup`, see [Migration Steps](references/migration-steps.md#step-7-update-cicd);
8. **Verify** — `pnpm install && pnpm nx run-many --target=build --all`, confirm hooks are active and build passes, see [Migration Steps](references/migration-steps.md#step-8-install-dependencies-and-verify).

## Rules

- Present the plan to the user for confirmation before creating or modifying any configuration files;
- Preserve the user's existing non-Rush configuration files (`.markdownlint.json`, `.nvmrc`, `.editorconfig`, etc.), do not delete them;
- Synchronously update related path references for every file move operation;
- Build the new repository structure in a temporary directory first, apply to the target directory only after verification.

## Examples

### Dialogue Interaction Example

**Example: AI guides the user through a Rush → Nx migration**

```
User > Help me migrate this Rush project to Nx

AI > Triggering rush-to-nx migration skill.

First, analyzing existing structure...
rush.json contains 3 projects:
- eslint-config/eslint-config-airbnb
- eslint-config/eslint-config-airbnb-ts
- prettier-config/prettier-config

Dependencies:
- eslint-config-airbnb-ts → eslint-config-airbnb (workspace:*)
- No custom Rush commands

Suggested directory structure:
- packages/eslint-config-airbnb
- packages/eslint-config-airbnb-ts
- packages/prettier-config

Proceed with this plan?

User > Proceed

AI > Creating Nx workspace base configuration...
Created pnpm-workspace.yaml, nx.json, .changeset/config.json, package.json, .npmrc

Copying source code to new repository...
All packages copied to packages/, Rush runtime files cleaned up

Creating project.json for each package...
eslint-config-airbnb: library, lint+build targets ✓
eslint-config-airbnb-ts: library, implicitDependencies=[eslint-config-airbnb] ✓
prettier-config: library, lint target ✓

Migrating Git hooks...
.husky/commit-msg ✓, .husky/pre-commit ✓, commitlint.config.js ✓

Updating configuration files...
.gitignore, .prettierrc.js, .prettierignore updated ✓

Running verification...
pnpm install ✓
pnpm nx run-many --target=build --all ✓

Migration complete! All 3 packages migrated to Nx + pnpm workspace.
```

### Execution Success Example

| Dimension | Description |
|-----------|-------------|
| Project count | 3 (2 eslint-config + 1 prettier-config) |
| Internal dependencies | 1 (workspace:* → converted to standard version) |
| New files created | 5 (pnpm-workspace.yaml, nx.json, .changeset/config.json, package.json, .npmrc) |
| Package configs | 3 project.json |
| Git hooks | commit-msg + pre-commit |
| CI/CD | Migrated from actions-rush to pnpm/action-setup |
| Verification result | pnpm install ✓, build ✓ |

## Review List

- [ ] All packages reorganized from Rush structure to `packages/` flat layout
- [ ] `pnpm-workspace.yaml`, `nx.json`, `.changeset/config.json` created
- [ ] Each package has a `project.json` with `implicitDependencies` declared for internal deps
- [ ] Git hooks (`.husky/commit-msg`, `.husky/pre-commit`) are active
- [ ] CI/CD config updated from `actions-rush` to `pnpm/action-setup`
- [ ] Rush runtime files (`rush.json`, `common/`, `.rush/`, `*.lint.log`) cleaned up
- [ ] Non-Rush config files preserved (`.markdownlint.json`, `.nvmrc`, etc.)
- [ ] `pnpm install && pnpm nx run-many --target=build --all` passes

## References

- [Quick Start](references/quick-start.md) — One-liner command overview
- [Migration Steps](references/migration-steps.md) — Detailed 8-step instructions from analysis to verification
- [Key Decisions & Configuration Checklist](references/configuration.md) — Directory structure, release workflow, version strategy, post-migration checklist
- [FAQ](references/faq.md) — Nx command not found, Husky hooks not executing, Changesets hash prefix
- [Migration Examples](EXAMPLES.md) — Complete hands-on migration starting from an empty directory
- [Release Script](scripts/release.sh) — Shell script for automatic bump, commit, tag, and publish
