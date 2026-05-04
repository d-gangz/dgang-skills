# Gap: Specification

## Definition

*You knew what you wanted; the brief didn't capture all of it.*

The cruel part: the agent did exactly what you asked. The output looks competent — it checks every box you wrote. The boxes you forgot to write are the gap.

## Symptoms

- Output addresses the literal request but skips a constraint you'd have stated if asked
- One of the 5 brief slots was empty: **Context / Task / Constraints / Verification / Output format**
- No stopping condition was specified — agent declared done at the first plausible artifact
- Agent followed the brief faithfully, but the result still isn't what you wanted

## Headline rule

**Walk the 5 brief slots; find the empty one.**

## The 5 brief slots

Use these as the audit checklist when comparing the user's prompt against what the agent actually needed:

- **Context** — background the agent needs to interpret the task: who it's for, what's already happened, where the artifacts live, what the user has already tried.
- **Task** — the deliverable in one sentence. What is the agent producing? A doc, a code change, a decision, a plan?
- **Constraints** — non-negotiables that bound the solution: must-haves, must-not-haves, tone, length, libraries to use/avoid, sources to cite.
- **Verification** — the stopping condition. How will the agent know it's done? What check must pass before it declares completion?
- **Output format** — the shape the result should take: file path, structure, headings, code block vs prose, where to write it.

A brief is "complete" when each slot has at least one concrete sentence. An empty slot is the most common Specification gap — and the audit is just walking the five and pointing at the blank.

## Fix type: User-side only

If the under-specified prompt was an *ad-hoc user prompt* (typed into the session), the fix is training the user to write better briefs next time — there's no file on disk to revise. **Reclassify as Tooling** if the under-specification came from a *skill body* (the skill itself failed to capture the constraint) — that's an agent-side fix.

## Part A — Tips for the next task

When generating tips, anchor each one to *which slot was empty in this session* and *what the missing constraint was*. Examples to draw from:

- *"The Verification slot was empty — your brief never said how the agent would know it was done. Next time, add a stopping condition: 'don't finish until [specific check].' For this session it would have been '[concrete example].'"*
- *"The Constraints slot was thin — you didn't write down '[specific rule]' but you'd have stated it if asked. Next brief: walk all 5 slots before sending."*
- *"For tasks like this, run `/grill-me` first to surface the constraints you haven't articulated, then `/create-brief` to structure them. The brief that produced the bad output had [N] empty slots — `/grill-me` would have caught them."*
- *"Rewrite the brief now (offline) with the missing slot filled. Save it somewhere you can paste into the next session."*

## Part B — Fix proposal

**Not applicable** when the under-specified artifact is a one-off user prompt.

If the diagnosis traces back to a skill body that's missing the constraint (e.g., `/meeting-prep` doesn't mention citation requirements), reclassify as **Tooling** and use that reference's fix proposal template — the fix is `/skill-master` revising the skill (applied by MAIN), not the user writing better one-off briefs.

## When to re-diagnose

After the user attempts the next task with a complete brief. If output is *still* off after a clean 5-slot brief, check whether you've now revised 3+ times — that's the masquerade signal to climb back to Understanding.
