# Quick Start

```bash
# 1. Analyze the existing Rush project structure
cat rush.json | jq '.projects[] | {packageName, projectFolder}'

# 2. Create new repository and initialize base configuration
mkdir my-repo-nx && cd my-repo-nx
pnpm init
pnpm add -D -w nx @changesets/cli @changesets/changelog-git husky lint-staged prettier

# 3. Copy source code, restructure directories
rsync -av --exclude='node_modules' --exclude='common' --exclude='.git' /path/to/rush-repo/ .
mkdir -p packages
# Restructure Rush's category/package layout into packages/

# 4. Install dependencies and verify
pnpm install
pnpm nx run-many --target=lint --all
```
