---
name: git-commit-helper
description: Generate Git commit messages following the Conventional Commits specification. Use when the user requests help writing commit messages, reviewing staged changes, or mentions "commit" or "commit message".
---

# Git Commit Helper

## Overview

Intelligently generate Git commit messages following the Conventional Commits specification. All generated commit messages are written in English.

## Definitions

- <a id="Conventional Commits"></a>**Conventional Commits**: A lightweight convention built on commit messages, conveying change intent through structured elements (type, scope, description, etc.).
- <a id="Commit Message"></a>**Commit Message**: A Git commit message containing subject, body and footer, following the format `<type>[scope][!]: <description>`.
- <a id="Type"></a>**Type**: The prefix noun of a Commit, indicating the category of change. Valid values include feat, fix, docs, style, refactor, perf, test, build, ci, chore, revert, etc.
- <a id="Scope"></a>**Scope**: An optional parameter wrapped in parentheses after the type, indicating the module/location affected by the change, e.g. `feat(auth):`.
- <a id="Subject"></a>**Subject**: The first line of the Commit message, formatted as `<type>[scope][!]: <description>`, no more than 50 characters.
- <a id="Body"></a>**Body**: The detailed explanation starting after a blank line following the Subject, describing "what" was done and "why".
- <a id="Footer"></a>**Footer**: An optional section after the Body, used to mark breaking changes (`BREAKING CHANGE:`) or reference Issues (e.g. Closes #123).
- <a id="BREAKING-CHANGE"></a>**BREAKING CHANGE**: A change that causes API or behavioral incompatibility, marked with `!` after the type/scope, or with `BREAKING CHANGE:` at the beginning of the footer.
- <a id="Description"></a>**Description**: A brief explanation after the colon in the Subject, starting with a lowercase verb in present tense, without a trailing period.
- <a id="是否对话-Diff-路径"></a>**Conversation Diff Path**: Marks whether the current mode is one where the user provides diff directly in the conversation. Set to true by step 0.2 when the conversation diff passes validation, skipping steps 0.3~0.6 and steps 1~2, going directly to step 3.
- <a id="暂存区"></a>**Staging Area**: The location where changes are staged after executing `git add`, viewable with `git diff --staged`.
- <a id="工作区"></a>**Working Directory**: The modification status of tracked files in the current working directory, viewable with `git diff`.
- <a id="根提交"></a>**Root Commit**: The first commit in a repository, with no parent commits. Use `git show` instead of `git diff` to view changes for such commits.
- <a id="未跟踪文件"></a>**Untracked File**: A new file not yet tracked by Git, not included in any `git diff` output, detected via `git status --short`.
- <a id="分支范围"></a>**Branch Range**: A Git range expression used to compare differences between two branches/commits (e.g. `main..feature`), obtaining changes via `git log <range> -p`.

## Prerequisites

- **Standard Path** (obtaining changes via Git):
  - Git 2.0+
  - Must be in a Git repository directory
  - There must be Git changes available for analysis (staged changes, working directory changes, specific commit, or branch range)
- **Conversation Diff Path** (user provides diff directly in the conversation):
  - No Git environment required; skip Git-related checks
  - Expected format is standard unified diff format, or other analyzable change descriptions
  - If the format cannot be parsed, prompt the user to provide a standard diff format

## Workflow

0. **Pre-checks** — Ensure the commit environment is ready;
  0.1 Initialize the global variable [Conversation Diff Path](#是否对话-Diff-路径) to false;
  0.2 Check if the user has provided diff content in the conversation:
    - Yes -> Validate if the diff format is parseable:
      - Yes -> Set [Conversation Diff Path](#是否对话-Diff-路径) to true, skip steps 0.3~0.6 and steps 1~2, go directly to step 3;
      - No -> Inform the user the diff format cannot be parsed, provide options via AskUserQuestion, blocking until user selects:
        - Switch to Git path -> Jump to step 0.3, enter the Git path check flow;
        - Cancel -> Terminate the flow;
    - No -> Next step;
  0.3 Check if in a Git repository:
    - Yes -> Next step;
    - No -> Report "Not currently in a Git repository", terminate the flow;
  0.4 Check if Git version is >= 2.0:
    - Yes -> Next step;
    - No -> Prompt to upgrade Git, terminate the flow;
  0.5 Detect if in a conflict state:
    - Whether in a merge conflict (check if `$(git rev-parse --git-dir)/MERGE_MSG` exists):
      - Yes -> Inform the user there is a merge conflict, terminate the flow;
      - No -> Next step;
    - Whether in a cherry-pick conflict (check if `$(git rev-parse --git-dir)/CHERRY_PICK_HEAD` exists):
      - Yes -> Inform the user there is a cherry-pick conflict, terminate the flow;
      - No -> Next step;
    - Whether in a revert conflict (check if `$(git rev-parse --git-dir)/REVERT_HEAD` exists):
      - Yes -> Inform the user there is a revert conflict, terminate the flow;
      - No -> Next step;
    - Whether in a rebase conflict (check if `$(git rev-parse --git-dir)/rebase-merge/REBASE_HEAD` or `$(git rev-parse --git-dir)/rebase-apply/` exists):
      - Yes -> Inform the user there is a rebase conflict, terminate the flow;
      - No -> Next step;
  0.6 Detect if there are unstaged or untracked changes in the working directory (via `git status --porcelain`):
    - Yes (unstaged/untracked changes exist) -> execute `git add .`, proceed to step 0.7;
    - No (working directory clean) -> proceed to step 0.7;
  0.7 Check if there are Git changes available for analysis (staging/working directory/commit/branch range):
    - Yes -> Next step (enter step 1);
    - No -> Inform the user there are no changes to analyze, terminate the flow;

1. **Determine input source** — Identify the source of change information;
   1.1 Determine the type of user input:
       - User has specified the change source intent (staging area/recent commit/branch range, etc.) -> Map directly to the corresponding scenario, enter step 2;
       - User has provided a commit id or branch range -> Enter step 2;
       - User has not provided any change information, but the staging area has content -> Scenario A, enter step 2;
       - User has not provided any change information -> Provide options via AskUserQuestion, blocking until user selects:
         - Staging area -> Scenario A, enter step 2;
         - Specific commit -> Get the user-input commit ID via AskUserQuestion (leave empty to default to HEAD), blocking until user input; after user input -> Scenario B, enter step 2;
         - Branch range -> Scenario C, enter step 2 (the branch range will be used to generate a single squash-style commit message);

2. **Get diff** — Retrieve change content based on the input source;
   2.1 Map to the corresponding scenario based on step 1's result ("recent commit" falls under Scenario B, with commit as HEAD):
       - Scenario A (staging area): Run `git diff --staged`:
         - Result is empty -> Inform the user there are no staged changes, terminate the flow;
         - Result is non-empty -> Go to step 2.2;
       - Scenario B (single commit): Run `git rev-list --parents -n 1 <commit>` to detect root commit:
         - Command fails (commit does not exist or is invalid) -> Inform the user the commit does not exist, guide them to check and retry, terminate the flow;
         - Result contains only one commit hash (no parent) -> Root commit, use `git show <commit>` instead;
         - Result contains multiple commit hashes (has parent) -> Run `git diff <commit>^!`;
         - Go to step 2.2;
       - Scenario C (branch range): Run `git log <range> -p`:
         - Command fails (invalid range) -> Inform the user the branch range is invalid, guide them to check and retry, terminate the flow;
         - Result is empty (no difference in range) -> Inform the user there are no changes in the selected range, guide them to check the range and retry, terminate the flow;
         - Go to step 2.2;
   2.2 After retrieval, go to step 3;

3. **Analyze changes** — Analyze the diff content and determine the commit type;
   3.0 Open [conventional-commits.md](references/conventional-commits.md) to determine applicable commit types, analyze the change scope and core intent;
   3.1 Process by file type:
       - Non-binary files -> Analyze change content normally;
       - Binary files -> Only note the file name and change type, do not analyze content;
   3.2 Output the "Change Analysis Content" (count adds/modifications/deletions/renames/permission changes by non-binary/binary files), go to step 4;

4. **Generate commit message** — Generate candidate options and confirm the final output (ask 4.3 and 4.4 together);
   4.1 Generate candidate options — Based on analysis results, select 1~3 reasonable types, generate one candidate commit message for each:
       - If the change involves multiple natures (e.g. new feature + refactor) -> Consider multiple reasonable types;
       - If the change nature is clearly singular -> Generate only 1 candidate;
       - Each candidate strictly follows the [Review List](#review-list) requirements;
       - Output **multi-option commit messages**
   4.2 User selection — Present candidate options for user selection:
       - Provide options via AskUserQuestion, blocking until user selects:
         - Option 1 -> Go to 4.3;
         - Option 2 (if exists) -> Go to 4.3;
         - Option 3 (if exists) -> Go to 4.3;
   4.3 Breaking change confirmation — Check if the candidate includes a breaking change marker (`!` or `BREAKING CHANGE:`):
       - Yes -> Provide options via AskUserQuestion, blocking until user selects:
         - Yes, it is indeed a breaking change -> Keep the marker, go to 4.4;
         - No, remove the breaking change marker -> Remove the marker, go to 4.4;
       - No -> Go to 4.4;
   4.4 Link Issue — Ask the user if they want to link an Issue;
       - Provide options via AskUserQuestion, blocking until user selects:
         - Yes, link Issue -> User inputs Issue number (e.g. `#123`), append to footer, then go to 4.5;
         - No, do not link -> Go to 4.5;
   4.5 Output the user's confirmed choices (selected option, breaking change marker, linked Issue), no further confirmation needed from the user, go to step 5;

5. **Review check** — Verify the commit message against the [Review List](#review-list);
  - Check if the Review List has content:
    - No -> Go directly to step 6;
    - Yes -> Next step;
  - Check each item in the [Review List](#review-list) sequentially to see if it passes (output all check item results one by one, do not skip with abbreviations):
    - Yes -> Continue to the next check item;
    - No -> Record the failed check item, continue to the next check item;
  - Check if any item failed:
    - Yes -> Guide the user to handle manually, terminate the flow;
    - No -> Go to step 6;
6. **Output results** — Output the execution summary and notify completion;
   6.1 Output the final commit message and complete structured log (including pre-checks, candidate options, confirmation steps, final output dimensions in a summary table);
   6.2 Notify the user that execution is complete;

## Rules

- **Format Rules**
  - Strictly follow the format definition in [conventional-commits.md](references/conventional-commits.md): `<type>[optional scope][!]: <description>`;
  - [Subject](#Subject) should remain within 50 characters;
  - Start with a verb (add, implement, correct, refactor, etc.), use lowercase verb, present tense;
  - [Description](#Description) should not end with a period (`.`);
  - Optional [Scope](#Scope) is wrapped in parentheses after [Type](#Type), e.g., `feat(auth):`;
  - [Body](#Body) explains "what" and "why";
  - [Body](#Body) each line does not exceed 72 characters;
- **Type Rules**
  - [Type](#Type) uses valid values from the "Type" reference table in [conventional-commits.md](references/conventional-commits.md): feat (new feature), fix (bug fix), docs (documentation), style (formatting), refactor (refactoring), perf (performance), test (testing), build (build system), ci (CI/CD), chore (chores), revert (revert);
- **Content Rules**
  - Commit messages must be in English;
  - Keep it concise, do not over-generate content;
  - Must not include CI skip markers like `[skip ci]`;
  - For binary file changes, only note the file name and change type, do not analyze content;
  - Breaking changes are marked with [BREAKING CHANGE](#BREAKING-CHANGE) or `!`;
  - The `!` marker must be placed after [Type](#Type)/[Scope](#Scope) and before the colon;
  - Link related Issues (if any);
- **Behavioral Rules**
  - All user-interaction steps involving decisions (selecting candidate options, confirming breaking changes, linking Issues, etc.) **must** use the `AskUserQuestion` tool; using plain text follow-up questions is prohibited; pass questions and options into AskUserQuestion in a structured format, with a maximum of ≤4 questions per call; free-text input (such as Issue numbers) is not subject to this restriction;

## Examples

### Conversation Interaction Examples

**Analysis Change Content**

```markdown
AI > | Action     | Non-binary Files | Binary Files |
      |------------|------------------|--------------|
      | **Total**  | **5**            | **1**        |
      | Added      | 2                | 0            |
      | Modified   | 3                | 0            |
      | Renamed    | 0                | 0            |
      | Deleted    | 0                | 1            |
      | Permission | 0                | 0            |
```

**Multi-option Commit Message Output**

```markdown
AI > Based on the analysis, the following candidate options have been generated:
```

```markdown
--- Option 1 ---
feat(auth): add user login and role management

- Implement JWT authentication for user login
- Add role-based access control for admin endpoints
```

```markdown
--- Option 2 ---
feat(auth)!: add user login and role management

BREAKING CHANGE: restructured authentication system

- Implement JWT authentication for user login
- Add role-based access control for admin endpoints
```

**Summary of User's Confirmed Choices**

```markdown
AI > All your choices have been confirmed, ready to enter the review check:
     - Selected option: Option 2 — feat(auth)!: add user login and role management
     - Breaking change: Yes
     - Linked Issue: None
```

### Review Check Example

```markdown
AI > Entering review check. The Review List contains 13 items. Starting item-by-item verification:

**Format Check**
  - 🟩 subject does not exceed 50 characters
  - 🟩 description starts with a lowercase verb (add, implement, etc.), present tense

**Type Check**
  - 🟩 type uses valid values

**Content Check**
  - 🟩 commit message is in English
  - 🟩 binary files have been handled correctly

**Change Marker Check**
  - 🟩 breaking change has been correctly marked (`BREAKING CHANGE:` or `!`)
  - 🟩 linked Issue is correctly referenced

(Only representative passing items from each group are shown; the AI will output all 13 check item results one by one during runtime)

**!!! The following check items did NOT pass !!!**
  - 🟥 description starts with a lowercase verb (starts with a noun, should be a lowercase verb)
    Failed check. Return to the corresponding stage to regenerate based on the failed item type.
```

### Results Output Example

```markdown
【Pre-checks】
| Input Source   | File Range                          | Change Distribution          |
|----------------|-------------------------------------|------------------------------|
| Staged changes | Non-binary 5 / Binary 1 (image)     | Added 2 / Modified 3 / Deleted 0 / Renamed 0 |

【Candidate Options】
| Number of Candidates | Selected Option                             |
|----------------------|---------------------------------------------|
| 2                    | Option 1 — feat(auth): add user login…      |

【Confirmation】
| Breaking Change        | Linked Issue                  |
|------------------------|-------------------------------|
| No (confirmed by user) | #123 (Closes #123)            |

【Final Commit Message】

feat(auth): add user login and role management

- Implement JWT authentication for user login
- Add role-based access control for admin endpoints

Closes #123
```


## Review List

After generation, verify the following:

- **Format Check**
  - [ ] Strictly follows [conventional-commits.md](references/conventional-commits.md) format: `<type>[optional scope][!]: <description>`
  - [ ] [Subject](#Subject) does not exceed 50 characters
  - [ ] [Description](#Description) starts with a lowercase verb (add, implement, etc.), present tense, no trailing period
  - [ ] [Body](#Body) explains "what" and "why"
  - [ ] [Body](#Body) each line does not exceed 72 characters
- **Type Check**
  - [ ] [Type](#Type) uses valid values defined in [conventional-commits.md](references/conventional-commits.md)
- **Content Check**
  - [ ] Commit message is in English
  - [ ] Kept concise, not over-generated
  - [ ] Does not contain CI skip markers like `[skip ci]`
  - [ ] Binary files are handled correctly (only file name and change type noted, content not analyzed)
- **Change Marker Check**
  - [ ] Breaking change is correctly marked ([BREAKING CHANGE](#BREAKING-CHANGE) or `!`)
  - [ ] `!` marker is placed after [Type](#Type)/[Scope](#Scope) and before the colon
  - [ ] Linked Issue (if any) is correctly referenced

## References

- Conventional Commits specification details: see [conventional-commits.md](references/conventional-commits.md)
