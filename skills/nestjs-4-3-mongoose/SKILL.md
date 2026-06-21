---
name: nestjs-4-3-mongoose
description: Review NestJS Mongoose/MongoDB integration practices, covering Schema definition, model registration, virtual fields, and aggregation pipelines. Use when users need to review Mongoose integration or develop MongoDB data layer.
---

# NestJS Non-Relational Database Application (Mongoose)

## Overview

When AI encounters Mongoose related code in a NestJS project, it automatically performs the following: review the correctness of Schema definitions and model registration, check Mongoose module configuration, evaluate the use of virtual properties and middleware hooks, identify common query and indexing issues, and provide improvement suggestions.

## Definitions

- <a id="target-code"></a>**Target code**: The NestJS Mongoose Schema definition, model injection, or database operation code in the current conversation.
- <a id="mongoose-schema"></a>**Mongoose Schema**: A MongoDB document structure defined with the @Schema decorator, containing field types, validation rules, and indexes.
- <a id="model-injection"></a>**Model injection**: The approach of injecting specific Mongoose model instances into services via the @InjectModel decorator.
- <a id="analysis-complete"></a>**Analysis complete**: Indicates whether the analysis of the target code has been fully completed.

## Prerequisites

- NestJS project environment (including @nestjs/mongoose, mongoose dependencies);
- Mongoose Schema definitions or model operation code accessible;
- Understanding of MongoDB and Mongoose basic concepts.

## Workflow

0. **Pre-check** — Ensure the target code and runtime environment are reachable;
   - Determine if the target code exists and is readable:
     - Yes -> next step;
     - No -> prompt the user to provide the target code or file path, block and wait for user input;
   - Initialize global variable [analysis complete](#analysis-complete):
     - Determine if the code is fully parseable:
       - Satisfied -> initialize variable to true;
       - Not satisfied -> initialize variable to false;

1. **Analyze Mongoose code** — Read and understand Schema definitions and database operations;
   - Read the target code, identify the following core elements:
     - @Schema decorator configuration (timestamps, collection, validateBeforeSave, etc.);
     - Schema field type definitions and validation decorators (@Prop);
     - @InjectModel usage for model injection in services;
     - MongooseModule configuration (forRoot / forFeature);
     - Query methods (find, aggregate, populate, etc.);

2. **Review items** — Check Mongoose code quality against the review checklist;
   - Iterate through the following review items to determine if they pass:
     - Whether the Schema has timestamps enabled (auto-manage createdAt / updatedAt):
       - Pass -> record as passed, continue to next review item;
       - Fail -> record "Recommend enabling timestamps: true to auto-manage timestamp fields", continue;
     - Whether frequently queried fields have database indexes added (@Prop({ index: true })):
       - Pass -> record as passed, continue to next review item;
       - Fail -> record "Frequently queried fields lack indexes, may cause query performance issues", continue;
     - Whether type definitions in @Prop use Mongoose types (e.g., Schema.Types.ObjectId for references):
       - Pass -> record as passed, continue to next review item;
       - Fail -> record "Reference field type definitions are inaccurate, recommend using ref and type to specify relationships", continue;
     - Whether virtual properties (Virtual) are used for computed fields rather than storing in the database:
       - Pass -> record as passed, continue to next review item;
       - Fail -> record "Can use virtual properties in Schema instead of storing redundant data", continue;
     - Whether the aggregation pipeline includes a $match stage as the first step (to reduce processed documents):
       - Pass -> record as passed, continue to next review item;
       - Fail -> record "Recommend using $match as the first stage of the aggregation pipeline to reduce processing volume", continue;
     - Whether MongooseModule.forFeature correctly imports the corresponding Schema:
       - Pass -> record as passed, continue to next review item;
       - Fail -> record "Model not registered in forFeature, cannot be injected in services", continue;
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
  - Review items must reference Mongoose and NestJS official documentation;
  - SKILL.md no more than 300 lines; split to references/ directory when exceeded;
  - Reference hierarchy no more than one level;
  - Maintain terminology consistency, terms defined in Definitions must be referenced via anchor links in the body;
  - Remove any time-sensitive information;

- **Behavior rules**
  - Only output issue summaries and locations during review, do not directly modify code unless the user explicitly requests via AskUserQuestion;
  - All interaction steps involving code modification must use the AskUserQuestion tool;
  - Index and virtual property suggestions should be labeled as recommendations, not mandatory;

- **Defensive rules**
  - If target code is empty or unreadable, report directly and terminate;
  - Aggregation pipeline optimization suggestions should only be provided when the pipeline stage sequence is clear;

- **Validation rules**
  - Examples content must be self-consistent with Rules;
  - Examples must include a review check example;
  - Dialogue interaction examples should only focus on steps 0~3 (excluding review check and output);

## Examples

### Dialogue Interaction Example

**Example: User requests Mongoose Schema definition review**

```markdown
User > Help me check this Mongoose Schema configuration
AI   > Detected user needs NestJS Mongoose review, triggered nestjs-4-3-mongoose skill
AI   > Analyzing Schema and model code...

Review Results:
- 🟥 @Schema does not have timestamps enabled, missing auto timestamp management
- 🟩 @Prop field type definitions are correct
- 🟥 email field is frequently queried but lacks an index
- 🟩 Aggregation pipeline correctly uses $match as first step
- 🟩 MongooseModule.forFeature has registered the corresponding Schema

Summary: 2 issues need attention
User > Help me add timestamps and indexes
AI   > Modify @Schema({ timestamps: true }) and @Prop({ index: true, unique: true }). Apply?
User > Accept all
```

### Review Check Example

```markdown
AI > Entering review check, Review List contains 5 items, starting verification:

**Content Check**
  - 🟩 All review items reference official documentation
  - 🟩 Index suggestions labeled as recommendations

**Behavior Check**
  - 🟩 Did not directly modify user code
  - 🟩 Used AskUserQuestion

**Validation Check**
  - 🟩 Aggregation suggestions provided when pipeline is clear
  - 🟩 Output summary is complete

✅ All passed, proceeding to output.
```

### Output Example

**Review Result Example:**

```markdown
| Dimension | Result |
| --- | --- |
| Reviewed File | src/user/schemas/user.schema.ts |
| Total Review Items | 7 items |
| Passed | 5 items |
| Issues Found | 2 items |
| Risk Level | 🟡 Medium |
| Suggestions Adopted | 2 items |
```

## Review List

- **Content Check**
  - [ ] All review items reference Mongoose and NestJS official documentation
  - [ ] Index and virtual property suggestions labeled as recommendations, not mandatory
- **Behavior Check**
  - [ ] Did not directly modify user code (unless explicitly requested by the user)
  - [ ] All interaction steps used AskUserQuestion
- **Validation Check**
  - [ ] Correctly terminated when target code is empty or unreadable
  - [ ] Aggregation pipeline optimization provided when stage sequence is clear
  - [ ] Output summary includes file path, number of review items, issues found, and risk level

## References

- [NestJS Mongoose Integration Documentation](https://docs.nestjs.com/techniques/mongodb)
- [Mongoose Official Documentation](https://mongoosejs.com/)
- [skill-evolve Template](../../skill-evolve/template.md)
