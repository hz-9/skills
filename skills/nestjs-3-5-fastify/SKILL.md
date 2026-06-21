---
name: nestjs-3-5-fastify
description: Review NestJS Fastify platform adaptation and migration, covering platform replacement, middleware compatibility, and performance difference handling. Use when users need to review Fastify integration or migrate from Express.
---

# NestJS Server Model Migration (Fastify)

## Overview

When AI encounters Fastify platform related code in a NestJS project, it automatically performs the following: review the FastifyAdapter configuration and platform adaptation, check Express-specific API compatibility handling, evaluate performance optimization configurations, identify common migration issues, and provide improvement suggestions.

## Definitions

- <a id="target-code"></a>**Target code**: The NestJS Fastify adapter configuration, platform-related code, or migration configuration code in the current conversation.
- <a id="FastifyAdapter"></a>**FastifyAdapter**: NestJS's Fastify platform adapter for replacing the default Express, injected during NestFactory.create.
- <a id="platform-differences"></a>**Platform differences**: Differences between Express and Fastify in middleware format, request/response objects, file upload, serialization, etc.
- <a id="analysis-complete"></a>**Analysis complete**: Indicates whether the analysis of the target code has been fully completed.

## Prerequisites

- NestJS project environment (including @nestjs/platform-fastify dependency);
- Fastify adapter configuration or related code accessible;
- Understanding of basic differences between Express and Fastify.

## Workflow

0. **Pre-check** — Ensure the target code and runtime environment are reachable;
   - Determine if the target code exists and is readable:
     - Yes -> next step;
     - No -> prompt the user to provide the target code or file path, block and wait for user input;
   - Initialize global variable [analysis complete](#analysis-complete):
     - Determine if the code is fully parseable:
       - Satisfied -> initialize variable to true;
       - Not satisfied -> initialize variable to false;

1. **Analyze Fastify code** — Read and understand platform adaptation and configuration;
   - Read the target code, identify the following core elements:
     - FastifyAdapter creation and configuration (passed during NestFactory.create);
     - Fastify-specific configuration options (bodyLimit, maxParamLength, etc.);
     - Whether the middleware in use depends on Express-specific APIs (req, res);
     - File upload handling approach (fastify-multipart vs multer);
     - Serialization configuration (Fastify schema serializer);

2. **Review items** — Check Fastify adapter code quality against the review checklist;
   - Iterate through the following review items to determine if they pass:
     - Whether @nestjs/platform-fastify and its corresponding packages are used (replacing @nestjs/platform-express):
       - Pass -> record as passed, continue to next review item;
       - Fail -> record "Fastify platform requires installing @nestjs/platform-fastify", continue;
     - Whether the middleware used in the project has been checked for Fastify compatibility (Fastify middleware interface differs from Express):
       - Pass -> record as passed, continue to next review item;
       - Fail -> record "Some middleware depends on Express API, check Fastify compatibility", continue;
     - Whether file upload has been migrated to fastify-multipart (multer is not available under Fastify):
       - Pass -> record as passed, continue to next review item;
       - Fail -> record "File upload under Fastify requires using fastify-multipart instead of multer", continue;
     - Whether Fastify's bodyLimit is configured and reasonable (to avoid inappropriate request body size limits):
       - Pass -> record as passed, continue to next review item;
       - Fail -> record "Recommend configuring bodyLimit to control request body size", continue;
     - Whether differences in response serialization between Fastify and Express are handled (e.g., Fastify does not transform objects by default):
       - Pass -> record as passed, continue to next review item;
       - Fail -> record "Fastify and Express have different serialization behavior, requires explicit configuration", continue;
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
  - Review items must reference NestJS official Fastify adapter documentation;
  - SKILL.md no more than 300 lines; split to references/ directory when exceeded;
  - Reference hierarchy no more than one level;
  - Maintain terminology consistency, terms defined in Definitions must be referenced via anchor links in the body;
  - Remove any time-sensitive information;

- **Behavior rules**
  - Only output issue summaries and locations during review, do not directly modify code unless the user explicitly requests via AskUserQuestion;
  - All interaction steps involving code modification must use the AskUserQuestion tool;
  - Fastify migration recommendations (Express to Fastify) should be labeled as performance optimization suggestions, not mandatory migration requirements;

- **Defensive rules**
  - If target code is empty or unreadable, report directly and terminate;
  - Middleware compatibility should only be reported when identifiable as Express-specific API, do not trigger warnings for generic middleware;

- **Validation rules**
  - Examples content must be self-consistent with Rules;
  - Examples must include a review check example;
  - Dialogue interaction examples should only focus on steps 0~3 (excluding review check and output);

## Examples

### Dialogue Interaction Example

**Example: User requests Fastify migration review**

```markdown
User > Help me check if there is Express-specific code blocking Fastify migration
AI   > Detected user needs NestJS Fastify review, triggered nestjs-3-5-fastify skill
AI   > Analyzing project code...

Review Results:
- 🟩 @nestjs/platform-fastify is installed
- 🟥 helmet middleware uses Express-specific API, needs replacement
- 🟩 bodyLimit configured at 1MB, reasonable
- 🟥 File upload uses @UseInterceptors(FileInterceptor) (multer, not compatible with Fastify)
- 🟩 No serialization difference issues found

Summary: 2 issues need attention
User > Help me fix the compatibility issues
AI   > helmet needs to be replaced with @fastify/helmet, file upload needs to use fastify-multipart instead. Apply?
User > Accept all
```

### Review Check Example

```markdown
AI > Entering review check, Review List contains 5 items, starting verification:

**Content Check**
  - 🟩 All review items reference official documentation
  - 🟩 Migration suggestions labeled as performance optimization

**Behavior Check**
  - 🟩 Did not directly modify user code
  - 🟩 Used AskUserQuestion

**Validation Check**
  - 🟩 Middleware reported when Express-specific
  - 🟩 Output summary is complete

✅ All passed, proceeding to output.
```

### Output Example

**Review Result Example:**

```markdown
| Dimension | Result |
| --- | --- |
| Reviewed File | src/main.ts, src/common/middleware/ |
| Total Review Items | 6 items |
| Passed | 4 items |
| Issues Found | 2 items |
| Risk Level | 🟡 Medium |
| Suggestions Adopted | 2 items |
```

## Review List

- **Content Check**
  - [ ] All review items reference NestJS official Fastify adapter documentation
  - [ ] Migration suggestions labeled as performance optimization, not mandatory
- **Behavior Check**
  - [ ] Did not directly modify user code (unless explicitly requested by the user)
  - [ ] All interaction steps used AskUserQuestion
- **Validation Check**
  - [ ] Correctly terminated when target code is empty or unreadable
  - [ ] Middleware compatibility only reported when Express-specific API
  - [ ] Output summary includes file path, number of review items, issues found, and risk level

## References

- [NestJS Fastify Adapter Official Documentation](https://docs.nestjs.com/techniques/performance)
- [Fastify Official Documentation](https://www.fastify.io/)
- [skill-evolve Template](../../skill-evolve/template.md)
