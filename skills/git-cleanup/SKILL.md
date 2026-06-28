---
name: git-cleanup
description: Clean up stale Worktrees, branches and tags in a Git repository. Includes stale Worktrees, merged branches, orphan branches, non-version tags and orphan tags. Use when a user requests cleanup or organization of Git Worktrees/branches/tags, discovers residual local references where the remote has been deleted, or mentions "cleaning up stale branches/unnecessary Tags".
---

# Git Cleanup

## Overview

Systematically clean up stale Worktrees, branches and tags in a Git repository. Follow the workflow of "Comprehensive scan -> One-time confirmation -> Unified deletion": first scan all categories at once (Worktree/branch/Tag), then let the user decide through a single confirmation, then execute deletions uniformly, and after a second confirmation, uniformly delete remote references. A backup is automatically created before execution.

## Definitions

- <a id="废弃分支"></a>**stale branch**: A branch that meets any of the following conditions:
    - **merged branch**: A local branch that has been merged into the main branch;
    - **orphan branch**: A local branch whose remote-tracking branch no longer exists (showing `: gone]`) after executing `git fetch -p`;
- <a id="废弃 Tag"></a>**stale tag**: A tag that meets any of the following conditions:
    - **non-version Tag**: A tag that does not match the semantic versioning pattern (e.g., `v1.2.3`, `1.2.3`, `v1.2.3-beta.1`);
    - **orphan Tag**: A tag whose referenced commit has no local or remote branch references;
