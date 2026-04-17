#!/bin/bash
# PostToolUse (Task) - 에이전트 완료 시 터미널에 알림

INPUT=$(cat)

DESCRIPTION=$(echo "$INPUT" | python3 -c "
import sys, json
d = json.load(sys.stdin)
print(d.get('tool_input', {}).get('description', ''))
" 2>/dev/null)

if [ -n "$DESCRIPTION" ]; then
  echo "  ✓ 완료  $DESCRIPTION" >&2
fi
