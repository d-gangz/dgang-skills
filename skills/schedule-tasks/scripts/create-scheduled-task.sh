#!/bin/bash
set -e

NAME="$1"
DESC="$2"
PROMPT="$3"
CRON="$4"
MODEL="${5:-claude-opus-4-6}"
FOLDER="${6:-$PWD}"

if [ -z "$NAME" ] || [ -z "$DESC" ] || [ -z "$PROMPT" ] || [ -z "$CRON" ]; then
  echo "Usage: create-scheduled-task.sh <name> <description> <prompt> <cron> [model] [folder]"
  echo ""
  echo "Arguments:"
  echo "  name          Task name in kebab-case (e.g. daily-review)"
  echo "  description   Short description (shown in Desktop UI)"
  echo "  prompt        Task instructions, or @filepath to read from a file"
  echo "  cron          Cron expression in local timezone (e.g. '0 8 * * *')"
  echo "  model         Claude model (default: claude-opus-4-6)"
  echo "  folder        Project folder to give access to (default: current dir)"
  exit 1
fi

# If prompt starts with @, read from file
if [[ "$PROMPT" == @* ]]; then
  PROMPT_FILE="${PROMPT:1}"
  if [ ! -f "$PROMPT_FILE" ]; then
    echo "Error: Prompt file not found: $PROMPT_FILE"
    exit 1
  fi
  PROMPT=$(cat "$PROMPT_FILE")
fi

# Resolve folder to absolute path
FOLDER="$(cd "$FOLDER" 2>/dev/null && pwd || echo "$FOLDER")"

SKILL_DIR="$HOME/.claude/scheduled-tasks/$NAME"
SKILL_PATH="$SKILL_DIR/SKILL.md"

# Step 1: Create SKILL.md
mkdir -p "$SKILL_DIR"
cat > "$SKILL_PATH" << SKILLEOF
---
name: $NAME
description: $DESC
---

$PROMPT
SKILLEOF

echo "Created: $SKILL_PATH"

# Step 2: Find scheduled-tasks.json in claude-code-sessions and add entry
CONFIGS=$(find "$HOME/Library/Application Support/Claude/claude-code-sessions" \
  -name "scheduled-tasks.json" -type f 2>/dev/null)

if [ -z "$CONFIGS" ]; then
  echo "Error: No scheduled-tasks.json found in claude-code-sessions."
  echo "You need at least one existing scheduled task created via Claude Desktop UI first."
  exit 1
fi

# Pick the config whose existing tasks reference our folder (via cwd), or fall back to first
TARGET_CONFIG=""
while IFS= read -r cfg; do
  if uv run python3 -c "
import json, sys
data = json.load(open('$cfg'))
cwds = set()
for t in data.get('scheduledTasks', []):
    c = t.get('cwd', '')
    if c: cwds.add(c)
sys.exit(0 if '$FOLDER' in cwds or not cwds else 1)
" 2>/dev/null; then
    TARGET_CONFIG="$cfg"
    break
  fi
done <<< "$CONFIGS"

TARGET_CONFIG="${TARGET_CONFIG:-$(echo "$CONFIGS" | head -1)}"

# Add the task entry
uv run python3 -c "
import json, time

f = '$TARGET_CONFIG'
data = json.load(open(f))

for t in data['scheduledTasks']:
    if t['id'] == '$NAME':
        print(f'Error: Task \"$NAME\" already exists')
        exit(1)

data['scheduledTasks'].append({
    'id': '$NAME',
    'cronExpression': '$CRON',
    'enabled': True,
    'filePath': '$SKILL_PATH',
    'createdAt': int(time.time() * 1000),
    'model': '$MODEL',
    'cwd': '$FOLDER',
    'useWorktree': False,
    'permissionMode': 'bypassPermissions'
})

json.dump(data, open(f, 'w'), indent=2)
print(f'Added \"$NAME\" to scheduled-tasks.json')
"

echo ""
echo "Task: $NAME"
echo "Schedule: $CRON (local timezone)"
echo "Model: $MODEL"
echo "Folder: $FOLDER"
echo ""
echo "Restart Claude Desktop to activate."
