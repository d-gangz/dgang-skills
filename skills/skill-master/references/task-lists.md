# Gated task lists

When a skill's sequence contains long-running steps — a bash command that takes a while, a build, a large test run — have the agent create one task per step in its task list. Long waits invite derailment after interruptions (hooks, sub-agent results, context compaction). A sequence whose steps all run quickly doesn't need this.

**Key insight:** the agent may only reliably see task titles, not descriptions. Put essential information in the title:
- Gate conditions: "GATE: steps 1-7 complete — Push and create PR"
- Key context: "Run /simplify — wait for ALL agents before proceeding"

**Pattern: Gated workflow**

Some steps depend on prior steps. Make this explicit in the task title so it's visible after compaction.

````markdown
## FIRST: Create your task checklist

Before reading anything else, create one task per step below in your task list. Mark each task completed as you finish it. After any interruption, check your task list to find the next uncompleted step.

**Important**: Copy each step verbatim as the task title — gate conditions must appear in the title so they're visible in the task list after compaction.

1. Read context and reference files
2. Create feature branch
3. Implement core functionality
4. Run tests and type check
5. Run /simplify — wait for ALL agents to report back, fix issues, re-run tests
6. GATE: steps 1-5 complete — Push branch, create PR, run code review
7. GATE: steps 1-6 complete — Stop and wait for user review
8. GATE: user approved — Merge PR
````

**Why this works:**
- Tasks created upfront survive context loss
- Gate conditions in titles prevent premature execution
- "After any interruption, check your task list" recovers state
