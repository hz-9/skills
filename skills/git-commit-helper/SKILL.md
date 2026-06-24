---
name: git-commit-helper
description: Generate Git commit messages following the Conventional Commits specification. Use when the user requests help writing a commit message, reviewing staged changes, or mentions "commit" or "commit message".
---

# Git Commit Helper

## Overview

Intelligently generate Git commit messages following the Conventional Commits specification. All generated commit messages are in English.

## Definitions

- <a id="Conventional Commits"></a>**Conventional Commits**: A lightweight convention based on commit messages, conveying the intent of changes through structured elements (type, scope, description, etc.).
- <a id="Commit Message"></a>**Commit Message**: A Git commit message containing subject, body, and footer, following the `<type>[scope][!]: <description>` format.
- <a id="Type"></a>**Type**: The prefix noun of a commit indicating the category of change. Valid values include feat, fix, docs, style, refactor, perf, test, build, ci, chore, revert, etc.
- <a id="Scope"></a>**Scope**: An optional parameter wrapped in parentheses after the type, indicating the module/location affected by the change, e.g., `feat(auth):`.
- <a id="Subject"></a>**Subject**: The first line of a commit message in the format `<type>[scope][!]: <description>`, not exceeding 50 characters.
- <a id="Body"></a>**Body**: A detailed explanation starting with a blank line after the subject, describing "what" was done and "why".
- <a id="Footer"></a>**Footer**: An optional section after the body, used to mark breaking changes (BREAKING CHANGE:) or reference issues (e.g., Closes #123).
- <a id="BREAKING-CHANGE"></a>**BREAKING CHANGE**: A change that causes API or behavioral incompatibility, marked with `!` after the type/scope or starting a footer line with `BREAKING CHANGE:`.
- <a id="Description"></a>**Description**: A brief explanation after the colon in the subject, starting with a lowercase verb in simple present tense, without a trailing period.
- <a id="是否对话-Diff-路径"></a>**Conversation Diff Path**: Indicates whether the current mode is in a conversation directly providing a diff. Set to true by step 0.2 when conversation diff validation passes, skipping steps 0.3~0.6 and steps 1~2, going directly to step 3.
- <a id="暂存区"></a>**Staging Area**: The location where changes are staged after executing `git add`, viewed via `git diff --staged`.
- <a id="工作区"></a>**Working Directory**: The modification status of tracked files in the current working directory, viewed via `git diff`.
- <a id="根提交"></a>**Root Commit**: The first commit in a repository with no parent commit. Such commits use `git show` instead of `git diff` to view changes.
- <a id="未跟踪文件"></a>**Untracked File**: A new file not yet tracked by Git, not included in any `git diff` output, detected via `git status --short`.
- <a id="分支范围"></a>**Branch Range**: A Git range expression (e.g., `main..feature`) used to compare differences between two branches/commits, obtained via `git log <range> -p`.

## Prerequisites

- **Standard Path** (obtain changes via Git):
  - Git 2.0+
  - Currently in a Git repository directory
  - Git changes available for analysis (staged changes, working directory changes, specified commits, or branch ranges)
  - `scripts/check-env.sh` is executable (`bash scripts/check-env.sh` can run normally)
  - `jq` (JSON processor, required by `scripts/check-env.sh`)
- **Conversation Diff Path** (user provides diff directly in conversation):
  - No Git environment required; skip Git-related checks
  - Expected format is standard unified diff format, or other analyzable change descriptions
  - If the format cannot be parsed, prompt the user to provide a standard diff format

## Workflow

0. **Pre-check** — Ensure the commit environment is ready;
  0.1 Initialize global variable [Conversation Diff Path](#是否对话-Diff-路径):
      - Determine if the user has provided diff content in the conversation:
        - Yes -> Set [Conversation Diff Path](#是否对话-Diff-路径) to true;
        - No -> Set [Conversation Diff Path](#是否对话-Diff-路径) to false;
  0.2 Check if [Conversation Diff Path](#是否对话-Diff-路径) is true:
      - Yes -> Validate if the diff format is parseable:
        - Yes -> Skip steps 0.3 and steps 1~2, go directly to step 3;
        - No -> Inform the user the diff format cannot be parsed, provide options via AskUserQuestion, block and wait for user selection:
          - Switch to Git path -> Go to step 0.3, enter Git path check flow;
          - Cancel -> Terminate the flow;
      - No -> Proceed to step 0.3;
  0.3 Execute environment check (`bash scripts/check-env.sh`):
    - Check if the script executed successfully:
      - Success -> Parse JSON, check for "error" field:
        - Present -> Report script error (e.g., missing jq dependency), terminate flow;
        - Absent -> Report each check result:
      - "in-git-repo" failed -> Report "Not in a Git repository", terminate flow;
      - "git-version" failed -> Prompt to upgrade Git to 2.0+, terminate flow;
      - "conflict-state" failed -> Report the specific conflict type (merge/cherry-pick/revert/rebase), terminate flow;
      - "has-changes" failed -> Inform the user there are no changes to analyze, terminate flow;
    - All checks passed -> Proceed to step 0.4;
  0.4 Check if Git changes are available for analysis (has-changes from 0.3 passed / commit / branch range):
    - Yes -> Proceed to step 1;
    - No -> Inform the user there are no changes to analyze, terminate flow;

1. **Determine input source** — Identify the source of change information;
   1.1 Determine the type of user input:
       - User specifies the source of changes (staging area/recent commit/branch range, etc.) -> Directly map to the corresponding scenario, proceed to step 2;
       - User provides a commit id or branch range -> Proceed to step 2;
       - User does not provide any change information, but the staging area has content -> Scenario A, proceed to step 2;
       - User does not provide any change information -> Provide options via AskUserQuestion, block and wait for user selection:
         - Staging area -> Scenario A, proceed to step 2;
         - Specify a commit -> Obtain the commit ID entered by the user via AskUserQuestion (leave blank defaults to HEAD), block and wait for user input; after user input -> Scenario B, proceed to step 2;
         - Branch range -> Scenario C, proceed to step 2 (branch range will be generated as a squash-style single commit message);

2. **Get diff** — Retrieve change content based on input source;
   2.1 Map to the corresponding scenario based on the determination in step 1 ("recent commit" falls under scenario B with commit as HEAD):
       - Scenario A (staging area): Execute `git diff --staged`:
         - Result empty -> Inform the user there are no staged changes, terminate flow;
         - Result non-empty -> Proceed to step 2.2;
       - Scenario B (single commit): Execute `git rev-list --parents -n 1 <commit>` to detect root commit:
         - Command execution failed (commit does not exist or is invalid) -> Inform the user the commit does not exist, guide them to check and retry, terminate flow;
         - Result contains only one commit hash (no parent) -> Root commit, use `git show <commit>` instead;
         - Result contains multiple commit hashes (has parent) -> Execute `git diff <commit>^!`;
         - Proceed to step 2.2;
       - Scenario C (branch range): Execute `git log <range> -p`:
         - Command execution failed (invalid range) -> Inform the user the branch range is invalid, guide them to check and retry, terminate flow;
         - Result empty (no changes in range) -> Inform the user there are no changes in the selected range, guide them to check the range and retry, terminate flow;
         - Proceed to step 2.2;
   2.2 After retrieval, proceed to step 3;

3. **Analyze changes** — Analyze the diff content and determine the commit type, generate candidates;
   3.0 Open [conventional-commits.md](references/conventional-commits.md) to determine applicable commit types, analyze the scope of impact and core intent of the changes;
   3.1 Process by file type:
       - Non-binary files -> Normal analysis of change content;
       - Binary files -> Only mark the file name and change type, do not analyze content;
   3.2 Output [Change Analysis](#change-analysis);
   3.3 Generate candidate options — Based on analysis results, select 1~3 reasonable types, generate a candidate commit message for each:
       - If the changes involve multiple natures (e.g., new feature + refactor) -> Consider multiple reasonable types;
       - If the nature of the changes is clearly singular -> Generate only 1 candidate;
   3.4 Optimize candidates — Check and optimize each candidate against the [Review List](#review-list):
       - **Subject length control**: Force subject ≤ 50 characters, trim description if too long;
       - **Format specification**: Verify correct format of type, scope, and `!` marker;
       - **Content specification**: Confirm English usage, keep it concise, no `[skip ci]` etc.;
   3.5 Output **Commit Message Multi-option Output** (see [Commit Message Multi-option Output Example](#multi-option-output-example))

4. **Confirm commit message** — Present candidates to the user and complete interactive confirmation (4.1, 4.2, 4.3 should be asked as a group via AskUserQuestion);
    4.1 User selection — Present candidates for user selection:
        - Provide options via AskUserQuestion, block and wait for user selection:
          - Option 1 -> Record selection, proceed to next step;
          - Option 2 (if exists) -> Record selection, proceed to next step;
          - Option 3 (if exists) -> Record selection, proceed to next step;
    4.2 Breaking change confirmation — Provide options via AskUserQuestion, block and wait for user selection:
        - Yes -> Record selection, proceed to next step;
        - No -> Record selection, proceed to next step;
    4.3 Issue tracking — Ask the user if they want to link an Issue;
        - Yes -> Pause task, user enters Issue number (e.g., `#123`), after user input, proceed to next step;
        - No -> Record selection, proceed to next step;
    4.4 Candidate optimization — Update candidate information based on selections from 4.2 and 4.3;
    4.5 Output user-confirmed selections (output in [User Confirmation Summary Example](#user-confirmation-summary-example) format);

5. **Review check** — Compare against [Review List](#review-list), confirm commit message content;
  - Check if Review List has content:
    - No -> Directly proceed to step 6;
    - Yes -> Next step;
  - Check each item in [Review List](#review-list) sequentially for pass/fail (must output all items individually, not in abbreviated form):
    - Pass -> Continue to next item;
    - Fail -> Record failed item, continue to next item;
  - Check if any items failed:
    - Yes -> Guide the user to handle manually, terminate flow;
    - No -> Proceed to step 6; (see [Review Check Example](#review-check-example))
6. **Output results** — Output execution summary, inform completion;
   6.1 Output the final commit message and complete structured log (summary table containing pre-information, candidates, confirmation stage, final output, etc.);
   6.2 Inform the user that execution is complete;

## Rules

- **Format Specification**
  - Strictly follow the format defined in [conventional-commits.md](references/conventional-commits.md): `<type>[optional scope][!]: <description>`;
  - [Subject](#Subject) should be kept within 50 characters;
  - Use a verb at the beginning (add, implement, correct, refactor, etc.), use lowercase verb in simple present tense;
  - [Description](#Description) should not end with a period (.)
  - Optional [Scope](#Scope) should be wrapped in parentheses after [Type](#Type), e.g., `feat(auth):`;
  - [Body](#Body) should explain "what" was done and "why";
  - [Body](#Body) should not exceed 72 characters per line;
  - All commit messages must be in English
- **Type Specification**
  - [Type](#Type) should use valid values from the [conventional-commits.md](references/conventional-commits.md) "Types" reference table: feat (new feature), fix (bug fix), docs (documentation), style (formatting), refactor (refactoring), perf (performance), test (testing), build (build system), ci (CI), chore (maintenance), revert (rollback);
- **Content Specification**
  - Commit messages in English;
  - Keep it concise, don't over-generate content;
  - Do not include CI skip markers like `[skip ci]`;
  - When binary files are involved, only mark the file name and change type, do not analyze content;
  - Breaking changes should be marked with [BREAKING CHANGE](#BREAKING-CHANGE) or `!`;
  - The `!` marker must be placed after [Type](#Type)/[Scope](#Scope) and before the colon;
  - Reference related Issues (if any);
  - **Conflict handling**: Breaking change markers must be consistent with user confirmation; when the user's response conflicts with the candidate marker, automatically correct (remove `!` if candidate has it but user says no, add it if candidate doesn't have it but user says yes);
- **Behavioral Specification**
  - All interactive steps involving user decision-making (selecting candidates, confirming breaking changes, linking issues, etc.) **must** use the `AskUserQuestion` tool; do not use plain text follow-up questions as a substitute; pass questions and options structured into AskUserQuestion, no more than 4 questions per call; free-text input (such as Issue numbers) is not subject to this limitation;

## Examples

**Change Analysis**<a id="change-analysis"></a>

```markdown
AI > | Action   | Non-binary Files | Binary Files |
      |----------|------------|-----------|
      | **Total** | **5**      | **1**     |
      | Added    | 2          | 0         |
      | Modified | 3          | 0         |
      | Renamed  | 0          | 0         |
      | Deleted  | 0          | 1         |
      | Permission Changed | 0 | 0         |
```

<a id="multi-option-output-example"></a>**Commit Message Multi-option Output**

```markdown
AI > Based on the analysis, the following candidates are generated:
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

<a id="user-confirmation-summary-example"></a>**User Confirmation Summary Example**

```markdown
AI > Your selections have been confirmed, ready for review:
     - Selected option: Option 2 — feat(auth): add user login and role management
     - Breaking change: Yes (independently confirmed, candidate contains ! marker, retained)
     - Linked Issue: None
```

### <a id="review-check-example"></a>Review Check Example

```markdown
AI > Entering review check. Review List contains 13 items, starting verification:

**Format Check**
  - 🟩 subject does not exceed 50 characters
  - 🟩 description starts with a lowercase verb (add, implement, etc.), in simple present tense

**Type Specification Check**
  - 🟩 type uses a valid value

**Content Check**
  - 🟩 commit message is in English
  - 🟩 binary files are properly handled

**Change Marker Check**
  - 🟩 breaking changes are correctly marked (`BREAKING CHANGE:` or `!`)
  - 🟩 linked Issue is correctly referenced

(Only representative passing items from each group are shown here; AI will output all 13 check items individually when running)

**!!! The following checks FAILED !!!**
  - 🟥 description does not start with a lowercase verb (starts with a noun, should be a lowercase verb)
    Failed check, return to the corresponding step based on the failed item type to regenerate.
```

### <a id="output-example"></a>Output Example

```markdown
【Pre-information】
| Input Source  | File Scope                           | Change Distribution       |
|---------------|--------------------------------------|---------------------------|
| Staged changes| Non-binary 5 / Binary 1 (images)     | Added 2 / Modified 3 / Deleted 0 / Renamed 0 |

【Candidates】
| Candidate Count | Selected Option                       |
|-----------------|---------------------------------------|
| 2               | Option 1 — feat(auth): add user login…|

【Confirmation Stage】
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
  - [ ] Strictly follow [conventional-commits.md](references/conventional-commits.md) format: `<type>[optional scope][!]: <description>`
  - [ ] [Subject](#Subject) does not exceed 50 characters
  - [ ] [Description](#Description) starts with a lowercase verb (add, implement, etc.), in simple present tense, without trailing period
  - [ ] [Body](#Body) explains "what" was done and "why"
  - [ ] [Body](#Body) does not exceed 72 characters per line
- **Type Specification Check**
  - [ ] [Type](#Type) uses valid values defined in [conventional-commits.md](references/conventional-commits.md)
- **Content Check**
  - [ ] Commit message is in English
  - [ ] Kept concise, not over-generated
  - [ ] Does not contain `[skip ci]` or similar CI skip markers
  - [ ] Binary files are properly handled (only file name and change type marked, content not analyzed)
- **Change Marker Check**
  - [ ] Breaking changes are correctly marked ([BREAKING CHANGE](#BREAKING-CHANGE) or `!`)
  - [ ] `!` marker is placed after [Type](#Type)/[Scope](#Scope) and before the colon
  - [ ] Linked Issue (if any) is correctly referenced
  - [ ] When the user's response on breaking changes conflicts with the candidate marker, the marker has been correctly corrected (added/removed `!` and `BREAKING CHANGE:`)

## References

- Conventional Commits specification details: see [conventional-commits.md](references/conventional-commits.md)
