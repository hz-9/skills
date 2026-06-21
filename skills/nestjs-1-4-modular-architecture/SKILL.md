---
name: nestjs-1-4-modular-architecture
description: Review NestJS modular architecture design, including @Module configuration, module imports and exports, dynamic modules, and global module best practices. Use when users need to review module organization or design inter-module dependencies.
---

# NestJS Modular Architecture and Dynamic Modules

## Overview

When AI encounters module configuration-related code in a NestJS project, it automatically performs the following: review the completeness of @Module decorator configuration, check the reasonableness of module import/export relationships, evaluate whether the use cases for dynamic modules and global modules are appropriate, and provide improvement suggestions.

## Definitions

- <a id="target-code"></a>**Target Code**: The NestJS module class code (a class identified by the @Module decorator) or file path in the current conversation.
- <a id="module-metadata"></a>**Module Metadata**: The four properties of the @Module decorator — imports, controllers, providers, exports.
- <a id="dynamic-module"></a>**Dynamic Module**: A module that can be dynamically configured at runtime via static methods (forRoot, forFeature, register, etc.), created using the ConfigurableModuleBuilder pattern.
- <a id="global-module"></a>**Global Module**: A module marked with the @Global() decorator that automatically exposes its providers to all modules.
- <a id="analysis-complete"></a>**Analysis Complete**: Indicates whether the analysis of the target code has yielded complete results.

## Prerequisites

- NestJS project environment;
- Code files containing @Module declarations or module configuration accessible;
- Basic understanding of modular design principles.

## Workflow

