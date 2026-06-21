---
name: nestjs-2-2-exception-filters
description: Review NestJS global and local exception filter implementations, ensuring the exception mapping layer follows hierarchical handling and unified response format. Use when users need to review exception handling logic or troubleshoot uncaught exceptions.
---

# NestJS Global and Local Exception Handling

## Overview

When AI encounters exception filter-related code in a NestJS project, it automatically performs the following: review the registration method of global and local exception filters, check the standard conformance of custom exception class definitions, evaluate the consistency of exception response formats, diagnose potential sources of uncaught exceptions, and provide improvement suggestions.

## Definitions

- <a id="target-code"></a>**Target Code**: The NestJS exception filter implementation code or exception class definition code in the current conversation.
- <a id="filter-level"></a>**Filter Level**: Three scopes of exception filters — global filter (app.useGlobalFilters), controller-level filter (@UseFilters), method-level filter (@UseFilters).
- <a id="HttpException"></a>**HttpException**: NestJS's built-in base exception class, containing HTTP status code and error message. All custom exceptions should inherit from this class.
- <a id="analysis-complete"></a>**Analysis Complete**: Indicates whether the analysis of the target code has yielded a complete result.

## Prerequisites

- NestJS project environment;
- Exception filter or exception class code files are accessible;
- Understanding of the exception filter's position in the NestJS request processing chain.

## Workflow

