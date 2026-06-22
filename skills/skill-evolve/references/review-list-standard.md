# Review List Writing Standard — Define Review List Writing Conventions and Type Adaptation Standards

## Overview

Review List validates output quality (result), defining what the result should look like after completion.

## Content Boundary

- **Should be in Review List**: Result validation items, quality acceptance criteria
- **Should NOT be in Review List**: AI behavior constraints (go in Rules), execution step descriptions (go in Workflow)

## Inline vs Anchor Reference Standard

- **Use anchor reference** (avoid duplication): When check items are already fully defined in a reference file's `## Verification Checklist`
- **Keep inline**: Only for check items unique to this SKILL or requiring specific context

## Type Adaptation

- **Meta-skill** (skills that modify/validate SKILL.md): Review includes structural checks (metadata, standard sections, Secure steps, consistency)
- **Domain/Action skill** (skills that execute specific tasks): Review only validates output/result quality

## Grouping Recommendation

Group by quality dimension, with group names and order aligned with [Rules grouping scheme](rules-standard.md#grouping-recommendation).

> **Note**: The grouping order consistency requirement only applies to newly optimized or re-aligned skills. For automatic re-alignment of existing Review Lists, confirmation via AskUserQuestion is required before proceeding.

## Verification Checklist

- [ ] All check items validate output quality (result), not AI behavior
- [ ] Check items that can be covered via anchor reference are not duplicated inline
- [ ] Group structure aligns with Rules' Concern Separation principle
- [ ] Variable declaration completeness: all cross-step workflow variables are declared in Definitions in the format "是否 xxx"
- [ ] Review List grouping order is consistent with Rules grouping order
