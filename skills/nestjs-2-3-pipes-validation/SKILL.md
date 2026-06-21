---
name: nestjs-2-3-pipes-validation
description: Review NestJS data validation and transformation pipe implementation, covering best practices for built-in pipes, custom pipes, and global pipe registration. Use when users need to review input validation logic or develop DTO validation.
---

# NestJS Data Validation and Transformation Pipes

## Overview

When AI encounters pipe-related code in a NestJS project, it automatically performs the following: review the pipe registration method and scope, check the standard conformance of class-validator / class-transformer decorator usage, evaluate the implementation quality of custom pipes, identify common validation omissions, and provide improvement suggestions.

## Definitions

- <a id="target-code"></a>**Target Code**: The NestJS pipe implementation code, DTO definitions, or controller parameter validation code in the current conversation.
- <a id="built-in-pipes"></a>**Built-in Pipes**: Out-of-the-box pipes provided by NestJS such as ValidationPipe, ParseIntPipe, ParseUUIDPipe, ParseBoolPipe, DefaultValuePipe, etc.
- <a id="dto"></a>**DTO**: Data Transfer Object, a data validation rules class defined using class-validator and class-transformer decorators.
- <a id="analysis-complete"></a>**Analysis Complete**: Indicates whether the analysis of the target code has yielded a complete result.

## Prerequisites

- NestJS project environment;
- Code files containing pipes, DTOs, or parameter validation are accessible;
- Understanding of the basic usage of class-validator and class-transformer.

## Workflow

0. **Pre-check** — Ensure the target code and runtime environment are reachable;
   - Determine if the target code exists and is readable:
     - Yes -> next step;
     - No -> prompt the user to provide the target code or file path, block and wait for user input;
   - Initialize global variable [Analysis Complete](#analysis-complete):
     - Determine if the code is complete and parseable:
       - Satisfied -> initialize variable to true;
       - Not satisfied -> initialize variable to false;

1. **Analyze pipe and validation code** — Read and understand the validation logic and data transformation flow;
   - Read the target code, identify the following core elements:
     - Pipe registration method (global / controller / parameter-level);
     - class-validator decorators used in DTO classes (@IsString, @IsInt, @ValidateNested, etc.);
     - Custom pipe implementation (implementing PipeTransform interface);
     - ValidationPipe configuration options (whitelist, transform, forbidNonWhitelisted, etc.);

2. **Item-by-item review** — Check pipe and validation code quality against the review checklist;
   - Sequentially evaluate whether each review item passes:
     - Are necessary validation decorators missing on DTO properties (such as @IsOptional, @IsEmail, etc.):
       - Pass -> record as passed, continue to the next review item;
       - Fail -> record "Missing necessary validation decorators, recommend adding them based on business requirements", continue;
     - Is the whitelist option of ValidationPipe enabled (to automatically filter un-decorated properties):
       - Pass -> record as passed, continue to the next review item;
       - Fail -> record "Recommend enabling whitelist: true to prevent unexpected field injection", continue;
     - Is the transform option of ValidationPipe enabled (for automatic type conversion):
       - Pass -> record as passed, continue to the next review item;
       - Fail -> record "Recommend enabling transform: true to automatically perform type conversion", continue;
     - Does the nested DTO use the @ValidateNested decorator:
       - Pass -> record as passed, continue to the next review item;
       - Fail -> record "Nested objects require @ValidateNested() and @Type() for recursive validation", continue;
     - Does the transform() method in custom pipes return the correct type:
       - Pass -> record as passed, continue to the next review item;
       - Fail -> record "The return type of transform() is inconsistent with its declaration, may cause runtime type errors", continue;
     - Is the global ValidationPipe properly registered in main.ts:
       - Pass -> record as passed, continue to the next review item;
       - Fail -> record "Global ValidationPipe is recommended to use app.useGlobalPipes() in main.ts", continue;
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
  - Review items must reference NestJS official documentation on pipes and validation;
  - SKILL.md must not exceed 300 lines; split into references/ directory when exceeded;
  - Reference depth must not exceed one level;
  - Maintain terminology consistency, terms defined in Definitions must be referenced via anchor links in the body;
  - Remove any time-sensitive information;

- **Behavior Standards**
  - During review, only output issue summaries and locations, do not directly modify code unless the user explicitly requests it via AskUserQuestion;
  - All interaction steps involving code modification must use the AskUserQuestion tool;
  - ValidationPipe configuration suggestions (whitelist, transform) should be marked as recommendations, not mandatory;

- **Defensive Standards**
  - If the target code is empty or unreadable, report directly and terminate;
  - class-validator decorator omissions should only be reported when the DTO type is clear; when uncertain, mark as requiring manual confirmation;

- **Validation Standards**
  - Examples content must be self-consistent with Rules;
  - Examples must include a review check example;
  - Dialogue interaction examples should only focus on steps 0~3 (excluding review check and output results);

## Examples

### Dialogue Interaction Example

**Example: User requests DTO validation configuration review**

```markdown
User > Please check the validation configuration for this CreateUserDto
AI   > Detected user needs NestJS pipe and validation review, triggering nestjs-2-3-pipes-validation skill
AI   > Analyzing DTO code...

Review Results:
- 🟩 Core fields use @IsString, @IsEmail and other decorators
- 🟥 Missing whitelist: true configuration, un-decorated properties will be retained
- 🟩 transform: true is enabled, types will be auto-converted
- 🟥 Nested ProfileDto does not use @ValidateNested() and @Type()
- 🟩 Global ValidationPipe is registered in main.ts

Summary: 2 issues need attention
User > Please add whitelist and nested validation
AI   > Fix plan generated. Would you like to apply it?
User > Accept all
```

### Review Check Example

```markdown
AI > Entering review check, Review List contains 6 items, starting item-by-item verification:

**Content Check**
  - 🟩 All review items reference official pipe documentation
  - 🟩 ValidationPipe configuration is marked as recommendation

**Behavior Check**
  - 🟩 Did not directly modify user code
  - 🟩 Used AskUserQuestion

**Validation Check**
  - 🟩 DTO decorator omissions reported only when type is clear
  - 🟩 Output summary is complete

✅ All passed, proceeding to output results.
```

### Output Results Example

**Review Results Example:**

```markdown
| Dimension | Result |
| --- | --- |
| Review File | src/user/dto/create-user.dto.ts |
| Total Items | 8 items |
| Passed | 6 items |
| Issues Found | 2 items |
| Risk Level | 🟡 Medium |
| Suggestions Accepted | 2 suggestions |
```

## Review List

- **Content Check**
  - [ ] All review items reference NestJS official pipe and validation documentation
  - [ ] ValidationPipe configuration is marked as recommended, not mandatory
- **Behavior Check**
  - [ ] Did not directly modify user code (unless explicitly requested by the user)
  - [ ] All interaction steps used AskUserQuestion
- **Validation Check**
  - [ ] Correctly terminated when target code is empty or unreadable
  - [ ] DTO decorator omissions reported only when the type is clear
  - [ ] Output summary includes file path, number of items, issues found, and risk level

## References

- [NestJS Pipes Official Documentation](https://docs.nestjs.com/pipes)
- [NestJS ValidationPipe](https://docs.nestjs.com/techniques/validation)
- [class-validator Documentation](https://github.com/typestack/class-validator)
- [skill-evolve 模板](../../skill-evolve/template.md)
