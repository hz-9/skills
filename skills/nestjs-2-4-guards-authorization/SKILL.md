---
name: nestjs-2-4-guards-authorization
description: Review NestJS guard implementation and authorization control strategies, covering role-based guards, permission checks, and custom access policies. Use when users need to review authentication/authorization logic or develop access control strategies.
---

# NestJS Authorization Control and Guards

## Overview

When AI encounters guard-related code in a NestJS project, it automatically performs the following: review the guard implementation and registration method, check the completeness of permission checking logic, evaluate the design of role control and custom access strategies, identify authorization bypass risks, and provide improvement suggestions.

## Definitions

- <a id="target-code"></a>**Target Code**: The NestJS guard implementation code, permission metadata definitions, or custom access policy code in the current conversation.
- <a id="guard-interface"></a>**Guard Interface**: The CanActivate interface that all guards must implement, containing the canActivate(context: ExecutionContext) method.
- <a id="metadata-reflection"></a>**Metadata Reflection**: A data transfer mechanism between guards implemented via the @SetMetadata decorator and the Reflector class.
- <a id="analysis-complete"></a>**Analysis Complete**: Indicates whether the analysis of the target code has yielded a complete result.

## Prerequisites

- NestJS project environment;
- Guard implementation or access control configuration code is accessible;
- Understanding of the guard's execution order in the NestJS request processing chain (after middleware, before interceptors).

## Workflow

