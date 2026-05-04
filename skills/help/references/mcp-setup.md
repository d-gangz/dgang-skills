# MCP Setup Guide (for Claude)

This reference helps you (the agent) add an MCP server for the user. **Do as much yourself as possible** via Bash, file edits, etc. Only defer to the user for things you genuinely can't do: interactive OAuth in a browser, restarting Claude Code, or commands that need an interactive password/UAC prompt.

## What you decide vs what you ask

The user typically gives you a server name and either a URL (HTTP MCP) or an `npx`/JSON config (stdio MCP). Decide the rest from context — only ask if genuinely ambiguous:

- **Transport**: URL → `http`. `npx ...` or stdio JSON → `stdio`.
- **Platform**: detect via Bash (`uname`). Windows changes the procedure for stdio servers only.
- **Scope**: ask the user, unless they already said. Don't assume — the difference matters and the user might not know it. Show both options briefly:
  - **Project (`--scope project`)** — saved to `.mcp.json` in this project, checked into git, shared with everyone on the project. Pick this for tools the whole team should have (e.g. team Notion, shared Sentry).
  - **User (`--scope user`)** — saved to `~/.claude.json`, available across all your projects, just for you. Pick this for personal tools or anything with private credentials you don't want in the repo.

  Use the `AskUserQuestion` tool with these two options.

## Prerequisites

For any stdio MCP that uses `npx`, verify Node.js first:

```bash
node --version && npm --version
```

If missing, **offer to install it for the user via Bash** — you can run `brew` / `winget` yourself. Confirm before running since it modifies the system, and warn that it may prompt for a password (sudo on Mac) or a UAC dialog (Windows):

- **Mac:** `brew install node`
- **Windows:** `winget install OpenJS.NodeJS.LTS --source winget`

If the install command becomes interactive (password prompt, UAC), it'll hang Bash — at that point, hand the command to the user to run in their own terminal.

HTTP MCPs don't need Node.js.

## Procedure: HTTP MCP (the easy case)

Most popular MCPs are HTTP — Notion, GitHub, Sentry, Linear, Slack. Same command on every platform, including Windows. Run it yourself via Bash:

```bash
claude mcp add --scope <scope> --transport http <name> <url>
```

Then tell the user:
1. Restart Claude Code (`/exit`, then `claude`)
2. If the server requires auth, run `/mcp` inside Claude Code and follow the browser flow

## Procedure: stdio MCP

### On Mac / Linux

Run via Bash:

```bash
claude mcp add --scope <scope> --transport stdio <name> -- npx -y <package>
```

Then tell the user to restart Claude Code.

### On Windows

**Do not use `claude mcp add` for stdio servers on Windows.** A CLI parser bug mangles the `/c` flag (turns it into `C:/`), producing a broken config. Anthropic marked this won't-fix.

Do it yourself by editing `.mcp.json`:

1. Read `.mcp.json` at the project root (create it if missing).
2. Merge in this entry under `mcpServers`, using the `cmd /c` shim:

   ```json
   {
     "mcpServers": {
       "<name>": {
         "command": "cmd",
         "args": ["/c", "npx", "-y", "<package>"]
       }
     }
   }
   ```
3. Save the file. Tell the user to restart Claude Code.

For user-level scope, do the same edit inside `~/.claude.json` under the user's project entry's `mcpServers` field.

#### Why the `cmd /c` wrapper is needed (Windows only)

`npx` on Windows is `npx.cmd` (a batch file). Claude Code's child-process spawn can't run `.cmd` files directly — `cmd /c` wraps it. This is independent of how Claude Code was installed (native installer, WinGet) and whether Git for Windows is present. Git for Windows enables Claude's internal Bash tool but does not affect MCP child-process spawning.

#### Converting an `npx` config from online docs to Windows format

Most online MCP install docs (Playwright, filesystem, Airtable) show the standard `npx` JSON form. Convert before writing to `.mcp.json` on Windows:

1. `"command": "npx"` → `"command": "cmd"`
2. Prepend `"/c"` and `"npx"` to `"args"`

**Example — Playwright:**

What docs show (Mac/Linux form):
```json
{
  "mcpServers": {
    "playwright": {
      "command": "npx",
      "args": ["@playwright/mcp@latest"]
    }
  }
}
```

What you write on Windows:
```json
{
  "mcpServers": {
    "playwright": {
      "command": "cmd",
      "args": ["/c", "npx", "@playwright/mcp@latest"]
    }
  }
}
```

Same recipe applies to other Windows `.cmd`/`.bat` shims: `npm`, `yarn`, `pnpm`, `uvx`. Wrap them with `cmd /c` the same way.

**No conversion needed for:** `node`, `python`, `python3`, `deno`, or any direct path to a `.exe` — those are real executables, not shims.

## Scope: project vs user

| Scope | File | Who can use it |
|-------|------|----------------|
| `--scope project` (default) | `.mcp.json` (project root, checked in) | Everyone on the project |
| `--scope user` | `~/.claude.json` (home folder, NOT `~/.claude/`) | Just this user, all projects |

## Common MCP servers

Templates — substitute `<scope>` with whichever the user picked (`project` or `user`).

| Server | Command |
|--------|---------|
| GitHub | `claude mcp add --scope <scope> --transport http github https://api.githubcopilot.com/mcp/` |
| Notion | `claude mcp add --scope <scope> --transport http notion https://mcp.notion.com/mcp` |
| Sentry | `claude mcp add --scope <scope> --transport http sentry https://mcp.sentry.dev/mcp` |
| Slack | `claude mcp add --scope <scope> --transport http slack https://mcp.slack.com/mcp` |
| Linear | `claude mcp add --scope <scope> --transport http linear https://mcp.linear.app/mcp` |
| Playwright (stdio) | Mac/Linux: `claude mcp add --scope <scope> --transport stdio playwright -- npx -y @playwright/mcp@latest`<br>Windows: hand-edit `.mcp.json` per the Windows procedure above |

Full registry: https://code.claude.com/docs/en/mcp

## Managing MCP servers

| Command | What it does |
|---------|--------------|
| `claude mcp list` | List configured servers |
| `claude mcp get <name>` | Details for one server |
| `claude mcp remove <name>` | Remove a server |
| `/mcp` (inside Claude Code) | Status + interactive auth |

## Helping the user find their config files

If the user asks where their MCP config lives:

- **Project-level (`.mcp.json`)**: project root, same level as `.claude/`. Hidden file. On Mac, press **Cmd + Shift + .** in Finder to reveal hidden files.
- **User-level (`~/.claude.json`)**: home folder directly — NOT inside `~/.claude/`. Also hidden.

## Troubleshooting

### Server doesn't appear after adding
User must restart Claude Code: `/exit` (or Ctrl+C), then `claude`.

### "npx: command not found"
Node.js isn't installed. See Prerequisites.

### "Connection closed" on Windows for a stdio MCP
Config is missing `cmd /c`, or the user previously used `claude mcp add` (which mangles `/c`). Fix by hand-editing `.mcp.json` per the Windows procedure.

### Saw `C:/` instead of `/c` in the config (Windows)
Known CLI parser bug, won't be fixed. Run `claude mcp remove <name>`, then add by hand-editing `.mcp.json`.

### `cmd /c` form still fails on Windows (last resort)
Bypass `npx` entirely: install the MCP package globally with `npm install -g <package>`, then point `command` directly at `node` (or `node.exe`) with the absolute path to the package's CLI JS file. `node.exe` is a real executable, no shim, no `cmd /c` needed. More setup, but reliable.
