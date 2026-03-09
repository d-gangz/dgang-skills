# dgang-skills

A collection of open-source agent skills for Claude Code. Install with a single command.

## Install

**All skills (user-level, available across all projects):**

```bash
npx skills add d-gangz/dgang-skills -g
```

**All skills (project-level, current project only):**

```bash
npx skills add d-gangz/dgang-skills
```

**List available skills:**

```bash
npx skills add d-gangz/dgang-skills --list
```

**A specific skill:**

```bash
npx skills add d-gangz/dgang-skills --skill schedule-tasks
npx skills add d-gangz/dgang-skills --skill schedule-tasks -g  # user-level
```

## Available Skills

### schedule-tasks

Manage persistent scheduled tasks that run Claude Code headlessly inside Claude Desktop on a cron schedule — tasks that survive across sessions and run automatically in the background.

**What it does:**

- **Create** scheduled tasks with a name, cron expression, prompt, and model
- **List** all scheduled tasks across projects with their status, schedule, and last run time
- **Delete** tasks and clean up associated session metadata
- **Analyze logs** — reads past session transcripts from completed runs, identifies recurring errors, wasted steps, and prompt issues, then directly improves the task's SKILL.md prompt

**When to use:** Say "scheduled task" or ask to create/manage tasks that persist beyond the current session. Works with Claude Desktop's built-in scheduler.

**When NOT to use:** For ephemeral in-session jobs like "remind me in 20 minutes" or "check this every 5 min" — those use the built-in `CronCreate`/`CronDelete` tools instead.

```bash
npx skills add d-gangz/dgang-skills --skill schedule-tasks
```

## Contributing

Want to add a skill? Create a new folder under `skills/<your-skill-name>/` with a valid `SKILL.md` and open a PR.

## License

MIT
