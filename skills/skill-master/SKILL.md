---
name: skill-master
description: Create a new skill from the conversation that just happened, or improve an existing one — carries the reference for writing skills well.
disable-model-invocation: true
---

A skill exists to wrangle determinism out of a stochastic system. **Predictability** — the agent taking the same _process_ every run, not producing the same output — is the root virtue; every lever below serves it.

**Bold terms** are defined in `references/glossary.md`; look them up there for the full meaning.

## Steps

You are invoked after the work happened: the user has just worked through a task with you (creating a skill), or an existing skill misbehaved (improving one). The conversation is the interview — mine it, don't re-ask.

1. **Mine the conversation** — the workflow that actually ran, the context it needed, what varied between the general case and this instance, what went wrong. For an existing skill, read it and diagnose against **Failure modes** below.
2. **Ask only what the conversation can't answer** (invocation type is the usual case) — one question at a time, with a recommended answer.
3. **Draft** the skill applying the reference below. Done when every piece of material has a decided rung: inline if every run needs it, behind a branch-named pointer if only some runs reach it.
4. **Verify** — run the no-op test sentence by sentence, prune, and sweep the failure modes. Done when every sentence survives the test and the description carries one trigger per branch.

## Invocation

Two choices, trading different costs:

- A **model-invoked** skill keeps a **description**, so the agent can fire it autonomously _and_ other skills can reach it (you can still type its name too). It contributes to **context load** — the description sits in the window every turn. Mechanics: omit `disable-model-invocation`, and write a model-facing description with rich trigger phrasing ("Use when the user wants…, mentions…").
- A **user-invoked** skill strips the description from the agent's reach: only you, typing its name, can invoke it — and no other skill can. Zero context load, but it spends **cognitive load**: _you_ are the index that must remember it exists. Mechanics: set `disable-model-invocation: true`; the `description` becomes human-facing — a one-line summary, trigger lists stripped.

Pick model-invocation only when the agent must reach the skill on its own, or another skill must. If it only ever fires by hand, make it user-invoked and pay no context load.

When user-invoked skills multiply past what you can remember, that piled-up cognitive load is cured by a **router skill**: one user-invoked skill that names the others and when to reach for each.

## Writing the description

A model-invoked **description** does two jobs — state what the skill is, and list the **branches** that should trigger it. Every word increases **context load**, so a description earns even harder pruning than the body:

- **Front-load the skill's leading word** — the description is where it does its invocation work.
- **One trigger per branch.** Synonyms that rename a single branch are **duplication** — "build features using TDD … asks for test-first development" is one branch written twice. Collapse them; keep only genuinely distinct branches.
- **Cut identity that's already in the body.** Keep the description to triggers, plus any "when another skill needs…" reach clause.

**Good:** "Generate BigQuery queries for sales analytics. Use when the user asks about revenue or pipeline metrics, or names a BigQuery table to query."

**Bad:** "Helps with data queries." — no leading word, no branches; nothing to trigger on.

## Lead with the goal

Open the skill's body with its **goal** and the _why_ behind it — the outcome it exists to produce, and why that outcome matters. An agent aiming at a known target executes with intent: it adapts when a step doesn't fit the situation instead of following a bare rule off a cliff. The same logic runs step by step — knowing _why_ a step exists is what lets the agent bend it when the edge case arrives.

## Information hierarchy

A skill is built from two content types — **steps** and **reference** — that mix freely: a skill can be all steps, all reference, or both. The core decision is which to use and where each sits on the **information hierarchy**, a ladder ranked by how immediately the agent needs the material:

