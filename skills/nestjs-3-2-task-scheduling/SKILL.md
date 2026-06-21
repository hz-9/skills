---
name: nestjs-3-2-task-scheduling
description: Review NestJS scheduled task and asynchronous task orchestration implementation, covering @nestjs/schedule and custom task registration. Use when users need to review scheduled task configuration or develop background jobs.
---

# NestJS Asynchronous Tasks and Scheduling

## Overview

When AI encounters scheduled task or asynchronous task related code in a NestJS project, it automatically performs the following: review the usage of @nestjs/schedule decorators, check the correctness of Cron expressions and interval configurations, evaluate task concurrency control and error handling strategies, and provide improvement suggestions.

## Definitions

- <a id="target-code"></a>**Target code**: The NestJS scheduled task classes, Cron methods, or task scheduling configuration code in the current conversation.
- <a id="cron-decorator"></a>**Cron decorator**: The @Cron, @Interval, @Timeout decorators provided by @nestjs/schedule, corresponding to Cron expressions, scheduled intervals, and one-time delayed execution respectively.
- <a id="ScheduleModule"></a>**ScheduleModule**: The root module of @nestjs/schedule, registered in AppModule using ScheduleModule.forRoot().
- <a id="analysis-complete"></a>**Analysis complete**: Indicates whether the analysis of the target code has been fully completed.

## Prerequisites

- NestJS project environment (including @nestjs/schedule dependency);
- Scheduled task classes or scheduling configuration code accessible;
- Understanding of basic Cron expression syntax.

## Workflow

