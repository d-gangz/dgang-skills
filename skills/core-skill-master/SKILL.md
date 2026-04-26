---
name: core-skill-master
description: >
  Create new skills, modify and improve existing skills. Use when users want to
  create a skill from scratch, edit or optimize an existing skill, turn a workflow
  into a reusable skill, or improve a skill's description for better triggering.
---

# Skill Master

Create and improve skills through conversation. The key insight: skills capture workflows, and the best way to understand a workflow is to experience it together.

## Core Approach

**Don't jump to drafting.** The most common mistake is writing a skill before fully understanding what it should do. Instead:

1. **Engage with the task itself** - When a user describes what they want, try solving it with them first. This reveals edge cases, preferences, and implicit requirements that wouldn't surface in an interview.

2. **Notice patterns** - As you work through the task, observe what context you need, what decisions require judgment, what steps are always the same, and what varies.

3. **Probe one question at a time** - When engagement leaves gaps, fill them through `AskUserQuestion`. Ask one question, propose a recommended answer with a one-line reason, wait for the response before asking the next. Each answer informs the next question. Never batch.

4. **Draft when ready** - Only write the skill once you understand the workflow well enough to explain it to another Claude instance.

5. **Delegate heavy reading** - If the user references long transcripts, multi-file codebases, or large attached docs, spawn `Explore` or `general-purpose` to read. Light material — the existing skill, a short doc, a single file — read directly.

## Creating a New Skill

When a user wants to create a skill:

**If they describe a task:** Offer to work through it together first. "Let's try this together - describe a specific example and I'll help you accomplish it. That'll help me understand exactly what the skill should do."

**If they have a workflow in mind:** Ask them to walk you through it with a real example. Watch for:
- What information do they provide upfront vs. what do you need to ask for?
- Where do they make judgment calls?
- What output format do they expect?
- What would make this fail?

**If they're capturing a conversation:** Extract from the conversation history what context was needed, what steps were taken, what corrections were made, and what the final output looked like.

### Decisions to resolve

Once engagement reveals enough of the workflow, walk these decisions in dependency order. Each gates the next — don't jump branches until the current one is resolved.

1. **Triggers** — what phrases, file types, or contexts activate this skill? Gates everything downstream because trigger phrasing defines scope.
2. **Scope** — what range of tasks does this procedure cover, and what falls outside? Bounds what the skill is responsible for encoding vs. what stays general.
3. **Output** — what does success look like? Format, shape, examples.
4. **Degrees of freedom** — text instructions, parameterized templates, or exact scripts. Match to task fragility.
5. **Structure** — single SKILL.md, references, or scripts. Falls out of the previous answers.

Walk one at a time via `AskUserQuestion`, recommendation-first.

### Probing tactics

Layer these onto the decision walk so each answer is actually load-bearing. Deploy as the situation calls, not as a checklist.

- **Press for definitions** - When the user says "smarter triggering", "more robust handling", "better description", or other fuzzy terms, force a concrete version — specific phrases, observable behavior. Propose a sharp definition they can accept with one tap.
- **Surface assumptions** - Check the framing before walking the tree. Is this one skill or three? Is the workflow actually reusable, or one-off? Is the user reaching for a skill when a CLAUDE.md note would fit better?
- **Test consequences** - After each answer, trace the implication. "If the trigger is X, this also fires on Y — OK?" / "If freedom is high, output will vary across runs — OK?"
- **Probe with counterexamples** - Stress-test a tentative decision before locking it in. "Would this correctly *not* fire when user says Z?" If it breaks, revisit before moving down the branch.

## Improving an Existing Skill

When a user wants to improve a skill:

1. **Read the current skill** - Understand what it claims to do and how it's structured.

2. **Identify gaps** - Either from user feedback ("it doesn't handle X well") or by analyzing against best practices:
   - Is the description specific enough for triggering?
   - Is the content concise or bloated?
   - Are instructions clear or ambiguous?
   - Does it handle common edge cases?

3. **Probe the gaps** - Same one-at-a-time, recommendation-first pattern as Core Approach #3, scoped to the gaps you identified rather than re-interviewing broadly.

4. **Optionally, test the workflow** - Have the user describe a task the skill should handle. Try it and see where it falls short.

## Writing the Skill

### Structure

```
skill-name/
├── SKILL.md           # Main instructions (required, <500 lines)
├── references/        # Detailed docs loaded on-demand
└── scripts/           # Utility scripts (if needed)
```

