# Gap: Understanding

## Definition

*You haven't yet decided what you actually want.*

Understanding gaps spread to everything downstream — fuzzy understanding makes a fuzzy brief, which makes wrong output. The cheapest gap to prevent and the most expensive to catch late.

## Symptoms

- User couldn't describe the deliverable in one sentence
- User hand-waved on a key decision ("we'll figure that out later")
- User reached for vague terms — "cleaner", "feels right", "more polished" — without defining them
- **The masquerade signal:** brief has been revised 3+ times and output is still off
- Output looks plausible but solves a slightly different problem than the user actually wanted

## Headline rule

**Prevent, don't diagnose.** The cheapest fix is the one you do upfront — before handing off to the agent.

## Fix type: User-side only

Understanding gaps live in the user's head, not in any file. There's nothing on disk for an agent to revise. The fix is *training the user to notice the gap before handing off* — so it's delivered as **tips for the next task**, not a system change.

## Part A — Tips for the next task

When generating tips, anchor each one to *what specifically went fuzzy in this session*. Don't deliver generic boilerplate. Examples to draw from:

- *"Before kicking off the next task, run `/grill-me`. In this session, the deliverable shifted between '[X]' and '[Y]' twice — that's a sign there's a decision you haven't actually made yet."*
- *"Apply the one-sentence test before briefing: 'I want X to do Y for Z.' This session got stuck because the user said '[vague term]' without nailing down [the specific axis]."*
- *"Stop revising the brief. You revised it [N] times and the output is still off — that's the masquerade rule firing. The next attempt should start with `/grill-me`, not another brief edit."*
- *"Write down the assumption that changed before re-attempting. The mental shift from '[A]' to '[B]' is the load-bearing fix; the brief change is downstream."*

## Part B — Fix proposal

**Not applicable.** No file on disk to revise.

If the diagnosis surfaces an Understanding gap that *also* corresponds to under-specified context in a recurring skill (e.g., the user kept fuzzy-briefing because the skill they reach for never asks the right clarifying questions), reclassify as **Tooling** and use that reference instead.

## When to re-diagnose

After the user attempts the next task with the tips applied. If output is *still* off, run `/debug-agent` again in that new session — the upstream gap may have been deeper than this round identified, or a different gap is now upstream.
