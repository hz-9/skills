---
name: skill-create
description: Create a new agent skill following the skill-evolve standard. Use when the user needs to create, write, or build a new skill.
disable-model-invocation: true
---

# Skill Create

## Overview

Create an agent skill from scratch. Refer to the skill-evolve standard template to create SKILL.md and auxiliary directories. For uncertain decisions, use AskUserQuestion to confirm with the user. Once created, it can be handed over to skill-evolve for further optimization.

## Definitions

- <a id="标准模板结构"></a>**Standard Template Structure**: A structure containing eight standard sections: Overview, Definitions, Prerequisites, Workflow, Rules, Examples, Review List, References;
- <a id="引用层次"></a>**Reference Level**: SKILL.md directly links files under `references/` as one level; files in `references/` should not link to external resources;
- <a id="Secure-步骤"></a>**Secure Steps**: Three standardized steps that always appear in the Workflow: Pre-check (first step), Review check (second-to-last step), Output results (last step);

## Prerequisites

- `skill-evolve` is installed (this skill depends on its `template.md` and `directory-structure.md`);
- The problem the skill needs to solve and the scenario in which it will be triggered must be clearly defined;
- Relevant knowledge in the domain is required.

## Workflow

0. **Pre-check** -- Confirm that skill-evolve's `template.md` and `directory-structure.md` are accessible;
  - Check whether `template.md` and `directory-structure.md` exist and are readable:
    - Yes -> next step;
    - No -> report missing files, terminate flow;
  - Check whether the target skill directory name already exists:
    - Yes -> check whether SKILL.md already exists:
      - Yes -> Provide options via AskUserQuestion, block and wait for user selection:
        - Overwrite existing file -> overwrite and proceed to next step;
        - Terminate -> terminate flow;
      - No -> next step;
    - No -> next step;
1. **Collect requirements** -- Gather skill information via AskUserQuestion;
  - Provide options via AskUserQuestion, block and wait for user selection:
    - [Dynamic options, AI generates up to 4 questions based on requirements] -> record answers, proceed to next step after execution;
2. **Create directory structure** -- Create files and folders following the [Directory Structure Standard](../skill-evolve/references/directory-structure.md);
  - Check whether at least `SKILL.md` has been created:
    - Yes -> next step;
    - No -> create `SKILL.md`, proceed to next step after execution;
3. **Draft SKILL.md** -- Organize content according to the template;
  - Organize content following the standard section order by referring to the [SKILL Template](../skill-evolve/template.md);
  - description must follow the format requirements in Rules;
  - Add guidance text for each section to help AI understand the purpose of that section;
  - Check whether the line count exceeds 300 lines:
    - Yes -> split into `references/`, proceed to next step after execution;
    - No -> next step;
4. **Add auxiliary directories** -- Evaluate and create auxiliary directories via AskUserQuestion;
  - If `references/` was already created in step 3 due to line splitting, skip the `references/` check;
  - Ask the user via AskUserQuestion whether the following directories are needed, confirming one by one:
    - Is `references/` directory needed:
      - Yes -> create `references/` directory, continue to next check;
      - No -> skip, continue to next check;
    - Is `scripts/` directory needed:
      - Yes -> create `scripts/` directory, continue to next check;
      - No -> skip, continue to next check;
    - Is `assets/` directory needed:
      - Yes -> create `assets/` directory, continue to next check;
      - No -> skip, continue to next check;
    - Is `schemas/` directory needed:
      - Yes -> create `schemas/` directory, continue to next check;
      - No -> skip, continue to next check;
    - Is `tests/` directory needed:
      - Yes -> create `tests/` directory, proceed to next step after execution;
      - No -> next step;
5. **Review with user** -- Present draft and confirm;
  - Provide options via AskUserQuestion, block and wait for user selection:
    - No modifications needed, approved -> next step;
    - Requires modifications followed by re-review -> modify based on feedback and return to step 5 (max 3 revisions within the same round, auto-proceed to next step if exceeded);
    - Unsatisfied, redraft -> return to step 3;
