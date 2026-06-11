# Rush.js → Nx + Changesets Complete Migration Reference

## Migration Comparison

| Dimension | Before Migration | After Migration |
|-----------|-----------------|----------------|
| Monorepo Tool | Rush.js | Nx |
| Package Manager | Rush built-in pnpm | Native pnpm |
| Workspace Definition | `rush.json` + `common/config/rush/` | `pnpm-workspace.yaml` |
| Task Orchestration | `rush build`, `rush lint` | `nx run-many --target=build` |
| Version Management | `rush change` + `rush version` | Changesets (`pnpm changeset`) |
| Publishing | `rush publish` | Changesets (`pnpm changeset publish`) |
| Git Hooks | `common/git-hooks/` + Rush autoinstaller | `.husky/` |
| Commit Convention | `rush-commitlint` autoinstaller | `commitlint.config.js` + husky |
| Formatting | `rush-prettier` autoinstaller | `.husky/pre-commit` + lint-staged |
| CI/CD | `actions-rush` GitHub Action | `pnpm/action-setup` |

## Suitable Migration Scenarios

- Small number of packages (< 20), simple dependency relationships
- Infrequent version releases
- Team is familiar with pnpm rather than the Rush ecosystem
- No need for Rush-specific features (hotfix branches, version strategies, etc.)

## Migration Steps

### Step 1: Analyze Existing Repository Structure

```bash
# Understand Rush project structure and dependencies
ls -la rush.json
cat rush.json | jq '.projects[] | {packageName, projectFolder}'
```

Key Information:
- How many projects? Which ones need to be published?
- What are the `workspace:*` dependency relationships between projects?
- Are there any custom Rush commands (commitlint, prettier, etc.)?
- How is CI/CD configured?

### Step 2: Initialize Nx Workspace

Create the following files:

**pnpm-workspace.yaml**
```yaml
packages:
  - 'packages/*'
```

**.npmrc**
```ini
registry=https://registry.npmmirror.com/
shamefully-hoist=true
strict-peer-dependencies=false
```

**Root package.json**
```json
{
  "name": "my-repo-nx",
  "private": true,
  "scripts": {
    "nx": "nx",
    "build": "nx run-many --target=build --all",
    "lint": "nx run-many --target=lint --all",
    "format": "prettier --write \"**/*.{js,ts,json,css,md}\"",
    "format:check": "prettier --check \"**/*.{js,ts,json,css,md}\"",
    "prepare": "husky",
    "changeset": "changeset",
    "version": "changeset version",
    "publish": "changeset publish",
    "ci:version": "changeset version && pnpm install --lockfile-only"
  },
  "devDependencies": {
    "@changesets/cli": "^2.27.1",
    "@changesets/changelog-git": "^0.2.1",
    "@commitlint/cli": "^19.2.2",
    "@commitlint/config-conventional": "^19.2.2",
    "@trivago/prettier-plugin-sort-imports": "^4.3.0",
    "eslint": "^8.2.0",
    "husky": "^9.0.11",
    "lint-staged": "^15.2.2",
    "nx": "19.0.0",
    "prettier": "^3.2.5",
    "pretty-quick": "^4.0.0",
    "typescript": "^5.0.0"
  },
  "engines": {
    "node": ">=18.15.0 <19.0.0 || >=20.9.0 <21.0.0"
  },
  "packageManager": "pnpm@8.15.9"
}
```

**nx.json**
```json
{
  "$schema": "./node_modules/nx/schemas/nx-schema.json",
  "defaultBase": "master",
  "targetDefaults": {
    "build": { "dependsOn": ["^build"], "inputs": ["production", "^production"] },
    "lint": { "inputs": ["default", "{workspaceRoot}/.eslintrc*", "{workspaceRoot}/.eslintignore"] }
  },
  "namedInputs": {
    "default": ["{projectRoot}/**/*"],
    "production": ["default"]
  }
}
```

**.changeset/config.json**
```json
{
  "$schema": "https://unpkg.com/@changesets/config@3.0.0/schema.json",
  "changelog": "@changesets/changelog-git",
  "commit": false,
  "fixed": [],
  "linked": [],
  "access": "public",
  "baseBranch": "master",
  "updateInternalDependencies": "patch",
  "ignore": []
}
```

