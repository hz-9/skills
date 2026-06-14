---
name: git-cleanup
description: Clean up stale Git branches and tags, including merged branches, orphan branches, non-version tags, and orphan tags. Use when the user asks to clean up or organize Git branches/tags, discovers leftover local references from deleted remotes, or mentions "cleaning up stale branches/tags".
---

# Git Cleanup

## Overview

Systematically clean up stale branches and tags in a Git repository. Follows a "scan → display → confirm → delete" workflow: first processes local branches and tags, then after a second confirmation, deletes remote references in bulk. An automatic backup is created before execution.

## Definitions

- **Stale Branch**: A branch meeting any of the following conditions:
    - **Merged Branch**: A local branch that has been merged into the main branch;
    - **Orphan Branch**: A local branch whose remote-tracking branch no longer exists after `git fetch -p` (showing `: gone]`);
- **Stale Tag**: A tag meeting any of the following conditions:
    - **Non-version Tag**: A tag that does not match a semantic versioning pattern (e.g., `v1.2.3`, `1.2.3`, `v1.2.3-beta.1`);
    - **Orphan Tag**: A tag pointing to a commit that is not referenced by any local or remote branch;
- **Main Branch**: The primary development branch of the repository (e.g., `main` or `master`), auto-detected by AI and confirmed with the user;
- **Protected Branches**: The main branch and `develop`, automatically skipped and not deletable;
- **Current Checked-out Branch**: The branch pointed to by `HEAD`, automatically skipped and not deletable.

## Prerequisites

- Git 2.0+;
- Currently inside a Git repository (can be verified with `git rev-parse --git-dir`);
- Push access to the remote repository (required for remote deletion).

## Workflow

