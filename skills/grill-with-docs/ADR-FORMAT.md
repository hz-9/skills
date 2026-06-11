# ADR Format

ADRs live in the `docs/adr/` directory, using sequential numbering: `0001-slug.md`, `0002-slug.md`, etc.

Create the `docs/adr/` directory lazily—only when the first ADR is needed.

## Template

```md
# {Short title of the decision}

{1-3 sentences: what the context was, what we decided, and why.}
```

That's it. An ADR can be a single paragraph. Its value lies in recording that a decision *was* made and *why*—not in filling out sections.

## Optional Sections

Only include these when they provide real value. Most ADRs won't need them.

- **Status** front-matter (`proposed | accepted | deprecated | superseded by ADR-NNNN`)—useful when a decision gets revisited
- **Options considered**—only when the rejected alternatives are worth remembering
- **Consequences**—only when there are non-obvious downstream effects to call out

## Numbering

Scan the highest existing number in the `docs/adr/` directory, then add one.

## When to Propose Writing an ADR

All three conditions must be met:

1. **Hard to undo**—changing your mind would be costly
2. **Confusing without context**—future readers looking at the code would think "why in the world did they do that?"
3. **A real trade-off**—genuine alternatives existed and you chose one based on specific reasons

If a decision is easy to undo, skip it—you can always change it back. If it's not confusing, no one will question why. If there were no real alternatives, there's nothing to record other than "we did the obvious thing."

### What Qualifies

- **Architectural shape.** "We use a monorepo." "The write model is event-sourced, and the read model is projected to Postgres."
- **Integration patterns between contexts.** "Ordering and Billing communicate via domain events, not synchronous HTTP."
- **Technology choices with lock-in effects.** Database, message bus, auth provider, deployment target. Not every library—only those that would take a quarter to replace.
- **Boundary and scope decisions.** "Customer data is owned by the Customer context; other contexts reference it only by ID." Explicit negatives are just as valuable as positives.
- **Intentional deviations from the norm.** "We use manual SQL instead of an ORM because of X." Any place a reasonable reader might assume the opposite. This prevents the next engineer from "fixing" something that was done intentionally.
- **Constraints invisible in code.** "We can't use AWS due to compliance requirements." "Response times must be under 200ms due to the partner API contract."
- **Rejected alternatives (when the rejection reason isn't obvious).** If you considered GraphQL but chose REST for a nuanced reason, document it—otherwise someone will propose GraphQL again in six months.