**File naming tips:**
- Use forward slashes for paths (`reference/guide.md`, not `reference\guide.md`)
- Name files descriptively: `form_validation_rules.md`, not `doc2.md`
- Organize by domain: `reference/finance.md`, `reference/sales.md` (not `docs/file1.md`)

### Progressive Disclosure Patterns

**Pattern 1: High-level guide with references**
````markdown
# PDF Processing

## Quick start
[Minimal example here]

## Advanced features
**Form filling**: See [FORMS.md](FORMS.md) for complete guide
**API reference**: See [REFERENCE.md](REFERENCE.md) for all methods
````

**Pattern 2: Domain-specific organization**
```
bigquery-skill/
├── SKILL.md (overview and navigation)
└── reference/
    ├── finance.md (revenue, billing)
    ├── sales.md (pipeline, accounts)
    └── product.md (usage, features)
```
Claude reads only the relevant domain file.

**Pattern 3: Conditional details**
```markdown
## Creating documents
Use docx-js for new documents. See [DOCX-JS.md](DOCX-JS.md).

## Editing documents
For simple edits, modify XML directly.
**For tracked changes**: See [REDLINING.md](REDLINING.md)
```

**Tip:** For reference files >100 lines, include a table of contents at the top so Claude can see available sections even when previewing with partial reads.

### SKILL.md Template

```markdown
---
name: skill-name
description: >
  Brief description of capability. Use when [specific triggers].
  Include keywords users might say.
---

# Skill Name

## Quick Start

[Minimal working example or first steps]

## Workflow

[Step-by-step process, with decision points if needed]

## Advanced

[Link to reference files if content exceeds main file]
See [references/advanced.md](references/advanced.md) for details.
```

### Description Guidelines

The description is the **only thing Claude sees** when deciding whether to load a skill. It must include:
- What the skill does (first sentence)
- When to trigger it (second sentence, "Use when...")
- Key trigger words/contexts

**Good:** "Generate BigQuery queries for sales analytics. Use when user asks about sales data, revenue metrics, pipeline analysis, or mentions BigQuery and sales in the same request."

**Bad:** "Helps with data queries."

### Naming Conventions

Use consistent naming with lowercase letters, numbers, and hyphens only. Prefer gerund form (verb + -ing) for clarity:
- Good: `processing-pdfs`, `analyzing-spreadsheets`, `managing-databases`
- Avoid: `helper`, `utils`, `tools` (too vague)

### Writing Principles

**Concise is key.** Claude is already smart - only add context it doesn't have. Challenge each piece:
- "Does Claude really need this explanation?"
- "Can I assume Claude knows this?"
- "Does this paragraph justify its token cost?"

**Set appropriate degrees of freedom.** Match specificity to task fragility:
- **High freedom** (text instructions): Multiple approaches valid, decisions depend on context
- **Medium freedom** (pseudocode/parameterized scripts): Preferred pattern exists, some variation OK
- **Low freedom** (specific scripts, exact commands): Operations are fragile, consistency critical

**Other principles:**
- **Explain the why** - Theory of mind beats rigid MUSTs.
- **One level of references** - SKILL.md links to files; those files don't link further.

### When to Add Scripts

Add utility scripts when:
- Operations are deterministic (validation, formatting)
- Same code would be generated repeatedly
- Errors need explicit handling

**Use `/create-cli` to build utility CLIs.** When a skill needs a CLI script, use `/create-cli` to build it. This ensures the CLI is agent-friendly (non-interactive, parseable output, actionable errors).

**Make clear whether Claude should execute or read the script:**
- **Execute** (most common): "Run `analyze_form.py` to extract fields" - more reliable, saves tokens
- **Read as reference**: "See `analyze_form.py` for the extraction algorithm" - when Claude needs to understand the logic

**Don't assume packages are installed.** Be explicit about dependencies:
- Bad: "Use the pdf library to process the file."
- Good: "Install required package: `pip install pypdf`, then use `PdfReader` to open files."

### MCP Tool References

If your skill uses MCP tools, always use fully qualified names to avoid "tool not found" errors:

```markdown
Use the BigQuery:bigquery_schema tool to retrieve table schemas.
Use the GitHub:create_issue tool to create issues.
```

Format: `ServerName:tool_name` - without the server prefix, Claude may fail to locate the tool.

### Dynamic Context Injection

