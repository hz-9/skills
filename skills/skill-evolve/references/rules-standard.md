# Rules Writing Standard — Define Rules Writing Conventions, Grouping Recommendations, and Variable Declaration Standards

## Overview

Rules constrain AI execution behavior (process), telling the AI how to behave during execution.

## Content Boundary

- **Should be in Rules**: Metadata standards, Structure standards, Content standards, Behavior standards, Defense standards, Validation standards
- **Should NOT be in Rules**: Result validation (go in Review List), metadata definitions (go in Definitions), writing standards (go in this file)

## Grouping Recommendation

- When count ≥ 10, use two-level indented list grouping (e.g., `- **Group Name**`)
- Recommended to group by the following six dimensions. This scheme is the authoritative definition for Rules grouping, and Review List grouping should align accordingly:

| # | Group Name           | Focus Area               | Scope                                                                  |
|---| -------------------- | ------------------------ | ---------------------------------------------------------------------- |
| 1 | **Metadata**         | Skill self-declaration   | name, description, frontmatter field validation                        |
| 2 | **Structure**        | Directory & file structure | Standard sections, file structure constraints                          |
| 3 | **Content**          | References, anchors, paths, terminology | Reference levels, specification conflicts, path matching, anchor references, term definitions |
| 4 | **Behavior**         | File operations & interactions | File CRUD, AskUserQuestion interactions, Workflow structure, reference execution behavior |
| 5 | **Defense**          | Side effects & error handling | Side effect synchronization, error classification, rollback mechanisms |
| 6 | **Validation**       | Consistency & reference validation | Concern Separation, Workflow-Rules-RL alignment, Examples consistency |

## Variable Declaration Standards

Cross-step workflow variables used in Workflow must follow these conventions:

- **Declaration location**: Declared as list items with `<a id="">` anchors in `## Definitions`;
- **Naming format**: Begins with "是否" (whether) or "是否为" (whether it is) (e.g., "是否跨步骤循环引用" - whether cross-step circular reference exists, "是否为技能原始仓库" - whether it is the skill's original repository), with name reflecting the variable's acquisition rules;
- **Variable description**: Explains acquisition rules in the Definitions entry (may include file references), allowing AI to determine how to evaluate the variable;
- **Initialization location**: Initialized in Workflow Step 0 (pre-check) using a common pattern, formatted as:
  ```markdown
  - Initialize global variables [VariableA](#anchorA), [VariableB](#anchorB), ...:
    - Evaluate each variable's conditions in order:
      - Met -> initialize the variable to true;
      - Not met -> initialize the variable to false;
  ```
- **Variable reading**: Referenced via anchor links to Definitions variable definitions in steps where variable values are needed;
- **Scope rule**: Only cross-step global variables need declaration; local variables used within a single substep do not require declaration.

## Relationship with Review List

Rules and Review List follow Concern Separation, with no mandatory one-to-one correspondence:

- Rules constrain AI execution behavior (process), Review List validates output quality (result)
- Purely structural check items do not require a corresponding Rule
- Purely process-level constraints already covered by Workflow do not require a corresponding Review List item

## Verification Checklist

- [ ] All Rules constrain AI execution behavior (process), not result validation
- [ ] No Review List check items are mistakenly placed in Rules
- [ ] Grouping threshold is appropriate (≥10 items follows the grouping recommendation)
- [ ] Grouping uses the recommended six dimensions (Metadata/Structure/Content/Behavior/Defense/Validation)
- [ ] Rules internal consistency: no contradictions between rules within the same group, no conflicts across groups in interaction scenarios (e.g., file deletion confirmation in Behavior should not contradict editing scope exceptions)
