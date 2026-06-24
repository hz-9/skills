---
name: nestjs-1-3-dependency-injection
description: Review NestJS dependency injection system usage, covering @Injectable, custom providers, factory patterns, and injection scope control. Use when users need to review dependency injection configuration or troubleshoot injection issues.
---

# NestJS Dependency Injection and Providers

## Overview

When AI encounters dependency injection-related code in a NestJS project, it automatically performs the following: review the correctness of @Injectable decorator usage, check the accuracy of custom provider configuration, evaluate whether injection scope selection is reasonable, and identify common injection anti-patterns.

## Definitions

- <a id="target-code"></a>**Target Code**: The NestJS Provider, Service, or factory function code or file path in the current conversation.
- <a id="provider-classification"></a>**Provider Classification**: Provider types supported by NestJS, including useValue (value provider), useClass (class provider), useFactory (factory provider), and useExisting (alias provider).
- <a id="injection-scope"></a>**Injection Scope**: NestJS's three scopes — DEFAULT (singleton), REQUEST (new instance per request), and TRANSIENT (new instance per injection).
- <a id="analysis-complete"></a>**Analysis Complete**: Indicates whether the analysis of the target code has yielded complete results.

## Prerequisites

- NestJS project environment;
- Code files containing Provider declarations or injections accessible;
- Basic understanding of dependency injection concepts (constructor injection, property injection).

## Workflow

