---
name: nestjs-1-1-cli-scaffolding
description: Review NestJS CLI scaffolding configuration and project lifecycle management, ensuring project structure follows official conventions. Use when users need to review project initialization structure, nest-cli.json configuration, or package.json scripts.
---

# NestJS CLI Scaffolding & Project Lifecycle

## Overview

When AI encounters CLI configuration or project structure related code in a NestJS project, it automatically performs the following: review project initialization structure against official conventions, verify nest-cli.json and tsconfig configuration completeness, check lifecycle hook usage, and provide improvement suggestions.

## Definitions

- <a id="target-code"></a>**Target Code**: The NestJS project's CLI configuration files (nest-cli.json, tsconfig.json, tsconfig.build.json) or class code declaring lifecycle hooks in the current conversation.
- <a id="scaffold-config"></a>**Scaffold Configuration**: Project structure created by `nest new` or maintained manually, including src/ directory layout, nest-cli.json compiler options, package.json scripts, etc.
- <a id="lifecycle-hooks"></a>**Lifecycle Hooks**: The five interface methods of NestJS components: onModuleInit, onApplicationBootstrap, onModuleDestroy, beforeApplicationShutdown, onApplicationShutdown.
- <a id="analysis-complete"></a>**Analysis Complete**: Flag indicating whether the analysis of target code has produced complete results.

## Prerequisites

- NestJS project directory (package.json containing @nestjs/core dependency);
- Target configuration files or code with lifecycle hooks accessible;
- Understanding of basic NestJS CLI commands (nest new, nest generate, etc.).

## Workflow

