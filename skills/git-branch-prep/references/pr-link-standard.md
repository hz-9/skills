# PR Link Standard

## Extract from git push Output

After a successful push, extract the PR creation link from the `git push` output:

```
remote: Create a pull request for 'feat/xxx' on GitHub by visiting:
remote:      https://github.com/org/repo/pull/new/feat/xxx
```

Regex match `remote:.*(https://github.com/.*/pull/new/.*)` to extract the link.

## Build PR Link Based on Remote URL

If the PR link cannot be extracted from the push output (e.g., not pushed or push failed), obtain the remote URL via `git remote get-url origin`, then build the PR link.

### Extract Repository Info

```bash
REMOTE_URL=$(git remote get-url origin)
# Extract owner/repo from git@github.com:hz-9/skills.git or https://github.com/hz-9/skills.git
OWNER_REPO=$(echo "$REMOTE_URL" | sed 's|.*github.com[\/:]||' | sed 's|\.git$||')
```

### Build PR Link

Generate the PR link for the merge branch of the current branch `<branch>`. Only display the corresponding row if the branch exists in origin:

| Merge Target | PR Link Format | Description |
|---------|-------------|------|
| dev | `<a href="https://github.com/{OWNER_REPO}/compare/dev...{branch}?expand=1">Create PR</a>` | Daily development merge |
| stage | `<a href="https://github.com/{OWNER_REPO}/compare/stage...{branch}?expand=1">Create PR</a>` | Pre-release environment merge |
| staging | `<a href="https://github.com/{OWNER_REPO}/compare/staging...{branch}?expand=1">Create PR</a>` | Pre-release environment merge |
| prod | `<a href="https://github.com/{OWNER_REPO}/compare/prod...{branch}?expand=1">Create PR</a>` | Production environment merge |
| master | `<a href="https://github.com/{OWNER_REPO}/compare/master...{branch}?expand=1">Create PR</a>` | Production environment merge |

> Prefer extracting the PR link from the `git push` output (with upstream hints), otherwise use this method to build a universal link.
