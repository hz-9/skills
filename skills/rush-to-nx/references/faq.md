# FAQ

## Nx command not found

```bash
# When nx is not globally installed, use the pnpm prefix
pnpm nx run-many --target=lint --all
```

## Husky hooks not executing

```bash
# Ensure the prepare script has been run
pnpm prepare    # or pnpm install
# .husky/_ is an internal marker file for husky v9; no manual handling needed
```

## Changesets changelog hash prefix

`@changesets/cli/changelog` (default) produces a `dbece3b:` hash prefix. Switch to `@changesets/changelog-git` to remove the hash and use git log message format.
