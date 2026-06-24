---
name: nestjs-7-3-standalone-apps
description: Review the implementation of NestJS standalone application mode, covering non-HTTP applications, microservice clients, and CLI tool scenarios. Use this when users need to review or develop standalone NestJS applications.
---

# NestJS Standalone Applications

## Overview

When AI encounters standalone application-related code in a NestJS project, it automatically performs the following: review the usage of NestFactory.createApplicationContext, check service retrieval and module loading in standalone applications, evaluate applicable scenarios, and provide improvement suggestions.

## Definitions

- <a id="target-code"></a>**Target Code**: The standalone application creation code or scenario code using standalone applications from the NestJS project in the current conversation.
- <a id="standalone-app"></a>**Standalone Application**: A NestJS application instance created using NestFactory.createApplicationContext that does not start an HTTP server and is used only for background scripts.

## Prerequisites

- NestJS project environment; understanding of DI container and module system.

## Workflow

0. **Pre-check** — Ensure target code and runtime environment are reachable;
   - Determine if target code exists and is readable:
     - Yes -> Next step;
     - No -> Prompt user to provide code, block and wait for user input;

1. **Analyze standalone application code** — Read and understand application creation and service retrieval logic;
   - Identify the method of using app.get() to retrieve services; check if app.close() is called to release resources;

2. **Item-by-item review** — Check the correctness of standalone application implementation;
   - Determine if app.init() or app.close() correctly manages the lifecycle:
     - Pass -> Record as pass;
     - Fail -> Record "Missing app.close() may cause resource leaks";
   - Determine if the service obtained via get() exists in the imported module:
     - Pass -> Record as pass;
     - Fail -> Record "Service is not exported from the module, cannot be retrieved from standalone application";
   - Determine if there are any issue records:
     - Yes -> Compile issue list, proceed to next step;
     - No -> Proceed directly to step 4;

3. **Provide modification suggestions** — Confirm via AskUserQuestion whether to apply changes;
4. **Review check** — Verify against Review List item by item;
5. **Output results** — Output review summary table;

## Rules

- **Content Standards**
  - description uses third person, no more than 1024 characters; SKILL.md no more than 300 lines;
- **Behavior Standards**
  - During review, only output issue summaries; interaction steps use AskUserQuestion;
- **Defense Standards**
  - If the target code is empty or unreadable, report directly and terminate;

## Examples

### Conversation Interaction Example

```markdown
User > Help me check this standalone application
AI   > Triggered nestjs-7-3-standalone-apps skill...
Review Results:
- 🟩 Correctly created using createApplicationContext
- 🟥 Missing app.close(), may cause process to hang
- 🟩 Service is exported from the module
User > Help me add app.close()
AI   > Apply changes? User > Yes
```

### Review Check Example

```markdown
AI > Review List verification... ✅ All passed.
```

### Output Example

```markdown
| Dimension | Result |
| --- | --- |
| Reviewed File | scripts/seed.ts | Total Review Items | 4 | Passed | 3 | Issues Found | 1 |
```

## Review List

- [ ] Reported when missing app.close(); [ ] Reported when service not exported; [ ] Output summary is complete

## References

- [NestJS Standalone Apps](https://docs.nestjs.com/standalone-applications)
- [skill-evolve Template](../../skill-evolve/template.md)