> `@changesets/changelog-git` uses git log messages as the changelog, with a clean format and no hash prefix. If you prefer conventional commit format, you can switch to `@changesets/changelog-gfm`.

### Step 3: Copy Source Packages

```bash
# Copy packages from Rush repository to the new repository (excluding node_modules, Rush cache, and runtime files)
rsync -av --exclude='node_modules' \
  --exclude='common/temp' --exclude='common/autoinstallers' \
  --exclude='.git' --exclude='*.lint.log' \
  --exclude='.DS_Store' \
  /path/to/rush-repo/ /path/to/nx-repo/

# Remove .rush temporary directories
rm -rf packages/*/.rush

# Reorganize directory structure (Rush commonly uses a two-level category/package structure)
mkdir -p packages
mv category-a/package-a packages/package-a
mv category-b/package-b packages/package-b
rm -rf category-a category-b
```

### Step 4: Create project.json for Each Package

```json
{
  "name": "@scope/package-name",
  "$schema": "../../node_modules/nx/schemas/project-schema.json",
  "sourceRoot": "{projectRoot}",
  "projectType": "library",
  "targets": {
    "build": {
      "executor": "nx:run-commands",
      "options": {
        "command": "echo 'No build needed'",
        "cwd": "{projectRoot}"
      }
    },
    "lint": {
      "executor": "nx:run-commands",
      "options": {
        "command": "eslint --fix ./src/**/*.js",
        "cwd": "{projectRoot}"
      }
    }
  },
  "tags": ["scope:package"]
}
```

If a package has internal dependencies, add `implicitDependencies`:
```json
{
  "implicitDependencies": ["@scope/dependency-name"]
}
```

> **Note**: The `lint`/`build` command paths in each package's `package.json` must match the actual directory structure of that package. If a package does not have a `src/` directory, adjust the path accordingly (e.g., `./profile/**/*.js`).

### Step 5: Migrate Git Hooks

Remove the Rush-based `common/git-hooks/` and `common/autoinstallers/`, and create husky hooks:

```bash
# Create .husky/ directory and default hook
npx husky init   # This will automatically add "prepare": "husky" to package.json

# commit-msg hook
cat > .husky/commit-msg << 'EOF'
npx --no -- commitlint --edit $1
EOF

# pre-commit hook
cat > .husky/pre-commit << 'EOF'
npx --no -- lint-staged
EOF

chmod +x .husky/commit-msg .husky/pre-commit
```

`npx husky init` will automatically add the `"prepare": "husky"` script to `package.json`. This ensures husky activates Git hooks every time `pnpm install` is run.

Create `commitlint.config.js`:
```js
module.exports = {
  extends: ['@commitlint/config-conventional'],
  rules: {
    'scope-enum': [2, 'always', ['pkg-a', 'pkg-b', 'all']],
  },
}
```

Create `.lintstagedrc.json`:
```json
{
  "*.{js,jsx,ts,tsx}": ["prettier --write", "eslint --fix"],
  "*.{json,css,md}": ["prettier --write"]
}
```

> **Prettier vs ESLint resolution**: Prettier searches upward from the project root for configuration (root `.prettierrc.js` applies globally), while ESLint searches upward from the file's directory (each package can have its own `eslintrc` configuration).

### Step 6: Update Configuration Files

**Update .gitignore** — Remove Rush entries, add Nx entries:
```
# Rush related (remove)
- common/deploy/
- common/temp/
- **/.rush/temp/

# Nx related (add)
+ .nx/
+ nx-cloud.env
```

**Update .prettierrc.js** — Change Rush autoinstaller paths to npm package names:
```js
// Before migration
plugins: ['./common/autoinstallers/rush-prettier/node_modules/...']

// After migration
plugins: ['@trivago/prettier-plugin-sort-imports']
```

**Update .prettierignore** — Replace Rush paths with Nx paths:
```
# Rush related (remove)
- common/deploy/
- common/temp/
- common/autoinstallers/*/.npmrc
- **/.rush/temp/
- /eslint-config/*/dist
- /eslint-config/*/lib
- /eslint-config/*/temp

# Nx related (add)
+ .nx/
+ /packages/*/dist
+ /packages/*/lib
+ /packages/*/temp
+ .changeset/
```

