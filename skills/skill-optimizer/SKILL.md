---
name: skill-optimizer
description: Optimizes SKILL.md directory structure, trims redundant content, and splits reference documents to improve readability and maintainability. Use when the user needs to improve, refactor, or standardize an existing SKILL.md.
---
# Skill Optimizer

## Overview

Standardize and optimize existing SKILL.md files: align with the standard template structure, trim redundant content, and split reference documents to improve maintainability.

## Definitions

- **Similar-meaning Sections**: Sections with the same semantics as standard sections but different historical names (e.g. `Description`↔`Overview`, `Checklist`↔`Review List`). The AI auto-detects their existence and the corresponding target section, then the user confirms whether to adopt, leave blank, or skip;
- **Reference Hierarchy**: SKILL.md directly linking to files under `references/` is a single level; files under `references/` linking to external resources is a second level and should be avoided.

## Prerequisites

The target to be modified and optimized already exists. This SKILL handles optimization, not creation from scratch. To create a skill from scratch, use `skill-create`.

## Workflow

1. **Structure Alignment** — Compare against the [template](template.md), fill in missing sections and adjust section order;
   - Check frontmatter: confirm `name` and `description` fields exist;
     - description must satisfy the format requirements in [Rules](#rules) (first sentence = capability + second sentence = trigger + third person + ≤1024 characters);
     - If missing or non-standard, interactively confirm the fix approach;
   - Missing sections: AI auto-detects similar-meaning sections and presents them to the user, who confirms whether to adopt, leave blank, or skip;
2. **Content Refinement** — Check and clean SKILL.md content;
   - Non-standard section content → migrate to `references/` (if a file with the same name exists, interactively confirm whether to overwrite, merge, or skip);
   - After migration, update internal links that previously pointed to the original location;
   - Line count must not exceed 300; if over 300 lines or containing a large amount of complex content, migrate to `references/` (first reduce blank lines, then apply [Text Simplification Rules](references/text-optimization.md) to compress content; do not compress semantic density);
   - Remove time-sensitive information; maintain terminology consistency;
   - Evaluate whether a `scripts/` directory is needed: if the skill includes deterministic operations (verification, formatting), code that would be regenerated repeatedly, or logic requiring explicit error handling, it is recommended to introduce one;
3. **Reference Document Splitting** — If `REFERENCE.md` exists, present a split plan first, then execute after confirmation:
   - Split by domain into multiple files under `references/`; if files with the same name exist, interactively confirm whether to overwrite, merge, or skip;
   - After splitting, update all links in SKILL.md that previously pointed to the original file;
4. **Review Check** — Verify optimization results against the [Review List](#review-list);
   - Any check item that fails → return to the corresponding step to fix, until all pass or the user confirms skipping;
   - Once all pass, output an optimization summary (line count comparison, section completion status, reference document split status, etc.) and report completion;

## Rules

- description must follow the format: first sentence describes what the skill can do, second sentence describes the trigger condition ("Use when..."), use third person, not exceeding 1024 characters;
- Any file deletion must be confirmed through an interactive question to the user;
- Only edit files under `SKILL.md` and `references/` directory (moving/deleting root-level REFERENCE.md or template.md is an exception to this scope and requires interactive confirmation);
- REFERENCE.md should be moved to the `references` folder and split into multiple files;
- After splitting REFERENCE.md, compare each section against the original to confirm no content is lost (e.g. parenthetical examples, notes, and other details are not omitted);
- For every operation involving file movement, splitting, or deletion, side effects caused by the operation must be handled synchronously (e.g. updating link references, fixing relative paths);
- Directory structure standards apply only to the target SKILL's SKILL.md file itself and do not affect other files in the directory;
- Reference hierarchy must not exceed one level: SKILL.md can directly link to files under `references/`; files under `references/` should not link to external resources;

## Examples

### Dialogue Interaction Example

**Example: AI triggers automatically based on trigger condition**

```
User > Help me optimize this SKILL.md; the structure feels a bit messy

AI > Detected user needs optimization, triggering skill-optimizer skill
AI > Reading target SKILL.md, comparing directory structure against template...
     Missing section: Review List
     Extra section: Changelog (not in template)
AI > Missing "Overview" section...
     Please choose how to handle:
     1. Migrate the xxxxx section (a similar-meaning section; if none exists, this option will not appear)
     2. Set to "None", handle manually later
AI > Found "Changelog" section, which does not exist in the template.
     Please choose how to handle:
     1. Migrate to the references/ folder
     2. Delete
User > 1
AI > Changelog content has been migrated to references/changelog.md
AI > Directory structure alignment complete, starting content quality check...
     Found time-sensitive info: v1.2.0, 2024-03-15
AI > Content cleanup in progress… time-sensitive info removed; currently 92 lines (<300), no split needed
AI > Starting review check… description format correct ✓, 92 lines (<300) ✓, single reference level ✓, dead links fixed ✓, all passed.
```

### Execution Success Example

| Dimension | Before | After |
|-----------|--------|-------|
| SKILL.md line count | 150 lines | 85 lines |
| Section completeness | Missing Prerequisites, Review List | All sections filled |
| Time-sensitive info | Contained v2.1.0, 2024-05-01, etc. | All removed |
| Reference document organization | REFERENCE.md as single file | Split into 3 independent files under references/ |
| Trigger condition | Vague description | Explicit "Use when..." included |

## Review List

After optimization, verify the following:
- [ ] description format: includes trigger condition ("Use when..."), uses third person (no you/your/we/I etc. first/second person pronouns), not exceeding 1024 characters
- [ ] SKILL.md does not exceed 300 lines; if over 300 lines or containing a large amount of complex content, migrate to references/
- [ ] Content quality: no time-sensitive info, consistent terminology, includes concrete examples with values matching rules
- [ ] References & links: reference hierarchy not exceeding one level, no dead links (including in-file #anchor links that resolve to correct headings), no unresolved placeholders
- [ ] Post-split content integrity: each section compared against original, no content lost
- [ ] After content trimming, verify against the [Text Simplification Verification Checklist](references/text-optimization.md#verification-checklist) item by item
- [ ] Extension directories: whether scripts/, tests/, or schemas/ needs to be introduced has been evaluated

## References

- [SKILL Directory Structure](references/directory-structure.md)
- [SKILL Template](template.md)
- [Text Simplification Rules](references/text-optimization.md)
