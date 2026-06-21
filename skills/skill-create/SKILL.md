---
name: skill-create
description: Create new agent skills following skill-evolve standards. Use when the user needs to create, write, or build a new skill.
disable-model-invocation: true
---

# Skill Create

## Overview

Create an agent skill from scratch. **Follow skill-evolve standards to create a SKILL. If anything is uncertain, ask the user. If any information or positioning is unknown, ask the user.**

## Workflow

1. **Pre-check** — Verify that skill-evolve's template.md and directory-structure.md are accessible;
2. **Create skill** — Create directory structure and SKILL.md following template.md and directory-structure.md. For any uncertain decisions during creation, ask the user via AskUserQuestion;
3. **Review and confirm** — Present the creation result, confirm with the user via AskUserQuestion, then output the result.

## Rules

- For anything uncertain during creation (skill name, description content, whether auxiliary directories are needed, content decisions, etc.), **must** use AskUserQuestion to ask the user. Do not make assumptions.

## References

- [SKILL Template](../skill-evolve/template.md)
- [SKILL Directory Structure](../skill-evolve/references/directory-structure.md)
