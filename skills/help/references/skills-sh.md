# skills.sh Guide (for Claude)

This reference helps you (the agent) guide the user through installing a skill from [skills.sh](https://skills.sh/) — an open ecosystem of reusable agent skills that work with Claude Code, Cursor, Windsurf, and other agents.

## What you can do vs. what the user does

| Action | Who |
|---|---|
| Suggest specific skills based on the user's need (browse skills.sh via WebFetch) | You |
| Check that Node.js is installed (`node --version`) | You |
| Install Node.js if missing | You via Bash, **with the UAC/sudo caveat** — hand off if it prompts |
| Run `npx skills add ...` | **User**, in a separate terminal — the CLI is interactive |
| Pick scope (user vs project) | **User** answers the CLI's own interactive prompt |
| Verify the skill installed | You via Bash (`ls`) |
| Restart Claude Code so the new skill loads | User |

**Why the user runs the install command:** the skills CLI presents an interactive menu (scope, optional config). Claude Code's Bash tool can't drive interactive prompts, so it has to run in the user's own terminal.

**Don't pre-ask scope.** The CLI already prompts for it during install — asking again upfront is duplicate friction. Just brief the user on what the prompt means (see Step 3) so they pick the right one.

Your job is to give them **one** clear command to copy-paste, plus everything around it (suggest, verify) — not a six-step walkthrough.

## Procedure

### Step 1 — Pick the skill

If the user already named a skill (`anthropics/skills`, `vercel-labs/agent-skills`, etc.), skip to Step 2.

If they described a need ("I want a skill for X"), help them find one:

- Browse the leaderboard via WebFetch: `https://skills.sh/`
- Or search docs: `https://skills.sh/docs`

Suggest 1–3 candidates with a one-line description of each. Let the user pick.

### Step 2 — Verify Node.js (you)

```bash
node --version && npm --version
```

If missing, offer to install (warn that it may prompt for a password / UAC and would need to be run by the user in that case):

- **Mac:** `brew install node`
- **Windows:** `winget install OpenJS.NodeJS.LTS --source winget`

If the install command becomes interactive and hangs Bash, hand it to the user.

### Step 3 — Hand the user the install command

Give them one command they can copy and run in a separate terminal:

```bash
npx skills add <owner>/<repo>
```

Tell the user:

1. Open a normal terminal (not Claude Code).
   - **Mac:** Cmd+Space → "Terminal"
   - **Windows:** Windows key → "PowerShell"
2. If they want the skill scoped to this project (shared with the team via git), `cd` into the project first — give them the actual path: `cd <project-path>`. Otherwise, run from anywhere for user-level install.
3. Run the command above.
4. **The CLI will ask where to install.** Brief them so they're ready:
   - **User level** → `~/.claude/skills/`, available in every project on this machine. Pick this for general-purpose / personal skills.
   - **Project level** → `.claude/skills/` in the current directory, shared with the team via git. Pick this for skills tied to this codebase. (Only available if they `cd`'d into a project first.)

### Step 4 — Verify installation (you)

After the user reports the install finished:

```bash
# User scope
ls ~/.claude/skills/

# Project scope
ls .claude/skills/
```

Confirm the new skill folder is present. If not, troubleshoot (see below).

### Step 5 — Tell the user to restart Claude Code

`/exit`, then `claude`. The new skill becomes available as a slash command — same name as the skill folder.

## Troubleshooting

### "npx: command not found"

Node.js isn't installed. Go back to Step 2.

### Skill not appearing after install

1. Check the right scope folder (Step 4). Picking the wrong scope at the CLI prompt is the most common cause — confirm with the user which they chose.
2. Confirm Claude Code was restarted (Step 5).
3. Open the skill's `SKILL.md` and check the frontmatter `name:` — that's the slash-command name.

### Want to remove a skill

You can do this for the user:

```bash
# User scope
rm -rf ~/.claude/skills/<skill-name>

# Project scope
rm -rf .claude/skills/<skill-name>
```

Confirm with the user before running `rm -rf`.

### Issues with a specific skill's behavior

That's an issue with the skill itself, not the installer. Direct the user to the skill's GitHub repo.

## Reference

- **Website:** https://skills.sh/
- **Docs:** https://skills.sh/docs
- **FAQ:** https://skills.sh/docs/faq
- **CLI source:** https://github.com/vercel-labs/skills
