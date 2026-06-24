---
name: changeset-gen
description: Analyze affected packages based on staged changes and automatically generate pnpm changeset version change files. Use when the user needs to generate version change files for completed changes in an nx + pnpm changeset monorepo.
---

# changeset-gen

Based on staged changes, analyze affected packages and automatically generate pnpm changeset version change files. Does not involve branch creation, code commits, or push operations, focusing on a single responsibility.

## Overview

This skill is a pure utility skill focused on changeset file generation. It receives the version change type and change summary specified by the user, and generates independent changeset files for each affected package.

Only applicable to pnpm changeset monorepo repositories (supports the nx ecosystem).

## Definitions

- <a id="changeset-file"></a>**Changeset File**: A Markdown file located in the `.changeset/` directory, describing the package change type and content, used by the changeset release flow to automatically calculate version numbers and generate changelogs.
- <a id="affected-packages"></a>**Affected Packages**: Packages involved in the current changes, determined by the package directories defined in `pnpm-workspace.yaml` (e.g., `packages/*/`, `apps/*/`, etc.).

## Prerequisites

- Git repository
- Staged changes exist (`git diff --staged --name-only` has output)
- Project has pnpm changeset enabled (`.changeset/` directory and `@changesets/cli` exist)
- `jq` (JSON processor, required by `scripts/check-env.sh`)
- `pnpm-workspace.yaml` file exists (to determine the package directory structure)

## Workflow

0. **Pre-check** — Ensure prerequisites for subsequent tasks are met;
  0.1 Execute environment check (`bash scripts/check-env.sh`):
    - Check if the script executed successfully:
      - Success -> Parse JSON, check for "error" field:
        - Present -> Report script error (e.g., missing jq dependency), terminate flow;
        - Absent -> Report each check result:
      - "in-git-repo" failed -> Report "Not in a Git repository", terminate flow;
      - "git-version" failed -> Prompt to upgrade Git to 2.0+, terminate flow;
      - "has-changes" failed -> Inform user there are no changes to analyze, terminate flow;
      - "pnpm-changeset" failed -> Report unmet conditions (missing .changeset/ or @changesets/cli), terminate flow or prompt user to handle;
      - "pnpm-workspace" failed -> Report missing pnpm-workspace.yaml or packages configuration, terminate flow;
    - All checks passed -> Proceed to step 1;

1. **Generate plan proposals** — Analyze staged changes, generate two types of proposals for subsequent steps;
  1.1 Analyze affected packages
    - Execute `git diff --staged --name-only` to get the list of changed files;
    - Read the `packages` configuration from `pnpm-workspace.yaml` to determine the package search directory list (default `packages/*/`);
    - Identify package directories from the changed file paths, read the `name` field from each package's `package.json`, compile the list of affected packages;
    - If a package's `package.json` does not exist or lacks a `name` field: skip that package and notify the user;
    - If no affected packages are found:
      - Inform the user that the current changes do not involve files under package directories, no changeset needs to be generated, proceed to step 5 (output results);
  1.2 Generate unified proposals
    - Comprehensively evaluate based on the content of all affected packages' changes, generate 1~3 unified proposals, each containing a unified version change level and change summary applicable to all packages;
    - Each proposal includes:
      - Proposal number and title (e.g., "Proposal 1: Recommended — Multi-module feature update")
      - Version change level combination (e.g., @scope/auth: minor, @scope/core: patch)
      - Suggested change summary (e.g., "feat(auth): add user authentication module & fix(core): adjust configuration")
      - AI selection rationale
  1.3 Generate independent proposals
    - View detailed change content for each package via `git diff --staged -- packages/<name>/`;
    - Based on change content analysis, generate 1~3 suggested proposals for each package independently, each including:
      - Proposal number and title (e.g., "Proposal 1: Recommended — Add user authentication module")
      - Version change level (major / minor / patch)
      - Suggested change summary (e.g., "feat(auth): add user authentication module")
      - AI selection rationale (e.g., "Contains multiple new feature exports, recommended minor upgrade")

