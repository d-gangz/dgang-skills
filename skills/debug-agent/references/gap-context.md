# Gap: Execution — Context

## Definition

*The agent knew what to do, but lost the thread while doing it.*

The brief was solid; the agent's working memory got messy. Context rot creeps in slowly — symptoms look like reasoning failures, but the cause is the environment.

## Symptoms

- Agent contradicted an instruction from earlier in the session
- Agent repeated work it had already done
- `/context` shows past the smart zone for the *task type* (see below)
- Status line was high before output quality cliffed
- Agent slipped back to default behavior on a constraint stated earlier

## Smart zones by task type

The smart zone isn't a single number — it depends on what the agent is doing. Calibrate the diagnosis to the task type:

| Task type | Smart zone | Notes |
|-----------|------------|-------|
| **Brainstorming / research** (exploring options, reading widely, synthesizing) | up to ~300–400K | More forgiving — attention can spread across more material without quality cliffing |
| **Execution / reasoning-heavy** (writing the doc, producing the artifact, multi-step workflow) | ~100–120K | Tightest constraint — past this, output quality cliffs |

When diagnosing, ask: *what was the agent doing when output went off?* If it was producing the artifact or executing a workflow, the 100–120K threshold is the relevant one. If it was reading widely and synthesizing, the higher threshold applies.

## Headline rule

**Reset the thread, then re-prompt with what was missing.**

## Fix type: User-side only

Context gaps are operator-habit failures: the user kept piling work into a session past the smart zone. There's nothing on disk to revise. The fix is *training the user to manage sessions better* — delivered as **tips for next time**.

## Part A — Tips for the next task

When generating tips, anchor each one to *what specifically rotted in this session*. Examples to draw from:

- *"At [specific point in session], `/context` was already at [%]. That was the moment to reset, not push through. Next time, glance at the status line every few turns and reset before output cliffs — not after."*
- *"You re-prompted [N] times after the agent went off-track. Faster move: double-tap Esc to rewind to before the wrong turn, then re-prompt with what was missing. Piling more context onto a broken thread makes it worse."*
- *"For long multi-step tasks like this one, externalize the plan with **TaskCreate** so each step survives even when intermediate output gets long. The plan becomes durable; the session can rot without losing the thread."*
- *"For the verification step that produced [N] file reads, spin up a sub-agent. Only the result returns to the parent — intermediate noise stays out of your window."*
- *"Pick the lightest reset that gets you past rot: rewind (drop bad turns) → `/compact <hint>` (summarize, steer with a hint) → `/clear` (fresh start with a handoff message you write)."*

## Part B — Fix proposal

**Not applicable.** No file on disk to revise.

If the user is *consistently* hitting Context gaps in workflows that run a specific skill (e.g., a skill that always reads 30 files inline instead of delegating to a sub-agent), reclassify as **Tooling** — the skill body itself is the gap.

## When to re-diagnose

After the user attempts the next task with session-management tips applied. If the same Context symptoms recur, look for whether a skill is the underlying cause (Tooling) — or whether the user is taking on tasks too big for any single session and needs multi-phase execution.
