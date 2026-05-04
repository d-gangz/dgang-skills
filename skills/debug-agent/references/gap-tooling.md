# Gap: Execution — Tooling

## Definition

*The agent knew what to do, but its skills, scripts, or tools didn't let it do it.*

Tooling gaps usually show up at the *skill* layer first — a skill that should have applied didn't fire because the description didn't match how the user phrased the request, or it fired but the body was so vague the agent improvised and drifted. Deeper down, they show up as tool issues — a CLI returns an error the agent can't act on, or there's no tool for an affordance the agent needed.

## Symptoms

- A skill that should have fired didn't (the agent improvised a different shape instead)
- A skill fired but produced inconsistent output across runs (body too vague)
- The agent re-derived the same code-doable step every run (parsing the same CSV, formatting the same template)
- A tool/CLI returned an error the agent couldn't interpret or act on
- A tool returned empty and the agent treated it as success

## Headline rule

**Audit the skill first; then read raw tool output and fix what's beneath.**

## Fix type: Agent-side primary

The failing artifact lives on disk — a skill body, a CLI script, a hook config. The fix is a concrete change to a file. As FORK, your job is to describe it precisely in the Part B proposal below; **MAIN will apply it after the user approves**.

## Part A — Tips for the next task

Optional but encouraged. Most of the value lives in Part B (the file fix), but a user-phrasing tip often pairs well — e.g., *"In the next session, try using the slash command directly (`/research-prospect`) until the description revision lands; that bypasses the trigger-matching issue."* Always include a tip if any user habit contributed to the gap.

## Part B — Fix proposal

Fill in the bracketed sections with concrete details from the diagnosis, then include the result in the structured report you return to MAIN. MAIN will surface it to the user and apply it after approval.

```
- **Target file(s):** `[exact path, e.g., .claude/skills/research-prospect/SKILL.md]`

- **Specific changes:**
  [Be concrete. For description fixes:]
  - Add the following trigger phrases to the description:
    - "[phrase 1]"
    - "[phrase 2]"
  - Keep the existing wording intact; expand the trigger surface.

  [For body fixes:]
  - The body is too vague at step [N]: "[current vague text]". Replace
    with concrete instructions: "[recommended text]".
  - Factor the [code-doable step] into a script the skill calls, not
    text the agent re-derives.

  [For CLI fixes:]
  - The CLI returns "[unhelpful error]". Wrap it via `/create-cli` so
    it returns parseable output and actionable error messages.

- **Recommended tool to apply:**
  - For skill revisions: `/skill-master`.
  - For CLI work: `/create-cli`.
  - For hook creation: `/help` (carries the hook lifecycle, event
    list, action schema, and exit codes from the official docs).
  - For small targeted edits: direct `Edit`.
```

## When to re-diagnose

After the user re-runs the original task in a fresh session. If the skill fires correctly but output is *still* off, the gap may now be downstream (Reasoning) — the skill works but verification is missing. Run `/debug-agent` again to surface it.
