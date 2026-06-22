---
name: your-skill-name
description: Briefly describe what this skill does and what problem it solves. Use when the user needs X, wants to do Y, or mentions Z.
---

# Skill Name: xxx

## Overview

Briefly describe what this Skill does, what problem it solves, and in what scenarios it is triggered. Use third-person perspective, no more than 1024 characters.

Example:

> Clean up stale Git branches, support interactive selection, safely delete merged local branches.

## Definitions

Define terms and conventions involved in the skill, as well as cross-step flow variables (starting with "是否" / whether), to help understand subsequent execution instructions. Each entry should be explained in one sentence. Each term should use an `<a id="term-name"></a>` tag to provide an anchor for precise referencing.

Example:

> - <a id="similar-meaning-section"></a>**Similar meaning section**: Sections with the same semantics as standard sections but with different historical names, automatically mapped during optimization without interactive confirmation.
> - <a id="reference-level"></a>**Reference level**: SKILL.md directly linking to `references/` files is level one; `references/` files linking to external resources is level two, which should be avoided.
> - <a id="secure-steps"></a>**Secure steps**: A set of fixed standardized steps in the Workflow, whose specific composition and structure are defined by [Workflow Writing Standard](references/workflow-standard.md).
> - <a id="abstract-variable-name"></a>**Abstract variable name**: A generalized placeholder in reference files used to replace specific values or paths, usually enclosed in square brackets `[]` (e.g., `[filename]`, `[directory-name]`), ensuring the referenced content does not become invalid when the referenced file content changes.
> - <a id="template-standard-sections"></a>**Template standard sections**: The set of standard sections defined by `##` heading sections in the [template](template.md), serving as the target baseline for structural alignment.
> - <a id="whether-cross-step-circular-reference"></a>**Whether cross-step circular reference**: Marks whether there are cross-step circular jump references between the substeps of the target SKILL.md's Workflow, controlling whether digital sub-numbering format is needed. Initialized after analyzing the reference relationship according to [Workflow Writing Standard](references/workflow-standard.md#digital-sub-numbering-reference-scenarios).

## Prerequisites

Conditions that need to be satisfied before execution, such as dependency tools, environment variables, prerequisite knowledge. If there are complementary skills, declare them here and explain the division of boundaries (avoid overlapping responsibilities).

Example:

> Requires Git 2.0+, currently in a Git repository directory, with branch deletion permissions. If creating a skill from scratch, use `skill-create`.

## Workflow

Core part: Step-by-step detailed instructions, telling the AI exactly what to do. Steps should be clear and executable.

The Workflow must include three Secure steps (Pre-check, Review Check, Output), with specific definitions and structures referenced in [Workflow Writing Standard](references/workflow-standard.md).

Example:

> 0. **Pre-check** — Ensure prerequisites for subsequent tasks are met;
> 1. **Get branch list** — Execute `git branch` to get local branch list;
> 2. **Filter protected branches** — Filter out current branch, main/master/develop;
> 3. **Confirm deletion one by one** — Ask user whether to delete each branch;
> 4. **Execute deletion** — Execute `git branch -d` for confirmed branches;
> 5. **Review check** — Confirm execution results against Review List;
> 6. **Output** — Output execution summary, inform completion;

## Rules

Tell the AI: Constraints and behavioral guidelines to follow during SKILL execution.

