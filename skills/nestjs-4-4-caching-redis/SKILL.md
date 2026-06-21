---
name: nestjs-4-4-caching-redis
description: Review NestJS caching strategy and Redis integration practices, covering CacheModule configuration, custom cache managers, and cache invalidation strategies. Use when users need to review cache implementation or optimize performance.
---

# NestJS Caching Strategy and Redis

## Overview

When AI encounters cache related code in a NestJS project, it automatically performs the following: review cache module configuration and cache manager setup, check CacheInterceptor usage scenarios, evaluate cache invalidation strategies and data consistency mechanisms, identify common caching pitfalls, and provide improvement suggestions.

## Definitions

- <a id="target-code"></a>**Target code**: The NestJS cache module configuration, cache interceptor usage, or custom cache management code in the current conversation.
- <a id="cache-manager"></a>**Cache manager**: NestJS's CacheManager, supporting in-memory caching and external storage like Redis, providing get, set, del operations.
- <a id="cache-interceptor"></a>**Cache interceptor**: NestJS built-in CacheInterceptor that automatically caches GET endpoint responses, needs to be enabled in @Module.
- <a id="analysis-complete"></a>**Analysis complete**: Indicates whether the analysis of the target code has been fully completed.

## Prerequisites

- NestJS project environment (including @nestjs/cache-manager and cache-manager dependencies);
- Cache configuration or related code accessible;
- Understanding of basic caching strategy concepts (TTL, cache penetration, cache avalanche).

## Workflow

0. **Pre-check** — Ensure the target code and runtime environment are reachable;
   - Determine if the target code exists and is readable:
     - Yes -> next step;
     - No -> prompt the user to provide the target code or file path, block and wait for user input;
   - Initialize global variable [analysis complete](#analysis-complete):
     - Determine if the code is fully parseable:
       - Satisfied -> initialize variable to true;
       - Not satisfied -> initialize variable to false;

1. **Analyze cache code** — Read and understand cache configuration and strategy;
   - Read the target code, identify the following core elements:
     - CacheModule registration approach (global / module-level) and configuration (ttl, max);
     - Redis store integration configuration (store type, connection parameters);
     - CacheInterceptor application scope (global / controller / method-level);
     - Manual cache operations (cacheManager.get, set, del);
     - Cache key naming strategy;

2. **Review items** — Check cache implementation quality against the review checklist;
   - Iterate through the following review items to determine if they pass:
     - Whether the cache TTL value is reasonable (avoiding stale data due to excessive TTL or cache inefficiency due to insufficient TTL):
       - Pass -> record as passed, continue to next review item;
       - Fail -> record "TTL setting is unreasonable, recommend adjusting based on data update frequency", continue;
     - Whether cache invalidation is performed after write operations (POST / PUT / DELETE) (to avoid dirty data):
       - Pass -> record as passed, continue to next review item;
       - Fail -> record "Related cache not cleared after write operations, may return stale data", continue;
     - Whether Redis configuration is correct (using store configuration in @nestjs/cache-manager):
       - Pass -> record as passed, continue to next review item;
       - Fail -> record "Redis store configuration is incomplete, please check store driver and connection parameters", continue;
     - Whether cache keys are unique and contain sufficient context information (to avoid key conflicts):
       - Pass -> record as passed, continue to next review item;
       - Fail -> record "Cache key definition is too simple, may cause conflicts, recommend including module name prefix", continue;
     - Whether CacheInterceptor is only applied to GET endpoints (non-idempotent methods should not be auto-cached):
       - Pass -> record as passed, continue to next review item;
       - Fail -> record "CacheInterceptor applied to non-GET methods may cause unexpected behavior", continue;
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
  - Review items must reference NestJS and cache-manager official documentation;
  - SKILL.md no more than 300 lines; split to references/ directory when exceeded;
  - Reference hierarchy no more than one level;
  - Maintain terminology consistency, terms defined in Definitions must be referenced via anchor links in the body;
  - Remove any time-sensitive information;

- **Behavior rules**
  - Only output issue summaries and locations during review, do not directly modify code unless the user explicitly requests via AskUserQuestion;
  - All interaction steps involving code modification must use the AskUserQuestion tool;
  - TTL value suggestions should be based on data update frequency as reference, not fixed values;

- **Defensive rules**
  - If target code is empty or unreadable, report directly and terminate;
  - Cache invalidation necessity should only be reported when write operations are confirmable, uncertain related data should be labeled as requiring manual confirmation;

- **Validation rules**
  - Examples content must be self-consistent with Rules;
  - Examples must include a review check example;
  - Dialogue interaction examples should only focus on steps 0~3 (excluding review check and output);

## Examples

### Dialogue Interaction Example

**Example: User requests cache configuration review**

```markdown
User > Help me check if the cache configuration is reasonable
AI   > Detected user needs NestJS caching strategy review, triggered nestjs-4-4-caching-redis skill
AI   > Analyzing cache configuration and code...

Review Results:
- 🟥 TTL set to 86400 seconds (24 hours), may return stale data
- 🟥 UserController.update method does not clear user cache after update
- 🟩 CacheModule correctly configured with Redis store
- 🟩 Cache key uses user:${id} format, good uniqueness
- 🟩 CacheInterceptor only applied to GET endpoints

Summary: 2 issues need attention
User > Adjust TTL and add cache invalidation
AI   > TTL recommended to change to 3600 seconds, add @CacheEvict after update method. Apply?
User > Accept all
```

### Review Check Example

```markdown
AI > Entering review check, Review List contains 5 items, starting verification:

**Content Check**
  - 🟩 All review items reference official documentation
  - 🟩 TTL suggestions labeled as reference values

**Behavior Check**
  - 🟩 Did not directly modify user code
  - 🟩 Used AskUserQuestion

**Validation Check**
  - 🟩 Cache invalidation reported when write operations are clear
  - 🟩 Output summary is complete

✅ All passed, proceeding to output.
```

### Output Example

**Review Result Example:**

```markdown
| Dimension | Result |
| --- | --- |
| Reviewed File | src/app.module.ts, src/user/user.controller.ts |
| Total Review Items | 7 items |
| Passed | 5 items |
| Issues Found | 2 items |
| Risk Level | 🟡 Medium |
| Suggestions Adopted | 2 items |
```

## Review List

- **Content Check**
  - [ ] All review items reference NestJS and cache-manager official documentation
  - [ ] TTL value suggestions labeled as reference, not fixed values
- **Behavior Check**
  - [ ] Did not directly modify user code (unless explicitly requested by the user)
  - [ ] All interaction steps used AskUserQuestion
- **Validation Check**
  - [ ] Correctly terminated when target code is empty or unreadable
  - [ ] Cache invalidation reported when write operations are confirmed
  - [ ] Output summary includes file path, number of review items, issues found, and risk level

## References

- [NestJS Cache Official Documentation](https://docs.nestjs.com/techniques/caching)
- [cache-manager Documentation](https://github.com/node-cache-manager/node-cache-manager)
- [skill-evolve Template](../../skill-evolve/template.md)
