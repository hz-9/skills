---
name: git-cleanup
description: Clean up stale branches and tags in a Git repository, including merged branches, orphan branches, non-version tags and orphan tags. Use when the user requests cleaning or organizing Git branches/tags, finds leftover local references after remote deletion, or mentions "clean up stale branches/unnecessary tags".
---

# Git Cleanup

## Overview

Systematically clean up stale branches and tags in a Git repository. Follow the "Scan -> Display -> User Confirm -> Delete" workflow, processing local branches and tags first, then deleting remote references after a second confirmation. Automatically creates a backup before execution.

## Definitions

- <a id="Stale-Branch"></a>**Stale Branch**: A branch meeting any of the following conditions:
    - **Merged Branch**: A local branch that has been merged into the main branch;
    - **Orphan Branch**: A local branch whose remote-tracking branch no longer exists after running `git fetch -p` (showing `: gone]`);
- <a id="Stale-Tag"></a>**Stale Tag**: A tag meeting any of the following conditions:
    - **Non-version Tag**: A tag that does not match a semantic versioning pattern (e.g., `v1.2.3`, `1.2.3`, `v1.2.3-beta.1`);
    - **Orphan Tag**: A tag pointing to a commit that is not referenced by any local or remote branch;
- <a id="Main-Branch"></a>**Main Branch**: The primary development branch of the repository (e.g., `main` or `master`), auto-detected by AI and confirmed with the user;
- <a id="Protected-Branch"></a>**Protected Branch**: The main branch and `develop` branch, automatically skipped and not deletable;
- <a id="Currently-Checked-Out-Branch"></a>**Currently Checked Out Branch**: The branch pointed to by `HEAD`, automatically skipped and not deletable.

## Prerequisites

- Git 2.0+;
- Currently in a Git repository directory (verifiable via `git rev-parse --git-dir`);
- User has push access to the remote repository (if remote deletion is needed).

## Workflow

