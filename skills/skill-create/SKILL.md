---
name: skill-create
description: Create new agent skills following skill-evolve standards. Use when the user needs to create, write, or build a new skill.
disable-model-invocation: true
---

# Skill Create

## Overview

Create an agent skill from scratch. **Follow skill-evolve standards to create a SKILL. If anything is uncertain, ask the user. If any information or positioning is unknown, ask the user.**

## Definitions

No content yet

## Prerequisites

No content yet

## Workflow

0. **Pre-check** — Verify that skill-evolve's template.md and directory-structure.md are accessible:
    - Yes -> Next step;
    - No -> Report missing files, terminate flow;
1. **Create skill** — Create directory structure and SKILL.md following template.md and directory-structure.md. For any uncertain decisions during creation, ask the user via AskUserQuestion;
2. **Review check** — Check results against [Review List](#review-list):
    - Check if Review List has content:
        - No -> Directly proceed to next step (Output results);
        - Yes -> Verify item by item:
            - All passed -> Next step;
            - Any failures -> Terminate flow;
3. **Output results** — Output structured summary and report completion.

## Rules

- For anything uncertain during creation (skill name, description content, whether auxiliary directories are needed, content decisions, etc.), **must** use AskUserQuestion to ask the user. Do not make assumptions.

## Examples

No content yet

## Review List

No content yet

## References

- [SKILL Template](../skill-evolve/template.md)
- [SKILL Directory Structure](../skill-evolve/references/directory-structure.md)