Use dynamic context injection to run shell commands **before** the skill is sent to Claude. The output replaces the placeholder, so Claude receives actual data, not the command.

**Syntax:**
- Inline: exclamation mark followed by backtick-wrapped command (e.g., `!` + `` `git status` ``)
- Multi-line: open a code fence with three backticks followed by `!`, then close normally

**When to use:** You always need the same context upfront (not conditional).

**Example - PR summary skill:**

A skill that needs PR context would include lines like:
- `- PR diff:` followed by inline command for `gh pr diff`
- `- Changed files:` followed by inline command for `gh pr diff --name-only`

**Example - multi-line environment info:**

A skill needing multiple commands would use a fenced block opened with the `!` modifier, containing commands like `node --version` and `npm --version` on separate lines.

This is preprocessing - Claude only sees the final output, not the commands. Don't use this for conditional logic (if A do X, if B do Y) - those should be regular instructions Claude executes.

## Workflows and Feedback Loops

### Use Workflows for Complex Tasks

For multi-step operations, use `TaskCreate` to create one task per step. This prevents derailment after interruptions (hooks, agent results, context compaction).

**Key insight:** Claude can only read task titles, not descriptions. Put essential information in the title:
- Gate conditions: "GATE: steps 1-7 complete — Push and create PR"
- Key context: "Run /simplify — wait for ALL agents before proceeding"

**Pattern: Gated workflow**

Some steps depend on prior steps. Make this explicit in the task title so it's visible after compaction.

````markdown
## FIRST: Create your task checklist

Before reading anything else, use TaskCreate to create one task per step below. Mark each task completed as you finish it. After any interruption, check your task list to find the next uncompleted step.

**Important**: Copy each step verbatim as the task `subject` — gate conditions must appear in the subject so they're visible in TaskList after compaction.

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

### Implement Feedback Loops

For quality-critical operations, build in validation cycles (run check → fix → repeat):

```markdown
## Editing process

1. Make your edits
2. **Validate immediately**:
   - With scripts: `python scripts/validate.py`
   - Without scripts: Review against checklist in STYLE_GUIDE.md
3. If validation fails:
   - Note specific issues
   - Fix them
   - Validate again
4. **Only proceed when validation passes**
```

This pattern catches errors early whether you're using code or manual review.

## Common Patterns

### Template Pattern

Provide templates for output format. Match strictness to requirements:

````markdown
## Report structure

ALWAYS use this exact template:

```markdown
# [Title]

## Executive summary
[One-paragraph overview]

## Key findings
- Finding 1
- Finding 2

## Recommendations
1. Action item
2. Action item
```
````

### Examples Pattern

Show input/output pairs for skills where output quality depends on examples:

````markdown
## Commit message format

**Example 1:**
Input: Added user authentication with JWT tokens
Output: `feat(auth): implement JWT-based authentication`

**Example 2:**
Input: Fixed bug where dates displayed incorrectly
Output: `fix(reports): correct date formatting in timezone conversion`
````

### Conditional Workflow Pattern

Guide Claude through decision points:

```markdown
## Document modification workflow

1. Determine the modification type:

   **Creating new content?** → Follow "Creation workflow" below
   **Editing existing content?** → Follow "Editing workflow" below

2. Creation workflow:
   - Use library X
   - Build from scratch
   - Export to format

3. Editing workflow:
   - Unpack existing document
   - Modify directly
   - Validate after each change
```

## Review Checklist

Before finalizing:

- [ ] Description includes trigger phrases ("Use when...")
- [ ] SKILL.md under 500 lines
- [ ] No time-sensitive information
- [ ] Consistent terminology throughout
- [ ] Concrete examples included
- [ ] References one level deep (if any)
- [ ] Tested with a real task

## Anti-Patterns

- **Drafting before understanding** - The skill will be generic and miss important cases.
- **Over-engineering** - Start minimal; add complexity only when needed.
- **Vague descriptions** - "Helps with X" doesn't trigger; be specific.
- **Deep nesting** - Claude may only partially read nested references.
- **Time-sensitive content** - "After August 2025, use X" will rot.
- **Offering too many options** - "Use pypdf, or pdfplumber, or PyMuPDF..." is confusing. Provide a default with an escape hatch for edge cases.
- **Batching questions** - Hides dependencies; each answer should inform the next.
- **Asking without a recommendation** - You're the designer, not a form.
- **Asking what could be read** - Skim referenced files, attached transcripts, or the existing skill before asking the user.