0. **Preparation** — Verify environment, detect main branch, create backup:
    - Verify if currently inside a Git repository:
        - Yes → proceed;
        - No → report "Not inside a Git repository", terminate the workflow;
    - Auto-detect the main branch (check `refs/heads/main`, `refs/heads/master`, `refs/heads/develop` in order):
        - Found → use AskUserQuestion to provide options (confirm main branch name / manually specify another branch), block and wait for user selection;
        - Not found → use AskUserQuestion to provide options (manually specify a main branch name), block and wait for user selection;
    - Identify the currently checked-out branch (`git branch --show-current`), mark it in memory as skipped;
    - Run `git fetch -p` to prune remote-tracking references that no longer exist;
    - Create a backup (`cp -a` at the repository's parent directory, naming format `<repo-name>.bak.<YYYYMMDD>`):
        - Success → proceed;
        - Failure → report "Backup creation failed", use AskUserQuestion to provide options (skip backup and continue / terminate), block and wait for user selection;

1. **Scan and delete stale Branches (local)** — Collect and display branches to clean:
    - Scan merged branches: `git branch --merged <main-branch> --format='%(refname:short)'`, filter out protected branches and the current branch;
    - Scan orphan branches: `git branch -vv | awk '/: gone]/{print $1}'`, filter out the current branch;
    - Merge both lists into a candidate set, deduplicate;
    - Check if the candidate set is empty:
        - Yes → report "No stale branches found for cleanup", proceed to step 2;
        - No → display in a table (columns: Branch Name / Type / Reason), use AskUserQuestion to provide options (delete all / select some / skip all), block and wait for user selection;
    - For each branch confirmed for deletion, execute:
        - Merged branch: `git branch -d <branch-name>`;
        - Orphan branch: `git branch -D <branch-name>` (since orphan branches have no remote tracking, `-d` may refuse to delete, requiring `-D`);
        - Record each deletion result (success / failure and reason);

2. **Scan and delete stale Tags (local)** — Collect and display tags to clean:
    - Scan non-version tags: `git tag -l | grep -v -E '^v?[0-9]+\.[0-9]+\.[0-9]+'`;
    - Scan orphan tags: iterate over all tags, for each tag run `git branch --all --contains <tag-name>`:
        - Empty output → mark as orphan tag;
        - Non-empty output → skip;
    - Merge both lists into a candidate set, deduplicate;
    - Check if the candidate set is empty:
        - Yes → report "No stale tags found for cleanup", proceed to step 3;
        - No → display in a table (columns: Tag Name / Type / Reason), use AskUserQuestion to provide options (delete all / select some / skip all), block and wait for user selection;
    - For each tag confirmed for deletion, execute `git tag -d <tag-name>`, record each deletion result;

3. **Remote deletion (second confirmation)** — Output summary, then delete remote references in bulk:
    - Output a local deletion summary table:
        - Branches: list deleted branch names and count, plus any failures (if any);
        - Tags: list deleted tag names and count, plus any failures (if any);
        - Auto-skipped: list the current branch and protected branches;
    - Check if any stale references were successfully deleted locally:
        - Yes → use AskUserQuestion to provide options (confirm remote deletion push / keep local deletion only / view details before deciding), block and wait for user selection;
        - No (no local deletions) → report "No changes to sync to remote", terminate the workflow;
    - For references confirmed for remote deletion, execute in bulk:
        - Delete remote branches: `git push origin --delete <branch1> <branch2> ...`;
        - Delete remote tags: `git push origin --delete refs/tags/<tag1> refs/tags/<tag2> ...`;
    - Output the final cleanup report (local + remote deletion statistics).

## Rules

- **Safety Rules**
    - Backup (`cp -a`) must be completed before any deletion operation;
    - The currently checked-out branch is automatically skipped and never entered into the scan list;
    - Protected branches (main branch + `develop`) are automatically skipped and never entered into the scan list;
    - Remote deletion requires a second confirmation; pushing deletions directly after the first confirmation is prohibited;
- **Interaction Rules**
    - All user-decision interaction points (confirming deletion, choosing operation mode, confirming the main branch, etc.) **must** use the `AskUserQuestion` tool; do not replace it with plain text prompts; pass questions and options structured into AskUserQuestion, with no more than 4 questions per call;
- **Execution Rules**
    - Process Branches first, then Tags;
    - Delete local references first, then remote references (two phases);
    - The deletion summary must be output after local deletion completes, before the second confirmation;
    - When a deletion command fails, record the failure reason and continue with subsequent deletions without interrupting the workflow;
- **Output Rules**
    - Scan results and deletion summaries must be presented in tables;
    - Table columns must be clear, including necessary dimensions such as "Reference Name / Type / Reason / Status";
    - The final cleanup report must include statistics for each dimension (deleted / skipped / failed, etc.).

## Examples

### Conversation Example

**Example: AI auto-triggers based on condition**

```
User  > Help me clean up the stale branches and tags in this repository
AI    > Detected user needs branch/tag cleanup, triggering the git-cleanup skill:
AI    > Running preparation... Git repository confirmed, detecting main branch.

   [AI uses AskUserQuestion with options: main branch is "main" / manually specify]

User  > Confirm main
AI    > Main branch confirmed as main. Currently checked out branch is feature/my-work (skipped).
       Pruning remote-tracking references (git fetch -p)... done.
       Creating backup my-project.bak.20260614... done.

AI    > Scanning stale branches...

| Branch Name | Type | Reason |
|-------------|------|--------|
| feature/old-login | Merged | Merged into main |
| fix/temp-patch | Orphan | Remote deleted |
| test/experiment | Merged | Merged into main |

Found 3 stale branches. Delete?

   [AI uses AskUserQuestion with options: delete all / select some / skip all]

User  > Select some
AI    > User confirmed deletion of feature/old-login and fix/temp-patch.
       Deleting branches...feature/old-login (git branch -d) success. fix/temp-patch (git branch -D) success.

AI    > Scanning stale tags...

| Tag Name | Type | Reason |
|----------|------|--------|
| debug-temp | Non-version Tag | Does not match version pattern |
| test-only | Orphan Tag | No branch references this commit |

Found 2 stale tags. Delete?

   [AI uses AskUserQuestion with options: delete all / select some / skip all]

User  > Delete all
AI    > Deleting tags...debug-temp (git tag -d) success. test-only (git tag -d) success.

AI    > Local deletion completed. Summary:

| Type | Deleted | Failed |
|------|---------|--------|
| Branches | 2 | 0 |
| Tags | 2 | 0 |
| Auto-skipped (current + protected) | 2 | — |

Sync these changes to remote?

   [AI uses AskUserQuestion with options: confirm push / keep local only / view details]

User  > Confirm push
AI    > Pushing remote deletions...git push origin --delete ... (success).
AI    > Cleanup complete. Deleted 2 branches and 2 tags, synced to remote.
```

### Success Example

| Item | Count |
|------|-------|
| Stale branches scanned | 3 |
| Stale tags scanned | 2 |
| Local branches deleted | 2 |
| Local tags deleted | 2 |
| Remote branches deleted | 2 |
| Remote tags deleted | 2 |
| Auto-skipped (current + protected) | 2 |
| User declined to delete | 1 (test/experiment) |
| Backup path | ../my-project.bak.20260614 |

## Review List

- **Safety & Backup Checks**
    - [ ] `cp -a` backup created before execution, path and naming correct
    - [ ] Current checked-out branch not included in deletion list
    - [ ] Protected branches (main + develop) not included in deletion list
    - [ ] Second confirmation obtained before remote deletion
- **Operation Result Checks**
    - [ ] All user-confirmed branches successfully deleted (or failure reasons recorded)
    - [ ] All user-confirmed tags successfully deleted (or failure reasons recorded)
    - [ ] Remote delete commands executed correctly with no push errors
- **Output Quality Checks**
    - [ ] Scan results displayed in table format with clear column names
    - [ ] Deletion summary includes statistics for each dimension (deleted / skipped / failed)
    - [ ] Final cleanup report includes both local and remote dimension statistics
- **Process Integrity Checks**
    - [ ] Followed execution order: Branches first, then Tags
    - [ ] Followed two-phase deletion: local first, then remote
    - [ ] No interruption signs: no incomplete deletion operations

## References

None (this skill is simple and does not require external reference documentation).
