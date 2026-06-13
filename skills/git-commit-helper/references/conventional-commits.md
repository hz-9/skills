# Conventional Commits 1.0.0

> !!! Important: This document is forked from https://github.com/conventional-commits/conventionalcommits.org

## Summary

The Conventional Commits specification is a lightweight convention on top of commit messages.
It provides a set of simple rules for creating a clear commit history;
which makes it easier to write automated tools on top of.
By describing features, fixes, and breaking changes in commit messages,
this convention works in tandem with SemVer.

The commit message should be structured as follows:

---
```
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]
```
---

The commit message contains the following structural elements to communicate intent to the consumers of your library:

1. **fix:** A commit of the _fix_ type patches a bug in the codebase (this correlates with [`PATCH`](https://semver.org/#summary) in Semantic Versioning).
2. **feat:** A commit of the _feat_ type introduces a new feature to the codebase (this correlates with [`MINOR`](https://semver.org/#summary) in Semantic Versioning).
3. **BREAKING CHANGE:** A commit that includes `BREAKING CHANGE:` in the footer or appends a `!` at the end indicates a breaking change (this correlates with [`MAJOR`](https://semver.org/#summary) in Semantic Versioning).
   A BREAKING CHANGE can be part of commits of any _type_.
4. In addition to `fix:` and `feat:`, other commit _types_ are also allowed, such as `build:`, `chore:`, `ci:`, `docs:`, `style:`, `refactor:`, `perf:`, `test:`, etc., recommended by [@commitlint/config-conventional](https://github.com/conventional-changelog/commitlint/tree/master/%40commitlint/config-conventional) (based on the [Angular convention](https://github.com/angular/angular/blob/22b96b9/CONTRIBUTING.md#-commit-message-guidelines)).

The expected commit messages under the Conventional Commits specification are as follows:

*   Commit messages with `!` and `BREAKING CHANGE:` footer indicate breaking changes
*   In addition to `feat` and `fix`, other types are allowed, such as: `build:`, `chore:`, `ci:`, `docs:`, `style:`, `refactor:`, `perf:`, `test:`, etc.
*   An optional `!` may be appended to the commit message to emphasize a breaking change

## Specification

The key words "MUST", "MUST NOT", "REQUIRED", "SHALL", "SHALL NOT", "SHOULD", "SHOULD NOT", "RECOMMENDED", "MAY", and "OPTIONAL" in this document are to be interpreted as described in [RFC 2119](https://www.ietf.org/rfc/rfc2119.txt).

1. Each commit **MUST** be prefixed with a type, which consists of a noun such as `feat`, `fix`, etc., followed by an optional **scope**, and after the **scope**, **MUST** come a `!` or `:` followed by a space.
2. When a commit introduces a breaking change, `BREAKING CHANGE:` **MUST** be added after the `type/scope` or at the beginning of the `footer`. Breaking changes may be used together with other types.
3. A commit **MUST** provide a description after the type/scope to briefly describe the change. The description starts with a verb in present tense. It **SHOULD NOT** start with a capital letter, and **SHOULD NOT** end with a period (.).
4. After the short description, a longer commit body **MAY** be provided. The body **MUST** start on a new line after the end of the description.
5. The commit body content **MAY** include an explanation of what was changed and why.
6. One or more footers **MAY** be separated by a blank line gap.
7. When a commit includes a `BREAKING CHANGE:` footer or a `!` appended after the type/scope, the footer **MUST** introduce the breaking change.
8. In addition to `feat` and `fix`, other types **MAY** be introduced in commits.
9. Other than BREAKING CHANGE, commit parsers **MAY** ignore other footers set by developers.

## Examples

### Commit message with a `!` indicating a breaking change

```
feat!: send an email to the customer when a product is shipped
```

### Commit message with both `!` and BREAKING CHANGE footer

```
chore!: drop support for Node 6

BREAKING CHANGE: use JavaScript features not available in Node 6.
```

### Commit message without a body

```
docs: correct spelling of CHANGELOG
```

### Commit message with scope

```
feat(lang): add polish language
```

### Commit message with a body for a fix

```
fix: correct minor typos in code

see the issue for details

on typos fixed.

Reviewed-by: Z
Refs #133
```

### Commit message with a BREAKING CHANGE footer

```
feat: allow provided config object to extend other configs

BREAKING CHANGE: `extends` key in config file is now used for extending other config files
```

### Commit message with both `!` and BREAKING CHANGE footer

```
feat!: allow provided config object to extend other configs

BREAKING CHANGE: `extends` key in config file is now used for extending other config files
```

### Commit message with footers

```
feat: allow provided config object to extend other configs

Refs #123, #456
```

## Specification Details

### Types

| Type | Description |
|------|-------------|
| feat | New feature |
| fix | Bug fix |
| docs | Documentation |
| style | Code formatting (does not affect functionality, e.g., spaces, semicolons, etc.) |
| refactor | Refactoring (neither a new feature nor a bug fix) |
| perf | Performance optimization |
| test | Adding tests |
| build | Changes to the build system or external dependencies (e.g., webpack, npm, etc.) |
| ci | Changes to CI configuration or scripts (e.g., Jenkins, Travis CI, GitHub Actions, etc.) |
| chore | Other changes (does not modify src or test files) |
| revert | Rollback a previous commit |

### Scope

Scope is an optional parameter used to specify the location/module affected by the commit change:

```
feat(auth): add user login with JWT authentication
fix(parser): handle null pointer exception
docs(api): update API documentation
```

### Breaking Changes

When a commit includes a breaking change, a `!` must be appended after the type/scope, or `BREAKING CHANGE:` must be included in the footer:

```
feat(auth)!: redesign authentication system
```

or

```
feat(auth): redesign authentication system

BREAKING CHANGE: the authentication API has been completely redesigned
```

### Issue References

Issues can be referenced in the footer:

```
feat: add user login feature

Closes #123
```
