---
name: grill-me
description: Relentlessly question the user's plan or design until consensus is reached, traversing every branch of the decision tree. Use when the user wants to stress-test a plan, put a design through rigorous questioning, or mentions "grill me".
---

# Grill Me

## Overview

Relentlessly question every aspect of the user's plan or design, following every branch of the decision tree to its conclusion, resolving inter-decision dependencies one by one. Provide a recommended answer for each question, ask only one question at a time, until consensus is reached.

## Definitions

- **Grill**: Systematically challenge and question every decision point in a plan to expose potential risks and oversights;
- **Decision Tree Branch**: Interdependent decision paths within a plan, each requiring independent traversal to completion.

## Prerequisites

- The user has a plan, design, or proposal ready to be grilled;
- The agent can browse the project codebase to verify technology-related questions directly, replacing the need to question the user.

## Workflow

1. Understand the user's plan or design and identify the core decision points;
2. Start questioning along one branch of the decision tree, asking only one question at a time;
3. Provide a recommended answer for each question to help the user move forward quickly;
4. If a question can be answered by browsing the codebase, verify directly instead of asking the user;
5. Traverse all branches, resolving inter-decision dependencies one by one, until consensus is reached on all points or the user terminates.

## Rules

- Ask only one question at a time; avoid information overload;
- Every question must include a recommended answer;
- Questions answerable by browsing the codebase → verify directly, do not ask the user;
- Traverse all decision branches without omission; do not make decisions on your own — user consent is required;
- Once consensus is reached, stop questioning and output a summary.

## Examples

### Dialogue Interaction Example

**Example: AI systematically grills a user's proposal**

```
User > Grill this plan: we want to use Redis distributed locks to prevent duplicate orders

AI > Alright, let's begin grilling.

First question: If a Redis node fails, will the lock state be lost?
Recommendation: Use the Redlock algorithm with multiple independent Redis instances, requiring majority confirmation for lock acquisition.
What do you think?

User > OK, let's use Redlock.

AI > What TTL should we set for the lock? Too short and the business might not finish before release; too long and failover recovery is slow.
Recommendation: Initial 30 seconds, with a watchdog renewal mechanism, and active release when the business completes.

User > Reasonable, 30s + watchdog.

AI > If a thread experiences a GC pause exceeding the TTL after acquiring the lock, the lock auto-releases and another thread acquires it — how do we prevent that?
Recommendation: Use a unique identifier (UUID) for the lock value and verify holder identity on release.

User > Right, add UUID verification.

AI > All these measures are at the application layer. Can we accept the extremely low probability of duplicate orders if the lock fails in edge cases? Or should we add a database unique constraint as the final safety net?

User > Add the database unique constraint as a safety net, keep it consistent.

AI > Consensus reached. Summary:
- Redlock (multi-instance majority)
- TTL 30s + watchdog renewal
- UUID holder verification
- Database unique constraint as safety net
Grilling complete.
```

### Execution Success Example

| Dimension | Description |
|-----------|-------------|
| Grilling topic | Redis distributed lock to prevent duplicate orders |
| Question rounds | 4 |
| Codebase lookups | 0 (pure design grilling) |
| Final decisions | 4 (Redlock, TTL+watchdog, UUID verification, DB safety net) |
| Result | Full consensus reached |

## Review List

- [ ] Only one question asked at a time, no multi-question bombardment
- [ ] Every question included a recommended answer
- [ ] Questions answerable by codebase browsing were verified directly
- [ ] All decision branches were traversed without omission
- [ ] A summary was output after consensus was reached

## References

None (this skill requires no external reference documents).
