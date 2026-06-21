---
name: nestjs-3-3-file-upload
description: Review NestJS file upload and stream processing implementation, covering Multer configuration, file validation, storage strategies, and multi-file upload. Use when users need to review file upload logic or develop file processing functionality.
---

# NestJS File Upload and Stream Processing

## Overview

When AI encounters file upload related code in a NestJS project, it automatically performs the following: review the file uploader configuration and storage strategy, check file validation and security measures, evaluate the implementation of stream processing (StreamableFile), and provide improvement suggestions.

## Definitions

- <a id="target-code"></a>**Target code**: The NestJS file upload controller, Multer configuration, or stream processing code in the current conversation.
- <a id="file-interceptor"></a>**File interceptor**: NestJS built-in interceptors for handling file uploads, including FileInterceptor (single file), FilesInterceptor (multiple files with same name), FileFieldsInterceptor (multiple files with different names), and AnyFilesInterceptor (any files).
- <a id="StreamableFile"></a>**StreamableFile**: NestJS's stream-based file response class, used for efficiently returning large files without consuming memory.
- <a id="analysis-complete"></a>**Analysis complete**: Indicates whether the analysis of the target code has been fully completed.

## Prerequisites

- NestJS project environment;
- File upload controller or configuration code accessible;
- Understanding of basic file upload concepts (MIME types, size limits, storage strategies).

## Workflow

