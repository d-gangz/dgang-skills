---
name: grill-me
description: >
  Interview the user relentlessly about a plan, design, or idea until reaching
  shared understanding. Use when they want to stress-test a plan, get grilled
  on a design, or say "grill me".
---

# Grill Me

Interview the user relentlessly about the thing they want to work on, walking the decision tree one branch at a time. The steps below are the mechanics; the goal is shared understanding — you and the user aligned on what to do and why. Keep the interview sharp and adaptive: pull moves as the conversation needs them, don't march the list.

## How to grill

1. **Ground first.** Spawn sub-agents in parallel to read the relevant codebase and anything the user attached or referenced — files, URLs, tickets, docs. Skip only if the subject is genuinely context-free.
2. **Start at the root.** Open with the decision that gates the most others. Ask if the subject itself is unclear.
3. **One question at a time, always with a recommended answer.** End on a single ask — don't bolt a second question on with "and" or a dash; that's the next turn's, not a tail on this one. An either/or that rephrases the same question is fine. Choice-shaped decisions get numbered options; open or reframing ones get just the recommendation and why. Lay it out per **Question shape**.
4. **Explore instead of asking** when the answer lives in code, config, git history, or the attached resources. Only ask for judgment, preference, or knowledge you can't derive.
5. **Follow dependencies.** Resolve decisions in dependency order — each answer constrains the next, so settle the gating one before the choices that hang off it. Don't wander to siblings until the current branch is resolved.
6. **Don't stop early.** Keep going until every decision has an answer, the user ends it, or what's left is pure implementation detail. Then summarize the decisions made.

## Question shape

Make it answerable at a glance: lead with the question, then the options — each option's detail rides in the option, not a preamble before the list.

**Q1 — the question, one line.**

1. **Short label** — its description: what it means, the trade-off, whatever context it needs. As long as it needs to be, never padded.
2. **Short label** — its description.

Recommend: **N** — why, sized to the decision.

State the question once, up top — don't restate it after the options. Any framing goes above the question, and only when it's a real Socratic move (a reframe, a surfaced assumption, a consequence) — never to narrate the method ("now we walk the tree in dependency order"). Keep framing to a sentence or two — surface what the user doesn't know that changes the answer; don't teach a framework or restate what the options already say.

## Socratic moves

Layer these on to make sure the answer being accepted is actually load-bearing:

- **Surface assumptions before walking the tree.** Probe whether the root is framed correctly and the stated goal is the real goal — a tree rooted in the wrong place wastes the whole interview.
- **Press for definitions.** Don't accept "fast", "scalable", "simple", "clean", "good UX" — force a concrete version (numbers, examples, observable outcomes) and propose a sharp one.
- **Test consequences.** Trace each answer's downstream implications and confirm the user wants them: "If X, then Y and Z follow — OK with that?"
- **Check for contradictions.** Watch for answers that conflict with earlier ones; name both and ask which wins.
- **Probe with counterexamples.** Stress-test a tentative decision with one edge case before locking it in. If it breaks down, revisit before moving down the branch.