2. **User confirms proposal** — Select proposal mode and confirm per package/overall;
  2.1 Select proposal mode
    - Ask the user via AskUserQuestion which proposal mode to adopt:
      - Unified proposal -> Use a single proposal for all packages, proceed to substep 2.2;
      - Independent proposal -> Select per package, proceed to substep 2.3;
  2.2 Select unified proposal
    - Display the 1~3 unified proposals generated in Step 1;
    - Provide options via AskUserQuestion for the user to select one proposal, options include:
      - [Dynamic options, generated by AI based on the unified proposal list] -> Use this proposal, apply uniformly to all packages, proceed to next step;
      - Custom -> Let the user enter manually, apply uniformly to all packages, proceed to next step;
  2.3 Select independent proposals
    - Ask per package in the affected package list, each package decided independently:
      - Display the 1~3 independent proposals for that package generated in Step 1;
      - Provide options via AskUserQuestion for the user to select one proposal, options include:
        - [Dynamic options, generated by AI based on the proposal list for this package] -> Use this proposal, record version change type and change summary, proceed to next package or next step;
        - Custom -> Let the user enter the version change type and change summary manually, proceed to next package or next step;
    - Once all packages are confirmed, proceed to the next step;

3. **Generate changeset files** — Create independent changeset files for each affected package;
  3.1 Generate unique filenames
    - Create independent `.changeset/<random-name>.md` files for each affected package;
    - Filenames use random English word combinations (e.g., `adjective-noun-noun`), ensuring uniqueness, avoiding manual naming conflicts;
    - If the randomly generated name conflicts with an existing file in the `.changeset/` directory, regenerate until no conflict;
  3.2 Write changeset content

    ```markdown
    ---
    '@scope/package-name': minor
    ---

    feat: add xxx support for something
    ```

    - Change summary uses the content provided by the user in Step 2;
  3.3 Handle multi-package scenarios
    - If multiple packages are affected, create independent changeset files for each package;
  3.4 Confirm file path
    - File path: `.changeset/<random-word-combination>.md`;

