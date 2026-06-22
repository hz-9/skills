# Example Writing Standard — Define the Writing Format and Consistency Rules for the `## Examples` Section in SKILL.md

## Overview

Standardize the writing format and content requirements for the `## Examples` section in SKILL.md, covering writing standards and consistency rules for three example types: dialogue interaction examples, review check examples, and output examples.

## Dialogue Interaction Example Standard

- Demonstrates the dialogue flow between user and AI, helping understand the SKILL's trigger method and AI's response behavior
- Each example is summarized by a bold title (`**Title**`) describing the scenario
- Immediately followed by a ````markdown code block wrapping the dialogue content
- Multiple examples separated by blank lines

## Review Check Example Standard

- Demonstrates the output format and style of the review check execution, for AI reference on output structure
- Examples may show **representative passing items** by group (1-2 items per group), with full failure scenarios displayed; annotated at the end with "(AI will output all check item results one by one during runtime)"
- During AI runtime, **all** Review List check items must be output one by one, not abbreviated as "remaining items passed"
- Use 🟩 for passing items, 🟥 for failing items
- When a check fails, the flow must be explicitly terminated

## Output Example Standard

- Demonstrates the result state after SKILL execution, allowing users to intuitively understand the applied effect
- Each example is summarized by a bold title (`**Title**`) describing the scenario
- Immediately followed by a ````markdown code block wrapping the result table
- Multiple examples separated by blank lines

## Example Consistency Rules

- Examples content must be consistent with Rules (behaviors, flows, values in examples must align with Rules definitions)
- Examples must include a review check example (showing the termination flow when Review List acceptance fails)
- Dialogue interaction examples only focus on steps 0-5 (excluding Secure steps like review and output)
- All examples in `## Examples` must be wrapped in ````markdown code blocks
- After modifying or renaming Workflow steps, synchronously check the step names referenced in dialogue interaction examples
- Example flows must be consistent with the latest Workflow flow
- Numbers in examples (step count, check item count, line count, etc.) must be synchronized with actual values
- Numbers in Examples should use generic example values **decoupled** from the file's actual state, avoiding volatile numbers like file line count or check item count
- If it is necessary to show numbers related to actual values (e.g., "38 check items"), they must be synchronously updated during Step 3's volatile number scan

## Verification Checklist

- [ ] Dialogue interaction examples: format compliance (bold title + ``markdown code block wrapping dialogue content)
- [ ] Review check example: uses **representative passing items** + full failure scenario format, annotated with runtime full output declaration at the end
- [ ] Review check example: correctly uses 🟩/🟥 for pass/fail status, terminates flow on failure
- [ ] Output examples: format compliance (bold title + ``markdown code block wrapping result table)
- [ ] Examples consistent with Rules: behaviors, flows, values align with Rules
- [ ] Review check termination flow: example shows the Review List acceptance failure termination flow
- [ ] Dialogue interaction only focuses on steps 0-5
- [ ] Example wrapping format: all examples wrapped in ````markdown code blocks
- [ ] Example-Workflow synchronization: example steps match latest Workflow, numbers synchronized with actual values
- [ ] Volatile numbers checked: no hardcoded numbers (like line count) bound to actual file state in Examples; used numbers are generic example values or synchronously updated
