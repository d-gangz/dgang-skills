# Domain Docs Seed

Adapt this seed into the repo's `agent-docs/domain.md`. Remove drafting notes, choose exactly one layout, include the people lines only for a non-code repo, and replace example paths with verified repo paths. Do not create missing context, people, or ADR files to satisfy the seed.

```markdown
# Domain Docs

This repository uses a [single domain context / multiple domain contexts].

## Before working with the domain

- For a single-context repo, read root `CONTEXT.md` if it exists.
- For a multi-context repo, read root `CONTEXT-MAP.md`, then only the context-specific `CONTEXT.md` files relevant to the task.
- [Non-code repo:] If the task produces output for or about specific people (clients, stakeholders, owners), read root `PEOPLE.md` if it exists.
- Read relevant system-wide and context-specific ADRs from their verified locations.

If any of these files do not exist, proceed silently. Do not flag their absence or suggest creating them upfront. The `domain-modeling` skill, reached through `grill-with-docs` or `improve-codebase-architecture`, creates them lazily when terms, decisions, or person-facts are resolved.

## Use the glossary's vocabulary

When your output names a domain concept—in an issue title, refactor proposal, hypothesis, test name, documentation, plan, or research, use the term defined in the relevant `CONTEXT.md`. Do not drift to synonyms the glossary explicitly avoids.

If the concept you need is not in the glossary, treat that as a signal: either you are inventing language the project does not use, in which case reconsider it, or there is a real gap — flag it (see below).

## Flag gaps — keep working

If you learn something the domain docs should hold but don't — a missing or drifting term, or [non-code repo:] a durable, work-relevant fact about a person — flag it in your response and suggest running the `domain-modeling` skill. Then continue the task: never block, and never detour to update the domain docs mid-task.

## Flag ADR conflicts

If proposed work contradicts an existing ADR, surface the conflict explicitly instead of silently overriding the decision.

## Layout

[For a single-context repo, show the verified layout. Example:]

    /
    ├── CONTEXT.md
    ├── PEOPLE.md                     [non-code repo]
    └── <verified ADR location>/

[For a multi-context repo, show the verified map, context, and ADR locations. Contexts may live anywhere in code or non-code repos. Example:]

    /
    ├── CONTEXT-MAP.md
    ├── PEOPLE.md                     [non-code repo — always at the root, never per-context]
    ├── <verified system-wide ADR location>/
    ├── <first-context>/
    │   ├── CONTEXT.md
    │   └── <verified context ADR location>/
    └── <second-context>/
        ├── CONTEXT.md
        └── <verified context ADR location>/
```
