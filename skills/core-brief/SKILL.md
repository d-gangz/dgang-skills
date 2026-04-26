---
name: core-brief
description: >
  Shape conversation context (or a fresh task description) into a 5-part brief —
  Context / Task / Constraints / Verification / Output format — ready to hand off
  to an agent. Use when the user is ready to execute a task and wants it
  structured first. Composes naturally with /core-grill-me upstream, but works
  standalone too. Triggers: "/core-brief", "draft a brief", "shape this into a
  brief", "turn this into a task spec", "write a brief for this".
---

# Brief

Turn conversation context into an executable 5-part brief.

The user has thought enough about a task — through `/core-grill-me`, free-form
conversation, or just typing a request — and is ready to hand it off.
`/core-brief` produces the structured handoff.

## Workflow

1. **Read the conversation.** Pull every signal about the task from the recent
   conversation, including any `/core-grill-me` recap. If `$ARGUMENTS` was
   provided (e.g., `/core-brief I want to draft a follow-up email...`), treat
   that as additional task input on top of the conversation.

2. **Fill what you can.** Map signals to the 5 slots in the template below.
   Quote the user's own words where possible — don't paraphrase intent the
   user didn't express.

3. **Identify weak slots.** A slot is weak if it's empty, vague, or relies on
   guessing the user's intent. The most commonly weak slots:
   - **Verification** — users rarely think in stopping conditions
   - **Constraints** — often unstated must-dos / must-not-dos
   - **Output format** — sometimes the user genuinely doesn't care

4. **Ask one focused question per weak slot.** Use `AskUserQuestion`. Each
   question must propose a recommended answer the user can accept with one
   tap. Skip the question entirely if you can derive a strong answer from
   the conversation.

5. **Respect "I don't have anything."** If the user passes on a slot, record
   that as the slot value (e.g., "agent picks" for Output format) — don't
   force content. Absence is a real signal to the downstream agent.

6. **Output the brief in a single markdown code block** so the user can copy
   it cleanly. Use the template below, replacing each bracketed placeholder
   with the user's content.

7. **Suggest the next step in one line.** "Hand this to a fresh Claude session
   for cleanest execution, or paste it back here to run it now."

## Output template

````markdown
## Brief: [one-line task title]

**Context**
[Background the agent needs: situation, goal, audience, files/URLs/docs to consult.]

**Task**
[What you want done. A clear sentence for simple work; a paragraph or sub-bullets when the task needs detail to be accomplishable.]

**Constraints**
[Rules, must-dos, must-not-dos. Bullet list.]

**Verification — don't finish until:**
[Stopping conditions that tell the agent it's done. Bullet list.]

**Output format**
[Shape of the deliverable, or "agent picks" if the user passed.]
````

## Anti-patterns

- **Shipping `[TODO]` placeholders.** If a slot is weak, ask. If the user
  passes, record their pass — don't leave a placeholder.
- **Paraphrasing intent.** If the user said "be brief," don't translate to
  "concise and impactful." Keep their words.
- **Over-asking.** If a slot is reasonably derivable from context, fill it.
  Save questions for what's genuinely missing.
- **Bloating the brief.** Keep each slot as tight as the work demands. Task
  can grow when accomplishing the work needs detail, but don't pad it with
  rules (those go in Constraints) or shape (Output format). The brief is a
  handoff artifact, not documentation.
- **Forgetting Verification.** This is the slot users most often skip and the
  one that most affects output quality. Always raise it, even if just to
  confirm the user has nothing specific.
