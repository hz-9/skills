# Key Decisions & Configuration Checklist

## 1. Directory Structure

| Original Rush Structure | Recommended Nx Structure |
|---|---|
| `eslint-config/eslint-config-airbnb/` | `packages/eslint-config-airbnb/` |
| `apps/web-app/` | `apps/web-app/` |
| `libraries/shared-utils/` | `packages/shared-utils/` |

Rush enforces `projectFolderMinDepth=2`; Nx has no such restriction. It is recommended to use `packages/` uniformly.

## 2. Release Workflow

Release workflow for each release:

```bash
# 1. Record changes (interactively select version type and changelog)
pnpm changeset

# 2. Execute release
bash scripts/release.sh
```

`release.sh` automates:
1. Record the current version snapshot of each package
2. Run `pnpm changeset version` to apply version bumps
3. Update the lockfile
4. Detect which packages have version changes
5. git commit (message: `chore: version bump`)
6. Create individual tags for each changed package (format: `@scope/pkg@x.y.z`)
7. `pnpm changeset publish` to npm
8. git push + git push --tags

> **Note**: `release.sh` uses temp files (not `declare -A`) to record version snapshots, ensuring compatibility with macOS default bash.

## 3. Version Strategy

- Packages in the 0.x.x range: `feat` → minor, `fix` → patch
- Packages >=1.0.0: `feat` → minor, `fix` → patch, breaking → major
- Changesets `updateInternalDependencies: "patch"` ensures internal consumers auto patch bump
- When a new package gets its first changeset, Changesets will ask whether to set an initial version

## 4. When Not to Use This Approach

- Requires hotfix branch management (Rush hotfix)
- Requires enforced dependency version consistency (Rush ensureConsistentVersions)
- Very large monorepo (> 100 packages)
- Already has a stable Rush pipeline and the team is familiar with it

## Configuration Checklist

After migration, verify the following items:

- [ ] `pnpm-workspace.yaml` configured
- [ ] `nx.json` configured
- [ ] `.changeset/config.json` configured
- [ ] Each package has a `project.json`
- [ ] `.husky/commit-msg` and `.husky/pre-commit` configured
- [ ] `commitlint.config.js` created
- [ ] `.lintstagedrc.json` created
- [ ] `.gitignore` updated (remove Rush, add Nx)
- [ ] `.prettierrc.js` plugin paths updated
- [ ] `.prettierignore` updated (remove Rush paths, add Nx paths)
- [ ] `.npmrc` created
- [ ] CI/CD updated (`actions-rush` → `pnpm/action-setup`)
- [ ] `.vscode/settings.json` cleaned up
- [ ] Each package's `repository.directory` updated (`category/package` → `packages/package`)
- [ ] Non-Rush config files preserved (`.markdownlint.json`, `.nvmrc`, etc.)
- [ ] Rush runtime files cleaned up (`*.lint.log`, `.rush/` directories)
- [ ] `rush.json` deleted
- [ ] `common/` directory deleted (confirm no content needs to be preserved)
