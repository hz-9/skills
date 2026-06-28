---
description: Execute a cycle of Code Review → Log output → Fix issues → Regression review on the current code changes, until convergence or reaching the iteration limit.
---

# Review and Fix Cycle

## Definition

### Severity Levels

| Level      | Definition                                                                  | Example                                                               |
| ---------- | --------------------------------------------------------------------------- | --------------------------------------------------------------------- |
| **High**   | Structural issues or semantic errors that may cause functionality failure or security risks | Logic errors, security vulnerabilities, API misuse, dead links       |
| **Medium** | Maintainability issues or non-critical omissions                            | Non-standard naming, missing boundary checks, inconsistent comments and code |
| **Low**    | Optimization suggestions that do not affect correctness                     | Code style tweaks, redundant comments, recommended but not mandatory best practices |

### Convergence Conditions

**Convergence**: **0 new issues** found in this review round, meeting the cycle exit condition.

> **Definition of New Issue**: An issue newly discovered in this round that was not previously recorded, relative to the last equivalent evaluation result of this round's operation. If the same issue reappears after being fixed, it is considered a recurrence and counted as a new issue.

### Iteration Limit

| Level                       | Limit |
| --------------------------- | ----- |
| Fix Loop (Inner)            | 10    |
| Code Review Outer Loop      | 30    |

## Prerequisites

- The current workspace is a Git repository (to identify the scope of changes)
- CodeReview Agent sub-agent is available
- The `docs/review-and-fix-cycle/` directory exists in the current workspace (created if it does not exist); the UTC time subdirectory is automatically created by Step 0

## Workflow

### Step 0: Pre-checks

0.1 Check if the current workspace is a Git repository:
  - Yes -> proceed to the next step;
  - No -> report "Not a Git repository, cannot identify the scope of changes", terminate the process;

0.2 Check if the CodeReview Agent sub-agent is available (attempt to invoke via the `Agent` tool):
  - Yes -> proceed to the next step;
  - No -> report "CodeReview Agent is not available", terminate the process;

0.3 Get the current UTC time and create the `docs/review-and-fix-cycle/{UTC time}/` directory (parent directories are also created if they do not exist). All reports from this run are saved to this directory:
  - Created successfully -> proceed to the next step;
  - Creation failed -> report "Directory creation failed", terminate the process;

0.4 Determine the review scope:
  - Scan the current staging area and workspace changes (`git diff --cached` and `git diff`):
    - Only staged changes exist -> review scope is staged changes;
    - Only workspace changes exist -> review scope is workspace changes;
    - Both staged and workspace changes exist -> provide options via AskUserQuestion, blocking wait for user selection:
      - Staged changes (recommended) -> review scope is staged changes;
      - Workspace changes -> review scope is workspace changes;
      - All changes -> review scope includes both staging area and workspace changes;
    - No changes exist -> provide options via AskUserQuestion, blocking wait for user selection:
      - Review specified file/directory -> the user specifies the path, proceed to the next step after execution;
      - Review the entire repository -> review scope is the entire repository;
      - Review the most recent commit -> review scope is the changes from the most recent commit;
      - Terminate -> terminate the process;

### Step 1: Code Review

Dispatch **exactly 3** CodeReview Agents (Completeness, Correctness, Impact) in parallel, each independently reviewing the scope of changes from a fresh perspective. **They must not reference previous review results or historical reports from this round (except for regression review scenarios, see Step 5), and must not downgrade on the grounds that this step has already been executed or the number of issues has decreased**. Each agent records the issues they find:

- **All 3 Agents report 0 new issues** -> **Convergence**, proceed to Step 6;
- **Any Agent finds issues** -> Deduplicate and aggregate, then proceed to Step 2;
- **Any Agent is unavailable due to environmental failure** -> Treat as environmental failure, terminate the process and note "CodeReview Agent is not available" in the report;

### Step 2: Record Issues

Record each issue in the review log, mark the severity (High/Medium/Low), generate the review log file `review-cycle-{outer iteration}.md` and save it to `docs/review-and-fix-cycle/{UTC time}/`, in the following format:

```markdown
# Review Cycle - Round {N}

## Issues Found

| # | Severity | Source | File | Description |
|---|----------|--------|------|-------------|
| 1 | High | Completeness | src/example.ts:42 | ... |
| 2 | Medium | Correctness | src/example.ts:88 | ... |

## Issue Details

### [High] Issue 1: {Title}

- **Source**: Completeness Agent
- **File**: `src/example.ts:42`
- **Description**: {Detailed description}

### [Medium] Issue 2: {Title}
...
```

### Step 3: Fix Issues

Fix all discovered issues one by one:

- After each fix, generate a fix report `review-cycle-{outer iteration}-fix{fix round}.md`, record the fix method and result, and save it to `docs/review-and-fix-cycle/{UTC time}/`;
- After all issues are fixed, increment the fix round by 1, proceed to Step 4;

### Step 4: Fix Round Limit Check

Check if the 10 fix round limit has been reached:
- Yes -> Mark "Fix limit reached, some issues unresolved", abort the fix process, proceed to Step 6;
- No -> Proceed to Step 5;

### Step 5: Regression Review

