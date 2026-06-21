---
name: nestjs-7-2-scopes-circular-deps
description: Review NestJS injection scope and circular dependency configuration and management, covering REQUEST/TRANSIENT scopes and forwardRef usage. Use this when users need to troubleshoot injection scope issues or circular dependencies.
---

# NestJS Scopes & Circular Dependencies

## Overview

When AI encounters injection scope or circular dependency-related code in a NestJS project, it automatically performs the following: review whether scope configuration is reasonable, check for circular dependencies and provide forwardRef solutions, evaluate the performance impact of scopes, and provide improvement suggestions.

## Definitions

- <a id="target-code"></a>**Target Code**: The @Injectable scope configuration or module/service code with circular dependencies from the NestJS project in the current conversation.
- <a id="injection-scope"></a>**Injection Scope**: The scope types provided by NestJS — DEFAULT (singleton), REQUEST (request-scoped), TRANSIENT (injection-scoped).
- <a id="forwardref"></a>**forwardRef**: A helper function for resolving circular dependencies, allowing references to each other before dependencies are fully established.
- <a id="analysis-complete"></a>**Analysis Complete**: A flag indicating whether the analysis of the target code has reached a complete result.

## Prerequisites

- NestJS project environment;
- Code files involving scopes or circular dependencies accessible;
- Understanding of DI mechanism and module loading order basics.

## Workflow

0. **Pre-check** — Ensure target code and runtime environment are reachable;
   - Determine if target code exists and is readable:
     - Yes -> Next step;
     - No -> Prompt user to provide target code or file path, block and wait for user input;
   - Initialize global variable [Analysis Complete](#analysis-complete):
     - Determine if the code is fully parsable:
       - Satisfied -> Initialize variable to true;
       - Not satisfied -> Initialize variable to false;

1. **Analyze code** — Read and understand scope configuration and dependency relationships;
   - Read target code, identify the following core elements:
     - Scope configuration on @Injectable or @Controller;
     - Whether the import chain between modules has circular references;
     - Whether constructor injection between services has mutual references;

2. **Item-by-item review** — Check scope and circular dependency issues;
   - Determine whether each review item passes in sequence:
     - Is REQUEST scope used unnecessarily (DEFAULT SINGLETON should be preferred):
       - Pass -> Record as pass, continue to next item;
       - Fail -> Record "REQUEST scope creates new instances per request, may impact performance", continue;
     - Are circular dependencies resolved using forwardRef:
       - Pass -> Record as pass, continue to next item;
       - Fail -> Record "Detected circular dependency missing forwardRef, recommend adding", continue;
     - Does TRANSIENT scope usage truly require creating new instances on every injection:
       - Pass -> Record as pass, continue to next item;
       - Fail -> Record "TRANSIENT scope may create excessive instances, please confirm necessity", continue;
   - Determine if there are any issue records:
     - Yes -> Compile issue list, proceed to next step;
     - No -> Proceed directly to step 4 (Review Check);

3. **Provide modification suggestions** — Give specific remediation plans for discovered issues;
   - Provide remediation suggestions for each issue sequentially;
   - Present options via AskUserQuestion, block and wait for user selection:
     - Accept all suggestions -> Generate corrected code, proceed to step 4;
     - Confirm one by one -> User decides to accept or ignore each item, proceed to step 4 after all confirmed;
     - View only, no modification -> Do not affect code, proceed directly to step 4;

4. **Review check** — Verify execution results against the [Review List](#review-list);
   - Determine if the Review List has content:
     - No -> Proceed directly to next step (Output);
     - Yes -> Next step;
   - Determine if each check item in the [Review List](#review-list) passes in sequence:
     - Display output based on the "Review Check Example";
   - Terminate the process if any check fails;
   - Proceed to next step after all pass;

5. **Output results** — Output review summary, notify completion;
   - Output a structured summary table (reviewed file / number of review items / passed / issues found / risk level / suggestions adopted);
   - Notify that the review is complete;

## Rules

- **Content Standards**
  - description must follow the format: use third person, no more than 1024 characters;
  - SKILL.md must not exceed 300 lines; reference hierarchy must not exceed one level;
  - Remove any time-sensitive information;
- **Behavior Standards**
  - During review, only output issue summaries, do not directly modify code;
  - All interaction steps must use AskUserQuestion tool;
  - Scope optimization should be marked as performance suggestion rather than defect;
- **Defense Standards**
  - If the target code is empty or unreadable, report directly and terminate;
  - Circular dependencies should only be reported when import relationships are visible;
- **Verification Standards**
  - Examples must include a review check example;
  - Conversation interaction examples should only focus on steps 0~3;

## Examples

### Conversation Interaction Example

**Example: User requests circular dependency review**

```markdown
User > My AuthModule and UserModule depend on each other, help me check
AI   > Detected issue, triggering nestjs-7-2-scopes-circular-deps skill
AI   > Analysis found AuthModule and UserModule have circular reference...
AI   > Recommend using forwardRef(() => UserModule) and forwardRef(() => AuthModule). Apply changes?
User > Yes
```

### Review Check Example

```markdown
AI > Entering review check, Review List has 4 check items, beginning verification:

**Content Check**
  - 🟩 Review items reference official documentation
  - 🟩 Scope suggestions marked as performance advice

**Behavior Check**
  - 🟩 Used AskUserQuestion

**Verification Check**
  - 🟩 Circular dependencies reported when visible
  - 🟩 Output summary is complete
✅ All passed.
```

### Output Example

```markdown
| Dimension | Result |
| --- | --- |
| Reviewed File | src/auth/auth.module.ts |
| Total Review Items | 5 |
| Passed | 3 |
| Issues Found | 2 |
| Risk Level | 🟡 Medium |
| Suggestions Adopted | 2 |
```

## Review List

- **Content Check**
  - [ ] Review items reference NestJS official scope and circular dependency documentation
  - [ ] Scope optimization marked as performance suggestion
- **Behavior Check**
  - [ ] All interaction steps used AskUserQuestion
- **Verification Check**
  - [ ] Circular dependencies only reported when imports are visible
  - [ ] Output summary includes file path and review results

## References

- [NestJS Injection Scopes Documentation](https://docs.nestjs.com/fundamentals/injection-scopes)
- [NestJS Circular Dependency](https://docs.nestjs.com/fundamentals/circular-dependency)
- [skill-evolve Template](../../skill-evolve/template.md)
