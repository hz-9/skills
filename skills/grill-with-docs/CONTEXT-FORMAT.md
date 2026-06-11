# CONTEXT.md Format

## Structure

```md
# {Context Name}

{One or two sentences describing what this context is and why it exists.}

## Language

**Order**:
{A concise description of the term}
_Avoid using_: Purchases, Transactions

**Invoice**:
A payment request sent to the customer after delivery.
_Avoid using_: Bill, Payment Request

**Customer**:
The individual or organization that places an order.
_Avoid using_: Client, Buyer, Account

## Relationships

- An **Order** generates one or more **Invoices**
- An **Invoice** belongs to exactly one **Customer**

## Example Conversation

> **Developer:** "When a **Customer** places an **Order**, do we immediately create an **Invoice**?"
> **Domain Expert:** "No—an **Invoice** is only generated after **Fulfillment** is confirmed."

## Tagged Ambiguities

- "account" was previously used for both **Customer** and **User**—resolved: they are distinct concepts.
```

## Rules

- **Be opinionated.** When multiple words exist for the same concept, pick the best one and list the others as aliases to avoid.
- **Tag conflicts explicitly.** If a term's usage is ambiguous, call it out in the "Tagged Ambiguities" section and give a clear resolution.
- **Keep definitions lean.** One sentence max. Define what it **is**, not what it does.
- **Show relationships.** Use bolded term names and indicate cardinality where necessary.
- **Only include terms specific to this project's context.** Generic programming concepts (timeout, error types, tooling patterns) don't belong here even if widely used in the project. Before adding a term, ask yourself: is this a concept unique to this context, or a general programming concept? Only the former belongs here.
- **Group terms under subheadings when they naturally form clusters.** If all terms belong to the same cohesive domain, a simple list works.
- **Write an example conversation.** A dialogue between a developer and a domain expert that shows how terms interact naturally and clarifies the boundaries between related concepts.

## Single Context vs. Multi-Context Repositories

**Single context (most repositories):** A single `CONTEXT.md` at the repository root.

**Multi-context:** A `CONTEXT-MAP.md` at the repository root that lists each context with its location and relationships:

```md
# Context Map

## Contexts

- [Ordering](./src/ordering/CONTEXT.md) — Receives and tracks customer orders
- [Billing](./src/billing/CONTEXT.md) — Generates invoices and processes payments
- [Fulfillment](./src/fulfillment/CONTEXT.md) — Manages warehouse picking and shipping

## Relationships

- **Ordering → Fulfillment**: Ordering emits `OrderPlaced` events; Fulfillment consumes these to start picking
- **Fulfillment → Billing**: Fulfillment emits `ShipmentDispatched` events; Billing consumes these to generate invoices
- **Ordering ↔ Billing**: Share `CustomerId` and `Money` types
```

The skill infers the applicable structure:

- If `CONTEXT-MAP.md` exists, read it to find contexts
- If only `CONTEXT.md` at the root, it's a single context
- If neither exists, lazily create a root `CONTEXT.md` when the first term needs to be resolved

When there are multiple contexts, infer which one the current topic relates to. If unsure, ask.
