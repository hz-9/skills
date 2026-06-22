---
name: grill-with-docs
description: Grilling session, challenge your solution against the existing domain model, clarify terminology, and immediately update documentation (CONTEXT.md, ADR) as decisions are made. Use when the user wants to stress-test a solution against the project's language and recorded decisions.
---

<what-to-do>

Keep questioning every aspect of this solution until we reach a consensus. Traverse each branch of the design tree one by one, resolving dependencies between decisions along the way. For each question, provide your recommended answer.

Ask one question at a time, and continue only after receiving feedback on each one.

If a question can be answered by browsing the codebase, go and browse the codebase.

</what-to-do>

<supporting-info>

## Domain Awareness

When browsing the codebase, also look for existing documentation:

### File Structure

Most repositories have a single context:

```
/
├── CONTEXT.md
├── docs/
│   └── adr/
│       ├── 0001-event-sourced-orders.md
│       └── 0002-postgres-for-write-model.md
└── src/
```

If a `CONTEXT-MAP.md` exists in the root directory, the repository has multiple contexts. The map points to where each context lives:

```
/
├── CONTEXT-MAP.md
├── docs/
│   └── adr/                          ← System-level decisions
├── src/
│   ├── ordering/
│   │   ├── CONTEXT.md
│   │   └── docs/adr/                 ← Context-specific decisions
│   └── billing/
│       ├── CONTEXT.md
│       └── docs/adr/
```

Create files lazily—only when you need to write content. If `CONTEXT.md` doesn't exist, create it when the first term is established. If `docs/adr/` doesn't exist, create it when the first ADR is needed.

## During the Session

### Challenge Against the Glossary

When the user uses a term that conflicts with language already in `CONTEXT.md`, point it out immediately. "Your glossary defines 'cancellation' as X, but you seem to mean Y—which one is it?"

### Clarify Ambiguous Language

When the user uses a vague or overloaded term, propose a precise canonical term. "You say 'account'—do you mean Customer or User? They're different things."

### Discuss Concrete Scenarios

When discussing domain relationships, stress-test them with concrete scenarios. Design scenarios that probe edge cases and force the user to precisely articulate the boundaries between concepts.

### Cross-Reference with Code

When the user states how something works, check if the code agrees. If you find a contradiction, surface it: "Your code cancels entire Orders, but you just said partial cancellation is possible—which one is correct?"

### Update CONTEXT.md Immediately

Update `CONTEXT.md` as soon as a term is established. Don't batch—capture them as they happen. Use the format from [CONTEXT-FORMAT.md](./CONTEXT-FORMAT.md).

Don't couple `CONTEXT.md` with implementation details. Only include terms that are meaningful to domain experts.

### Offer ADRs Judiciously

Only offer to create an ADR when all three of the following conditions are met:

1. **Hard to reverse**—changing your mind later would be costly
2. **Surprising without context**—future readers would wonder "why did they do that?"
3. **A genuine trade-off**—real alternatives existed and you chose one for a specific reason

If any condition is missing, skip the ADR. Use the format from [ADR-FORMAT.md](./ADR-FORMAT.md).

</supporting-info>
