# Punctuation Usage Convention — Standardize Punctuation Usage in SKILL.md and references/ Files

## Overview

Standardize punctuation usage in SKILL.md and `references/` files, ensuring consistent full-width/half-width usage, unified branch marker symbols, and language-appropriate quotes/brackets. Avoid AI format learning disorders caused by inconsistent symbols.

## Core Principles

1. **Language determines symbols**: Chinese content uses full-width punctuation, English content uses half-width punctuation (applies to body text only; code blocks, inline code, and file paths always use half-width).
2. **Branch symbol binding**: The tree arrow format of branch logic binds specific symbols (`；` as terminator, `：` as sub-operation introducer), unchanged by language switching.
3. **Specification file self-referential consistency**: All reference files' own punctuation usage must conform to this document's definitions, with no internal inconsistencies.

## Rule 1: Full-width / Half-width Distinction

### 1.1 Chinese Body Text

- Period `。`, comma `，`, colon `：`, semicolon `；`, parentheses `（）` — all full-width
- Quotes: Chinese body text uses Chinese curly quotes (left `"`, right `"` and left `'`, right `'`), not half-width straight quotes `""`
- Em dash: Uniformly use `—` (full-width em dash with one space on each side)
- Book title marks: `《》`

### 1.2 English Body Text

- Period `.`, comma `,`, colon `:`, semicolon `;`, parentheses `()`, quotes `"` `'` — all half-width

### 1.3 Mixed Content

- Code blocks, inline code (`` `code` ``), file paths (`path/to/file`) always use half-width, unchanged by context language
- Half-width symbols in technical terms (e.g., `v2.1.0`, `README.md`) remain half-width
- No mixing: do not use half-width commas in Chinese sentences, nor full-width commas in English sentences

### Examples

```markdown
**Correct** (Chinese uses full-width)
Check whether `name` exists: if missing, provide options via AskUserQuestion.

**Wrong** (Chinese uses half-width colon and comma)
Check whether `name` exists: if missing, provide options via AskUserQuestion.
```

## Rule 2: Branch Logic Marker Symbols

Consistent with branch logic marker symbols in [Workflow Writing Standard](workflow-standard.md#branch-logic-writing-format):

| Symbol             | Position                              | Meaning                                    |
| ------------------ | ------------------------------------- | ------------------------------------------ |
| `；` (full-width)  | End of each branch action line        | Branch end marker, indicating this path terminates |
| `：` (full-width)  | End of non-terminating branch line introducing sub-conditions/sub-operations | Sub-operation expansion marker             |
| `->` (half-width)  | Between branch condition and action   | Branch direction indicator, **full-width arrow `→` is prohibited** |

**Prohibited**:

- Using `;` instead of `；` (half-width semicolon replacing full-width semicolon is unacceptable because visual differences may cause AI to ignore the rule)
- Using `；` as an enumeration separator in non-branch logic regular text (should use `、` or `，`)
- Using full-width arrow `→` instead of `->`; all arrow symbols must use half-width `->`, including "A → B" in text descriptions which should be replaced with "A -> B"
- Using `；` as a separator between actions and flow control (e.g., `next step;`); when explicit flow direction annotation is needed after an action, use `，` to connect, e.g., `execute action, then proceed to next step;`

### Examples

```markdown
**Correct**

- Check if file exists:
  - Yes -> read content;
  - No -> terminate flow;

**Wrong** (half-width semicolon instead of full-width semicolon)

- Check if file exists:
  - Yes -> read content;
  - No -> terminate flow;
```

## Rule 3: Quote Usage

| Language             | Quote Type            | Example                           |
| -------------------- | --------------------- | --------------------------------- |
| Chinese              | Curly quotes `""` `''`| Report "target not found"         |
| Chinese nested quote | `'...'`               | He said 'okay'                    |
| English              | Straight quotes `"` `'`| Report "target not found"         |
| Inline code          | Backticks `` ` ``     | `name` field                      |

**Prohibited**:

- Using straight quotes in Chinese (outside code context, Chinese body text quotes should use curly quotes, not half-width straight quotes)
  - Wrong example (straight quotes): `"target not found"` (using half-width straight quotes)
  - Correct example (curly quotes): `"target not found"` (using Chinese curly quotes, with left and right directional differences)
- Using curly quotes in English

## Rule 4: Parentheses Usage

| Language      | Parenthesis Type    | Example                                        |
| ------------- | ------------------- | ---------------------------------------------- |
| Chinese       | Full-width `（）`   | Overwrite (overwrite file) / Merge (merge content) |
| English       | Half-width `()`     | Provide options (overwrite / merge / skip)      |
| Code/Path     | Half-width `()`     | Used only for function calls or technical syntax |

**Note**: Option lists in `AskUserQuestion` have been changed to indented sublist format, no longer using parentheses for options. Parentheses are only used for inline enumeration in non-AskUserQuestion scenarios.

## Rule 5: Ellipsis and Enumeration

- Enumeration separators: use `、` (Chinese) or `, ` (English): `overwrite, merge, skip` or `overwrite, merge, skip`
- `...` (three half-width dots) only for code or technical context, not as Chinese ellipsis
- Chinese ellipsis should be `……` (two full-width dots), but unnecessary ellipsis should be avoided in SKILL.md

## Rule 6: Special Symbols

### 6.1 Bidirectional Arrow `↔`

`↔` indicates a bidirectional mapping relationship, used only in Definitions to show equivalence between terms.

> **Example**: `Description`↔`Overview` (indicating both have the same meaning and can be mapped to each other)

**Prohibited**:

- Using `↔` to indicate flow direction in Workflow (flow direction should use `->` half-width arrow)
- Using `↔` in Rules or Review List

### 6.2 Full-Width Em Dash `—`

- Full-width em dash `—` is only used as a separator in headings/entries, with one space on each side: `Step Name — Step Description`
- Prohibited from using full-width em dash in body text to replace commas or periods
- Prohibited from using two or more consecutive full-width em dashes `———`

### 6.3 Tilde `～`

- Avoid using tilde `～` in SKILL.md
- Use textual expressions for ranges (e.g., "3 to 5"), do not use `3～5`

### 6.4 Backticks

- Backticks (`` ` ``) are only used to wrap inline code, filenames, file paths, and tool names
- Prohibited from using backticks to replace quotes in non-code contexts