- <a id="废弃 Worktree"></a>**stale Worktree**: A Worktree that is in a clean state (no uncommitted changes), automatically excluding [dirty Worktrees](#脏-worktree);

- <a id="脏 Worktree"></a>**dirty Worktree**: A Worktree with uncommitted changes (unstaged or uncommitted changes). Dirty Worktrees are automatically skipped and cannot be deleted;
- <a id="主分支"></a>**main branch**: The primary development branch of the repository (e.g., `main`, `master`, or `prod`), automatically detected by AI and confirmed with the user;
- <a id="保护分支"></a>**Protected branch**: Refer to [references/protected-branch.md](references/protected-branch.md). Protected branches serve a dual role in git-cleanup:
  - **Operation gate**: This skill is only allowed to run when the currently checked-out branch is in the protected branch list (step 0.5);
  - **Data protection**: Protected branches are automatically skipped during scanning and will not enter the deletion candidate list, thus will not be deleted;

## Prerequisites

- Git 2.0+;
- Currently in a Git repository directory (verifiable via `git rev-parse --git-dir`);
- `jq` (JSON processing tool, required by scripts such as check-env.sh / scan.sh / delete.sh / setup.sh);
- User has push permission to the remote repository (if remote deletion is required);
- Currently only supports remote deletion for repositories with a remote named `origin`;

## Workflow

0. **Pre-check** — Ensure the environment is ready;
  0.1 Run environment check (`bash scripts/check-env.sh`):
    - Determine whether the script executed successfully:
      - Success -> Parse JSON, check if it contains an "error" field:
        - Yes -> Report script error (e.g., missing jq dependency), terminate flow;
        - No -> Report each check result item by item:
      - "in-git-repo" failed -> Report "Not currently in a Git repository", terminate flow;
      - "git-version" failed -> Prompt to upgrade Git to 2.0+, terminate flow;
      - "has-remote" -> Store the result (used in step 4.1 for remote deletion);
    - When the passed field of all check items is true, consider it "all checks passed" and proceed to step 0.2;
    - If any check item's passed is false, handle according to the corresponding rule;
  0.2 Run environment setup (`bash scripts/setup.sh`):
    - Determine whether the script executed successfully:
      - Success -> Parse JSON, check if it contains an "error" field:
        - Yes -> Report script error (e.g., missing jq dependency), terminate flow;
        - No -> Read the following information:
      - main_branch_candidate -> Auto-detected main branch name;
      - current_worktree -> Current Worktree path;
      - current_branch -> Currently checked-out branch;
      - backup_created / backup_path -> Backup status and path;
    - Determine whether the backup was created successfully:
      - Success -> Proceed to step 0.3;
      - Failure -> Report "Backup creation failed", terminate flow;
  0.3 Confirm main branch — Provide options via AskUserQuestion, block and wait for user selection:
    - Main branch detected -> Provide options:
      - Confirm main branch name -> Use that name, proceed to step 0.4;
      - Manually specify another branch -> User enters a branch name, proceed to step 0.4;
    - Main branch not detected -> Provide options:
      - Manually specify main branch name -> User enters a branch name, proceed to step 0.4;
  0.4 Confirm protected branches — Provide options via AskUserQuestion, block and wait for user selection:
    - Provide the default protected branch list (refer to [references/protected-branch.md](references/protected-branch.md)) and allow the user to enter additional branch names (comma-separated);
    - After confirmation, merge the reference file's default list with user-specified branches as the final protected branch list, proceed to step 0.5;
  0.5 Check current branch — Determine whether the currently checked-out branch (current_branch) is in the protected branch list:
    - Yes (current branch is in the protected list) -> Proceed to step 1;
    - No -> Report "Current branch 'xxx' is not a protected branch, please run this skill under a [Protected branch](#保护分支)", terminate flow;

1. **Comprehensive scan** — First perform remote pruning, then run the scan script, output three category JSONs;
  1.0 Execute remote pruning (`git fetch -p`):
    - Determine whether the command executed successfully:
      - Success -> Continue to step 1.1;
      - Failure -> Record the failure reason (e.g., network unreachable), continue to step 1.1;
  1.1 Execute the scan script (`bash scripts/scan.sh --main-branch <main-branch> --protected-branches <protected branch list comma-separated>`):
    - Determine whether the script executed successfully:
      - Success -> Parse JSON, check if it contains an "error" field:
        - Yes -> Report script error (e.g., missing jq dependency), terminate flow;
        - No -> Retrieve the three arrays: worktrees, branches, tags;
      - Failure -> Report "Scan script execution abnormal", terminate flow;
  1.2 Check whether all three arrays are empty:
    - Yes -> Report "No stale references found to clean up", terminate flow;
    - No -> Proceed to step 2;

2. **Category confirmation** — Display scan results by category, confirm deletions separately;
  2.1 Display scan results — Render the three JSON arrays as Markdown tables:
      - Worktree table (columns: Path / Associated Branch / Current / Dirty Status);
        - dirty Worktree (is_dirty=true) marked as "⚠️ Has uncommitted changes, skipping deletion", not entered into deletion candidate list;
        - Current Worktree marked as "Skipped (current)", not entered into deletion candidate list;
      - Branch table (columns: Branch Name / Type / Reason);
      - Tag table (columns: Tag Name / Type / Reason);
  2.2 Confirm Worktree (only for the "stale Worktree" candidate list) — Provide options via AskUserQuestion, block and wait for user selection:
      - Yes, delete all stale Worktrees -> Mark all as pending deletion, proceed to 2.3;
      - Select partial deletion -> Prompt user to enter paths (comma-separated), after confirmation proceed to 2.3;
      - Skip -> Proceed to 2.3;
      - Note: dirty Worktrees and current Worktree are not in this candidate list and are automatically skipped;
  2.3 Confirm branches — Provide options via AskUserQuestion, block and wait for user selection:
      - Yes, delete all stale branches -> Mark all as pending deletion, proceed to 2.4;
      - Select partial deletion -> Prompt user to enter branch names (comma-separated), after confirmation proceed to 2.4;
      - Skip -> Proceed to 2.4;
  2.4 Confirm Tags — Provide options via AskUserQuestion, block and wait for user selection:
      - Yes, delete all stale Tags -> Mark all as pending deletion, proceed to 2.5;
      - Select partial deletion -> Prompt user to enter Tag names (comma-separated), after confirmation proceed to 2.5;
      - Skip -> Proceed to 2.5;
  2.5 Check if there are any references marked as pending deletion:
      - Yes (there are items pending deletion) -> Proceed to step 3;
      - No (all skipped) -> Report "No items selected for deletion", terminate flow;

3. **Unified execution** — Use the delete script to execute all confirmed deletions;
  3.1 Execute the delete script (`bash scripts/delete.sh --worktrees '<json>' --branches '<json>' --tags '<json>' --protected-branches '<protected branch list comma-separated>'`):
    - Determine whether the script executed successfully:
      - Failure -> Report "Delete script execution abnormal", jump to step 5 (Abnormal exit handling);
      - Success -> Parse JSON;
      - Example input data structures:
        - `--worktrees '[{"path":"/path/to/wt"}]'`
        - `--branches '[{"name":"feature/old","type":"merged"},{"name":"fix/temp","type":"orphan"}]'`
        - `--tags '[{"name":"v0.1-alpha","type":"non-version"},{"name":"temp-tag","type":"orphan"}]'`
    - Parse the returned JSON result array, output deletion results one by one (success / failure / skipped);
    - Handle status in the output results:
      - "success" -> Output "Success";
      - "skipped" (reason="dirty worktree") -> Output "Skipped (Worktree has uncommitted changes)", continue with subsequent deletions;
      - "failed" -> When Worktree deletion fails, ask the user via AskUserQuestion whether to attempt force deletion (`git worktree remove --force <path>`):
        - Yes -> Execute force deletion and output the result;
        - No -> Skip that Worktree, continue processing subsequent deletions;
  3.2 Output local deletion summary table (count successes/skips/failures), refer to <a id="本地删除摘要示例"></a>[Local Deletion Summary Example](#本地删除摘要示例);
  3.3 Proceed to step 4;

4. **Remote deletion** — Execute remote deletion after second confirmation;
  4.1 Retrieve the has-remote result from step 0.1 check-env, determine whether there were local deletions:
      - Remote exists and there were local deletions -> Provide options via AskUserQuestion, block and wait for user selection:
        - Confirm push remote deletion -> Proceed to 4.2;
        - Keep local deletion only -> Proceed to 4.3;
      - Remote does not exist or no local deletions -> Report "No changes need to be synced to remote", proceed to step 6;
  4.2 Execute remote deletion script (`bash scripts/remote-delete.sh --branches '<json>' --tags '<json>'`):
    - Determine whether the script executed successfully:
      - Failure -> Report "Remote deletion script execution abnormal", jump to step 5 (Abnormal exit handling);
      - Success -> Parse JSON;
      - Example input data structures:
        - `--branches '[{"name":"feature/old-login"}]'`
        - `--tags '[{"name":"temp-tag-123"}]'`
      - Parse the returned JSON, output deletion results one by one;
  4.3 Output final cleanup report (local + remote deletion statistics);

5. **Abnormal exit handling** — Output recovery guidance, jump here when any deletion step exits abnormally;
  5.1 Check the backup_created result from step 0.2 setup.sh output:
    - Yes -> Output backup path and recovery commands, refer to <a id="备份恢复示例"></a>[Backup Recovery Example](#备份恢复示例);
    - No -> Report "No backup available, please check repository status";
  5.2 Output a summary of deletion operations completed so far (if there is a list of deleted Worktrees/Branches/Tags);
  5.3 Inform the user that the process has been safely terminated, provide manual recovery suggestions and backup path information, terminate flow;

6. **Review check** — Check against the [Review List](#review-list) to confirm execution results;
  6.1 Determine whether the Review List has any content:
    - No -> Directly proceed to the next step (Output results);
    - Yes -> Next step;
  6.2 Check each item in the [Review List](#review-list) one by one to determine whether it passed (output display content based on "Review Check Example"):
    - Yes -> Continue to the next check item;
    - No -> Provide options via AskUserQuestion, block and wait for user selection:
      - Retry the failed step -> Return to the corresponding step for re-execution;
      - Skip the failed item and continue -> Mark as incomplete, proceed to Output results;
      - Terminate flow -> Terminate flow;
  6.3 After all pass, proceed to the next step (Output results);

7. **Output results** — Output cleanup summary, backup path, and rollback guidance, notify completion;
  7.1 Output structured summary (including statistical counts for each dimension of this cleanup);
  7.2 Output backup path and recovery commands (refer to [Backup Recovery Example](#备份恢复示例));
  7.3 Remind the user to confirm the current workspace state and the correctness of the backup path before rollback;
  7.4 Notify cleanup is complete;

## Rules

- **Metadata Specification**
  - The description follows the format: first sentence states what the skill can do, second sentence states the trigger condition ("Use when..."), uses third person, no more than 1024 characters;
- **Structure Specification**
  - The standard directory only applies to SKILL.md itself, does not affect other files under the directory;
- **Content Specification**
  - Scan results and deletion summaries are both presented in table format;
  - Table column names are clear, including necessary dimensions such as "Reference Name / Type / Reason / Status";
  - The final cleanup report includes statistical counts for each dimension (Deleted / Skipped / Failed, etc.);
- **Behavior Specification**
  - Skipping when backup fails is not allowed; backup must succeed or the process must be terminated;
  - [dirty Worktrees](#脏-worktree) (with uncommitted changes) are automatically skipped, not entered into the deletion candidate list, and cannot be deleted;
  - [Protected branches](#保护分支) (refer to [references/protected-branch.md](references/protected-branch.md)) are automatically skipped and not entered into the scan list;
  - This skill is only allowed to run when the currently checked-out branch belongs to the [Protected branch](#保护分支) list; otherwise, terminate the process and prompt the user to run under a protected branch;
  - Remote deletion must go through a second confirmation; direct push deletion after the first confirmation is prohibited;
  - All interaction steps involving user decisions (confirming deletion, selecting operation mode, confirming [main branch](#主分支), etc.) **must** use the `AskUserQuestion` tool; plain text follow-up questions are prohibited; pass questions and options into AskUserQuestion in a structured manner, no more than 4 questions per call;
  - First scan all categories uniformly, then execute deletions uniformly; during the deletion phase, execute in the order Worktree -> Branch -> Tag;
  - First delete local references, then delete remote references (two-phase approach);
  - After overall completion, output the deletion summary, then proceed to second confirmation for remote deletion;
  - When a deletion command fails, record the failure reason and continue with subsequent deletions without interrupting the process;
  - **Defense levels**: Each entity follows a different defense level:
    - Worktree: scan script marks (is_dirty) -> AI excludes from candidate list -> delete script double-checks, 3 levels total;
    - Branch: scan script filters -> AI confirms candidate list with user -> delete script double-checks protected branches, 3 levels total;
    - Tag: scan script filters -> AI confirms candidate list with user, 2 levels total;
- **Defense Specification**
  - Before deleting any file, confirmation must be obtained from the user through interactive questioning;
- **Validation Specification**
  - Example content should be consistent with the latest Workflow steps;

## Examples

### Dialogue Interaction Examples

***Triggering the Skill***

```markdown
User > Help me clean up the stale Worktrees, branches, and tags in this repository
AI   > Triggering git-cleanup skill, starting pre-checks...
```

***Comprehensive scan -> One-time confirmation -> Unified execution***

```markdown
AI   > Scanning all categories of stale references using commands...
       - Worktree: git worktree list --porcelain
       - Branch: git branch --merged + git branch -vv
       - Tag: git tag -l + orphan tag detection
       
      Consolidated candidate table (grouped by category):
      | Category | Reference Name | Reason |
      |----------|----------------|--------|
      | Worktree | /path/to/linked-wt | Stale Worktree |
      | Worktree | /path/to/old-wt | Stale Worktree |
      | Branch | feature/old-login | Merged into main |
      | Branch | fix/temp-patch | Orphan branch (remote deleted) |
      | Tag | v0.1-alpha | Non-version Tag |
      | Tag | temp-tag-123 | Orphan Tag |
       
      Scanned a total of 6 stale references.

      ---
      Confirming Worktree (current step 2.2):
      [AskUserQuestion provides options: Yes, delete all / Select partial deletion / Skip]
User > Yes, delete all

      ---
      Confirming branches (current step 2.3):
      [AskUserQuestion provides options: Yes, delete all / Select partial deletion / Skip]
User > Yes, delete all

      ---
      Confirming Tags (current step 2.4):
      [AskUserQuestion provides options: Yes, delete all / Select partial deletion / Skip]
User > Yes, delete all

AI   > Executing deletions...
       Worktree: /path/to/linked-wt Success
       Worktree: /path/to/old-wt Success
       Branch: feature/old-login (git branch -d) Success
       Branch: fix/temp-patch (git branch -D) Success
       Tag: v0.1-alpha (git tag -d) Success
       Tag: temp-tag-123 (git tag -d) Success
       Deleted a total of 6 stale references.
```

***Nothing to Clean Up***

```markdown
AI   > Scan complete:
      - No stale Worktrees
      - No merged or orphan branches
      - No non-version or orphan Tags
      No deletion operations are needed.
      Backup path: ../my-project.bak.20260614T143052
      It is recommended to run this skill periodically to keep the repository clean.
```

***Select Partial Deletion***

```markdown
      ---
      Confirming Worktree (current step 2.2):
      [AskUserQuestion provides options: Yes, delete all / Select partial deletion / Skip]
User > Select partial deletion
AI   > Please specify the Worktree paths to delete (comma-separated):
User > /path/to/old-wt
      ---
      Confirming branches (current step 2.3):
      [AskUserQuestion provides options: Yes, delete all / Select partial deletion / Skip]
User > Skip
      ---
      Confirming Tags (current step 2.4):
      [AskUserQuestion provides options: Yes, delete all / Select partial deletion / Skip]
User > Yes, delete all
AI   > Executing deletions.../path/to/old-wt (git worktree remove) Success.
      temp-tag-123 (git tag -d) Success.
```

***Backup Recovery Example***

```markdown
# If recovery is needed due to accidental deletion, please execute the following commands:
rm -rf <repository-directory>
cp -a <backup-path>/<repo-name>.bak.<backup-timestamp> <repository-directory>
# Note: Rollback will overwrite all new changes made after the rollback point, please first confirm the current workspace state.
```

***Local Deletion Summary Example***

```markdown
AI   > Local deletion summary:
      - Worktree: 2 deleted, 1 skipped (has uncommitted changes)
      - Branches: 2 deleted (feature/old-login, fix/temp-patch)
      - Tags: 1 deleted (v0.1-alpha)
      - Auto-skipped: current Worktree, currently checked-out branch (main), protected branches (dev, stage, staging, prod, master, main)
```

***Remote Deletion Second Confirmation***

```markdown
AI   > The following changes will be pushed to the remote:
      - Branches: 2 deleted (feature/old-login, fix/temp-patch)
      - Tags: 1 deleted (v0.1-alpha)
      - Auto-skipped: current Worktree, currently checked-out branch (main), protected branches (dev, stage, staging, prod, master, main)

      Do you want to sync these changes to the remote?
      [AskUserQuestion provides options: Confirm push / Keep local deletion only / View details]
User > Confirm push
AI   > Pushing remote deletions...
      git push origin --delete feature/old-login (Success)
      git push origin --delete fix/temp-patch (Success)
      git push origin --delete refs/tags/v0.1-alpha (Success)
```

***Keep Local Deletion Only***

```markdown
AI   > Do you want to sync these changes to the remote?
      [AskUserQuestion provides options: Confirm push / Keep local deletion only / View details]
User > Keep local deletion only
AI   > Remote push skipped. Local changes:
       - Deleted Worktrees: /path/to/linked-wt, /path/to/old-wt
       - Deleted branches: feature/old-login, fix/temp-patch
       - Deleted Tags: v0.1-alpha
       - Backup path: ../my-project.bak.20260614T143052
      Note: The corresponding references on the remote have not been deleted. Please handle them manually.
```

***Dirty Worktree Auto-Skipped***

```markdown
      Worktree scan results:
      | Path | Associated Branch | Current | Dirty Status |
      |------|------------------|---------|--------------|
      | /path/to/wt1 | feature/new | No | Yes ⚠️ |
      | /path/to/wt2 | fix/bug | No | No |

      ⚠️ Detected 1 dirty Worktree (/path/to/wt1), has uncommitted changes, automatically skipped.
      Stale Worktree candidate list (deletable):
      | Path | Associated Branch |
      |------|------------------|
      | /path/to/wt2 | fix/bug |
```

***Non-Protected Branch Termination***

```markdown
AI   > [Currently checked-out branch: feature/my-task]
      Current branch 'feature/my-task' is not in the protected branch list (dev, stage, staging, prod, master, main),
      please run this skill under a protected branch.
      Process terminated.
```

### Review Check Example

```markdown
AI > Entering review check. The Review List contains 18 items, starting verification one by one:

**Content Check**
  - 🟩 All Worktrees confirmed for deletion by the user have been successfully deleted
  - 🟩 All branches confirmed for deletion by the user have been successfully deleted
  - 🟩 All Tags confirmed for deletion by the user have been successfully deleted
  - 🟥 Remote deletion command execution failed (network error), deletions not pushed
  - 🟩 Scan results displayed in table format with clear column names
  - 🟩 ... (All remaining check items passed)

**Behavior Check**
  - 🟩 `cp -a` backup created before execution, path and naming correct
  - 🟩 `git fetch -p` executed, remote tracking pruned
  - 🟩 Current Worktree and currently checked-out branch were not included in the deletion list
  - 🟩 Protected branches were not included in the deletion list
  - 🟩 Second confirmation obtained before remote deletion
  - 🟩 Followed the workflow: "Comprehensive scan -> One-time confirmation -> Unified execution (Worktree -> Branch -> Tag)"
  - 🟩 Followed the two-phase deletion workflow: "local first, remote second"

**!!! The following check items did not pass !!!**
  - 🟥 Remote deletion failed (network error)

[AskUserQuestion provides options: Retry the failed step / Skip the failed item and continue / Terminate flow]

User > Terminate flow
AI   > Process terminated. It is recommended to manually check the network connection and then re-execute the remote sync.
```

### Output Example

**Example of Git Worktree, Branch and Tag Cleanup Execution Results:**

```markdown
## Cleanup Complete

The Git repository cleanup operation has been completed. Below is the execution summary:

| Item | Count |
|------|-------|
| Stale Worktrees scanned | 2 |
| Stale branches scanned | 3 |
| Stale Tags scanned | 2 |
| Locally deleted Worktrees | 2 |
| Locally skipped Worktrees (dirty) | 1 |
| Locally deleted branches | 2 |
| Locally deleted Tags | 2 |
| Remotely deleted branches | 2 |
| Remotely deleted Tags | 2 |
| Auto-skipped (current Worktree + current/protected branches + dirty Worktrees) | 4 |
| User refused deletion | 1 (test/experiment) |
| Backup path | ../my-project.bak.20260614T143052 |

All deletion operations completed, no unfinished operations.
```

## Review List

- **Content Check**
  - [ ] All Worktrees confirmed for deletion by the user have been successfully deleted (or failure reasons recorded)
  - [ ] All branches confirmed for deletion by the user have been successfully deleted (or failure reasons recorded)
  - [ ] All Tags confirmed for deletion by the user have been successfully deleted (or failure reasons recorded)
  - [ ] Remote deletion commands executed correctly, no push errors
  - [ ] Consolidated candidate table displayed grouped by Worktree/Branch/Tag, including count statistics for each group
  - [ ] Deletion summary includes statistics for each dimension (Deleted / Skipped / Failed)
  - [ ] Final cleanup report includes statistics for both local and remote dimensions
- **Behavior Check**
  - [ ] `git fetch -p` has been executed, remote-tracking references pruned (or confirmed skipped when no remote is configured)
  - [ ] `cp -a` backup created before execution, path and naming correct
  - [ ] [dirty Worktrees](#脏-worktree) (with uncommitted changes) were not included in the deletion candidate list
  - [ ] [Protected branches](#保护分支) (user-configured list) were not included in the deletion list
  - [ ] Checked whether the currently checked-out branch is a [Protected branch](#保护分支) before execution
  - [ ] Second confirmation obtained before remote deletion
  - [ ] Followed the workflow of "Comprehensive scan -> One-time confirmation -> Unified execution (Worktree -> Branch -> Tag)"
  - [ ] Followed the "local first, remote second" two-phase deletion workflow
  - [ ] On abnormal exit, correctly jumped to the abnormal exit handling step and output recovery guidance
- **Defense Check**
  - [ ] When a deletion command failed, the failure reason was correctly recorded and subsequent deletions continued
- **Validation Check**
  - [ ] No interruption signs: no unfinished deletion operations

## References

- [protected-branch.md](references/protected-branch.md) — Protected branch list definition and detached HEAD detection logic;
