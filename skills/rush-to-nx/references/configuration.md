# Key Decisions & Configuration Checklist

## 1. Directory Structure

| Original Rush Structure | Suggested Nx Structure |
|---|---|
| `eslint-config/eslint-config-airbnb/` | `packages/eslint-config-airbnb/` |
| `apps/web-app/` | `apps/web-app/` |
| `libraries/shared-utils/` | `packages/shared-utils/` |

Rush enforces `projectFolderMinDepth=2`, Nx has no such restriction. A flat `packages/` layout is recommended.

## 2. Publishing Workflow

Each release workflow:

```bash
# 1. Record changes (interactive version type and changelog selection)
pnpm changeset

# 2. Execute release
bash scripts/release.sh
```

`release.sh` automatically:
1. Record current version snapshot for each package
2. Run `pnpm changeset version` to apply version bumps
3. Update lockfile
4. Detect which packages have version changes
5. git commit (message: `chore: version bump`)
6. Create independent tags for each changed package (format: `@scope/pkg@x.y.z`)
7. `pnpm changeset publish` to publish to npm
8. git push + git push --tags

> **Note**: `release.sh` uses temp files (not `declare -A`) for version snapshots, compatible with macOS default bash.

## 3. Version Strategy

- Packages at 0.x.x stage: `feat` → minor, `fix` → patch
- Packages at >=1.0.0: `feat` → minor, `fix` → patch, breaking → major
- Changesets `updateInternalDependencies: "patch"` ensures internal consumers auto patch bump
- When adding a new package's first changeset, Changesets will ask if you want to set an initial version

## 4. When This Approach Is Not Suitable

- Hotfix branch management needed (Rush hotfix)
- Enforced dependency version consistency needed (Rush ensureConsistentVersions)
- Very large monorepo (> 100 packages)
- Stable Rush pipeline already in place and team is familiar with it

## Configuration Checklist

After migration, verify item by item:

- [ ] `pnpm-workspace.yaml` configured
- [ ] `nx.json` configured
- [ ] `.changeset/config.json` configured
- [ ] Each package has `project.json`
- [ ] `.husky/commit-msg` and `.husky/pre-commit` configured
- [ ] `commitlint.config.js` created
- [ ] `.lintstagedrc.json` created
- [ ] `.gitignore` updated (remove Rush, add Nx)
- [ ] `.prettierrc.js` plugin path updated
- [ ] `.prettierignore` updated (remove Rush paths, add Nx paths)
- [ ] `.npmrc` created
- [ ] CI/CD updated (`actions-rush` → `pnpm/action-setup`)
- [ ] `.vscode/settings.json` cleaned
- [ ] Each package's `repository.directory` updated (`category/package` → `packages/package`)
- [ ] Non-Rush config files preserved (`.markdownlint.json`, `.nvmrc`, etc.)
- [ ] Rush runtime files cleaned (`*.lint.log`, `.rush/` directory)
- [ ] `rush.json` deleted
- [ ] `common/` directory deleted (confirm nothing needs to be kept)
