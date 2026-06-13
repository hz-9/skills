---
name: skill-optimizer
description: Optimize SKILL.md directory structure, condense redundant content, and split reference documents to improve readability and maintainability. Use when the user needs to improve, refactor, or standardize an existing SKILL.md.
---
# Skill Optimizer

## Overview

Standardize and optimize existing SKILL.md files: align with the standard template structure, condense redundant content, and split reference documents to improve maintainability.

## Definitions

- **Similar-meaning directory**: A directory with the same semantics as a standard directory but a different historical name (e.g., `Description`↔`Overview`, `Checklist`↔`Review List`). The AI automatically identifies whether such directories exist and their corresponding target directories; adoption is confirmed by the user;
- **Reference hierarchy**: SKILL.md directly linking to files under `references/` is one level; `references/` files then linking to external resources is two levels and should be avoided.

## Prerequisites

The target to be modified and optimized must already exist. This SKILL is for optimization, not creation from scratch. To create a skill from scratch, use `skill-create`.

## Workflow

1. **Structure alignment** — Compare against the [template](template.md), fill in missing directories, and adjust directory order;
   - Check frontmatter: confirm that `name` and `description` fields exist;
     - description must satisfy the format requirements in [Rules](#rules) (first sentence: capability + second sentence: trigger + third person + ≤1024 characters);
     - If missing or non-compliant, interactively confirm the fix approach;
   - Missing directories: the AI automatically identifies whether similar-meaning directories exist and presents them to the user, who confirms whether to adopt, leave empty, or skip;
2. **Content condensation** — Check and clean up SKILL.md content;
   - Content not in the template's standard directories → migrate to `references/` (if a file with the same name exists, interactively confirm overwrite, merge, or skip);
   - After migration, update internal links in the migrated content that point to the original location;
   - Line count must not exceed 300 lines; content exceeding 300 lines or containing large amounts of complex content must be migrated to `references/` (prioritize reducing blank lines, then compress with [text simplification rules](references/text-optimization.md); compressing semantic density is prohibited);
   - Remove time-sensitive information; maintain terminology consistency;
   - Determine whether to add a `scripts/` directory: recommended if the skill includes deterministic operations (validation, formatting), code that would be repeatedly generated, or logic requiring explicit error handling;
3. **Reference document splitting** — If `REFERENCE.md` exists, present the split plan first, then execute after confirmation:
   - Split by domain into multiple files under `references/`; if a file with the same name exists, interactively confirm overwrite, merge, or skip;
   - After splitting, update all links in SKILL.md pointing to the original file;
4. **Review check** — Compare against the [Review List](#review-list), verify optimization results item by item;
   - If any check item fails → return to the corresponding step to fix, until all pass or the user confirms to skip;
   - Once all pass, output an optimization summary (line count comparison, directory completion status, reference document split status, etc.), and notify that optimization is complete;

## Rules

- The description must follow the format: the first sentence states what the skill can do, the second sentence states the trigger condition ("Use when..."), using third person, not exceeding 1024 characters;
- Before deleting any file, always ask the user for confirmation through interactive questioning;
- Only recommend editing files in `SKILL.md` and the `references/` directory (moving/deleting REFERENCE.md or template.md at the root is an exception within this scope and requires interactive confirmation);
- REFERENCE.md should be moved to the `references` folder and split into multiple files;
- For every operation involving file movement, splitting, or deletion, side effects caused by that operation must be handled synchronously (such as updating link references, fixing relative paths);
- The directory structure standard applies only to the SKILL.md file of the target SKILL itself and does not affect other files in the directory;
- Reference hierarchy must not exceed one level: SKILL.md may directly link to files under `references/`; files under `references/` should not link to external resources;

## Examples

### Interactive Conversation Examples

**Example: AI automatically invokes based on trigger conditions**

```
User > Help me optimize this SKILL.md, the structure feels a bit messy
AI > Detected user needs optimization, triggered skill-optimizer skill
AI > Reading target SKILL.md, checking directory structure against template...
     Missing directory: Review List
     Extra directory: Changelog (not in template)
AI > Missing "Overview" directory...
     Please choose how to handle:
     1. Migrate xxxxx directory (a similar-meaning directory; this option does not appear if none exists)
     2. Set to "None yet" for manual handling later
AI > Found "Changelog" directory, which does not exist in the template.
     Please choose how to handle:
     1. Migrate to references/ folder
     2. Delete
User > 1
AI > Changelog content has been migrated to references/changelog.md
AI > Directory structure alignment complete, starting content quality check...
     Found time-sensitive information: v1.2.0, 2024-03-15
AI > Content cleanup in progress… time-sensitive info removed, current 92 lines (<300), no splitting needed
AI > Review check starting… description format correct ✓, 92 lines (<300) ✓, reference hierarchy one level ✓, dead links fixed ✓, all passed.
```

### Execution Success Examples

| Dimension | Before Optimization | After Optimization |
|-----------|--------------------|--------------------|
| SKILL.md lines | 150 lines | 85 lines |
| Directory completeness | Missing Prerequisites, Review List | All directories filled |
| Time-sensitive info | Contains v2.1.0, 2024-05-01, etc. | All removed |
| Reference document organization | REFERENCE.md single file | Split into 3 independent files under references/ |
| Trigger condition | Vague description | Clearly includes "Use when..." |

## Review List

After optimization completes, verify the following:
- [ ] description includes trigger condition ("Use when...") and does not exceed 1024 characters
- [ ] SKILL.md does not exceed 300 lines; content exceeding 300 lines or with large amounts of complex content has been migrated to references/
- [ ] Content quality: no time-sensitive info, consistent terminology, includes concrete examples with values matching rules
- [ ] References and links: reference hierarchy does not exceed one level, no dead links, no unresolved placeholders
- [ ] After content condensation, verify against the [text simplification verification checklist](references/text-optimization.md#verification-checklist)
- [ ] Extended directories: scripts/, tests/, or schemas/ have been evaluated if needed

## References

- [SKILL Directory Structure](references/directory-structure.md)
- [SKILL Template](template.md)
- [Text Simplification Rules](references/text-optimization.md)
