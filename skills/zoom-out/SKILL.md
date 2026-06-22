---
name: zoom-out
description: Let the agent zoom out to provide broader context or a higher-level perspective. Use when the user is unfamiliar with a piece of code or needs to understand how it fits into the bigger picture.
disable-model-invocation: true
---

# Zoom Out

## Overview

When the user is unfamiliar with a section of code, the AI triggers a zoom-out perspective: pull the view up one level of abstraction, generate a global map of related modules and callers using project domain terminology, helping the user understand where the code sits in the overall architecture.

## Definitions

- <a id="zoom-out"></a>**Zoom Out**: Pull the view up from the current code fragment to a higher level of abstraction, showing module relationships, call chains, and architectural roles in a panoramic view.
- <a id="Module-Map"></a>**Module Map**: A structured view listing the upstream and downstream dependencies, callers, and callees of the current file/module.

## Prerequisites

- The current project has a browseable codebase that the agent can access for relevant source files.
- It is better (but not required) if the project has a domain glossary or established naming conventions.

> **Suggestion**: If the project already has a `CONTEXT.md` or domain documentation, zoom-out will be able to use more accurate domain terminology when organizing the module map.

## Workflow

0. **Pre-flight Check** — Ensure zoom-out conditions are met;
    - Ensure target code is accessible:
      - Yes -> next step;
      - No -> report "Target code does not exist or is not accessible", terminate flow;
    - Check if the project has a domain glossary:
      - Yes -> load the glossary for subsequent output;
      - No -> infer terminology from code naming conventions;

1. **Understand Target Code** — Analyze the context of the target code specified by the user;
    - Identify the module and architectural role of the target code;

2. **Analyze Call Relationships** — Search and list call chains;
    - Use code search tools to find which files reference this module;
    - Use LSP or code navigation features to obtain call chains;
    - Mark module layer positions (infrastructure / domain / application);

3. **Generate Module Map** — Organize output using project domain terminology (max 3 retries);
    - (Initialize retry count to 0 on first execution)
    - Check if output is in structured map format:
      - Yes -> next step;
      - No -> increment retry count by 1:
        - Not exceeded 3 times -> reorganize into map format, return to step 3 start and re-verify;
        - Reached 3 times -> report "Cannot generate structured map", terminate flow;

4. **Review Check** — Check against [Review List](#review-list) to confirm output content;
    - (Initialize review retry count to 0 on first entry)
    - Check if Review List has content:
        - No -> go directly to next step (output results);
        - Yes -> next step;
    - Check each item in [Review List](#review-list) in order, check if passed:
        - Display output content based on "Review Check Example";
        - Any check fails -> increment review retry count by 1:
          - Not exceeded 3 times -> regenerate module map, return to step 3;
          - Reached 3 times -> report "Review check failed", terminate flow;
        - All passed -> next step;

5. **Output Results** — Present [Module Map](#Module-Map) to the user, explaining how the target code fits into the big picture;
    - Output structured summary (module identity, upstream caller count, downstream dependency count, etc.);
    - Notify processing complete;

## Rules

- **Content Conventions**
  - Always abstract up one level, do not dive into implementation details;
  - Output is presented in a structured map format, not as long descriptive text.
- **Terminology Conventions**
  - Use existing project domain terminology, avoid introducing new terms;
  - If the project has no domain glossary, infer terminology from code naming conventions;
- **Verification Conventions**
  - Review List check items cover all binding rules in Rules, ensuring that behaviors constrained by Rules have corresponding output quality verification in Review List (following the Concern Separation principle);

## Examples

### Dialog Interaction Examples

**Example: AI triggers zoom-out based on user request**

```markdown
User > I'm not familiar with this code, help me zoom out

AI > Triggering zoom-out perspective, starting analysis...

Target code: UserAuthService.authenticate()
Module: auth (authentication module)

┌─────────────────────────────────────────┐
│              Callers                     │
│  LoginController (web/login)            │
│  ApiGateway (gateway/)                  │
│  SessionManager (core/session)          │
└──────────────┬──────────────────────────┘
               │
    UserAuthService.authenticate()
               │
┌──────────────┴──────────────────────────┐
│              Dependencies               │
│  PasswordHasher (crypto/)               │
│  UserRepository (data/user)             │
│  TokenService (auth/token)              │
│  AuditLogger (core/logging)             │
└─────────────────────────────────────────┘

UserAuthService is located in the auth module, responsible for user authentication.
Upstream callers include LoginController, ApiGateway, etc.;
downstream dependencies include encryption, data access, and token services.
```

### Review Check Example

```markdown
AI > Entering review check, verifying against Review List:

**Content Completeness Check**
  - 🟩 Output includes module identity and architectural role
  - 🟥 Upstream callers and downstream dependencies not listed — call chain missing
  - 🟩 Callers and dependencies include path information
**Format Conformance Check**
  - 🟩 Uses project domain terminology
  - 🟥 Output is long descriptive text rather than structured map format

(AI will output all check item results during runtime)

**!!! Following check items FAILED !!!**
  - 🟥 Content completeness: call chain information missing
  - 🟥 Format conformance: output not in map format

Terminating flow, returning to step 3 to regenerate module map.
```

### Output Results Example

```markdown
| Dimension | Description |
|-----------|-------------|
| Target code | UserAuthService.authenticate() |
| Module | auth (authentication module) |
| Upstream callers | 3 |
| Downstream dependencies | 4 |
| Abstraction | Abstracted up one level |
| Output format | Structured module map |
```

### Execution Success Example

```markdown
| Dimension | Description |
|-----------|-------------|
| Target code | UserAuthService.authenticate() |
| Module | auth (authentication module) |
| Upstream callers | 3 (LoginController, ApiGateway, SessionManager) |
| Downstream dependencies | 4 (PasswordHasher, UserRepository, TokenService, AuditLogger) |
| Output format | Structured module map |
```

## Review List

After zoom-out, verify the following:

- **Content Completeness Check**
    - [ ] Output includes the target code's module identity and architectural role
    - [ ] Upstream callers and downstream dependencies listed
    - [ ] Callers and dependencies include path/location information
- **Format Conformance Check**
    - [ ] Uses project domain terminology, not introducing new terms
    - [ ] When no project domain glossary exists, terminology inferred from code naming conventions, not self-created
    - [ ] Output in structured map format, not long descriptive text
    - [ ] Abstraction level correct: only abstracted up one level, not diving into implementation details

## References

None (this skill requires no external reference documents).
---
name: zoom-out
description: Make the agent zoom out, providing broader context or a higher-level perspective. Use when you're unfamiliar with some code or need to understand how it fits into the bigger picture.
disable-model-invocation: true
---

I'm not very familiar with this code. Go up one level of abstraction. Give me a map of all related modules and callers, using the project's domain glossary terminology.

## Examples

- User: "I'm not familiar with this code, help me zoom out" → agent outputs a module map and call relationships
- User: "What does this file do? How does it relate to the whole project?" → agent explains the file's role in the overall architecture
