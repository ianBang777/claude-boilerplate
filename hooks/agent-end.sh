#!/bin/bash
# PostToolUse (Task) - 에이전트 완료 시 터미널에 표시

INPUT=$(cat)

DESCRIPTION=$(echo "$INPUT" | python3 -c "
import sys, json
d = json.load(sys.stdin)
print(d.get('tool_input', {}).get('description', ''))
" 2>/dev/null)

[ -z "$DESCRIPTION" ] && exit 0

# 경과 시간 계산
TIMER_KEY=$(echo "$DESCRIPTION" | python3 -c "
import sys, hashlib
print(hashlib.md5(sys.stdin.read().strip().encode()).hexdigest()[:8])
" 2>/dev/null)
TIMER_FILE="/tmp/claude-agent-${TIMER_KEY}.ts"

ELAPSED=""
if [ -f "$TIMER_FILE" ]; then
  START=$(cat "$TIMER_FILE")
  END=$(date +%s)
  DIFF=$((END - START))
  if [ "$DIFF" -lt 60 ]; then
    ELAPSED="${DIFF}s"
  else
    ELAPSED="$((DIFF / 60))m $((DIFF % 60))s"
  fi
  rm -f "$TIMER_FILE"
fi

# ANSI
GREEN=$'\033[0;32m'
DIM=$'\033[2m'
RESET=$'\033[0m'

TS=$(date '+%H:%M:%S')
ELAPSED_LABEL=""
[ -n "$ELAPSED" ] && ELAPSED_LABEL="  ${DIM}${ELAPSED}${RESET}"

printf "  %b\n\n" "${DIM}└ ${GREEN}✓${RESET}  ${DESCRIPTION}${ELAPSED_LABEL}  ${DIM}${TS}${RESET}" >&2
