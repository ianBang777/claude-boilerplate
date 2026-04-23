#!/bin/bash
# PreToolUse (Task) - 에이전트 시작 시 터미널에 표시

INPUT=$(cat)

DESCRIPTION=$(echo "$INPUT" | python3 -c "
import sys, json
d = json.load(sys.stdin)
print(d.get('tool_input', {}).get('description', ''))
" 2>/dev/null)

MODEL=$(echo "$INPUT" | python3 -c "
import sys, json
d = json.load(sys.stdin)
print(d.get('tool_input', {}).get('model', ''))
" 2>/dev/null)

[ -z "$DESCRIPTION" ] && exit 0

# 경과 시간 계산용 시작 시각 저장
TIMER_KEY=$(echo "$DESCRIPTION" | python3 -c "
import sys, hashlib
print(hashlib.md5(sys.stdin.read().strip().encode()).hexdigest()[:8])
" 2>/dev/null)
date +%s > "/tmp/claude-agent-${TIMER_KEY}.ts" 2>/dev/null

# ANSI
CYAN=$'\033[0;36m'
DIM=$'\033[2m'
RESET=$'\033[0m'

TS=$(date '+%H:%M:%S')
MODEL_LABEL=""
[ -n "$MODEL" ] && MODEL_LABEL="${DIM} (${MODEL})${RESET}"

printf "  %b\n" "${DIM}┌ ▶${RESET}  ${CYAN}${DESCRIPTION}${RESET}${MODEL_LABEL}  ${DIM}${TS}${RESET}" >&2