0. **Pre-check** — Ensure the target code and runtime environment are accessible;
   - Determine if the target code exists and is readable:
     - Yes -> next step;
     - No -> prompt the user to provide target code or file path, block and wait for user input;
   - Initialize global variable [Analysis Complete](#analysis-complete):
     - Determine if the code is complete and parseable:
       - Satisfied -> initialize variable to true;
       - Not satisfied -> initialize variable to false;

1. **Analyze Dependency Injection Code** — Read and understand providers and injection relationships;
   - Read the target code, identify the following core elements:
     - Usage locations of the @Injectable() decorator;
     - Dependency injection parameters in the constructor;
     - Configuration of the providers array in @Module;
     - Types of custom providers (useValue / useClass / useFactory / useExisting);
     - Injection scope settings (@Injectable({ scope: Scope.REQUEST }), etc.);

2. **Itemized Review** — Check dependency injection code quality against the review checklist;
   - Determine whether each of the following review items passes:
     - Whether @Injectable() is present on all classes that require injection (non-Controller provider classes):
       - Pass -> record as pass, continue to next review item;
       - Fail -> record "Missing @Injectable() decorator; class cannot be recognized by the injection system", continue;
     - Whether custom useFactory has a corresponding inject dependency array:
       - Pass -> record as pass, continue to next review item;
       - Fail -> record "useFactory lacks inject array; dependencies cannot be properly injected", continue;
     - Whether the injection scope is reasonable (avoid unnecessary use of REQUEST scope causing performance degradation):
       - Pass -> record as pass, continue to next review item;
       - Fail -> record "REQUEST scope may cause performance issues; confirm whether a new instance is needed per request", continue;
     - Whether circular dependencies exist (A injects B, B injects A):
       - Pass -> record as pass, continue to next review item;
       - Fail -> record "Circular dependency detected; consider using forwardRef() to resolve", continue;
     - Whether Provider tokens use string constants instead of Symbol or class names (prone to conflicts):
       - Pass -> record as pass, continue to next review item;
       - Fail -> record "Consider using class names or Symbol as Provider tokens instead of strings", continue;
     - Whether async initialization logic is properly handled in async providers:
       - Pass -> record as pass, continue to next review item;
       - Fail -> record "Async providers must return a Promise to ensure initialization completes before injection", continue;
   - Determine if there are any issues recorded:
     - Yes -> summarize the issue list, proceed to next step;
     - No -> directly proceed to step 4 (Review Check);

3. **Provide Modification Suggestions** — Give specific fix solutions for identified issues;
   - For each issue, provide fix suggestions with comparisons of incorrect and correct usage;
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
  - description must follow the format: first sentence states what is reviewed, second sentence states trigger condition, use third person, no more than 1024 characters;
  - Review items must reference NestJS official documentation on DI standards;
  - SKILL.md must not exceed 300 lines; split into references/ directory when exceeded;
  - Reference depth must not exceed one level;
  - Maintain consistent terminology; terms defined in Definitions must be referenced via anchor links in the body;
  - Remove any time-sensitive information;

- **Behavior Standards**
  - During review, only output issue summaries and locations; do not directly modify code unless the user explicitly requests it via AskUserQuestion;
  - All interaction steps involving code modification must use the AskUserQuestion tool;
  - Scope recommendations should be labeled as suggestions rather than requirements, with performance impact explanations;

- **Defensive Standards**
  - If the target code is empty or unreadable, directly report and terminate;
  - Circular dependency detection should be based only on visible import relationships; mark as requiring manual confirmation when cross-file analysis is not possible;

- **Validation Standards**
  - Examples content must be consistent with Rules;
  - Examples must include a review check example;
  - Conversation interaction examples should only focus on steps 0~3 (excluding review check and results output);

## Examples

### Conversation Interaction Example

**Example: User requests dependency injection configuration review**

```markdown
User > Could you check the dependency injection configuration of this module?
AI   > Detected that user needs NestJS dependency injection review, triggering nestjs-1-3-dependency-injection skill
AI   > Analyzing DI configuration...

Review Results:
- 🟩 UserService has @Injectable() decorator
- 🟥 CustomProvider's useFactory lacks inject array
- 🟩 Default SINGLETON scope used, good performance
- 🟥 Circular dependency detected between AuthModule and UserModule
- 🟩 Provider token uses class name instead of string

Summary: 2 issues need attention
User > Please help fix the circular dependency issue
AI   > Suggest using forwardRef(() => UserModule) in AuthModule,
       and forwardRef(() => AuthModule) in UserModule.
       Would you like to apply this change?
User > Yes, please apply it
```

### Review Check Example

```markdown
AI > Entering review check. Review List contains 6 items, starting verification:

**Content Check**
  - 🟩 All review items reference official DI standards
  - 🟩 Scope recommendations labeled as suggestions with performance notes

**Behavior Check**
  - 🟩 Did not directly modify user code
  - 🟩 Used AskUserQuestion to confirm modifications

**Validation Check**
  - 🟩 Circular dependency marked as requiring manual confirmation
  - 🟩 Output summary is complete

✅ All passed, proceeding to results output.
```

### Results Output Example

**Review Results Example:**

```markdown
| Dimension | Result |
| --- | --- |
| Reviewed File | src/auth/auth.module.ts, src/user/user.module.ts |
| Total Review Items | 8 |
| Passed | 6 |
| Issues Found | 2 |
| Risk Level | 🔴 High |
| Suggestions Accepted | 1 |
| Ignored / Review Only | 1 |
```

## Review List

- **Content Check**
  - [ ] All review items reference NestJS official DI standards
  - [ ] Scope recommendations labeled as suggestions with performance impact notes
- **Behavior Check**
  - [ ] Did not directly modify user code (unless explicitly requested by user)
  - [ ] All interaction steps used AskUserQuestion
- **Validation Check**
  - [ ] Correctly terminated when target code is empty or unreadable
  - [ ] Circular dependency marked as requiring manual confirmation when cross-file analysis is not possible
  - [ ] Output summary includes file path, review item count, issues found, and risk level

## References

- [NestJS Providers Official Documentation](https://docs.nestjs.com/providers)
- [NestJS Custom Providers](https://docs.nestjs.com/fundamentals/custom-providers)
- [NestJS Injection Scopes](https://docs.nestjs.com/fundamentals/injection-scopes)
- [NestJS Circular Dependency](https://docs.nestjs.com/fundamentals/circular-dependency)
- [skill-evolve template](../../skill-evolve/template.md)
