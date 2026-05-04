# Gap: Execution — Reasoning

## Definition

*Spec was clean, context was healthy, skills and tools worked — and the model still got it wrong.*

Reasoning is the only gap you can't prevent in advance — it's how the model works. The wrong output looks right: no error, no warning, and the agent sounds *most* confident when it's wrong.

## Symptoms

Three flavors:

- **Hallucination** — made-up fact, citation, or claimed verification that didn't actually happen
- **Instruction skip** — the spec said it clearly; the agent didn't follow
- **Bad inference** — correct inputs, wrong conclusion

Before classifying as Reasoning, **rule out Context** (memory failed) and **Tooling** (skills/tools failed) — those are cheaper to fix.

## Headline rule

**Can't prevent — only catch.** Every Reasoning failure is a missing way to verify the output.

## Fix type: Mixed

Reasoning failures happen *inside* a session, not because of a file. The fix is *adding a feedback loop so the next run can't fail the same way.* Where that loop lives determines fix type:

- **Agent-side** — if the failed workflow ran through a skill (the verification belongs in the skill body) or if a deterministic check belongs in a hook on disk. Output a Part B fix proposal; MAIN applies it after approval.
- **User-side** — if the failed workflow was an ad-hoc prompt (the user needs to add stopping conditions to their prompts going forward). Output Part A tips only.

Use the diagnosis evidence to pick the right side. **Default to agent-side** when the workflow is one the user runs repeatedly — fixing it in a skill or hook means the next run is protected automatically; the user-side tip is only as durable as the user's memory.

## Part A — Tips for the next task (user-side)

Use when the failed workflow was an ad-hoc prompt and isn't likely to be run via a skill in the future. Reach as far down the Module 5 spectrum as the cost of failure justifies. Always include tips even when Part B applies — the user benefits from learning the underlying pattern. Examples to draw from:

- *"Add a stopping condition to your next brief: 'Don't finish until [specific verification].' For this session, '[concrete check]' would have caught the [specific Reasoning failure]."*
- *"For tasks like this, bake in the citation check pattern: 'Don't finish until every URL cited has been opened and the source confirms the claim.'"*
- *"For high-stakes outputs (client-facing, irreversible), structure: agent proposes → you approve. Don't let the agent send / publish / commit. Have it draft, you review, you ship."*

## Part B — Fix proposal (agent-side)

Use when the failed workflow runs through a skill, or when a deterministic check belongs in a hook. Fill in the bracketed sections with concrete details from the diagnosis, then include the result in the report you return to MAIN. MAIN will surface it to the user and apply it after approval.

```
- **Target file(s):** `[exact path, e.g., .claude/skills/research-prospect/SKILL.md]`
  [or for hooks: `.claude/settings.json` and the hook script path]

- **Specific changes:**
  [Pick the right level on the Module 5 spectrum.]

  [For skill body — stopping condition + self-verification pattern:]
  - Add to the skill body: "Don't finish until [specific verification].
    Specifically, [concrete check, e.g., 'open every URL cited in the
    dossier and confirm the source supports the claim — flag any
    that don't']."
  - If applicable, add a self-verification pattern: artifact reopen,
    citation check, unverified-gap audit, visual check, regression
    check, or uncertainty surfacing.

  [For sub-agent reviewer baked into the skill:]
  - Append to the skill workflow: "After producing the artifact, spawn
    a sub-agent with the artifact and a review prompt: '[review
    criteria]'. Address every flag before declaring done."

  [For hooks:]
  - Create a [trigger event, e.g., `Stop` or `PostToolUse`] hook that
    runs [check, e.g., 're-read the markdown files edited this turn'].

- **Recommended tool to apply:**
  - For skill revisions: `/skill-master`.
  - For hook creation: `/help` (carries the hook lifecycle, event
    list, action schema, and exit codes from the official docs;
    scaffolds `.claude/settings.json` and `.claude/hooks/` cleanly).
  - For small targeted edits: direct `Edit`.
```

## When to re-diagnose

After the feedback loop is in place, re-run the original task in a fresh session. If the same Reasoning failure recurs, the loop you added didn't catch it — escalate to a stronger one in the spectrum (e.g., from in-skill stopping condition → sub-agent reviewer → hook → human review).
