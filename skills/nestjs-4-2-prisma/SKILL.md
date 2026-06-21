---
name: nestjs-4-2-prisma
description: Review NestJS Prisma ORM integration practices, covering Schema design, PrismaClient management, migration and query optimization. Use when users need to review Prisma integration code or optimize database queries.
---

# NestJS Prisma ORM Practices

## Overview

When AI encounters Prisma related code in a NestJS project, it automatically performs the following: review the standardization of Prisma Schema design, check PrismaClient instance management and module injection approach, evaluate query optimization strategies, identify common Prisma integration pitfalls, and provide improvement suggestions.

## Definitions

- <a id="target-code"></a>**Target code**: The NestJS project's Prisma Schema file, PrismaService, or database operation code in the current conversation.
- <a id="PrismaService"></a>**PrismaService**: A wrapper service for PrismaClient in NestJS, typically extending PrismaClient and implementing the OnModuleInit lifecycle hook.
- <a id="schema-definition"></a>**Schema definition**: The datasource, generator, model, and enum defined in the prisma/schema.prisma file.
- <a id="analysis-complete"></a>**Analysis complete**: Indicates whether the analysis of the target code has been fully completed.

## Prerequisites

- NestJS project environment (including @prisma/client and prisma dependencies);
- Prisma Schema or service code files accessible;
- Understanding of Prisma ORM basic concepts (schema, migration, queries).

## Workflow

0. **Pre-check** — Ensure the target code and runtime environment are reachable;
   - Determine if the target code exists and is readable:
     - Yes -> next step;
     - No -> prompt the user to provide the target code or file path, block and wait for user input;
   - Initialize global variable [analysis complete](#analysis-complete):
     - Determine if the code is fully parseable:
       - Satisfied -> initialize variable to true;
       - Not satisfied -> initialize variable to false;

1. **Analyze Prisma code** — Read and understand Schema definition and database operations;
   - Read the target code, identify the following core elements:
     - Model definitions and relation declarations in Prisma Schema;
     - PrismaService implementation approach (extending PrismaClient + onModuleInit);
     - Prisma query methods in services (findMany, create, update, etc.);
     - PrismaService providing and exporting approach in PrismaModule;

2. **Review items** — Check Prisma code quality against the review checklist;
   - Iterate through the following review items to determine if they pass:
     - Whether PrismaService correctly implements the OnModuleInit lifecycle hook (connection management):
       - Pass -> record as passed, continue to next review item;
       - Fail -> record "PrismaService does not implement onModuleInit, database connection may not be established before first use", continue;
     - Whether PrismaService is provided as a global singleton (avoid creating multiple PrismaClient instances):
       - Pass -> record as passed, continue to next review item;
       - Fail -> record "PrismaService should be set as a global singleton to reuse database connections", continue;
     - Whether the @relation in Schema model relationships has onDelete cascade behavior configured:
       - Pass -> record as passed, continue to next review item;
       - Fail -> record "Relationship missing onDelete cascade configuration, may cause foreign key constraint errors", continue;
     - Whether queries use select or include to limit returned data (avoid returning the entire object graph):
       - Pass -> record as passed, continue to next review item;
       - Fail -> record "Recommend using select to specify returned fields to reduce data volume", continue;
     - Whether there is N+1 query risk (querying the database one by one in a loop):
       - Pass -> record as passed, continue to next review item;
       - Fail -> record "Detected potential N+1 query issue, recommend using include preloading or batch queries", continue;
     - Whether Prisma migration configuration is correct (whether using prisma migrate):
       - Pass -> record as passed, continue to next review item;
       - Fail -> record "Migration strategy is unclear, recommend using prisma migrate to manage Schema changes", continue;
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
  - Review items must reference Prisma and NestJS official documentation;
  - SKILL.md no more than 300 lines; split to references/ directory when exceeded;
  - Reference hierarchy no more than one level;
  - Maintain terminology consistency, terms defined in Definitions must be referenced via anchor links in the body;
  - Remove any time-sensitive information;

- **Behavior rules**
  - Only output issue summaries and locations during review, do not directly modify code unless the user explicitly requests via AskUserQuestion;
  - All interaction steps involving code modification must use the AskUserQuestion tool;
  - Query optimization suggestions (select, include) should be labeled as recommendations, not mandatory;

- **Defensive rules**
  - If target code is empty or unreadable, report directly and terminate;
  - N+1 queries should only be reported when loop queries are clearly visible, dynamic queries should be labeled as requiring manual confirmation;

- **Validation rules**
  - Examples content must be self-consistent with Rules;
  - Examples must include a review check example;
  - Dialogue interaction examples should only focus on steps 0~3 (excluding review check and output);

## Examples

### Dialogue Interaction Example

**Example: User requests Prisma Schema and query review**

```markdown
User > Help me check if there are issues with the Prisma integration
AI   > Detected user needs NestJS Prisma review, triggered nestjs-4-2-prisma skill
AI   > Analyzing Prisma code...

Review Results:
- 🟩 PrismaService implements onModuleInit to establish connection
- 🟩 PrismaService set as global module in PrismaModule
- 🟥 User and Post relationship missing onDelete: Cascade
- 🟥 getUserPosts method queries one by one in a loop, N+1 risk
- 🟩 Schema model definitions are complete

Summary: 2 issues need attention
User > Help me fix the N+1 query
AI   > Can use include: { posts: true } to load related data at once. Apply?
User > Yes
```

### Review Check Example

```markdown
AI > Entering review check, Review List contains 6 items, starting verification:

**Content Check**
  - 🟩 All review items reference official documentation
  - 🟩 Query suggestions labeled as recommendations

**Behavior Check**
  - 🟩 Did not directly modify user code
  - 🟩 Used AskUserQuestion

**Validation Check**
  - 🟩 N+1 reported when clearly visible
  - 🟩 Output summary is complete

✅ All passed, proceeding to output.
```

### Output Example

**Review Result Example:**

```markdown
| Dimension | Result |
| --- | --- |
| Reviewed File | prisma/schema.prisma, src/prisma/prisma.service.ts |
| Total Review Items | 7 items |
| Passed | 5 items |
| Issues Found | 2 items |
| Risk Level | 🟡 Medium |
| Suggestions Adopted | 1 item |
| Ignored/Reviewed Only | 1 item |
```

## Review List

- **Content Check**
  - [ ] All review items reference Prisma and NestJS official documentation
  - [ ] Query optimization suggestions labeled as recommendations, not mandatory
- **Behavior Check**
  - [ ] Did not directly modify user code (unless explicitly requested by the user)
  - [ ] All interaction steps used AskUserQuestion
- **Validation Check**
  - [ ] Correctly terminated when target code is empty or unreadable
  - [ ] N+1 queries only reported when clearly visible
  - [ ] Output summary includes file path, number of review items, issues found, and risk level

## References

- [NestJS Prisma Integration Documentation](https://docs.nestjs.com/recipes/prisma)
- [Prisma Official Documentation](https://www.prisma.io/docs)
- [skill-evolve Template](../../skill-evolve/template.md)
