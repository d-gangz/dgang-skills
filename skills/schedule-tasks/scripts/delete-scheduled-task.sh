#!/bin/bash
set -e

TASK_NAME="$1"

if [ -z "$TASK_NAME" ]; then
  echo "Usage: delete-scheduled-task.sh <task-name>"
  exit 1
fi

# Step 1: Find and remove from scheduled-tasks.json in claude-code-sessions
CONFIGS=$(find "$HOME/Library/Application Support/Claude/claude-code-sessions" \
  -name "scheduled-tasks.json" -type f 2>/dev/null)

FOUND=false
while IFS= read -r cfg; do
  if python3 -c "
import json, sys
data = json.load(open('$cfg'))
ids = [t['id'] for t in data.get('scheduledTasks', [])]
sys.exit(0 if '$TASK_NAME' in ids else 1)
" 2>/dev/null; then
    FOUND=true
    BASE=$(dirname "$cfg")

    python3 -c "
import json
f = '$cfg'
data = json.load(open(f))
data['scheduledTasks'] = [t for t in data['scheduledTasks'] if t['id'] != '$TASK_NAME']
json.dump(data, open(f, 'w'), indent=2)
print(f'Removed \"$TASK_NAME\" from scheduled-tasks.json')
"

    # Step 2: Clean up orphaned session metadata
    COUNT=0
    for f in $(grep -l "\"scheduledTaskId\":\"$TASK_NAME\"" "$BASE"/local_*.json 2>/dev/null); do
      rm -f "$f"
      COUNT=$((COUNT + 1))
    done
    echo "Cleaned up $COUNT orphaned session metadata files"
  fi
done <<< "$CONFIGS"

if [ "$FOUND" = false ]; then
  echo "Warning: Task '$TASK_NAME' not found in any scheduled-tasks.json"
fi

# Step 3: Delete the SKILL.md
SKILL_DIR="$HOME/.claude/scheduled-tasks/$TASK_NAME"
if [ -d "$SKILL_DIR" ]; then
  rm -rf "$SKILL_DIR"
  echo "Deleted: $SKILL_DIR"
else
  echo "Note: $SKILL_DIR not found (already deleted?)"
fi

echo ""
echo "Done. Restart Claude Desktop to fully stop the scheduler."
