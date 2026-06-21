---
name: nestjs-1-2-routing-controllers
description: Review NestJS routing and controller design quality, check route decorator usage, parameter binding, and RESTful style consistency. Use when users need to review or develop Controller layer code.
---

# NestJS Routing and Controller Design

## Overview

When AI encounters Controller-related code in a NestJS project, it automatically performs the following: review the correctness of route decorator usage, check the accuracy of parameter binding, evaluate the consistency of RESTful API design style, and provide improvement suggestions.

## Definitions

- <a id="target-code"></a>**Target Code**: The NestJS Controller class code or file path in the current conversation.
- <a id="route-decorator"></a>**Route Decorator**: HTTP method decorators such as @Controller, @Get, @Post, @Put, @Delete, @Patch, @All.
- <a id="parameter-decorator"></a>**Parameter Decorator**: Request parameter extraction decorators such as @Param, @Query, @Body, @Headers, @Req, @Res.
- <a id="analysis-complete"></a>**Analysis Complete**: Indicates whether the analysis of the target code has yielded complete results.

## Prerequisites

- NestJS project environment;
- Controller code file or code snippet accessible;
- Basic understanding of HTTP routing and RESTful API design concepts.

## Workflow

0. **Pre-check** — Ensure the target code and runtime environment are accessible;
   - Determine if the target code exists and is readable:
     - Yes -> next step;
     - No -> prompt the user to provide target code or file path, block and wait for user input;
   - Initialize global variable [Analysis Complete](#analysis-complete):
     - Determine if the code is complete and parseable:
       - Satisfied -> initialize variable to true;
       - Not satisfied -> initialize variable to false;

1. **Analyze Controller Code** — Read and understand the structure and intent of routes and controllers;
   - Read the target Controller code;
   - Identify the following core elements:
     - @Controller prefix path;
     - Each route handler method and its HTTP method decorator;
     - Request data sources bound via parameter decorators;
     - Response handling approach (implicit return vs @Res injection);

2. **Itemized Review** — Check route controller code quality against the review checklist;
   - Determine whether each of the following review items passes:
     - Whether the @Controller prefix path uses semantic naming (e.g., /users rather than /api):
       - Pass -> record as pass, continue to next review item;
       - Fail -> record "Consider using a semantic path prefix instead of a generic prefix", continue;
     - Whether the HTTP method decorator matches the operation semantics (GET for queries, POST for creation, PUT for full update, PATCH for partial update, DELETE for deletion):
       - Pass -> record as pass, continue to next review item;
       - Fail -> record "HTTP method semantics do not match the operation", continue;
     - Whether route path parameters have corresponding @Param extraction:
       - Pass -> record as pass, continue to next review item;
       - Fail -> record "Route parameters not explicitly extracted via @Param", continue;
     - Whether POST/PUT request bodies explicitly declare DTO types via @Body:
       - Pass -> record as pass, continue to next review item;
       - Fail -> record "Request body does not use DTO type declaration", continue;
     - Whether @Res() is mixed with implicit return (which may cause response sending conflicts):
       - Pass -> record as pass, continue to next review item;
       - Fail -> record "Mixing @Res and implicit return may cause response conflicts", continue;
     - Whether RESTful endpoint names are plural and consistent (e.g., /users/:id rather than /user/:id):
       - Pass -> record as pass, continue to next review item;
       - Fail -> record "Endpoint naming does not follow RESTful plural convention", continue;
   - Determine if there are any issues recorded:
     - Yes -> summarize the issue list, proceed to next step;
     - No -> directly proceed to step 4 (Review Check);

3. **Provide Modification Suggestions** — Give specific fix solutions for identified issues;
   - For each issue, provide fix suggestions with positive and negative comparison examples;
   - Provide options via AskUserQuestion, block and wait for user selection:
     - Accept all suggestions -> generate corrected code, proceed to step 4;
     - Confirm one by one -> user decides to accept or ignore each item, proceed to step 4 after all confirmed;
     - Review only without modification -> do not affect code, directly proceed to step 4;

4. **Review Check** — Verify execution results against the [Review List](#review-list);
   - Determine if Review List has content:
     - No -> directly proceed to next step (Results Output);
     - Yes -> next step;
   - Check each item in [Review List](#review-list) sequentially to see if it passes:
     - Display output content based on the "Review Check Example";
   - If any check fails, terminate the flow;
   - After all pass, proceed to next step;

5. **Results Output** — Output the review summary and notify completion;
   - Output a structured summary table (Reviewed File / Total Review Items / Passed / Issues Found / Risk Level / Suggestions Accepted);
   - Notify that the review is complete;

## Rules

- **Content Standards**
  - description must follow the format: first sentence states what is reviewed, second sentence states trigger condition ("Use when users need to..."), use third person, no more than 1024 characters;
  - Review items must reference NestJS official documentation or RESTful design standards;
  - SKILL.md must not exceed 300 lines; split into references/ directory when exceeded;
  - Reference depth must not exceed one level;
  - Maintain consistent terminology; terms defined in Definitions must be referenced via anchor links in the body;
  - Remove any time-sensitive information;

- **Behavior Standards**
  - During review, only output issue summaries and locations; do not directly modify code unless the user explicitly requests it via AskUserQuestion;
  - All interaction steps involving code modification must use the AskUserQuestion tool;
  - Anti-pattern judgments must provide positive and negative comparison explanations;

- **Defensive Standards**
  - If the target code is empty or unreadable, directly report and terminate;
  - HTTP method recommendations should be labeled as suggestions rather than requirements;

- **Validation Standards**
  - Examples content must be consistent with Rules;
  - Examples must include a review check example;
  - Conversation interaction examples should only focus on steps 0~3 (excluding review check and results output);

## Examples

### Conversation Interaction Example

**Example: User requests Controller code review**

```markdown
User > Could you review this Controller code?
AI   > Detected that user needs NestJS routing controller review, triggering nestjs-1-2-routing-controllers skill
AI   > Analyzing Controller code...

Review Results:
- 🟩 @Controller('/users') path has good semantic naming
- 🟥 getUser method uses @Post, but the operation is a query (suggest changing to @Get)
- 🟩 createUser method uses @Body with CreateUserDto type declaration
- 🟥 findUser uses @Res injection while also returning an object, risk of response sending conflict
- 🟩 Endpoint names consistently use plural form

Summary: 2 issues need attention. Would you like to fix them?
User > Please fix them for me
AI   > Would you like to accept all suggestions?
User > Let me confirm one by one
(One-by-one confirmation process...)
```

### Review Check Example

```markdown
AI > Entering review check. Review List contains 5 items, starting verification:

**Content Check**
  - 🟩 All review items reference official standards
  - 🟩 RESTful conventions labeled as suggestions, not requirements

**Behavior Check**
  - 🟩 Did not directly modify user code
  - 🟩 Used AskUserQuestion for interactions

**Validation Check**
  - 🟩 Target code readability is normal

✅ All passed, proceeding to results output.
```

### Results Output Example

**Review Results Example:**

```markdown
| Dimension | Result |
| --- | --- |
| Reviewed File | src/users/users.controller.ts |
| Total Review Items | 8 |
| Passed | 6 |
| Issues Found | 2 |
| Risk Level | 🟡 Medium |
| Suggestions Accepted | 2 |
```

## Review List

- **Content Check**
  - [ ] All review items reference NestJS official standards or RESTful design standards
  - [ ] HTTP method recommendations labeled as suggestions, not requirements
- **Behavior Check**
  - [ ] Did not directly modify user code (unless explicitly requested by user)
  - [ ] All interaction steps used AskUserQuestion
- **Validation Check**
  - [ ] Correctly terminated when target code is empty or unreadable
  - [ ] Output summary includes file path, review item count, issues found, and risk level

## References

- [NestJS Controllers Official Documentation](https://docs.nestjs.com/controllers)
- [NestJS Route Parameters and Request Handling](https://docs.nestjs.com/controllers#request-object)
- [skill-evolve template](../../skill-evolve/template.md)
