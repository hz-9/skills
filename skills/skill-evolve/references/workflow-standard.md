# Workflow Writing Standard — Define the Complete Writing Standards for the `## Workflow` Section in SKILL.md

## Overview

Define the complete writing standards for the `## Workflow` section in SKILL.md, covering fixed step structure, step numbering and formatting, branch logic, and interaction patterns. Following this standard ensures consistent Workflow structure, clear hierarchy, and easy maintainability across all SKILLs.

## Terminology

- **Secure steps**: Three standardized steps that appear fixedly in Workflow: Pre-check (first step), Review Check (second-to-last step), Output (last step), collectively referred to as Secure steps.
- **Pre-check**: Step 0 of Workflow (first step), verifying environment integrity and prerequisites before executing core logic.
- **Review Check**: The second-to-last step of Workflow, reviewing results against the Review List item by item after execution.
- **Output**: The last step of Workflow, outputting a result summary and informing completion after review passes.

Each Secure step includes **Core (required)** and **Supplementary (optional)** parts:

- **Core**: The essential content of the step, determined by the step's core responsibilities;
- **Supplementary**: Added as needed by the target SKILL based on its own scenario in the Workflow step;

## Fixed Step Specification

### 1. Pre-check

**Name**: `0. **Pre-check** — [responsibility description]`

**Responsibility**: Before starting the core workflow, ensure prerequisites for subsequent tasks are met.

**Standard content**:

**Core (required):**

- Ensure prerequisites are met (environment, tools, permissions, etc.):
  - Yes -> next step;
  - No -> report unmet conditions, terminate flow or prompt user to handle;

**Supplementary (optional):**

- Save complete original content copy of the target file (as rollback baseline);
- Verify template (if depended on) exists and structure is parseable:
  - Yes -> next step;
  - No -> report "Template file missing or corrupted", terminate flow;
- Verify referenced files under `references/` exist and are synchronized with References section:
  - Yes -> next step;
  - No -> list missing files, provide options via AskUserQuestion, block and wait for user selection:
    - Skip missing and continue -> next step;
    - Terminate, fix and re-run -> terminate flow;
- Initialize global variables (list determined by variables declared in Definitions), using common format:
  ```
  - Initialize global variables [VariableA](#anchorA), [VariableB](#anchorB), ...:
      - Evaluate each variable's conditions in order:
          - Met -> initialize the variable to true;
          - Not met -> initialize the variable to false;
  ```
- Verify Pre-check covers all conditions declared in `## Prerequisites` section, **ensuring Prerequisites and Step 0 remain synchronized**:
  - Yes -> next step;
  - No -> add missing check items, mark Prerequisites section as synchronized, then proceed to next step;

**Auto-completion rules:**

- If the first step of the target SKILL.md's Workflow is not "Pre-check", AI should automatically insert this step at the very beginning;
- Auto-generated content directly reproduces the complete content of the above "Core (required)" section without additional modification;
- Supplementary part is determined by AI based on the specific scenario of the target SKILL;
- Pre-check step number is fixed as `0.`;
- Failure handling principle: Recoverable conditions prompt user to handle; unrecoverable conditions directly terminate flow.

### 2. Review Check

**Name**: `N. **Review Check** — Confirm execution results against [Review List](#review-list)`

- Where N = total steps - 1 (second-to-last step)

**Responsibility**: After all operations are completed, review execution results against the Review List item by item, ensuring quality standards are met.

**Standard content**:

**Core (required):**

- Check if Review List has content:
  - No -> directly go to next step (Output);
  - Yes -> next step;