6. **Review check** -- Verify the creation result against the [Review List](#review-list);
  - Check whether the Review List has content:
    - No -> directly proceed to next step (Output results);
    - Yes -> next step;
  - Check each item in the [Review List](#review-list) one by one to see if it passes:
    - Yes -> continue to next check item;
    - No -> record the failed check item (display output based on the "Review Check Example"), continue to next check item;
  - Check whether any check item failed:
    - Yes -> terminate flow;
    - No -> proceed to next step (Output results);
7. **Output results** -- Output a structured summary informing that creation is complete;
  - Output a structured summary (created files, line count, overwritten directories, auxiliary directories, etc.);
  - Inform the user that creation is complete;

## Rules

- description must follow the format: first sentence describes the skill's capability, second sentence describes the trigger condition ("Use when..."), use third-person perspective, no more than 1024 characters;
- SKILL.md must not exceed 300 lines; if exceeded, split into `references/`;
- Reference level must not exceed one level (SKILL.md links files under `references/` as one level; `references/` should not link to external resources);
- Remove any time-sensitive information; keep terminology consistent;
- Include concrete examples with values consistent with the rules;
- All interactive steps involving user decisions **must** use the `AskUserQuestion` tool; plain text follow-up questions are prohibited; pass questions and options to AskUserQuestion in a structured manner, with no more than 4 questions per call;
- Any uncertainty during the creation process (skill name, description content, whether auxiliary directories are needed, content trade-offs, etc.) **must** be confirmed with the user via AskUserQuestion; making assumptions independently is prohibited;
- Review List check items must cover all constraint rules in Rules, ensuring one-to-one correspondence between Rules and Review List;

## Examples

### Dialogue Interaction Example

**Example: AI auto-triggers based on trigger condition**

```markdown
User > I want a skill to auto-clean local Git branches
AI   > Detected that the user needs to write a new skill, triggering skill-create
AI   > Starting requirements collection: What task/domain does this skill involve?
User > Help me list merged local branches and safely delete them
AI   > Do you need executable scripts?
User > No
AI   > Any reference materials?
User > No
AI   > Drafting SKILL.md based on template structure...
AI   > Please review the draft. Does this cover your use case?
User > Looks good
```

### Review Check Example

**Example: All review checks passed**

```markdown
AI > Entering review check, verifying against the Review List item by item:

- name field: skill-create ✅
- description format: conforms to "Use when..." standard ✅
- Structure alignment: all standard sections present ✅
- Line count 150 (<300, no split needed) ✅
- Examples wrapped in ```markdown code blocks ✅
- Interaction standard: uses AskUserQuestion ✅

✅ All passed, skill creation complete.
```

**Example: Review check failed and terminated**

```markdown
AI > Entering review check. Review List contains 13 items, starting verification:

**Metadata check**
  - 🟩 name field: skill-create, consistent with directory name
  - 🟥 description format: missing "Use when..."

**Content quality check**
  - 🟩 SKILL.md 150 lines (<300)
  - 🟥 Examples not wrapped in ```markdown code blocks

**!!! The following checks failed !!!**
  - 🟥 description format: missing "Use when..."
  - 🟥 Example format: not wrapped in markdown code blocks

Terminating flow. Recommend fixing and re-executing.
```

(AI will output all check item results one by one during runtime)

### Output Example

**Creation result example**

```markdown
| Dimension | Description |
|-----------|-------------|
| Created files | SKILL.md |
| Structure | Aligned with all standard template sections |
| Line count | 150 lines (<300) |
| description format | Contains "Use when..." |
| Interaction pattern | Uses AskUserQuestion |
```

## Review List

After creation is complete, verify the following:

- **Metadata check**
  - [ ] name field: exists with correct content, consistent with the directory name where SKILL.md is located
  - [ ] description format: first sentence describes the skill's capability, second sentence describes the trigger condition ("Use when..."), uses third-person perspective, no more than 1024 characters
- **Content quality check**
  - [ ] SKILL.md does not exceed 300 lines
  - [ ] No time-sensitive information (dates, version numbers, etc. have been removed)
  - [ ] Content quality: terminology consistent, includes concrete examples with values consistent with the rules
  - [ ] Example format: all examples wrapped in ```markdown code blocks
- **Reference check**
  - [ ] Reference level does not exceed one level
  - [ ] No dead links
- **Self-consistency check**
  - [ ] All standard sections are present (Overview, Definitions, Prerequisites, Workflow, Rules, Examples, Review List, References)
  - [ ] Secure steps are complete (Pre-check, Review check, Output results)
  - [ ] Interaction standard: all user decision interactions use AskUserQuestion; plain text follow-up questions are prohibited; each AskUserQuestion call contains no more than 4 questions with structured options
  - [ ] No independent assumptions: any uncertainty during the creation process must be confirmed with the user via AskUserQuestion; AI making assumptions independently is prohibited
  - [ ] Self-consistency: Review List check items correspond one-to-one with Rules constraint rules, no omissions

## References

- [SKILL Directory Structure](../skill-evolve/references/directory-structure.md): Defines the skill directory structure standard and auxiliary directory specifications
- [SKILL Template](../skill-evolve/template.md): Standard skill template containing responsibility descriptions and writing guidelines for all standard sections
---
name: skill-create
description: Create a new agent skill following the skill-evolve standard. Use when the user needs to create, write, or build a new skill.
disable-model-invocation: true
---

# Skill Create

## Overview

Create an agent skill from scratch. Create SKILL.md and auxiliary directories following the skill-evolve standard template. For uncertain decisions, ask the user via AskUserQuestion for confirmation. After creation, it can be further optimized by skill-evolve.

## Definitions

- <a id="Standard-Template-Structure"></a>**Standard Template Structure**: A structure containing eight standard sections: Overview, Definitions, Prerequisites, Workflow, Rules, Examples, Review List, References;
- <a id="Reference-Level"></a>**Reference Level**: SKILL.md directly linking files under `references/` is level one; files in `references/` should not link to external resources;
- <a id="Secure-Steps"></a>**Secure Steps**: Three standardized steps that always appear in the Workflow: Pre-flight Check (first step), Review Check (second-to-last step), Output Results (last step);

## Prerequisites

- `skill-evolve` is installed (this skill depends on its template.md and directory-structure.md);
- Clear understanding of what problem the skill to be created solves and under what scenarios it is triggered;
- Domain knowledge in the relevant area.

## Workflow

0. **Pre-flight Check** — Confirm skill-evolve's template.md and directory-structure.md are accessible;
  - Check if template.md and directory-structure.md exist and are readable:
    - Yes -> next step;
    - No -> report missing files, terminate flow;
  - Check if the target skill directory name already exists:
    - Yes -> check if SKILL.md already exists:
      - Yes -> provide options via AskUserQuestion, block and wait for user selection:
        - Overwrite existing file -> overwrite, proceed to next step;
        - Terminate -> terminate flow;
      - No -> next step;
    - No -> next step;
1. **Collect Requirements** — Gather skill information via AskUserQuestion;
  - Provide options via AskUserQuestion, block and wait for user selection:
    - [Dynamic options generated by AI based on requirements, up to 4 questions] -> record answers, proceed to next step;
2. **Create Directory Structure** — Create files and folders following [directory structure standard](../skill-evolve/references/directory-structure.md);
  - Check if at least `SKILL.md` was created:
    - Yes -> next step;
    - No -> create `SKILL.md`, proceed to next step;
3. **Draft SKILL.md** — Organize content following the template;
  - Follow the [SKILL template](../skill-evolve/template.md) to organize content in standard section order;
  - description must follow the format requirements in Rules;
  - Write guidance text for each section to help AI understand its purpose;
  - Check if line count exceeds 300:
    - Yes -> split into `references/`, proceed to next step;
    - No -> next step;
4. **Add Auxiliary Directories** — Evaluate and create auxiliary directories via AskUserQuestion;
  - If `references/` directory was already created due to line count splitting in step 3, skip the `references/` check;
  - Ask the user via AskUserQuestion whether the following directories are needed, confirm one by one:
    - Is `references/` directory needed:
      - Yes -> create `references/` directory, continue to next check;
      - No -> skip, continue to next check;
    - Is `scripts/` directory needed:
      - Yes -> create `scripts/` directory, continue to next check;
      - No -> skip, continue to next check;
    - Is `assets/` directory needed:
      - Yes -> create `assets/` directory, continue to next check;
      - No -> skip, continue to next check;
    - Is `schemas/` directory needed:
      - Yes -> create `schemas/` directory, continue to next check;
      - No -> skip, continue to next check;
    - Is `tests/` directory needed:
      - Yes -> create `tests/` directory, proceed to next step;
      - No -> next step;
5. **Review with User** — Present draft and confirm;
  - Provide options via AskUserQuestion, block and wait for user selection:
    - No changes needed, approve -> next step;
    - Changes needed, re-review after modification -> modify based on feedback and return to step 5 (max 3 modifications in the same round, auto-proceed after exceeding limit);
    - Not satisfied, redraft -> return to step 3;
6. **Review Check** — Check against [Review List](#review-list) to confirm creation results;
  - Check if Review List has content:
    - No -> go directly to next step (output results);
    - Yes -> next step;
  - Check each item in [Review List](#review-list) in order, check if passed:
    - Yes -> continue to next check item;
    - No -> record failed check item (display output content based on "Review Check Example"), continue to next check item;
  - Check if any check item failed:
    - Yes -> terminate flow;
    - No -> enter next step (output results);
7. **Output Results** — Output structured summary, notify creation complete;
  - Output structured summary (created files, line count, covered sections, auxiliary directories, etc.);
  - Inform user creation is complete;

## Rules

- description must follow the format: first sentence describes skill capability, second sentence describes trigger condition ("Use when..."), third person, no more than 1024 characters;
- SKILL.md does not exceed 300 lines; split into `references/` if exceeded;
- Reference level does not exceed one level (SKILL.md linking files under `references/` is level one; `references/` should not link external resources);
- Remove any time-sensitive information, maintain consistent terminology;
- Include concrete examples with values consistent with rules;
- All user decision-making interactions **must** use the `AskUserQuestion` tool; plain text follow-ups are prohibited; pass questions and options into AskUserQuestion in a structured way, no more than 4 questions per call;
- Any uncertainties during creation (skill name, description content, whether auxiliary directories are needed, content decisions, etc.) **must** ask the user via AskUserQuestion, do not assume on your own;
- Review List check items must cover all binding rules in Rules, ensuring one-to-one correspondence between Rules and Review List;

## Examples

### Dialog Interaction Examples

**Example: AI auto-triggered by matching condition**

```markdown
User > I want a skill to automatically clean up local Git branches
AI   > Detected user needs to write a new skill, triggering skill-create
AI   > Starting requirement collection: What task/domain does this skill involve?
User > It should list merged local branches and safely delete them
AI   > Do you need executable scripts?
User > No
AI   > Any reference materials?
User > No
AI   > Drafting SKILL.md following the template structure...
AI   > Please review the draft. Does this cover your use case?
User > Looks good
```

### Review Check Example

**Review Check All Passed Example**

```markdown
AI > Entering review check, verifying against Review List:

- name field: skill-create ✅
- description format: follows "Use when..." convention ✅
- Structure alignment: all standard sections present ✅
- Line count 150 (<300, no split needed) ✅
- Examples wrapped in ```markdown code blocks ✅
- Interaction conventions: uses AskUserQuestion ✅

✅ All passed, skill creation complete.
```

**Review Check Failed Termination Example**

```markdown
AI > Entering review check, Review List contains 13 check items, starting verification:

**Metadata Check**
  - 🟩 name field: skill-create, consistent with directory name
  - 🟥 description format: missing "Use when..."

**Content Quality Check**
  - 🟩 SKILL.md 150 lines (<300)
  - 🟥 Example not wrapped in ```markdown code block

**!!! Following check items FAILED !!!**
  - 🟥 description format: missing "Use when..."
  - 🟥 Example format: not wrapped in markdown code block

Terminating flow. Suggest fixing and re-executing.
```

(AI will output all check item results during runtime)

### Output Results Example

**Creation Result Example**

```markdown
| Dimension | Description |
|-----------|-------------|
| Created files | SKILL.md |
| Structure | Aligned with all standard template sections |
| Line count | 150 lines (<300) |
| description format | Includes "Use when..." |
| Interaction paradigm | Uses AskUserQuestion |
```

## Review List

After creation, verify the following:

- **Metadata Check**
  - [ ] name field: exists and correct, consistent with SKILL.md's parent directory name
  - [ ] description format: first sentence describes skill capability, second sentence describes trigger condition ("Use when..."), third person, no more than 1024 characters
- **Content Quality Check**
  - [ ] SKILL.md does not exceed 300 lines
  - [ ] No time-sensitive information (dates, version numbers, etc. all cleaned)
  - [ ] Content quality: consistent terminology, includes concrete examples with values consistent with rules
  - [ ] Example format: all examples wrapped in ```markdown code blocks
- **Reference Check**
  - [ ] Reference level does not exceed one level
  - [ ] No broken links
- **Self-Consistency Check**
  - [ ] All standard sections present (Overview, Definitions, Prerequisites, Workflow, Rules, Examples, Review List, References)
  - [ ] Secure Steps complete (Pre-flight Check, Review Check, Output Results)
  - [ ] Interaction conventions: all user decision-making interactions use AskUserQuestion, plain text follow-ups prohibited; each AskUserQuestion call does not exceed 4 questions, questions and options passed in a structured way
  - [ ] No autonomous assumptions: any uncertainties during creation must be confirmed with the user via AskUserQuestion, AI must not assume on its own
  - [ ] Self-consistency: Review List check items correspond one-to-one with Rules binding rules, no omissions

## References

- [SKILL Directory Structure](../skill-evolve/references/directory-structure.md): Defines skill directory structure standards and auxiliary directory conventions
- [SKILL Template](../skill-evolve/template.md): Skill standard template, containing responsibility descriptions and writing guidance for all standard sections
---
name: skill-create
description: Create new agent skills following skill-evolve standards. Use when the user needs to create, write, or build a new skill.
disable-model-invocation: true
---

# Skill Create

## Overview

Create an agent skill from scratch. **Follow skill-evolve standards to create a SKILL. If anything is uncertain, ask the user. If any information or positioning is unknown, ask the user.**

## Definitions

No content yet

## Prerequisites

No content yet

## Workflow

0. **Pre-check** — Verify that skill-evolve's template.md and directory-structure.md are accessible:
    - Yes -> Next step;
    - No -> Report missing files, terminate flow;
1. **Create skill** — Create directory structure and SKILL.md following template.md and directory-structure.md. For any uncertain decisions during creation, ask the user via AskUserQuestion;
2. **Review check** — Check results against [Review List](#review-list):
    - Check if Review List has content:
        - No -> Directly proceed to next step (Output results);
        - Yes -> Verify item by item:
            - All passed -> Next step;
            - Any failures -> Terminate flow;
3. **Output results** — Output structured summary and report completion.

## Rules

- For anything uncertain during creation (skill name, description content, whether auxiliary directories are needed, content decisions, etc.), **must** use AskUserQuestion to ask the user. Do not make assumptions.

## Examples

No content yet

## Review List

No content yet

## References

- [SKILL Template](../skill-evolve/template.md)
- [SKILL Directory Structure](../skill-evolve/references/directory-structure.md)
