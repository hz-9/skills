---
name: changeset-gen
description: Analyze staged changes to determine affected packages and automatically generate pnpm changeset version files. Use when a user needs to generate version change files for completed changes in an nx + pnpm changeset monorepo.
---

# changeset-gen

Analyze staged changes to determine affected packages and automatically generate pnpm changeset version files. Does not involve branch creation, code commit, or push workflows — focusing on a single responsibility.

## Overview

This skill is a pure utility skill focused on changeset file generation. It receives the user-specified version change type and change summary, and generates independent changeset files for each affected package.

Only applicable to pnpm changeset monorepo repositories (supports nx ecosystem).

## Definitions

- <a id="changeset-file"></a>**changeset file**: A Markdown file located in the `.changeset/` directory that describes the package change type and content, used by the changeset release workflow to automatically calculate version numbers and generate changelogs.
- <a id="affected-package"></a>**Affected Package**: A package that is involved in the current changes, determined based on the package directories defined in `pnpm-workspace.yaml` (e.g., `packages/*/`, `apps/*/`, etc.).

## Prerequisites

- Git repository
- Staged changes exist (`git diff --staged --name-only` has output)
- Project has pnpm changeset enabled (`.changeset/` directory and `@changesets/cli` exist)
- `pnpm-workspace.yaml` file exists (to determine package directory structure)

## Workflow

0. **Pre-flight check** — Ensure prerequisites for subsequent tasks are met;
  0.1 Verify currently in a Git repository:
    - Yes -> next step;
    - No -> report "Not currently in a Git repository", terminate flow;
  0.2 Check Git version >= 2.0:
    - Yes -> next step;
    - No -> prompt to upgrade Git, terminate flow;
  0.3 Check for unstaged or untracked changes in the working directory (via `git status --porcelain`):
    - Yes (unstaged/untracked changes exist) -> execute `git add .`:
      - Success -> proceed to step 0.4;
      - Failure -> report error details, prompt user to manually resolve and retry, terminate flow;
    - No (working directory clean) -> proceed to step 0.4;
  0.4 Check if Git staging area has content:
    - Yes -> next step;
    - No -> inform user there are no changes to analyze, terminate flow;
  0.5 Verify pnpm changeset is enabled (`.changeset/` directory and `@changesets/cli`):
    - All met -> next step;
    - Any unmet -> report unmet conditions, terminate flow or prompt user to resolve;
  0.6 Verify `pnpm-workspace.yaml` exists and contains `packages` configuration:
    - Yes -> next step;
    - No -> report "Missing pnpm-workspace.yaml or packages configuration", terminate flow;

1. **Generate proposal** — Analyze staged changes to generate two types of proposals for subsequent steps;
  1.1 Analyze affected packages
    - Execute `git diff --staged --name-only` to get the list of changed files;
    - Read `packages` configuration from `pnpm-workspace.yaml` to determine package search directories (default `packages/*/`);
    - Identify package directories from changed file paths, read the `name` field from each package's `package.json`, compile the list of affected packages;
    - If a package's `package.json` is missing or lacks a `name` field: skip that package and notify the user;
    - If no affected packages are found:
      - Inform user that current changes do not involve files under any package directory, no changeset needed, proceed to step 5 (output results);
  1.2 Generate unified proposal
    - Based on a comprehensive assessment of all affected packages' changes, generate 1-3 unified proposals, each with a unified version change level and change summary applicable to all packages;
    - Each proposal includes:
      - Proposal number and title (e.g., "Proposal 1: Recommended — Multi-module feature update")
      - Version change level combination (e.g., @scope/auth: minor, @scope/core: patch)
      - Suggested change summary (e.g., "feat(auth): add user auth module & fix(core): adjust config")
      - AI selection rationale
  1.3 Generate independent proposals
    - View detailed changes for each package via `git diff --staged -- packages/<name>/`;
    - Based on change analysis, independently generate 1-3 proposals for each package, each containing:
      - Proposal number and title (e.g., "Proposal 1: Recommended — Add user auth module")
      - Version change level (major / minor / patch)
      - Suggested change summary (e.g., "feat(auth): add user authentication module")
      - AI selection rationale (e.g., "Contains multiple new feature exports, suggests minor upgrade")