1. **In-skill step** — an ordered action in `SKILL.md`, the primary tier: what the agent does, in order. Each step ends on a **completion criterion**, the condition that tells the agent the work is done. Make it _checkable_ (can the agent tell done from not-done?) and, where it matters, _exhaustive_ ("every modified model accounted for", not "produce a change list") — a vague criterion invites **premature completion**.
2. **In-skill reference** — a definition, rule, or fact in `SKILL.md`, consulted on demand. Often a legitimately flat peer-set (every rule of a review on one rung) — a fine arrangement, not a smell.
3. **External reference** — reference pushed out of `SKILL.md` into a separate file, reached by a **context pointer**, loaded only when the pointer fires. (Spans _disclosed_ reference — a sibling file like `references/glossary.md`, still part of the skill — through fully **external reference** that lives outside the skill system and any skill can point at.)

A demanding completion criterion drives thorough **legwork** — the digging the agent does within the work — whether the skill has steps or not, since "every rule applied" binds flat reference just as "every step done" binds a sequence.

Push too little down and the top bloats; push too much and you hide material the agent actually needs. That tension is the whole decision.

**Progressive disclosure** is the move down the ladder — out of `SKILL.md` into a linked file — so the top stays legible. Mechanics: a linked `.md` file in the skill folder, named for what it holds (this skill discloses its full definitions to `references/glossary.md`). Some skills are used in more than one way, and each distinct way is a **branch** — different runs taking different paths through the skill. Branching is the cleanest disclosure test: inline what every branch needs, and push behind a pointer what only some branches reach. A **context pointer**'s _wording_, not its target, decides when and how reliably the agent reaches the material.

Where the ladder decides _how far down_ a piece sits, **co-location** decides _what sits beside it_ once there: keep a concept's definition, rules, and caveats under one heading rather than scattered, so reading one part brings its neighbours with it.

## When disclosure pays

**Progressive disclosure** (above) says what's eligible to move — material only some branches reach. Eligible isn't sufficient: this decides whether the move pays.

Splitting doesn't remove a **branch** — it leaves a **context pointer** inline that every run still reads. The load you shed is _body minus pointer_: split only when the body is meaningfully bigger. A full ruleset sheds almost all its weight; a one-line fork sheds nothing. In the fuzzy middle, split when the branch is a distinct situation a run fully enters or fully skips; keep it inline when it's a small variation woven through a shared flow.

Three patterns put disclosure into practice:

**Pattern 1: High-level guide with references**
````markdown
# PDF Processing

## Goal
[What this skill produces and why it matters]

## Advanced features
- If the task involves filling forms, read `references/forms.md`.
- If you need the full API, read `references/api.md`.
````

**Pattern 2: Domain-specific organization**
```
bigquery-skill/
├── SKILL.md (overview and navigation)
└── references/
    ├── finance.md (revenue, billing)
    ├── sales.md (pipeline, accounts)
    └── product.md (usage, features)
```
The agent reads only the relevant domain file.

**Pattern 3: Conditional details**
```markdown
## Creating documents
If creating a new document, use docx-js — read `references/docx-js.md`.

## Editing documents
For simple edits, modify XML directly.
If the edit needs tracked changes, read `references/redlining.md`.
```

For reference files over ~100 lines, include a table of contents at the top so the agent can see available sections even when previewing with partial reads.

## When to split

**Granularity** is how finely you divide skills, and each cut spends one of the two loads, so split only when the cut earns it. Two cuts:

