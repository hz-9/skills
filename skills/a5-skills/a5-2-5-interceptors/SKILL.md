---
name: nestjs-2-5-interceptors
description: Review NestJS interceptor design and implementation, covering request/response transformation, logging, caching, and exception mapping aspects. Use when users need to review or develop interceptor logic.
---

# NestJS Aspect Interception and Data Processing

## Overview

When AI encounters interceptor-related code in a NestJS project, it automatically performs the following: review the interceptor implementation and registration method, check the standard conformance of RxJS operator usage, evaluate the correctness of response mapping and data transformation logic, identify common interceptor pitfalls, and provide improvement suggestions.

## Definitions

- <a id="target-code"></a>**Target Code**: The NestJS interceptor implementation code or controller code using interceptors in the current conversation.
- <a id="interceptor-interface"></a>**Interceptor Interface**: The NestInterceptor interface that all interceptors must implement, containing the intercept(context: ExecutionContext, next: CallHandler) method.
- <a id="callhandler"></a>**CallHandler**: An interface in interceptors used to call the next handler, returning an Observable via the handle() method.
- <a id="rxjs-operators"></a>**RxJS Operators**: Commonly used RxJS operators in interceptors, including map, tap, catchError, timeout, retry, etc.
- <a id="analysis-complete"></a>**Analysis Complete**: Indicates whether the analysis of the target code has yielded a complete result.

## Prerequisites

- NestJS project environment;
- Interceptor implementation code is accessible;
- Understanding of basic RxJS operators and the Observable pattern.

## Workflow

0. **Pre-check** — Ensure the target code and runtime environment are reachable;
   - Determine if the target code exists and is readable:
     - Yes -> next step;
     - No -> prompt the user to provide the target code or file path, block and wait for user input;
   - Initialize global variable [Analysis Complete](#analysis-complete):
     - Determine if the code is complete and parseable:
       - Satisfied -> initialize variable to true;
       - Not satisfied -> initialize variable to false;

1. **Analyze interceptor code** — Read and understand the interceptor implementation and data processing logic;
   - Read the target code, identify the following core elements:
     - Interceptor implementation approach (implementing the NestInterceptor interface);
     - How next.handle() is called in the intercept method;
     - The order of RxJS operator chains in pipe() (map, tap, catchError, etc.);
     - Interceptor registration method (global / controller / method-level);

2. **Item-by-item review** — Check interceptor code quality against the review checklist;
   - Sequentially evaluate whether each review item passes:
     - Does the interceptor call next.handle() (without it, downstream controllers will not execute):
       - Pass -> record as passed, continue to the next review item;
       - Fail -> record "next.handle() not called, controller method will not be executed", continue;
     - Does the RxJS pipe() include a catchError operator (to prevent uncaught exceptions from propagating to the client):
       - Pass -> record as passed, continue to the next review item;
       - Fail -> record "Missing catchError, exceptions thrown in the interceptor may not be handled properly", continue;
     - Is the response mapping logic correct (does the transformation function in the map operator maintain data structure integrity):
       - Pass -> record as passed, continue to the next review item;
       - Fail -> record "Response mapping may have altered the expected response structure", continue;
     - Does the interceptor use Observable operator chains rather than raw Promises (to fully leverage RxJS capabilities):
       - Pass -> record as passed, continue to the next review item;
       - Fail -> record "Recommend using RxJS operator chains instead of raw Promises to leverage operator capabilities", continue;
     - Is the timeout value in timeout interceptors set appropriately (to avoid killing normal requests):
       - Pass -> record as passed, continue to the next review item;
       - Fail -> record "Timeout value is unreasonable, recommend adjusting based on business scenarios", continue;
     - Is the execution order of multiple interceptors as expected (global → controller → method):
       - Pass -> record as passed, continue to the next review item;
       - Fail -> record "Interceptor registration order may cause unexpected behavior, please check execution order", continue;
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
  - Review items must reference NestJS official documentation on interceptors;
  - SKILL.md must not exceed 300 lines; split into references/ directory when exceeded;
  - Reference depth must not exceed one level;
  - Maintain terminology consistency, terms defined in Definitions must be referenced via anchor links in the body;
  - Remove any time-sensitive information;

- **Behavior Standards**
  - During review, only output issue summaries and locations, do not directly modify code unless the user explicitly requests it via AskUserQuestion;
  - All interaction steps involving code modification must use the AskUserQuestion tool;
  - RxJS operator selection should be marked as suggestions, not mandatory (different operators suit different scenarios);

- **Defensive Standards**
  - If the target code is empty or unreadable, report directly and terminate;
  - Timeout reasonableness should only be suggested when comparable interfaces are available for reference; otherwise, mark as requiring manual confirmation;

- **Validation Standards**
  - Examples content must be self-consistent with Rules;
  - Examples must include a review check example;
  - Dialogue interaction examples should only focus on steps 0~3 (excluding review check and output results);

## Examples

### Dialogue Interaction Example

**Example: User requests interceptor implementation review**

```markdown
User > Please check this response wrapper interceptor
AI   > Detected user needs NestJS interceptor review, triggering nestjs-2-5-interceptors skill
AI   > Analyzing interceptor code...

Review Results:
- 🟩 Correctly implements NestInterceptor interface
- 🟩 next.handle() is called to ensure normal controller execution
- 🟥 Missing catchError in pipe(), exceptions are not caught
- 🟥 Uses Promise.then() instead of RxJS map operator
- 🟩 Registered at global level, applies to all routes

Summary: 2 issues need attention
User > Please replace Promise with RxJS operators
AI   > Can use pipe(map()) instead of .then(). Apply the change?
User > Accept all
```

### Review Check Example

```markdown
AI > Entering review check, Review List contains 6 items, starting item-by-item verification:

**Content Check**
  - 🟩 All review items reference official interceptor documentation
  - 🟩 RxJS operator suggestions are marked as suggestions

**Behavior Check**
  - 🟩 Did not directly modify user code
  - 🟩 Used AskUserQuestion

**Validation Check**
  - 🟩 Timeout suggestions are marked as requiring manual confirmation
  - 🟩 Output summary is complete

✅ All passed, proceeding to output results.
```

### Output Results Example

**Review Results Example:**

```markdown
| Dimension | Result |
| --- | --- |
| Review File | src/common/interceptors/response-wrapper.interceptor.ts |
| Total Items | 7 items |
| Passed | 5 items |
| Issues Found | 2 items |
| Risk Level | 🟡 Medium |
| Suggestions Accepted | 2 suggestions |
```

## Review List

- **Content Check**
  - [ ] All review items reference NestJS official interceptor documentation
  - [ ] RxJS operator selection is marked as suggestions, not mandatory
- **Behavior Check**
  - [ ] Did not directly modify user code (unless explicitly requested by the user)
  - [ ] All interaction steps used AskUserQuestion
- **Validation Check**
  - [ ] Correctly terminated when target code is empty or unreadable
  - [ ] Timeout reasonableness is marked as requiring manual confirmation
  - [ ] Output summary includes file path, number of items, issues found, and risk level

## References

- [NestJS Interceptors Official Documentation](https://docs.nestjs.com/interceptors)
- [RxJS Operators Documentation](https://rxjs.dev/api/operators)
- [skill-evolve 模板](../../skill-evolve/template.md)
