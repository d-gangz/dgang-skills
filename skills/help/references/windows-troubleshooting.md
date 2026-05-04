# Windows Troubleshooting (for Claude)

This reference helps you (the agent) diagnose and fix Windows-specific Claude Code problems for the user. **Diagnose via Bash before suggesting anything**, then do the fixes yourself where possible. Only hand off when the action genuinely requires the user.

## What you can do vs. what the user does

| Action | Who |
|---|---|
| Detect platform (`uname`) | You |
| Check `where.exe claude`, `Test-Path ...`, env vars | You via Bash |
| Set User-level env vars via PowerShell | You via Bash, with the **UAC/hang caveat** |
| Install via `winget` | You via Bash, with the **UAC/hang caveat** |
| Edit `settings.json` to add `CLAUDE_CODE_GIT_BASH_PATH` | You via Edit |
| Restart the terminal after env / PATH changes | **User** |
| Accept UAC dialogs | **User** |
| Run PowerShell as Administrator | **User** |
| Press **Alt+V** to paste images (instead of Ctrl+V) | **User** |
| Switch out of "Windows PowerShell (x86)" to 64-bit PowerShell | **User** |

**The UAC/hang caveat:** PowerShell-via-Bash works for non-elevated commands. If a command triggers a UAC prompt or password prompt, it'll hang Bash with no output. Warn the user before running anything risky; if it does hang, hand the command to them and have them run it directly.

## Diagnose first

When the user reports a Windows issue, run these via Bash before proposing a fix:

```bash
uname                                  # confirms OS — Windows reports MINGW*/MSYS*
```

```powershell
# Inside Claude Code Bash on Windows you can pipe to powershell.exe -Command
where.exe claude                       # is claude on PATH? where?
Test-Path "$env:USERPROFILE\.local\bin\claude.exe"   # did installer place the binary?
$env:PATH -split ';' | Select-String '\.local\\bin'  # is install dir on PATH?
[Environment]::GetEnvironmentVariable('CLAUDE_CODE_GIT_BASH_PATH','User')  # git-bash override
[Environment]::Is64BitOperatingSystem  # rules out x86 PowerShell mistake
```

Also check the user's settings.json for the env var alternative:

```bash
jq '.env' ~/.claude/settings.json 2>/dev/null
jq '.env' .claude/settings.json 2>/dev/null
```

Match the symptom to the relevant section below and act.

## Symptom map

