# Handoff mechanics — Codex

Cross-session handoff in Codex uses two tools and one identifier (the thread ID):

- `create_thread` — creates a new user-visible task (sidebar task). Input `{ prompt, target }`. Returns the new task's thread ID.
- `send_message_to_thread` — delivers a message to an existing task. Min input `{ threadId, prompt }`; optional overrides for host, model, and reasoning level. Returns the target thread ID. The target must be accessible in your Codex environment — you cannot message another user's private tasks.

`spawn_agent` creates an *internal* sub-agent for parallel work, **not** a user-visible sidebar task — do not use it for handoff.

## One ID, directly visible

A Codex session is identified by its **thread ID**, surfaced in its own SessionStart hook context. Unlike Claude Code, there is no separate messaging ID and no "can't see your own address" problem: the thread ID is both identity and address, and a session can read its own. So there is no breadcrumb step — a session states its own thread ID directly.

## Send off — spin up a side session

Call `create_thread`, passing the brief as `prompt` and a `target`. Include the origin's own thread ID in the brief as the return address. `create_thread` returns the new task's thread ID directly, so — unlike Claude Code's chip flow — you get an immediate handle to the child.

**Choosing the target.** `create_thread` requires an explicit `target` — there is *no* implicit "same project" default; same-project is *this skill's* policy, not a `create_thread` behaviour, so you set the target every time. Resolve the project with `list_projects` and pass the **`projectId` it returns**:

```
{ "type": "project", "projectId": "<projectId from list_projects>", "environment": { "type": "local" } }
```

- **Same project as the origin** (the default): call `list_projects`, match the origin task's workspace path, and use that project's returned `projectId`. You don't need the user to supply it.
- **A different project** (only when the user asks): match the target project in `list_projects` and use its `projectId`.
- **No project:** `{ "type": "projectless" }`.
- For an isolated checkout instead of working in place, use `"environment": { "type": "worktree" }`.

Project IDs are opaque — do not hardcode one. For local projects the ID is often the workspace path (e.g. `/Users/gang/gang-personal/kbos`), but that need not hold, especially for remote projects, so always use the value `list_projects` returns.

## Hand back — return to the origin

1. Read the origin's **thread ID** from your brief.
2. Call `send_message_to_thread` with `{ threadId: <origin thread id>, prompt: <brief> }`. It arrives in the origin task as a new turn.
