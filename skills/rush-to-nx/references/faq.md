# Frequently Asked Questions

## Nx command not found

```bash
# When nx is not installed globally, use the pnpm prefix
pnpm nx run-many --target=lint --all
```

## Husky hooks not executing

```bash
# Ensure the prepare script has been executed
pnpm prepare    # or pnpm install
# .husky/_ is an internal marker file for husky v9, no manual handling needed
```

## Changesets changelog hash prefix

`@changesets/cli/changelog` (default) produces `dbece3b:` hash prefix. Switching to `@changesets/changelog-git` removes the hash and uses git log message format.
