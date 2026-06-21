---
name: nestjs-4-1-typeorm
description: Review NestJS TypeORM integration practices, covering entity definition, repository pattern, transaction management, and migration strategies. Use when users need to review TypeORM related code or troubleshoot database issues.
---

# NestJS Relational Database Integration (TypeORM)

## Overview

When AI encounters TypeORM related code in a NestJS project, it automatically performs the following: review the correctness of entity definitions and completeness of relationship mappings, check TypeORM module configuration and repository pattern usage, evaluate the reliability of transaction management, identify common database performance issues, and provide improvement suggestions.

## Definitions

- <a id="target-code"></a>**Target code**: The NestJS TypeORM entity classes, module configuration, or database operation code in the current conversation.
- <a id="entity-relationship"></a>**Entity relationship**: The @OneToOne, @OneToMany, @ManyToOne, @ManyToMany relationship decorators between entities in TypeORM.
- <a id="repository-pattern"></a>**Repository pattern**: The approach of injecting EntityRepository or Repository instances via @InjectRepository.
- <a id="analysis-complete"></a>**Analysis complete**: Indicates whether the analysis of the target code has been fully completed.

## Prerequisites

- NestJS project environment (including @nestjs/typeorm and typeorm dependencies);
- Entity, module, or database operation code files accessible;
- Understanding of relational databases and ORM basic concepts.

## Workflow

0. **Pre-check** — Ensure the target code and runtime environment are reachable;
   - Determine if the target code exists and is readable:
     - Yes -> next step;
     - No -> prompt the user to provide the target code or file path, block and wait for user input;
   - Initialize global variable [analysis complete](#analysis-complete):
     - Determine if the code is fully parseable:
       - Satisfied -> initialize variable to true;
       - Not satisfied -> initialize variable to false;

1. **Analyze TypeORM code** — Read and understand entity definitions and database operations;
   - Read the target code, identify the following core elements:
     - Entity @Entity decorator and column decorators (@Column, @PrimaryGeneratedColumn, etc.);
     - Relationship mapping decorator configuration (@OneToMany, @ManyToOne, etc.);
     - TypeORM module configuration (TypeOrmModule.forRoot / forFeature);
     - Database operation methods in services (find, save, query builder, etc.);

2. **Review items** — Check TypeORM code quality against the review checklist;
   - Iterate through the following review items to determine if they pass:
     - Whether entities use the @Entity decorator with a correct table name:
       - Pass -> record as passed, continue to next review item;
       - Fail -> record "Entity missing @Entity decorator or table name is unclear", continue;
     - Whether relationship mappings are correctly configured on both sides (bidirectional relations need decorators on both sides):
       - Pass -> record as passed, continue to next review item;
       - Fail -> record "Unidirectional relationship may cause inefficient queries, recommend configuring bidirectional relationships", continue;
     - Whether queries use select to limit returned fields (avoid SELECT * full table queries):
       - Pass -> record as passed, continue to next review item;
       - Fail -> record "Recommend using select to specify returned fields to reduce data transfer", continue;
     - Whether transaction handling uses @Transaction or QueryRunner to ensure atomicity:
       - Pass -> record as passed, continue to next review item;
       - Fail -> record "Multi-step database operations not using transactions may cause data inconsistency", continue;
     - Whether TypeOrmModule.forRoot() configuration is correct (database type, host, credentials, etc.):
       - Pass -> record as passed, continue to next review item;
       - Fail -> record "Database configuration is incomplete or uses a non-recommended approach", continue;
     - Whether migration configuration is correct (migrationsRun, migrations table name, etc.):
       - Pass -> record as passed, continue to next review item;
       - Fail -> record "Migration configuration is incomplete, may cause inconsistent table structures in production", continue;
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
  - Review items must reference TypeORM and NestJS official documentation;
  - SKILL.md no more than 300 lines; split to references/ directory when exceeded;
  - Reference hierarchy no more than one level;
  - Maintain terminology consistency, terms defined in Definitions must be referenced via anchor links in the body;
  - Remove any time-sensitive information;

- **Behavior rules**
  - Only output issue summaries and locations during review, do not directly modify code unless the user explicitly requests via AskUserQuestion;
  - All interaction steps involving code modification must use the AskUserQuestion tool;
  - Relationship design and query optimization suggestions should be labeled as architectural suggestions, not code defects;

- **Defensive rules**
  - If target code is empty or unreadable, report directly and terminate;
  - Transaction necessity should only be reported when multi-step operations are explicit, single-step operations do not require transactions;

- **Validation rules**
  - Examples content must be self-consistent with Rules;
  - Examples must include a review check example;
  - Dialogue interaction examples should only focus on steps 0~3 (excluding review check and output);

## Examples

### Dialogue Interaction Example

**Example: User requests TypeORM entity and query review**

```markdown
User > Help me check this User entity and query code
AI   > Detected user needs NestJS TypeORM review, triggered nestjs-4-1-typeorm skill
AI   > Analyzing entity and database code...

Review Results:
- 🟩 @Entity('users') table name is semantic
- 🟥 User and Profile relationship only configured as unidirectional @OneToOne
- 🟥 findAll method uses find() without specifying select, selecting all columns
- 🟩 createUser uses save method, operation is safe
- 🟩 TypeOrmModule configuration includes migration settings

Summary: 2 issues need attention
User > Help me optimize the query
AI   > Can add select: ['id', 'name', 'email'] in find(). Apply?
User > Yes
```

### Review Check Example

```markdown
AI > Entering review check, Review List contains 5 items, starting verification:

**Content Check**
  - 🟩 All review items reference official documentation
  - 🟩 Relationship suggestions labeled as architectural suggestions

**Behavior Check**
  - 🟩 Did not directly modify user code
  - 🟩 Used AskUserQuestion

**Validation Check**
  - 🟩 Transactions only required for multi-step operations
  - 🟩 Output summary is complete

✅ All passed, proceeding to output.
```

### Output Example

**Review Result Example:**

```markdown
| Dimension | Result |
| --- | --- |
| Reviewed File | src/user/entities/user.entity.ts |
| Total Review Items | 7 items |
| Passed | 5 items |
| Issues Found | 2 items |
| Risk Level | 🟡 Medium |
| Suggestions Adopted | 1 item |
| Ignored/Reviewed Only | 1 item |
```

## Review List

- **Content Check**
  - [ ] All review items reference TypeORM and NestJS official documentation
  - [ ] Relationship design suggestions labeled as architectural suggestions, not code defects
- **Behavior Check**
  - [ ] Did not directly modify user code (unless explicitly requested by the user)
  - [ ] All interaction steps used AskUserQuestion
- **Validation Check**
  - [ ] Correctly terminated when target code is empty or unreadable
  - [ ] Transactions only required for multi-step operations
  - [ ] Output summary includes file path, number of review items, issues found, and risk level

## References

- [NestJS TypeORM Integration Documentation](https://docs.nestjs.com/techniques/database)
- [TypeORM Official Documentation](https://typeorm.io/)
- [skill-evolve Template](../../skill-evolve/template.md)
