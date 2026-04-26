# dgang-skills

A collection of open-source agent skills for Claude Code. Install with a single command.

## Install

```bash
npx skills add d-gangz/dgang-skills
```

This launches an interactive guide where you can choose which skills to install and whether to install at user-level or project-level.

## Available Skills

### create-brief

Shape conversation context (or a fresh task description) into a 5-part brief — Context / Task / Constraints / Verification / Output format — ready to hand off to an agent.

**When to use:** You're ready to execute a task and want it structured first. Composes naturally with `grill-me` upstream, but works standalone too.

**Triggers:** "draft a brief", "shape this into a brief", "turn this into a task spec", "write a brief for this".

```bash
npx skills add d-gangz/dgang-skills --skill create-brief
```

### create-cli

Build command-line interfaces for AI agents. Covers arguments, flags, subcommands, help text, output formats, error messages, exit codes, config/env precedence, and safe/dry-run behavior.

**When to use:** Building a new CLI or refactoring an existing one for agent use. Includes references on CLI guidelines, auth for agents, context-window discipline, multi-resource CLIs, and response sanitization.

```bash
npx skills add d-gangz/dgang-skills --skill create-cli
```

### grill-me

Interview the user relentlessly about whatever they want to work on — a plan, task, design, idea, feature, architecture decision, or anything else — until reaching shared understanding. Walks the decision tree one branch at a time, resolving dependencies between decisions.

**When to use:** Say "grill me", or when you want to stress-test a plan, be interviewed about a design, or flesh out an under-specified task.

```bash
npx skills add d-gangz/dgang-skills --skill grill-me
```

### skill-master

Create new skills, modify and improve existing skills. Engages with the task first to understand the workflow, then drafts the skill — rather than jumping straight to writing.

**When to use:** Creating a skill from scratch, editing or optimizing an existing one, turning a workflow into a reusable skill, or improving a skill's description for better triggering.

```bash
npx skills add d-gangz/dgang-skills --skill skill-master
```

### claude-md

Create or improve a `CLAUDE.md` file. Explores the codebase first, then writes instructions tuned to what actually exists.

**When to use:** Always invoke when creating, editing, or improving any `CLAUDE.md` file.

```bash
npx skills add d-gangz/dgang-skills --skill claude-md
```

### tune-review-structure

Audit a non-technical repo's folder structure for agent-navigability and propose a refactor plan.

**When to use:** Say "review structure", "audit folders", "audit my repo", "check organization", "is my repo agent-friendly", or "clean up structure".

```bash
npx skills add d-gangz/dgang-skills --skill tune-review-structure
```

### schedule-tasks

Manage persistent scheduled tasks that run Claude Code headlessly inside Claude Desktop on a cron schedule — tasks that survive across sessions and run automatically in the background.

**What it does:**

- **Create** scheduled tasks with a name, cron expression, prompt, and model
- **List** all scheduled tasks across projects with their status, schedule, and last run time
- **Delete** tasks and clean up associated session metadata
- **Analyze logs** — reads past session transcripts from completed runs, identifies recurring errors, wasted steps, and prompt issues, then directly improves the task's SKILL.md prompt

**Compatibility:** This skill works with **Claude Code scheduled tasks** only. It does **not** support Claude Cowork scheduled tasks — these are different scheduling systems with separate configurations and session management.

**When to use:** Say "scheduled task" or ask to create/manage tasks that persist beyond the current session. Works with Claude Desktop's built-in scheduler.

**Note:** After creating or deleting a scheduled task, restart Claude Desktop for changes to take effect. Prompt edits to an existing task's SKILL.md take effect on the next run without a restart.

**When NOT to use:** For ephemeral in-session jobs like "remind me in 20 minutes" or "check this every 5 min" — those use the built-in `CronCreate`/`CronDelete` tools instead.

```bash
npx skills add d-gangz/dgang-skills --skill schedule-tasks
```

## Requirements

macOS or Linux. Some skills use bash scripts and macOS-specific paths (e.g. `~/Library/Application Support/`), so they won't work on Windows.

## Contributing

Want to add a skill? Create a new folder under `skills/<your-skill-name>/` with a valid `SKILL.md` and open a PR.

## License

MIT