- Check each item in [Review List](#review-list) one by one, whether it passes:
  - Display output content based on "Review Check Example";
- If any check fails, terminate flow;
- If all pass, proceed to next step (Output);

**Auto-completion rules:**

- If the second-to-last step of the target SKILL.md's Workflow is not "Review Check", AI should automatically insert this step before the last step;
- Auto-generated content directly reproduces the complete content of the above "Core (required)" section without additional modification;
- Step number is automatically calculated as current total steps - 1.

### 3. Output

**Name**: `N. **Output** — Output execution summary, inform completion`

- Where N = total steps (last step)

**Responsibility**: After review passes, summarize execution results, output a result summary, and inform the user of completion.

**Standard content**:

**Core (required):**

- Output structured summary (refer to the target SKILL's "Output Example" for specific format);
- Inform user of completion;

**Supplementary (optional):**

- Only list dimensions that changed this time; do not output dimensions that remained unchanged;

**Auto-completion rules:**

- If the last step of the target SKILL.md's Workflow is not "Output", AI should automatically append this step;
- Auto-generated content must include the Core (required) part:
  - Output structured summary (refer to the target SKILL's "Output Example" for specific format);
  - Inform user of completion;
- Supplementary (optional) part is determined by AI based on the target SKILL's context;
- Step number is automatically calculated as current total steps.

### Auto-completion Algorithm

When AI inspects the Workflow structure of the target SKILL.md, execute the following logic:

1. **Parse**: Extract all step lines in `N. **Name**` format from Workflow;
2. **Check first step**:
  - If the first step name is not "Pre-check" -> Check if a step named "Pre-check" exists in Workflow:
    - Exists -> Move that step to the first position, no need to add;
    - Does not exist -> Insert Pre-check step at the very beginning (number `0.`);
3. **Check last step**:
  - If the last step name is not "Output" -> Check if a step named "Output" exists in Workflow:
    - Exists -> Move that step to the last position, no need to add;
    - Does not exist -> Append Output step at the end;
4. **Recalculate** total step count N;
5. **Check second-to-last step**:
  - If the second-to-last step name is not "Review Check" -> Check if a step named "Review Check" exists in Workflow:
    - Exists -> Move that step before Output, no need to add;
    - Does not exist -> Insert Review Check step before Output;
6. **Renumber** all steps (starting from 0, incrementing sequentially);
7. **No user confirmation needed**, automatically execute the above completion operations.

### Consistency Requirements

- All SKILL.md Workflows must include these three Secure steps;
- The core responsibilities of the three steps remain consistent across all SKILL.md files:
  - **Pre-check**: Verify environment, prevent mid-execution failures;
  - **Review Check**: Item-by-item review, ensure quality standards met;
  - **Output**: Summarize and present, inform execution completion;
- Sub-steps can be adapted based on the target SKILL's specific scenario (e.g., whether Pre-check includes template verification), but the core responsibility of each step cannot be changed;
- Auto-completed step content should be relevant to the target SKILL's context (e.g., referenced file list should be synchronized with the SKILL's References section).

### Fix Retry Specification

When Workflow involves iterative loops of "fix → recheck → still fail":

- A maximum retry limit should be set (recommended 2-3 times)
- After exceeding the limit, the handling plan must be explicitly stated in the Workflow (e.g., "record failure item, continue to next step" or "terminate flow")
- Degradation (recording failure and continuing to next step) is not default behavior and must be explicitly declared in the Workflow
- Return point should be precise to the sub-step that triggered the operation, not the beginning of the entire step

> This specification constrains Workflow writing behavior, not AI execution behavior. AI should follow this specification when writing/modifying Workflow.

### Examples

#### Pre-check Auto-completion

```markdown
Before modification (missing Pre-check):

1. **Metadata Structure** — Check frontmatter content correctness;
2. **Structure Alignment** — Complete missing sections against template;

After modification (auto-insert Pre-check): 0. **Pre-check** — Verify environment integrity; - Verify target SKILL.md exists and is readable: - Yes -> next step; - No -> report "Target file does not exist or cannot be read", terminate flow; - Save original content copy in memory;

1. **Metadata Structure** — Check frontmatter content correctness;
2. **Structure Alignment** — Complete missing sections against template;
```

#### Review Check + Output Auto-completion

```markdown
Before modification (missing Review Check and Output): 4. **Content Streamline** — Check and clean SKILL.md content;

After modification (auto-append Review Check and Output): 4. **Content Streamline** — Check and clean SKILL.md content; 5. **Review Check** — Confirm optimization results against Review List; - Check each item in Review List one by one, whether it passes: - Yes -> next step; - No -> output failing items, terminate flow; - If all pass, proceed to next step; 6. **Output** — Output optimization summary, inform completion;
```

## Step Writing Format

This section defines Workflow step numbering systems, title naming, sub-step structure, and other general format rules. Detailed specifications for conditional branches (tree arrows, polarity matching, etc.) are fully defined in Section 3.

### Numbering System

#### Top-level Steps

- Step numbers start from 0, incrementing sequentially: `0.`, `1.`, `2.`, `3.`…
- `0.` is reserved for Secure step "Pre-check"
- Number is followed by a space, then the title

```
0. **Pre-check** — Ensure prerequisites for subsequent tasks are met;
1. **Main Flow** — Execute core logic;
```

#### Sub-step Numbering

- **Regular sub-steps**: Use indented bullet list (`-`), **do not** use numeric numbering
- **Sub-steps requiring positional references**: Use 1.1, 1.2, 1.3 (or 2.1, 2.2) format, **only when** there are circular jumps between sub-steps or references needed in other parts of the document

```
3. **Fix Loop** — Fix discovered issues one by one;
  3.1 Fix current issue;
  3.2 Re-verify fix result;
  3.3 Return to entry judgment;
  - Fix list empty -> next step;
```

### Title Naming

#### Format

```
N. **Title** — Description;
```

| Part         | Requirement                        |
| ------------ | ---------------------------------- |
| `N.`         | Step number, followed by a space   |
| `**Title**`  | Bold step core action, 3~10 words  |
| `—`          | Em dash, one space on each side    |
| `Description`| Brief step purpose, 10~30 words    |
| `;`          | Semicolon ending                  |

Title and description are connected by an em dash `—`, not colon `：`, hyphen `-`, or en dash `--`.

#### Examples

```
0. **Pre-check** — Ensure prerequisites for subsequent tasks are met;
1. **Metadata Structure** — Check frontmatter content correctness;
2. **Structure Alignment** — Complete missing sections and adjust order against template;
6. **Review Check** — Confirm optimization results against Review List;
7. **Output** — Output optimization summary, inform completion;
```

### Sub-step Structure

#### Bullet List (Regular)

Sub-steps start with `-`, nested layers indicated by indentation:

```
N. **Title** — Description;
  - Check a condition:
    - Yes -> next step;
    - No -> handling method;
  - Execute an operation:
    - Success -> next step;
    - Failure -> terminate flow;
```

Each level indented by 2 spaces. Conditional branches (`Yes -> / No ->`) indented by another 2 spaces.

#### <a id="digital-sub-numbering-reference-scenarios"></a>Digital Sub-numbering (Reference Scenarios)

When there are circular jumps between sub-steps or cross-references in other parts of the document, use `N.M` format:

```
4. **Content Streamline** — Check and clean SKILL.md content;
  4.1 Check if line count exceeds 300:
    - Yes -> migrate to references/;
    - No -> next step;
  4.2 Delete time-sensitive information, maintain term consistency;
  4.3 Check abstract variable names:
    - Issues found -> replace and return to 4.1 for re-evaluation;
    - No issues -> next step;
```

### Conditional Branches

Detailed specifications for conditional branches (tree arrow format, branch endpoints, polarity matching, loops and iterations, cross-step references, etc.) are fully defined in Section 3 [Branch Logic Writing Format](#branch-logic-writing-format).

This section only lists the most commonly used points in the step writing format context:

- Tree arrow format: `- Yes -> action;` / `- No -> action;`
- Branch endpoint explicit: Each branch must end with `next step;`, `terminate flow;`, or `return N.M`
- Each condition check must have explicit `Yes` and `No` branches; the negative branch must not be missing

### Loops and Iterations

#### Loop Markers

When Workflow contains iterative loops, clearly state the loop boundary at the loop entry:

```
3. **Fix Loop** — Fix discovered issues one by one;
  - Check if fix list is empty:
    - Yes -> next step (all fixes complete);
    - No -> continue fixing;
  - Fix current issue;
  - Execute verification, check verification result:
    - Passed -> continue to next issue;
    - Failed -> return to current issue, re-fix;
```

#### Iteration Handling

When involving multi-element iteration, explicitly describe the handling path for each element:

```
- Execute steps 4.1~4.3 for each file in sequence:
  - All complete -> next step;
  - Any failure -> terminate flow, report failed filename;
```

Avoid using vague expressions like "generate separately" or "process one by one."

### Cross-step References

#### Reference Format

When referencing other steps in sub-steps, use a unified format:

| Reference Type | Format      | Example          |
| -------------- | ----------- | ---------------- |
| Top-level step | `Step N`    | `Step 3`         |
| Sub-step       | `Step N.M`  | `Step 4.2`       |
| Range          | `Steps N~M` | `Steps 4.1~4.3`  |

#### Examples

```
- Issues found -> record and return to Step 3 for re-evaluation;
- All fixed -> proceed to Step 5 (Review Check);
```

### Common Mistakes

| ❌ Wrong Format                        | ✅ Correct Format                               | Reason                                                   |
| -------------------------------------- | ----------------------------------------------- | -------------------------------------------------------- |
| `### 1. Title`                         | `1. **Title** — Description;`                   | Avoid using Markdown heading levels to define steps      |
| `1) Execute operation`                 | `- Execute operation`                           | Sub-steps uniformly use bullet symbols                   |
| `If condition is met, continue; otherwise terminate` | `- Yes -> next step; No -> terminate flow;` | Conditional branches use tree arrows                     |
| `Loop until complete`                  | `- List empty -> next step; No -> continue;`    | Loop boundaries explicit                                 |

### Complete Example

The following is a complete Workflow that conforms to all the above specifications:

```markdown
0. **Pre-check** — Ensure prerequisites for subsequent tasks are met;
  - Ensure prerequisites are met:
    - Verify target file exists and is readable:
      - Yes -> next step;
      - No -> report "File missing", terminate flow;
  - Save original content copy (as rollback baseline);
1. **Execute Main Flow** — Complete core business logic;
  - Execute operation A:
    - Yes -> next step;
    - No -> report error, terminate flow;
2. **Fix Loop** — Fix discovered issues one by one;
  2.1 Check if fix list is empty:
    - Yes -> next step (enter Review Check);
    - No -> continue;
  2.2 Fix current issue;
  2.3 Re-verify fix result:
    - Passed -> return to 2.1 for next issue;
    - Failed -> return to 2.2 for re-fix;
3. **Review Check** — Confirm execution results against Review List;
  - Check if Review List has content:
    - No -> directly go to Output;
    - Yes -> next step;
  - Check each item one by one, whether it passes:
    - Display output content based on "Review Check Example";
  - If any check fails, terminate flow;
  - If all pass, proceed to Output;
4. **Output** — Output execution summary, inform completion;
  - Output structured summary;
  - Inform completion;
```

## Branch Logic Writing Format

Standardize the writing of conditional branch judgments in SKILL.md, converting flat if-else to tree arrow format (`Yes -> / No ->`), ensuring each branch result corresponds to a clear, executable operation instruction. Each branch action line must end with `；` as a branch end marker; non-terminating branch lines introducing sub-conditions or sub-operation lists end with `：`.

### Rule 1: Branch Logic Tree-ification

Conditional branches must be presented in tree arrow format, with each outcome (Yes/No) on its own line, indented to express hierarchy, avoiding compressing multiple branch results into the same line.

> **Standard format**:
>
> ```markdown
> - Check condition:
>   - Yes -> execute action A;
>   - No -> execute action B;
> ```

#### Example 1: Simple Binary Decision

```markdown
**Original**

- If missing or non-standard, interactively confirm fix plan;

**Optimized**

- Confirm `[fieldname]` exists:
  - Yes -> next step;
  - No -> provide options via AskUserQuestion, block and wait for user selection:
  - Folder name -> use folder name, then proceed to next step;
  - Filename derived from SKILL.md -> use filename, then proceed to next step;
```

> **Key improvement**: The original only has an implicit branch for "if missing"; AI doesn't know what to do when the condition is met. The optimized version explicitly defines "Yes -> next step."

#### Example 2: Nested Branches

```markdown
**Original**

- Non-template standard section content -> migrate to `references/` (if filename already exists, interactively confirm overwrite, merge, or skip);

**Optimized**

- Non-template standard section content -> migrate to `references/`:
  - Does filename already exist:
    - Yes -> provide options via AskUserQuestion, block and wait for user selection:
      - Overwrite -> overwrite file, then proceed to next step;
      - Merge -> merge content, then proceed to next step;
      - Skip -> keep original file, then proceed to next step;
    - No -> next step;
```

> **Key improvement**: The original compresses "migrate" and "handle same filename" into one line; AI might confuse execution order. The optimized version expresses parent-child judgment relationships through indentation.

#### Example 3: Existence Detection

```markdown
**Original**

- If `REFERENCE.md` exists, show split plan first, confirm and execute:

**Optimized**

- Check if `[target_file]` exists:
  - Yes -> provide options via AskUserQuestion, block and wait for user selection:
    - [Dynamic options generated by AI based on [target_file] content] -> execute corresponding split plan, then proceed to next step;
  - No -> next step;
```

> **Key improvement**: The original lacks the behavior definition for "when it does not exist." The optimized version adds `No -> next step`, eliminating the AI's behavior blind spot.

#### Example 4: Multi-step Action Block with Colon Alignment

```markdown
**Original**

- After split, update all links pointing to original file in SKILL.md

**Optimized**

- After split, update all links pointing to original file in SKILL.md:
  - Scan SKILL.md for all links pointing to original REFERENCE.md;
  - Update each to new split file paths;
  - Verify no dead links;
```

> **Key improvement**: The original's "update" is a vague action. The optimized version ends with `：` to introduce a sub-operation list, each sub-operation ending with `；`, with unified format and clear boundaries.

### Rule 2: Idempotent Guard

For judgments of "whether already conforms to a certain specification," the "Yes" branch must annotate the skip reason, preventing duplicate optimization triggers during second execution.

> **Standard format**:
>
> ```markdown
> - Check if [element] already uses [specification] standard format:
>   - Yes -> next step (current content already meets the section's template requirements, marked as compliant, skip this round of optimization; when template requirements are updated or content substantially deviates, this check needs to be re-executed);
>   - No -> optimize based on [specification];
> ```

#### Example: Idempotent Interaction Check

```markdown
**Original**

- Check if `## Workflow` contains interaction points involving user decisions
  - Yes -> optimize based on interaction writing standard
  - No -> next step

**Optimized**

- Check if `## Workflow` contains interaction points involving user decisions:
  - Yes -> check if already using `AskUserQuestion` standard format:
    - Yes -> next step (current content already meets the section's template requirements, marked as compliant, skip this round of optimization; when template requirements are updated or content substantially deviates, this check needs to be re-executed);
    - No -> optimize based on [interaction writing standard];
  - No -> next step;
```

> **Key improvement**: The original lacks the "already compliant -> skip" secondary check, causing the second execution to "optimize" already correctly formatted content, potentially causing format deformation.

### Rule 3: Sequential Judgment (Set Iteration)

When needing to judge each element in a collection one by one, use the "sequentially check each..." prefix to clarify the iteration scope.

> **Standard format**:
>
> ```markdown
> - Sequentially check each [element] in [collection], whether it [condition]:
>   - Yes -> next step (current content already meets the section's template requirements, marked as compliant, skip this round of optimization; when template requirements are updated or content substantially deviates, this check needs to be re-executed);
>   - No -> optimize based on [specification];
> ```

#### Example: Batch Interaction Point Check

```markdown
**Original**

- Check if `## Workflow` contains interaction points involving user decisions
  - Yes -> optimize based on interaction writing standard
  - No -> next step

**Optimized**

- Sequentially check each interaction point in `## Workflow` that involves user decisions, whether it already uses `AskUserQuestion` standard format:
  - Yes -> next step (current content already meets the section's template requirements, marked as compliant, skip this round of optimization; when template requirements are updated or content substantially deviates, this check needs to be re-executed);
  - No -> optimize based on [interaction writing standard];
```

> **Key improvement**: "Sequentially check each..." compared to "check if... exists" upgrades "existence detection" to "item-by-item compliance check"; AI won't stop checking after the first compliant item.

### Rule 4: Conditional Polarity Matching

The choice of conditional words must align with branch semantics. The "positive/negative" polarity of the condition determines branch direction; incorrect polarity matching can cause AI to misjudge branch ownership.

> **Standard format**: Always use positive polarity conditions ("whether exists", "whether satisfied"), avoid negative polarity conditions ("whether not satisfied", "if missing").

#### Example 1: Correct Polarity Alignment

```markdown
**Original**

- If description is missing, interactively confirm fix plan;

**Optimized**

- Check if description exists:
  - Yes -> next step;
  - No -> provide options via AskUserQuestion, block and wait for user selection:
  - [Dynamic options generated by AI based on missing type] -> execute corresponding fix, then proceed to next step;
```

> **Key improvement**: The original's "if...missing" is a negative polarity condition with only one branch for "when missing," lacking behavior for "when not missing." After changing to "check if exists," the positive and negative branch boundaries naturally align.

#### Example 2: Positive vs Negative Polarity

```markdown
**Wrong**

- Check if description does not meet format requirements:
  - Yes -> provide options via AskUserQuestion (fix / keep current), block and wait for user selection;
  - No -> next step;
```

> **Problem**: The condition itself is negative polarity ("whether not met"), `Yes ->` corresponds to "not met -> fix", `No ->` corresponds to "met -> skip." Negative polarity conditions increase AI reading comprehension burden and may confuse "Yes/No" with "Good/Bad."
> **Correct**: Always use positive polarity condition `Check if description meets format requirements`, then swap the `Yes` / `No` branch actions.

#### Example 3: Single-Path Sentence Not Suitable for Binary Branches

```markdown
**Wrong**

- When SKILL.md exceeds 300 lines:
  - Yes -> execute migration;
  - No -> next step;
```

> **Problem**: "When..." is a single-path condition, not suitable for `Yes -> / No ->` binary branches. AI might be confused: the semantics of "When..." imply action only when condition is met, with no clear "not met" semantics.
> **Correct**: Use "Check if SKILL.md exceeds 300 lines"

**Self-check method**: After writing the condition, read it aloud in natural language as "Yes->X", "No->Y" to verify it matches intuition.

### Rule 5: Explicit Branch Endpoint

Each branch (`Yes ->` / `No ->`) must end with an explicit flow control action; output alone without subsequent flow direction instructions is not allowed. Non-terminating branches must have a clear "next step" indication.

> **Standard format**:
>
> - Terminating branch: `Yes -> execute action; terminate flow;`
> - Continue flow: `Yes -> execute action, then proceed to next step;`
> - Skip optimization: `Yes -> next step (current content already meets the section's template requirements, marked as compliant, skip this round of optimization; when template requirements are updated or content substantially deviates, this check needs to be re-executed);`
> - Introduce sub-operations: `Yes -> enter sub-operations:` (ending with `：`)

#### Example 1: Output Only, Missing Flow Direction

```markdown
**Wrong**

- Check if file exists:
  - Yes -> read content;
  - No -> prompt user;
```

> **Problem**: After `Yes -> read content;`, where does it go? Continue with subsequent steps or terminate? AI cannot determine, may output content and then continue with subsequent steps.

```markdown
**Correct**

- Check if file exists:
  - Yes -> read content, then proceed to next step;
  - No -> prompt user file does not exist; terminate flow;
```

#### Example 2: Branch Endpoint with Colon

```markdown
**Correct** (multi-step action block)

- Non-template standard section content -> migrate to references/ :
  - Does file already exist:
  - Yes -> provide options via AskUserQuestion, block and wait for user selection:
      - Overwrite -> overwrite file, then proceed to next step;
      - Merge -> merge content, then proceed to next step;
      - Skip -> keep original file, then proceed to next step;
```

> The non-terminating line "migrate to references/:" ends with a full-width colon, indicating "sub-operations to be expanded here"; sub-operations ultimately end with `；`, indicating "this path has ended."

### Branch Action Types

The `Yes ->` / `No ->` in tree branches can be followed by the following action types:

| Type                    | Format                                                      | Meaning                                                        |
| ----------------------- | ----------------------------------------------------------- | -------------------------------------------------------------- |
| Next step               | `next step;`                                                | Continue to next judgment within the current step, or proceed to next step |
| Terminate flow          | `terminate flow;`                                           | Stop execution, do not continue with subsequent steps           |
| Skip optimization       | `next step (current content already meets the section's template requirements, marked as compliant, skip this round of optimization; when template requirements are updated or content substantially deviates, this check needs to be re-executed);` | Current item compliant, skip and continue                      |
| Multi-step action block | `migrate to references/:` + indented sublist                | Execute a group of ordered sub-operations; non-terminating line ends with `：`, sub-operation lines end with `；` |
| Introduce suggestion    | `suggest introducing corresponding directory;`             | Give suggestion but not enforce                                |
| Block interaction       | `Provide options via AskUserQuestion, block and wait for user selection:` + indented sublist `- Option -> action, then proceed to next step;` | Pause execution, provide structured options to user via UI component and wait for selection |

#### Example: Terminate Flow

```markdown
- Check if target exists:
  - Yes -> next step;
  - No -> report "Target does not exist", terminate flow;
```

> **Difference from "next step"**: `terminate flow` is a flow-level end; all subsequent steps are not executed. `next step` only ends the current judgment and continues with the next operation within the same step.

### Dangerous Scenario Analysis

> **Scenario 1: Missing negative branch**
> _Example_: `If file exists, read content` -> missing behavior for "when file does not exist"
> _Problem_: AI may error out or skip when file does not exist, behavior unpredictable
> _Correct_: Explicit `No -> prompt user file does not exist and exit`
>
> **Scenario 2: Multiple branches compressed**
> _Example_: `If A then X, if B then Y` -> two independent conditions written on the same line
> _Problem_: AI finds it difficult to determine if A and B are mutually exclusive, may execute both X and Y
> _Correct_: Split into two independent tree-shaped judgment blocks
>
> **Scenario 3: Hierarchy confusion**
> _Example_: `If A is true, execute B; if C is true, execute D`
> _Problem_: Is C a sub-condition of A or a sibling condition? AI cannot determine
> _Correct_: Use indentation to distinguish parent-child hierarchy
>
> **Scenario 4: Specification files themselves violate the specification**
> _Example_: Example 3 of this specification previously had `- No -> next step` missing the line-ending semicolon (now fixed), but the standard format and Example 1 both end with `；`
> _Problem_: When AI learns format based on specification files, inconsistent examples lead to random behavior (sometimes adding semicolons, sometimes not)
> _Correct_: Specification files themselves must pass their own verification checklist, ensuring strictly consistent format across examples
>
> **Scenario 5: Conditional polarity causing AI behavior deviation**
> _Example_: `If description format does not meet requirements, provide options via AskUserQuestion`
> _Problem_: Negative polarity condition ("does not meet requirements") + only single branch; AI may miss the "format already compliant" path
> _Real case_: In Code Review, AI sent correctly formatted descriptions through the fix flow because the original condition did not define behavior for "when compliant"
> _Correct_: Always use positive polarity conditions ("whether exists", "whether satisfied"), positive and negative branch boundaries naturally align
>
> **Scenario 6: Inconsistent quote styles causing format learning disorders**
> _Example_: Earlier version of this specification used `「Yes」` in one example and `"Already compliant"` in another; angle quotes and curly quotes mixed in the same file
> _Problem_: When AI learns format based on specification files, inconsistent quote styles cause AI to randomly pick one style when generating new content
> _Correct_: Uniformly use Chinese curly quotes `""`, prohibit `「」` in Chinese body text (refer to [Punctuation Convention](punctuation-convention.md) Rule 3)
>
> **Scenario 7: Adding new symbol rules without retroactively verifying specification files themselves**
> _Example_: Punctuation-convention.md Rule 6.2 prohibits consecutive full-width em dashes, but its own Rule 1.1 previously used `——` (double em dash)
> _Problem_: After adding new rules, specification files themselves are not immediately scanned, causing the self-contradiction of "rule prohibits its own content"
> _Correct_: After adding new punctuation rules, immediately execute the verification checklist on the specification files themselves

### Common Anti-patterns

#### Anti-pattern 1: Implicit else

Only the "Yes" branch exists, missing the "No" branch.

> **Wrong**: `If [fieldname] is missing, interactively confirm` -> missing "No" branch (what to do when [fieldname] exists?)
> **Correct**:
>
> ```markdown
> - Check if name exists:
>   - Yes -> next step;
>   - No -> provide confirmation options via AskUserQuestion (generated by AI based on context), block and wait for user selection;
> ```

#### Anti-pattern 2: Inline Nesting

Writing nested conditions in parentheses or on the same line.

> **Wrong**: `Migrate to references/ (if filename already exists, interactively confirm overwrite, merge, or skip)`
> **Correct**: Use indentation levels to expand:
>
> ```markdown
> - Migrate to references/:
>   - Does filename already exist:
>     - Yes -> provide options via AskUserQuestion, block and wait for user selection:
>       - Overwrite -> overwrite file, then proceed to next step;
>       - Merge -> merge content, then proceed to next step;
>       - Skip -> keep original file, then proceed to next step;
>     - No -> next step;
> ```

#### Anti-pattern 3: Missing Arrows

Branch content exists but `Yes ->` / `No ->` is not marked.

> **Wrong**:
>
> ```markdown
> - Check if file exists;
>   - Read content;
>   - Prompt user;
> ```
>
> **Problem**: Indentation does not equal branching. Is "Prompt user" for when it doesn't exist?
> **Correct**: Explicitly mark arrows

#### Anti-pattern 4: Missing Idempotent Guard

Not checking existing compliance status for "whether already conforms to specification," directly sending all matching items into the optimization flow.

> **Wrong**: `Check if Workflow contains interaction points -> Yes -> optimize based on interaction writing standard`
> **Problem**: Already compliant content gets "optimized" a second time, potentially causing format deformation or introducing new issues
> **Correct**: Add secondary check `Already using AskUserQuestion standard format? -> Yes -> next step (current content already meets the section's template requirements, marked as compliant, skip this round of optimization; when template requirements are updated or content substantially deviates, this check needs to be re-executed)`

#### Anti-pattern 5: Conditional Polarity Misalignment

Conditional words do not match branch semantics.

> **Wrong**: `When X does not meet requirements:` - Yes -> fix; - No -> next step;
> **Problem**: The condition itself is negative polarity ("does not meet requirements"); `Yes ->` corresponds to "does not meet," which is intuitive but misleading. Additionally, "When..." is a single-path sentence pattern, not suitable for binary branches.
> **Correct**: `Check if X meets requirements:` - Yes -> next step; - No -> fix;

#### Anti-pattern 6: Implicit Flow Control

Branches fail to explicitly declare post-execution flow direction.

> **Wrong**:
>
> ```markdown
> - Verify target file exists:
>   - Yes -> read content;
>   - No -> report error and exit;
> ```
>
> **Problem**: Where does it go after "read content"? Does the flow terminate after "report error and exit"? AI can only guess.
> **Correct**: Explicitly annotate "next step;" or "terminate flow;".

## Interaction Writing Standard

Standardize the writing of interaction points involving user decisions in SKILL.md, ensuring AI correctly uses the `AskUserQuestion` tool for blocking UI confirmation, rather than replacing it with plain text questions.

### Rule 1: Interaction Confirmation Rules in Rules

`## Rules` must include behavior fallback for using `AskUserQuestion`.

**Must include rule**:

```markdown
- All interaction points involving user decisions (confirming fix plans, choosing processing methods, confirming deletion/overwrite/merge, etc.) **must** use the `AskUserQuestion` tool; plain text follow-up questions are prohibited; pass questions and options structurally into AskUserQuestion, each call ≤ 4 questions;
```

Purpose: Provide fallback for interaction operations that are not explicitly configured;

### Rule 2: Interaction Writing Paradigm in Workflow

Steps involving user decisions in Workflow must be written in a fixed paradigm, ensuring the structured options generated by AI are clear and executable.

> **Standard paradigm**: `Provide options via AskUserQuestion, block and wait for user selection:` + indented sublist
>
> ```markdown
> - OptionA -> corresponding action, then proceed to next step;
> - OptionB -> corresponding action, then proceed to next step;
> - OptionC -> corresponding action, then proceed to next step;
> ```

#### Example 1: Single-Condition Interaction

```markdown
**Original**

Interactively confirm overwrite, merge, or skip;

**Optimized**

Provide options via AskUserQuestion, block and wait for user selection:
  - Overwrite -> overwrite file, then proceed to next step;
  - Merge -> merge content, then proceed to next step;
  - Skip -> keep original file, then proceed to next step;
```

#### Example 2: Confirmation Interaction

```markdown
**Original**

User confirms whether to adopt, leave blank, or skip;

**Optimized**

Provide options via AskUserQuestion, block and wait for user selection:
  - Adopt -> next step;
  - Leave blank -> next step;
  - Skip -> next step;
```

> **Dangerous scenario**: Using vague expressions to replace the paradigm
> _Example_: `Ask user how to handle` -> AI may output plain text questions instead of calling the tool
> _Correct_: `Provide options via AskUserQuestion, block and wait for user selection:` + indented sublist

### Rule 3: Dynamic Options

When option content depends on context analysis results and cannot be pre-enumerated in SKILL.md, use the dynamic options pattern.

> **Standard paradigm**: `Provide options via AskUserQuestion, block and wait for user selection:`
>
> ```markdown
> - [Dynamic options generated by AI based on [analysis target]] -> execute corresponding option operation, then proceed to next step;
> ```

#### Example: Context-Dependent Options

```markdown
**Original**

Need user to confirm the fix plan for description format;

**Optimized**

Provide options via AskUserQuestion, block and wait for user selection:
  - [Dynamic options generated by AI based on description missing type] -> execute corresponding fix, then proceed to next step;
```

> **Applicable condition**: Used when options depend on specific characteristics of the content to be optimized (such as missing type, non-compliant item content, split domain), and predefined options are not feasible.

<a id="option-flow-annotation"></a>

### Rule 4: Option Flow Annotation

Each `AskUserQuestion` option must be followed by an explicit action flow annotation, ensuring AI can clearly determine the next behavior after user selection.

> **Standard format**:
>
> ```markdown
> Provide options via AskUserQuestion, block and wait for user selection:
>     - Overwrite -> overwrite file, then proceed to next step;
>     - Merge -> merge content, then proceed to next step;
>     - Skip -> keep original file, then proceed to next step;
> ```

#### Example: Interaction with Flow Annotation

```markdown
**Original**

Provide options via AskUserQuestion (overwrite / merge / skip), block and wait for user selection;

**Optimized**

Provide options via AskUserQuestion, block and wait for user selection:
  - Overwrite -> overwrite file, then proceed to next step;
  - Merge -> merge content, then proceed to next step;
  - Skip -> keep original file, then proceed to next step;
```

> **Key improvement**: Without flow annotation, AI's behavior direction after user selection is unclear. After adding `-> action; next step`, each option's behavior is uniquely determined.
>
> **Dynamic option adaptation**: Dynamic options also need flow annotation; attach a flow template when describing the dynamic option scope:
> ```markdown
> Provide options via AskUserQuestion, block and wait for user selection:
>     - [Dynamic options generated by AI based on [analysis target], each option annotated with flow direction] -> corresponding action, then proceed to next step;
> ```

### Common Anti-patterns

#### Anti-pattern 1: Plain Text Follow-up

Replacing `AskUserQuestion` tool call with a regular message.

> **Wrong**: `Confirm with user whether to delete`
> **Problem**: AI outputs text instead of UI confirmation, may not block and wait
> **Correct**:
>
> ```markdown
> Provide options via AskUserQuestion, block and wait for user selection:
>     - Delete -> delete file, then proceed to next step;
>     - Keep -> keep file, then proceed to next step;
> ```

#### Anti-pattern 2: Missing Option Description

Only mentioning "ask user" without providing specific options.

> **Wrong**: `Ask user to choose processing method`
> **Problem**: AI doesn't know which options to provide, may miss key options
> **Correct**:
>
> ```markdown
> Provide options via AskUserQuestion, block and wait for user selection:
>     - Overwrite -> overwrite file, then proceed to next step;
>     - Merge -> merge content, then proceed to next step;
>     - Skip -> keep original file, then proceed to next step;
> ```

#### Anti-pattern 3: Excessive Options

More than 4 questions in a single call.

> **Wrong**: One `AskUserQuestion` call containing 6 questions
> **Problem**: UI display is confusing, user decision burden is high
> **Correct**: Split into multiple calls, each with ≤ 4 questions

#### Anti-pattern 4: Missing Flow Annotation

Options only list names, without annotating behavior direction after selection.

> **Wrong**: `Provide options via AskUserQuestion (overwrite / merge / skip), block and wait for user selection`
> **Problem**: After user selects "Overwrite," AI is uncertain about the specific behavior and may execute incorrect subsequent operations
> **Correct**:
>
> ```markdown
> Provide options via AskUserQuestion, block and wait for user selection:
>     - Overwrite -> overwrite file, then proceed to next step;
>     - Merge -> merge content, then proceed to next step;
>     - Skip -> keep original file, then proceed to next step;
> ```

## Review List

The target SKILL.md's `## Review List` section contains the checklist of items to verify after execution is complete.

### Review List Writing Rules

- When Review List references external verification checklists, it must point to a specific sub-group anchor (e.g., `#interaction-standard-verification`), not reference an ungrouped complete checklist
- Each check item in Review List should cover all sub-conditions of the corresponding Rule, not just cover part

## Verification Checklist

### Structure Verification

- [ ] Workflow includes three Secure steps (Pre-check, Review Check, Output)
- [ ] Step numbers start from 0, incrementing sequentially
- [ ] Sub-steps use indented bullet list (`-`), numeric numbering only for loop jumps/reference scenarios
- [ ] Each step title follows format `N. **Title** — Description;`
- [ ] Step titles do not use Markdown heading levels (`###`) to define

### Branch Logic Verification

- [ ] Each condition check has explicit `Yes ->` and `No ->` branches
- [ ] Nested branches correctly express parent-child hierarchy through indentation
- [ ] Each branch points to specific, executable operation instructions
- [ ] No nested conditions within parentheses (Anti-pattern 2)
- [ ] No implicit else (Anti-pattern 1)
- [ ] No multiple independent conditions written on the same line (Dangerous Scenario 2)
- [ ] Judgments of "whether already conforms to specification" include secondary idempotent guard (compliant -> skip)
- [ ] Set iteration uses "sequentially check each..." prefix, not "check if... exists"

### Format Verification

- [ ] Each terminating branch line ends with `；`; non-terminating branch lines introducing sub-conditions or sub-operation lists end with `：`
- [ ] All examples within the specification file itself have strictly consistent format (self-referential consistency)
- [ ] Conditional polarity matches: condition words use positive polarity ("whether exists", "whether satisfied"), not negative polarity ("whether not satisfied", "if missing")
- [ ] Branch endpoints explicit: each `Yes ->` / `No ->` branch ends with a specific action, not a bare condition
- [ ] Multi-step action block colon alignment: non-terminating lines (introducing sub-operations) end with `：`, sub-operation lines end with `；`
- [ ] Quote style consistent: use Chinese curly quotes `""` for quoted text, do not use `「」` (refer to [Punctuation Convention](punctuation-convention.md) Rule 3)
- [ ] Review List references external verification checklists using specific sub-group anchors (`#anchor-name`); only reference `#verification-checklist` when the target file's verification checklist has no sub-groups

### Interaction Standard Verification

- [ ] Rules include behavior constraint rules for using `AskUserQuestion`
- [ ] Each interaction point in Workflow uses standard paradigm `Provide options via AskUserQuestion, block and wait for user selection:` + indented sublist
- [ ] Each interaction step provides clear 2-4 options, or annotates the dynamic options pattern (generated by AI based on context)
- [ ] Dynamic options pattern correctly annotates the basis and scope for AI option generation
- [ ] Each `AskUserQuestion` call has ≤ 4 questions
- [ ] No expressions using plain text instead of interactive confirmation exist
- [ ] Each option is annotated with action flow direction (`Option -> action;`), no flow blind spots
