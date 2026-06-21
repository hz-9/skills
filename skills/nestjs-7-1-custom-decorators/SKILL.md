---
name: nestjs-7-1-custom-decorators
description: Review NestJS custom decorator implementation, covering parameter decorators, method decorators, metadata reflection, and decorator composition. Use this when users need to review or develop custom decorators.
---

# NestJS Custom Decorators

## Overview

When AI encounters custom decorator-related code in a NestJS project, it automatically performs the following: review the usage of createParamDecorator, check the cooperation between custom decorators and metadata reflection (Reflector), evaluate the reasonableness of decorator composition, and provide improvement suggestions.

## Definitions

- <a id="target-code"></a>**Target Code**: The custom decorator implementation code or controller code using custom decorators from the NestJS project in the current conversation.
- <a id="parameter-decorator"></a>**Parameter Decorator**: A custom parameter decorator created using createParamDecorator, used to extract and transform specific data from requests.
- <a id="metadata-decorator"></a>**Metadata Decorator**: A custom decorator created using @SetMetadata or Reflector, used to set metadata on controllers or methods.
- <a id="analysis-complete"></a>**Analysis Complete**: A flag indicating whether the analysis of the target code has reached a complete result.

## Prerequisites

- NestJS project environment;
- Custom decorator code files accessible;
- Understanding of decorator patterns and reflect-metadata basics.

## Workflow

0. **Pre-check** — Ensure target code and runtime environment are reachable;
   - Determine if target code exists and is readable:
     - Yes -> Next step;
     - No -> Prompt user to provide target code or file path, block and wait for user input;
   - Initialize global variable [Analysis Complete](#analysis-complete):
     - Determine if the code is fully parsable:
       - Satisfied -> Initialize variable to true;
       - Not satisfied -> Initialize variable to false;

1. **Analyze decorator code** — Read and understand custom decorator implementation;
   - Read target code, identify the following core elements:
     - Decorator type (parameter decorator / method decorator / class decorator);
     - Factory function implementation of createParamDecorator;
     - Metadata reading logic in cooperation with Reflector;
     - Composition of multiple decorators;

2. **Item-by-item review** — Check decorator code quality against the review checklist;
   - Determine whether each review item passes in sequence:
     - Does the createParamDecorator factory function correctly handle data extraction logic:
       - Pass -> Record as pass, continue to next item;
       - Fail -> Record "Parameter decorator data processing logic is incomplete", continue;
     - Does the custom decorator use SetMetadata in conjunction with Reflector (metadata-driven):
       - Pass -> Record as pass, continue to next item;
       - Fail -> Record "Recommend using SetMetadata + Reflector for metadata-driven decorators", continue;
     - Does decorator composition maintain readability (avoiding excessive nesting that makes it hard to understand):
       - Pass -> Record as pass, continue to next item;
       - Fail -> Record "Decorator composition is overly complex, recommend simplifying or merging", continue;
     - Does the custom decorator have TypeScript type declarations (providing good IDE hints):
       - Pass -> Record as pass, continue to next item;
       - Fail -> Record "Custom decorator missing return type declaration", continue;
     - Does the decorator's data parameter provide a default value (fallback behavior when no argument is passed):
       - Pass -> Record as pass, continue to next item;
       - Fail -> Record "Decorator data parameter does not handle undefined case", continue;
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
  - description must follow the format: first sentence describes review content, second sentence describes trigger conditions, use third person, no more than 1024 characters;
  - Review items must reference NestJS official custom decorator documentation;
  - SKILL.md must not exceed 300 lines; split to references/ directory when exceeded;
  - Reference hierarchy must not exceed one level;
  - Maintain consistent terminology, terms defined in Definitions must be referenced via anchor links in the body;
  - Remove any time-sensitive information;

- **Behavior Standards**
  - During review, only output issue summaries and locations, do not directly modify code unless explicitly requested by the user via AskUserQuestion;
  - All code modification interaction steps must use the AskUserQuestion tool;
  - Decorator composition should be marked as a code style suggestion rather than mandatory;

- **Defense Standards**
  - If the target code is empty or unreadable, report directly and terminate;
  - Missing type declarations should only be reported when there is a clear interface context;

- **Verification Standards**
  - Examples content must be consistent with Rules;
  - Examples must include a review check example;
  - Conversation interaction examples should only focus on steps 0~3 (excluding review check and output);

## Examples

### Conversation Interaction Example

**Example: User requests custom decorator review**

```markdown
User > Help me check this @CurrentUser decorator
AI   > Detected user needs NestJS custom decorator review, triggering nestjs-7-1-custom-decorators skill
AI   > Analyzing decorator code...

Review Results:
- 🟩 createParamDecorator factory function correctly handles user data extraction
- 🟩 Uses @SetMetadata with reflector for role metadata
- 🟥 Multiple decorator composition leads to poor readability (4 levels of nesting)
- 🟩 Provides CurrentUser interface return type
- 🟥 data parameter does not provide default value

Summary: 2 issues need attention
User > Help me simplify the decorator composition
AI   > You can encapsulate common combinations into a composite decorator. Apply changes?
User > Yes
```

### Review Check Example

```markdown
AI > Entering review check, Review List has 5 check items, beginning verification:

**Content Check**
  - 🟩 All review items reference official documentation
  - 🟩 Composition method marked as style suggestion

**Behavior Check**
  - 🟩 Did not directly modify user code
  - 🟩 Used AskUserQuestion

**Verification Check**
  - 🟩 Type declarations reported when context is clear
  - 🟩 Output summary is complete

✅ All passed, proceeding to output.
```

### Output Example

**Review Results Example:**

```markdown
| Dimension | Result |
| --- | --- |
| Reviewed File | src/common/decorators/current-user.decorator.ts |
| Total Review Items | 6 |
| Passed | 4 |
| Issues Found | 2 |
| Risk Level | 🟢 Low |
| Suggestions Adopted | 1 |
| Ignored/Viewed Only | 1 |
```

## Review List

- **Content Check**
  - [ ] All review items reference NestJS official custom decorator documentation
  - [ ] Decorator composition method marked as style suggestion
- **Behavior Check**
  - [ ] Did not directly modify user code (unless explicitly requested by user)
  - [ ] All interaction steps used AskUserQuestion
- **Verification Check**
  - [ ] Correctly terminated when target code is empty or unreadable
  - [ ] Type declarations only reported when interface context is clear
  - [ ] Output summary includes file path, number of review items, issues found, and risk level

## References

- [NestJS Custom Decorators Documentation](https://docs.nestjs.com/custom-decorators)
- [TypeScript Decorators Reference](https://www.typescriptlang.org/docs/handbook/decorators.html)
- [skill-evolve Template](../../skill-evolve/template.md)
