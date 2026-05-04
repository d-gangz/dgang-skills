# Creating Hooks

A hook is an automation built into Claude Code's lifecycle. Every hook is two pieces:

- **Trigger** — a lifecycle event (e.g. `SessionStart`, `UserPromptSubmit`, `PreToolUse`, `PostToolUse`, `Stop`)
- **Action** — a shell script that runs when the event fires

The user does **not** write hooks by hand. Your job is to fetch the official docs, interview them, and scaffold a working hook for them.

---

## Workflow

### Step 1 — Fetch and read the official docs (mandatory)

Before you can sensibly interview the user about a hook, you need a working mental model of what hooks are: which lifecycle events exist, how matchers work, the JSON shape of stdin per event, the `hookSpecificOutput` schema, and exit-code semantics. **Read the docs first; only then ask the user questions** — otherwise you will mistranslate their plain English into the wrong event or schema.

**Do not use `WebFetch`** — its small fast model heavily summarizes this page, dropping most of the 28 events, the per-tool input schemas, the exit-code-2 table, and entire sections (defer flow, async hooks, prompt/agent hooks, security, debug). Use `curl` against the `.md` endpoint instead, which returns the raw markdown verbatim, then strip Mintlify JSX with the local cleanup script:

```bash
ROOT=$PWD; while [ "$ROOT" != / ] && [ ! -d "$ROOT/.claude" ]; do ROOT=$(dirname "$ROOT"); done
curl -s https://code.claude.com/docs/en/hooks.md \
  | python3 "$ROOT"/.claude/skills/help/scripts/clean-mintlify-docs.py \
  > /tmp/claude-hooks-docs.md
```

