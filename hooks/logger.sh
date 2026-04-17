#!/bin/bash
# PostToolUse - 세션별 툴 사용 로그 저장

INPUT=$(cat)

TOOL=$(echo "$INPUT" | python3 -c "
import sys, json
d = json.load(sys.stdin)
print(d.get('tool_name', 'unknown'))
" 2>/dev/null)

SESSION=$(echo "$INPUT" | python3 -c "
import sys, json
d = json.load(sys.stdin)
print(d.get('session_id', 'unknown')[:8])
" 2>/dev/null)

DATE=$(date "+%Y-%m-%d %H:%M:%S")
PROJECT=$(basename "$PWD")
LOG_DIR="$HOME/.claude/logs"

mkdir -p "$LOG_DIR"
echo "[$DATE] [$PROJECT] [$SESSION] $TOOL" >> "$LOG_DIR/$(date '+%Y-%m-%d').log"