0. **Pre-flight Check** — Verify environment, detect main branch, create backup;
  - Detect Git locale (check `locale` command output for `LANG` or `LC_MESSAGES`):
    - Non-English locale -> prefix subsequent git commands with `LC_ALL=C` to force English output;
    - English locale -> execute normally;
  - Verify currently in a Git repository:
    - Yes -> next step;
    - No -> report "Not currently in a Git repository", terminate flow;
  - Auto-detect main branch (check `refs/heads/main`, `refs/heads/master` in order):
    - Detected -> provide options via AskUserQuestion, block and wait for user selection:
      - Confirm main branch name -> use that name, proceed to next step;
      - Manually specify another branch -> user enters branch name, proceed to next step;
    - Not detected -> provide options via AskUserQuestion, block and wait for user selection:
      - Manually specify main branch name -> user enters branch name, proceed to next step;
  - Identify [Currently Checked Out Branch](#Currently-Checked-Out-Branch) (`git branch --show-current`), mark it in memory to skip;
  - Create backup (`cp -a` in the same parent directory as the repo, naming format `<repo-name>.bak.<YYYYMMDDTHHMMSS>`):
    - Success -> next step;
    - Failure -> report "Backup creation failed", terminate flow;
  - Execute `git fetch -p` to prune removed remote-tracking references:
    - Success -> next step;
    - Failure -> record failure reason, continue execution (orphan branch detection still based on current state);

1. **Scan and Delete Stale Branches (Local)** — Collect and display branches to clean;
  - Scan merged branches: `git branch --merged <main-branch> --format='%(refname:short)'`, filter out [Protected Branches](#Protected-Branch) and [Currently Checked Out Branch](#Currently-Checked-Out-Branch);
  - Scan orphan branches: `git branch -vv | awk '/: gone]/{if ($1 == "*") print $2; else print $1}'`, filter out [Protected Branches](#Protected-Branch) and [Currently Checked Out Branch](#Currently-Checked-Out-Branch);
  - Merge both lists into a candidate set, deduplicate;
  - Check if the candidate set is empty:
    - Yes -> report "No stale branches found to clean", proceed to Step 2;
    - No -> display in table format (columns: Branch Name / Type / Reason), provide options via AskUserQuestion, block and wait for user selection:
      - Confirm delete all -> delete all candidate branches, proceed to next step;
      - Select partial deletion -> prompt user to enter reference names (comma-separated), parse and display the deletion list, wait for user confirmation before deleting;
      - Skip all -> proceed to Step 2;
  - For each branch confirmed by the user, execute deletion:
    - Merged branches: `git branch -d <branch-name>`;
    - Orphan branches: `git branch -D <branch-name>` (since orphan branches have no remote tracking, `-d` may refuse, use `-D`);
    - Record each deletion result (success / failure and reason);

2. **Scan and Delete Stale Tags (Local)** — Collect and display tags to clean;
  - Scan non-version tags: `git tag -l | grep -v -E '^v?[0-9]+\.[0-9]+\.[0-9]+(-[a-zA-Z0-9.-]+)?(\+[a-zA-Z0-9.]+)?$'`;
  - Scan orphan tags: Collect all tag list (`git tag -l`), for each tag use `git branch --all --contains <tag-name>` to check:
    - No branch contains it -> mark as orphan tag;
    - Some branch contains it -> skip, continue to next tag;
  - Merge both lists into a candidate set, deduplicate;
  - Check if the candidate set is empty:
    - Yes -> report "No stale tags found to clean", proceed to Step 3;
    - No -> display in table format (columns: Tag Name / Type / Reason), provide options via AskUserQuestion, block and wait for user selection:
      - Confirm delete all -> delete all candidate tags, proceed to next step;
      - Select partial deletion -> prompt user to enter tag names (comma-separated), parse and display the deletion list, wait for user confirmation before deleting;
      - Skip all -> proceed to Step 3;
  - For each tag confirmed by the user, execute `git tag -d <tag-name>`, record each deletion result;

3. **Remote Deletion (Second Confirmation)** — Output summary, then delete remote references;
  - Check if remote repository exists (`git remote`):
    - Remote exists -> continue;
    - Remote does not exist -> report "No remote configured for this repository, skip remote deletion", proceed to Step 4;
  - Output local deletion summary table:
    - Branches: list deleted branch names and count, plus any failures;
    - Tags: list deleted tag names and count, plus any failures;
    - Auto-skipped: list [Currently Checked Out Branch](#Currently-Checked-Out-Branch), [Protected Branches](#Protected-Branch);
  - Check if any stale references were successfully deleted locally:
    - Yes -> provide options via AskUserQuestion, block and wait for user selection:
      - Confirm push remote deletion -> execute remote deletion, proceed to next step;
      - Keep local deletion only -> skip remote deletion, proceed to next step;
      - View details before deciding -> display detailed deletion list, provide options again via AskUserQuestion, block and wait for user selection:
        - Confirm push remote deletion -> execute remote deletion, proceed to next step;
        - Keep local deletion only -> skip remote deletion, proceed to next step;
    - No (nothing deleted locally) -> report "No changes to sync to remote", proceed to Step 4;
  - For references confirmed for remote deletion, execute one by one:
    - Delete remote branches: execute `git push origin --delete <branch-name>` for each branch;
    - Delete remote tags: execute `git push origin --delete refs/tags/<tag-name>` for each tag;
    - Record each deletion result (success / failure and reason);
  - Output final cleanup report (local + remote deletion statistics).

4. **Review Check** — Check against [Review List](#review-list) to confirm execution results;
  - Check if Review List has content:
    - No -> proceed directly to next step (output results);
    - Yes -> next step;
  - Check each item in [Review List](#review-list) in order, check if passed (based on "Review Check Example" display output):
    - Yes -> continue to next check item;
    - No -> provide options via AskUserQuestion, block and wait for user selection:
      - Retry the failed step -> return to corresponding step and re-execute;
      - Skip failed items and continue -> mark as incomplete, proceed to output results;
      - Terminate flow -> terminate flow;
  - After all checks pass, proceed to next step (output results);

5. **Output Results** — Output cleanup summary, backup path and rollback instructions, notify completion;
  - Output structured summary (including statistics for each dimension of this cleanup);
  - Output backup path and restore command template:
    ```
    # If you need to restore mistakenly deleted data, run the following command:
    rm -rf <repo-directory>
    cp -a <backup-path>/<repo-name>.bak.<backup-timestamp> <repo-directory>
    # Note: Rollback will overwrite all new changes after the rollback point, please confirm the current working state first
    ```
  - Prompt the user to confirm the current working state and the correctness of the backup path before rollback;
  - Notify cleanup complete;

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
  - [Currently Checked Out Branch](#Currently-Checked-Out-Branch) is automatically skipped and not included in scan list;
  - [Protected Branches](#Protected-Branch) ([Main Branch](#Main-Branch) + `develop`) are automatically skipped and not included in scan list;
  - Remote deletion must go through second confirmation; direct push after first confirmation is prohibited;
  - All user decision-making interactions (confirming deletion, selecting operation mode, confirming [Main Branch](#Main-Branch), etc.) **must** use the `AskUserQuestion` tool; plain text follow-ups are prohibited; pass questions and options into AskUserQuestion in a structured way, no more than 4 questions per call;
  - Process Branches first, then Tags;
  - Delete local references first, then remote references (two-phase);
  - Must output deletion summary after local deletion, then proceed to second confirmation;
  - When a deletion command fails, record the failure reason and continue with subsequent deletions, do not interrupt the flow;
- **Defensive Conventions**
  - Before deleting any reference, confirm with the user through interactive questioning;
- **Verification Conventions**
  - Example content should be consistent with the latest Workflow steps;

## Examples

### Dialog Interaction Examples

***Triggering the Skill***

```markdown
User > Help me clean up stale branches and tags in this repository
AI   > Triggering git-cleanup skill, starting pre-flight checks...
```

***Confirm Delete All***

```markdown
AI   > Stale branch list is shown above. Delete them?
      [AskUserQuestion provides options: Delete All / Select Partial / Skip All]
User > Delete All
AI   > Deleting...feature/old-login (successful), fix/temp-patch (successful).
      Deleted 2 stale branches in total.
```

***Nothing to Clean***

```markdown
AI   > Scan complete: no merged or orphan branches found, nor non-version or orphan tags.
      No deletion operations needed.
      Backup path: ../my-project.bak.20260614T143052
      It is recommended to run this skill periodically to keep the repository clean.
```

***Select Partial Deletion***

```markdown
AI   > Stale branch list is shown above. Delete them?
      [AskUserQuestion provides options: Delete All / Select Partial / Skip All]
User > Select Partial
AI   > Please specify the branches to delete:
User > feature/old-login, fix/temp-patch
AI   > Deleting...feature/old-login (git branch -d) successful. fix/temp-patch (git branch -D) successful.
```

***Remote Deletion Second Confirmation***

```markdown
AI   > Sync these changes to remote?
      [AskUserQuestion provides options: Confirm Push / Keep Local Deletion Only / View Details]
User > Confirm Push
AI   > Pushing remote deletions...git push origin --delete ... (successful).
```

***Keep Local Deletion Only***

```markdown
AI   > Sync these changes to remote?
      [AskUserQuestion provides options: Confirm Push / Keep Local Deletion Only / View Details]
User > Keep Local Deletion Only
AI   > Skipped remote push. Local changes:
       - Deleted branches: feature/old-login (successful)
       - Deleted Tags: v0.1-alpha (successful)
       - Backup path: ../my-project.bak.20260614T143052
      Note: Corresponding references in the remote repository have not been deleted, please handle manually.
```

### Review Check Example

```markdown
AI > Entering review check, Review List contains 15 check items, starting verification:

**Content Check**
  - 🟩 All branches confirmed for deletion by user have been successfully deleted
  - 🟩 All tags confirmed for deletion by user have been successfully deleted
  - 🟥 Remote deletion command failed (network error), deletion not pushed
  - 🟩 Scan results displayed in table format with clear column headers
  - 🟩 ...(remaining check items all passed)

**Behavior Check**
  - 🟩 `cp -a` backup created before execution, path and naming correct
  - 🟩 `git fetch -p` executed, remote tracking references pruned
  - 🟩 Currently checked out branch not included in deletion list
  - 🟩 Protected branches not included in deletion list
  - 🟩 Second confirmation obtained before remote deletion
  - 🟩 Followed "Branches first, Tags second" execution order
  - 🟩 Followed "local first, remote second" two-phase deletion flow

**!!! Following check items FAILED !!!**
  - 🟥 Remote deletion failed (network error)

[AskUserQuestion provides options: Retry Failed Step / Skip Failed Items and Continue / Terminate Flow]

User > Terminate Flow
AI   > Flow terminated. It is recommended to manually check network connection and re-execute remote sync.
```

### Output Results Example

**Git Branch and Tag Cleanup Execution Example:**

```markdown
## Cleanup Complete

The Git repository cleanup operation has been completed. Below is the execution summary:

| Item | Count |
|------|-------|
| Stale branches scanned | 3 |
| Stale tags scanned | 2 |
| Local branches deleted | 2 |
| Local tags deleted | 2 |
| Remote branches deleted | 2 |
| Remote tags deleted | 2 |
| Auto-skipped (current + protected) | 2 |
| User refused deletion | 1 (test/experiment) |
| Backup path | ../my-project.bak.20260614T143052 |

All deletion operations completed, no pending operations.
```

## Review List

- **Content Check**
  - [ ] All user-confirmed branches have been successfully deleted (or failure reasons recorded)
  - [ ] All user-confirmed tags have been successfully deleted (or failure reasons recorded)
  - [ ] Remote deletion commands executed correctly, no push errors
  - [ ] Scan results displayed in table format with clear column headers
  - [ ] Deletion summary includes statistics for each dimension (deleted / skipped / failed)
  - [ ] Final cleanup report includes both local and remote statistics
- **Behavior Check**
  - [ ] `git fetch -p` executed, remote tracking references pruned (or confirmed skipped when no remote configured)
  - [ ] `cp -a` backup created before execution, path and naming correct
  - [ ] [Currently Checked Out Branch](#Currently-Checked-Out-Branch) not included in deletion list
  - [ ] [Protected Branches](#Protected-Branch) ([Main Branch](#Main-Branch) + develop) not included in deletion list
  - [ ] Second confirmation obtained before remote deletion
  - [ ] Followed "Branches first, Tags second" execution order
  - [ ] Followed "local first, remote second" two-phase deletion flow
- **Defensive Check**
  - [ ] When deletion command failed, failure reason correctly recorded and subsequent deletions continued
- **Verification Check**
  - [ ] No interruption signs: no incomplete deletion operations

## References

None (this skill is self-contained, no external reference documents needed).
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
