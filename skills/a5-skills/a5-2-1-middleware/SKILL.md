---
name: nestjs-2-1-middleware
description: Review NestJS middleware implementation and application, including function middleware, class middleware, and registration strategies for both global and module-level middleware. Use when users need to review or develop middleware logic.
---

# NestJS Middleware Application

## Overview

When AI encounters middleware-related code in a NestJS project, it automatically performs the following: review the middleware registration method and scope, check the implementation standards for function middleware and class middleware, evaluate middleware execution order and applicable scenarios, and provide improvement suggestions.

## Definitions

- <a id="target-code"></a>**Target Code**: The NestJS middleware implementation or configuration code in the current conversation.
- <a id="middleware-type"></a>**Middleware Type**: Two forms of middleware supported by NestJS — Function Middleware and Class Middleware (implementing the NestMiddleware interface).
- <a id="registration-method"></a>**Registration Method**: Three ways to mount middleware — global middleware (app.use), module-level middleware (configure method), controller-level middleware (@MiddlewareConsumer).
- <a id="analysis-complete"></a>**Analysis Complete**: Indicates whether the analysis of the target code has yielded a complete result.

## Prerequisites

- NestJS project environment;
- Middleware code or configuration code files are accessible;
- Understanding of the middleware's position and purpose in the request processing chain.

## Workflow

0. **Pre-check** — Ensure the target code and runtime environment are reachable;
   - Determine if the target code exists and is readable:
     - Yes -> next step;
     - No -> prompt the user to provide the target code or file path, block and wait for user input;
   - Initialize global variable [Analysis Complete](#analysis-complete):
     - Determine if the code is complete and parseable:
       - Satisfied -> initialize variable to true;
       - Not satisfied -> initialize variable to false;

1. **Analyze middleware code** — Read and understand the middleware implementation and configuration;
   - Read the target code, identify the following core elements:
     - Middleware type (function vs class middleware);
     - Middleware application configuration (global app.use / module configure / controller-level);
     - Whether next() is properly called in all code branches;

2. **Item-by-item review** — Check middleware code quality against the review checklist;
   - Sequentially evaluate whether each review item passes:
     - Is the middleware type selection reasonable (class middleware supports DI injection, function middleware is suitable for dependency-free scenarios):
       - Pass -> record as passed, continue to the next review item;
       - Fail -> record "Consider using class middleware if dependency injection is needed", continue;
     - Is next() called in all branch logic (to avoid hanging requests):
       - Pass -> record as passed, continue to the next review item;
       - Fail -> record "Branch(es) missing next() call, may cause request timeout", continue;
     - Is global middleware registered via app.use() (outside Nest module management scope):
       - Pass -> record as passed, continue to the next review item;
       - Fail -> record "Global middleware is recommended to use app.use() in main.ts", continue;
     - Is the exclude() path configuration correct (to prevent sensitive routes from being intercepted by middleware):
       - Pass -> record as passed, continue to the next review item;
       - Fail -> record "Exclude path configuration is incorrect, please check the regex or path string", continue;
     - Does the middleware contain async operations with unhandled errors (uncaught async exceptions):
       - Pass -> record as passed, continue to the next review item;
       - Fail -> record "Async operations in middleware need try/catch or catchError handling", continue;
   - Determine if any issues were recorded:
     - Yes -> summarize the issue list, proceed to the next step;
     - No -> proceed directly to step 4 (Review Check);

3. **Provide modification suggestions** — Offer specific fix solutions for the identified issues;
   - Provide fix suggestions for each issue in order, including positive and negative comparison examples;
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
  - Review items must reference NestJS official documentation on middleware;
  - SKILL.md must not exceed 300 lines; split into references/ directory when exceeded;
  - Reference depth must not exceed one level;
  - Maintain terminology consistency, terms defined in Definitions must be referenced via anchor links in the body;
  - Remove any time-sensitive information;

- **Behavior Standards**
  - During review, only output issue summaries and locations, do not directly modify code unless the user explicitly requests it via AskUserQuestion;
  - All interaction steps involving code modification must use the AskUserQuestion tool;
  - Middleware type selection suggestions should be marked as suggestions, not mandatory;

- **Defensive Standards**
  - If the target code is empty or unreadable, report directly and terminate;
  - Mark complex exclude path regex as requiring manual confirmation of correctness;

- **Validation Standards**
  - Examples content must be self-consistent with Rules;
  - Examples must include a review check example;
  - Dialogue interaction examples should only focus on steps 0~3 (excluding review check and output results);

## Examples

### Dialogue Interaction Example

**Example: User requests middleware implementation review**

```markdown
User > Please check this middleware code
AI   > Detected user needs NestJS middleware review, triggering nestjs-2-1-middleware skill
AI   > Analyzing middleware code...

Review Results:
- 🟩 Uses class middleware implementing NestMiddleware interface, supports DI injection
- 🟥 Error handling branch does not call next(), may hang the request
- 🟩 forRoutes and exclude configured in module-level configure()
- 🟩 Exclude path correctly excludes the health check endpoint

Summary: 1 issue needs attention
User > Please fix the next() issue
AI   > The error branch needs to add return next(error). Apply the change?
User > Yes
```

### Review Check Example

```markdown
AI > Entering review check, Review List contains 5 items, starting item-by-item verification:

**Content Check**
  - 🟩 All review items reference official documentation
  - 🟩 Middleware type suggestions are marked as suggestions

**Behavior Check**
  - 🟩 Did not directly modify user code
  - 🟩 Used AskUserQuestion

**Validation Check**
  - 🟩 Exclude path regex is marked for manual confirmation
  - 🟩 Output summary is complete

✅ All passed, proceeding to output results.
```

### Output Results Example

**Review Results Example:**

```markdown
| Dimension | Result |
| --- | --- |
| Review File | src/common/middleware/auth.middleware.ts |
| Total Items | 6 items |
| Passed | 5 items |
| Issues Found | 1 item |
| Risk Level | 🟡 Medium |
| Suggestions Accepted | 1 suggestion |
```

## Review List

- **Content Check**
  - [ ] All review items reference NestJS official middleware documentation
  - [ ] Middleware type suggestions are marked as suggestions, not mandatory
- **Behavior Check**
  - [ ] Did not directly modify user code (unless explicitly requested by the user)
  - [ ] All interaction steps used AskUserQuestion
- **Validation Check**
  - [ ] Correctly terminated when target code is empty or unreadable
  - [ ] Exclude path regex is marked as requiring manual confirmation
  - [ ] Output summary includes file path, number of items, issues found, and risk level

## References

- [NestJS Middleware Official Documentation](https://docs.nestjs.com/middleware)
- [skill-evolve 模板](../../skill-evolve/template.md)