**Update each package's repository.directory** — Reflect the new directory structure:
```json
// Before migration
"repository": {
  "directory": "category-name/package-name"
}

// After migration
"repository": {
  "directory": "packages/package-name"
}
```

**Preserve non-Rush configuration files** — These files are unrelated to Rush and should not be deleted:
- `.markdownlint.json` — markdown lint configuration
- `.nvmrc` — Node.js version management
- `.editorconfig` — Editor configuration (if present)

**Update .vscode/settings.json** — Remove Rush path references:
```json
// Remove
"eslint.nodePath": "common/autoinstallers/rush-eslint"
```

### Step 7: Update CI/CD

```yaml
# Before migration (Rush)
- name: RushJS Helper
  uses: advancedcsg-open/actions-rush@v1.6.2

# After migration (pnpm + Nx)
- name: Setup pnpm
  uses: pnpm/action-setup@v4
  with:
    version: 8
- name: Install dependencies
  run: pnpm install --frozen-lockfile
- run: pnpm nx run-many --target=build --all
```

### Step 8: Install Dependencies and Verify

```bash
pnpm install
pnpm nx run-many --target=lint --all
pnpm nx run-many --target=build --all
pnpm nx graph
```

> On the first `pnpm install`, the `prepare` script will automatically run `npx husky init` to activate Git hooks and generate a `_` marker file in `.husky/`. This is normal behavior for husky v9 and requires no manual intervention.

## Key Decision Points

### 1. Directory Structure

| Original Rush Structure | Recommended Nx Structure |
|-------------------------|------------------------|
| `eslint-config/eslint-config-airbnb/` | `packages/eslint-config-airbnb/` |
| `apps/web-app/` | `apps/web-app/` |
| `libraries/shared-utils/` | `packages/shared-utils/` |

Rush enforces `projectFolderMinDepth=2`, while Nx has no such restriction. It is recommended to use `packages/` uniformly.

### 2. Release Process

Each release process:

```bash
# 1. Record changes (interactively select version type and changelog)
pnpm changeset

# 2. Execute release
bash scripts/release.sh
```

`release.sh` automatically completes:
1. Record version snapshots of each package
2. Execute `pnpm changeset version` to apply version bumps
3. Update lockfile
4. Detect which packages have version changes
5. git commit (message: `chore: version bump`)
6. Create individual tags for each changed package (format: `@scope/pkg@x.y.z`)
7. `pnpm changeset publish` to npm
8. git push + git push --tags

> **Note**: `release.sh` uses temp files (not `declare -A`) to record version snapshots, ensuring compatibility with macOS default bash.

### 3. Version Strategy

- Package at 0.x.x stage: `feat` → minor, `fix` → patch
- Package at >=1.0.0: `feat` → minor, `fix` → patch, breaking → major
- Changesets `updateInternalDependencies: "patch"` ensures internal consumers get automatic patch bumps
- When a new package generates its first changeset, Changesets will prompt whether to set an initial version

### 4. When This Approach Is Not Suitable

- Hotfix branch management is needed (Rush hotfix)
- Enforcing consistent dependency versions is required (Rush ensureConsistentVersions)
- Extremely large-scale monorepo (> 100 packages)
- Already have a well-established Rush pipeline and the team is familiar with it

## Configuration Checklist

After migration completes, verify each item:

- [ ] `pnpm-workspace.yaml` configured
- [ ] `nx.json` configured
- [ ] `.changeset/config.json` configured
- [ ] Each package has `project.json`
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
- [ ] Non-Rush configuration files preserved (`.markdownlint.json`, `.nvmrc`, etc.)
- [ ] Rush runtime files cleaned up (`*.lint.log`, `.rush/` directory)
- [ ] `rush.json` deleted
- [ ] `common/` directory deleted (confirmed no content that needs to be kept)

## Frequently Asked Questions

### Nx command not found
```bash
# When nx is not globally installed, use the pnpm prefix
pnpm nx run-many --target=lint --all
```

### Husky hooks not executing
```bash
# Ensure the prepare script has been executed
pnpm prepare    # or pnpm install
# .husky/_ is an internal marker file for husky v9, no manual handling needed
```

### Changesets changelog hash prefix
`@changesets/cli/changelog` (default) generates a `dbece3b:` hash prefix. Switching to `@changesets/changelog-git` removes the hash and uses git log message format.
