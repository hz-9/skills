---
name: nestjs-5-4-observability
description: Review NestJS system observability implementation, covering logging, metrics collection, and distributed tracing best practices. Use this when users need to review observability configuration or troubleshoot monitoring issues.
---

# NestJS System Observability

## Overview

When AI encounters logging, monitoring, or tracing-related code in a NestJS project, it automatically performs the following: review logging strategies (built-in Logger vs third-party integration), check health check endpoint configuration, evaluate metrics collection and distributed tracing implementation, and provide improvement suggestions.

## Definitions

- <a id="target-code"></a>**Target Code**: The logging configuration, health check, or monitoring-related code from the NestJS project in the current conversation.
- <a id="health-check"></a>**Health Check**: A health check endpoint implemented via @nestjs/terminus for monitoring database, external services, and system resource status.
- <a id="logger"></a>**Logger**: NestJS's built-in Logger interface that can be custom-implemented or integrated with logging libraries such as Winston, Pino.
- <a id="analysis-complete"></a>**Analysis Complete**: A flag indicating whether the analysis of the target code has reached a complete result.

## Prerequisites

- NestJS project environment;
- Logging configuration, health check, or monitoring-related code accessible;
- Understanding of the three pillars of observability (logging, metrics, tracing).

## Workflow

0. **Pre-check** — Ensure target code and runtime environment are reachable;
   - Determine if target code exists and is readable:
     - Yes -> Next step;
     - No -> Prompt user to provide target code or file path, block and wait for user input;
   - Initialize global variable [Analysis Complete](#analysis-complete):
     - Determine if the code is fully parsable:
       - Satisfied -> Initialize variable to true;
       - Not satisfied -> Initialize variable to false;

1. **Analyze observability code** — Read and understand logging, monitoring, and tracing implementation;
   - Read target code, identify the following core elements:
     - Logger usage (built-in console.log vs custom Logger service);
     - Whether third-party logging libraries are integrated (Winston, Pino, etc.);
     - Health check endpoint configuration (TerminusModule.forRoot);
     - Request logging interceptor (recording request method, path, response time);

2. **Item-by-item review** — Check observability code quality against the review checklist;
   - Determine whether each review item passes in sequence:
     - Does the code use NestJS's Logger interface rather than direct console.log (for easier replacement and unified management):
       - Pass -> Record as pass, continue to next item;
       - Fail -> Record "Using console.log for logging, recommend replacing with Logger interface", continue;
     - Is log level configured for production environments (avoiding debug logs leaking to production):
       - Pass -> Record as pass, continue to next item;
       - Fail -> Record "Missing log level control, production environment may output excessive debug logs", continue;
     - Is a health check endpoint configured (monitoring critical dependency status via @nestjs/terminus):
       - Pass -> Record as pass, continue to next item;
       - Fail -> Record "Missing health check endpoint, recommend adding @nestjs/terminus", continue;
     - Does the request logging interceptor record key information (request method, path, status code, response time):
       - Pass -> Record as pass, continue to next item;
       - Fail -> Record "Request logging missing key metrics like response time, recommend adding interceptor", continue;
     - Are logs structured (JSON format) rather than free text (for easier parsing by log aggregation systems):
       - Pass -> Record as pass, continue to next item;
       - Fail -> Record "Recommend using JSON format for logging to facilitate log system parsing", continue;
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
  - Review items must reference NestJS official documentation and logging best practices;
  - SKILL.md must not exceed 300 lines; split to references/ directory when exceeded;
  - Reference hierarchy must not exceed one level;
  - Maintain consistent terminology, terms defined in Definitions must be referenced via anchor links in the body;
  - Remove any time-sensitive information;

- **Behavior Standards**
  - During review, only output issue summaries and locations, do not directly modify code unless explicitly requested by the user via AskUserQuestion;
  - All code modification interaction steps must use the AskUserQuestion tool;
  - Third-party logging library selection (Winston / Pino) should be marked as a technical choice rather than a defect;

- **Defense Standards**
  - If the target code is empty or unreadable, report directly and terminate;
  - Log level control suggestions should only be provided when conditional checks or configuration exists, not mandated without baseline configuration;

- **Verification Standards**
  - Examples content must be consistent with Rules;
  - Examples must include a review check example;
  - Conversation interaction examples should only focus on steps 0~3 (excluding review check and output);

## Examples

### Conversation Interaction Example

**Example: User requests observability configuration review**

```markdown
User > Help me check the project's logging and monitoring configuration
AI   > Detected user needs NestJS observability review, triggering nestjs-5-4-observability skill
AI   > Analyzing logging and monitoring code...

Review Results:
- 🟥 Using console.log directly in controllers, recommend using Logger interface
- 🟥 No log level configured for production environment
- 🟩 @nestjs/terminus health check configured
- 🟥 Missing request logging interceptor (response time metrics, etc.)
- 🟩 Logs use JSON format for structured output

Summary: 3 issues need attention
User > Help me add Logger and request logging interceptor
AI   > Created LoggerService to replace console.log, added LoggingInterceptor. Apply changes?
User > Accept all
```

### Review Check Example

```markdown
AI > Entering review check, Review List has 5 check items, beginning verification:

**Content Check**
  - 🟩 All review items reference official documentation
  - 🟩 Logging library selection marked as technical choice

**Behavior Check**
  - 🟩 Did not directly modify user code
  - 🟩 Used AskUserQuestion

**Verification Check**
  - 🟩 Log level suggested when configurable
  - 🟩 Output summary is complete

✅ All passed, proceeding to output.
```

### Output Example

**Review Results Example:**

```markdown
| Dimension | Result |
| --- | --- |
| Reviewed File | src/app.module.ts, src/user/user.controller.ts |
| Total Review Items | 7 |
| Passed | 4 |
| Issues Found | 3 |
| Risk Level | 🟡 Medium |
| Suggestions Adopted | 2 |
| Ignored/Viewed Only | 1 |
```

## Review List

- **Content Check**
  - [ ] All review items reference NestJS official logging and health check documentation
  - [ ] Third-party logging library selection marked as technical choice
- **Behavior Check**
  - [ ] Did not directly modify user code (unless explicitly requested by user)
  - [ ] All interaction steps used AskUserQuestion
- **Verification Check**
  - [ ] Correctly terminated when target code is empty or unreadable
  - [ ] Log level suggestion provided when configurable
  - [ ] Output summary includes file path, number of review items, issues found, and risk level

## References

- [NestJS Logging Documentation](https://docs.nestjs.com/techniques/logger)
- [NestJS Health Checks](https://docs.nestjs.com/recipes/terminus)
- [NestJS Performance Monitoring](https://docs.nestjs.com/techniques/performance)
- [skill-evolve Template](../../skill-evolve/template.md)
