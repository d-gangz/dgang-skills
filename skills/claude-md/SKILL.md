---
name: claude-md
description: ALWAYS invoke this command when creating, editing, or improving any CLAUDE.md file
argument-hint: [additional information to add]
---

# Create or Improve a CLAUDE.md

## FIRST: Explore the Codebase

**Before doing ANYTHING else**, use the Task tool with these exact parameters:
- `subagent_type`: `Explore`
- `thoroughness`: `very thorough`
- `prompt`: Include the WHAT/WHY/HOW questions listed below

Do NOT proceed until exploration is complete.

---

## Overview

You are creating or improving a `CLAUDE.md` file for a codebase. This file is the **only content guaranteed to appear in every Claude conversation**, making it critical infrastructure for agent effectiveness.

## Key Principles (from HumanLayer research)

1. **Under 300 lines** (ideally <100). Shorter = better followed.
2. **Only universally applicable directives**. Claude's system prompt uses ~50 of ~150-200 available instruction slots.
3. **Progressive disclosure**: Reference separate docs, don't inline everything.
4. **Never use as linter**: Use actual linters/formatters, not LLM instructions for code style.
5. **No commands, skills, hooks, or automations**: These are discoverable via `/help`, `.claude/commands/`, `.claude/skills/`, `.claude/settings.json`, and `.claude/automations/`. Don't inventory them in CLAUDE.md — they change frequently and become stale.
6. **Use `file:line` pointers** instead of code snippets (prevents outdated info).

## What "Universally Applicable" Means

A rule is universally applicable if it applies to **every single task** in this codebase. Ask yourself:
- Would this rule apply when fixing a bug? Adding a feature? Writing tests? Refactoring?
- If the answer is "only sometimes", it does NOT belong in CLAUDE.md.

**Examples of universally applicable rules:**
- "Use `uv add` instead of `pip install`" (applies to every Python task)
- "Run `make check` before committing" (applies to every change)
- "All API endpoints require authentication except `/health`" (applies to every API task)

**Examples of NOT universally applicable (don't include):**
- "Use React Query for data fetching" (only applies when adding data fetching)
- "Add migration files for schema changes" (only applies when changing schema)
- Code style rules (use linters instead)
- Commands, skills, hooks, and automations (discoverable via tools, not LLM guidance)

## Your Process

### Step 1: Explore (ALREADY DONE ABOVE)

Your Explore agent should have discovered:

**WHAT** (Technology & Structure):
- Primary language(s) and frameworks
- Project structure (especially monorepo layouts)
- Key directories and their purposes
- Configuration files (package.json, pyproject.toml, Cargo.toml, etc.)
- Build/CI configuration

**WHY** (Purpose & Architecture):
- What the project does
- How different components relate
- Key abstractions and patterns used

**HOW** (Commands & Workflows):
- Build commands
- Test commands (unit, integration, e2e)
- Lint/format commands
- Run/dev commands
- Deployment patterns

### Step 2: Check Existing Documentation

Search for:
- Existing README.md, CONTRIBUTING.md, docs/
- Existing CLAUDE.md — if one exists, **read it carefully and propose targeted edits** rather than rewriting from scratch. Preserve what's already working.
- Architecture decision records (ADRs)
- Code conventions documentation

### Step 3: Create Progressive Disclosure Structure

If complex docs are needed, create an `agent-docs/` directory at the repo root with focused files:

```
agent-docs/
├── architecture.md       # System design, component relationships
├── build-and-test.md     # How to build, test, verify changes
├── conventions.md        # Code patterns specific to this project
├── database.md           # Schema, migrations, data patterns
├── api-patterns.md       # API design, authentication, etc.
└── glossary.md           # User-specific vocabulary Claude can't infer
```

Only create files that add real value. Don't create empty templates.

### Step 4: Write the CLAUDE.md

Structure the file as:

```markdown
# Project Name

[One sentence describing what this project is]

## Quick Reference

- **Build**: `[command]`
- **Test**: `[command]`
- **Lint**: `[command]`
- **Dev server**: `[command]`

## Non-Obvious Structure

[Don't list directories — Claude can discover those via tools]
[Instead, document things that AREN'T discoverable from file names alone:]
[- Generated code paths (so Claude doesn't edit them)]
[- Monorepo package relationships and dependency direction]
[- Naming conventions that imply behavior (e.g. *.server.ts = server-only)]
[- Co-location patterns (e.g. each feature owns its routes/, models/, services/)]

## Key Patterns

[2-3 critical patterns or conventions unique to this codebase]
[Use file:line references, not code snippets]

## Documentation

- `agent-docs/architecture.md` - System design and component relationships
- `agent-docs/build-and-test.md` - Detailed build and test instructions
[Only list files that exist]

## Critical Rules

[Only include rules that are UNIVERSALLY applicable across ALL tasks]
[Max 5-10 rules]
[If it can be enforced by a linter, don't include it here]
```

### Step 5: Validate Against Checklist

Before writing the CLAUDE.md:

- [ ] Under 100 lines (stretch goal: under 60)
- [ ] No code style rules (use linters instead)
- [ ] No code snippets (use file:line references)
- [ ] Only universally applicable directives
- [ ] Commands are verified to work
- [ ] Progressive disclosure used for complex topics
- [ ] References existing documentation where appropriate

## Output

1. **First**: Summarize what you discovered about the codebase
2. **Second**: Directly create or edit the `CLAUDE.md` file. If one exists, make targeted edits. If not, create it.
3. **Third**: Create any `agent-docs/` files that add real value
4. **Fourth**: List unresolved questions (e.g., "Is there a staging environment?")

## Important Notes

- If a CLAUDE.md already exists, **default to targeted edits** — don't rewrite from scratch. Only do a full replacement if the existing file is fundamentally broken.
- Ask clarifying questions if the codebase purpose is unclear.
- Don't guess at commands—verify they exist in package.json/Makefile/etc.
- Don't include commands, skills, hooks, automations, or other discoverable/deterministic config. These belong in `.claude/commands/`, `.claude/skills/`, `.claude/settings.json`, and `.claude/automations/` — not CLAUDE.md.

## Additional information provided by User

$ARGUMENTS
