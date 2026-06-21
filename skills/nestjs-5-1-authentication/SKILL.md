---
name: nestjs-5-1-authentication
description: Review NestJS authentication implementation, covering JWT strategy, Session management, OAuth2 integration, and @AuthGuard usage. Use this when users need to review authentication flows or troubleshoot login issues.
---

# NestJS Authentication & Security

## Overview

When AI encounters authentication-related code in a NestJS project, it automatically performs the following: review the correctness of JWT strategy and Passport integration, check the implementation and registration of authentication guards, evaluate the completeness of token management (Access Token / Refresh Token), identify common authentication vulnerabilities, and provide improvement suggestions.

## Definitions

- <a id="target-code"></a>**Target Code**: The NestJS authentication module, Passport strategy, or AuthGuard related code in the current conversation.
- <a id="jwt-strategy"></a>**JWT Strategy**: A JWT verification strategy implemented based on @nestjs/passport and passport-jwt, containing logic for extracting tokens from requests and validating payloads.
- <a id="authguard"></a>**AuthGuard**: A built-in guard provided by @nestjs/passport that automatically invokes the Passport strategy for authentication.
- <a id="analysis-complete"></a>**Analysis Complete**: A flag indicating whether the analysis of the target code has reached a complete result.

## Prerequisites

- NestJS project environment (including @nestjs/passport, @nestjs/jwt, passport dependencies);
- Authentication module or strategy code files accessible;
- Understanding of JWT, Passport, and OAuth2 basics.

## Workflow

0. **Pre-check** — Ensure target code and runtime environment are reachable;
   - Determine if target code exists and is readable:
     - Yes -> Next step;
     - No -> Prompt user to provide target code or file path, block and wait for user input;
   - Initialize global variable [Analysis Complete](#analysis-complete):
     - Determine if the code is fully parsable:
       - Satisfied -> Initialize variable to true;
       - Not satisfied -> Initialize variable to false;

1. **Analyze authentication code** — Read and understand the authentication flow and strategy implementation;
   - Read target code, identify the following core elements:
     - Passport strategy implementation (JwtStrategy, etc.) and configuration (secretOrKey, jwtFromRequest);
     - JwtModule registration configuration (secret, signOptions);
     - Usage of AuthGuard (@nestjs/passport) and custom guards;
     - Route design of authentication controller (login, register, refresh);
     - Refresh Token implementation (if any);

2. **Item-by-item review** — Check authentication code quality against the review checklist;
   - Determine whether each review item passes in sequence:
     - Is the JWT secret managed using environment variables (rather than hardcoded in code):
       - Pass -> Record as pass, continue to next item;
       - Fail -> Record "JWT secret is hardcoded in code, recommend using environment variables", continue;
     - Is the JWT token configured with a reasonable expiration time (expiresIn, avoiding too long or too short):
       - Pass -> Record as pass, continue to next item;
       - Fail -> Record "JWT expiration time is unreasonable, recommend adjusting based on security policy", continue;
     - Is the Refresh Token mechanism implemented (to avoid frequent re-login when Access Token expires):
       - Pass -> Record as pass, continue to next item;
       - Fail -> Record "Missing Refresh Token mechanism, user experience may be affected", continue;
     - Does the Passport strategy's validate method verify that the user exists (not relying solely on token validity):
       - Pass -> Record as pass, continue to next item;
       - Fail -> Record "validate method does not verify user status, deleted users can still use old tokens", continue;
     - Does the login route include request rate limiting (to prevent brute force attacks):
       - Pass -> Record as pass, continue to next item;
       - Fail -> Record "Login route lacks rate limiting, recommend adding @nestjs/throttler", continue;
     - Are passwords stored using hashing (e.g., bcrypt) rather than plaintext:
       - Pass -> Record as pass, continue to next item;
       - Fail -> Record "Passwords are stored in plaintext, posing a serious security risk", continue;
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
  - Review items must reference NestJS official authentication documentation and security best practices;
  - SKILL.md must not exceed 300 lines; split to references/ directory when exceeded;
  - Reference hierarchy must not exceed one level;
  - Maintain consistent terminology, terms defined in Definitions must be referenced via anchor links in the body;
  - Remove any time-sensitive information;

- **Behavior Standards**
  - During review, only output issue summaries and locations, do not directly modify code unless explicitly requested by the user via AskUserQuestion;
  - All code modification interaction steps must use the AskUserQuestion tool;
  - Security-related review items (password hashing, secret management) should be marked as mandatory rather than advisory;

- **Defense Standards**
  - If the target code is empty or unreadable, report directly and terminate;
  - Refresh Token mechanism should be marked as an enhancement suggestion rather than a requirement;

- **Verification Standards**
  - Examples content must be consistent with Rules;
  - Examples must include a review check example;
  - Conversation interaction examples should only focus on steps 0~3 (excluding review check and output);

## Examples

### Conversation Interaction Example

**Example: User requests authentication review**

```markdown
User > Help me check the security of this JWT authentication
AI   > Detected user needs NestJS authentication review, triggering nestjs-5-1-authentication skill
AI   > Analyzing authentication code...

Review Results:
- 🟥 JWT secret is hardcoded in code, recommend using environment variables
- 🟩 Token expiration set to 15 minutes, reasonable
- 🟥 Missing Refresh Token mechanism
- 🟩 validate method verifies user existence
- 🟥 Passwords stored in plaintext, serious security risk

Summary: 3 issues need attention
User > Help me fix the secret hardcoding and password storage issues
AI   > Changed secret to use ConfigService, passwords to use bcrypt hashing. Apply changes?
User > Accept all
```

### Review Check Example

```markdown
AI > Entering review check, Review List has 6 check items, beginning verification:

**Content Check**
  - 🟩 All review items reference official documentation
  - 🟩 Security items marked as mandatory

**Behavior Check**
  - 🟩 Did not directly modify user code
  - 🟩 Used AskUserQuestion

**Verification Check**
  - 🟩 Refresh Token marked as suggestion
  - 🟩 Output summary is complete

✅ All passed, proceeding to output.
```

### Output Example

**Review Results Example:**

```markdown
| Dimension | Result |
| --- | --- |
| Reviewed File | src/auth/auth.module.ts, src/auth/jwt.strategy.ts |
| Total Review Items | 8 |
| Passed | 5 |
| Issues Found | 3 |
| Risk Level | 🔴 High |
| Suggestions Adopted | 2 |
| Ignored/Viewed Only | 1 |
```

## Review List

- **Content Check**
  - [ ] All review items reference NestJS official authentication documentation and security best practices
  - [ ] Security-related review items (password hashing, secret management) marked as mandatory
- **Behavior Check**
  - [ ] Did not directly modify user code (unless explicitly requested by user)
  - [ ] All interaction steps used AskUserQuestion
- **Verification Check**
  - [ ] Correctly terminated when target code is empty or unreadable
  - [ ] Refresh Token marked as enhancement suggestion
  - [ ] Output summary includes file path, number of review items, issues found, and risk level

## References

- [NestJS Authentication Documentation](https://docs.nestjs.com/security/authentication)
- [NestJS Passport Integration](https://docs.nestjs.com/recipes/passport)
- [JWT Official Documentation](https://jwt.io/)
- [skill-evolve Template](../../skill-evolve/template.md)