| What the user sees | Section |
|---|---|
| `'claude' is not recognized` / `command not found: claude` | [PATH](#claude-not-on-path) |
| `Claude Code on Windows requires either Git for Windows (for bash) or PowerShell` | [Shell tool missing](#shell-tool-missing) |
| `Claude Code does not support 32-bit Windows` (on a 64-bit machine) | [Wrong PowerShell entry](#wrong-powershell-entry-x86) |
| MCP server fails with "Connection closed" / "npx not found" | [Windows MCP — see mcp-setup.md](#mcp-issues) |
| `irm is not recognized` / `&& is not valid` / `bash is not recognized` | [Wrong shell for install command](#wrong-shell-for-install-command) |
| `The process cannot access the file ... being used by another process` (during install) | [Install file lock](#install-file-lock) |
| Image paste does nothing | [Image paste](#image-paste) |
| `Killed` (during install on Linux/WSL) | Not Windows-specific; see `https://code.claude.com/docs/en/troubleshoot-install` |

For anything not listed, fetch the live troubleshooting docs and search there:

```bash
ROOT=$PWD; while [ "$ROOT" != / ] && [ ! -d "$ROOT/.claude" ]; do ROOT=$(dirname "$ROOT"); done
curl -s https://code.claude.com/docs/en/troubleshoot-install.md \
  | python3 "$ROOT"/.claude/skills/help/scripts/clean-mintlify-docs.py \
  > /tmp/claude-troubleshoot.md
```

Then `Read` `/tmp/claude-troubleshoot.md`.

---

## `claude` not on PATH

**Symptom:** `'claude' is not recognized as an internal or external command` (CMD) or `The term 'claude' is not recognized as the name of a cmdlet` (PowerShell).

**Diagnose:**

```bash
powershell.exe -Command "Test-Path \"$env:USERPROFILE\.local\bin\claude.exe\""
```

- `True` → binary exists, PATH issue. Continue to fix.
- `False` → installer never placed it. Have the user re-run the install command from `https://code.claude.com/docs/en/overview`.

**Fix (you can do this via Bash):**

```bash
powershell.exe -Command "
\$current = [Environment]::GetEnvironmentVariable('PATH', 'User');
[Environment]::SetEnvironmentVariable('PATH', \"\$current;\$env:USERPROFILE\.local\bin\", 'User')
"
```

**Then tell the user:** close and reopen the terminal (PATH changes don't apply to running shells). After restart, `claude --version` should work.

---

## Shell tool missing

**Symptom:** `Claude Code on Windows requires either Git for Windows (for bash) or PowerShell` at startup.

Claude Code uses the Bash tool when Git for Windows is installed; otherwise it falls back to PowerShell. This error means it found neither. Most native Windows users only need Git for Windows if they want Bash semantics.

**Fix path A — let it use PowerShell (no install needed):** PowerShell ships with Windows. If they're seeing this error, PowerShell may not be on PATH. Have them open the **Windows PowerShell** Start menu entry directly (not from the broken terminal) and try `claude` from there. If it works, the issue is the terminal they were using.

**Fix path B — install Git for Windows (if they want Bash):**

You can install via Bash:

```bash
powershell.exe -Command "winget install Git.Git --source winget"
```

(May trigger UAC; warn user.) After install, close and reopen the terminal.

**Fix path C — Git is installed but Claude Code can't find it:** set `CLAUDE_CODE_GIT_BASH_PATH` in settings.json. You do this via Edit:

```json
{
  "env": {
    "CLAUDE_CODE_GIT_BASH_PATH": "C:\\Program Files\\Git\\bin\\bash.exe"
  }
}
```

Confirm scope first (`AskUserQuestion`):
- User-level → `~/.claude/settings.json` (applies in every project)
- Project-level → `.claude/settings.json` (committed)

If their Git is somewhere else, find it via Bash:

```bash
powershell.exe -Command "where.exe git"
```

The Git Bash path is `<install-dir>\bin\bash.exe`.

---

## Wrong PowerShell entry (x86)

**Symptom:** `Claude Code does not support 32-bit Windows` on a 64-bit machine.

Windows ships two PowerShell Start menu entries: `Windows PowerShell` (64-bit) and `Windows PowerShell (x86)` (32-bit). The x86 one runs as a 32-bit process and triggers this error even on 64-bit Windows.

**Confirm via Bash:**

```bash
powershell.exe -Command "[Environment]::Is64BitOperatingSystem"
```

- `True` → tell the user to close the current PowerShell window, open **Windows PowerShell** (without the x86 suffix) from the Start menu, and rerun `claude`.
- `False` → they're actually on 32-bit Windows. Claude Code requires 64-bit; no workaround.

---

## Wrong shell for install command

**Symptoms (during the install command itself):**

| Error | What it means | Fix |
|---|---|---|
| `'irm' is not recognized` | They ran the PowerShell command in CMD | Switch to PowerShell, or use the CMD installer below |
| `The token '&&' is not valid` | They ran the CMD command in PowerShell | Use the PowerShell installer below |
| `'bash' is not recognized` | They ran the macOS/Linux command on Windows | Use a Windows installer below |

**PowerShell installer (give the user this):**

```powershell
irm https://claude.ai/install.ps1 | iex
```

**CMD installer:**

```batch
curl -fsSL https://claude.ai/install.cmd -o install.cmd && install.cmd && del install.cmd
```

**WinGet (alternative, no curl needed):**

```powershell
winget install Anthropic.ClaudeCode
```

You can offer to run the WinGet command via Bash, with the UAC caveat.

---

## Install file lock

**Symptom:** `Failed to download binary: The process cannot access the file ... because it is being used by another process` during the PowerShell install.

Usually a previous install attempt is still running, or antivirus is scanning a partial download in `%USERPROFILE%\.claude\downloads`.

**Fix (you can do via Bash):**

```bash
powershell.exe -Command "Remove-Item -Recurse -Force \"\$env:USERPROFILE\.claude\downloads\""
```

Then have the user rerun the installer.

If the user has multiple PowerShell windows running the installer concurrently, ask them to close the others first.

---

## MCP issues

Windows MCP setup (especially the `cmd /c` shim for `npx`-based stdio servers) is fully covered in `mcp-setup.md`. Don't duplicate it here. Read that file when handling MCP issues on Windows.

The two highlights worth remembering:

- **HTTP MCPs (Notion, GitHub, Sentry, Linear, Slack)** work the same on Windows as Mac/Linux — no Windows-specific handling needed.
- **stdio MCPs (Playwright, filesystem, etc.)** need the `cmd /c` wrapper on Windows because `npx` is a `.cmd` shim. **Don't use `claude mcp add` for stdio on Windows** — there's a parser bug. Hand-edit `.mcp.json` per `mcp-setup.md`.

---

## Image paste

**Symptom:** Ctrl+V doesn't paste images into Claude Code on Windows.

Windows terminals only support **text** paste with Ctrl+V. This is a Windows terminal architecture limitation, not a Claude Code bug. No fix on your end.

**Tell the user:**
- Use **Alt+V** to paste images, or
- Drag-and-drop the image file onto the Claude Code window

---

## Final hand-off checklist

Before declaring a Windows issue fixed:

1. The user has restarted their terminal (most fixes need this).
2. `claude --version` works in the new terminal.
3. If you set `CLAUDE_CODE_GIT_BASH_PATH` or installed Git for Windows, `claude` starts cleanly without the shell-missing error.
4. For MCP fixes, the user has restarted Claude Code (`/exit`, then `claude`).

## Resources

- **Live troubleshooting docs (always fetch fresh):** https://code.claude.com/docs/en/troubleshoot-install.md
- **Install configurator:** https://code.claude.com/docs/en/overview
- **MCP on Windows:** see `mcp-setup.md` in this skill
