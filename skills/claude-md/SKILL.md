---
name: claude-md
description: Create a new CLAUDE.md or make targeted edits to an existing one
disable-model-invocation: true
---

# Create or Improve a CLAUDE.md

## Goal

CLAUDE.md is the only content guaranteed to appear in every Agent conversation in a repo — and the repo may hold code, business docs, a knowledge base, or any mix. Every line it carries is paid on every task, so it must carry only rules that are universally applicable (defined below) — that test drives every decision here. Such files usually land under ~100 lines, but length itself is not a rule: a longer file is fine when every line passes the test. Treat growth past that mark only as a cue to re-check the rules against it.

## Process

1. **Know the repo.** If you're creating from scratch, or the edit relies on repo knowledge you haven't verified, read `references/explore.md` and do the exploration first.
2. **Map the domain docs.** Inspect existing `CONTEXT.md`, `CONTEXT-MAP.md`, `PEOPLE.md`, ADRs, and `agent-docs/domain.md`. Establish whether the repo is code or non-code: non-code means the deliverable is documents, knowledge, or operations rather than software — supporting scripts don't change this. Use multi-context only when `CONTEXT-MAP.md` exists or the repo has verified distinct domain contexts; code layout or monorepo structure alone is not evidence. Otherwise use single-context.
3. **Edit or create.** If a CLAUDE.md exists, make targeted edits and steer the file toward the template below — don't rewrite from scratch unless it's fundamentally broken. If none exists, write one following the template.
4. **Write the domain consumer guide.** Read `references/domain.md`, then create or update `agent-docs/domain.md` from that seed using the verified layout. Do not create empty `CONTEXT.md`, `CONTEXT-MAP.md`, or ADR files.
5. **Disclose the rest.** Material that is only sometimes applicable goes in `agent-docs/`, not the root CLAUDE.md.
6. **Validate** the whole file against the checklist.

## Universally applicable

A rule belongs in CLAUDE.md only if it applies to **every single task** in the repo: would it apply when fixing a bug? Adding a feature? Drafting a document? Doing research? If the answer is "only sometimes", it belongs in a disclosure target or nowhere.

**Belongs:** "Use `uv add` instead of `pip install`" (every Python task); "Run `make check` before committing" (every change); "`company/identity.md` is the canonical source for all bios — never draft from scratch" (every writing task in that repo).

**Doesn't belong:** "Use React Query for data fetching" (only when adding data fetching); "lead files follow `sales/pipeline/_LEAD-TEMPLATE.md`" (only when creating leads); style rules a linter or formatter can enforce; inventories of commands, skills, hooks, or automations (discoverable via `.claude/`, and stale the week after you write them).

## Template

```markdown
# Project Name

[One sentence describing what this repo is]

## Quick Reference

[The handful of commands or canonical-file pointers needed on every task.]
[Code repo, typically:]
- **Build**: `[command]`
- **Test**: `[command]`
- **Lint**: `[command]`
[Docs/ops repo: pointers to canonical sources, e.g.]
- **Identity/Bio** → `company/identity.md` (canonical — never draft from scratch)

## Non-Obvious Structure

[Don't list directories — agents discover those via tools.]
[Document only what file and directory names alone don't reveal:]
[- Generated or machine-managed paths (so agents don't edit or hand-create them)]
[- Monorepo package relationships and dependency direction]
[- Naming conventions that imply behavior (e.g. *.server.ts = server-only)]
[- Canonical vs superseded distinctions (e.g. positioning/ current, archive/ old)]

## Key Patterns

[2-3 critical patterns unique to this repo, as pointers to canonical files (file:line for code) — never copied content]

## Domain docs

[Single-context: Single-context layout. Before working with or producing domain-specific output, read `agent-docs/domain.md` and apply the repo's context.]
[Multi-context: Multi-context layout. Before working in or producing output for a domain area, read `agent-docs/domain.md` to locate and apply that area's context.]
[Non-code repo: extend the chosen line's trigger to also fire on people, e.g. "Before working with domain-specific material, or producing output for or about a specific person (client, stakeholder), read `agent-docs/domain.md` …".]

## Documentation

- `agent-docs/architecture.md` - System design and component relationships
- `agent-docs/[area].md` - Read before creating or editing anything in `[folder]/` ([one-line contents hint])
[Only list files that exist. Do not repeat `agent-docs/domain.md` here; the triggered pointer above already discloses it.]
[Write scoped entries as triggers ("Read before …") — see Disclosure targets.]

## Critical Rules

[Only universally applicable rules; max 5-10; nothing a linter can enforce]
```

## Disclosure targets

Material that matters only for certain tasks belongs in **`agent-docs/`** at the repo root, e.g. `architecture.md`, `conventions.md`, or `content.md`. Use portable context pointers rather than scoped CLAUDE.md files, whose automatic loading is Claude Code-specific.

Write each Documentation entry as a **trigger** — the condition that requires reading the file — not a description of its contents: `` `agent-docs/<area>.md` - Read before creating or editing anything in `<folder>/` (contents hint) ``. A folder is the most common scope, but any determinate condition works ("Read before creating a lead"); reserve descriptive entries for genuinely cross-cutting references like `architecture.md`. The trigger is the portable replacement for scoped CLAUDE.md auto-loading. Widen the verb to match the folder's side effects — "creating, editing, or running" where scripts send email or spend money.

Only create a file when you have real content for it — no empty templates. The root CLAUDE.md's Documentation section lists every disclosure file except `agent-docs/domain.md`, which has its own triggered pointer.

### Domain consumer guide

`agent-docs/domain.md` is the routing layer, not the domain source. Build it from `references/domain.md`, adapting every path and the single- or multi-context layout to evidence from the repo. Contexts may live anywhere — never assume a code-specific path such as `src/`. Keep actual domain knowledge in `CONTEXT.md`, people context in `PEOPLE.md`, and actual decisions in ADRs; do not duplicate any of these into `agent-docs/domain.md`.

## Checklist

The change is done only when every box checks:

- [ ] Every directive universally applicable
- [ ] If past ~100 lines, the test above was re-run and every line still passes
- [ ] No style rules a linter or formatter could enforce
- [ ] No copied content — point at canonical files (`file:line` for code)
- [ ] No inventories of commands, skills, hooks, or automations
- [ ] Every command and file path presented as existing was verified; optional conventional paths are identified as optional
- [ ] "Only sometimes" material moved to a disclosure target, not deleted or inlined
- [ ] Scoped Documentation entries are trigger-phrased ("Read before …"), verbs matching the folder's side effects
- [ ] CLAUDE.md contains the correct single- or multi-context Domain docs pointer, extended with the people trigger in a non-code repo
- [ ] `agent-docs/domain.md` records the verified layout without duplicating domain knowledge
- [ ] No empty `CONTEXT.md`, `CONTEXT-MAP.md`, `PEOPLE.md`, or ADR files were created