It is recommended to refer to the [Rules Writing Standard](references/rules-standard.md#grouping-recommendation) grouping scheme, dividing rules into the following six dimensions: Metadata, Structure, Content, Behavior, Defense, Validation. Each dimension is a group, presented as a two-level indented list.

> **Grouping threshold**: When Rules count ≥ 10, grouping is recommended; when fewer than 10, use a flat list to avoid unnecessary grouping.

Example:

> - **Metadata**
>   - description must follow format: first sentence describes what the skill does, second sentence describes trigger condition ("Use when..."), use third-person, no more than 1024 characters;
> - **Structure**
>   - Standard structural sections only apply to the target SKILL's SKILL.md file itself, not affecting other files in the directory;
> - **Content**
>   - (Please supplement based on skill characteristics)
> - **Behavior**
>   - Any file deletion must be confirmed with the user through interactive questioning;
> - **Defense**
>   - Every operation involving file movement, splitting, or deletion must synchronously handle side effects caused by the operation (e.g., updating link references, fixing relative paths);
>   - If an unrecoverable error is detected during execution, rollback using [original content copy](../skill-evolve/SKILL.md#original-content-copy) and inform the user of the recovery result;
> - **Validation**
>   - Example writing standards refer to [Example Writing Standard](references/example-standard.md#example-consistency-rules);

## Examples

### Dialogue Interaction Example

Refer to [Example Writing Standard](references/example-standard.md#dialogue-interaction-example-standards).

Example 1:

> **AI automatically triggered by condition**
>
> ```markdown
> User> Let me check if there are any stale local branches to clean up in the current project.
>
> AI > Detected user needs branch cleanup operation, triggering git-branch-cleanup skill:
>
> AI > Executing git branch to get local branch list...
>      Found merged branches: feature/old-login, fix/temp-patch, test/experiment
>      Current branch: main (skipped)
>      Protected branches: main, develop (skipped)
>
> AI > Delete feature/old-login? (merged to main)
> User> Yes
> AI > Deleted feature/old-login
>
> AI > Delete fix/temp-patch? (merged to main)
> User> No
> AI > Skipped fix/temp-patch
> ```

Example 2:

> **User actively requests to use specific skill**
>
> ```markdown
> User> Use commit-helper to generate a commit message for me.
>
> AI   > OK, analyzing staged changes...
>       Detected 3 staged files:
>       - src/auth.ts (new)
>       - src/user.ts (modified)
>       - tests/auth.test.ts (new)
>
>       Suggested commit message:
>       feat(auth): add user authentication module
>
>       - Implement JWT token generation and validation
>       - Add refresh token mechanism
>       - Add authentication-related unit tests
>
>       Use this message?
> User> Yes
> AI   > Commit completed with this message
> ```

### Review Check Example

Refer to [Example Writing Standard](references/example-standard.md#review-check-example-standards).

```markdown
AI > Entering review check, Review List contains 12 check items, starting one-by-one verification:

**Metadata Check**
  - 🟩 name field: your-skill-name, matches directory name
  - 🟥 description format: missing "Use when..."

**Content Check**
  - 🟩 SKILL.md 150 lines (<300)
  - 🟥 Example not wrapped in ```markdown code block

**Structure Check**
  - 🟩 All standard sections present
  - 🟩 Secure steps complete

**Validation Check**
  - 🟩 Review check example exists, showing termination flow
  - 🟩 Consistency: Review List corresponds to Rules one-to-one

**!!! The following checks did NOT pass !!!**
  - 🟥 description format: missing "Use when..."
  - 🟥 Example format: not wrapped in markdown code block

Terminate flow, suggest manual inspection and re-execution.
```

### Output Example

Refer to [Example Writing Standard](references/example-standard.md#output-example-standards).

Example 1:

> **SKILL optimization skill execution effect example:**
>
> ```markdown
> | Dimension             | Before Optimization              | After Optimization                |
> | --------------------- | -------------------------------- | --------------------------------- |
> | SKILL.md line count   | 150 lines                        | 85 lines                          |
> | Section completeness  | Missing Prerequisites, Review List | All sections completed          |
> | Time-sensitive info   | Contains v2.1.0, 2024-05-01 etc. | All removed                       |
> | Reference docs        | REFERENCE.md single file         | Split into 3 files under references/ |
> | Trigger condition     | Vague description                | Clearly includes "Use when..."    |
> ```

Example 2:

> **Git branch cleanup skill execution effect example:**
>
> ```markdown
> | Item                                | Count     |
> | ----------------------------------- | --------- |
> | Merged branches                     | 3         |
> | Unmerged branches (unpushed, skipped) | 1       |
> | Cleaned up                          | 2         |
> | User declined to clean              | 1         |
> | Auto-skipped (current + protected)  | 2         |
> | Disk space freed                    | ~45MB     |
> ```

## Review List

Tell the AI: Review check items after SKILL completion.

**Tip**: The check items in Review List should be determined based on the actual output nature of the skill, following [Review List Writing Standard](references/review-list-standard.md#type-adaptation) "Type Adaptation" rules:

- **Meta-skill** (skills that modify/validate SKILL.md, such as skill-evolve, skill-create):
  Review includes file structure checks (metadata, standard sections, Secure steps, consistency)
- **Domain/Action skill** (skills that execute specific tasks, such as code analysis, migration tools, query tools):
  Review only validates output/result quality, does not include the skill's own file structure checks

> The following example **is only a reference for Meta-skills**. Domain/Action skills should tailor according to their own output nature, do not mechanically copy.

It is recommended to refer to [Review List Writing Standard](references/review-list-standard.md#grouping-recommendation) grouping scheme, organizing check items by quality dimension (e.g., metadata, content, references), each dimension as a group, using two-level indented list format.

Example:

> - **Metadata Check**
>   - [ ] description format: includes trigger condition ("Use when..."), uses third-person, no more than 1024 characters
> - **Structure Check**
>   - [ ] Extension directories: scripts/, tests/ or schemas/ have been evaluated
>   - [ ] Secure steps completeness: Workflow step structure conforms to standards defined in [Workflow Writing Standard](references/workflow-standard.md)
> - **Content Check**
>   - [ ] SKILL.md does not exceed 300 lines
>   - [ ] Content quality: no time-sensitive information, consistent terminology, includes concrete examples with values consistent with rules
>   - [ ] Reference level no more than one level, no dead links
>   - [ ] Format standards: punctuation and quote style must follow [Punctuation Convention](references/punctuation-convention.md#verification-checklist)
> - **Behavior Check**
>   - [ ] Interaction: confirm item by item against [Workflow Writing Standard](references/workflow-standard.md#interaction-standard-verification)
>   - [ ] Branch logic: confirm item by item against [Workflow Writing Standard](references/workflow-standard.md#branch-logic-verification)
> - **Defense Check**
>   - [ ] Error handling completeness: review check correctly handles recoverable/unrecoverable errors according to defense standards
> - **Validation Check**
>   - [ ] Example specification consistency: confirm against [Example Writing Standard](references/example-standard.md#verification-checklist)

> **Tip**: Specific check items in Review List can be implemented through anchor references to each file's `## Verification Checklist` section under `references/`, avoiding inline duplication. Refer to [Content Boundary Standard](references/content-boundary.md).

> **Advanced Tip**: If the SKILL's Rules and Review List use anchor reference structure, it is recommended to add a "Format Unification Check" step in the Workflow, referencing each reference file's `## Verification Checklist` to check item by item.

## References

List of referenced external documents and resources. Add more reference items as needed.

Example:

> - [SKILL Directory Structure](references/directory-structure.md)
> - [SKILL Template](template.md)
> - [Content Boundary Standard](references/content-boundary.md): Defines content ownership boundaries between SKILL.md and references/ files
> - [Workflow Writing Standard](references/workflow-standard.md): Defines Workflow fixed step structure, step writing format, branch logic and interaction patterns
> - [Rules Writing Standard](references/rules-standard.md): Constrains AI execution behavior
> - [Review List Writing Standard](references/review-list-standard.md): Defines Review List writing conventions
> - [Punctuation Convention](references/punctuation-convention.md)
> - [Example Writing Standard](references/example-standard.md): Defines writing format and consistency rules for `## Examples` section
