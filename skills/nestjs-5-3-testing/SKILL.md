---
name: nestjs-5-3-testing
description: Review NestJS automated testing practices, covering unit tests, integration tests, Test.createTestingModule, and E2E tests. Use this when users need to review test code or optimize test coverage.
---

# NestJS Automated Testing

## Overview

When AI encounters test-related code in a NestJS project, it automatically performs the following: review test module configuration and test case structure, check the coverage completeness of unit tests and E2E tests, evaluate Mock strategies and test isolation, and provide improvement suggestions.

## Definitions

- <a id="target-code"></a>**Target Code**: The test code (.spec.ts or .e2e-spec.ts files) from the NestJS project in the current conversation.
- <a id="testmodule"></a>**TestModule**: A testing module created by @nestjs/testing's Test.createTestingModule, used to simulate NestJS's DI container.
- <a id="e2e-test"></a>**E2E Test**: End-to-end testing that creates HTTP clients using supertest to test complete request/response chains.
- <a id="analysis-complete"></a>**Analysis Complete**: A flag indicating whether the analysis of the target code has reached a complete result.

## Prerequisites

- NestJS project environment (including @nestjs/testing, jest, supertest dependencies);
- Test specification files accessible;
- Understanding of Jest testing framework and test layering principles.

## Workflow

0. **Pre-check** — Ensure target code and runtime environment are reachable;
   - Determine if target code exists and is readable:
     - Yes -> Next step;
     - No -> Prompt user to provide target code or file path, block and wait for user input;
   - Initialize global variable [Analysis Complete](#analysis-complete):
     - Determine if the code is fully parsable:
       - Satisfied -> Initialize variable to true;
       - Not satisfied -> Initialize variable to false;

1. **Analyze test code** — Read and understand test structure and strategy;
   - Read target code, identify the following core elements:
     - Test.createTestingModule compilation configuration and imported modules;
     - Mock strategies in unit tests (jest.mock, useValue custom providers);
     - Test case naming conventions and structure (describe / it nesting);
     - App creation and supertest usage in E2E tests;
     - Test coverage of edge cases (happy path, error path, boundary values);

2. **Item-by-item review** — Check test code quality against the review checklist;
   - Determine whether each review item passes in sequence:
     - Does the test use Test.createTestingModule rather than direct instantiation (leveraging DI container):
       - Pass -> Record as pass, continue to next item;
       - Fail -> Record "Recommend using Test.createTestingModule to build test module", continue;
     - Are external dependencies (database, HTTP services) replaced by Mocks (avoiding test dependency on external services):
       - Pass -> Record as pass, continue to next item;
       - Fail -> Record "External dependencies are not Mocked, tests may fail due to unstable external services", continue;
     - Do test cases cover both success paths and failure paths (exceptions, invalid inputs, etc.):
       - Pass -> Record as pass, continue to next item;
       - Fail -> Record "Error paths not covered, recommend adding exception scenario tests", continue;
     - In E2E tests, is the app created in beforeAll and closed in afterAll (ensuring test isolation):
       - Pass -> Record as pass, continue to next item;
       - Fail -> Record "App lifecycle management is incomplete, may cause test interference", continue;
     - Are test cases independent of each other (not relying on execution order):
       - Pass -> Record as pass, continue to next item;
       - Fail -> Record "State sharing exists between test cases, recommend using beforeEach to reset state", continue;
     - Is describe used to group tests by function/module (improving readability and maintainability):
       - Pass -> Record as pass, continue to next item;
       - Fail -> Record "Test cases lack describe grouping, recommend organizing by functionality", continue;
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
  - Review items must reference NestJS testing best practices;
  - SKILL.md must not exceed 300 lines; split to references/ directory when exceeded;
  - Reference hierarchy must not exceed one level;
  - Maintain consistent terminology, terms defined in Definitions must be referenced via anchor links in the body;
  - Remove any time-sensitive information;

- **Behavior Standards**
  - During review, only output issue summaries and locations, do not directly modify code unless explicitly requested by the user via AskUserQuestion;
  - All code modification interaction steps must use the AskUserQuestion tool;
  - Mock strategies and test coverage should be marked as suggestions rather than mandatory, depending on project testing strategy;

- **Defense Standards**
  - If the target code is empty or unreadable, report directly and terminate;
  - Test coverage only checks visible test case structure, does not run actual tests;

- **Verification Standards**
  - Examples content must be consistent with Rules;
  - Examples must include a review check example;
  - Conversation interaction examples should only focus on steps 0~3 (excluding review check and output);

## Examples

### Conversation Interaction Example

**Example: User requests test implementation review**

```markdown
User > Help me check the unit tests for this service
AI   > Detected user needs NestJS testing review, triggering nestjs-5-3-testing skill
AI   > Analyzing test code...

Review Results:
- 🟩 Using Test.createTestingModule to build test module
- 🟥 Database Repository not Mocked, tests directly depend on database
- 🟩 Happy path coverage is complete
- 🟥 No coverage for exception inputs and error return scenarios
- 🟩 App correctly closed in afterAll

Summary: 2 issues need attention
User > Help me add Mocks and exception tests
AI   > Use useValue to provide Mock Repository and add exception scenario tests. Apply changes?
User > Accept all
```

### Review Check Example

```markdown
AI > Entering review check, Review List has 5 check items, beginning verification:

**Content Check**
  - 🟩 All review items reference testing best practices
  - 🟩 Mock strategies marked as suggestions

**Behavior Check**
  - 🟩 Did not directly modify user code
  - 🟩 Used AskUserQuestion

**Verification Check**
  - 🟩 Test coverage only checks visible structure
  - 🟩 Output summary is complete

✅ All passed, proceeding to output.
```

### Output Example

**Review Results Example:**

```markdown
| Dimension | Result |
| --- | --- |
| Reviewed File | src/user/user.service.spec.ts |
| Total Review Items | 7 |
| Passed | 5 |
| Issues Found | 2 |
| Risk Level | 🟡 Medium |
| Suggestions Adopted | 2 |
```

## Review List

- **Content Check**
  - [ ] All review items reference NestJS testing best practices
  - [ ] Mock strategies and test coverage marked as suggestions
- **Behavior Check**
  - [ ] Did not directly modify user code (unless explicitly requested by user)
  - [ ] All interaction steps used AskUserQuestion
- **Verification Check**
  - [ ] Correctly terminated when target code is empty or unreadable
  - [ ] Test coverage only checks visible structure
  - [ ] Output summary includes file path, number of review items, issues found, and risk level

## References

- [NestJS Testing Documentation](https://docs.nestjs.com/fundamentals/testing)
- [Jest Official Documentation](https://jestjs.io/)
- [Supertest Documentation](https://github.com/ladjs/supertest)
- [skill-evolve Template](../../skill-evolve/template.md)
