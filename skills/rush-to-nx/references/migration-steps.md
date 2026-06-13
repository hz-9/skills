# Migration Steps

## Before / After Comparison

| Dimension | Before | After |
|-----------|--------|-------|
| Monorepo tool | Rush.js | Nx |
| Package manager | Rush's built-in pnpm | Native pnpm |
| Workspace definition | `rush.json` + `common/config/rush/` | `pnpm-workspace.yaml` |
| Task orchestration | `rush build`, `rush lint` | `nx run-many --target=build` |
| Version management | `rush change` + `rush version` | Changesets (`pnpm changeset`) |
| Publishing | `rush publish` | Changesets (`pnpm changeset publish`) |
| Git hooks | `common/git-hooks/` + Rush autoinstaller | `.husky/` |
| Commit conventions | `rush-commitlint` autoinstaller | `commitlint.config.js` + husky |
| Formatting | `rush-prettier` autoinstaller | `.husky/pre-commit` + lint-staged |
| CI/CD | `actions-rush` GitHub Action | `pnpm/action-setup` |

## Suitable Scenarios

- Few packages (< 20) with simple dependency relationships
- Infrequent version releases
- Team is familiar with pnpm rather than the Rush ecosystem
- No need for Rush-specific features (hotfix branches, version policies, etc.)

## Step 1: Analyze Existing Repository Structure

```bash
# Understand Rush project structure and dependencies
ls -la rush.json
cat rush.json | jq '.projects[] | {packageName, projectFolder}'
```

Key information:
- How many projects? Which ones need to be published?
- `workspace:*` dependency relationships between projects?
- Any custom Rush commands (commitlint, prettier, etc.)?
- CI/CD configuration approach?

## Step 2: Initialize Nx Workspace

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

> `@changesets/changelog-git` uses git log messages as changelogs with a clean format and no hash prefix. For conventional commit format, switch to `@changesets/changelog-gfm`.

## Step 3: Copy Source Packages

```bash
# Copy packages from Rush repo to new repo (exclude node_modules, Rush cache, and runtime files)
rsync -av --exclude='node_modules' \
  --exclude='common/temp' --exclude='common/autoinstallers' \
  --exclude='.git' --exclude='*.lint.log' \
  --exclude='.DS_Store' \
  /path/to/rush-repo/ /path/to/nx-repo/

# Remove .rush temp directories
rm -rf packages/*/.rush

# Reorganize directories (Rush typically uses category/package two-level structure)
mkdir -p packages
mv category-a/package-a packages/package-a
mv category-b/package-b packages/package-b
rm -rf category-a category-b
```

## Step 4: Create project.json for Each Package

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

> **Note**: The `lint`/`build` command paths in each package's `package.json` must match the actual directory structure. If a package does not have a `src/` directory, adjust the path accordingly (e.g. `./profile/**/*.js`).

## Step 5: Migrate Git Hooks

Remove Rush's `common/git-hooks/` and `common/autoinstallers/`, create husky hooks:

```bash
# Create .husky/ directory and default hook
npx husky init   # automatically adds "prepare": "husky" to package.json

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

`npx husky init` automatically adds `"prepare": "husky"` to `package.json`. This way, every `pnpm install` will automatically activate Git hooks.

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

> **Prettier vs ESLint Resolution Rules**: Prettier looks up configuration from the project root upward (root `.prettierrc.js` applies globally), while ESLint looks up from the file's directory upward (each package can have its own `eslintrc` configuration).

## Step 6: Update Configuration Files

**Update .gitignore** — remove Rush entries, add Nx entries:
```
# Rush related (remove)
- common/deploy/
- common/temp/
- **/.rush/temp/

# Nx related (add)
+ .nx/
+ nx-cloud.env
```

**Update .prettierrc.js** — change Rush autoinstaller paths to npm package names:
```js
// Before
plugins: ['./common/autoinstallers/rush-prettier/node_modules/...']

// After
plugins: ['@trivago/prettier-plugin-sort-imports']
```

**Update .prettierignore** — replace Rush paths with Nx paths:
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

**Update each package's repository.directory** — reflect the new directory structure:
```json
// Before
"repository": {
  "directory": "category-name/package-name"
}

// After
"repository": {
  "directory": "packages/package-name"
}
```

**Preserve non-Rush configuration files** — these files are unrelated to Rush and should not be deleted:
- `.markdownlint.json` — markdown lint configuration
- `.nvmrc` — Node.js version management
- `.editorconfig` — editor configuration (if present)

**Update .vscode/settings.json** — remove Rush path references:
```json
// Remove
"eslint.nodePath": "common/autoinstallers/rush-eslint"
```

## Step 7: Update CI/CD

```yaml
# Before (Rush)
- name: RushJS Helper
  uses: advancedcsg-open/actions-rush@v1.6.2

# After (pnpm + Nx)
- name: Setup pnpm
  uses: pnpm/action-setup@v4
  with:
    version: 8
- name: Install dependencies
  run: pnpm install --frozen-lockfile
- run: pnpm nx run-many --target=build --all
```

## Step 8: Install Dependencies and Verify

```bash
pnpm install
pnpm nx run-many --target=lint --all
pnpm nx run-many --target=build --all
pnpm nx graph
```

> The first `pnpm install` will automatically run `npx husky init` via the `prepare` script to activate Git hooks, generating a `_` marker file under `.husky/`. This is normal behavior for husky v9 and requires no manual handling.
