---
name: your-skill-name
description: Briefly describe what this skill does and what problem it solves. Use when the user needs X, wants to do Y, or mentions Z.
---

# Skill Name: xxx

## Overview

Briefly describe what this Skill does, what problem it solves, and in what scenarios it is triggered. Use third person, no more than 1024 characters.

Example:

> Clean up stale Git branches with interactive selection, safely deleting merged local branches.

## Definitions

Define the terms and conventions involved in the skill to help understand the execution instructions that follow. Describe each in one sentence.

Example:

> - **Similar-meaning directory**: A directory with the same semantics as a standard directory but a different historical name; automatically mapped during optimization without interactive confirmation.

## Prerequisites

Conditions that need to be met before execution, such as dependency tools, environment variables, prerequisite knowledge. If there are complementary skills, declare them here and explain the division of responsibilities (to avoid overlapping responsibilities).

Example:

> Requires Git 2.0+, currently in a Git repository directory, has branch deletion permissions. To create a skill from scratch, use `skill-create`.

## Workflow

Core section: detailed step-by-step instructions telling the AI exactly what to do. Steps should be clear and executable.

Example:

> 1. Run `git branch` to get the local branch list
> 2. Filter out the current branch, main/master/develop
> 3. Ask the user one by one whether to delete each branch
> 4. Run `git branch -d` for confirmed branches

## Rules

Tell the AI: the constraints and behavioral guidelines to follow during SKILL execution.

Example:

> - Before deleting any file, always ask the user for confirmation through interactive questioning;
> - Only recommend editing files in `SKILL.md` and `references/` directory;
> - REFERENCE.md should be moved to the `references` folder and split into multiple files;

## Examples

### Interactive Conversation Examples

Show the conversation flow between the user and the AI to help understand how the SKILL is triggered and the AI's response behavior.

Example:

> **Example: AI automatically invokes based on trigger conditions**
>
> ```
> User> Help me check if the current project has stale local branches that need cleanup
>
> AI > Detected user needs branch cleanup, triggered git-branch-cleanup skill:
>
> AI > Running git branch to get local branch list...
>     Found merged branches: feature/old-login, fix/temp-patch, test/experiment
>     Current branch: main (skipped)
>     Protected branches: main, develop (skipped)
>
> AI > Delete feature/old-login? (merged into main)
> User > Yes
> AI > Deleted feature/old-login
>
> AI > Delete fix/temp-patch? (merged into main)
> User > No
> AI > Skipped fix/temp-patch
> ```

### Execution Success Examples

Show the results after SKILL execution, helping the user intuitively understand the application effect.

Example 1:

> **SKILL optimization skill execution effect example:**
>
> | Dimension | Before Optimization | After Optimization |
> |-----------|--------------------|--------------------|
> | SKILL.md lines | 150 lines | 85 lines |
> | Directory completeness | Missing Prerequisites, Review List | All directories filled |
> | Time-sensitive info | Contains v2.1.0, 2024-05-01, etc. | All removed |
> | Reference document organization | REFERENCE.md single file | Split into 3 independent files under references/ |
> | Trigger condition | Vague description | Clearly includes "Use when..." |

Example 2:

> **Git branch cleanup skill execution effect example:**
>
> | Item | Count |
> |------|-------|
> | Merged branches | 3 |
> | Unmerged branches (with unpushed changes, skipped) | 1 |
> | Cleaned up | 2 |
> | User declined cleanup | 1 |
> | Auto-skipped (current branch + protected branches) | 2 |
> | Disk space freed | ~45MB |

## Review List

Tell the AI: the verification checklist after completing the SKILL.

Example:

> - [ ] Description includes trigger condition ("Use when...")
> - [ ] SKILL.md does not exceed 300 lines
> - [ ] Content quality: no time-sensitive info, consistent terminology, includes concrete examples with values matching rules
> - [ ] References and links: reference hierarchy does not exceed one level, no dead links, no unresolved placeholders
> - [ ] Extended directories: scripts/, tests/, or schemas/ have been evaluated if needed

## References

List of external documents and resources referenced; add more reference items as needed.

Example:

> - [SKILL Directory Structure](references/directory-structure.md)
> - [SKILL Template](template.md)
