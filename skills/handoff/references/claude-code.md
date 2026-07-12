# Handoff mechanics — Claude Code

Cross-session handoff runs on the CCD session tools. Concrete tool names (this is the Claude-Code-specific branch):

- `spawn_task` — CCD session server; spins off a new user-visible session via a chip.
- `search_session_transcripts` — CCD session-management server; full-text search across *other* sessions' transcripts.
- `send_message` — CCD session-management server; delivers a message to another session.
- `get_session` / `list_sessions` — CCD session-management server; look up other sessions' metadata.

## Two IDs, and why it matters

Every session has two identifiers:

- **Runtime ID** — the bare `sessionId` a session sees in its own SessionStart hook context. A session knows *its own* runtime ID.
- **Messaging ID** — a `local_…` ID that `send_message`, `get_session`, etc. use to address a session. A session **cannot see its own** messaging ID.

There is **no tool that returns your own messaging ID** — do not go looking for one. `get_session`, `send_message`, `list_sessions`, and `search_session_transcripts` all reject or exclude the current session (only `archive_session` accepts a `"self"` sentinel, and it returns nothing usable here).

So you can never announce your own address directly. Instead you plant a **breadcrumb**: state your runtime ID in a normal chat message. Once it's in your transcript, another session runs `search_session_transcripts` on it and gets back your `local_…` messaging ID. The hook context alone may not be searchable — say it in a message to be safe.

## Send off — spin up a side session

1. **Plant your breadcrumb.** State your own runtime ID (from your SessionStart hook) in a chat message, and record it in the brief as the return address — together with your session **title and cwd** (used to disambiguate on hand back).
2. **Spawn the side session** with `spawn_task`, passing the brief as its `prompt` (plus a `title` and `tldr`). This surfaces a suggested-task chip; the user clicks "Start locally" to birth the session. Start type is **local by default** — the session runs in-place in the target folder, no worktree. (The tool's return text mentions a "worktree"; ignore it — that's the non-default option.)
3. **Project folder.** Omit `cwd` and the side session opens in the **same project as the origin** (the tool's own default). To place it in a different project, pass `cwd` as that project's **absolute path** (e.g. `/Users/gang/gang-personal/kbos`) — not a project name or ID.
4. `spawn_task` returns a **task id, not a session id** — you get no handle to the child. To find it later, run `search_session_transcripts` on a distinctive phrase from the brief.

## Hand back — return to the origin

1. **Read the origin's runtime ID** from your brief — it was planted there when you were spawned.
2. **Resolve its messaging ID:** run `search_session_transcripts` on that runtime ID. If more than one session matches — which happens when the origin also spun up **sibling** side sessions, since every child's brief quotes the origin's runtime ID — pick the hit whose **title and cwd** match the origin's (recorded in your brief). That hit's `local_…` ID is the origin's messaging ID.
3. **Deliver the brief:** `send_message` it to that `local_…` ID. The user confirms before it lands, and it arrives in the origin as a user turn linking back to you.
