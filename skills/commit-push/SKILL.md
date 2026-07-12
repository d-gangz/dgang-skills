---
name: commit-push
description: Generate organized commits and push changes directly to current branch.
---

# Generate organized commits & push changes

**Goal:** Commits are the retrieval index for future sessions — batch and word them so a later `git log` reads as a useful changelog of what changed and why.

## Pre-fetched context

**Current branch:** !`git branch --show-current`

**Working tree status:**
```
!`git status --porcelain`
```

**Change summary (staged + unstaged):**
```
!`git diff HEAD --stat`
```

## Steps

1. Review the context above:
   - If on main/master, warn me but still continue.
   - If there are no changes at all (staged or unstaged), inform me and stop.
   - If there are already staged changes: unstage them with `git reset HEAD` and explain "Unstaging to create organized batched commits", then proceed with all unstaged changes.
   - If you don't recognize a change from this session's context, read its diff before batching.

2. Batch the changes into atomic, focused commits. If changes relate to a Linear issue mentioned in conversation, include its magic word (ref) + ID in that commit (e.g., `feat(auth): add login, ref INT-42`).

3. Create the commits (proceed immediately, no approval needed). For each batch, `git add` only that batch's files — never `git add .` or `-A`.

4. Push to the current branch and confirm success.

5. Report back to user: commits created (message, files), batching rationale, push status.