4. **Review check** — Compare against [Review List](#review-list), confirm execution results;
  4.1 Check each item in Review List
    - Sequentially check each item in [Review List](#review-list) for pass/fail:
      - Pass -> Continue to next item;
      - Fail -> Proceed to step 4.2;
  4.2 Handle failed items
    - Output failed items, ask the user:
      - Keep generated files and exit -> Output file paths, terminate flow;
      - Delete generated files and exit -> Delete all files, then terminate flow;
      - Return to corresponding step to fix -> Delete generated changeset files, ask the user via AskUserQuestion which step they want to return to:
        - Step 1 (re-analyze changes) -> Return to step 1;
        - Step 2 (re-select proposals) -> Return to step 2;
        - Step 3 (re-generate files) -> Return to step 3;
  4.3 All passed -> Proceed to next step (output results);

5. **Output results** — Output execution summary, inform completion;
  5.1 Handle no-affected-packages scenario
    - If entered from "no affected packages" scenario: Output "The current changes do not involve any files under package directories, no changeset file needs to be generated", directly inform completion;
  5.2 Output structured summary
    - If entered normally: Output structured summary (including generated file list and paths);
  5.3 Prompt for staging
    - Prompt the user to execute `git add .changeset/` to stage the generated changeset files for subsequent commit and release flow use;
  5.4 Inform completion
    - Inform the user that execution is complete;

## Rules

- Changeset filenames must be randomly unique to avoid manual naming conflicts
- Check the `.changeset/` directory before generating filenames to ensure no existing files are overwritten
- Each affected package generates a separate independent changeset file
- All user decision interaction points must use the AskUserQuestion tool; do not consult users with plain text questions
- If there are no staged changes, remind the user to `git add` first
- This skill only auto-stages all unstaged changes on demand in step 0.3 (`git add .`), and does not execute `git commit`, `git push`, or any branch operations
- Generated files are limited to the `.changeset/` directory

## Examples

### Dialogue Interaction Examples

**User Selects Unified Proposal**

```markdown
User> /changeset-gen

AI > Detected staged changes, analyzing affected packages...

     Changed files:
       packages/auth/src/login.ts
       packages/auth/src/signup.ts
       packages/core/src/config.ts

     Affected packages: @scope/auth, @scope/core

     ╔══ Unified Proposals ══╗
     Proposal 1 (Recommended): All packages unified minor, summary "feat: multi-module feature update"
     Proposal 2:               @scope/auth minor + @scope/core patch
     Proposal 3:               All packages unified patch, summary "fix: multi-module fix"
     ╚════════════════════════╝

     Please select proposal mode:
     1. Unified proposal — All packages use the same proposal
     2. Independent proposal — Each package selects individually

User> Unified proposal

AI > Displaying unified proposals:
     1 (Recommended): All packages unified minor — feat: multi-module feature update
     2:               @scope/auth minor + @scope/core patch
     3:               All packages unified patch — fix: multi-module fix
     4:               Custom

User> Proposal 1

AI > Changeset files generated

     .changeset/curly-boxes-type.md → @scope/auth: minor
     .changeset/flat-tigers-run.md → @scope/core: minor
```

**User Selects Independent Proposals**

```markdown
User> /changeset-gen

AI > Detected staged changes, analyzing affected packages...

     Changed files:
       packages/auth/src/login.ts
       packages/auth/src/signup.ts
       packages/core/src/config.ts

     Affected packages: @scope/auth, @scope/core

     ╔══ Unified Proposals ══╗
     Proposal 1 (Recommended): All packages unified minor
     Proposal 2:               All packages unified patch
     ╚════════════════════════╝

     ── Per-Package Independent Proposals ──
     @scope/auth:
       Proposal 1 (Recommended): minor — feat(auth): add user registration module
       Proposal 2:               patch — fix(auth): optimize login module

     @scope/core:
       Proposal 1 (Recommended): patch — fix(core): adjust configuration defaults
       Proposal 2:               minor — feat(core): extend configuration interface

     Please select proposal mode:
     1. Unified proposal — All packages use the same proposal
     2. Independent proposal — Each package selects individually

User> Independent proposals

AI > @scope/auth please select a proposal:
     1 (Recommended): minor — feat(auth): add user registration module
     2:               patch — fix(auth): optimize login module

User> Proposal 1

AI > @scope/core please select a proposal:
     1 (Recommended): patch — fix(core): adjust configuration defaults
     2:               minor — feat(core): extend configuration interface

User> Proposal 1

AI > Changeset files generated

     .changeset/curly-boxes-type.md → @scope/auth: minor
     .changeset/flat-tigers-run.md → @scope/core: patch
```

### Review Check Example

```markdown
AI > Entering review check. Review List contains 7 items, starting verification:

**Result Check**
  - 🟩 Changeset files generated independently for each affected package
  - 🟩 Version type matches user selection
  - 🟩 Change summary matches user input
  - 🟩 Changeset filenames are randomly unique
  - 🟩 Changeset file format is correct (YAML frontmatter valid, package names correctly quoted)
  - 🟩 Generated files are limited to `.changeset/` directory
  - 🟩 No staged changes were modified or git commit/push operations performed

All checks passed, proceeding to next step.
```

### Output Example

**Changeset Generation Complete**

```markdown
| Item            | Count/Path               |
| --------------- | ------------------------ |
| Affected packages | 2                      |
| Changesets generated | 2                   |
| File path       | .changeset/              |

Next step: Please execute git add .changeset/ to stage these files.
```

## Review List

- **Result Check**
  - [ ] Changeset files generated independently for each affected package
  - [ ] Version type matches user selection
  - [ ] Change summary matches user input
  - [ ] Changeset filenames are randomly unique, no conflict with existing files
  - [ ] Changeset file format is correct (YAML frontmatter valid, package names correctly quoted)
  - [ ] Generated files are limited to `.changeset/` directory
  - [ ] No staged changes were modified or git commit/push operations performed

## References

- [Changesets Documentation](https://github.com/changesets/changesets)
- [pnpm changeset workflow](https://pnpm.io/using-changesets)

