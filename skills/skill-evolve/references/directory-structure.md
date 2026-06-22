# SKILL Directory Structure — Define SKILL Standard Directory Structure and references/ File Specification

## Overview

Define the standard directory structure for a SKILL and the format specification for `references/` files. Use when optimizing a target SKILL's directory structure or checking references/ file format.

## Directory Structure

```markdown
your-skill-name/
├── SKILL.md          # (Required) Core execution instructions
├── scripts/          # (Optional) Executable scripts
├── references/       # (Optional) Detailed reference documents
├── assets/           # (Optional) Static resources such as templates, images
├── tests/            # (Optional) Test cases, an important part of engineering
└── schemas/          # (Optional) Data transfer between Skills for chaining
```

## References

### references/ File Content Specification

Each specification file under `references/` (workflow-standard.md, punctuation-convention.md, text-optimization.md and their extensions) must follow this structure:

- Begins with `# [filename] — one-line responsibility description`
- Contains `## Overview` section, briefly explaining responsibilities
- Contains one or more `##` main content sections
- **Must** end with `## Verification Checklist`, listing all check items covered by this file
- `## Verification Checklist` may use `###` sub-groups to organize check items (purely for readability, does not affect referencing)

Workflow Step 3's "directory structure check" will verify that all references/ files conform to this structure.

### Self-Evolution Scenario

When the target SKILL is `skill-evolve` itself (whether self-evolving = true) in the skill's original repository, and template.md exists, template.md should also be included in the inspection scope:

- If template.md and SKILL.md share fields/cross-references, modifications to SKILL.md should verify whether template.md needs synchronous updates
- In self-evolution scenarios, Workflow Step 0's pre-check should additionally verify that template.md exists and its structure is parseable

## Verification Checklist

- [ ] File begins with `# [filename] — description` format
- [ ] Contains `## Overview` section
- [ ] Ends with `## Verification Checklist` section
- [ ] Verification checklist lists all check items covered by this file