0. **Pre-check** — Ensure target code and runtime environment are accessible;
   - Check if target code exists and is readable:
     - Yes -> Next step;
     - No -> Prompt user to provide target code or file path, block waiting for user input;
   - Initialize global variable [Analysis Complete](#analysis-complete):
     - Check if code is fully parseable:
       - Satisfied -> Initialize variable to true;
       - Not satisfied -> Initialize variable to false;

1. **Analyze project configuration** — Read CLI configuration and project structure;
   - Read the following configuration files in the project (if accessible):
     - `nest-cli.json` — Check compilerOptions, entryFile, sourceRoot fields;
     - `tsconfig.json` / `tsconfig.build.json` — Check strict mode, decorator support, etc.;
     - `package.json` — Check scripts (build, start, start:dev) and dependency versions;
   - Identify core files under src/: main.ts, app.module.ts, app.controller.ts, app.service.ts;

2. **Review scaffold configuration quality** — Check configuration against official conventions;
   - Iterate through the following review items sequentially:
     - Does nest-cli.json have deleteOutDir configured in compilerOptions:
       - Pass -> Record pass, proceed to next item;
       - Fail -> Record "Missing deleteOutDir, may leave stale files in output directory";
     - Is TypeScript strict mode enabled:
       - Pass -> Record pass, proceed to next item;
       - Fail -> Record "Recommended to enable strict mode for better type safety";
     - Does the build script in package.json use nest build:
       - Pass -> Record pass, proceed to next item;
       - Fail -> Record "Build script missing nest build, may cause build inconsistency";
     - Does src/ directory structure follow official conventions (main.ts + app.module.ts):
       - Pass -> Record pass, proceed to next item;
       - Fail -> Record "src/ structure deviates from official conventions, may affect nest generate";

3. **Review lifecycle hook usage** — Check lifecycle interface implementations;
   - Check if target code contains lifecycle hooks:
     - Yes -> Read and analyze hook implementation;
     - No -> Skip this step, proceed to next step;
   - Iterate review items:
     - Are async operations (e.g., DB connections) in onModuleInit justified:
       - Pass -> Record pass;
       - Fail -> Record "Recommend moving async initialization to onApplicationBootstrap";
     - Is resource cleanup properly handled in onModuleDestroy:
       - Pass -> Record pass;
       - Fail -> Record "Missing onModuleDestroy cleanup logic, may cause resource leaks";
   - Check if any issues were recorded:
     - Yes -> Summarize issue list, go to next step;
     - No -> Directly go to step 5 (Review Check);

4. **Provide improvement suggestions** — Give specific fixes for found issues;
   - Provide fix suggestions for each issue;
   - Use AskUserQuestion to provide options, block waiting for user selection:
     - Apply all suggestions -> Generate corrected config or code, go to step 5;
     - Confirm one by one -> User decides per suggestion, then go to step 5;
     - View only without changes -> Do not modify code, go to step 5;

5. **Review Check** — Verify against [Review List](#review-list);
   - Check if Review List has content:
     - No -> Proceed to next step (Output);
     - Yes -> Next step;
   - Iterate through each item in [Review List](#review-list), check pass/fail:
     - Display output based on "Review Check Example";
   - Any failure terminates the flow;
   - All pass, proceed to next step;

6. **Output** — Output review summary, notify completion;
   - Output structured summary table (Reviewed Files / Total Items / Passed / Issues Found / Risk Level / Adopted Suggestions);
   - Notify review completion;

## Rules

- **Content Standards**
  - description must follow format: first sentence describes review scope, second sentence describes trigger condition ("Use when..."), uses third person,不超过 1024 characters;
  - Review items must reference NestJS official documentation or community best practices;
  - SKILL.md不超过 300 lines; split to references/ when exceeded;
  - Reference hierarchy不超过 one level;
  - Maintain consistent terminology, link terms defined in Definitions via anchor references;
  - Remove any time-sensitive information;

- **Behavior Standards**
  - Only output issue summary and location when reviewing, do not modify code unless user explicitly requests via AskUserQuestion;
  - All code modification interactions must use AskUserQuestion tool;
  - Anti-pattern judgments should provide positive vs negative examples;

- **Defense Standards**
  - If target code is empty or unreadable, report and terminate immediately;
  - Version compatibility issues should be marked with risk level in the report;

- **Verification Standards**
  - Examples must be self-consistent with Rules;
  - Examples must include a Review Check example;
  - Conversation examples should only focus on steps 0~4;

## Examples

### Conversation Example

**Example: User requests project configuration review**

```markdown
User > Check my nest-cli.json and project structure
AI   > Detected NestJS CLI scaffolding review request, triggering nestjs-1-1-cli-scaffolding
AI   > Analyzing project configuration...

nest-cli.json:
  - ✅ compilerOptions.deleteOutDir configured
  - ✅ sourceRoot points to src/

tsconfig.json:
  - ❌ strict not enabled (recommended)
  - ✅ experimentalDecorators configured

package.json:
  - ✅ build script uses nest build
  - ❌ start:dev missing --watch flag

src/ directory:
  - ✅ Contains main.ts and app.module.ts

Summary: 2 issues found. Need fix suggestions?
User > Yes, give me recommendations
AI   > 1. strict mode: add "strict": true to tsconfig compilerOptions
      2. start:dev: change to "nest start --watch"
      Apply these changes?
User > View only, no changes
```

### Review Check Example

```markdown
AI > Running review check, 6 items in Review List:

**Content Check**
  - ✅ All review items reference official conventions
  - ✅ Positive/negative comparisons provided

**Behavior Check**
  - ✅ No direct code modification
  - ✅ AskUserQuestion used for interactions

**Verification Check**
  - ✅ Target code readability verified
  - ❌ Compatibility issues not marked with risk level

**!!! FAILED ITEMS !!!**
  - ❌ Compatibility issues not marked with risk level

Flow terminated, manual review recommended.
```

### Output Example

```markdown
| Dimension | Result |
| --- | --- |
| Reviewed Files | nest-cli.json, tsconfig.json, package.json |
| Total Items | 10 |
| Passed | 8 |
| Issues Found | 2 |
| Risk Level | 🟡 Medium |
| Adopted Suggestions | 0 |
| View Only | 2 |
```

## Review List

- **Content Check**
  - [ ] All review items reference NestJS official conventions or best practices
  - [ ] Anti-patterns provided with positive/negative comparison
- **Behavior Check**
  - [ ] No direct code modification (unless user explicitly requests)
  - [ ] All interactions used AskUserQuestion
- **Verification Check**
  - [ ] Empty/unreadable target code properly terminated
  - [ ] Compatibility issues marked with risk level
  - [ ] Output summary includes file paths, item counts, issues found, and risk level

## References

- [NestJS CLI Documentation](https://docs.nestjs.com/cli/overview)
- [NestJS Project Structure](https://docs.nestjs.com/first-steps)
- [NestJS Lifecycle Events](https://docs.nestjs.com/fundamentals/lifecycle-events)
- [skill-evolve Template](../../skill-evolve/template.md)
