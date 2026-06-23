---
name: git-cleanup
description: Clean up stale Worktrees, branches and tags in a Git repository, including non-current Worktrees, merged branches, orphan branches, non-version tags and orphan tags. Use when the user requests cleaning or organizing Git Worktrees/branches/tags, finds leftover local references after remote deletion, or mentions "clean up stale branches/unnecessary tags".
---

# Git Cleanup

## Overview

Systematically clean up stale Worktrees, branches and tags in a Git repository. Follow the "Scan -> Display -> User Confirm -> Delete" workflow, processing local Worktrees, local branches, and local tags in sequence, then deleting remote references after a second confirmation. Automatically creates a backup before execution.

## Definitions

- <a id="Stale-Worktree"></a>**Stale Worktree**: A non-current Worktree (any Worktree other than the user's current working directory);
- <a id="Current-Worktree"></a>**Current Worktree**: The Worktree corresponding to the user's current working directory, automatically skipped and not deletable;
- <a id="Stale-Branch"></a>**Stale Branch**: A branch meeting any of the following conditions:
    - **Merged Branch**: A local branch that has been merged into the main branch;
    - **Orphan Branch**: A local branch whose remote-tracking branch no longer exists after running `git fetch -p` (showing `: gone]`);
- <a id="Stale-Tag"></a>**Stale Tag**: A tag meeting any of the following conditions:
    - **Non-version Tag**: A tag that does not match a semantic versioning pattern (e.g., `v1.2.3`, `1.2.3`, `v1.2.3-beta.1`);
    - **Orphan Tag**: A tag pointing to a commit that is not referenced by any local or remote branch;
- <a id="Main-Branch"></a>**Main Branch**: The primary development branch of the repository (e.g., `main` or `master`), auto-detected by AI and confirmed with the user;
- <a id="Protected-Branch"></a>**Protected Branch**: The main branch and `develop` branch, automatically skipped and not deletable;
- <a id="Currently-Checked-Out-Branch"></a>**Currently Checked Out Branch**: The branch pointed to by `HEAD`, automatically skipped and not deletable.
- <a id="Worktree-Bound-Branch"></a>**Worktree Bound Branch**: A branch that has been checked out and is in use by a Worktree. Deleting it would cause the corresponding Worktree to malfunction, automatically skipped and not deletable.

## Prerequisites

- Git 2.0+;
- Currently in a Git repository directory (verifiable via `git rev-parse --git-dir`);
- User has push access to the remote repository (if remote deletion is needed).

## Workflow

0. **Pre-flight Check** — Verify environment, detect main branch, create backup;
  0.1 Verify currently in a Git repository:
    - Yes -> next step;
    - No -> report "Not currently in a Git repository", terminate flow;
  0.2 Check Git version >= 2.0:
    - Yes -> next step;
    - No -> prompt to upgrade Git, terminate flow;
  0.3 Execute `git fetch -p` to prune removed remote-tracking references:
    - Success -> next step;
    - Failure -> record failure reason, continue execution (orphan branch detection still based on current state);
  0.4 Auto-detect main branch (check `refs/heads/main`, `refs/heads/master`, `refs/heads/prod` in order):
    - Detected -> provide options via AskUserQuestion, block and wait for user selection:
      - Confirm main branch name -> use that name, proceed to next step;
      - Manually specify another branch -> user enters branch name, proceed to next step;
    - Not detected -> provide options via AskUserQuestion, block and wait for user selection:
      - Manually specify main branch name -> user enters branch name, proceed to next step;
  0.5 Identify [Current Worktree](#Current-Worktree) via `git worktree list` and [Currently Checked Out Branch](#Currently-Checked-Out-Branch) via `git branch --show-current`;
  0.6 Create backup (`cp -a` in the same parent directory as the repo, naming format `<repo-name>.bak.<YYYYMMDDTHHMMSS>`):
    - Success -> next step;
    - Failure -> report "Backup creation failed", terminate flow;

1. **Scan and Delete Stale Worktree** — Collect and display all Worktrees, only delete non-current Worktrees;
  1.1 Use `git worktree list --porcelain` to list all Worktree information, identify [Current Worktree](#Current-Worktree) and mark the "Is Current" column;
  1.2 Display all Worktrees in table format (columns: Path / Associated Branch / Is Current), automatically skip deleting the current Worktree;
  1.3 Collect all non-current Worktrees as candidate list;
  1.4 Check if the candidate list is empty:
    - Yes -> report "No non-current Worktrees found to clean", proceed to Step 2;
    - No -> provide options via AskUserQuestion, block and wait for user selection:
      - Confirm delete all -> delete all candidate Worktrees, proceed to next step;
      - Select partial deletion -> prompt user to enter Worktree paths (comma-separated), parse and display the deletion list, wait for user confirmation before deleting;
      - Skip all -> proceed to Step 2;
  1.5 For each Worktree confirmed by the user, execute `git worktree remove <path>`:
    - Success -> record success;
    - Failure (e.g., uncommitted changes) -> prompt user about `git worktree remove --force <path>` for forced deletion, confirm via AskUserQuestion;
    - Record each deletion result (success / failure and reason);

2. **Scan and Delete Stale Branch (Local)** — Collect and display branches to clean;
  2.1 Use `git worktree list --porcelain` to extract all Worktree-associated branches, mark as "Worktree-bound", automatically skip deletion;
  2.2 Scan merged branches: `git branch --merged <main-branch> --format='%(refname:short)'`, filter out [Protected Branches](#Protected-Branch), [Currently Checked Out Branch](#Currently-Checked-Out-Branch) and Worktree-bound branches;
  2.3 Scan orphan branches: `git branch -vv | awk '/: gone]/{if ($1 == "*") print $2; else print $1}'`, filter out [Protected Branches](#Protected-Branch), [Currently Checked Out Branch](#Currently-Checked-Out-Branch) and Worktree-bound branches;
  2.4 Merge both lists into a candidate set, deduplicate;
  2.5 Check if the candidate set is empty:
    - Yes -> report "No stale branches found to clean", proceed to Step 3;
    - No -> display in table format (columns: Branch Name / Type / Reason / Bound Worktree), provide options via AskUserQuestion, block and wait for user selection:
      - Confirm delete all -> delete all candidate branches, proceed to next step;
      - Select partial deletion -> prompt user to enter branch names (comma-separated), parse and display the deletion list, wait for user confirmation before deleting;
      - Skip all -> proceed to Step 3;
  2.6 For each branch confirmed by the user, execute deletion:
    - Merged branches: `git branch -d <branch-name>`;
    - Orphan branches: `git branch -D <branch-name>` (since orphan branches have no remote tracking, `-d` may refuse, use `-D`);
    - Record each deletion result (success / failure and reason);

3. **Scan and Delete Stale Tag (Local)** — Collect and display tags to clean;
  3.1 Scan non-version tags: `git tag -l | grep -v -E '^v?[0-9]+\.[0-9]+\.[0-9]+(-[a-zA-Z0-9.-]+)?(\+[a-zA-Z0-9.]+)?$'`;
  3.2 Scan orphan tags: Collect all tag list (`git tag -l`), for each tag use `git branch --all --contains <tag-name>` to check:
    - No branch contains it -> mark as orphan tag;
    - Some branch contains it -> skip, continue to next tag;
  3.3 Merge both lists into a candidate set, deduplicate;
  3.4 Check if the candidate set is empty:
    - Yes -> report "No stale tags found to clean", proceed to Step 4;
    - No -> display in table format (columns: Tag Name / Type / Reason), provide options via AskUserQuestion, block and wait for user selection:
      - Confirm delete all -> delete all candidate tags, proceed to next step;
      - Select partial deletion -> prompt user to enter tag names (comma-separated), parse and display the deletion list, wait for user confirmation before deleting;
      - Skip all -> proceed to Step 4;
  3.5 For each tag confirmed by the user, execute `git tag -d <tag-name>`, record each deletion result;

4. **Remote Deletion (Second Confirmation)** — Output summary, then delete remote references;
  4.1 Check if remote repository exists (`git remote`):
    - Remote exists -> continue;
    - Remote does not exist -> report "No remote configured for this repository, skip remote deletion", proceed to Step 6;
  4.2 Output local deletion summary table:
    - Worktree: list deleted Worktree paths and count, plus any failures (if any);
    - Branches: list deleted branch names and count, plus any failures (if any);
    - Tags: list deleted tag names and count, plus any failures (if any);
    - Auto-skipped: list [Current Worktree](#Current-Worktree), [Currently Checked Out Branch](#Currently-Checked-Out-Branch), [Protected Branches](#Protected-Branch), [Worktree Bound Branches](#Worktree-Bound-Branch);
  4.3 Check if any stale references were successfully deleted locally:
    - Yes -> provide options via AskUserQuestion, block and wait for user selection:
      - Confirm push remote deletion -> execute remote deletion, proceed to next step;
      - Keep local deletion only -> skip remote deletion, proceed to next step;
    - No (nothing deleted locally) -> report "No changes to sync to remote", proceed to Step 6;
  4.4 For references confirmed for remote deletion, execute one by one:
    - Delete remote branches: execute `git push origin --delete <branch-name>` for each branch;
    - Delete remote tags: execute `git push origin --delete refs/tags/<tag-name>` for each tag;
    - Record each deletion result (success / failure and reason);
  4.5 Output final cleanup report (local + remote deletion statistics).

5. **Abnormal Exit Handling** — Output recovery guidance, jump here when any deletion step exits abnormally;
  5.1 Check if a usable backup exists (successfully created during the Pre-flight Check step):
    - Yes -> output backup path and restore command template:
      ```
      # If you need to restore mistakenly deleted data, run the following command:
      rm -rf <repo-directory>
      cp -a <backup-path>/<repo-name>.bak.<backup-timestamp> <repo-directory>
      # Note: Rollback will overwrite all new changes after the rollback point, please confirm the current working state first
      ```
    - No -> report "No backup available, please check repository status";
  5.2 Output summary of completed deletions so far (list of deleted Worktrees/Branches/Tags, if any);
  5.3 Notify the user that the process has been safely terminated, provide manual recovery advice and backup path information, terminate flow.

6. **Review Check** — Check against [Review List](#review-list) to confirm execution results;
  6.1 Check if Review List has content:
    - No -> proceed directly to next step (output results);
    - Yes -> next step;
  6.2 Check each item in [Review List](#review-list) in order, check if passed (based on "Review Check Example" display output):
    - Yes -> continue to next check item;
    - No -> provide options via AskUserQuestion, block and wait for user selection:
      - Retry the failed step -> return to corresponding step and re-execute;
      - Skip failed items and continue -> mark as incomplete, proceed to output results;
      - Terminate flow -> terminate flow;
  6.3 After all checks pass, proceed to next step (output results);

7. **Output Results** — Output cleanup summary, backup path and rollback instructions, notify completion;
  7.1 Output structured summary (including statistics for each dimension of this cleanup);
  7.2 Output backup path and restore command template:
    ```
    # If you need to restore mistakenly deleted data, run the following command:
    rm -rf <repo-directory>
    cp -a <backup-path>/<repo-name>.bak.<backup-timestamp> <repo-directory>
    # Note: Rollback will overwrite all new changes after the rollback point, please confirm the current working state first
    ```
  7.3 Prompt the user to confirm the current working state and the correctness of the backup path before rollback;
  7.4 Notify cleanup complete;

## Rules

- **Metadata Conventions**
  - description follows the format: first sentence describes what the skill does, second sentence describes trigger condition ("Use when..."), written in third person, no more than 1024 characters;
- **Structure Conventions**
  - Standard directory only applies to SKILL.md itself, does not affect other files in the directory;
- **Content Conventions**
  - Scan results and deletion summaries are presented in table format;
  - Table column headers are clear, including necessary dimensions like "Reference Name / Type / Reason / Status";
  - Final cleanup report includes statistical counts for each dimension (deleted / skipped / failed, etc.);
- **Behavioral Conventions**
  - Backup failure cannot be skipped; must either succeed or terminate the flow;
  - [Current Worktree](#Current-Worktree) and [Currently Checked Out Branch](#Currently-Checked-Out-Branch) are automatically skipped and not included in scan list;
  - [Worktree Bound Branches](#Worktree-Bound-Branch) are automatically skipped and not included in deletion candidate list;
  - [Protected Branches](#Protected-Branch) ([Main Branch](#Main-Branch) + `develop`) are automatically skipped and not included in scan list;
  - Remote deletion must go through second confirmation; direct push after first confirmation is prohibited;
  - All user decision-making interactions (confirming deletion, selecting operation mode, confirming [Main Branch](#Main-Branch), etc.) **must** use the `AskUserQuestion` tool; plain text follow-ups are prohibited; pass questions and options into AskUserQuestion in a structured way, no more than 4 questions per call;
  - Process Worktree first, then Branches, then Tags;
  - Delete local references first, then remote references (two-phase);
  - Must output deletion summary after each local deletion step, then output final summary before second confirmation;
  - When a deletion command fails, record the failure reason and continue with subsequent deletions, do not interrupt the flow;
- **Defensive Conventions**
  - Before deleting any reference, confirm with the user through interactive questioning;
- **Verification Conventions**
  - Example content should be consistent with the latest Workflow steps;

## Examples

### Dialog Interaction Examples

***Triggering the Skill***

```markdown
User > Help me clean up stale Worktrees, branches and tags in this repository
AI   > Triggering git-cleanup skill, starting pre-flight checks...
```

***Scan and Clean Stale Worktree***

```markdown
AI   > Scanning Worktrees using git worktree list --porcelain...
       
      | Path | Associated Branch | Is Current |
      |------|----------|----------|
      | /path/to/repo | main | Yes (auto-skipped) |
      | /path/to/linked-wt | feature/experiment | No |
      | /path/to/old-wt | fix/hotfix-old | No |

      2 non-current Worktrees found. Delete them?
      [AskUserQuestion provides options: Delete All / Select Partial / Skip All]
User > Delete All
AI   > Deleting.../path/to/linked-wt (git worktree remove) successful.
      /path/to/old-wt (git worktree remove) successful.
      2 stale Worktrees deleted in total.
```

***Scan and Clean Stale Branch***

```markdown
AI   > Extracting Worktree-bound branches using git worktree list --porcelain...
      Scanning stale branches using git branch --merged and git branch -vv...
       
      | Branch Name | Type | Reason | Bound Worktree |
      |--------|------|------|---------------|
      | feature/old-login | Merged | Merged into main | No |
      | fix/temp-patch | Orphan | Remote tracking gone | No |
      | feature/in-use | Merged | Merged into main | Yes (auto-skipped) |

      2 stale branches available for deletion. Delete them?
      [AskUserQuestion provides options: Delete All / Select Partial / Skip All]
User > Delete All
AI   > Deleting...feature/old-login (git branch -d) successful.
      fix/temp-patch (git branch -D) successful.
      2 stale branches deleted in total.
```

***Scan and Clean Stale Tag***

```markdown
AI   > Scanning stale tags using git tag -l with regex filtering and orphan check...
       
      | Tag Name | Type | Reason |
      |--------|------|------|
      | v0.1-alpha | Non-version Tag | Does not match semver pattern |
      | temp-tag-123 | Orphan Tag | No branch references this commit |

      Delete these 2 stale tags?
      [AskUserQuestion provides options: Delete All / Select Partial / Skip All]
User > Delete All
AI   > Deleting...v0.1-alpha (git tag -d) successful.
      temp-tag-123 (git tag -d) successful.
      2 stale tags deleted in total.
```

***Nothing to Clean***

```markdown
AI   > Scan complete:
      - No non-current Worktrees
      - No merged or orphan branches
      - No non-version or orphan tags
      No deletion operations needed.
      Backup path: ../my-project.bak.20260614T143052
      It is recommended to run this skill periodically to keep the repository clean.
```

***Select Partial Deletion***

```markdown
AI   > Stale Worktree list is shown above. Delete them?
      [AskUserQuestion provides options: Delete All / Select Partial / Skip All]
User > Select Partial
AI   > Please specify Worktree paths to delete (comma-separated):
User > /path/to/old-wt
AI   > Deleting.../path/to/old-wt (git worktree remove) successful.
```

***Remote Deletion Second Confirmation***

```markdown
AI   > Local deletion summary:
      - Worktree: 2 deleted
      - Branches: 2 deleted (feature/old-login, fix/temp-patch)
      - Tags: 1 deleted (v0.1-alpha)
      - Auto-skipped: Current Worktree, current branch (main), protected (develop)

      Sync these changes to remote?
      [AskUserQuestion provides options: Confirm Push / Keep Local Deletion Only / View Details]
User > Confirm Push
AI   > Pushing remote deletions...
      git push origin --delete feature/old-login (successful)
      git push origin --delete fix/temp-patch (successful)
      git push origin --delete refs/tags/v0.1-alpha (successful)
```

***Keep Local Deletion Only***

```markdown
AI   > Sync these changes to remote?
      [AskUserQuestion provides options: Confirm Push / Keep Local Deletion Only / View Details]
User > Keep Local Deletion Only
AI   > Skipped remote push. Local changes:
       - Deleted Worktree: /path/to/linked-wt, /path/to/old-wt
       - Deleted branches: feature/old-login, fix/temp-patch
       - Deleted Tags: v0.1-alpha
       - Backup path: ../my-project.bak.20260614T143052
      Note: Corresponding references in the remote repository have not been deleted, please handle manually.
```

### Review Check Example

```markdown
AI > Entering review check, Review List contains 16 check items, starting verification:

**Content Check**
  - 🟩 All Worktrees confirmed for deletion have been successfully deleted
  - 🟩 All branches confirmed for deletion have been successfully deleted
  - 🟩 All tags confirmed for deletion have been successfully deleted
  - 🟥 Remote deletion command failed (network error), deletion not pushed
  - 🟩 Scan results displayed in table format with clear column headers
  - 🟩 ...(remaining check items all passed)

**Behavior Check**
  - 🟩 `cp -a` backup created before execution, path and naming correct
  - 🟩 `git fetch -p` executed, remote tracking references pruned
  - 🟩 Current Worktree and currently checked out branch not included in deletion list
  - 🟩 Protected branches not included in deletion list
  - 🟩 Second confirmation obtained before remote deletion
  - 🟩 Followed "Worktree first, then Branches, then Tags" execution order
  - 🟩 Followed "local first, remote second" two-phase deletion flow

**!!! Following check items FAILED !!!**
  - 🟥 Remote deletion failed (network error)

[AskUserQuestion provides options: Retry Failed Step / Skip Failed Items and Continue / Terminate Flow]

User > Terminate Flow
AI   > Flow terminated. It is recommended to manually check network connection and re-execute remote sync.
```

### Output Results Example

**Git Worktree, Branch and Tag Cleanup Execution Example:**

```markdown
## Cleanup Complete

The Git repository cleanup operation has been completed. Below is the execution summary:

| Item | Count |
|------|-------|
| Stale Worktrees scanned | 2 |
| Stale branches scanned | 3 |
| Stale tags scanned | 2 |
| Local Worktrees deleted | 2 |
| Local branches deleted | 2 |
| Local tags deleted | 2 |
| Remote branches deleted | 2 |
| Remote tags deleted | 2 |
| Auto-skipped (current Worktree + current/protected branches) | 3 |
| User refused deletion | 1 (test/experiment) |
| Backup path | ../my-project.bak.20260614T143052 |

All deletion operations completed, no pending operations.
```

## Review List

- **Content Check**
  - [ ] All user-confirmed Worktrees have been successfully deleted (or failure reasons recorded)
  - [ ] All user-confirmed branches have been successfully deleted (or failure reasons recorded)
  - [ ] All user-confirmed tags have been successfully deleted (or failure reasons recorded)
  - [ ] Remote deletion commands executed correctly, no push errors
  - [ ] Scan results displayed in table format with clear column headers
  - [ ] Deletion summary includes statistics for each dimension (deleted / skipped / failed)
  - [ ] Final cleanup report includes both local and remote statistics
- **Behavior Check**
  - [ ] `git fetch -p` executed, remote tracking references pruned (or confirmed skipped when no remote configured)
  - [ ] `cp -a` backup created before execution, path and naming correct
  - [ ] [Current Worktree](#Current-Worktree) and [Currently Checked Out Branch](#Currently-Checked-Out-Branch) not included in deletion list
  - [ ] [Worktree Bound Branches](#Worktree-Bound-Branch) not included in deletion candidate list
  - [ ] [Protected Branches](#Protected-Branch) ([Main Branch](#Main-Branch) + develop) not included in deletion list
  - [ ] Second confirmation obtained before remote deletion
  - [ ] Followed "Worktree first, then Branches, then Tags" execution order
  - [ ] Followed "local first, remote second" two-phase deletion flow
  - [ ] Abnormal exit correctly jumped to Abnormal Exit Handling step and output recovery guidance
- **Defensive Check**
  - [ ] When deletion command failed, failure reason correctly recorded and subsequent deletions continued
- **Verification Check**
  - [ ] No interruption signs: no incomplete deletion operations

## References

None (this skill is self-contained, no external reference documents needed).
