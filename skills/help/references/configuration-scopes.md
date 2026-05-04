# Configuration Scopes (for Claude)

This reference is your decision guide when the user asks **"where should I put X"**, **"should this be user or project"**, or **"how do I move X from one to the other"**. The same scope concept applies to settings, MCP servers, plugins, skills, agents, and CLAUDE.md.

You can read and edit any of these scopes yourself via Bash / Read / Edit — `~/.claude/`, `.claude/`, `.mcp.json`, `~/.claude.json` are all just files. **Do the file moves yourself; don't make the user do it.** But always **confirm the target scope with the user via `AskUserQuestion`** before acting — the wrong scope is invisible and frustrating to undo.

## The three scopes

| Scope | Where it lives | Who sees it | Shared via git? |
|---|---|---|---|
| **User** | `~/.claude/` (and `~/.claude.json` for MCP) | You, in every project on this machine | No |
| **Project** | `.claude/` in repo (and `.mcp.json` at repo root for MCP) | Everyone on the project | Yes (committed) |
| **Local** | `.claude/settings.local.json` (and `CLAUDE.local.md`) | You, in this repo only | No (gitignored) |

**Precedence (when the same setting is in multiple scopes):** Local > Project > User. Example: project `.claude/settings.json` denies `Bash(rm *)` → your user-level allow doesn't override it.

## File-by-file location map

| Feature | User | Project | Local |
|---|---|---|---|
| Settings | `~/.claude/settings.json` | `.claude/settings.json` | `.claude/settings.local.json` |
| MCP servers | `~/.claude.json` *(home folder, NOT inside `~/.claude/`)* | `.mcp.json` *(repo root, NOT inside `.claude/`)* | — (use project or user) |
| Skills | `~/.claude/skills/` | `.claude/skills/` | — |
| Subagents | `~/.claude/agents/` | `.claude/agents/` | — |
| Plugins (registration) | `~/.claude/settings.json` | `.claude/settings.json` | `.claude/settings.local.json` |
| CLAUDE.md | `~/.claude/CLAUDE.md` | `CLAUDE.md` *or* `.claude/CLAUDE.md` | `CLAUDE.local.md` |

**Note for CLAUDE.md:** all three are loaded and concatenated — the user, project, and local CLAUDE.md all show up in the agent's context. They don't override each other.

## How you decide which to suggest

Use this rubric when proposing a default, then confirm with `AskUserQuestion`:

| Situation | Suggest |
|---|---|
| Personal API key / credential | User |
| MCP server tied to user's personal account (their Notion, their email) | User |
| MCP server everyone on the project needs (team Sentry, shared Linear) | Project |
| Skill the user wants in every project | User |
| Skill specific to one project's domain | Project |
| Team coding standards / project rules | Project (in `CLAUDE.md`) |
| Personal preferences ("always use bun", "don't add comments") | User (in `~/.claude/CLAUDE.md`) |
| Permissions for a command they keep approving | Match the scope of the command's relevance — `bun run dev` for one project = Local; `gh ...` everywhere = User |
| Trying out a setting before sharing it | Local |
| Anything with secrets that must not be committed | User or Local — never Project |

Always **ask** with `AskUserQuestion`, two options minimum: "Project (shared with team via git)" vs "User (just you, all projects)". Add a third "Local (just you, this project, gitignored)" only when relevant.

## Common requests and how to handle them

### "Move X from project to user level"

1. Read the current location (Read tool).
2. Read the target file (or note that it doesn't exist yet).
3. Merge — don't overwrite — into the target.
4. Remove from the source.
5. Tell the user what you changed and where.

For settings JSON, merge by key (don't blow away their existing keys). For skills/agents (folder-based), `mv` the directory.

### "Where is my MCP config?"

The two MCP locations trip people up — they're **not** under `.claude/`:

- **Project MCP**: `.mcp.json` at the project root (same level as `.claude/`)
- **User MCP**: `~/.claude.json` in the home folder (NOT `~/.claude/.mcp.json` — that file does not exist)

Both are hidden files (start with `.`). On Mac, **Cmd+Shift+.** in Finder reveals hidden files. You can also just open them yourself with Read.

### "I added something but it's not loading"

Check:
1. Is it in the scope you think? (e.g. project skill in `.claude/skills/<name>/SKILL.md`, not `~/.claude/skills/`)
2. For settings/MCP changes: did the user restart Claude Code? Most config is read on session start.
3. Is `settings.json` valid JSON? `jq . .claude/settings.json` — a parse error silently disables the file.

## What you can do vs. what the user does

| Action | Who |
|---|---|
| Read any config file (Read tool) | You |
| Edit any config file (Edit tool) | You |
| Move files between scopes (Bash `mv`, Read+Write) | You |
| Validate JSON (`jq .`) | You |
| Restart Claude Code (`/exit`, then `claude`) for changes to take effect | User |
| Decide between project / user / local scope | User decides — you ask via `AskUserQuestion` |
