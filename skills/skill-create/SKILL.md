---
name: skill-create
description: Create a new agent skill with proper structure, progressive information disclosure, and packaged resources. Use when the user wants to create, write, or build a new skill.
---

# Create a Skill

## Overview

Create a new agent skill from scratch. Organize content per the standard template structure, package directory layout and reference documents. After creation, can be further optimized by `skill-optimizer`.

## Definitions

- **Standard template structure**: The SKILL.md standard structure maintained by skill-optimizer, consisting of eight sections: Overview, Definitions, Prerequisites, Workflow, Rules, Examples, Review List, References;
- **Reference hierarchy**: SKILL.md directly linking to files under `references/` is one level; files under `references/` should not link to external resources.

## Prerequisites

- `skill-optimizer` must be installed (this skill depends on its template.md and directory-structure.md);
- Be clear about what problem the skill solves and in what scenarios it triggers;
- Have relevant domain knowledge.

## Workflow

1. **Gather requirements** — Ask the user about:
   - What task/domain does the skill involve?
   - What specific use cases should it handle?
   - Does it need executable scripts or just instructions?
   - Are there any reference materials?
   - Are there complementary or boundary relationships with other skills?

2. **Create directory structure** — Refer to the [directory structure standard](../skill-optimizer/references/directory-structure.md) to create files and folders, at minimum creating `SKILL.md`;

3. **Draft SKILL.md** —
   - Refer to the [SKILL template](../skill-optimizer/template.md) and organize content in the standard directory order;
   - The description must follow the format requirements in [Rules](#rules);
   - Write a guide sentence for each section to help the AI understand its purpose;
   - SKILL.md must not exceed 300 lines; content exceeding 300 lines or containing large amounts of complex content should be split into `references/`;

4. **Add auxiliary directories** —
   - `references/`: Move useful content that is not in the template standard sections here;
   - `scripts/`: Deterministic operations, repeatedly generated code, or logic requiring explicit error handling;
   - `assets/`: Templates, images, and other static resources;
   - `schemas/`: Scenarios requiring data exchange with other skills;
   - `tests/`: Engineering testing scenarios;

5. **Review with user** — Present the draft and confirm: does it cover the use cases, is anything missing, are there sections needing adjustment;

6. **Final check** — Refer to the [Review List in template.md](../skill-optimizer/template.md#review-list) and verify item by item.

## Rules

- The description must follow the format: the first sentence states the skill's capability, the second sentence states the trigger condition ("Use when..."), using third person, not exceeding 1024 characters;
- SKILL.md must not exceed 300 lines;
- Reference hierarchy must not exceed one level (SKILL.md linking to files under `references/` is one level; files under `references/` should not link to external resources);
- Remove any time-sensitive information;
- Maintain terminology consistency;
- Include concrete examples with values matching the rules;

## Examples

### Interactive Conversation Example

**Example: AI automatically invokes based on trigger conditions**

```
User > I want a skill that automatically cleans up local Git branches
AI   > Detected user needs a new skill, triggered skill-create
AI   > Gathering requirements: What task/domain does the skill involve?
User > Just list merged local branches and delete them safely
AI   > Do you need executable scripts?
User > No
AI   > Any reference materials?
User > No
AI   > Creating git-branch-cleanup/SKILL.md per directory structure standard
AI   > Drafting SKILL.md per template structure...
      description format complies ✓
      85 lines (<300, no splitting needed) ✓
AI   > Please review the draft. Does this cover your use case?
User > Looks good
AI   > Final check: referring to template.md's Review List ✓
      Skill created!
```

### Execution Success Example

| Dimension | Description |
|-----------|-------------|
| Files created | SKILL.md |
| Structure | Aligned with all standard template sections |
| Lines | 85 lines (<300) |
| Auxiliary directories | None |

## Review List

Refer to the [Review List in template.md](../skill-optimizer/template.md#review-list) and verify item by item.

## References

- [SKILL Directory Structure](../skill-optimizer/references/directory-structure.md)
- [SKILL Template](../skill-optimizer/template.md)