0. **Pre-check** — Ensure the target code and runtime environment are accessible;
   - Determine if the target code exists and is readable:
     - Yes -> next step;
     - No -> prompt the user to provide target code or file path, block and wait for user input;
   - Initialize global variable [Analysis Complete](#analysis-complete):
     - Determine if the code is complete and parseable:
       - Satisfied -> initialize variable to true;
       - Not satisfied -> initialize variable to false;

1. **Analyze Module Code** — Read and understand module configuration and dependency relationships;
   - Read the target module code, identify the following core elements:
     - Configuration of the four @Module decorator properties (imports, controllers, providers, exports);
     - Whether @Global() global decorator is used;
     - Whether it is a dynamic module (static methods forRoot, register, forFeature);
     - Import/export relationship chains between modules;

2. **Itemized Review** — Check module configuration quality against the review checklist;
   - Determine whether each of the following review items passes:
     - Whether the modules imported in imports are all necessary (avoid importing unused modules that increase startup overhead):
       - Pass -> record as pass, continue to next review item;
       - Fail -> record "Unused modules imported, consider removing them", continue;
     - Whether exports includes all providers intended for use by other modules:
       - Pass -> record as pass, continue to next review item;
       - Fail -> record "Some providers are not exported, other modules cannot inject them", continue;
     - Whether @Global() usage is reasonable (avoid overusing global modules leading to implicit coupling):
       - Pass -> record as pass, continue to next review item;
       - Fail -> record "Consider using @Global() cautiously, consider importing a shared module instead", continue;
     - Whether dynamic modules follow correct naming conventions (forRoot for root module registration, forFeature for feature module registration, register for single registration):
       - Pass -> record as pass, continue to next review item;
       - Fail -> record "Dynamic module static method naming does not follow conventions", continue;
     - Whether circular module references exist (ModuleA imports ModuleB, ModuleB imports ModuleA):
       - Pass -> record as pass, continue to next review item;
       - Fail -> record "Circular module reference detected, consider using forwardRef()", continue;
     - Whether the module has a single responsibility (avoid a single module containing providers from multiple domains):
       - Pass -> record as pass, continue to next review item;
       - Fail -> record "Module responsibility is too broad, consider splitting into multiple domain modules", continue;
   - Determine if there are any issues recorded:
     - Yes -> summarize the issue list, proceed to next step;
     - No -> directly proceed to step 4 (Review Check);

3. **Provide Modification Suggestions** — Give specific fix solutions for identified issues;
   - For each issue, provide fix suggestions with positive and negative comparison examples;
   - Provide options via AskUserQuestion, block and wait for user selection:
     - Accept all suggestions -> generate corrected code, proceed to step 4;
     - Confirm one by one -> user decides to accept or ignore each item, proceed to step 4 after all confirmed;
     - Review only without modification -> do not affect code, directly proceed to step 4;

4. **Review Check** — Verify execution results against the [Review List](#review-list);
   - Determine if Review List has content:
     - No -> directly proceed to next step (Results Output);
     - Yes -> next step;
   - Check each item in [Review List](#review-list) sequentially to see if it passes:
     - Display output content based on the "Review Check Example";
   - If any check fails, terminate the flow;
   - After all pass, proceed to next step;

5. **Results Output** — Output the review summary and notify completion;
   - Output a structured summary table (Reviewed File / Total Review Items / Passed / Issues Found / Risk Level / Suggestions Accepted);
   - Notify that the review is complete;

## Rules

- **Content Standards**
  - description must follow the format: first sentence states what is reviewed, second sentence states trigger condition, use third person, no more than 1024 characters;
  - Review items must reference NestJS official documentation on module standards;
  - SKILL.md must not exceed 300 lines; split into references/ directory when exceeded;
  - Reference depth must not exceed one level;
  - Maintain consistent terminology; terms defined in Definitions must be referenced via anchor links in the body;
  - Remove any time-sensitive information;

- **Behavior Standards**
  - During review, only output issue summaries and locations; do not directly modify code unless the user explicitly requests it via AskUserQuestion;
  - All interaction steps involving code modification must use the AskUserQuestion tool;
  - Module responsibility split recommendations should be labeled as architectural suggestions rather than code defects;

- **Defensive Standards**
  - If the target code is empty or unreadable, directly report and terminate;
  - Dynamic module naming convention recommendations should be labeled as community conventions rather than official hard requirements;

- **Validation Standards**
  - Examples content must be consistent with Rules;
  - Examples must include a review check example;
  - Conversation interaction examples should only focus on steps 0~3 (excluding review check and results output);

## Examples

### Conversation Interaction Example

**Example: User requests module architecture design review**

```markdown
User > Could you check if there are any issues with this AppModule configuration?
AI   > Detected that user needs NestJS modular architecture review, triggering nestjs-1-4-modular-architecture skill
AI   > Analyzing module configuration...

Review Results:
- 🟩 imports includes DatabaseModule, AuthModule, UserModule
- 🟥 DatabaseModule uses @Global(), but only AuthModule and UserModule use it
- 🟩 exports correctly includes shared providers
- 🟥 UserModule both imports and provides EmailService (consider splitting into EmailModule)
- 🟩 No circular module references

Summary: 2 issues need attention
User > What are the specific suggestions?
AI   > 1. Remove @Global() from DatabaseModule; instead have AppModule explicitly export it
      2. Extract the consumers of EmailService into a standalone EmailModule
User > Let me just review for now, no need to modify yet
```

### Review Check Example

```markdown
AI > Entering review check. Review List contains 6 items, starting verification:

**Content Check**
  - 🟩 All review items reference official module standards
  - 🟩 Dynamic module conventions labeled as community conventions

**Behavior Check**
  - 🟩 Did not directly modify user code
  - 🟩 Used AskUserQuestion

**Validation Check**
  - 🟩 Module responsibility recommendations labeled as architectural suggestions
  - 🟩 Output summary is complete

✅ All passed, proceeding to results output.
```

### Results Output Example

**Review Results Example:**

```markdown
| Dimension | Result |
| --- | --- |
| Reviewed File | src/app.module.ts |
| Total Review Items | 8 |
| Passed | 6 |
| Issues Found | 2 |
| Risk Level | 🟡 Medium |
| Suggestions Accepted | 0 |
| Ignored / Review Only | 2 |
```

## Review List

- **Content Check**
  - [ ] All review items reference NestJS official module standards
  - [ ] Dynamic module naming conventions labeled as community conventions
- **Behavior Check**
  - [ ] Did not directly modify user code (unless explicitly requested by user)
  - [ ] All interaction steps used AskUserQuestion
- **Validation Check**
  - [ ] Correctly terminated when target code is empty or unreadable
  - [ ] Module responsibility split recommendations labeled as architectural suggestions rather than code defects
  - [ ] Output summary includes file path, review item count, issues found, and risk level

## References

- [NestJS Modules Official Documentation](https://docs.nestjs.com/modules)
- [NestJS Dynamic Modules](https://docs.nestjs.com/fundamentals/dynamic-modules)
- [NestJS Global Modules](https://docs.nestjs.com/modules#global-modules)
- [NestJS Circular Dependency](https://docs.nestjs.com/fundamentals/circular-dependency)
- [skill-evolve template](../../skill-evolve/template.md)
