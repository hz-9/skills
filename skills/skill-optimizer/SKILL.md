---
name: skill-optimizer
description: Use when writing and optimizing SKILL.md content.
---

## Skill Optimizer

## Description

Optimize `SKILL.md` content to resolve unclear directory structures and redundant documentation content.

## Prerequisites

The target to be modified and optimized already exists; the purpose of this SKILL is optimization, not creating from scratch.

## Workflow

1. Compare the sections of the target `SKILL.md` with the [template](template.md);
  - If a section is missing, identify if there are other sections with similar meaning, and present options through interactive questioning:
    - 1. Adopt an existing section (if a similarly-meaning section exists)
    - 2. Set to "None yet" for manual input later;
  - If the section already exists, skip;
2. Check the content of `SKILL.md`;
  - Sections not present in the [template](template.md) should be moved to the `references` folder;
  - Adjust the section order of `SKILL.md` to match the [template](template.md);
  - `SKILL.md` should be at most 100 lines; relevant content should be appropriately condensed;
    - First prioritize reducing unnecessary blank lines;
    - Then condense content appropriately;
  - The description in the metadata area should be at most 1024 characters; if exceeded, condense it;
  - Do not include time-sensitive information;
  - Keep terminology consistent;
3. Split `REFERENCE.md`;
  - If a `REFERENCE.md` file exists, it should be split into multiple files under the `references` folder based on different domains and content;

## Rules

- Before deleting any file, always ask the user for confirmation through interactive questioning;
- Only recommend editing the `SKILL.md` and REFERENCE.md files;
- REFERENCE.md should be moved to the `references` folder and split into multiple files;

## Examples

Refer directly to the [SKILL template](template.md)

## References

- [SKILL Directory Structure](directory-structure.md)
