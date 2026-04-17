#!/bin/bash
# PreToolUse (Bash) - 위험한 명령어 실행 전 차단

INPUT=$(cat)
COMMAND=$(echo "$INPUT" | python3 -c "
import sys, json
d = json.load(sys.stdin)
print(d.get('tool_input', {}).get('command', ''))
" 2>/dev/null)

# 절대 차단 패턴 (exit 2 → Claude에게도 전달되어 재시도 불가)
BLOCK_PATTERNS=(
  "rm -rf /"
  "rm -rf ~"
  "rm -rf \$HOME"
  "git push --force origin main"
  "git push -f origin main"
  "git push --force origin master"
  "DROP DATABASE"
  "chmod -R 777 /"
)

for pattern in "${BLOCK_PATTERNS[@]}"; do
  if echo "$COMMAND" | grep -qi "$pattern"; then
    echo "🚫 위험한 명령어가 차단되었습니다: [$pattern]"
    echo "   실행하려면 직접 터미널에서 입력하십시오."
    exit 2
  fi
done
