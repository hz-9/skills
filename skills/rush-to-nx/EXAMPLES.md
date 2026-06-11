# Rush.js → Nx Migration Examples

## Example 1: Full Migration from Scratch

```bash
# Assume original Rush repository is in ~/projects/lint, containing 3 packages:
#   eslint-config/eslint-config-airbnb/
#   eslint-config/eslint-config-airbnb-ts/
#   prettier-config/prettier-config/

# 1. Create new repository
mkdir ~/projects/lint-nx && cd ~/projects/lint-nx
git init
git checkout -b master

# 2. Copy source code
rsync -av --exclude='node_modules' --exclude='common/temp' --exclude='.git' --exclude='common/autoinstallers' ~/projects/lint/ .

# 3. Reorganize directory structure
mkdir -p packages
mv eslint-config/eslint-config-airbnb packages/eslint-config-airbnb
mv eslint-config/eslint-config-airbnb-ts packages/eslint-config-airbnb-ts
mv prettier-config/prettier-config packages/prettier-config
rm -rf eslint-config prettier-config

# 4. Remove Rush artifacts
rm -rf common rush.json .rush

# 5. Initialize Nx configuration (using skill scripts)
# Create pnpm-workspace.yaml, nx.json, .changeset/config.json, package.json
# Create .husky/ hooks, commitlint.config.js, .lintstagedrc.json

# 6. Update each package's repository path
# In packages/*/package.json, point "repository" to the new repository

# 7. Create project.json (one per package)
# Ensure lint/build command paths match the actual package directory structure

# 8. Install and verify
pnpm install
pnpm nx run-many --target=lint --all
pnpm nx run-many --target=build --all
```

## Example 2: Daily Release Process

```bash
# 1. Create changeset (interactive)
pnpm changeset
# ? Which packages? → Select changed packages
# ? Type of change? → major/minor/patch
# ? Summary → Enter changelog summary

# 2. Execute release
bash scripts/release.sh
```

## Example 3: Lint After Updating Package Content

```bash
# Lint all packages
pnpm nx run-many --target=lint --all

# Lint a specific package
pnpm nx run-many --target=lint --projects=eslint-config-airbnb

# Impact analysis (see which packages would be affected)
pnpm nx graph
```
