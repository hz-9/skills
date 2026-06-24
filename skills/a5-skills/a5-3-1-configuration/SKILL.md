---
name: nestjs-3-1-configuration
description: Review NestJS multi-environment configuration management practices, covering @nestjs/config, custom configuration loading, validation, and dynamic configuration injection. Use when users need to review configuration modules or troubleshoot environment configuration issues.
---

# NestJS Multi-Environment Configuration Management

## Overview

When AI encounters configuration management related code in a NestJS project, it automatically performs the following: review the ConfigModule configuration and custom namespace usage, check environment variable loading and validation logic, evaluate the reliability of dynamic configuration injection, identify common configuration management issues, and provide improvement suggestions.

## Definitions

- <a id="target-code"></a>**Target code**: The NestJS ConfigModule configuration, environment variable files, or custom configuration loading code in the current conversation.
- <a id="ConfigModule"></a>**ConfigModule**: The configuration module provided by @nestjs/config, supporting .env file loading, namespaces, and configuration validation.
- <a id="configuration-namespace"></a>**Configuration namespace**: Custom configuration functions registered via the load option of ConfigModule.forRoot, returning configuration objects grouped by domain.
- <a id="analysis-complete"></a>**Analysis complete**: Indicates whether the analysis of the target code has been fully completed.

## Prerequisites

- NestJS project environment (including @nestjs/config dependency);
- ConfigModule configuration or environment variable files accessible;
- Understanding of 12-factor app configuration management principles.

## Workflow

0. **Pre-check** — Ensure the target code and runtime environment are reachable;
   - Determine if the target code exists and is readable:
     - Yes -> next step;
     - No -> prompt the user to provide the target code or file path, block and wait for user input;
   - Initialize global variable [analysis complete](#analysis-complete):
     - Determine if the code is fully parseable:
       - Satisfied -> initialize variable to true;
       - Not satisfied -> initialize variable to false;

1. **Analyze configuration code** — Read and understand configuration management and environment variable loading;
   - Read the target code, identify the following core elements:
     - ConfigModule.forRoot() configuration options (envFilePath, ignoreEnvFile, load, validationSchema);
     - Naming and location of environment variable files (.env, .env.development, .env.production);
     - Custom configuration namespace implementation (registerAs function);
     - Configuration validation approach (joi or zod schema validation);

2. **Review items** — Check configuration management code quality against the review checklist;
   - Iterate through the following review items to determine if they pass:
     - Whether independent .env files are prepared for different environments (dev/test/prod):
       - Pass -> record as passed, continue to next review item;
       - Fail -> record "Recommend maintaining independent .env files for different environments", continue;
     - Whether a configuration validation Schema is used (joi or zod for required fields and type validation):
       - Pass -> record as passed, continue to next review item;
       - Fail -> record "Missing configuration validation Schema, configuration errors cannot be caught at startup", continue;
     - Whether custom configuration uses registerAs namespaces (to avoid global key conflicts):
       - Pass -> record as passed, continue to next review item;
       - Fail -> record "Recommend using registerAs to create configuration namespaces instead of directly reading process.env", continue;
     - Whether .env files are included in .gitignore (to prevent sensitive information leakage):
       - Provide modification suggestions but do not block -> continue;
     - Whether all configuration items have reasonable default values (to avoid runtime errors due to missing environment variables):
       - Pass -> record as passed, continue to next review item;
       - Fail -> record "Configuration items without default values will return undefined when environment variables are missing", continue;
     - Whether isGlobal is set as needed (to avoid implicit dependencies from global ConfigModule):
       - Pass -> record as passed, continue to next review item;
       - Fail -> record "isGlobal: true allows all modules to directly use ConfigService", continue;
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
  - Review items must reference NestJS official configuration management documentation;
  - SKILL.md no more than 300 lines; split to references/ directory when exceeded;
  - Reference hierarchy no more than one level;
  - Maintain terminology consistency, terms defined in Definitions must be referenced via anchor links in the body;
  - Remove any time-sensitive information;

- **Behavior rules**
  - Only output issue summaries and locations during review, do not directly modify code unless the user explicitly requests via AskUserQuestion;
  - All interaction steps involving code modification must use the AskUserQuestion tool;
  - isGlobal and namespace usage should be labeled as architectural suggestions, not mandatory;

- **Defensive rules**
  - If target code is empty or unreadable, report directly and terminate;
  - Suggestions about .env being included in .gitignore should only provide hints, do not block the process;

- **Validation rules**
  - Examples content must be self-consistent with Rules;
  - Examples must include a review check example;
  - Dialogue interaction examples should only focus on steps 0~3 (excluding review check and output);

## Examples

### Dialogue Interaction Example

**Example: User requests configuration management review**

```markdown
User > Help me check if the project's configuration management follows best practices
AI   > Detected user needs NestJS configuration management review, triggered nestjs-3-1-configuration skill
AI   > Analyzing configuration code...

Review Results:
- 🟩 Independent .env files for different environments
- 🟥 Missing joi validation Schema, configuration errors cannot be caught at startup
- 🟩 Using registerAs to create database and Redis namespaces
- 🟥 Some configuration items (DB_PORT) have no default values
- 🟩 .env is covered by .gitignore

Summary: 2 issues need attention
User > Add validation Schema and default values
AI   > Please provide the types and required fields of environment variables, I will generate the configuration Schema? User > OK
```

### Review Check Example

```markdown
AI > Entering review check, Review List contains 5 items, starting verification:

**Content Check**
  - 🟩 All review items reference official documentation
  - 🟩 isGlobal suggestions are labeled as suggestions

**Behavior Check**
  - 🟩 Did not directly modify user code
  - 🟩 Used AskUserQuestion

**Validation Check**
  - 🟩 .env suggestions labeled as hints
  - 🟩 Output summary is complete

✅ All passed, proceeding to output.
```

### Output Example

**Review Result Example:**

```markdown
| Dimension | Result |
| --- | --- |
| Reviewed File | src/config/app.config.ts |
| Total Review Items | 7 items |
| Passed | 5 items |
| Issues Found | 2 items |
| Risk Level | 🟡 Medium |
| Suggestions Adopted | 2 items |
```

## Review List

- **Content Check**
  - [ ] All review items reference NestJS official configuration management documentation
  - [ ] isGlobal and namespace labeled as architectural suggestions
- **Behavior Check**
  - [ ] Did not directly modify user code (unless explicitly requested by the user)
  - [ ] All interaction steps used AskUserQuestion
- **Validation Check**
  - [ ] Correctly terminated when target code is empty or unreadable
  - [ ] .env leakage hint does not block the process
  - [ ] Output summary includes file path, number of review items, issues found, and risk level

## References

- [NestJS Configuration Official Documentation](https://docs.nestjs.com/techniques/configuration)
- [@nestjs/config Documentation](https://github.com/nestjs/config)
- [skill-evolve Template](../../skill-evolve/template.md)
