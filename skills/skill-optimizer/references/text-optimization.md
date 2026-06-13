# Text Simplification Rules and Safety Boundaries

## Overview

When condensing SKILL.md content, follow the rules below to reduce text length while ensuring critical semantics are preserved, avoiding AI missing actions or misjudging behavior due to overly simplified instructions.

## Rule 1: Conditional Merging

Compress if-else branches into compact expressions like "otherwise" or "vice versa".

> **Safe scenario**: Regular logic branches not involving user interaction
> *Example*: `If unavailable, exit` → `Otherwise exit`
>
> **Dangerous scenario**: Branches containing user communication instructions
> *Example*: `If unavailable, inform the user that the template file is inaccessible and exit` → Must NOT be simplified to `Otherwise exit`
> *Reason*: The AI would still exit but would no longer inform the user why, causing a silent abort

## Rule 2: Positive Imperative

Change "if not exists then create" to "ensure exists".

> **Safe scenario**: Pure technical operations with no timing requirements
> *Example*: `If directory does not exist, create it` → `Ensure directory exists`
>
> **Dangerous scenario**: Operations involving execution timing or sequence
> *Example*: `If the references/ directory does not exist, create it before migration` → Must NOT be simplified to `Ensure references/ directory exists`
> *Reason*: Loses the "before migration" timing point; the AI might create it at the end of the entire process

## Rule 3: Omit Self-Explanatory Content

Delete supplementary descriptions in parentheses that can be understood without explanation.

> **Safe scenario**: Parenthetical content is purely supplementary information
> *Example*: `Present the split plan (listing the file names to be created)` → `Present the split plan`
>
> **Dangerous scenario**: Parenthetical content contains boundary conditions or exceptions
> *Example*: `Interactively confirm overwrite, merge, or skip (when a file with the same name exists)` → Must NOT omit "when a file with the same name exists"
> *Reason*: Without the boundary condition, the AI might run the confirmation flow for all files, not just conflicts

## Rule 4: Remove Redundant Verbs

Delete procedural descriptions that the AI can implicitly infer.

> **Safe scenario**: Implicit prerequisite steps the AI would execute by default
> *Example*: `Read the file, evaluate its content` → `Evaluate its content`
>
> **Dangerous scenario**: Interactive actions the AI will only perform when explicitly stated
> *Example*: `If violations are found after checking, return to the corresponding step and fix` → Must NOT be simplified to `Check for violations`
> *Reason*: Removes the iterative repair semantics in the verification phase; the AI might directly mark it as failed instead of returning to fix

## Rule 5: Semantic Deduplication

Merge multiple items pointing to the same concern.

> **Safe scenario**: Two items have exactly the same boundary conditions
> *Example*: `Check if links are valid; fix invalid links` → `Fix invalid links`
>
> **Dangerous scenario**: Two items appear similar on the surface but have different boundaries
> *Example*: `Scan all links in SKILL.md pointing to the original REFERENCE.md; update them to the new split file paths` → Must NOT be merged into `Update links`
> *Reason*: Loses the two independent operational instructions "scan scope" and "replacement target"

## Core Principle

> Simplification can reduce the **length** of text, but must not compress the **semantic density** of information.

**Judgment standard**: After removing a sentence, would the AI possibly make a different decision or miss an action? If so, it cannot be omitted.

## Rule Application Priority

The 5 rules are ordered from low to high risk. It is recommended to execute them in the following order:

| Priority | Rule | Risk Level | Rationale |
|----------|------|------------|-----------|
| 1 | Positive Imperative | 🟢 Low | Pure sentence pattern conversion, does not change information content |
| 2 | Remove Redundant Verbs | 🟢 Low | Removes steps the AI would execute implicitly |
| 3 | Conditional Merging | 🟡 Medium | Must confirm branches do not contain user interaction instructions |
| 4 | Omit Self-Explanatory Content | 🟡 Medium | Must confirm parentheses do not contain boundary conditions |
| 5 | Semantic Deduplication | 🔴 High | Must confirm the boundary conditions of two items are exactly the same |

**Execution strategy**: Start from low-risk rules and check one by one. For high-risk rules, if unsure, preserve the original text rather than forcibly simplifying.

## Composite Scenario Example

The following shows a real SKILL.md paragraph optimized using multiple rules.

**Original paragraph:**

```
1. Access the configuration file and check if it exists; if it does not exist, prompt the user "Configuration file missing" and exit;
2. Read the configuration file content and verify the completeness of configuration items;
3. For missing configuration items, check if default values exist; if defaults exist, supplement with defaults; if defaults do not exist, skip the item;
4. Return the final configuration object;
```

**Rule-by-rule analysis:**

| Rule | Application Location | Is Safe | Rationale |
|------|---------------------|---------|-----------|
| Positive Imperative | Line 1 "check if it exists" | ✅ | Pure operation transformation |
| Conditional Merging | Line 3 nested if-else | ❌ Skip | Branch contains independent "skip the item" logic; merging might cause AI to ignore the skip behavior |
| Remove Redundant Verbs | Line 1 "Access", Line 2 "Read" | ✅ | AI reads the target file by default |
| Semantic Deduplication | Line 3 two "if" clauses | ❌ Skip | The former requires supplementing with defaults, the latter requires skipping; different operations |

**Optimized paragraph:**

```
1. Ensure the configuration file exists; otherwise prompt the user and exit;
2. Verify the completeness of configuration items;
3. For missing configuration items: supplement with defaults if available, otherwise skip;
4. Return the final configuration object;
```

**Result**: Original 99 characters → Optimized 58 characters, 41% reduction, with complete semantics.

## Common Anti-Patterns

### Anti-Pattern 1: Over-Merging

Forcibly merging operations with different boundary conditions into one sentence.

> **Wrong**: `Check if there are uncommitted changes; check if there are unpushed commits` → `Check git status`
> **Problem**: After merging, the AI might only run `git status` once without distinguishing uncommitted from unpushed
> **Correct**: Explicitly keep two independent actions, or merge as `Check for uncommitted changes and unpushed commits`

### Anti-Pattern 2: Over-Omission

Deleting instructions related to user interaction, assuming the AI will "automatically" communicate.

> **Wrong**: `If the directory does not exist, create it` (omitting "prompt user for confirmation" from the original)
> **Problem**: AI silently creates the directory, user is unaware
> **Correct**: Keep the interaction instruction: `Create after confirming with user`

### Anti-Pattern 3: Over-Positivization

Forcibly converting instructions with conditional timing into "ensure", losing execution order.

> **Wrong**: `After the split is complete, update all links in SKILL.md` → `Ensure links are updated`
> **Problem**: AI might update links before the split, reversing the order
> **Correct**: Preserve the sequential relationship: `Update links after splitting`

### Anti-Pattern 4: Over-Deduplication

Merging "check scope" and "execute operation", losing operational details.

> **Wrong**: `Scan all source files; extract common functions` → `Extract common functions`
> **Problem**: AI only performs extraction without scanning, potentially missing files
> **Correct**: Keep both actions or merge as `Scan source files and extract common functions`

## Verification Checklist

After completing text simplification, verify each of the following:

- [ ] Each rule reference is clearly sourced (points to the corresponding rule number)
- [ ] Deleted content does not belong to user interaction instructions (Silent Abort check)
- [ ] Deleted content does not contain boundary conditions or exceptions
- [ ] Merged items indeed point to the same concern
- [ ] Execution timing/sequence relationships have not been diluted into "ensure"
- [ ] The simplified instructions still allow the AI to produce non-redundant, non-omitted results