0. **Pre-check** — Ensure the target code and runtime environment are reachable;
   - Determine if the target code exists and is readable:
     - Yes -> next step;
     - No -> prompt the user to provide the target code or file path, block and wait for user input;
   - Initialize global variable [analysis complete](#analysis-complete):
     - Determine if the code is fully parseable:
       - Satisfied -> initialize variable to true;
       - Not satisfied -> initialize variable to false;

1. **Analyze file upload code** — Read and understand file processing logic;
   - Read the target code, identify the following core elements:
     - Type of file interceptor used (FileInterceptor / FilesInterceptor / FileFieldsInterceptor);
     - Multer options configuration (storage, fileFilter, limits);
     - File validation logic (file type, size, quantity);
     - Storage strategy (local disk / cloud storage);
     - Stream-based download (StreamableFile) usage;

2. **Review items** — Check file upload code quality against the review checklist;
   - Iterate through the following review items to determine if they pass:
     - Whether file size limits are configured (limits.fileSize) to prevent large file attacks:
       - Pass -> record as passed, continue to next review item;
       - Fail -> record "Missing file size limit, recommend adding limits.fileSize", continue;
     - Whether a file type filter (fileFilter) is configured to restrict allowed MIME types:
       - Pass -> record as passed, continue to next review item;
       - Fail -> record "Missing file type filter, may allow unsupported file types to be uploaded", continue;
     - Whether the storage path uses dynamically generated filenames (to avoid filename conflicts and path traversal):
       - Pass -> record as passed, continue to next review item;
       - Fail -> record "Recommend using UUID or timestamp to rename files instead of original filenames", continue;
     - Whether large file downloads use StreamableFile (to avoid loading entire files into memory):
       - Pass -> record as passed, continue to next review item;
       - Fail -> record "Large file downloads should use StreamableFile for stream-based responses", continue;
     - Whether file upload endpoints have authentication/authorization guards (to prevent unauthorized uploads):
       - Pass -> record as passed, continue to next review item;
       - Fail -> record "File upload endpoint lacks access control, recommend adding guards", continue;
   - Determine if there are any issue records:
     - Yes -> compile issue list, proceed to next step;
     - No -> directly proceed to step 4 (review check);

3. **Provide modification suggestions** — Give specific fixes for identified issues;
   - Provide fix suggestions for each issue in sequence;
   - Offer options via AskUserQuestion, block and wait for user selection:
     - Accept all suggestions -> generate corrected code, proceed to step 4;
     - Confirm one by one -> let the user decide to accept or ignore each item, proceed to step 4 after all confirmed;
     - Review only without modification -> do not affect code, directly proceed to step 4;

4. **Review check** — Confirm execution results against [Review List](#review-list);
   - Determine if Review List has content:
     - No -> directly proceed to next step (output);
     - Yes -> next step;
   - Check each item in [Review List](#review-list) sequentially to see if it passes:
     - Display output based on the "Review check example";
   - If any check fails, terminate the process;
   - After all pass, proceed to next step;

5. **Output results** — Output review summary, inform completion;
   - Output structured summary table (reviewed file / number of review items / passed / issues found / risk level / adopted suggestions);
   - Inform the review is complete;

## Rules

- **Content rules**
  - description must follow format: first sentence describes review content, second sentence describes trigger condition, use third person, no more than 1024 characters;
  - Review items must reference NestJS official file upload documentation;
  - SKILL.md no more than 300 lines; split to references/ directory when exceeded;
  - Reference hierarchy no more than one level;
  - Maintain terminology consistency, terms defined in Definitions must be referenced via anchor links in the body;
  - Remove any time-sensitive information;

- **Behavior rules**
  - Only output issue summaries and locations during review, do not directly modify code unless the user explicitly requests via AskUserQuestion;
  - All interaction steps involving code modification must use the AskUserQuestion tool;
  - Storage strategy recommendations (local vs cloud storage) should be labeled as architectural suggestions, not mandatory;

- **Defensive rules**
  - If target code is empty or unreadable, report directly and terminate;
  - File size limits and type restrictions should only be recommended in production code, can be relaxed in development environments;

- **Validation rules**
  - Examples content must be self-consistent with Rules;
  - Examples must include a review check example;
  - Dialogue interaction examples should only focus on steps 0~3 (excluding review check and output);

## Examples

### Dialogue Interaction Example

**Example: User requests file upload configuration review**

```markdown
User > Help me check the security of the file upload functionality
AI   > Detected user needs NestJS file upload review, triggered nestjs-3-3-file-upload skill
AI   > Analyzing file upload code...

Review Results:
- 🟥 fileSize limit not configured, risk of large file attacks
- 🟥 fileFilter not configured, allowing all file types to be uploaded
- 🟩 Using UUID to rename uploaded files
- 🟥 Large file download uses readFileSync (should use StreamableFile)
- 🟩 Upload endpoint has AuthGuard added

Summary: 3 issues need attention
User > Help me harden the file upload security
AI   > Add fileSize: 5MB limit and image type filtering. Apply changes?
User > Accept all
```

### Review Check Example

```markdown
AI > Entering review check, Review List contains 5 items, starting verification:

**Content Check**
  - 🟩 All review items reference official documentation
  - 🟩 Storage strategy labeled as architectural suggestion

**Behavior Check**
  - 🟩 Did not directly modify user code
  - 🟩 Used AskUserQuestion

**Validation Check**
  - 🟩 Development environment limits labeled as relaxable
  - 🟩 Output summary is complete

✅ All passed, proceeding to output.
```

### Output Example

**Review Result Example:**

```markdown
| Dimension | Result |
| --- | --- |
| Reviewed File | src/common/upload.controller.ts |
| Total Review Items | 6 items |
| Passed | 3 items |
| Issues Found | 3 items |
| Risk Level | 🔴 High |
| Suggestions Adopted | 3 items |
```

## Review List

- **Content Check**
  - [ ] All review items reference NestJS official file upload documentation
  - [ ] Storage strategy labeled as architectural suggestion
- **Behavior Check**
  - [ ] Did not directly modify user code (unless explicitly requested by the user)
  - [ ] All interaction steps used AskUserQuestion
- **Validation Check**
  - [ ] Correctly terminated when target code is empty or unreadable
  - [ ] File limits labeled as relaxable in development environment
  - [ ] Output summary includes file path, number of review items, issues found, and risk level

## References

- [NestJS File Upload Official Documentation](https://docs.nestjs.com/techniques/file-upload)
- [NestJS Streaming Files](https://docs.nestjs.com/techniques/streaming-files)
- [Multer Documentation](https://github.com/expressjs/multer)
- [skill-evolve Template](../../skill-evolve/template.md)
