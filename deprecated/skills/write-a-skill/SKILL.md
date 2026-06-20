---
name: write-a-skill
description: Create a new agent skill with proper structure, progressive information disclosure, and bundled resources. Use when the user wants to create, write, or build a new skill.
---

# Writing a Skill

## Process

1. **Gather Requirements** - Ask the user:
   - What task/domain does this skill cover?
   - What specific use cases should it handle?
   - Does it need executable scripts or just instructions?
   - Are there any reference materials to include?

2. **Draft Skill** - Create:
   - A SKILL.md with concise instructions
   - Additional reference files if content exceeds 500 lines
   - Utility scripts if deterministic operations are needed

3. **Review with User** - Present the draft and ask:
   - Does this cover your use case?
   - Anything missing or unclear?
   - Are there sections that need more or less detail?

## Skill Structure

```
skill-name/
├── SKILL.md           # Main instructions (required)
├── REFERENCE.md       # Detailed documentation (optional)
├── EXAMPLES.md        # Usage examples (optional)
└── scripts/           # Utility scripts (optional)
    └── helper.js
```

## SKILL.md Template

```md
---
name: skill-name
description: A brief description of the capability. Use when [specific trigger condition].
---

# Skill Name

## Quick Start

[Minimum viable example]

## Workflow

[Step-by-step process with checklists for complex tasks]

## Advanced Features

[Link to separate file: see [REFERENCE.md](REFERENCE.md)]
```

## Description Requirements

The description is **the only information your agent sees when deciding which skill to load**. It appears in the system prompt alongside all other installed skills. Your agent reads these descriptions and selects the relevant skill based on the user's request.

**Goal**: Give your agent enough information to know:

1. What capability this skill provides
2. When/why to trigger it (specific keywords, context, file types)

**Format**:

- Maximum 1024 characters
- Written in third person
- First sentence: what it does
- Second sentence: "Use when [specific trigger condition]"

**Good Example**:

```
Extract text and tables from PDF files, fill forms, merge documents. Use when working with PDF files or when the user mentions PDF, forms, or document extraction.
```

**Bad Example**:

```
Helps process documents.
```

A bad example makes it impossible for your agent to distinguish this skill from other document-handling skills.

## When to Add Scripts

Add utility scripts when:

- The operation is deterministic (validation, formatting)
- The same code would be generated repeatedly
- Errors need explicit handling

Scripts save tokens and improve reliability compared to generated code.

## When to Split Files

Split into separate files when:

- SKILL.md exceeds 100 lines
- The content covers different domains (e.g., financial models vs. sales models)
- Advanced features are rarely used

## Review Checklist

After drafting, verify the following:

- [ ] Description includes trigger condition ("Use when...")
- [ ] SKILL.md does not exceed 100 lines
- [ ] No time-sensitive information
- [ ] Terminology is consistent
- [ ] Contains concrete examples
- [ ] Reference hierarchy does not exceed one level
