---
name: git-commit-helper
description: Generate Git commit messages following the Conventional Commits specification. Use when the user requests help writing a commit message, viewing staged changes, or mentions "commit" or "commit message".
---

# Git Commit Helper

## Overview

Intelligently generate Git commit messages that follow the Conventional Commits specification. All generated commit messages are written in English.

## Definitions

- <a id="Conventional Commits"></a>**Conventional Commits**: A lightweight convention built on commit messages, conveying change intent through structured elements (type, scope, description, etc.).
- <a id="Commit Message"></a>**Commit Message**: A Git commit message containing subject, body, and footer, following the `<type>[scope][!]: <description>` format.
- <a id="Type"></a>**Type**: The prefix noun of a commit indicating the category of change. Valid values include feat, fix, docs, style, refactor, perf, test, build, ci, chore, revert, etc.
- <a id="Scope"></a>**Scope**: An optional parameter wrapped in parentheses after the type, indicating the module/location affected by the change, e.g., `feat(auth):`.
- <a id="Subject"></a>**Subject**: The first line of the commit message, formatted as `<type>[scope][!]: <description>`, no more than 50 characters.
- <a id="Body"></a>**Body**: Detailed explanation starting on a new line after the subject, describing "what" and "why".
- <a id="Footer"></a>**Footer**: Optional section after the body, used to mark breaking changes (`BREAKING CHANGE:`) or reference issues (e.g., `Closes #123`).
- <a id="BREAKING-CHANGE"></a>**BREAKING CHANGE**: An incompatible change to API or behavior, marked with `!` after the type/scope or with `BREAKING CHANGE:` in the footer.
- <a id="Description"></a>**Description**: The brief explanation after the colon in the subject, starting with a lowercase verb, in present tense, without a trailing period.
- <a id="Conversation-Diff-Path"></a>**Conversation Diff Path**: Indicates whether currently in a mode where the user provides the diff directly in the conversation. Set to true by step 0.2 when conversation diff validation passes, skipping steps 0.3~0.6 and steps 1~2, going directly to step 3.
- <a id="Staging-Area"></a>**Staging Area**: The location where changes are stored after `git add`, viewed via `git diff --staged`.
- <a id="Working-Directory"></a>**Working Directory**: The modification status of tracked files in the current working directory, viewed via `git diff`.
- <a id="Root-Commit"></a>**Root Commit**: The first commit in a repository, which has no parent commit. Such commits use `git show` instead of `git diff` to view changes.
- <a id="Untracked-File"></a>**Untracked File**: A new file not yet tracked by Git, not included in any `git diff` output, detected via `git status --short`.
- <a id="Branch-Range"></a>**Branch Range**: A Git range expression for comparing differences between two branches/commits (e.g., `main..feature`), changes obtained via `git log <range> -p`.

## Prerequisites

- **Standard Path** (obtaining changes via Git):
  - Git 2.0+
  - Currently in a Git repository directory
  - Git changes available for analysis (staged changes, working directory changes, specified commit, or branch range)
- **Conversation Diff Path** (user provides diff directly in conversation):
  - No Git environment needed, skip Git-related checks
  - Expected format is standard unified diff format, or other analyzable change descriptions
  - If format cannot be parsed, prompt the user to provide a standard diff format

## Workflow