0. **Pre-check** — Ensure the target code and runtime environment are reachable;
   - Determine if the target code exists and is readable:
     - Yes -> next step;
     - No -> prompt the user to provide the target code or file path, block and wait for user input;
   - Initialize global variable [Analysis Complete](#analysis-complete):
     - Determine if the code is complete and parseable:
       - Satisfied -> initialize variable to true;
       - Not satisfied -> initialize variable to false;

1. **Analyze exception filter code** — Read and understand the filter implementation and exception hierarchy;
   - Read the target code, identify the following core elements:
     - Filter implementation approach (implementing ExceptionFilter interface or extending BaseExceptionFilter);
     - Filter registration level (global / controller / method);
     - Custom exception class definition (whether it inherits HttpException);
     - Response format structure (status code, message, timestamp, etc.);

2. **Item-by-item review** — Check exception handling code quality against the review checklist;
   - Sequentially evaluate whether each review item passes:
     - Do custom exception classes inherit HttpException (to maintain consistency with NestJS exception hierarchy):
       - Pass -> record as passed, continue to the next review item;
       - Fail -> record "Custom exceptions should inherit HttpException to leverage the built-in exception handling mechanism", continue;
     - Does the global filter have injected dependencies (global filters registered outside modules cannot use DI injection):
       - Pass -> record as passed, continue to the next review item;
       - Fail -> record "If the global filter needs DI injection, register it as a provider within a module", continue;
     - Does the exception filter catch specific exception types (rather than handling all exceptions uniformly, to avoid information loss):
       - Pass -> record as passed, continue to the next review item;
       - Fail -> record "Recommend using multiple filters or differentiated handling logic for different exception types", continue;
     - Is the response format consistent (are the structures returned by all filters aligned):
       - Pass -> record as passed, continue to the next review item;
       - Fail -> record "Response format is inconsistent, recommend defining a standard response interface", continue;
     - Are unexpected exceptions handled (is there a global filter as a fallback):
       - Pass -> record as passed, continue to the next review item;
       - Fail -> record "Missing global exception filter as fallback, unexpected exceptions may expose internal information", continue;
   - Determine if any issues were recorded:
     - Yes -> summarize the issue list, proceed to the next step;
     - No -> proceed directly to step 4 (Review Check);

3. **Provide modification suggestions** — Offer specific fix solutions for the identified issues;
   - Provide fix suggestions for each issue in order;
   - Present options via AskUserQuestion, block and wait for user selection:
     - Accept all suggestions -> generate corrected code, proceed to step 4;
     - Confirm one by one -> user decides to accept or ignore each item, proceed to step 4 after all confirmed;
     - View only, no modification -> do not affect the code, proceed directly to step 4;

4. **Review Check** — Verify execution results against [Review List](#review-list);
   - Determine if Review List has content:
     - No -> proceed directly to the next step (Output Results);
     - Yes -> next step;
   - Sequentially check each item in [Review List](#review-list) to see if it passes:
     - Display output based on the "Review Check Example";
   - If any check fails, terminate the process;
   - If all pass, proceed to the next step;

5. **Output Results** — Output the review summary, notify completion;
   - Output a structured summary table (Review File / Total Items / Passed / Issues Found / Risk Level / Suggestions Accepted);
   - Notify that the review is complete;

## Rules

- **Content Standards**
  - description must follow the format: first sentence describes the review content, second sentence describes the trigger condition, use third person, no more than 1024 characters;
  - Review items must reference NestJS official documentation on exception filters;
  - SKILL.md must not exceed 300 lines; split into references/ directory when exceeded;
  - Reference depth must not exceed one level;
  - Maintain terminology consistency, terms defined in Definitions must be referenced via anchor links in the body;
  - Remove any time-sensitive information;

- **Behavior Standards**
  - During review, only output issue summaries and locations, do not directly modify code unless the user explicitly requests it via AskUserQuestion;
  - All interaction steps involving code modification must use the AskUserQuestion tool;
  - Response format consistency suggestions should be marked as suggestions, not mandatory;

- **Defensive Standards**
  - If the target code is empty or unreadable, report directly and terminate;
  - DI injection issues should only be reported when the registration method can be confirmed; when uncertain, mark as requiring manual confirmation;

- **Validation Standards**
  - Examples content must be self-consistent with Rules;
  - Examples must include a review check example;
  - Dialogue interaction examples should only focus on steps 0~3 (excluding review check and output results);

## Examples

### Dialogue Interaction Example

**Example: User requests exception filter configuration review**

```markdown
User > Please check if the project's exception handling is complete
AI   > Detected user needs NestJS exception filter review, triggering nestjs-2-2-exception-filters skill
AI   > Analyzing exception handling code...

Review Results:
- 🟩 Custom exception class XxxException inherits from HttpException
- 🟥 Global filter uses app.useGlobalFilters() in main.ts, but needs to inject Logger service
- 🟩 Controller-level filter precisely catches specific exception types
- 🟥 Response formats differ between filters (some include timestamp, some don't)
- 🟩 Global exception filter exists as a fallback

Summary: 2 issues need attention
User > Please fix the global filter's injection issue
AI   > Recommend registering the global filter as a provider in AppModule. Apply the change?
User > Yes
```

### Review Check Example

```markdown
AI > Entering review check, Review List contains 5 items, starting item-by-item verification:

**Content Check**
  - 🟩 All review items reference official exception filter documentation
  - 🟩 Response format suggestions are marked as suggestions

**Behavior Check**
  - 🟩 Did not directly modify user code
  - 🟩 Used AskUserQuestion

**Validation Check**
  - 🟩 DI injection marked as pending confirmation when uncertain
  - 🟩 Output summary is complete

✅ All passed, proceeding to output results.
```

### Output Results Example

**Review Results Example:**

```markdown
| Dimension | Result |
| --- | --- |
| Review File | src/common/filters/http-exception.filter.ts |
| Total Items | 7 items |
| Passed | 5 items |
| Issues Found | 2 items |
| Risk Level | 🟡 Medium |
| Suggestions Accepted | 1 suggestion |
| Ignored / View Only | 1 item |
```

## Review List

- **Content Check**
  - [ ] All review items reference NestJS official exception filter documentation
  - [ ] Response format consistency suggestions are marked as suggestions, not mandatory
- **Behavior Check**
  - [ ] Did not directly modify user code (unless explicitly requested by the user)
  - [ ] All interaction steps used AskUserQuestion
- **Validation Check**
  - [ ] Correctly terminated when target code is empty or unreadable
  - [ ] DI injection is marked as requiring manual confirmation when uncertain
  - [ ] Output summary includes file path, number of items, issues found, and risk level

## References

- [NestJS Exception Filters Official Documentation](https://docs.nestjs.com/exception-filters)
- [NestJS Built-in HTTP Exceptions](https://docs.nestjs.com/exception-filters#built-in-http-exceptions)
- [skill-evolve 模板](../../skill-evolve/template.md)
