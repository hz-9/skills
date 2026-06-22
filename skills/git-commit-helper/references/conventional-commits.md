# Conventional Commits 1.0.0

> !!! Important: This document is forked from https://github.com/conventional-commits/conventionalcommits.org

## Summary

The Conventional Commits specification is a lightweight convention on top of commit messages.
It provides an easy set of rules for creating an explicit commit history;
which makes it easier to write automated tools on top of.
This convention dovetails with SemVer,
by describing the features, fixes, and breaking changes made in commit messages.

The commit message should be structured as follows:

---
```
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]
```
---

The commit contains the following structural elements, to communicate intent to the
consumers of your library:

1. **fix:** a commit of the _type_ `fix` patches a bug in your codebase (this correlates with [`PATCH`](https://semver.org/#summary) in semantic versioning).
2. **feat:** a commit of the _type_ `feat` introduces a new feature to the codebase (this correlates with [`MINOR`](https://semver.org/#summary) in semantic versioning).
3. **BREAKING CHANGE:** a commit that has a footer `BREAKING CHANGE:`, or appends `!` after the type/scope, introduces a breaking API change (correlating with [`MAJOR`](https://semver.org/#summary) in semantic versioning).
   A BREAKING CHANGE can be part of commits of any _type_.
4. Types other than `fix:` and `feat:` are allowed, for example [@commitlint/config-conventional](https://github.com/conventional-changelog/commitlint/tree/master/%40commitlint/config-conventional) (based on the [Angular convention](https://github.com/angular/angular/blob/22b96b9/CONTRIBUTING.md#-commit-message-guidelines)) recommends `build:`, `chore:`, `ci:`, `docs:`, `style:`, `refactor:`, `perf:`, `test:`, and others.

We also recommend `improvement` for commits that improve a current implementation without adding a new feature or fixing a bug.
Notice this type is not part of the Conventional Commits specification and is not automatically implied by conventional commits.

We encourage the use of `improvement` as a type for commits that enhance or refine an existing implementation without introducing a new feature or fixing a bug. Note that this type is not part of the official Conventional Commits specification and should not be considered automatically implied.

The Conventional Commits specification expects the following commit messages:

*   With the `!` and `BREAKING CHANGE:` footer, the commit introduces a breaking change
*   Types other than `feat` and `fix` are allowed, e.g., `build:`, `chore:`, `ci:`, `docs:`, `style:`, `refactor:`, `perf:`, `test:`, etc.
*   The optional `!` is appended after the type/scope to emphasize a breaking change

## Specification

The key words "MUST", "MUST NOT", "REQUIRED", "SHALL", "SHALL NOT", "SHOULD", "SHOULD NOT", "RECOMMENDED", "MAY", and "OPTIONAL" in this document are to be interpreted as described in [RFC 2119](https://www.ietf.org/rfc/rfc2119.txt).

1. Each commit MUST use a type (a noun), such as `feat`, `fix`, etc., followed by an optional scope, which MUST be followed by a `!` or `:` and a space.
2. When a commit introduces a breaking change, it MUST include `BREAKING CHANGE:` at the beginning of the footer or append `!` after the type/scope. A breaking change can be part of commits of any type.
3. After the type/scope, a commit MUST provide a description briefly describing the change. The description starts with a verb in present tense. It SHOULD NOT start with a capital letter and SHOULD NOT end with a period (.).
4. After the short description, a longer commit body MAY be provided. The body MUST start on a new line after the description.
5. The commit body MAY contain an explanation of what changed and why.
6. A gap of one or more blank lines MAY be included between footers.
7. When a commit contains `BREAKING CHANGE:` in the footer or appends `!` after the type/scope, the footer MUST introduce a breaking change.
8. Types other than `feat` and `fix` MAY be used in commits.
9. Apart from BREAKING CHANGE, commit parsers MAY ignore other footers defined by developers.

## Examples

### Commit message with description and breaking change footer

```
feat!: send an email to the customer when a product is shipped
```

### Commit message with `!` and BREAKING CHANGE footer

```
chore!: drop support for Node 6

BREAKING CHANGE: use JavaScript features not available in Node 6.
```

### Commit message with no body

```
docs: correct spelling of CHANGELOG
```

### Commit message with scope

```
feat(lang): add polish language
```

### Commit message with body for fix

```
fix: correct minor typos in code

see the issue for details

on typos fixed.

Reviewed-by: Z
Refs #133
```

### Commit message with breaking change footer

```
feat: allow provided config object to extend other configs

BREAKING CHANGE: `extends` key in config file is now used for extending other config files
```

### Commit message with `!` and breaking change footer

```
feat!: allow provided config object to extend other configs

BREAKING CHANGE: `extends` key in config file is now used for extending other config files
```

### Commit message with footer

```
feat: allow provided config object to extend other configs

Refs #123, #456
```

## Specification Details

### Types

| Type | Description |
|------|-------------|
| feat | A new feature |
| fix | A bug fix |
| docs | Documentation only changes |
| style | Code style changes (does not affect functionality, e.g., whitespace, semicolons) |
| refactor | A code change that neither fixes a bug nor adds a feature |
| perf | A code change that improves performance |
| test | Adding or correcting tests |
| build | Changes that affect the build system or external dependencies (e.g., webpack, npm) |
| ci | Changes to CI configuration files and scripts (e.g., Jenkins, Travis CI, GitHub Actions) |
| chore | Other changes that don't modify src or test files |
| revert | Reverts a previous commit |

### Scope

Scope is an optional parameter specifying the location/module affected by the commit:

```
feat(auth): add user login with JWT authentication
fix(parser): handle null pointer exception
docs(api): update API documentation
```

### Breaking Changes

When a commit introduces a breaking change, `!` must be added after the type/scope or `BREAKING CHANGE:` must be included in the footer:

```
feat(auth)!: redesign authentication system
```

or

```
feat(auth): redesign authentication system

BREAKING CHANGE: the authentication API has been completely redesigned
```

### Associated Issues

Issues can be associated in the footer:

```
feat: add user login feature

Closes #123
```
