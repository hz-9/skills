---
name: nestjs-5-2-security-tools
description: Review NestJS web security defense strategies, covering Helmet, CORS, CSRF, Rate Limiting, and input security. Use this when users need to review security configurations or harden API protection.
---

# NestJS Web Security Defense Strategies

## Overview

When AI encounters web security-related code in a NestJS project, it automatically performs the following: review the configuration of security middleware such as Helmet, CORS, and CSRF, check the reasonableness of Rate Limiting strategies, evaluate the completeness of overall security protection, identify common security configuration omissions, and provide improvement suggestions.

## Definitions

- <a id="target-code"></a>**Target Code**: The security configuration in main.ts or the implementation code of security middleware in the NestJS project from the current conversation.
- <a id="helmet"></a>**Helmet**: Middleware that defends against common web attacks by setting HTTP security headers (Content-Security-Policy, X-Frame-Options, etc.).
- <a id="rate-limiting"></a>**Rate Limiting**: Request frequency limiting implemented using the @nestjs/throttler module to prevent API abuse or DDoS attacks.
- <a id="analysis-complete"></a>**Analysis Complete**: A flag indicating whether the analysis of the target code has reached a complete result.

## Prerequisites

- NestJS project environment;
- main.ts or security configuration related code accessible;
- Understanding of common web security threats (XSS, CSRF, clickjacking, etc.).

## Workflow

0. **Pre-check** — Ensure target code and runtime environment are reachable;
   - Determine if target code exists and is readable:
     - Yes -> Next step;
     - No -> Prompt user to provide target code or file path, block and wait for user input;
   - Initialize global variable [Analysis Complete](#analysis-complete):
     - Determine if the code is fully parsable:
       - Satisfied -> Initialize variable to true;
       - Not satisfied -> Initialize variable to false;

1. **Analyze security code** — Read and understand security middleware configuration;
   - Read target code, identify the following core elements:
     - Helmet middleware registration and configuration options;
     - CORS configuration (origin, methods, credentials, etc.);
     - CSRF protection implementation;
     - ThrottlerModule configuration (ttl, limit, storage);

2. **Item-by-item review** — Check security configuration completeness against the review checklist;
   - Determine whether each review item passes in sequence:
     - Is the Helmet middleware registered (setting security HTTP headers to defend against XSS, etc.):
       - Pass -> Record as pass, continue to next item;
       - Fail -> Record "Missing Helmet middleware, recommend adding helmet security headers", continue;
     - Does CORS configure specific allowed origins (avoiding wildcard `*`):
       - Pass -> Record as pass, continue to next item;
       - Fail -> Record "CORS uses wildcard *, recommend restricting to specific allowed origins", continue;
     - Is CSRF protection configured (for cookie-authenticated applications):
       - Pass -> Record as pass, continue to next item;
       - Fail -> Record "Missing CSRF protection, recommend adding @nestjs/csurf or csurf middleware", continue;
     - Is ThrottlerModule registered with reasonable rate limiting parameters:
       - Pass -> Record as pass, continue to next item;
       - Fail -> Record "Missing rate limiting configuration, recommend adding @nestjs/throttler to prevent abuse", continue;
     - Is request body size limit handled (body-parser or Fastify's bodyLimit):
       - Pass -> Record as pass, continue to next item;
       - Fail -> Record "Request body size is not limited, recommend setting bodyParser limit option", continue;
   - Determine if there are any issue records:
     - Yes -> Compile issue list, proceed to next step;
     - No -> Proceed directly to step 4 (Review Check);

3. **Provide modification suggestions** — Give specific remediation plans for discovered issues;
   - Provide remediation suggestions for each issue sequentially;
   - Present options via AskUserQuestion, block and wait for user selection:
     - Accept all suggestions -> Generate corrected configuration code, proceed to step 4;
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
  - Review items must reference OWASP security best practices and NestJS official documentation;
  - SKILL.md must not exceed 300 lines; split to references/ directory when exceeded;
  - Reference hierarchy must not exceed one level;
  - Maintain consistent terminology, terms defined in Definitions must be referenced via anchor links in the body;
  - Remove any time-sensitive information;

- **Behavior Standards**
  - During review, only output issue summaries and locations, do not directly modify code unless explicitly requested by the user via AskUserQuestion;
  - All code modification interaction steps must use the AskUserQuestion tool;
  - Security configuration review items (Helmet, CSRF) should be marked as recommended, CORS wildcard and request body size as suggestions;

- **Defense Standards**
  - If the target code is empty or unreadable, report directly and terminate;
  - CSRF necessity should be marked as mandatory only for cookie-authenticated applications, optional for token-authenticated applications;

- **Verification Standards**
  - Examples content must be consistent with Rules;
  - Examples must include a review check example;
  - Conversation interaction examples should only focus on steps 0~3 (excluding review check and output);

## Examples

### Conversation Interaction Example

**Example: User requests security configuration review**

```markdown
User > Help me check if the project's security configuration is complete
AI   > Detected user needs NestJS web security review, triggering nestjs-5-2-security-tools skill
AI   > Analyzing security configuration...

Review Results:
- 🟥 Helmet middleware not registered
- 🟥 CORS configured as origin: '*', recommend restricting to specific domains
- 🟩 CSRF protection configured (using JWT token auth, not required)
- 🟥 No rate limiting configured, missing @nestjs/throttler
- 🟩 Request body size limited to 1MB

Summary: 3 issues need attention
User > Help me add Helmet and rate limiting configuration
AI   > Added app.use(helmet()) and ThrottlerModule. Apply changes?
User > Accept all
```

### Review Check Example

```markdown
AI > Entering review check, Review List has 5 check items, beginning verification:

**Content Check**
  - 🟩 All review items reference OWASP best practices
  - 🟩 CSRF marking depends on auth method

**Behavior Check**
  - 🟩 Did not directly modify user code
  - 🟩 Used AskUserQuestion

**Verification Check**
  - 🟩 CSRF necessity marked with context dependency
  - 🟩 Output summary is complete

✅ All passed, proceeding to output.
```

### Output Example

**Review Results Example:**

```markdown
| Dimension | Result |
| --- | --- |
| Reviewed File | src/main.ts |
| Total Review Items | 7 |
| Passed | 4 |
| Issues Found | 3 |
| Risk Level | 🔴 High |
| Suggestions Adopted | 2 |
| Ignored/Viewed Only | 1 |
```

## Review List

- **Content Check**
  - [ ] All review items reference NestJS official security documentation and OWASP best practices
  - [ ] CSRF marked as required or optional based on auth method
- **Behavior Check**
  - [ ] Did not directly modify user code (unless explicitly requested by user)
  - [ ] All interaction steps used AskUserQuestion
- **Verification Check**
  - [ ] Correctly terminated when target code is empty or unreadable
  - [ ] CSRF necessity marked with context dependency
  - [ ] Output summary includes file path, number of review items, issues found, and risk level

## References

- [NestJS Security Documentation](https://docs.nestjs.com/security/helmet)
- [NestJS CORS Configuration](https://docs.nestjs.com/security/cors)
- [NestJS Rate Limiting](https://docs.nestjs.com/security/rate-limiting)
- [OWASP Security Best Practices](https://owasp.org/)
- [skill-evolve Template](../../skill-evolve/template.md)
