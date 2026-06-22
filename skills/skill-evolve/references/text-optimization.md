# Text Simplification Rules and Safety Boundaries — Compression Rules and Safety Constraints to Follow When Streamlining SKILL.md Content

## Overview

When streamlining SKILL.md content, follow these rules to compress text length while ensuring no loss of key semantics, preventing AI from missing actions or misjudging behavior due to overly brief instructions.

## Core Principle

> Simplification can reduce the "length" of text, but cannot compress the "semantic density" of information.

**Judgment Standard**: If removing a sentence could cause the AI to make a different decision or miss an action, it cannot be omitted.

## Global Protection

> Any interaction decision sentence containing `AskUserQuestion` is exempt from simplification. None of the compression rules in this document (including Rule 1 Positive Command Conversion) apply. The AskUserQuestion whitelist in each rule serves as supplementary explanation, further elaborating the reasons why simplification is prohibited under each rule.

## Rule 1: Positive Command Conversion

Change "create if not exists" to "ensure exists."

> **Safe scenario**: Pure technical operation, no timing requirement
> _Example_: `create directory if not exists` -> `ensure directory exists`
>
> **Dangerous scenario**: Involves execution timing or order
> _Example_: `if references/ directory does not exist, create before migration` -> cannot be simplified to `ensure references/ directory exists`
> _Reason_: Loses the "before migration" time point, AI might create it at the end of the entire flow

## Rule 2: Remove Redundant Verbs

Delete step descriptions that AI can implicitly infer.

> **Safe scenario**: Implicit prerequisite steps AI would execute by default
> _Example_: `read the file, evaluate content` -> `evaluate content`
>
> **Dangerous scenario**: Interactive actions that AI would only execute when explicitly declared
> _Example_: `if violations found after check, return to corresponding step for correction` -> cannot be simplified to `check for violations`
> _Reason_: Removes the iterative fix semantics in the validation loop, AI might directly mark failures instead of returning to fix
>
> **Whitelist**: `AskUserQuestion` paradigm statements
> _Example_: `Provide options via AskUserQuestion, block and wait for user selection:` + indented sublist -> "block and wait for user selection" cannot be simplified to "confirm"
> _Reason_: "Block and wait" is a key behavioral constraint for tool invocation; simplifying it may cause AI not to wait for user response

## Rule 3: Omit Self-Explanatory Content

Delete supplementary descriptions in parentheses that can be understood without explanation.

> **Safe scenario**: Parenthetical content is purely supplementary information
> _Example_: `show split plan (list filenames to be created)` -> `show split plan`
>
> **Dangerous scenario**: Parenthetical content contains boundary conditions or exceptions
> _Example_: `confirm overwrite, merge, or skip (when filename already exists)` -> cannot omit "when filename already exists"
> _Reason_: Lacking boundary condition constraints, AI might execute the confirmation flow for all files rather than only when conflicts occur
>
> **Whitelist**: Option lists in `AskUserQuestion` paradigm statements
> _Example_: `Provide options via AskUserQuestion, block and wait for user selection:` + indented sublist -> options cannot be omitted
> _Reason_: Options are structured parameters of the interaction tool; omitting them prevents AI from determining which options to provide

## Rule 4: Semantic Deduplication

Merge multiple sub-items pointing to the same concern.

> **Safe scenario**: Two sub-items have identical boundary conditions
> _Example_: `check if links are valid; fix invalid links` -> `fix invalid links`
>
> **Dangerous scenario**: Two sub-items appear similar but have different boundaries
> _Example_: `scan SKILL.md for all links pointing to original REFERENCE.md; update to new split file paths` -> cannot be merged into `update links`
> _Reason_: Loses two independent operation instructions: "scan scope" and "replacement target"
>
> **Whitelist**: "Definition + Constraint" closed loop containing `AskUserQuestion`
> _Example_: Interactive confirmation definition in Definitions and interaction constraint rule in Rules -> cannot be merged into one
> _Reason_: They form a "definition + execution constraint" closed loop, respectively constraining tool purpose and behavior boundary; merging may cause AI to follow only one

## Rule Application Priority

The 4 rules are ordered from lowest to highest risk, recommended to execute sequentially in the following order:

