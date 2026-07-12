---
name: domain-modeling
description: Build and sharpen a project's domain model. Use when the user wants to pin down domain terminology or a ubiquitous language, record a significant decision, capture working context about the people a non-code project serves, or when another skill needs to maintain the domain model.
---

# Domain Modeling

Actively build and sharpen the project's domain model as you design. This is the *active* discipline — challenging terms, inventing edge-case scenarios, and writing the glossary and decisions down the moment they crystallise. (Merely *reading* `CONTEXT.md` for vocabulary is not this skill — that's a one-line habit any skill can do. This skill is for when you're changing the model, not just consuming it.)

This applies to any repo built around a domain — software, or a non-code repo: one whose deliverable is not software but documents, operations, research, or knowledge. The test is what the repo produces, not what it contains — supporting scripts that serve the documents (converters, senders, digests) don't make a repo a code repo, and an app or library is a code repo no matter how much markdown it holds. Where the steps below say *code*, read *the repo's source of truth*: in a non-code repo that's the canonical documents, data, or records. Likewise an ADR records any consequential decision — a strategy, policy, or structural choice — not only software architecture. In a non-code repo the model also includes the people the work is for, with, or about — captured in a single root `PEOPLE.md` roster. Code repos skip this; a cast of named individuals is almost never load-bearing context there.

## File structure

Most repos have a single context:

```
/
├── CONTEXT.md
├── PEOPLE.md                         ← non-code repos only
├── agent-docs/
│   └── adr/
│       ├── 0001-event-sourced-orders.md
│       └── 0002-postgres-for-write-model.md
└── src/
```

If a `CONTEXT-MAP.md` exists at the root, the repo has multiple contexts. The map points to where each one lives:

```
/
├── CONTEXT-MAP.md
├── PEOPLE.md                         ← non-code repos only; always at the root, never per-context
├── agent-docs/
│   └── adr/                          ← system-wide decisions
├── src/
│   ├── ordering/
│   │   ├── CONTEXT.md
│   │   └── docs/adr/                 ← context-specific decisions
│   └── billing/
│       ├── CONTEXT.md
│       └── docs/adr/
```

Create files lazily — only when you have something to write. If no `CONTEXT.md` exists, create one when the first term is resolved. If no `agent-docs/adr/` exists, create it when the first ADR is needed. If no `PEOPLE.md` exists (non-code repos), create it when the first person-fact is resolved.

## During the session

### Challenge against the glossary

When the user uses a term that conflicts with the existing language in `CONTEXT.md`, call it out immediately. "Your glossary defines 'cancellation' as X, but you seem to mean Y — which is it?"

### Sharpen fuzzy language

When the user uses vague or overloaded terms, propose a precise canonical term. "You're saying 'account' — do you mean the Customer or the User? Those are different things."

### Discuss concrete scenarios

When domain relationships are being discussed, stress-test them with specific scenarios. Invent scenarios that probe edge cases and force the user to be precise about the boundaries between concepts.

### Cross-reference with the source of truth

When the user states how something works, check whether the repo's source of truth agrees — the code, or in a non-code repo the canonical documents, data, or records. If you find a contradiction, surface it: "Your code cancels entire Orders, but you just said partial cancellation is possible — which is right?"

### Update CONTEXT.md inline

When a term is resolved, update `CONTEXT.md` right there. Don't batch these up — capture them as they happen. Use the format in [CONTEXT-FORMAT.md](./CONTEXT-FORMAT.md).

`CONTEXT.md` should be totally devoid of implementation details. Do not treat `CONTEXT.md` as a spec, a scratch pad, or a repository for implementation decisions. It is a glossary and nothing else.

### Maintain the people roster (non-code repos)

When the user references a person ambiguously — "the client", "the stakeholder" — sharpen it: *which person?* When a durable, work-relevant fact about a person is resolved — their authority, what they care about, how they want things delivered — update `PEOPLE.md` right there, same as a glossary term. Use the format in [PEOPLE-FORMAT.md](./PEOPLE-FORMAT.md); the write bar lives there.

### Offer ADRs sparingly

Only offer to create an ADR when all three are true:

1. **Hard to reverse** — the cost of changing your mind later is meaningful
2. **Surprising without context** — a future reader will wonder "why did they do it this way?"
3. **The result of a real trade-off** — there were genuine alternatives and you picked one for specific reasons

If any of the three is missing, skip the ADR. Use the format in [ADR-FORMAT.md](./ADR-FORMAT.md).