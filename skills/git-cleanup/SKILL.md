---
name: git-cleanup
description: Clean up stale Worktrees, branches, and tags in a Git repository. Includes non-current Worktrees, merged branches, orphan branches, non-version tags, and orphan tags. Use when the user requests cleaning or organizing Git Worktrees/branches/tags, finds residual local references after remote deletion, or mentions "clean up stale branches/unnecessary tags".
---

# Git Cleanup

## Overview

Systematically clean up stale Worktrees, branches, and tags in a Git repository. Operates in a "comprehensive scan -> single confirmation -> unified deletion" flow: first scan all categories (Worktree/branch/tag) at once, then confirm deletions with the user in one pass, execute deletion uniformly, and after secondary confirmation, delete remote references uniformly. Automatically creates a backup before execution.

## Definitions

- <a id="Stale-Branch"></a>**Stale Branch**: A branch meeting any of the following conditions:
    - **Merged branch**: A local branch that has been merged into the main branch;
    - **Orphan branch**: A local branch whose remote tracking branch no longer exists after executing `git fetch -p` (displays `: gone]`);
- <a id="Stale-Tag"></a>**Stale Tag**: A tag meeting any of the following conditions:
    - **Non-version tag**: A tag that does not match the semantic versioning pattern (e.g., `v1.2.3`, `1.2.3`, `v1.2.3-beta.1`);
    - **Orphan tag**: A tag pointing to a commit that is not referenced by any local or remote branch;