The first line walks up from the current directory until it finds a `.claude/` folder — this resolves the project root without needing git. (Don't substitute `$CLAUDE_PROJECT_DIR` here — that variable is set only during hook execution, not for regular Bash tool calls. It *is* the right choice inside actual hook scripts and `command:` fields; see Step 5.)

Then `Read` `/tmp/claude-hooks-docs.md`. Re-fetch every time you invoke this skill — Claude Code's hook surface evolves and assumptions rot.

After reading, you should know:

- the full list of events and what each fires on
- which events accept matchers, and what the matcher matches (tool name, source type, etc.)
- the stdin JSON shape per event (`session_id`, `transcript_path`, `tool_name`, `tool_input`, etc.)
- the `hookSpecificOutput` shape per event (e.g. `additionalContext` for `SessionStart` / `UserPromptSubmit`, `permissionDecision: "deny"` + `permissionDecisionReason` for `PreToolUse`, top-level `decision: "block"` + `reason` for `Stop` / `PostToolUse` / `UserPromptSubmit`) — the decision pattern differs by event, copy from the docs, don't assume
- exit-code semantics per event

You will refer back to this file in later steps when implementing the specific event the user picks.

If the fetch fails or you hit something the docs don't answer, spawn the `claude-code-guide` subagent for verification before writing.

### Step 2 — Interview the user

Now that you know the event surface, ask **one** question at a time using `AskUserQuestion`. You need three things:

1. **What should fire it?** → maps to a lifecycle event. Translate plain English:
   - "every time I open a session / after `/clear`" → `SessionStart`
   - "right after I send a prompt" → `UserPromptSubmit`
   - "before the agent runs a command/tool" → `PreToolUse`
   - "after the agent edits a file / runs a tool" → `PostToolUse`
   - "when the agent finishes its turn" → `Stop`

2. **What should it do?** → the action. Be concrete. Examples:
   - inject text into the agent's context
   - block a tool call
   - run a formatter on an edited file
   - print a reminder to the user

3. **Should it match a specific tool / file pattern?** (only relevant for `PreToolUse` / `PostToolUse`) — e.g. only fire on `Edit` of `*.md`.

### Step 3 — Plan the output, then write the script

Before writing code, decide what the hook will say. A hook can speak through three channels; pick deliberately for each piece of information and **default to silence.**

**Three channels, three audiences, three purposes:**

| Channel | Audience | Purpose |
|---|---|---|
| `hookSpecificOutput.additionalContext` (or stdout on `SessionStart` / `UserPromptSubmit`) | The agent, on its next model call | **Course correction.** What went wrong and, where possible, how to fix it. Every token costs context — keep it helpful and tight. |
| Top-level `systemMessage` (or stderr on user-routing events: `SessionStart`, `Setup`, `Notification`, `SubagentStart`, `SessionEnd`, `CwdChanged`, `FileChanged`, `PostCompact`) | The user watching the session | **Situational awareness.** Counts, blocked actions, completion summaries — what the user should glance at. |
| Exit `2`, `decision: "block"`, or `permissionDecision: "deny"` | Claude Code itself | **Stop the action.** Reserved for hooks that explicitly mean to deny. |

**Default to silence.** If the check passed and there's nothing actionable, exit `0` with no output. A hook that prints `"ran OK"` on every fire wastes user attention and agent context for no payoff.

**Agent context = course correction, not status reports.** What the agent reads should be what it needs to *do something different*:

- ✅ `"3 lint errors in src/auth.ts (lines 14, 22, 31). Run bun lint --fix to auto-correct."` — error + fix suggestion, actionable.
- ❌ `"Lint hook ran successfully."` — nothing to act on; should have been silent.
- ❌ Full file dumps — the agent can re-read on demand; don't burn tokens.

**User output = progress updates.** Counts, summaries, alerts the user can glance at:

- ✅ `"3 lint errors detected"`, `"Tests passed in 4.2s"`, `"Blocked: rm -rf on protected path"`.
- ❌ Stack traces, internal jargon, verbose logs — the agent handles those.

**Phrase agent context as facts**, not commands. *"Tests are failing in auth.ts"* lands; *"Tell Claude to fix the tests"* trips Claude's prompt-injection defenses and gets surfaced to the user instead of treated as context.

**Don't double up.** If a hook injects an error into the agent's context *and* echoes the same line to `systemMessage`, one is wasted. Pick the audience that needs to act.

**Cap:** `additionalContext` is hard-capped at 10,000 chars; over that, the agent only sees a preview — another reason to stay tight.

#### Now write the script

Hook scripts live in **`.claude/hooks/`** at the project root. Name them:

```
.claude/hooks/<purpose>-<event>.sh
```

Existing project examples — read both before drafting:

- `.claude/hooks/md-review-stop.sh` — Stop hook that blocks if markdown was edited
- `.claude/hooks/session_id.sh` — SessionStart hook that injects the session ID

**Project conventions:**

- `#!/bin/bash` and a short comment block explaining **WHY** the hook exists.
- Read stdin once: `INPUT=$(cat)` or `jq -r '.field' <&0`.
- Parse with `jq` — never regex JSON.
- Emit output as JSON with `jq -n --arg ...`. Never `echo` raw JSON with interpolated variables — quotes/newlines in the variable break the output.
- Exit `0` for pass-through. Prefer structured `hookSpecificOutput` JSON over magic exit codes when both work (confirm in the docs).
- For Stop hooks, **always** guard against infinite loops: check `stop_hook_active` from stdin and exit `0` if it's `true`. (See `md-review-stop.sh` lines 17–20.)

### Step 4 — Make it executable

```bash
chmod +x .claude/hooks/<filename>.sh
```

Confirm:

```bash
ls -la .claude/hooks/<filename>.sh   # mode should start with -rwx
```

### Step 5 — Wire it up in `.claude/settings.json`

Hooks are registered under the top-level `"hooks"` key in `.claude/settings.json`. The project already has this key — append to the relevant event array, do **not** overwrite.

The shape (confirm against the docs you just fetched):

```json
{
  "hooks": {
    "<EventName>": [
      {
        "matcher": "<optional, only for PreToolUse/PostToolUse>",
        "hooks": [
          {
            "type": "command",
            "command": "bash \"$CLAUDE_PROJECT_DIR\"/.claude/hooks/<filename>.sh",
            "timeout": 10
          }
        ]
      }
    ]
  }
}
```

Use `"$CLAUDE_PROJECT_DIR"` (with quotes) — this is how the existing hooks in this project resolve the path. Set a `timeout` (seconds) so a stuck hook doesn't hang the session.

For `PreToolUse` / `PostToolUse`, the `matcher` field filters by tool name (e.g. `"Edit"`, `"Bash"`, or a regex). Look up the exact matcher syntax in the docs you fetched.

### Step 6 — Verify the hook yourself before handing off

**Do not tell the user "go test it" until you have verified it works.** Run these checks first; fix anything that fails before moving on.

#### 6a — Static checks

```bash
# Bash syntax check — catches typos without executing the script
bash -n .claude/hooks/<filename>.sh

# Settings JSON is valid — a broken settings.json silently disables ALL hooks
jq . .claude/settings.json > /dev/null && echo OK

# Hook is registered where you expect
jq '.hooks' .claude/settings.json

# Executable bit is set
test -x .claude/hooks/<filename>.sh && echo executable
```

All four must pass before continuing.

#### 6b — Dry-run the script with a synthetic stdin payload

Hooks read JSON from stdin. Construct a payload that matches what Claude Code sends for the chosen event (you got the shape from the docs in Step 1) and pipe it in:

```bash
# Example: SessionStart payload
echo '{"session_id":"test-123","transcript_path":"/tmp/fake.jsonl","cwd":"'"$PWD"'"}' \
  | bash .claude/hooks/<filename>.sh
echo "exit code: $?"
```

```bash
# Example: PreToolUse payload (adjust tool_name / tool_input for the matcher you set)
echo '{"session_id":"test-123","tool_name":"Bash","tool_input":{"command":"ls"}}' \
  | bash .claude/hooks/<filename>.sh
echo "exit code: $?"
```

```bash
# Example: Stop payload — set stop_hook_active=false to exercise the real path,
# then re-run with stop_hook_active=true to confirm the loop guard short-circuits.
echo '{"session_id":"test-123","transcript_path":"/tmp/fake.jsonl","stop_hook_active":false}' \
  | bash .claude/hooks/<filename>.sh
```

Check four things:

1. **Exit code matches intent** — `0` for "pass through", non-zero only when the hook means to block (per the docs).
2. **Stdout is valid JSON when the hook emits structured output** — pipe through `jq .` to confirm: `... | bash <hook> | jq .`. If it errors, the hook will fail at runtime.
3. **The output contains the right keys** — e.g. `hookSpecificOutput.additionalContext` for `SessionStart`/`UserPromptSubmit`, `permissionDecision: "deny"` for `PreToolUse`, top-level `decision` + `reason` for `Stop`. Cross-check against the docs.
4. **Output discipline holds** (per the plan in Step 3) — the no-op path is silent; agent context is concise and actionable; no double-up between agent and user channels.

#### 6c — Edge cases worth dry-running

- **Empty / missing input field** — what does the hook do if `tool_input` or `transcript_path` is empty? Should exit `0`, not crash.
- **Loop guard (Stop hooks only)** — re-run with `"stop_hook_active":true` and confirm exit `0` with no output.
- **Matcher boundary (PreToolUse/PostToolUse)** — pipe in a payload with a tool name that should *not* match and confirm the hook is a no-op.

#### 6d — Then hand off to the user

Once 6a–6c pass, tell the user how to verify it live:

- `SessionStart` → start a new session or run `/clear`; check the system reminder appears.
- `UserPromptSubmit` → submit any prompt; check the injected context.
- `PreToolUse` / `PostToolUse` → trigger the matching tool; check the side effect.
- `Stop` → let the agent finish a turn under conditions that should fire the hook.

If the hook doesn't fire live (despite passing 6a–6c), check:

1. The event name is spelled correctly (case-sensitive)
2. For `PreToolUse`/`PostToolUse`, the `matcher` actually matches the tool name
3. The session was restarted after the settings.json change (some events only re-read on session boot)

---

## Output to the User

After scaffolding, give the user a short summary:

1. **What you created** — file path + event + one-line of what it does
2. **Where you wired it** — the entry added to `.claude/settings.json`
3. **How to test** — one concrete step
4. **How to remove it** — delete the file + remove the settings.json entry

Keep it copy-paste friendly; the audience is non-technical.

---

## Common Pitfalls

- **Forgetting `chmod +x`** — the hook will silently not run. Always do this and verify.
- **Bad JSON in `settings.json`** — breaks all hooks, not just the new one. Validate with `jq . .claude/settings.json`.
- **Stop-hook infinite loop** — must check `stop_hook_active` and short-circuit.
- **Echoing raw JSON** — use `jq -n` to construct output. Variable interpolation into raw JSON breaks on quotes/newlines.
- **Wrong event name** — `SessionStart`, not `session-start` / `sessionStart` / `SessionStarted`. Always copy from the docs.
- **Hardcoding paths** — use `"$CLAUDE_PROJECT_DIR"` so the hook works on any teammate's machine.
- **Long-running actions** — set a `timeout`. A formatter that takes 30s will block the agent's turn.
- **Verbose hooks** — printing on every fire ("hook ran OK", "checked 0 files") is noise. Exit `0` silently when there's nothing useful to say. See Step 3.
- **Confusing the channels** — agent-facing info in `systemMessage` (user sees jargon they can't act on) or user-facing summaries in `additionalContext` (agent gets a status report it doesn't need). Agent context = course correction; `systemMessage` = situational awareness for the user.
- **Imperative `additionalContext`** — phrasing context as system commands ("Tell Claude to use bun") trips prompt-injection defenses. Use factual statements ("This repo uses bun test").

---

## Resources

- **Official hooks reference (always fetch first):** https://code.claude.com/docs/en/hooks.md (raw markdown endpoint — fetch via `curl`, not `WebFetch`)
- **Cleanup script:** `.claude/skills/help/scripts/clean-mintlify-docs.py` — strips Mintlify JSX (`<Tip>`, `<Note>`, `<Warning>`, `<Frame>`, `<Steps>`, `<Tabs>`, `theme={null}`) from the raw markdown
- **Existing project examples:** `.claude/hooks/md-review-stop.sh`, `.claude/hooks/session_id.sh`
- **Existing settings.json:** `.claude/settings.json` — see the `"hooks"` block for the registration pattern
- **Fallback for uncertainty:** spawn the `claude-code-guide` subagent
