---
name: skill-evolve
description: Perform a complete structural evolution on a specified SKILL: optimize directory structure, streamline redundant content, split reference documents to improve readability and maintainability. Use when the user needs to improve, refactor, or standardize an existing SKILL.md.
---

# Skill Evolve

## Overview

Perform a one-time structural evolution on an existing SKILL.md: align with the standard template, streamline redundant content, split reference documents to improve maintainability.

Called by skill-evolve-cycle during the small cycle A phase, or run independently for a single optimization.

## Definitions

- <a id="similar-meaning-section"></a>**Similar meaning section**: Sections with the same semantics as standard sections but with different historical names (e.g., `Description`↔`Overview`, `Checklist`↔`Review List`). AI automatically identifies whether they exist and their target sections; whether to adopt or leave blank is confirmed by the user.
- <a id="reference-level"></a>**Reference level**: SKILL.md directly linking to files under `references/` is level one; `references/` files linking to external resources is level two, which should be avoided.
- <a id="secure-steps"></a>**Secure steps**: A set of fixed standardized steps in the Workflow, whose specific composition and structure are defined by [Workflow Writing Standard](references/workflow-standard.md).
- <a id="abstract-variable-name"></a>**Abstract variable name**: A generalized placeholder in reference files used to replace specific values or paths, usually enclosed in square brackets `[]` (e.g., `[filename]`, `[directory-name]`), ensuring the referenced content does not become invalid when the referenced file content changes.
- <a id="template-standard-sections"></a>**Template standard sections**: The set of standard sections defined by `##` heading sections in the [template](template.md), serving as the target baseline for structural alignment.
- <a id="whether-cross-step-circular-reference"></a>**Whether cross-step circular reference**: Marks whether there are cross-step circular jump references between the substeps of the target SKILL.md's Workflow, controlling whether digital sub-numbering format is needed. Initialized after analyzing the reference relationship according to [Workflow Writing Standard](references/workflow-standard.md#digital-sub-numbering-reference-scenarios).
- <a id="exit-path"></a>**Exit path**: All possible exits for terminating execution in the Workflow, including four types: normal completion, user termination, error termination, and review failure termination.
- <a id="original-content-copy"></a>**Original content copy**: The initial complete content of the target SKILL.md saved in memory during the Workflow pre-check phase, used as a rollback baseline for unrecoverable errors.
- <a id="whether-self-evolving"></a>**Whether self-evolving**: Marks whether the target SKILL.md is skill-evolve itself. Initialized by Step 0 by comparing the normalized absolute path of the target with the normalized absolute path of this SKILL.md file — if they match, the value is true.

## Prerequisites

The object to be modified and optimized already exists. This SKILL is responsible for optimization, not creation from scratch. To create a skill from scratch, use `skill-create`.

## Workflow

