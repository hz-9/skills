---
name: skill-evolve-cycle
description: Perform cyclic evolution on a specified SKILL: small cycles (optimize->fix and review->fix->re-review convergence) and large cycles (optimize->review->merge->backport) alternate iteratively until no new issues are found in review or iteration limit is reached. Use when the user wants to execute multiple rounds of evolutionary cycles on a target SKILL.
disable-model-invocation: true
---

# Skill Evolve Cycle

## Overview

Execute multiple rounds of "optimize->review->fix->merge->backport" cyclic evolution on a target SKILL. Alternately driven by skill-evolve (optimization phase) and Code Review (review phase), supporting evolution of skill-evolve itself.

## Definitions

- <a id="skill-original-repository"></a>**Skill original repository**: A repository whose remote URL is `git@github.com:hz-9/skills.git` or `https://github.com/hz-9/skills`. When the current workspace belongs to this repository, certain steps (backport) require additional execution.

- <a id="convergence"></a>**Convergence**: A state where a cycle at a certain level finds 0 new issues in the current iteration, satisfying the exit condition.

- <a id="whether-skill-repository"></a>**Whether skill repository**: Marks whether the current workspace belongs to the [skill original repository](#skill-original-repository). Initialized by Step 0.1 through `git remote get-url origin` matching, cached and reused throughout the entire flow.

### Convergence Conditions

| Level                  | Convergence Condition                                                                                       | Determination Position                                                                                                 |
| ---------------------- | ----------------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------- |
| **Small Cycle A Conv** | Current skill-evolve optimization finds **0 new issues**                                                    | Target SKILL aligned with standard structure, no items to optimize                                                      |
| **Small Cycle B Conv** | Current Code Review finds **0 new issues**                                                                  | Two cases: ① First review from fresh perspective finds no issues -> target SKILL stable; ② After fix, re-review finds no issues -> fix correct, no new issues introduced |
| **Large Cycle Conv**   | ① Current Small Cycle A first round finds 0 issues **AND** ② Large Cycle Step 2 Small Cycle B first Code Review finds **0 new issues** | Both conditions satisfied means target SKILL is stable, no issues to fix                                                |

> **New issue definition**: An issue newly discovered in this round compared to the last equivalent judgment result, which was not previously recorded. Recurrence of the same issue after being fixed counts as a new issue.

### Severity Classification

| Level      | Definition                                                | Example                                                      |
| ---------- | --------------------------------------------------------- | ------------------------------------------------------------ |
| **High**   | Structural issue or semantic error, may cause user misunderstanding or functionality failure | Missing key section, description format error, dead link     |
| **Medium** | Maintainability issue or non-critical omission            | Non-standard punctuation, inconsistent terminology, exceeds 300 lines but not split |
| **Low**    | Optimization suggestion, does not affect correctness       | Redundant content, recommended but not mandatory best practices |

## Prerequisites

- Target SKILL.md file already exists
- skill-evolve skill is available
- `docs/skill-evolve-cycle/` directory exists in the current workspace (create if not exists); UTC time subdirectory auto-created by Step 0

## Workflow

0. **Pre-check** — Check workspace state, remote repository ownership, and target identity;
  0.1 Attempt to execute `git remote get-url origin`:
    - Success and matches [skill original repository](#skill-original-repository) -> mark [whether skill repository](#whether-skill-repository) = true, then proceed to next step;
    - Success but does not match -> mark [whether skill repository](#whether-skill-repository) = false, then proceed to next step;
    - Command fails (not a Git repo or no remote) -> mark [whether skill repository](#whether-skill-repository) = false, report warning "Unable to get remote repository info, assuming [non-skill original repository](#skill-original-repository)", then proceed to next step;
  0.2 (Reserved: self-evolution scenario judgment; current version has no special handling, directly next step);
  0.3 Get current UTC time and create `docs/skill-evolve-cycle/{UTC-time}/` directory (create parent directories if they don't exist); all reports for this run are saved to this directory:
   - Creation successful -> next step;
   - Creation failed -> report "Directory creation failed", terminate flow;
  0.4 Verify general prerequisites:
   - Verify target SKILL.md exists and is readable:
     - Yes -> next step;
     - No -> report "Target file does not exist or cannot be read", terminate flow;
   - Verify skill-evolve skill is available (corresponding SKILL.md exists):
     - Yes -> next step;
     - No -> report "skill-evolve skill unavailable", terminate flow;

1. **Small Cycle A (Optimization)** — Use skill-evolve to optimize target SKILL until [convergence](#convergence);
  1.1 **skill-evolve optimization** — Use skill-evolve to optimize target SKILL (note: run the complete optimization flow and steps each time, do not perform quick checks; skill-evolve's own flow already includes investigation and fixes);
  1.2 **Generate iteration report** — Generate `cycle{round}-A-{iteration}.md` and save to `docs/skill-evolve-cycle/{UTC-time}/`;
  1.3 **Check whether to continue cycling** - Check the number of issues found
    - **Issues found** -> continue to 1.4;
    - **0 issues found** -> **Small Cycle A converged**, complete Small Cycle A, go to Large Cycle Step 2 (Small Cycle B);
    - **Execution failed (error returned)** -> mark "Small Cycle A - execution exception", continue to 1.4;
  1.4 **Small Cycle A iteration count check** — Check if Small Cycle A has reached the 30 iteration limit:
    - Yes -> force exit Small Cycle A, annotate "Small Cycle A - not fully converged" in report, go to Large Cycle Step 2 (Small Cycle B);
    - No -> return to 1.1, re-run optimization (Small Cycle A iteration count + 1);

2. **Small Cycle B (Review)** — Review target SKILL via Code Review and fix issues until [convergence](#convergence);

   Run the following steps until [convergence](#convergence);

  2.1 **Code Review** — **Each time this step is executed**, dispatch exactly **3** CodeReview Agents (Completeness, Correctness, Impact) in parallel, each independently reviewing the target SKILL from a fresh perspective, **prohibited from referencing previous review results or historical reports from this round (except for regression review scenarios, see 2.4); not allowed to downgrade because this step has been executed before or issue count has decreased**, each records discovered issues;
    - **All 3 Agents report 0 new issues** -> **Small Cycle B converged**, continue to Step 2.6;
    - **Any Agent finds issues** -> after deduplication, continue to 2.2;
    - **Any Agent unavailable due to environment failure** -> consider as environment failure, terminate flow and annotate "CodeReview Agent unavailable" in report;
  2.2 **Record issues** — Record each issue in the current round's report, annotate severity (High/Medium/Low);
  2.3 **Fix issues** — Fix all discovered issues one by one;
    - After each fix, generate a fix report `cycle{round}-B-{iteration}-fix{fix-round}.md`, recording fix method and result;
    - After all issues are fixed, increment fix round by 1, go to 2.4;
  2.4 **Regression review and cycle control** — Dispatch exactly **3** CodeReview Agents (Completeness, Correctness, Impact) in parallel, perform regression review on fixed issues (regression review Agents are not bound by the 2.1 prohibition on referencing history; may carry the current round's fix summary context), verify fixes are correct and no new issues introduced, each records findings;
    - All 3 Agents report **0 new issues** -> **Inner fix cycle converged**, continue to 2.5;
    - Any Agent finds issues -> after deduplication, return to 2.2 (fix round + 1);
  2.5 **Generate iteration report** — Summarize all fix records from this round, generate `cycle{round}-B-{iteration}.md` and save to `docs/skill-evolve-cycle/{UTC-time}/`;
  2.6 **Check whether to continue cycling** - Check the number of issues from step 2.1's 3 Agents in current cycle
    - **All 3 Agents report 0 new issues** -> **Small Cycle B converged**, go to Large Cycle Step 3;
    - **Any Agent finds issues** -> mark "Small Cycle B - execution exception", continue to 2.7;
  2.7 **Small Cycle B outer iteration count check** — Check if Small Cycle B outer iteration has reached the 30 iteration limit:
    - Yes -> force exit Small Cycle B, annotate "Small Cycle B - not fully converged" in report, go to Large Cycle Step 3;
    - No -> return to 2.1, re-run review (Small Cycle B outer iteration count + 1);

3. **Large Cycle [Convergence](#convergence) Judgment** — Check if Large Cycle [convergence](#convergence) condition is met (Small Cycle A first round 0 issues AND Small Cycle B first round 0 issues);
   3.1 Check if Small Cycle A first round this Large Cycle found 0 issues AND Small Cycle B first round review found 0 issues:
   - Yes -> continue to Step 7;
   - No -> continue to Step 4;
4. **Merge and Organize** — Summarize issues and categorize by type, route by flow divergence;

Summarize all issues found in Small Cycle A and Small Cycle B this round, categorize by type.

**Flow divergence**:

- [Whether skill repository](#whether-skill-repository) = true -> continue to Step 5;
- [Whether skill repository](#whether-skill-repository) = false -> skip Step 5, continue to Step 6;

5. **Backport to skill-evolve** — Write review experience by backport routing standard to appropriate files;

⚠️ This step is only executed when the current repository is the [skill original repository](#skill-original-repository). It will modify skill-evolve's SKILL.md or files under references/.

5.1 Execute pre-check per "Backport Routing Standard" in Rules, determine if valid backport content exists:
   - Yes -> query [Content Boundary Standard](../skill-evolve/references/content-boundary.md) to determine destination, provide options via AskUserQuestion, block and wait for user selection:
     - [Dynamic options generated by AI based on Code Review content + pre-check + [File Ownership Boundaries](../skill-evolve/references/content-boundary.md#file-ownership-boundaries)] -> execute corresponding backport items, then synchronously update SKILL.md's `## References` section, then proceed to next step;
   - No -> auto-skip, proceed to next step;
5.2 Was at least one backport performed:
   - Yes -> perform self-check on newly written backport content:
     - Self-check passed (new content has no self-contradictions or violations of new rules) -> re-read Skill Evolve's SKILL.md and references/ files (so new backport rules take effect when Step 1.1 calls skill-evolve), then proceed to next step;
     - Self-check failed -> revert that backport item, mark as "Pending manual confirmation", then proceed to next step;
   - No -> next step;

6. **Large Cycle Iteration Control** — Summarize reports and check Large Cycle iteration limit;

Summarize all reports from this round into `docs/skill-evolve-cycle/{UTC-time}/` directory, generate `cycle{round}-summary.md`. Check if 30 Large Cycle limit is reached:
- Not reached limit -> return to Step 1, start next Large Cycle (round + 1);
- Reached 30 limit -> terminate all flows, summarize all round reports, mark final state as "Large Cycle - not fully converged";

> Each Large Cycle has a maximum of 30 outer iterations (Steps 1->6 counted as one iteration). When the limit is reached without triggering Large Cycle convergence, terminate all flows, summarize all round reports, mark final state as "Large Cycle - not fully converged".

7. **Review Check** — Confirm optimization results against [Review List](#review-list);

- Check if Review List has content:
  - No -> directly go to next step (Output);
  - Yes -> next step;
- Sequentially check each item in [Review List](#review-list), whether it passes:
  - Yes -> continue to next check item;
  - No -> record failed check item (display output content based on [Review Check Example](#review-check-example));
- Check if any check failed:
  - Yes -> output [Review Check Example](#review-check-example), terminate all flows;
  - No -> all passed, proceed to next step (Output);

8. **Output** — Output optimization summary, inform completion;

- Output final report (refer to [Output Example](#output-example) for specific format), save to `docs/skill-evolve-cycle/{UTC-time}/final-summary.md`, mark **Large Cycle Converged**;
- Output structured summary (refer to [Output Example](#output-example) for specific format);
- Inform optimization complete;
- Terminate all flows;

## Rules

- **Behavior Standard**
  - **Auto-continuous execution**: Between Large Cycles, must automatically proceed to the next round without interruption waiting for user confirmation to manually trigger.
  - **Interaction mode inheritance**: When calling skill-evolve, AI follows the internal logic defined in skill-evolve's Workflow to determine whether to trigger AskUserQuestion. If skill-evolve triggers AskUserQuestion, skill-evolve-cycle must also trigger that AskUserQuestion; AI self-decision is not allowed;
  - **Small cycle convergence means advance**: After Small Cycle A converges, go to Large Cycle Step 2; after Small Cycle B converges, Large Cycle Step 3 determines the destination (Large Cycle convergence or go to Step 4). No interruption allowed;
  - **Agent type locking rule**: Throughout the entire flow, the Code Review phase of Small Cycle B (including 2.1 first review and 2.4 regression review) **must** use CodeReview Agents for review. Strictly prohibited from switching to GeneralPurpose Agent or other Agent types for any reason (including but not limited to "small change volume", "all issues already fixed", "current round only needs quick confirmation", "regression review doesn't need new Agents"). If the environment objectively does not support CodeReview Agents, terminate flow and annotate "CodeReview Agent unavailable" in report; do not downgrade and continue execution.
  - **Parallel count hard constraint rule**: Each Code Review round (including 2.1 first review and 2.4 regression review) must dispatch exactly **3** CodeReview Agents in parallel, independently covering the three perspectives of Completeness, Correctness, and Impact. Not allowed to reduce parallel count for any reason (including but not limited to "small change volume", "issue count decreased", "current round is regression review", "parallel Agent resources tight"). Review results from all 3 Agents must be independently recorded in the current round's report; cannot be merged into a single Agent's output.
  - **Process downgrade prohibition rule**: All steps must strictly follow the order, content, and execution method defined in Workflow; not allowed to skip, simplify, merge, or accelerate any step for any reason. In particular, Small Cycle B does not allow:
    - Skipping 2.1 full review because "all issues already fixed" and directly entering "quick verification of completeness"
    - Downgrading 3 parallel Agents to 1 Agent or AI self-review because "small change volume" or "issue count decreased"
    - Omitting full three-perspective checks in 2.4 regression review because "this is regression review"
    - Merging 2.4 regression review with subsequent rounds of 2.1 review
- **Content Standard**
  - **Report persistence**: Each small cycle and each large cycle's merged report is saved to `docs/skill-evolve-cycle/{UTC-time}/` directory. Naming rules:
    - Small Cycle A report `cycle{round}-A-{iteration}.md` (iteration refers to each re-run from Step 1)
    - Small Cycle A error report `cycle{round}-A-error.md` (generated when skill-evolve execution fails)
    - Small Cycle B fix report `cycle{round}-B-{iteration}-fix{fix-round}.md` (generated after each fix, fix round increments from 1)
    - Small Cycle B iteration report `cycle{round}-B-{iteration}.md` (iteration refers to outer cycle count, generated each time re-review starts from Step 1)
    - Large Cycle merged report `cycle{round}-summary.md`
    - Final summary report `final-summary.md`
  - **Prohibition of labels outside workflow**: The execution and reports are **strictly prohibited** from containing flow labels or status identifiers not defined in the Workflow, including but not limited to "Final Code Review", "Last Review", "Final Confirmation", "Closing Review", "Final Round". All review rounds must uniformly use the names and identifiers defined in the Workflow (e.g., `cycle{N}-B-{iteration}.md`, `cycle{N}-B-{iteration}-fix{fix-round}.md`). Convergence determination is based solely on the convergence conditions and status labels defined in the Workflow.
- **Validation Standard**
  - **[Skill original repository](#skill-original-repository) determination**: Determine by matching the output of `git remote get-url origin` against known repository addresses, cache the result as [whether skill repository](#whether-skill-repository), reuse throughout the entire flow;
  - **Backport routing standard**: During the backport phase (Step 5), determine whether review experience should be backported and where, following this process:
    - **Pre-check**:
      - Is it this Code Review's unique, non-reproducible noise -> skip;
      - Does it already exist in SKILL.md or references/ (including same-semantic expressions) -> update existing content, skip backport;
      - Does not exist and worth backporting -> continue to routing determination;
    - **Routing determination**: Query [Content Boundary Standard](../skill-evolve/references/content-boundary.md):
      - Matches a reference file -> write to that file, do not append to SKILL.md;
      - Matches "Remain in SKILL.md" -> write to corresponding SKILL.md section;
      - No match -> ask user via AskUserQuestion;
    - After backporting, synchronously update SKILL.md's `## References` section;

## Examples

### Dialogue Interaction Example

```markdown
User > Run cyclic evolution on skills.zh-CN/skill-evolve/SKILL.md

AI > Starting skill-evolve-cycle:

     Cycle 1 — Large Cycle 1:
     Step 0  Pre-check…whether skill repository = true.
     Step 1  Small Cycle A (Optimization)…optimizing self, found 3 issues, fixed and converged.
     Step 2  Small Cycle B (Review)…found 2 issues, fixed and converged.
     Step 3  Large Cycle convergence check…Small Cycle A first round found issues -> go to Step 4.
     Step 4  Merge and organize…whether skill repository = true -> go to Step 5.
     Step 5  Backport to skill-evolve…3 new rules synchronized.
     Step 5.2 Backport exists -> re-read files, proceed to next step.
     Step 6  Large Cycle iteration control…round not at limit, return to Step 1 for next round.

     Cycle 2 — Large Cycle 2:
     Step 1  Small Cycle A (Optimization)…full optimization, found 0 new issues.
     Step 2  Small Cycle B (Review)…fresh perspective, found 0 new issues.
     Step 3  Large Cycle convergence check…Small Cycle A first round 0 issues + Small Cycle B first round 0 issues -> yes, go to Step 7.
     Steps 4-6 Skipped here (convergence doesn't need merge/backport/output)
     Steps 7-8 Review Check and Output passed.
```

### Review Check Example

```markdown
AI > Preparing for review check, checking against Review List item by item:

**Process Completeness Check**

  - 🟩 All report files saved to docs/skill-evolve-cycle/{UTC-time}/ directory? Saved cycle1-A-1.md, cycle1-B-1.md
  - 🟩 Convergence reason recorded? Recorded in cycle1-summary.md
  - 🟩 Force exit marking complete? All force exit scenario states annotated

**Result Consistency Check**

  - 🟩 Target SKILL.md description format correct? Aligned with standard format
  - 🟩 Target SKILL.md aligned with template structure? Aligned
  - 🟩 Backport did not break skill-evolve's own consistency? Checked, no conflicts

**Interaction Completeness Check**

  - 🟩 Small Cycle A phase: AskUserQuestion not suppressed by loops? Confirmed 3 triggers all correct

**!!! The following checks did NOT pass !!!**

**Result Consistency Check**

  - 🟥 Backport routing verification: Step 5.1 backport destination AskUserQuestion not covered in Review List — Terminate flow, suggest adding verification item and re-executing.

(AI will output all check item results one by one during runtime)
```

### Output Example

```markdown
## 🎉 skill-evolve-cycle Evolution Complete

Cyclic evolution of `[target SKILL path]` has been completed. Below is the execution summary:

### Execution Info

| Item           | Value                                       |
| -------------- | ------------------------------------------- |
| Repository     | `[repo URL]` (Skill Original Repo ✅ / ❌)  |
| Target SKILL   | `[skill name]` (↔ Self-evolution / Normal target) |
| Large Cycles   | [number] rounds                             |
| Total Fixed    | **[number] issues** (High [n] / Med [n] / Low [n]) |
| Final Status   | **Large Cycle Converged**                   |

### Fixed Issues Summary

**Cycle 1** — Issues found and fixed:

1. 🔴 [High severity issue brief]
2. 🟡 [Medium severity issue brief]
3. 🟢 [Low severity issue brief]

**Cycle 2** — Issues found from fresh perspective and fixed: 4. 🟡 [Medium severity issue brief]

### File Changes

- **`[modified file path]`** — [line change summary]
- **`docs/skill-evolve-cycle/{UTC-time}/`** — Generated [n] reports this round

### Backports

- [Backport content summary]
```

## Review List

After execution is complete, verify the following:

- **Process Completeness Check**
  - [ ] All report files saved to `docs/skill-evolve-cycle/{UTC-time}/` directory with correct naming
  - [ ] Convergence/termination reason recorded in final report
  - [ ] Force exit marking complete: all force exit scenarios (Small Cycle A/B not fully converged, Small Cycle B fix stuck, Small Cycle A execution exception, skill-evolve continuous failure - terminated, CodeReview Agent unavailable) have state annotated in corresponding reports
  - [ ] Pre-check termination handling: Step 0.4 correctly terminates flow and reports reason when target file does not exist or skill-evolve unavailable
  - [ ] skill-evolve execution failure handling: Step 1.1 execution failure generates `cycle{round}-A-error.md` error report and correctly enters Large Cycle Step 3
  - [ ] Step 4 flow divergence routing correct: based on [whether skill repository](#whether-skill-repository) flag, divergence executed as expected
  - [ ] File re-read after backport: Step 5.2 re-reads skill-evolve's SKILL.md and references/ files after backport execution
  - [ ] References section update after backport: Step 5.1 synchronously updates `## References` section after backport execution
- **Result Consistency Check**
  - [ ] Target SKILL.md's description conforms to skill-evolve standard format
  - [ ] Target SKILL.md aligned with standard template structure (all standard sections present, Secure steps complete, step order correct)
  - [ ] Target SKILL.md's Workflow step format conforms to standards (titles use `N. **Title** — Description;` plain text format, sub-steps use `N.M` digital numbering or tree arrow format)
  - [ ] Backport content does not break skill-evolve's own consistency
- **Interaction Completeness Check**
  - [ ] Small Cycle A phase: skill-evolve's AskUserQuestion triggers are not suppressed by loops; interactions triggered correctly for conflict decisions/irreversible operations
  - [ ] Backport phase (Step 5.1/Backport routing standard): decisions about backport content destination correctly triggered via AskUserQuestion; user confirmation mechanism provided when no match

## References

- [skill-evolve](../skill-evolve/SKILL.md): Single SKILL structure standardization and content optimization
- [SKILL Directory Structure](../skill-evolve/references/directory-structure.md)
- [Content Boundary Standard](../skill-evolve/references/content-boundary.md): Defines content ownership boundaries between SKILL.md and references/ files
