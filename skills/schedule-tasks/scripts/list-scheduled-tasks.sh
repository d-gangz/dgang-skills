#!/bin/bash

# Optional: pass a folder path to filter tasks for that project
FILTER_FOLDER="${1:-}"

find "$HOME/Library/Application Support/Claude/claude-code-sessions" \
  -name "scheduled-tasks.json" -type f 2>/dev/null | while read f; do
  uv run python3 -c "
import json, sys, os

data = json.load(open('$f'))
tasks = data.get('scheduledTasks', [])
if not tasks:
    sys.exit()

filter_folder = '$FILTER_FOLDER'

for t in tasks:
    cwd = t.get('cwd', '')
    if filter_folder and cwd != filter_folder:
        continue
    status = 'ON' if t.get('enabled') else 'OFF'
    last = t.get('lastRunAt', 'never')
    model = t.get('model', 'unknown')
    cron = t.get('cronExpression', '?')
    name = t['id']
    perm = t.get('permissionMode', '?')
    worktree = 'yes' if t.get('useWorktree') else 'no'
    print(f'  {name}  |  {cron}  |  {status}  |  {model}  |  last: {last}  |  cwd: {cwd}  |  perm: {perm}  |  worktree: {worktree}')
"
done
