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
2. **Edit or create.** If a CLAUDE.md exists, make targeted edits and steer the file toward the template below — don't rewrite from scratch unless it's fundamentally broken. If none exists, write one following the template.
3. **Disclose the rest.** Material that is only sometimes applicable goes in a disclosure target (see below), not the root CLAUDE.md.
4. **Validate** the whole file against the checklist.

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

## Documentation

- `agent-docs/architecture.md` - System design and component relationships
- `content/CLAUDE.md` - Content creation conventions (scoped)
[Only list files that exist. Scoped CLAUDE.md files MUST be listed here: only Claude Code auto-loads them; other agents (e.g. Codex) read just the root file and find them only through this list.]

## Critical Rules

[Only universally applicable rules; max 5-10; nothing a linter can enforce]
```

## Disclosure targets

Two homes for "only sometimes" material — topics that matter for certain tasks but fail the universally-applicable test:

- **Scoped CLAUDE.md** in a subdirectory, when the material maps to that directory (e.g. `content/CLAUDE.md` for content conventions). Claude Code auto-loads it when working in that directory — but only Claude Code does, so every scoped file must also be listed in the root CLAUDE.md's Documentation section for other agents to find.
- **`agent-docs/`** at the repo root, for cross-cutting topics that don't map to one directory, e.g. `architecture.md`, `conventions.md`, `glossary.md`.

Only create a file when you have real content for it — no empty templates. The root CLAUDE.md's Documentation section lists them all.

## Checklist

The change is done only when every box checks:

- [ ] Every directive universally applicable
- [ ] If past ~100 lines, the test above was re-run and every line still passes
- [ ] No style rules a linter or formatter could enforce
- [ ] No copied content — point at canonical files (`file:line` for code)
- [ ] No inventories of commands, skills, hooks, or automations
- [ ] Every command and file path verified to exist, not guessed
- [ ] "Only sometimes" material moved to a disclosure target, not deleted or inlined
- [ ] Scoped CLAUDE.md files all listed in the Documentation section