0. **Pre-check** — Ensure the target code and runtime environment are reachable;
   - Determine if the target code exists and is readable:
     - Yes -> next step;
     - No -> prompt the user to provide the target code or file path, block and wait for user input;
   - Initialize global variable [Analysis Complete](#analysis-complete):
     - Determine if the code is complete and parseable:
       - Satisfied -> initialize variable to true;
       - Not satisfied -> initialize variable to false;

1. **Analyze guard code** — Read and understand the guard implementation and permission control logic;
   - Read the target code, identify the following core elements:
     - Guard class implementation approach (implementing the CanActivate interface);
     - Implementation logic and return value of the canActivate method;
     - Permission metadata defined via @SetMetadata;
     - How Reflector reads metadata within the guard;
     - Guard registration method (global / controller / method-level);

2. **Item-by-item review** — Check guard code quality against the review checklist;
   - Sequentially evaluate whether each review item passes:
     - Does the canActivate method return a boolean value in all branches (true to allow, false to reject):
       - Pass -> record as passed, continue to the next review item;
       - Fail -> record "canActivate must return a boolean value; branches without a return will throw an exception", continue;
     - Is Reflector used to read controller or method metadata:
       - Pass -> record as passed, continue to the next review item;
       - Fail -> record "Recommend using Reflector to read permission metadata defined via @SetMetadata", continue;
     - Does the guard perform actual authentication/authorization checks (rather than just returning true):
       - Pass -> record as passed, continue to the next review item;
       - Fail -> record "Guard always returning true may lead to missing authorization checks", continue;
     - Are role or permission metadata set at the correct level (controller or method):
       - Pass -> record as passed, continue to the next review item;
       - Fail -> record "Metadata set at the wrong level may prevent the guard from reading it correctly", continue;
     - Does the guard handle exceptions properly (e.g., token expiration, error handling when unauthorized):
       - Pass -> record as passed, continue to the next review item;
       - Fail -> record "Uncaught exceptions in guard, recommend throwing specific HttpException", continue;
   - Determine if any issues were recorded:
     - Yes -> summarize the issue list, proceed to the next step;
     - No -> proceed directly to step 4 (Review Check);

3. **Provide modification suggestions** — Offer specific fix solutions for the identified issues;
   - Provide fix suggestions for each issue in order;
   - Present options via AskUserQuestion, block and wait for user selection:
     - Accept all suggestions -> generate corrected code, proceed to step 4;
     - Confirm one by one -> user decides to accept or ignore each item, proceed to step 4 after all confirmed;
     - View only, no modification -> do not affect the code, proceed directly to step 4;

4. **Review Check** — Verify execution results against [Review List](#review-list);
   - Determine if Review List has content:
     - No -> proceed directly to the next step (Output Results);
     - Yes -> next step;
   - Sequentially check each item in [Review List](#review-list) to see if it passes:
     - Display output based on the "Review Check Example";
   - If any check fails, terminate the process;
   - If all pass, proceed to the next step;

5. **Output Results** — Output the review summary, notify completion;
   - Output a structured summary table (Review File / Total Items / Passed / Issues Found / Risk Level / Suggestions Accepted);
   - Notify that the review is complete;

## Rules

- **Content Standards**
  - description must follow the format: first sentence describes the review content, second sentence describes the trigger condition, use third person, no more than 1024 characters;
  - Review items must reference NestJS official documentation on guards;
  - SKILL.md must not exceed 300 lines; split into references/ directory when exceeded;
  - Reference depth must not exceed one level;
  - Maintain terminology consistency, terms defined in Definitions must be referenced via anchor links in the body;
  - Remove any time-sensitive information;

- **Behavior Standards**
  - During review, only output issue summaries and locations, do not directly modify code unless the user explicitly requests it via AskUserQuestion;
  - All interaction steps involving code modification must use the AskUserQuestion tool;
  - Permission policy suggestions should be marked as architectural suggestions, not mandatory;

- **Defensive Standards**
  - If the target code is empty or unreadable, report directly and terminate;
  - Guard always returning true should only be reported as an issue when it can be clearly confirmed (e.g., no authentication middleware in front);

- **Validation Standards**
  - Examples content must be self-consistent with Rules;
  - Examples must include a review check example;
  - Dialogue interaction examples should only focus on steps 0~3 (excluding review check and output results);

## Examples

### Dialogue Interaction Example

**Example: User requests guard implementation review**

```markdown
User > Please check this RolesGuard implementation
AI   > Detected user needs NestJS guard and authorization review, triggering nestjs-2-4-guards-authorization skill
AI   > Analyzing guard code...

Review Results:
- 🟩 Implements CanActivate interface
- 🟥 Error handling branch missing return false, may fail to reject unauthorized access
- 🟩 Correctly uses Reflector to read @Roles() metadata
- 🟩 Guard registered at controller level, scope is clear
- 🟥 Token expiration scenario not handled, throws generic Unknown exception

Summary: 2 issues need attention
User > Please fix the return value issue in the error branch
AI   > Need to add return false or throw ForbiddenException. Apply the change?
User > Yes
```

### Review Check Example

```markdown
AI > Entering review check, Review List contains 5 items, starting item-by-item verification:

**Content Check**
  - 🟩 All review items reference official guard documentation
  - 🟩 Permission suggestions are marked as architectural suggestions

**Behavior Check**
  - 🟩 Did not directly modify user code
  - 🟩 Used AskUserQuestion

**Validation Check**
  - 🟩 Always returning true is only reported when clearly confirmed
  - 🟩 Output summary is complete

✅ All passed, proceeding to output results.
```

### Output Results Example

**Review Results Example:**

```markdown
| Dimension | Result |
| --- | --- |
| Review File | src/common/guards/roles.guard.ts |
| Total Items | 6 items |
| Passed | 4 items |
| Issues Found | 2 items |
| Risk Level | 🔴 High |
| Suggestions Accepted | 1 suggestion |
| Ignored / View Only | 1 item |
```

## Review List

- **Content Check**
  - [ ] All review items reference NestJS official guard documentation
  - [ ] Permission policy suggestions are marked as architectural suggestions, not mandatory
- **Behavior Check**
  - [ ] Did not directly modify user code (unless explicitly requested by the user)
  - [ ] All interaction steps used AskUserQuestion
- **Validation Check**
  - [ ] Correctly terminated when target code is empty or unreadable
  - [ ] Guard always returning true is only reported when clearly confirmed
  - [ ] Output summary includes file path, number of items, issues found, and risk level

## References

- [NestJS Guards Official Documentation](https://docs.nestjs.com/guards)
- [NestJS Custom Metadata and Decorators](https://docs.nestjs.com/fundamentals/execution-context)
- [skill-evolve 模板](../../skill-evolve/template.md)
