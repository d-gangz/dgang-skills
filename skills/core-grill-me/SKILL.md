---
name: core-grill-me
description: Interview the user relentlessly about whatever they want to work on — a plan, task, design, idea, feature, architecture decision, or anything else — until reaching shared understanding. Walk the decision tree one branch at a time, resolving dependencies between decisions. Use when the user says "grill me", wants to stress-test a plan or idea, wants to be interviewed about a design, or wants to flesh out an under-specified task.
---

# Grill Me

Interview the user relentlessly about the thing they want to work on. Walk the decision tree one branch at a time, resolving dependencies between decisions.

## How to grill

1. **Identify the subject.** Take whatever the user described — plan, task, design, idea, architecture decision, feature, process — as the root. Ask if unclear.

2. **Ground via sub-agents before the first question.** Spawn `Agent` (typically `Explore` or `general-purpose`) in parallel to read the relevant codebase *and* anything the user attached or referenced — files, URLs, tickets, docs, screenshots. Delegate the reading; don't burn your own context. Skip only if the subject is genuinely context-free.

3. **Map the tree mentally.** Using what the sub-agents returned, find the decision that gates the most other decisions. Start there.

4. **Ask one question at a time** using `AskUserQuestion`. Never batch.

5. **Always propose a recommended answer** with each question, plus a one-line reason. The user should be able to accept with one tap or push back.

6. **Explore instead of asking when you can.** If a question is answerable from code, config, git history, attached files, or linked tickets — spawn a sub-agent to find the answer. Only ask the user for judgment, preference, or knowledge you can't derive.

7. **Follow dependencies.** Each answer unlocks the next most load-bearing question on the current branch. Don't wander to siblings until the current branch is resolved.

8. **Keep going until the tree is resolved.** Stop only when every decision has an answer, the user ends the session, or what's left is pure implementation detail.

9. **Summarize at the end.** Produce a concise recap of the decisions made.

## Socratic moves

Layer these on top of the tree-walk to sharpen each exchange. They don't replace the recommendation-first format — they make sure the answer being recommended (and accepted) is actually load-bearing. Deploy them between tree-walk steps as the situation calls for them, not as a fixed checklist.

- **Press for definitions.** When the user uses fuzzy terms — "fast", "scalable", "simple", "clean", "user-friendly", "good UX" — don't accept them as answers. Force a concrete definition (numbers, examples, observable outcomes) and propose a sharp version they can accept with one tap.
- **Surface assumptions before mapping.** Before walking the tree, probe the load-bearing assumptions behind the root itself. Is the problem framed correctly? Is the stated goal the real goal? A tree rooted in the wrong place wastes the whole interview.
- **Test consequences.** After each answer, briefly trace its downstream implications and check the user actually wants them. "If we go with X, then Y and Z follow — are you OK with that?" Recommend the call and let them confirm.
- **Check for contradictions.** As answers accumulate, watch for inconsistencies with earlier answers. When you spot one, surface it directly, name both answers, and ask which one wins.
- **Probe with counterexamples.** Once a decision is tentatively made, stress-test it with one edge case before locking it in. "What about when X?" If the answer breaks down, the decision needs revisiting before moving down the branch.

## What to grill on

Anything the user is trying to figure out — plans, tasks, ideas, features, architecture decisions, process changes. The pattern is the same: find the root, ground via sub-agents, walk the tree, one recommended question at a time.

## Anti-patterns

- **Batching questions.** Kills the interview dynamic and hides dependencies.
- **Asking without a recommendation.** You're the interviewer, not a form.
- **Asking what sub-agents could tell you.** Delegate the reading, including any resources the user attached.
- **Stopping early** because it feels like enough. It's called "grill me" for a reason.
- **Wandering across branches** before the current one is resolved.
- **Accepting vague terms.** "Fast", "scalable", "clean", "simple" aren't answers — they're invitations to misinterpret. Press for a concrete definition before moving on.