| Priority | Rule                    | Risk Level | Reason                                                                            |
| -------- | ----------------------- | ---------- | --------------------------------------------------------------------------------- |
| 1        | Positive Command        | 🟢 Low     | Pure syntactic conversion, does not change information volume                     |
| 2        | Remove Redundant Verbs  | 🟢 Low     | Removes steps AI already implicitly executes; `AskUserQuestion` paradigm is whitelist |
| 3        | Omit Self-Explanatory   | 🟡 Medium  | Need to confirm parentheses do not contain boundary conditions; `AskUserQuestion` option list is whitelist |
| 4        | Semantic Deduplication  | 🔴 High    | Need to confirm two items have identical boundary conditions; `AskUserQuestion` definition+constraint loop not merged |

**Execution Strategy**: Start from low risk, check each rule one by one. For high-risk rules, if uncertain, keep the original text rather than forcibly simplifying.

> **Relationship with other specifications**: The expanded formats defined in `workflow-standard.md` (tree branches, interaction patterns, idempotent guards, etc.) take priority over the compression rules in this document. When the same text satisfies both expansion and compression conditions, retain the expanded format. For example: tree branches expanded per `workflow-standard.md` (`yes -> / no ->`), idempotent guards (`(compliant, skipping optimization)`), and sequential judgment prefixes cannot be re-compressed into single-line conditions by the rules in this document.

## Composite Scenario Example

The following demonstrates a real SKILL.md paragraph, optimized using multiple rules.

**Original paragraph:**

```markdown
1. Access the config file, check if it exists; if not, prompt the user "config file missing" and exit;
2. Read config file content, verify config item completeness;
3. For missing config items, check if default values exist; if yes, use default values to fill; if not, skip that item;
4. Return the final config object;
```

**Rule-by-rule analysis:**

| Rule                     | Application Location             | Safe? | Reason                                                    |
| ------------------------ | -------------------------------- | ----- | --------------------------------------------------------- |
| Positive Command         | Line 1 "check if exists"         | ✅    | Pure operation conversion                                 |
| Positive Command (merge) | Line 1 "otherwise prompt and exit" | ✅  | Does not involve AskUserQuestion interactive confirmation, safe to merge |
| Remove Redundant Verbs   | Line 1 "access", Line 2 "read"   | ✅    | AI reads target files by default                          |
| Semantic Deduplication   | Line 3 two "if" conditions       | ❌ Skip | Former needs default value fill, latter needs skip; different operations |

**Optimized paragraph:**

```markdown
1. Ensure config file exists; otherwise prompt user and exit;
2. Verify config item completeness;
3. For missing config items: if default exists, fill; otherwise skip;
4. Return the final config object;
```

**Result**: Original 92 characters -> optimized 55 characters, reduced by 40%, with complete semantics.

## Common Anti-patterns

### Anti-pattern 1: Over-Merging

Forcibly merging operations with different boundary conditions into one sentence.

> **Wrong**: `Check for uncommitted changes; check for unpushed commits` -> `Check git status`
> **Problem**: After merging, AI might only execute `git status` once, not distinguishing between uncommitted and unpushed
> **Correct**: Explicitly keep two independent actions, or merge into `Check for uncommitted changes and unpushed commits`

### Anti-pattern 2: Over-Omission

Removing instructions related to user interaction, assuming AI will "automatically" communicate.

> **Wrong**: `Create directory if not exists` (omitting the original "ask user for confirmation")
> **Problem**: AI silently creates the directory without the user's knowledge
> **Correct**: Keep the interaction instruction `Create after confirming with user`

### Anti-pattern 3: Over-Positivization

Forcibly converting conditional timing instructions to "ensure," losing execution order.

> **Wrong**: `After split is complete, update all links in SKILL.md` -> `Ensure links are updated`
> **Problem**: AI might update links before splitting, reversing the order
> **Correct**: Retain order relationship `Update links after split`

### Anti-pattern 4: Over-Deduplication

Merging "check scope" and "execute operation," losing operation details.

> **Wrong**: `Scan all source files; extract public functions` -> `Extract public functions`
> **Problem**: AI only executes extraction, not scanning, potentially missing files
> **Correct**: Keep both actions or merge into `Scan source files and extract public functions`

## Verification Checklist

After completing text simplification, confirm the following one by one:

- [ ] Each rule's reference source is clear (pointing to corresponding rule number)
- [ ] Deleted content does not belong to user interaction instructions
- [ ] Deleted content does not contain boundary conditions or exceptions
- [ ] Merged items indeed point to the same concern
- [ ] Execution timing/order relationships have not been diluted to "ensure"
- [ ] Simplified instructions can still produce non-duplicate, non-omitted results when executed by AI
