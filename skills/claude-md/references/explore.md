# Exploring the repo

Spawn a read-only exploration subagent, ask it to be very thorough, and give it these questions:

**WHAT** (Contents & Structure): how the repo is organized and what each area is for. Code: languages, frameworks, config files (package.json, pyproject.toml, Cargo.toml, etc.), build/CI setup. Docs/ops: domains, directory purposes, templates, canonical files (the single-source-of-truth docs everything else derives from), current vs superseded distinctions.

**WHY** (Purpose): what the repo exists to do; how its parts relate; key abstractions, patterns, or conventions.

**HOW** (Workflows): the recurring tasks and what runs them. Code: build, test (unit/integration/e2e), lint/format, run/dev, deployment. Docs/ops: the automations and tools that generate or consume content (so machine-managed paths are known), and the workflows the repo supports.

Also check existing documentation: README.md, CONTRIBUTING.md, docs/, scoped CLAUDE.md files in subdirectories, architecture decision records, convention docs. Done when you can answer all three question groups and know what documentation already exists.

For a targeted edit, scope the exploration to what the edit touches — you don't need the full sweep to verify one command or one pointer.

When finished with the CLAUDE.md work, summarize what you discovered about the repo and list unresolved questions (e.g., "Is there a staging environment?", "Is sales/leads-list/ still in use?").