### 6.5 HTML Tag Attributes

- HTML tag attribute values must use half-width straight quotes `""` (e.g., `<a id="xxx">`), prohibited from using Chinese curly quotes
- Even in Chinese context HTML tags (e.g., `<a id="similar-meaning-section">`), attribute value quotes must still use half-width straight quotes

## Common Anti-patterns

### Anti-pattern 1: Full-width / Half-width Mixing

> **Wrong**: `Provide options via AskUserQuestion (overwrite/merge/skip), block and wait for user selection`
> **Problem**: Parentheses are half-width but Chinese body text uses full-width punctuation, style inconsistency
> **Correct**:
>
> ```markdown
> Provide options via AskUserQuestion, block and wait for user selection:
>     - Overwrite -> next step;
>     - Merge -> next step;
>     - Skip -> next step;
> ```

### Anti-pattern 2: Semicolon Misuse

> **Wrong**: `next step; continue checking next file;`
> **Problem**: Using two full-width semicolons in the same line, violating "each semicolon marks the end of a single branch"
> **Correct**: Split into two lines or use commas to connect non-branch content

### Anti-pattern 3: Incomplete Language Switching

> **Wrong**: `Next step;` (Chinese symbol in English SKILL.md)
> **Problem**: Punctuation not updated during synchronous translation
> **Correct**: English uses `Next step;`

### Anti-pattern 4: Semicolon Separating Action and Flow Control

> **Wrong**: `overwrite file; next step;`
> **Problem**: Stacking two full-width semicolons in the same line; the first `；` is interpreted as a branch end marker, but `next step;` follows, causing semantic conflict
> **Correct**: `overwrite file, then proceed to next step;` (using comma to connect action and flow control)

## Verification Checklist

- [ ] Chinese content uses full-width punctuation (`。，：；（）""`), English content uses half-width punctuation (`.,:;()"`)
- [ ] Code blocks, inline code, file paths use half-width symbols
- [ ] Branch logic: terminating lines end with `；`, non-terminating lines end with `：`
- [ ] Quotes: Chinese uses curly quotes "", English uses straight quotes ""
- [ ] Parentheses: Chinese uses full-width `（）`, English uses half-width `()`
- [ ] No full-width/half-width mixing (same type of symbols consistent within the same paragraph)
- [ ] Ellipsis: Chinese body text uses `……` (two full-width dots), `...` only for code context
- [ ] Bidirectional arrow `↔` only used in Definitions, not appearing in Workflow/Rules/Review List
- [ ] Full-width em dash `—` only used as heading separator (one space on each side), not used consecutively
- [ ] HTML tag attribute values use half-width straight quotes `""`, not Chinese curly quotes
- [ ] Specification files themselves pass all the above check items
