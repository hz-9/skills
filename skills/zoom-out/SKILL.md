---
name: zoom-out
description: Helps the agent zoom out to provide broader context or a higher-level perspective. Use when the user is unfamiliar with a piece of code or needs to understand how it fits into the bigger picture.
disable-model-invocation: true
---

# Zoom Out

## Overview

When the agent is unfamiliar with a piece of code, trigger the zoom-out perspective: abstract up one level and generate a global map of related modules and callers, using the project's domain glossary terms, to help understand where the code sits in the overall architecture.

## Definitions

- **Zoom Out**: Abstracting upward from the current code snippet to present a panoramic view of module relationships, call chains, and architectural roles;
- **Module Map**: A structured view listing upstream/downstream dependencies, callers, and callees of the current file/module.

## Prerequisites

- The current project has a browsable codebase that the agent can access;
- Having a domain glossary or established naming conventions is helpful but not required.

## Workflow

1. Understand the target code specified by the user (file, function, module, or code snippet);
2. Abstract up one level and identify the module the target code belongs to and its architectural role;
3. Search and list the upstream callers that invoke this module, as well as the downstream modules it depends on;
4. Organize the output using the project's domain glossary terms and generate a module map;
5. Present the module map to the user, explaining how the target code fits into the bigger picture.

## Rules

- Always abstract up one level; do not dive into implementation details;
- Use the project's existing domain terminology; avoid introducing new terms;
- If the project has no domain glossary, infer terminology from code naming conventions;
- Present output in a structured map format rather than lengthy prose.

## Examples

### Dialogue Interaction Example

**Example: AI triggers zoom-out based on user request**

```
User > I'm not familiar with this piece of code, help me zoom out

AI > Triggering zoom-out perspective, analyzing...

Target code: UserAuthService.authenticate()
Module: auth

┌─────────────────────────────────────────┐
│              Callers                    │
│  LoginController (web/login)            │
│  ApiGateway (gateway/)                  │
│  SessionManager (core/session)          │
└──────────────┬──────────────────────────┘
               │
    UserAuthService.authenticate()
               │
┌──────────────┴──────────────────────────┐
│           Dependencies                  │
│  PasswordHasher (crypto/)               │
│  UserRepository (data/user)             │
│  TokenService (auth/token)              │
│  AuditLogger (core/logging)             │
└─────────────────────────────────────────┘

UserAuthService sits in the auth module, responsible for user authentication.
Called upstream by LoginController, ApiGateway, etc.;
Downstream it depends on crypto, data access, and token services.
```

### Execution Success Example

| Dimension | Description |
|-----------|-------------|
| Target code | UserAuthService.authenticate() |
| Module | auth |
| Upstream callers | 3 (LoginController, ApiGateway, SessionManager) |
| Downstream dependencies | 4 (PasswordHasher, UserRepository, TokenService, AuditLogger) |
| Output format | Structured module map |

## Review List

- [ ] Output includes the target code's module and architectural role
- [ ] Upstream callers and downstream dependencies are listed
- [ ] Project domain terminology is used
- [ ] Output is in a structured map format, not lengthy prose

## References

None (this skill requires no external reference documents).