0. **Pre-check** — Ensure prerequisites for subsequent tasks are met;

  - Verify target SKILL.md exists and is readable:
    - Yes -> next step;
    - No -> report "Target file does not exist or cannot be read", terminate flow;
  - Verify `template.md` exists and its frontmatter/main structure is parseable:
    - Yes -> next step;
    - No -> report "Template file missing or corrupted", terminate flow;
  - Verify referenced reference files under `references/` exist (file list must be synchronized with `## References` section):
    - Yes -> next step;
    - No -> list missing files, provide options via AskUserQuestion, block and wait for user selection:
      - Skip missing and continue -> skip missing files, continue execution, then proceed to next step;
      - Terminate, fix and re-run -> terminate flow;
  - Save the complete [original content copy](#original-content-copy) of the target SKILL.md in memory (as rollback baseline);
  - Initialize global variables [whether cross-step circular reference](#whether-cross-step-circular-reference), [whether self-evolving](#whether-self-evolving):
    - Sequentially evaluate variable conditions (refer to acquisition rules in variable definitions):
      - Met -> initialize the variable to true;
      - Not met -> initialize the variable to false;

1. **Metadata Structure** — Check and fix frontmatter content correctness;
  - Check if `name` exists:
    - Yes -> check if it matches the parent directory name:
      - Yes -> next step;
      - No -> force correct to directory name, then proceed to next step;
    - No -> set name based on the parent directory name, then proceed to next step;
  - Check if `description` exists and meets the format requirements in [Metadata Standard](#metadata-standard):
    - Yes -> next step;
    - No -> provide options via AskUserQuestion, block and wait for user selection:
      - Accept fix plan -> update description, then proceed to next step;
      - Specify manually -> user provides description, update, then proceed to next step;
2. **Structure Alignment** — Complete missing sections and adjust order against template;
  - Sequentially check each [template standard section](#template-standard-sections) (i.e., `##` heading sections defined in the [template](template.md)):
    - Yes -> next step (current content already meets the section's template responsibility requirements, marked as compliant, skip this round of optimization; when template requirements are updated or content substantially deviates, this check needs to be re-executed);
    - No -> provide options via AskUserQuestion, block and wait for user selection:
      - Adopt -> rename [similar meaning section](#similar-meaning-section) to the [template standard section](#template-standard-sections) name (keep original content), then proceed to next step;
      - Leave blank -> create the section (fill with "No content"), then proceed to next step;
  - Check if all [Secure steps](#secure-steps) (Pre-check, Review Check, Output) exist:
    - Yes -> next step;
    - No -> auto-complete (insert/move/renumber) based on [Workflow Writing Standard](references/workflow-standard.md#auto-completion-algorithm), no user confirmation needed, then proceed to next step;
  - Non-[template standard section](#template-standard-sections) content -> migrate to `references/` according to [Content Boundary Standard](references/content-boundary.md):
    - Check if file with same name exists:
      - Yes -> provide options via AskUserQuestion, block and wait for user selection:
        - Overwrite -> overwrite file with new content, update internal links in migrated content pointing to original location, scan SKILL.md and all references/ files for anchor links pointing to this non-standard section and update to new path, then proceed to next step;
        - Merge -> merge new content into existing file, update internal links in migrated content pointing to original location, scan SKILL.md and all references/ files for anchor links pointing to this non-standard section and update to new path, then proceed to next step;
        - Skip -> keep existing file unchanged, skip migration, then proceed to next step;
      - No -> create file with new name, update internal links in migrated content pointing to original location, scan SKILL.md and all references/ files for anchor links pointing to this non-standard section and update to new path, then proceed to next step;
    - After migration, delete the original non-standard section content (skip scenario excluded);
  - Check [whether cross-step circular reference](#whether-cross-step-circular-reference):
    - Yes -> use digital sub-numbering format to align sub-steps, then proceed to next step;
    - No -> use regular bullet list format, then proceed to next step;
  - Adjust section order;
3. **Format Standardization** — Align with template responsibilities, unify format, clean time-sensitive content;
  - Check against the responsibility requirements of each section in the [template](template.md):
    - Yes -> next step (current content already meets the section's template responsibility requirements, marked as compliant, skip this round of optimization; when template requirements are updated or content substantially deviates, this check needs to be re-executed);
    - No -> provide options via AskUserQuestion, block and wait for user selection:
      - [Dynamic options generated by AI based on differences between template responsibilities and current content] -> execute corresponding optimization, then proceed to next step;
  - [Format Unification Check] Sequentially check against the `## Verification Checklist` of the following reference files, performing item-by-item checks and fixes on the target SKILL.md (must **read each** check item one by one and confirm each; if non-compliance is found in any aspect, fix based on the corresponding specification, then re-check that aspect, up to 2 times; if still not passing, record the failure item and continue to the next aspect):
    - Workflow structure/format/branch logic/interaction patterns -> refer to [Workflow Writing Standard](references/workflow-standard.md#verification-checklist)
    - Punctuation/quotes/brackets/full-width half-width -> refer to [Punctuation Convention](references/punctuation-convention.md#verification-checklist)
    - Text simplification -> refer to [Text Simplification Rules](references/text-optimization.md#verification-checklist)
    - Rules standards -> refer to [Rules Writing Standard](references/rules-standard.md#verification-checklist)
    - Review List standards -> refer to [Review List Writing Standard](references/review-list-standard.md#verification-checklist)
    - Example format standards -> refer to [Example Writing Standard](references/example-standard.md#verification-checklist)
    - [Secure steps](#secure-steps) structure -> refer to [Workflow Writing Standard](references/workflow-standard.md#fixed-step-specification)
    - Directory structure consistency -> refer to references/ file content specifications in [SKILL Directory Structure](references/directory-structure.md#verification-checklist)
    - Examples volatile numbers -> refer to [Example Writing Standard](references/example-standard.md#verification-checklist)
  - Delete time-sensitive information (e.g., specific dates, version numbers); keep terminology consistent;
  - Check [abstract variable names](#abstract-variable-name) in files under `references/`: replace specific variables that could change in references to SKILL.md or other reference files with abstract variable names like `[filename]`, `[directory-name]`;
  - [Term Reference Integrity Audit] Scan each definition entry in `## Definitions` one by one, follow this flow to check full document references:
    - Retrieve current definition name and `<a id="">` anchor name;
    - Scan SKILL.md and all .md files under `references/`, locate all occurrences of the definition name;
    - For each occurrence, check reference format:
      - Already using `[term](#anchor)` anchor-level link -> continue to next occurrence;
      - Bare text (no link) -> replace with `[term](#anchor)` anchor-level link, continue to next occurrence;
    - After all analysis is complete, count the number of fixes, record in optimization report;
  - Check [whether self-evolving](#whether-self-evolving):
    - Yes -> verify if template.md needs synchronous updates due to this modification (e.g., new standard sections added, anchor IDs modified, reference paths changed):
      - Yes -> provide options via AskUserQuestion, block and wait for user selection:
        - Synchronously update template.md -> execute sync update, then proceed to next step;
        - Skip, handle manually later -> skip sync, then proceed to next step;
      - No -> next step;
    - No -> next step;
4. **Content Streamline** — Check and streamline SKILL.md content and line count;
  - Check if line count exceeds 500 lines:
    - Yes -> first try optimizing within SKILL.md (reduce blank lines, then compress content per [Text Simplification Rules](references/text-optimization.md); do not compress semantic density):
      - Still exceeds 500 lines after optimization:
        - Yes -> migrate some content to `references/`, update links in SKILL.md pointing to original content, then proceed to next step;
        - No -> next step;
    - No -> check [whether self-evolving](#whether-self-evolving):
      - Yes -> next step (self-optimization scenario, skip complexity migration);
      - No -> evaluate whether content complexity requires migration to references/ (criteria: referenced file count > 10, branch logic depth > 5 levels, Workflow steps > 20; meeting any one qualifies as complex):
        - Yes -> provide options via AskUserQuestion, block and wait for user selection:
          - Execute migration -> migrate content to references/ and update links, then proceed to next step;
          - Keep as-is -> skip migration, then proceed to next step;
        - No -> next step;
  - Check [whether self-evolving](#whether-self-evolving):
    - Yes -> next step (self-optimization scenario, skip directory addition suggestions);
    - No -> check if `scripts/`, `tests/`, `assets/`, or `schemas/` directories need to be added:
      - Yes -> suggest introducing corresponding directories (skill contains deterministic operations, code that will be repeatedly generated, logic requiring explicit error handling, test cases needed, static resources to store, or cross-Skill data transfer needed), then proceed to next step;
      - No -> next step;
5. **Reference Document Splitting** — Split REFERENCE.md into multiple files under references/;
  - Check if `REFERENCE.md` exists:
    - Yes -> provide options via AskUserQuestion, block and wait for user selection:
      - [Dynamic options generated by AI based on REFERENCE.md content domains] -> auto-split, then proceed to next step;
      - Skip -> execute References sync check, then proceed to Step 6 (Review Check);
      - Manually specify split plan -> wait for user to specify, then proceed to next step;
    - No -> execute References sync check, then proceed to Step 6 (Review Check);
  - Split into multiple files under `references/` by domain:
    - Does file with same name exist:
      - Yes -> provide options via AskUserQuestion, block and wait for user selection:
        - Overwrite -> overwrite file with new content, then proceed to next step;
        - Merge -> merge new content into existing file, then proceed to next step;
        - Skip -> keep existing file unchanged, then proceed to next step;
      - No -> next step;
  - After split, update all links in SKILL.md pointing to the original file;
  - After split, compare paragraph by paragraph with the original to confirm no content loss (e.g., examples in parentheses, notes, and other details not missed; max 2 retries):
    - Content lost -> add missing content and return to comparison operation (re-execute "compare paragraph by paragraph with original"), increment retry counter by 1;
    - No loss -> delete REFERENCE.md from root directory, next step;
    - Still has loss after exceeding retry limit (still has loss after 2 retries) -> record failure item, provide options via AskUserQuestion, block and wait for user selection:
      - Keep REFERENCE.md (content may have omissions) -> keep original file, then proceed to next step;
      - Confirm deletion (risk at your own) -> delete REFERENCE.md, then proceed to next step;
6. **Review Check** — Confirm optimization results against [Review List](#review-list);
  - Check if Review List has content:
    - No -> directly go to next step (Output);
    - Yes -> next step;
  - Sequentially check each item in [Review List](#review-list), whether it passes (must **output all** check item results one by one, not abbreviated as "remaining items passed"):
    - Yes -> continue to next check item;
    - No -> record failed check item (display output content based on "Review Check Example"), continue to next check item;
  - Verify synchronization between `## References` section and `references/` directory (after optimization):
    - Synchronized -> next step;
    - Not synchronized -> attempt auto-fix of References section (max 3 times):
      - Fix passes verification -> next step;
      - Still not synchronized after 3 fixes -> record failed check item, then proceed to next step;
  - Check if any check failed:
    - Yes -> execute per "Defense Standard" in Rules;
    - No -> proceed to next step (Output);
7. **Output** — Output optimization summary, inform completion;
  - Output structured summary (refer to "Output Example" for specific format);
  - Only list dimensions that changed this time (e.g., line count comparison, section completion, reference document splitting, etc.); do not output unchanged dimensions;
  - Inform optimization complete;

## Rules

- <a id="metadata-standard"></a>**Metadata Standard**
  - description must follow format: first sentence describes what the skill does, second sentence describes trigger condition ("Use when..."), use third-person, no more than 1024 characters;
  - Only validate `name` and `description` fields; other non-standard frontmatter fields (e.g., `disable-model-invocation`) remain unchanged, no processing;

- **Structure Standard**
  - Standard structural sections only apply to the target SKILL's SKILL.md file itself, not affecting other files in the directory;
  - REFERENCE.md should be moved to the `references` folder and split into multiple files;

- **Content Standard**
  - [Reference level](#reference-level) should not exceed one level: SKILL.md can directly link to files under `references/`; files under `references/` should not link to external resources;
  - When specification files under `references/` conflict, expanded format takes priority over compression rules (tree branches and interaction patterns in workflow-standard.md are not re-compressed by text-optimization.md rules);
  - When matching paths, avoid substring matching; prefer exact matching (e.g., directory name or full path) to prevent misjudgment of similar names;
  - When Review List references external verification checklists, it should point to the file's `## Verification Checklist` section or sub-group anchor; when referencing `#verification-checklist`, ensure the Workflow has an explicit "read each item" instruction;
  - All `#anchor` references in the Rules section must point to existing `##` heading nodes or `<a id="">` tag anchors;
  - Domain terms used in all Skill files must be explicitly defined in `## Definitions`; referenced terms must exactly match the definition name in Definitions (case-sensitive);
  - Each entry under `## Definitions` (e.g., `- **Template Standard Sections**`) **must** have a corresponding parseable anchor (`<a id="">` tag) for precise `[]()` referencing throughout the document;
  - When referencing Definitions terms in body text, use anchor-level links (e.g., `[Template Standard Sections](#template-standard-sections)`), not bare text without links;

- **Behavior Standard**
  - Any file deletion (except already-split REFERENCE.md) must be confirmed with the user through interactive questioning;
  - Editing scope limited to: only adjust the target SKILL's `SKILL.md` and files under `references/` directory;
    - Exception: moving or deleting `REFERENCE.md` (before splitting) or `template.md` from root directory -> provide options via AskUserQuestion, block and wait for user selection:
      - Confirm -> execute operation, then proceed to next step;
      - Cancel -> skip, directly proceed to subsequent operations of the current step;
  - After splitting REFERENCE.md, must compare paragraph by paragraph with the original to confirm no content loss (e.g., examples in parentheses, notes, and other details not missed);
  - Prohibited from asking users questions in plain text follow-up format; **must** use the `AskUserQuestion` tool;
  - Option flow annotation rules refer to [Workflow Writing Standard](references/workflow-standard.md#option-flow-annotation); "Skip" type options must explicitly annotate the jump target;
  - Responsibilities of adjacent steps in Workflow should be mutually exclusive; each step should have a clear and unique intent, avoiding overlapping descriptions;
  - Workflow step structure must follow [Workflow Writing Standard](references/workflow-standard.md); missing/incorrect content is auto-completed by Step 2;
  - When auto-completing [Secure steps](#secure-steps), first check if a step with the same name already exists in the entire Workflow; if it exists, move rather than add, avoiding duplicate insertion;
  - When Workflow references `## Verification Checklist`, AI must **read each** check item one by one and confirm each; violations of this rule should be marked as failed in Review Check;
  - When referencing external verification checklists, AI must first load the complete content of the referenced file into memory;

- **Defense Standard**
  - Every operation involving file movement, splitting, or deletion must synchronously handle side effects caused by the operation (e.g., updating link references, fixing relative paths);
  - If an unrecoverable error is detected during execution (file write failure, dead link after link update verification cannot be fixed), use the [original content copy](#original-content-copy) to restore the target file (rollback only restores SKILL.md; newly created files under references/ need manual cleanup; only takes effect for errors detected within the current session), and inform the user of the recovery result;
  - After Review Check is complete, if there are failed items, determine if they are unrecoverable errors (file write failure, dead links cannot be fixed, etc.):
    - **Recoverable error** -> record failed check item in optimization report, mark **Review Check failed**, terminate flow;
    - **Unrecoverable error** -> use Step 0's [original content copy](#original-content-copy) to rollback SKILL.md (newly created files under references/ need manual cleanup), inform the user, then terminate flow;

- **Verification Standard**
  - Concern Separation principle refers to [rules-standard](references/rules-standard.md);
  - [Exit paths](#exit-path) and rollback behaviors defined in Workflow must have corresponding verification items in Rules and Review List;
  - Workflow steps should explicitly cover the execution logic referenced by binding rules in Rules;
  - Multi-element iteration handling: refer to [Workflow Writing Standard](references/workflow-standard.md#loops-and-iterations);
  - Examples content must be self-consistent with Rules;
  - Examples must include a Review Check example;
  - Dialogue interaction examples only focus on steps 0-5;

## Examples

### Dialogue Interaction Example

**Interactive optimization: AI confirms user preferences item by item**

```markdown
User > Help me optimize skills.zh-CN/example-skill/SKILL.md

AI   > Checking metadata...description missing trigger condition.
      Provide options via AskUserQuestion, block and wait for user selection:
          - [Dynamic options generated by AI based on description missing type] -> execute corresponding fix, then proceed to next step;
User > Add trigger condition

AI   > Description updated. Aligning structure...Definitions and Review List are missing.
      Provide options via AskUserQuestion, block and wait for user selection:
          - Adopt AI-identified similar meaning section data -> update section, then proceed to next step;
          - Leave blank -> skip, then proceed to next step;
User > Complete

AI   > Definitions completed. Checking references...REFERENCE.md should be split into multiple files.
      Provide options via AskUserQuestion, block and wait for user selection:
          - [Dynamic options generated by AI based on REFERENCE.md content domains] -> execute split, then proceed to next step;
User > Auto-split
```

> Note: The above example shows the main flow of metadata -> structure alignment -> splitting. Steps 0 (Pre-check), 3 (Format Standardization), and 4 (Content Streamline) are omitted in this example. Review Check and Output are shown in their respective dedicated example sections.

### Review Check Example

```markdown
AI > Entering Review Check...Review List contains 42 check items, starting one-by-one verification:

**Metadata Check**
  - 🟩 name field: skill-evolve, matches directory name
  - 🟩 description format: includes trigger condition, third-person, within 1024 characters

**Structure Check**
  - 🟩 Content integrity after split: compared paragraph by paragraph with original, no content loss
  - 🟩 Secure steps completeness: Pre-check, Review Check, Output all exist

**Content Check**
  - 🟩 Content streamlined: SKILL.md kept within 500 lines, no redundant content
  - 🟩 Punctuation: conforms to punctuation usage convention

**Behavior Check**
  - 🟩 Interaction: uses AskUserQuestion standard paradigm
  - 🟩 Branch logic: tree arrow format correct

**Defense Check**
  - 🟩 Error handling completeness: recoverable/unrecoverable errors handled per defense standard

(Only representative passing items shown per group; during AI runtime, all 42 check item results will be output one by one)

**!!! The following checks did NOT pass !!!**
  - 🟥 Example flow synchronization: step numbers referenced in dialogue interaction example do not match latest Workflow
    Terminate flow, suggest manual inspection and re-execution.
```

### Output Example

**SKILL before/after optimization comparison example:**

```markdown
| Dimension                        | Before Optimization                    | After Optimization                      |
| -------------------------------- | -------------------------------------- | --------------------------------------- |
| SKILL.md line count              | 150 lines                              | 85 lines                                |
| Section completeness             | Missing Prerequisites, Review List     | All sections completed                  |
| Section order                    | Disordered (Overview at end)           | Aligned with template standard order    |
| Non-standard section migration   | Events, FAQ as body sections           | Migrated to references/                 |
| Time-sensitive info              | Contains v2.1.0, 2024-05-01 etc.       | All removed                             |
| Reference document organization  | REFERENCE.md single file (1200 lines)  | Split into 3 separate files under references/ |
| Reference level                  | references/ files linking to external blogs | Controlled within one level            |
| Trigger condition                | Vague description ("Used for commit")  | Clearly includes "Use when..."          |
| description person               | Contains "帮你" second person          | Unified third-person                    |
| Interaction paradigm             | Using plain text to ask user           | All switched to AskUserQuestion         |
| Branch arrows                    | Some steps missing (Yes -> / No ->)    | All aligned to tree arrow format        |
| Punctuation                      | Mixed Chinese/English punctuation, using「」| Unified curly quotes, Chinese punctuation |
| Secure steps                     | Missing Review Check and Output        | Complete 3 Secure steps                 |
| Abstract variables               | references/ contains specific paths    | Replaced with [filename], [directory-name] |
```

## Review List

After optimization is complete, verify the following:

- **Metadata Check**
  - [ ] name field: exists and correct, matches SKILL.md's parent directory name
  - [ ] description format: first sentence describes what the skill does, second sentence describes trigger condition ("Use when..."), uses third-person (no 你/您的/we/I first/second person pronouns), no more than 1024 characters
  - [ ] Non-standard field protection: frontmatter fields other than `name` and `description` (e.g., `disable-model-invocation`) remain unchanged, not modified or deleted
- **Structure Check**
  - [ ] Content integrity after split: compared paragraph by paragraph with original, no content loss
  - [ ] Extension directories: scripts/, tests/, assets/, or schemas/ have been evaluated
  - [ ] [Secure steps](#secure-steps) completeness: Workflow step structure conforms to standards defined in [Workflow Writing Standard](references/workflow-standard.md#fixed-step-specification), with no duplicate insertion
  - [ ] No trace of interrupted optimization: check for incomplete migrations (target file created but original content not deleted), or incomplete link updates after REFERENCE.md split
  - [ ] Self-exclusion judgment: if target is skill-evolve itself, confirm complexity migration and directory addition suggestions are skipped as expected
  - [ ] References section synchronization: after Step 5 split, `## References` section is synchronized with `references/` directory, no omissions for added/deleted files
- **Content Check**
  - [ ] SKILL.md does not exceed 500 lines; if exceeds 500 lines or has extensive complex content, migrated to references/
  - [ ] Content quality: no time-sensitive info, consistent terminology, includes concrete examples with values consistent with rules
  - [ ] After content streamlining, confirm item by item against [Text Simplification Rules](references/text-optimization.md#verification-checklist), no omissions
  - [ ] Links and anchors: reference level no more than one level, no dead links, no unresolved placeholders
  - [ ] Cross-reference consistency/path matching/cross-step reference format: confirm against [Workflow Writing Standard](references/workflow-standard.md#structure-verification)
  - [ ] Anchor availability: confirm anchor compliance against [review-list-standard](references/review-list-standard.md#verification-checklist)
  - [ ] Cross-file references: specific values in references/ referencing SKILL.md or other reference files have been replaced with [abstract variable names](#abstract-variable-name)
  - [ ] Term completeness: all domain terms used in Skill are defined in Definitions with exact name matching (no synonyms); when referencing terms in body text, use anchor-level link format, not bare text without links
  - [ ] Format priority correctness: [Text Simplification Rules](references/text-optimization.md) correctly avoid compressing content that should remain expanded (tree branches, interaction patterns, etc.); expanded format priority over compression rules is correctly executed
  - [ ] Punctuation: follows [Punctuation Convention](references/punctuation-convention.md#verification-checklist)
  - [ ] Cross-step reference format: follows [Workflow Writing Standard](references/workflow-standard.md#cross-step-references)
  - [ ] Markdown indentation: sub-steps indented 2 spaces, conditional branches indented another 2 spaces
  - [ ] Example wrapping format: all examples in `## Examples` wrapped in markdown code blocks
- **Behavior Check**
  - [ ] Interaction: confirm item by item against [Workflow Writing Standard](references/workflow-standard.md#interaction-standard-verification)
  - [ ] Branch logic: confirm item by item against [Workflow Writing Standard](references/workflow-standard.md#branch-logic-verification)
  - [ ] Step responsibility independence: adjacent steps in Workflow have mutually exclusive responsibilities, no overlapping descriptions
  - [ ] File deletion safety: any file deletion operation confirmed with user via AskUserQuestion before proceeding
  - [ ] Editing scope compliance: edit operations limited to SKILL.md and references/ directory (exceptions require user confirmation via AskUserQuestion)
- **Defense Check**
  - [ ] Error handling completeness: Review Check correctly handles recoverable/unrecoverable errors per defense standard
- **Validation Check**
  - [ ] Review List coverage: each check item in Review List should cover all sub-conditions of the corresponding Rule in Rules (e.g., description check item must cover "format, person, length" simultaneously), not just cover part
  - [ ] Self-consistency: Rules and Review List follow Concern Separation (Rules constrain behavior, Review List validates output), no misalignment or omission
  - [ ] Review Check example: Examples include a Review Check example showing the termination flow when Review List acceptance fails
  - [ ] Example content sync verification: after modifying or renaming Workflow steps, check that step names referenced in dialogue interaction examples match the latest Workflow
  - [ ] Example flow synchronization: example flows in `## Examples` should be consistent with the latest Workflow flow; after adding/modifying steps, examples must be synchronously updated
  - [ ] Non-example part count consistency: counts in non-example parts of the document (step count, check item count, etc.) are consistent with actual content
  - [ ] Example number decoupling: numbers in `## Examples` follow example writing standards, using generic example values decoupled from the file's actual state, with no residual volatile numbers bound to actual file state
  - [ ] Interaction example scope: dialogue interaction examples only focus on steps 0-5, excluding Review Check and Output
  - [ ] Workflow steps explicitly cover the execution logic referenced by all binding rules in Rules
  - [ ] Examples self-consistency: example content is consistent with related Rules, no self-contradictions
  - [ ] Specification file self-consistency: specification files under references/ must themselves pass their defined verification checklists
  - [ ] [Exit path](#exit-path) completeness: all exit paths defined in Workflow (normal completion, user termination, error termination, review failure termination) have corresponding verification items in Review List or corresponding constraints in Rules
  - [ ] Termination reason marking complete: all forced termination paths (file missing, unrecoverable error, etc.) have termination reasons recorded in the output report
  - [ ] Variable declaration completeness: all cross-step workflow variables are declared in Definitions in "是否 xxx" format with clear acquisition rules

## References

- [skill-evolve-cycle](../skill-evolve-cycle/SKILL.md): SKILL cyclic evolution orchestrator
- [SKILL Directory Structure](references/directory-structure.md)
- [SKILL Template](template.md)
- [Text Simplification Rules](references/text-optimization.md)
- [Workflow Writing Standard](references/workflow-standard.md): Defines Workflow fixed step structure, step writing format, branch logic and interaction patterns
- [Punctuation Convention](references/punctuation-convention.md)
- [Content Boundary Standard](references/content-boundary.md): Defines content ownership boundaries between SKILL.md and references/ files
- [Rules Writing Standard](references/rules-standard.md): Constrains AI execution behavior
- [Review List Writing Standard](references/review-list-standard.md): Defines Review List writing conventions
- [Example Writing Standard](references/example-standard.md): Defines writing format and consistency rules for `## Examples` section