2. **User confirms proposal** — Select proposal mode and confirm per-package or unified;
  2.1 Select proposal mode
    - Use AskUserQuestion to ask the user which proposal mode to adopt:
      - Unified proposal -> use a single unified proposal, proceed to sub-step 2.2;
      - Independent proposal -> select proposals per package individually, proceed to sub-step 2.3;
  2.2 Select unified proposal
    - Display the 1-3 unified proposals generated in Step 1;
    - Use AskUserQuestion to provide options for the user to select one, including:
      - [Dynamic options generated by AI based on the unified proposal list] -> use that proposal, apply uniformly to all packages, proceed to next step;
      - Custom -> let user input their own, apply uniformly to all packages, proceed to next step;
  2.3 Select independent proposals
    - Ask per package in the affected packages list, each package independently:
      - Display the 1-3 independent proposals for that package generated in Step 1;
      - Use AskUserQuestion to provide options for the user to select, including:
        - [Dynamic options generated by AI based on that package's proposal list] -> use that proposal, record version change type and summary, proceed to next package or next step;
        - Custom -> let user input version change type and summary, proceed to next package or next step;
    - After all packages are confirmed, proceed to next step;

3. **Generate changeset files** — Create independent changeset files for each affected package;
  3.1 Generate unique filenames
    - Create independent `.changeset/<random-name>.md` file for each affected package;
    - Filenames use random English word combinations (e.g., `adjective-noun-noun`), ensure uniqueness, avoid manual naming conflicts;
    - If the randomly generated name conflicts with an existing file in `.changeset/`, regenerate until no conflict;
  3.2 Write changeset content

    ```markdown
    ---
    '@scope/package-name': minor
    ---

    feat: add xxx support for something
    ```

    - Change summary uses the content provided by the user in Step 2;
  3.3 Handle multi-package scenario
    - If multiple packages are affected, create an independent changeset file for each package;
  3.4 Confirm file path
    - File path: `.changeset/<random-word-combination>.md`;

4. **Review check** — Check against [Review List](#review-list) to confirm execution results;
  4.1 Iterate through Review List items
    - Check each item in [Review List](#review-list) in order:
      - Passed -> continue to next item;
      - Failed -> proceed to step 4.2;
  4.2 Handle failed items
    - Output failed items, ask the user:
      - Keep generated files and exit -> output file paths, terminate flow;
      - Delete generated files and exit -> delete all files and terminate flow;
      - Return to corresponding step for fix -> delete generated changeset files, use AskUserQuestion to ask the user which step to return to:
        - Step 1 (re-analyze changes) -> return to step 1;
        - Step 2 (re-select proposal) -> return to step 2;
        - Step 3 (re-generate files) -> return to step 3;
  4.3 After all checks pass, proceed to next step (output results);

5. **Output results** — Output execution summary, notify completion;
  5.1 Handle no-affected-packages scenario
    - If entered from "no affected packages" scenario: output "Current changes do not involve files under any package directory, no changeset file needed", directly notify completion;
  5.2 Output structured summary
    - If entered normally: output structured summary (including generated file list and paths);
  5.3 Prompt to stage
    - Prompt the user to run `git add .changeset/` to stage the generated changeset files for subsequent commit and release workflows;
  5.4 Notify completion
    - Inform the user that the process is complete;

## Rules

- Changeset filenames must be randomly unique to avoid manual naming conflicts
- Check the `.changeset/` directory before generating filenames to ensure no overwrites
- Generate one independent changeset file per affected package
- All user decision interactions must use the AskUserQuestion tool; plain text follow-ups asking the user are prohibited
- If there are no staged changes, remind the user to `git add` first
- This skill only auto-stages all unstaged changes in step 0.3 (`git add .`) as needed; it does not execute any `git commit`, `git push`, or branch operations
- Generated files are limited to the `.changeset/` directory only

## Examples

### Dialog Interaction Examples

**User selects unified proposal**

```markdown
User> /changeset-gen

AI > Staged changes detected, analyzing affected packages...

     Changed files:
       packages/auth/src/login.ts
       packages/auth/src/signup.ts
       packages/core/src/config.ts

     Affected packages: @scope/auth, @scope/core

     ╔══ Unified Proposal ══╗
     Proposal 1 (Recommended): All packages minor, summary "feat: multi-module feature update"
     Proposal 2:               @scope/auth minor + @scope/core patch
     Proposal 3:               All packages patch, summary "fix: multi-module fixes"
     ╚════════════════════════╝

     Please select proposal mode:
     1. Unified proposal — same proposal for all packages
     2. Independent proposal — each package selects individually

User> Unified proposal

AI > Displaying unified proposal options:
     1 (Recommended): All packages minor — feat: multi-module feature update
     2:               @scope/auth minor + @scope/core patch
     3:               All packages patch — fix: multi-module fixes
     4:               Custom

User> Proposal 1

AI > Changeset files generated

     .changeset/curly-boxes-type.md → @scope/auth: minor
     .changeset/flat-tigers-run.md → @scope/core: minor
```

**User selects independent proposal**

```markdown
User> /changeset-gen

AI > Staged changes detected, analyzing affected packages...

     Changed files:
       packages/auth/src/login.ts
       packages/auth/src/signup.ts
       packages/core/src/config.ts

     Affected packages: @scope/auth, @scope/core

     ╔══ Unified Proposal ══╗
     Proposal 1 (Recommended): All packages minor
     Proposal 2:               All packages patch
     ╚════════════════════════╝

     ── Per-package Independent Proposals ──
     @scope/auth:
       Proposal 1 (Recommended): minor — feat(auth): add user registration module
       Proposal 2:               patch — fix(auth): optimize login module

     @scope/core:
       Proposal 1 (Recommended): patch — fix(core): adjust config defaults
       Proposal 2:               minor — feat(core): extend config interface

     Please select proposal mode:
     1. Unified proposal — same proposal for all packages
     2. Independent proposal — each package selects individually

User> Independent proposal

AI > @scope/auth please select a proposal:
     1 (Recommended): minor — feat(auth): add user registration module
     2:               patch — fix(auth): optimize login module

User> Proposal 1

AI > @scope/core please select a proposal:
     1 (Recommended): patch — fix(core): adjust config defaults
     2:               minor — feat(core): extend config interface

User> Proposal 1

AI > Changeset files generated

     .changeset/curly-boxes-type.md → @scope/auth: minor
     .changeset/flat-tigers-run.md → @scope/core: patch
```

### Review Check Example

```markdown
AI > Entering review check, Review List contains 7 check items, starting verification:

**Result Check**
  - 🟩 Changeset files generated independently for each affected package
  - 🟩 Version type matches user selection
  - 🟩 Change summary matches user input
  - 🟩 Changeset filenames are randomly unique
  - 🟩 Changeset file format is correct (valid YAML frontmatter, package names properly quoted)
  - 🟩 Generated files are limited to `.changeset/` directory only
  - 🟩 No staged changes were modified, no git commit/push operations were performed

All check items passed, proceeding to next step.
```

### Output Results Example

**Changeset generation complete**

```markdown
| Item              | Count/Path              |
| ----------------- | ----------------------- |
| Affected packages | 2                       |
| Changesets generated | 2                    |
| File path         | .changeset/             |

Next step: Run git add .changeset/ to stage these files for subsequent commit and release.
```

## Review List

- **Result Check**
  - [ ] Changeset files generated independently for each affected package
  - [ ] Version type matches user selection
  - [ ] Change summary matches user input
  - [ ] Changeset filenames are randomly unique, no conflict with existing files
  - [ ] Changeset file format is correct (valid YAML frontmatter, package names properly quoted)
  - [ ] Generated files are limited to `.changeset/` directory only
  - [ ] No staged changes were modified, no git commit/push operations were performed

## References

- [Changesets Documentation](https://github.com/changesets/changesets)
- [pnpm changeset workflow](https://pnpm.io/using-changesets)
