---
name: handoff
description: Hand a piece of work off to a separate user-visible session, and hand results back. Invoke to spin off a side session, or to return to the session that spawned you.
argument-hint: "The work to hand off, or 'back' to return results to the origin"
disable-model-invocation: true
---

Pass the baton for a unit of work between two user-visible sessions, so each session's context stays focused on its own job. A side session takes on delegated work without bloating the origin's context; when it finishes, results flow back. For the return trip to land, whoever hands off must leave an address the other session can find — the mechanics below hinge on this.

## Two directions

**Send off** — delegate to a *new* side session:
1. Compose the brief (below).
2. Spin off the side session and pass it the brief, using your harness mechanics. Open it in the **same project as the origin** by default; target a different project only when the user asks for one.

**Hand back** — return results to the session that spawned you:
1. Compose the brief (below), covering what you did and what you produced.
2. Resolve the origin session and deliver the brief to it, using your harness mechanics.

## The brief

Carry the brief **inline** in the spin-off / hand-back message, written so the receiving session can continue with no other context. If the user passed arguments, treat them as a description of what the receiving session should focus on and tailor the brief accordingly.

- Summarise the work: goal, what's done, what's left, key decisions.
- Include a **suggested skills** section naming skills the receiving session should invoke.
- Reference existing artifacts (specs, plans, ADRs, issues, commits, diffs) by path or URL — do not restate their content.
- Redact secrets and PII (API keys, passwords, personal data).
- On a **send off**, include the origin's return address so the side session can hand back (see harness mechanics).

Only when the context is too large to carry inline, write it to the OS temp directory (not the workspace) and include the file path as a pointer in the message.

## Harness mechanics

Spin-off and addressing differ by harness. Read the file for the one you are running in:

- Claude Code → `references/claude-code.md`
- Codex → `references/codex.md`