- <a id="Stale-Worktree"></a>**Stale Worktree**: Non-current Worktree (Worktrees outside the user's current working directory);
- <a id="Current-Worktree"></a>**Current Worktree**: The Worktree corresponding to the user's current working directory, automatically skipped and cannot be deleted;
- <a id="Main-Branch"></a>**Main Branch**: The primary development branch of the repository (e.g., `main` or `master`), auto-detected by the AI and confirmed with the user;
- <a id="Protected-Branch"></a>**Protected Branch**: The main branch and `develop` branch, automatically skipped and cannot be deleted;
- <a id="Current-Checked-Out-Branch"></a>**Current Checked-out Branch**: The branch pointed to by `HEAD`, automatically skipped and cannot be deleted.
- <a id="Worktree-Bound-Branch"></a>**Worktree-bound Branch**: A branch that has been checked out by a Worktree, automatically skipped and cannot be deleted;

## Prerequisites

- Git 2.0+;
- Currently in a Git repository directory (verifiable via `git rev-parse --git-dir`);
- `jq` (JSON processor, required by check-env.sh / scan.sh / delete.sh / setup.sh and other scripts);
- User has push permissions to the remote repository (if remote deletion is required).

## Workflow

0. **Pre-check** — Ensure the environment is ready;
  0.1 Execute environment check (`bash scripts/check-env.sh`):
    - Check if the script executed successfully:
      - Success -> Parse JSON, check for "error" field:
        - Present -> Report script error (e.g., missing jq dependency), terminate flow;
        - Absent -> Report each check result:
      - "in-git-repo" failed -> Report "Not in a Git repository", terminate flow;
      - "git-version" failed -> Prompt to upgrade Git to 2.0+, terminate flow;
      - "fetch-prune" failed -> Record failure reason, continue execution;
      - "has-remote" -> Store the result (used in step 4.1 for remote deletion);
    - All checks passed -> Proceed to step 0.2;
  0.2 Execute environment setup (`bash scripts/setup.sh`):
    - Check if the script executed successfully:
      - Success -> Parse JSON, check for "error" field:
        - Present -> Report script error (e.g., missing jq dependency), terminate flow;
        - Absent -> Read the following information:
      - main_branch_candidate -> Auto-detected main branch name;
      - current_worktree -> Current Worktree path;
      - current_branch -> Current checked-out branch;
      - backup_created / backup_path -> Backup status and path;
    - Check if backup was created successfully:
      - Success -> Proceed to step 0.3;
      - Failed -> Report "Backup creation failed", terminate flow;
  0.3 Confirm main branch — Provide options via AskUserQuestion, block and wait for user selection:
    - Main branch detected -> Provide options:
      - Confirm main branch name -> Use that name, proceed to step 1;
      - Manually specify another branch -> User enters branch name, proceed to step 1;
    - Main branch not detected -> Provide options:
      - Manually specify main branch name -> User enters branch name, proceed to step 1;

1. **Comprehensive scan** — Execute scan script, output three category JSON arrays;
  1.1 Execute scan script (`bash scripts/scan.sh --main-branch <main_branch>`):
    - Check if the script executed successfully:
      - Success -> Parse JSON, check for "error" field:
        - Present -> Report script error (e.g., missing jq dependency), terminate flow;
        - Absent -> Get worktrees, branches, and tags arrays;
      - Failure -> Report "Scan script execution failed", terminate flow;
  1.2 Check if all three arrays are empty:
    - Yes -> Report "No stale references found to clean up", terminate flow;
    - No -> Proceed to step 2;

2. **Category confirmation** — Display scan results by category, confirm deletion for each;
  2.1 Display scan results — Render the three JSON arrays as Markdown tables:
      - Worktree table (columns: Path / Linked Branch / Is Current);
      - Branch table (columns: Branch Name / Type / Reason);
      - Tag table (columns: Tag Name / Type / Reason);
  2.2 Confirm Worktree — Provide options via AskUserQuestion, block and wait for user selection:
      - Yes, delete all non-current Worktrees -> Mark all for deletion, proceed to 2.3;
      - Select partial deletion -> Prompt user to enter paths (comma-separated), confirm, proceed to 2.3;
      - Skip -> Proceed to 2.3;
  2.3 Confirm branches — Provide options via AskUserQuestion, block and wait for user selection:
      - Yes, delete all stale branches -> Mark all for deletion, proceed to 2.4;
      - Select partial deletion -> Prompt user to enter branch names (comma-separated), confirm, proceed to 2.4;
      - Skip -> Proceed to 2.4;
  2.4 Confirm tags — Provide options via AskUserQuestion, block and wait for user selection:
      - Yes, delete all stale tags -> Mark all for deletion, proceed to 2.5;
      - Select partial deletion -> Prompt user to enter tag names (comma-separated), confirm, proceed to 2.5;
      - Skip -> Proceed to 2.5;
  2.5 Check if any references are marked for deletion:
      - Yes (items exist) -> Proceed to step 3;
      - No (all skipped) -> Report "No items selected for deletion", terminate flow;

3. **Unified execution** — Use deletion script to execute all confirmed deletions;
  3.1 Execute deletion script (`bash scripts/delete.sh --worktrees '<json>' --branches '<json>' --tags '<json>'`):
    - Check if the script executed successfully:
      - Failure -> Report "Deletion script execution failed", go to step 5 (Abnormal exit handling);
      - Success -> Parse JSON;
      - Example data structure:
        - `--worktrees '[{"path":"/path/to/wt"}]'`
        - `--branches '[{"name":"feature/old","type":"merged"},{"name":"fix/temp","type":"orphan"}]'`
        - `--tags '[{"name":"v0.1-alpha","type":"non-version"},{"name":"temp-tag","type":"orphan"}]'`
    - Parse returned JSON result array, output deletion results (success/failure) line by line;
    - When Worktree deletion fails, ask the user via AskUserQuestion whether to attempt force deletion (`git worktree remove --force <path>`):
      - Yes -> Execute force deletion and output the result;
      - No -> Skip this Worktree, continue processing subsequent deletions;
  3.2 Output local deletion summary table (statistics of success/failure counts), see [Local Deletion Summary Example](#local-deletion-summary-example);
  3.3 Proceed to step 4;

4. **Remote deletion** — Execute remote deletion after secondary confirmation;
  4.1 Get the has-remote result from step 0.1 check-env, check if there are local deletions:
      - Remote exists and there are local deletions -> Provide options via AskUserQuestion, block and wait for user selection:
        - Confirm pushing remote deletion -> Proceed to 4.2;
        - Keep only local deletion -> Proceed to 4.3;
      - Remote does not exist or no local deletions -> Report "No changes to sync to remote", proceed to step 6;
  4.2 Execute remote deletion script (`bash scripts/remote-delete.sh --branches '<json>' --tags '<json>'`):
    - Check if the script executed successfully:
      - Failure -> Report "Remote deletion script execution failed", go to step 5 (Abnormal exit handling);
      - Success -> Parse JSON;
      - Example data structure:
        - `--branches '[{"name":"feature/old-login"}]'`
        - `--tags '[{"name":"temp-tag-123"}]'`
      - Parse returned JSON, output deletion results line by line;
  4.3 Output final cleanup report (local + remote deletion statistics);

5. **Abnormal exit handling** — Output recovery guidance, jump here on abnormal exit during any deletion step;
  5.1 Check step 0.2 setup.sh output for backup_created result:
    - Yes -> Output backup path and recovery command, see [Backup Recovery Example](#backup-recovery-example);
    - No -> Report "No backup available, please check repository status";
  5.2 Output summary of completed deletion operations in this run (list of deleted Worktrees/Branches/Tags, if any);
  5.3 Inform the user that execution has been safely terminated, provide manual recovery suggestions and backup path information, terminate flow.

6. **Review check** — Compare against [Review List](#review-list), confirm execution results;
  6.1 Check if Review List has content:
    - No -> Directly proceed to next step (output results);
    - Yes -> Next step;
  6.2 Check each item in [Review List](#review-list) sequentially for pass/fail (based on content displayed in "review check example"):
    - Pass -> Continue to next item;
    - Fail -> Provide options via AskUserQuestion, block and wait for user selection:
      - Retry failed step -> Return to corresponding step and re-execute;
      - Skip failed item and continue -> Mark as incomplete, proceed to output results;
      - Terminate flow -> Terminate flow;
  6.3 All passed -> Proceed to next step (output results);

7. **Output results** — Output cleanup summary, backup path, and rollback guidance, inform completion;
  7.1 Output structured summary (including statistics for each dimension cleaned in this run);
  7.2 Output backup path and recovery command (see [Backup Recovery Example](#backup-recovery-example))
  7.3 Remind the user to confirm the current working state and the correctness of the backup path before rollback;
  7.4 Inform that cleanup is complete;

## Rules

- **Metadata Specification**
  - Description follows the format: first sentence describes what the skill does, second sentence describes trigger conditions ("Use when..."), use third person, no more than 1024 characters;
- **Structure Specification**
  - Standard directory applies only to SKILL.md itself, does not affect other files in the directory;
- **Content Specification**
  - Scan results and deletion summaries should be presented in table format;
  - Table column names should be clear, including necessary dimensions such as "Reference Name / Type / Reason / Status";
  - Final cleanup report should include statistics for each dimension (Deleted / Skipped / Failed, etc.);
- **Behavioral Specification**
  - Backup failure must not be skipped; backup must succeed or the flow must terminate;
  - [Current Worktree](#Current-Worktree) and [Current Checked-out Branch](#Current-Checked-Out-Branch) are automatically skipped and not included in the scan list;
  - [Worktree-bound Branch](#Worktree-Bound-Branch) is automatically skipped and not included in the deletion candidate list;
  - [Protected Branches](#Protected-Branch) ([Main Branch](#Main-Branch) + `develop`) are automatically skipped and not included in the scan list;
  - Remote deletion must go through secondary confirmation; direct push deletion after the first confirmation is prohibited;
  - All interactive steps involving user decision-making (confirming deletion, selecting operation mode, confirming [Main Branch](#Main-Branch), etc.) **must** use the `AskUserQuestion` tool; do not use plain text follow-up questions as a substitute; pass questions and options structured into AskUserQuestion, no more than 4 questions per call;
  - First scan all categories uniformly, then execute deletion uniformly; deletion follows Worktree → Branch → Tag order;
  - First delete local references, then delete remote references (two-phase process);
  - After overall completion, output deletion summary, then perform remote deletion secondary confirmation;
  - When a deletion command fails, record the failure reason and continue executing subsequent deletions; do not interrupt the flow;
- **Defensive Specification**
  - Confirm with the user through interactive questioning before deleting any files;
- **Validation Specification**
  - Example content should be consistent with the latest Workflow steps;

## Examples

### Dialogue Interaction Examples

***Trigger Skill***

```markdown
User > Help me clean up the stale Worktrees, branches, and tags in this repository
AI   > Triggering git-cleanup skill, starting pre-checks...
```

***Comprehensive Scan → Single Confirmation → Unified Execution***

```markdown
AI   > Scanning all categories of stale references using commands...
       - Worktree：git worktree list --porcelain
       - Branch：git branch --merged + git branch -vv
       - Tag：git tag -l + Orphan tag detection
       
      Consolidated candidate table (grouped by category):
      | Category | Reference Name | Reason |
      |----------|----------------|--------|
      | Worktree | /path/to/linked-wt | Non-current Worktree |
      | Worktree | /path/to/old-wt | Non-current Worktree |
      | Branch | feature/old-login | Merged into main |
      | Branch | fix/temp-patch | Orphan branch (remote deleted)|
      | Tag | v0.1-alpha | Non-version tag |
      | Tag | temp-tag-123 | Orphan tag |
       
      Scanned 6 stale references total.

      ---
      Confirm Worktree (current step 2.2):
      [AskUserQuestion providing options: Yes, delete all / Select partial / Skip]
User > Yes, delete all

      ---
      Confirm branches (current step 2.3):
      [AskUserQuestion providing options: Yes, delete all / Select partial / Skip]
User > Yes, delete all

      ---
      Confirm tags (current step 2.4):
      [AskUserQuestion providing options: Yes, delete all / Select partial / Skip]
User > Yes, delete all

AI   > Executing deletion...
       Worktree：/path/to/linked-wt succeeded
       Worktree：/path/to/old-wt succeeded
       Branch：feature/old-login（git branch -d）succeeded
       Branch：fix/temp-patch（git branch -D）succeeded
       Tag：v0.1-alpha（git tag -d）succeeded
       Tag：temp-tag-123（git tag -d）succeeded
       Total 6 stale references deleted.
```

***Nothing to Clean***

```markdown
AI   > Scan complete:
      - No non-current Worktrees
      - No merged or orphan branches
      - No non-version or orphan tags
      No deletion operations needed.
      Backup path：../my-project.bak.20260614T143052
      It is recommended to run this skill periodically to keep the repository clean.
```

***Select Partial Deletion***

```markdown
      ---
      Confirm Worktree (current step 2.2):
      [AskUserQuestion providing options: Yes, delete all / Select partial / Skip]
User > Select partial
AI   > Please specify Worktree paths to delete (comma-separated):
User > /path/to/old-wt
      ---
      Confirm branches (current step 2.3):
      [AskUserQuestion providing options: Yes, delete all / Select partial / Skip]
User > Skip
      ---
      Confirm tags (current step 2.4):
      [AskUserQuestion providing options: Yes, delete all / Select partial / Skip]
User > Yes, delete all
AI   > Executing deletion.../path/to/old-wt（git worktree remove）succeeded.
      temp-tag-123（git tag -d）succeeded.
```

<a id="backup-recovery-example"></a>***Backup Recovery Example***

```markdown
# To restore after accidental deletion, execute the following command:
rm -rf <repository_directory>
cp -a <backup_path>/<repo_name>.bak.<backup_timestamp> <repository_directory>
# Note: Rollback will overwrite all new changes after the checkpoint. Please confirm the current working state first.
```

<a id="local-deletion-summary-example"></a>***Local Deletion Summary Example***

```markdown
AI   > Local deletion summary:
      - Worktree: 2 deleted
      - Branches: 2 deleted (feature/old-login, fix/temp-patch)
      - Tags: 1 deleted (v0.1-alpha)
      - Auto-skipped: Current Worktree, Current Checked-out Branch (main), Protected Branch (develop)
```

***Remote Deletion Secondary Confirmation***

```markdown
AI   > Local deletion summary:
      - Worktree: 2 deleted
      - Branches: 2 deleted (feature/old-login, fix/temp-patch)
      - Tags: 1 deleted (v0.1-alpha)
      - Auto-skipped: Current Worktree, Current Checked-out Branch (main), Protected Branch (develop)

      Sync these changes to remote?
      [AskUserQuestion providing options: Confirm push / Keep local only / View details]
User > Confirm push
AI   > Pushing remote deletion...
      git push origin --delete feature/old-login (succeeded)
      git push origin --delete fix/temp-patch (succeeded)
      git push origin --delete refs/tags/v0.1-alpha (succeeded)
```

***Keep Local Only***

```markdown
AI   > Sync these changes to remote?
      [AskUserQuestion providing options: Confirm push / Keep local only / View details]
User > Keep local only
AI   > Skipped remote push. Local changes:
       - Deleted Worktree：/path/to/linked-wt、/path/to/old-wt
       - Deleted Branches：feature/old-login、fix/temp-patch
       - Deleted Tags：v0.1-alpha
       - Backup path：../my-project.bak.20260614T143052
      Note: Corresponding references in the remote repository have not been deleted. Please handle manually.
```

### Review Check Example

```markdown
AI > Entering review check. Review List contains 16 items, starting verification:

**Content Check**
  - 🟩 All user-confirmed Worktrees successfully deleted
  - 🟩 All user-confirmed branches successfully deleted
  - 🟩 All user-confirmed tags successfully deleted
  - 🟥 Remote deletion command failed (network error), deletion not pushed
  - 🟩 Scan results presented in table format, column names clear
  - 🟩 ...(remaining items all passed)

**Behavior Check**
  - 🟩 `cp -a` backup created before execution, path and naming correct
  - 🟩 `git fetch -p` executed, remote tracking pruned
  - 🟩 Current Worktree and current checked-out branch not included in deletion list
  - 🟩 Protected branches not included in deletion list
  - 🟩 Secondary confirmation obtained before remote deletion
  - 🟩 Followed "comprehensive scan → single confirmation → unified execution (Worktree → Branch → Tag)" flow
  - 🟩 Followed "local first, then remote" two-phase deletion flow

**!!! The following checks FAILED !!!**
  - 🟥 Remote deletion failed (network error)

[AskUserQuestion providing options: Retry failed step / Skip failed item and continue / Terminate flow]

User > Terminate flow
AI   > Flow terminated. It is recommended to manually check network connectivity and re-execute remote sync.
```

### Output Example

**Git Worktree, Branch & Tag Cleanup Execution Effect Example:**

```markdown
## Cleanup Complete

The Git repository cleanup operation has been executed. Here is the execution summary:

| Item | Count |
|------|-------|
| Scanned stale Worktrees | 2 |
| Scanned stale branches | 3 |
| Scanned stale tags | 2 |
| Locally deleted Worktrees | 2 |
| Locally deleted branches | 2 |
| Locally deleted tags | 2 |
| Remotely deleted branches | 2 |
| Remotely deleted tags | 2 |
| Auto-skipped (Current Worktree + Current/Protected Branch) | 3 |
| User declined to delete | 1 (test/experiment) |
| Backup path | ../my-project.bak.20260614T143052 |

All deletion operations completed. No incomplete operations.
```

## Review List

- **Content Check**
  - [ ] All user-confirmed Worktrees successfully deleted (or failure reason recorded)
  - [ ] All user-confirmed branches successfully deleted (or failure reason recorded)
  - [ ] All user-confirmed tags successfully deleted (or failure reason recorded)
  - [ ] Remote deletion commands executed correctly with no push errors
  - [ ] Consolidated candidate table grouped by Worktree/Branch/Tag, including count per group
  - [ ] Deletion summary includes statistics for each dimension (Deleted / Skipped / Failed)
  - [ ] Final cleanup report includes both local and remote statistics
- **Behavior Check**
  - [ ] `git fetch -p` executed, remote tracking references pruned (or confirmed skipped when no remote configured)
  - [ ] `cp -a` backup created before execution, path and naming correct
  - [ ] [Current Worktree](#Current-Worktree) and [Current Checked-out Branch](#Current-Checked-Out-Branch) not included in deletion list
  - [ ] [Worktree-bound Branch](#Worktree-Bound-Branch) not included in deletion candidate list
  - [ ] [Protected Branches](#Protected-Branch) ([Main Branch](#Main-Branch) + develop) not included in deletion list
  - [ ] Secondary confirmation obtained before remote deletion
  - [ ] Followed "comprehensive scan → single confirmation → unified execution (Worktree → Branch → Tag)" flow
  - [ ] Followed "local first, then remote" two-phase deletion flow
  - [ ] On abnormal exit, correctly jumped to abnormal exit handling step and output recovery guidance
- **Defensive Check**
  - [ ] When deletion command failed, correctly recorded failure reason and continued subsequent deletions
- **Validation Check**
  - [ ] No interruption signs: no incomplete deletion operations

## References

None (this skill has simple content and does not require external reference documents).