0. **Pre-check** — Ensure the target code and runtime environment are reachable;
   - Determine if the target code exists and is readable:
     - Yes -> next step;
     - No -> prompt the user to provide the target code or file path, block and wait for user input;
   - Initialize global variable [analysis complete](#analysis-complete):
     - Determine if the code is fully parseable:
       - Satisfied -> initialize variable to true;
       - Not satisfied -> initialize variable to false;

1. **Analyze task code** — Read and understand scheduled tasks and scheduling configuration;
   - Read the target code, identify the following core elements:
     - Whether ScheduleModule.forRoot() is registered in the root module;
     - Parameter configuration of @Cron, @Interval, @Timeout decorators;
     - Exception handling logic in task methods;

2. **Review items** — Check task scheduling code quality against the review checklist;
   - Iterate through the following review items to determine if they pass:
     - Whether the Cron expression is correct (six or seven position format, each part within valid range):
       - Pass -> record as passed, continue to next review item;
       - Fail -> record "Cron expression format may be incorrect, please check each part's value range", continue;
     - Whether long-running tasks have configuration to prevent overlapping execution (@Cron name and preventOverlap):
       - Pass -> record as passed, continue to next review item;
       - Fail -> record "Long-running tasks should enable preventOverlap to avoid overlapping execution", continue;
     - Whether task methods include exception handling logic (exceptions inside @Cron methods are silently swallowed by default):
       - Pass -> record as passed, continue to next review item;
       - Fail -> record "Exceptions in scheduled tasks are silently swallowed by default, recommend adding try/catch and logging", continue;
     - Whether ScheduleModule is only imported in modules that need task scheduling (avoid unnecessary global registration):
       - Pass -> record as passed, continue to next review item;
       - Fail -> record "ScheduleModule only needs to be imported in modules that use scheduling functionality", continue;
     - Whether scheduled tasks are disabled in the test environment (avoid triggering real tasks during testing):
       - Pass -> record as passed, continue to next review item;
       - Fail -> record "Recommend disabling ScheduleModule in the test environment", continue;
   - Determine if there are any issue records:
     - Yes -> compile issue list, proceed to next step;
     - No -> directly proceed to step 4 (review check);

3. **Provide modification suggestions** — Give specific fixes for identified issues;
   - Provide fix suggestions for each issue in sequence;
   - Offer options via AskUserQuestion, block and wait for user selection:
     - Accept all suggestions -> generate corrected code, proceed to step 4;
     - Confirm one by one -> let the user decide to accept or ignore each item, proceed to step 4 after all confirmed;
     - Review only without modification -> do not affect code, directly proceed to step 4;

4. **Review check** — Confirm execution results against [Review List](#review-list);
   - Determine if Review List has content:
     - No -> directly proceed to next step (output);
     - Yes -> next step;
   - Check each item in [Review List](#review-list) sequentially to see if it passes:
     - Display output based on the "Review check example";
   - If any check fails, terminate the process;
   - After all pass, proceed to next step;

5. **Output results** — Output review summary, inform completion;
   - Output structured summary table (reviewed file / number of review items / passed / issues found / risk level / adopted suggestions);
   - Inform the review is complete;

## Rules

- **Content rules**
  - description must follow format: first sentence describes review content, second sentence describes trigger condition, use third person, no more than 1024 characters;
  - Review items must reference NestJS official task scheduling documentation;
  - SKILL.md no more than 300 lines; split to references/ directory when exceeded;
  - Reference hierarchy no more than one level;
  - Maintain terminology consistency, terms defined in Definitions must be referenced via anchor links in the body;
  - Remove any time-sensitive information;

- **Behavior rules**
  - Only output issue summaries and locations during review, do not directly modify code unless the user explicitly requests via AskUserQuestion;
  - All interaction steps involving code modification must use the AskUserQuestion tool;
  - preventOverlap and test environment disabling should be labeled as recommendations, not mandatory;

- **Defensive rules**
  - If target code is empty or unreadable, report directly and terminate;
  - Cron expressions should only be reported when clearly incorrect, complex expressions should be labeled as requiring manual verification;

- **Validation rules**
  - Examples content must be self-consistent with Rules;
  - Examples must include a review check example;
  - Dialogue interaction examples should only focus on steps 0~3 (excluding review check and output);

## Examples

### Dialogue Interaction Example

**Example: User requests scheduled task configuration review**

```markdown
User > Help me check the scheduled task configuration
AI   > Detected user needs NestJS task scheduling review, triggered nestjs-3-2-task-scheduling skill
AI   > Analyzing scheduled task code...

Review Results:
- 🟩 ScheduleModule.forRoot() is correctly registered
- 🟥 Cron expression '0 0 * * *' only has five positions (missing seconds)
- 🟥 syncData method does not catch exceptions, failures won't be logged
- 🟩 preventOverlap is enabled
- 🟥 Scheduled tasks not disabled in test environment

Summary: 3 issues need attention
User > Help me fix exception handling and test environment disabling
AI   > Add try/catch logging and test environment condition check. Apply changes?
User > Accept all
```

### Review Check Example

```markdown
AI > Entering review check, Review List contains 5 items, starting verification:

**Content Check**
  - 🟩 All review items reference official documentation
  - 🟩 preventOverlap labeled as recommendation

**Behavior Check**
  - 🟩 Did not directly modify user code
  - 🟩 Used AskUserQuestion

**Validation Check**
  - 🟩 Cron expressions labeled as requiring verification
  - 🟩 Output summary is complete

✅ All passed, proceeding to output.
```

### Output Example

**Review Result Example:**

```markdown
| Dimension | Result |
| --- | --- |
| Reviewed File | src/tasks/sync-data.task.ts |
| Total Review Items | 6 items |
| Passed | 3 items |
| Issues Found | 3 items |
| Risk Level | 🟡 Medium |
| Suggestions Adopted | 2 items |
| Ignored/Reviewed Only | 1 item |
```

## Review List

- **Content Check**
  - [ ] All review items reference NestJS official task scheduling documentation
  - [ ] preventOverlap and test disabling labeled as recommendations
- **Behavior Check**
  - [ ] Did not directly modify user code (unless explicitly requested by the user)
  - [ ] All interaction steps used AskUserQuestion
- **Validation Check**
  - [ ] Correctly terminated when target code is empty or unreadable
  - [ ] Cron expressions reported when clearly incorrect
  - [ ] Output summary includes file path, number of review items, issues found, and risk level

## References

- [NestJS Task Scheduling Official Documentation](https://docs.nestjs.com/techniques/task-scheduling)
- [@nestjs/schedule Documentation](https://github.com/nestjs/schedule)
- [skill-evolve Template](../../skill-evolve/template.md)