- **By invocation** — split off a **model-invoked** skill when you have a distinct **leading word** that should trigger it on its own, or another skill must reach it. You pay **context load** for the new always-loaded **description**, so that independent reach has to be worth it.
- **By sequence** — split a run of **steps** when the steps still ahead (a step's **post-completion steps**) tempt the agent to rush the one in front of it (**premature completion**). Keeping them out of view encourages the agent to do more **legwork** on the current task.

## Pruning

Keep each meaning in a **single source of truth**: one authoritative place, so changing the behaviour is a one-place edit.

Check every line for **relevance**: does it still bear on what the skill does?

Then hunt **no-ops** sentence by sentence, not just line by line: run the no-op test on each sentence in isolation, and when one fails, delete the whole sentence rather than trim words from it. Be aggressive — most prose that fails should go, not be rewritten.

## Leading words

A **leading word** is a compact concept already living in the model's pretraining that the agent thinks with while running the skill (e.g. _lesson_, _fog of war_, _tracer bullets_). Repeated throughout the text (though not necessarily - a strong leading word might only be needed once), it accumulates a distributed definition and anchors a whole region of behaviour in the fewest tokens, by recruiting priors the model already holds.

It serves predictability twice. In the body it anchors _execution_: the agent reaches for the same behaviour every time the word appears. In the description it anchors _invocation_: when the same word lives in your prompts, docs, and code, the agent links that shared language to the skill and fires it more reliably.

Hunt for opportunities to refactor skills to use leading words. A triad spelled out at three sites (**duplication**), a description spending a sentence to gesture at one idea — each is a passage begging to **collapse** into a single token. Examples include:

- "fast, deterministic, low-overhead" -> _tight_ — one quality restated across a phase — into a single pretrained word (a _tight_ loop).
- "a loop you believe in" -> _red_ — converts a fuzzy gate into a binary observable state (the loop goes _red_ on the bug, or it doesn't).

You win twice over: fewer tokens, _and_ a sharper hook for the agent to hang its thinking on. Assume every skill is carrying restatements that leading words retire — go find them.

## Portability

A skill may run in any coding agent, not just the one it was authored in — never hard-code what a harness controls:

- **MCP tools:** name them by server + capability — "the Linear server's issue-creation tool" — never by exact identifier. Harnesses prefix and rename tools differently; the executing agent resolves the actual name.
- **Always-needed command output:** when a skill always needs the same deterministic command output upfront (a git status, a schema dump), handle both runtimes in the skill: include the dynamic context injection syntax (fetch and follow https://code.claude.com/docs/en/skills#inject-dynamic-context) so Claude Code pre-renders the output at load, _and_ a plain instruction worded as a fallback — "If the output of X isn't already shown above, run X and use its output." Claude Code agents see the rendered output and skip the run; other agents see unrendered syntax, ignore it, and run the command.
- **User-invocation mechanics:** each agent gates invocation its own way. The frontmatter switch (see Invocation above) covers Claude Code; Codex reads an `agents/openai.yaml` file in the skill folder instead. A user-invoked skill ships both:

  ```yaml
  # agents/openai.yaml
  policy:
    allow_implicit_invocation: false
  ```

## Scripts and long-running steps

- If the skill's workflow contains a deterministic operation (validation, formatting, parsing) or code the agent would regenerate every run, read `references/scripts.md` — it may deserve a script.
- If the skill has long-running steps an agent could derail from, read `references/task-lists.md`.

## Failure modes

Use these to diagnose issues the user may be having with the skill.

- **Premature completion** — ending a step before it's genuinely done, attention slipping to _being done_. Defence, in order: sharpen the completion criterion first (cheap, local); only if it is irreducibly fuzzy _and_ you observe the rush, hide the post-completion steps by splitting (the sequence cut).
- **Duplication** — the same meaning in more than one place. Costs maintenance and tokens, and inflates a meaning's prominence on the ladder past its real rank.
- **Sediment** — stale layers that settle because adding feels safe and removing feels risky. The default fate of any skill without a pruning discipline.
- **Sprawl** — a skill simply too long, even when every line is live and unique. Hurts readability and maintainability and wastes tokens. The cure is the ladder: disclose **reference** behind pointers, and split by **branch** or sequence so each path carries only what it needs.
- **No-op** — a line the model already obeys by default, so you pay load to say nothing. The test: does it change behaviour versus the default? A weak leading word (_be thorough_ when the agent is already thorough-ish) is a no-op; the fix is a stronger word (_relentless_), not a different technique.
- **Deep nesting** — references that link to further references; the agent may only partially read them. Keep references one level deep: `SKILL.md` links to files; those files don't link further.
- **Time-sensitive content** — "after August 2025, use X" will rot. State behaviour, not dates.