0. **Pre-flight Check** — Ensure the commit environment is ready;
  0.1 Initialize global variable [Conversation Diff Path](#Conversation-Diff-Path) to false;
  0.2 Check if the user has already provided diff content in the conversation:
    - Yes -> Validate if the diff format is parseable:
      - Yes -> Set [Conversation Diff Path](#Conversation-Diff-Path) to true, skip steps 0.3~0.6 and steps 1~2, go directly to step 3;
      - No -> Inform the user the diff format is unparseable, provide options via AskUserQuestion, block and wait for user selection:
        - Switch to Git Path -> jump to step 0.3, enter Git path check flow;
        - Cancel -> terminate flow;
    - No -> next step;
  0.3 Check if in a Git repository:
    - Yes -> next step;
    - No -> report "Not currently in a Git repository", terminate flow;
  0.4 Check if Git version >= 2.0:
    - Yes -> next step;
    - No -> prompt to upgrade Git, terminate flow;
  0.5 Check if in a conflict state:
    - Check if in a merge conflict (check if `$(git rev-parse --git-dir)/MERGE_MSG` exists):
      - Yes -> inform user of merge conflict, terminate flow;
      - No -> next step;
    - Check if in a cherry-pick conflict (check if `$(git rev-parse --git-dir)/CHERRY_PICK_HEAD` exists):
      - Yes -> inform user of cherry-pick conflict, terminate flow;
      - No -> next step;
    - Check if in a revert conflict (check if `$(git rev-parse --git-dir)/REVERT_HEAD` exists):
      - Yes -> inform user of revert conflict, terminate flow;
      - No -> next step;
    - Check if in a rebase conflict (check if `$(git rev-parse --git-dir)/rebase-merge/REBASE_HEAD` or `$(git rev-parse --git-dir)/rebase-apply/` exists):
      - Yes -> inform user of rebase conflict, terminate flow;
      - No -> next step;
  0.6 Check if there are unstaged or untracked changes in the working directory (via `git status --porcelain`):
    - Yes (unstaged/untracked changes exist) -> provide options via AskUserQuestion, block and wait for user selection:
      - Yes, first execute `git add .` -> execute `git add .`, proceed to step 0.7;
      - No, do not stage -> terminate flow;
    - No (working directory clean) -> proceed to step 0.7;
  0.7 Check if Git changes are available for analysis (staged/working directory/commit/branch range):
    - Yes -> next step (enter step 1);
    - No -> inform user no changes to analyze, terminate flow;

1. **Determine Input Source** — Determine the source of change information;
   1.1 Determine the type of user input:
       - User specifies the source intent (staged/current commit/branch range, etc.) -> map directly to corresponding scenario, enter step 2;
       - User provides commit id or branch range -> enter step 2;
       - User provides no change information -> provide options via AskUserQuestion, block and wait for user selection:
         - Staging area -> Scenario A, enter step 2;
         - Specify commit -> get commit ID from user via AskUserQuestion (leave empty defaults to HEAD), block and wait for user input; after user input -> Scenario B, enter step 2;
         - Branch range -> Scenario C, enter step 2 (branch range will generate a squash-style single commit message);

2. **Get Diff** — Obtain change content based on input source;
   2.1 Map to corresponding scenario based on step 1 result ("current commit" falls into Scenario B, commit is HEAD):
       - Scenario A (staging area): execute `git diff --staged`:
         - Empty result -> inform user no staged changes, terminate flow;
         - Non-empty result -> enter step 2.2;
       - Scenario B (single commit): execute `git rev-list --parents -n 1 <commit>` to check if root commit:
         - Command failed (commit does not exist or invalid) -> inform user the commit does not exist, guide user to check and retry, terminate flow;
         - Result contains only one commit hash (no parent) -> root commit, use `git show <commit>` instead;
         - Result contains multiple commit hashes (has parent) -> execute `git diff <commit>^!`;
         - Enter step 2.2;
       - Scenario C (branch range): execute `git log <range> -p`:
         - Command failed (invalid range) -> inform user the branch range is invalid, guide user to check and retry, terminate flow;
         - Empty result (no changes in range) -> inform user no differences in the selected range, guide user to check range and retry, terminate flow;
         - Enter step 2.2;
   2.2 After obtaining, enter step 3;

3. **Analyze Changes** — Analyze diff content and determine commit type;
   3.0 Open [conventional-commits.md](references/conventional-commits.md) to determine applicable commit type, analyze change scope and core intent;
   3.1 Process by file type:
       - Non-binary files -> analyze change content normally;
       - Binary files -> note the file name and change type only, do not analyze content;
   3.2 Output change analysis summary table (count new/modified/deleted/renamed/permission changes by non-binary/binary file), enter step 4;

4. **Generate Commit Message** — Generate candidate proposals and confirm final output;
   4.1 Generate candidate proposals — Based on analysis results, select 1~3 reasonable types, generate one candidate commit message for each:
       - If changes involve multiple natures (e.g., new feature + refactor) -> consider multiple reasonable types;
       - If change nature is clear and singular -> generate only 1 candidate;
       - Each candidate strictly follows [conventional-commits.md](references/conventional-commits.md) specification format;
   4.2 User selection — Display candidate proposals for user selection:
       - Provide options via AskUserQuestion, block and wait for user selection:
         - Proposal 1 -> enter 4.3;
         - Proposal 2 (if exists) -> enter 4.3;
         - Proposal 3 (if exists) -> enter 4.3;
   4.3 Breaking change confirmation — Check if the candidate includes a breaking change marker (`!` or `BREAKING CHANGE:`):
       - Yes -> provide options via AskUserQuestion, block and wait for user selection:
         - Yes, it is indeed a breaking change -> keep the marker, enter 4.4;
         - No, remove the breaking change marker -> remove the marker, enter 4.4;
       - No -> enter 4.4;
   4.4 Associate Issue — Ask user if they need to associate an issue:
       - Provide options via AskUserQuestion, block and wait for user selection:
         - Yes, associate Issue -> user enters Issue number (e.g., `#123`), append to footer;
         - No, not needed -> skip;
   4.5 Summarize all user-confirmed selections (selected proposal, breaking change marker, associated Issue), enter step 5;

5. **Review Check** — Check against [Review List](#review-list) to confirm the commit message content;
  - Check if Review List has content:
    - No -> go directly to step 6;
    - Yes -> next step;
  - Check each item in [Review List](#review-list) in order, check if passed (must output all check item results one by one, must not skip with abbreviations):
    - Yes -> continue to next check item;
    - No -> record failed check item, continue to next check item;
  - Check if any check item failed:
    - Yes -> guide user to handle manually, terminate flow;
    - No -> enter step 6;
6. **Output Results** — Output execution summary, notify completion;
   6.1 Output the final commit message and complete structured log (summary table covering pre-flight info, candidate proposals, confirmation details, final output, etc.);
   6.2 Notify user execution complete;

## Rules

- **Format Conventions**
  - Strictly follow the format definition in [conventional-commits.md](references/conventional-commits.md): `<type>[optional scope][!]: <description>`;
  - [Subject](#Subject) stays within 50 characters;
  - Start with a verb (add, implement, correct, refactor, etc.), with a lowercase verb, in present tense;
  - [Description](#Description) does not end with a period (.) ;
  - Optional [Scope](#Scope) is wrapped in parentheses after [Type](#Type), e.g., `feat(auth):`;
  - [Body](#Body) explains "what" and "why";
  - [Body](#Body) does not exceed 72 characters per line;
- **Type Conventions**
  - [Type](#Type) uses valid values from the "Type" reference table in [conventional-commits.md](references/conventional-commits.md): feat (new feature), fix (bug fix), docs (documentation), style (formatting), refactor (refactoring), perf (performance), test (testing), build (build), ci (continuous integration), chore (miscellaneous), revert (rollback);
- **Content Conventions**
  - Commit messages in English;
  - Keep concise, do not over-generate;
  - Do not include CI skip markers like `[skip ci]`;
  - For binary file changes, only note the file name and change type, do not analyze content;
  - Breaking changes are marked with [BREAKING CHANGE](#BREAKING-CHANGE) or `!`;
  - The `!` marker must be placed after [Type](#Type)/[Scope](#Scope) and before the colon;
  - Reference related Issue (if any);
- **Behavioral Conventions**
  - All user decision-making interactions (selecting candidate proposals, confirming breaking changes, associating Issues, etc.) **must** use the `AskUserQuestion` tool; plain text follow-ups are prohibited; pass questions and options into AskUserQuestion in a structured way, no more than 4 questions per call; free-text input (like Issue numbers, etc.) is not subject to this restriction;

## Examples

### Dialog Interaction Examples

**Analyzing Changes**

```markdown
AI > | Action  | Non-binary Files | Binary Files |
      |---------|------------------|--------------|
      | **Summary** | **5**       | **1**        |
      | Added   | 2                | 0            |
      | Modified| 3                | 0            |
      | Renamed | 0                | 0            |
      | Deleted | 0                | 1            |
      | Permission Change | 0     | 0            |
```

**Multiple Proposal Output**

```markdown
AI > Based on the analysis, the following candidate proposals have been generated:
```

```markdown
--- Proposal 1 ---
feat(auth): add user login and role management

- Implement JWT authentication for user login
- Add role-based access control for admin endpoints
```

```markdown
--- Proposal 2 ---
feat(auth)!: add user login and role management

BREAKING CHANGE: restructured authentication system

- Implement JWT authentication for user login
- Add role-based access control for admin endpoints
```

**Summarizing User Confirmed Selections**

```markdown
AI > All your selections have been confirmed. Preparing to enter review check:
     - Selected proposal: Proposal 2 — feat(auth)!: add user login and role management
     - Breaking change: Yes
     - Associated Issue: None
```

### Review Check Example

```markdown
AI > Entering review check, Review List contains 13 check items, starting verification:

**Format Check**
  - 🟩 subject does not exceed 50 characters
  - 🟩 description starts with a lowercase verb (add, implement, etc.), in present tense

**Type Conformance Check**
  - 🟩 type uses valid values

**Content Check**
  - 🟩 Commit message in English
  - 🟩 Binary files correctly handled

**Marker Check**
  - 🟩 Breaking change correctly marked (`BREAKING CHANGE:` or `!`)
  - 🟩 Associated Issue correctly referenced

(Only representative passing items shown; AI will output all 13 check item results during runtime)

**!!! Following check items FAILED !!!**
  - 🟥 description starts with a lowercase verb (starts with a noun, should be a lowercase verb)
    Check failed. Based on the type of failure, return to the corresponding step to regenerate.
```

### Output Results Example

```markdown
【Pre-flight Info】
| Input Source  | File Scope                           | Change Distribution      |
|---------------|--------------------------------------|--------------------------|
| Staged changes| Non-binary 5 / Binary 1 (images)    | Added 2 / Modified 3 / Deleted 0 / Renamed 0 |

【Candidate Proposals】
| Candidate Count | Selected Proposal                      |
|-----------------|----------------------------------------|
| 2               | Proposal 1 — feat(auth): add user login… |

【Confirmation Details】
| Breaking Change      | Associated Issue              |
|----------------------|-------------------------------|
| No (confirmed by user) | #123 (Closes #123)          |

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
  - [ ] [Description](#Description) starts with a lowercase verb (add, implement, etc.), in present tense, ends without a period
  - [ ] [Body](#Body) explains "what" and "why"
  - [ ] [Body](#Body) does not exceed 72 characters per line
- **Type Conformance Check**
  - [ ] [Type](#Type) uses valid values defined in [conventional-commits.md](references/conventional-commits.md)
- **Content Check**
  - [ ] Commit message in English
  - [ ] Keeps concise, does not over-generate
  - [ ] Does not include CI skip markers like `[skip ci]`
  - [ ] Binary files correctly handled (only file names and change types noted, content not analyzed)
- **Marker Check**
  - [ ] Breaking change correctly marked ([BREAKING CHANGE](#BREAKING-CHANGE) or `!`)
  - [ ] `!` marker placed after [Type](#Type)/[Scope](#Scope) and before the colon
  - [ ] Associated Issue (if any) correctly referenced

## References

- Conventional Commits specification details: see [conventional-commits.md](references/conventional-commits.md)
---
name: git-commit-helper
description: Generate Git commit messages following the Conventional Commits specification. Use when users request help writing commit messages, viewing staged changes, generating PR descriptions, or mentioning "commit" or "commit message".
---

# Git Commit Helper

Intelligently generate Git commit messages following the Conventional Commits specification. All generated prompts are in English.

## Usage

| Trigger Phrase | Description |
|--------|------|
| `帮我生成 commit message` | Basic usage |
| `分析变更，生成 commit message` | Detailed analysis |
| `为这次变更生成 PR 描述` | PR description |

## Commit Types

| Type | Description | Example |
|------|------|------|
| feat | New Feature | feat: add user login |
| fix | Bug Fix | fix: correct validation |
| docs | Documentation | docs: update README |
| style | Code Style | style: format code |
| refactor | Refactor | refactor: simplify logic |
| perf | Performance | perf: improve speed |
| test | Testing | test: add login tests |
| build | Build System | build: update config |
| ci | CI Configuration | ci: add actions |
| chore | Maintenance | chore: update deps |
| revert | Revert | revert: revert feature |

## Commit Message Format

```
<type>(<scope>): <subject>

<body>

<footer>
```

### Examples

**Short version:**
```
feat: add user login feature
```

**Detailed version:**
```
feat(auth): add user login feature

- Add login page with email/password form
- Implement JWT authentication
- Add login API endpoint

Closes #123
```

## PR Description Format

```markdown
## Pull Request

### Change Summary
[One-line description]

### Changes
- ✅ [Specific change 1]
- ✅ [Specific change 2]

### Test Plan
- [ ] [Test item 1]
- [ ] [Test item 2]

### Related Issues
Closes #xxx
```

## Best Practices

- Keep subject within 50 characters
- Start with a verb (add, fix, update, remove)
- Body explains "what was done" and "why"
- Breaking changes start with `BREAKING CHANGE:`
- Reference related Issues

## Workflow

1. Run `git diff --staged` or `git diff` to view changes
2. Analyze the change type and scope
3. Generate commit message following Conventional Commits specification
4. If there are breaking changes, add `BREAKING CHANGE:` explanation
5. Automatically reference related Issues (if any)