Dispatch **exactly 3** CodeReview Agents (Completeness, Correctness, Impact) in parallel to perform a regression review on the fixed issues (regression review agents are not subject to the Step 1 restriction of not referencing history; they may carry the context of this round's fix summary), verify whether the fixes are correct and whether new issues have been introduced, each recording their findings:

- **All 3 Agents report 0 new issues** -> **Fix loop convergence**, generate iteration report `review-cycle-{outer iteration}.md`, save to `docs/review-and-fix-cycle/{UTC time}/`, proceed to Step 6;
- **Any Agent finds issues** -> Aggregate and deduplicate new issues, return to Step 2 (fix round +1);

### Step 6: Outer Loop Control

Check the number of issues found in this outer review round:

- **All 3 Agents report 0 new issues** -> **Convergence**, proceed to Step 7;
- **Issues exist** -> Check if the outer loop has reached the limit of 30 rounds:
  - Yes -> Mark "Outer loop - not fully converged", force exit, proceed to Step 7;
  - No -> Return to Step 1 (outer iteration count +1);

### Step 7: Summary Output

Aggregate all reports from this run, output a review and fix summary, including:

- Review overview (review scope, review rounds, total fixed issues, etc.)
- Issue statistics categorized by severity
- List of all generated report files

Generate the final summary report `final-summary.md` and save it to `docs/review-and-fix-cycle/{UTC time}/`.

## Rules

- **Behavior**
  - **Automatic continuous execution**: Steps must automatically proceed without interruption waiting for user confirmation to manually trigger (except for AskUserQuestion scenarios).
  - **Agent type lock**: Throughout the process, the Code Review phase (including Step 1 initial review and Step 5 regression review) **must** use CodeReview Agents for review. It is strictly forbidden to switch to GeneralPurpose Agent or any other Agent type for any reason. If the environment objectively does not support CodeReview Agents, the process terminates and notes "CodeReview Agent is not available" in the report; downgrading and continuing execution is not allowed.
  - **Parallel count hard constraint**: Each Code Review round (including Step 1 initial review and Step 5 regression review) must dispatch **exactly 3** CodeReview Agents in parallel, independently covering the three perspectives of Completeness, Correctness, and Impact. The review results of all 3 Agents must be independently recorded in the review log.
  - **No process downgrade**: Each step must strictly follow the order, content, and execution method defined in the Workflow. Skipping, simplifying, merging, or accelerating any step for any reason is not allowed.
  - **Fix method selection**: When fixing issues, decide on the modification method (directly modifying code or using relevant tools) based on the issue type, without needing to ask the user one by one.
  - **Do not affect the current workspace**: During execution, do not execute operations that affect Git history such as `git commit`, `git add`, unless explicitly requested by the user.
- **Report**
  - **Report persistence**: All review logs, fix reports, and summary reports are saved to the `docs/review-and-fix-cycle/{UTC time}/` directory.
  - **Naming rules**:
    - Review log: `review-cycle-{outer iteration}.md`
    - Fix report: `review-cycle-{outer iteration}-fix{fix round}.md`
    - Final summary: `final-summary.md`
  - **No external labels**: During process execution and in reports, it is **strictly prohibited** to include process labels or status identifiers not defined in the Workflow.
- **Interaction**
  - For scenarios requiring user decisions such as change scope selection, the `AskUserQuestion` tool **must** be used; do not consult the user in the form of plain text follow-up questions.

## Examples

### Dialogue Interaction Example

```markdown
User > Execute code review and fix

AI   > Starting Review and Fix Cycle:
       Step 0 Pre-checks...Git repository confirmed, UTC time directory created.

       Step 0.4 Determine review scope...Detected changes in both staging area and workspace.
       Provide options via AskUserQuestion:
          - Staged changes (recommended) -> review scope is staged changes;
          - Workspace changes -> review scope is workspace changes;
          - All changes -> review scope is all changes;
User > Staged changes

AI   > Step 1 Code Review...Dispatching 3 CodeReview Agents (Completeness, Correctness, Impact).
       Completeness found 2 issues, Correctness found 1 issue, Impact found 0 issues.
       After deduplication: 2 issues total.

       Step 2 Record issues...Recorded in review log review-cycle-1.md.

       Step 3 Fix issues...Fix issue 1 (High - logic error), issue 2 (Medium - naming non-standard).
       Generated fix report review-cycle-1-fix1.md.

       Step 5 Regression review...Dispatching 3 CodeReview Agents for regression review.
       All 3 Agents report 0 new issues -> Fix loop converged.

       Step 6 Outer loop control...Checking convergence:
       Current outer round found 2 issues -> Not converged, outer iteration+1, return to Step 1.

       Step 1 (Round 2) Code Review...Dispatching 3 CodeReview Agents.
       All 3 Agents report 0 new issues -> Converged.

       Step 7 Summary output...Review and fix complete! Found and fixed 2 issues (High 1 / Medium 1 / Low 0).
```

### Output Example

```markdown
## Review and Fix Cycle Complete

Review scope: Staged changes
Review rounds: 2 rounds (Fix loop: 1 round)

| Severity | Count |
|----------|-------|
| 🔴 High  | 1     |
| 🟡 Medium| 1     |
| 🟢 Low   | 0     |
| **Total** | **2** |

### Fixed Issues

1. 🔴 `src/example.ts:42` — Fixed logic error: reverse condition check causing permission validation failure
2. 🟡 `src/example.ts:88` — Unified variable naming convention: camelCase replaced snake_case

### Generated Reports

- `docs/review-and-fix-cycle/20260628T120000Z/review-cycle-1.md`
- `docs/review-and-fix-cycle/20260628T120000Z/review-cycle-1-fix1.md`
- `docs/review-and-fix-cycle/20260628T120000Z/final-summary.md`

Final status: **Converged**
```
