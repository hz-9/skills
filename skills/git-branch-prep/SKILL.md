---
name: git-branch-prep
description: Invoke git-commit-helper to generate a commit message → derive a branch name → confirm the branch and push via AskUserQuestion → create a PR link. Use when the user wants to start a new feature, create a branch and commit, or needs to complete the full flow of "analyze changes → generate branch name + commit message → generate PR".
---

# Git Branch Prep

## Overview

Invoke [git-commit-helper](../git-commit-helper/SKILL.md) to generate a commit message based on staged changes → derive a branch name → ask the user via AskUserQuestion to confirm branch selection and push intent → execute commit/push → generate a PR link.

## Definitions

- <a id="是否在保护分支上"></a>**On Protected Branch**: Indicates whether the current branch is a protected branch or a detached HEAD originating from a protected branch (see [Protected Branch Handling](references/protected-branch.md)). Determined by step 3.1 during branch status check, used to decide whether to force creation of a new branch.

## Prerequisites

- **Standard Path** (obtain changes via Git):
  - Git 2.0+
  - Currently in a Git repository directory
  - Git changes available for analysis (staged changes, working directory changes, specified commits, or branch ranges)
  - `jq` (JSON processor, required by `scripts/check-env.sh`)

## Workflow

0. **Pre-check** — Ensure the environment is ready;
  0.1 Execute environment check (`bash scripts/check-env.sh`):
    - Check if the script executed successfully:
      - Success -> Parse JSON, check for "error" field:
        - Present -> Report script error (e.g., missing jq dependency), terminate flow;
        - Absent -> Report each check result:
      - "in-git-repo" failed -> Report "Not in a Git repository", terminate flow;
      - "git-version" failed -> Prompt to upgrade Git to 2.0+, terminate flow;
      - "conflict-state" failed -> Report specific conflict type (merge/cherry-pick/revert/rebase), terminate flow;
      - "detached-head" failed -> Proceed to step 0.2 (need to handle detached HEAD);
      - "has-changes" failed -> Inform user there are no changes to analyze, terminate flow;
    - All checks passed (detached-head excepted) -> Proceed to step 1;
  0.2 Handle detached HEAD (only triggered when the script detects detached state):
    - Infer the source branch based on the current commit (see [Protected Branch Handling](references/protected-branch.md#detached-head-detection)):
      - Inference successful -> Switch to that branch (`git checkout <branch>`), after execution proceed to step 1;
      - Inference failed or switch failed -> Report the exception reason, terminate flow;

1. **Generate commit message** — Invoke git-commit-helper to execute the full commit message generation flow;
   1.1 Invoke [git-commit-helper](../git-commit-helper/SKILL.md) to execute its complete workflow:
       - Fully follow all interactive logic and branching decisions within git-commit-helper;
       - **Must not skip any AskUserQuestion interaction steps in git-commit-helper**;
       - If git-commit-helper triggers AskUserQuestion, must block and wait for user selection;
   1.2 Capture the final output of git-commit-helper (commit message and structured log);

2. **Derive branch name** — Follow [Branch Name Derivation Rules](references/branch-name-rules.md), extract the branch name from the commit message;

3. **Ask about branch and push intent** — Confirm user decisions via AskUserQuestion;
   3.1 Check if current branch is [on a protected branch](#是否在保护分支上):
       - Yes -> Provide only option: create new branch `<derived-branch-name>`, record user decision;
       - No -> Provide options via AskUserQuestion:
         - Commit on current branch `<current-branch>` -> Record user decision (when entering 4.1 branch handling, select "keep current branch");
         - Create new branch `<derived-branch-name>` -> Record user decision (when entering 4.1 branch handling, select "create new branch");
   3.2 Ask via AskUserQuestion whether to push:
       - Commit and push, generate PR link -> Record user decision (when entering 4.3 push flow, perform push);
       - Commit locally, generate PR link only -> Record user decision (after 4.2 is executed, skip 4.3, proceed to 4.4 to record PR command);

4. **Execute decisions** — Based on user selections from step 3;
   4.1 Branch handling (based on decision from step 3.1):
       - If creating a new branch -> `git checkout -b <derived-branch-name> 2>/dev/null || git checkout <derived-branch-name>`, after execution proceed to next step;
       - If committing on current branch -> Keep current branch, proceed to next step;
   4.2 Commit:
       - **⚠️ Must use `NO_VERIFY=1` environment variable to skip git hooks; never execute `git commit` without this variable, to prevent pre-commit or prepare-commit-msg hooks from blocking the commit**
       - Execute commit: `NO_VERIFY=1 git commit -m "<message>"`;
       - Verify commit success (`git status --porcelain` to confirm working directory is clean):
         - Success -> Proceed to next step;
         - Failed -> Inform user of the commit failure reason, terminate flow;
   4.3 Push (based on decision from step 3.2, if user chose to push):
       - Check if remote branch exists: `git ls-remote --exit-code origin "<branch>" 2>/dev/null`:
         - Exists (exit code 0) -> Refresh local remote tracking branch: `git fetch origin "<branch>"`, check if local is behind remote: `git rev-list --count HEAD..origin/"<branch>"`:
           - Behind (count > 0) -> Execute rebase: `git rebase origin/"<branch>"` (if conflict, pause and inform user, see [Error Handling](references/error-handling.md));
           - Not behind -> Next step;
         - Does not exist -> Next step;
       - Execute push: `git push -u origin <branch>`;
       - Verify push success:
         - Success -> Extract PR link from output (proceed to 4.4);
         - Failed -> Inform user of push failure reason, record push command in final output log (proceed to 4.4);
   4.4 Record PR information (based on [PR Link Standard](references/pr-link-standard.md)):
       - If push succeeded -> First try to regex-match from push output: `remote:.*(https://github.com/.*/pull/new/.*)` to extract PR link; if output contains no PR link, extract repository info via `git remote get-url origin`, dynamically build PR link based on the actual existing merge target branches in origin (see [PR Link Standard](references/pr-link-standard.md#build-pr-link-based-on-remote-url));
       - If not pushed or push failed -> Extract repository info via `git remote get-url origin`, dynamically build PR link based on the actual existing branches in origin (see [PR Link Standard](references/pr-link-standard.md#build-pr-link-based-on-remote-url)), record together with push command in final output log;

5. **Review check** — Compare against [Review List](#review-list), confirm execution results;
   5.1 Check if Review List has content:
       - No -> Directly proceed to step 6 (output results);
       - Yes -> Next step;
   5.2 Check each item in Review List:
       - All passed -> Proceed to 5.3;
       - Items failed -> Record failed items, terminate flow;
   5.3 Output final information summary (including branch name, commit message, push status, PR link, etc.), proceed to step 6;

6. **Output results** — Output execution summary, inform completion;
   Output structured summary (refer to "Output Example" for specific format), including:
   - Branch name, commit message;
   - Push status;
   - PR link (dynamically generate merge target link based on branches existing in origin);
   - Commands to execute (if any);

## Rules

- Commit messages must be in English, kept concise, without `[skip ci]`;
- Branch naming should reflect the nature of the change (feat/refactor/docs, etc.), avoid generic names (e.g., `new-branch`);
- PR link should first be extracted from `git push` output; if unavailable, build based on remote URL; merge target should be dynamically generated based on the actual existing branches in origin;
- **Commit specification**: Must use `NO_VERIFY=1` environment variable when committing; never use bare `git commit` calls, ensure pre-commit, commit-msg, and other git hooks are skipped;

## Examples

### Dialogue Interaction Examples

**Create New Branch**

```markdown
User> /git-ship

AI > ⏳ Step 1: Generate commit message...
     Calling git-commit-helper to analyze changes...
     [Fully following git-commit-helper's internal interaction flow]
     Final commit message：feat(auth): add user authentication with JWT

     ⏳ Step 2: Derive branch name...
     Branch name：feat/add-user-authentication

     ⏳ Step 3: Ask for decision...
     [AskUserQuestion]
     Q1: Current branch main (protected branch), options:
     - Create new branch feat/add-user-authentication
     Q2: Push?
     - Commit and push, generate PR link
     - Commit locally, generate PR link only

User> Create new branch, commit and push

AI > ✅ Step 4: Execute decisions
     4.1 → Creating new branch feat/add-user-authentication
     4.2 → Commit complete
     4.3 → Pushed to origin/feat/add-user-authentication
     4.4 → PR link extracted
```

**Commit on Current Branch**

```markdown
User> /git-ship

AI > ⏳ Step 1: Generate commit message...
     Current branch：fix/typo-in-readme (non-protected branch)
     Calling git-commit-helper to analyze changes...
     Final commit message：docs: fix typo in README

     ⏳ Step 2: Derive branch name...
     Branch name：docs/fix-typo-in-readme

     ⏳ Step 3: Ask for decision...
     [AskUserQuestion]
     Q1: Current branch fix/typo-in-readme (non-protected branch), options:
     - Commit on current branch fix/typo-in-readme
     - Create new branch docs/fix-typo-in-readme
     Q2: Push?
     - Commit and push, generate PR link
     - Commit locally, generate PR link only

User> Current branch, commit locally

AI > ✅ Step 4: Execute decisions
     4.1 → Keep current branch fix/typo-in-readme
     4.2 → Commit complete
```

**Push**

```markdown
User> /git-ship

AI > ⏳ Step 1: Generate commit message...
     Current branch：feat/update-login (non-protected branch)
     Calling git-commit-helper to analyze changes...
     Final commit message：feat(auth): enhance login validation

     ⏳ Step 2: Derive branch name...
     Branch name：feat/enhance-login-validation

     ⏳ Step 3: Ask for decision...
     [AskUserQuestion]
     Q1: Current branch feat/update-login (non-protected branch), options:
     - Commit on current branch feat/update-login
     - Create new branch feat/enhance-login-validation
     Q2: Push?
     - Commit and push, generate PR link
     - Commit locally, generate PR link only

User> Current branch, commit and push

AI > ✅ Step 4: Execute decisions
     4.1 → Keep current branch feat/update-login
     4.2 → Commit complete
     4.3 → Remote branch exists, syncing then pushing
     4.4 → PR link extracted
```

### Review Check Example

```markdown
AI > Entering review check. Review List contains 10 items, starting verification:

**Commit Message Check**
  - 🟩 commit message conforms to Conventional Commits specification
  - 🟩 Uses English, kept concise

**Branch Name Check**
  - 🟩 Branch name format is correct

**Security Specification Check**
  - 🟩 Protected branch not directly committed to

**PR Link Check**
  - 🟩 PR link correctly generated

(Only representative passing items from each group are shown here; AI will output all 10 check items individually when running)

✅ All passed, proceeding to output results.
```

### Output Example

```markdown
**Summary**
| Item          | Content                                    |
|---------------|--------------------------------------------|
| Branch        | feat/add-user-authentication               |
| Commit        | feat(auth): add user authentication with JWT |
| Push Status   | Pushed / Local                             |
| Push Command  | git push -u origin fix/typo-in-readme / '-'|

**PR**

| Merge Target | PR Link Format | Description |
|--------------|----------------|-------------|
| dev | `<a href="https://github.com/{OWNER_REPO}/compare/dev...{branch}?expand=1">Create PR</a>` | Daily development merge |
| stage | `<a href="https://github.com/{OWNER_REPO}/compare/stage...{branch}?expand=1">Create PR</a>` | Pre-release environment merge |
| master | `<a href="https://github.com/{OWNER_REPO}/compare/master...{branch}?expand=1">Create PR</a>` | Production environment merge |
```

> For the current branch `<branch>`, generate PR links for merge branches. Only display rows for branches that actually exist in origin.

## Review List

- **Commit Message Check**
  - [ ] commit message conforms to Conventional Commits specification
  - [ ] Uses English, kept concise
  - [ ] Does not contain `[skip ci]` or similar CI skip markers
- **Branch Name Check**
  - [ ] Branch name follows `<type>/<kebab-description>` format, length ≤ 50 characters
  - [ ] Reflects the nature of the change (feat/refactor/docs, etc.), avoids generic names
- **Security Specification Check**
  - [ ] Protected branch not directly committed to
- **PR Link Check**
  - [ ] PR link correctly generated (first extracted from push output, otherwise built from remote URL)
  - [ ] PR link covers actual existing merge target branches in origin
- **Interaction Completeness Check**
  - [ ] All user decision points have used AskUserQuestion to block and wait for user selection
  - [ ] Error scenarios all properly handled (branch already exists, invalid changes, rebase conflicts, etc.)
- **Commit Specification Check**
  - [ ] `NO_VERIFY=1` environment variable used when committing

## References

- [Branch Name Derivation Details](references/branch-name-rules.md)
- [Protected Branch Handling](references/protected-branch.md)
- [Error Handling](references/error-handling.md)
- [PR Link Standard](references/pr-link-standard.md)
- Commit message generation: see [git-commit-helper](../git-commit-helper/SKILL.md)
- Conventional Commits specification: see [git-commit-helper/references/conventional-commits.md](../git-commit-helper/references/conventional-commits.md)
