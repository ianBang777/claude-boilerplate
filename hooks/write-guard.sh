#!/bin/bash
# PreToolUse (Write/Edit) - 프로젝트 외부 경로 파일 쓰기 차단

INPUT=$(cat)

FILE_PATH=$(echo "$INPUT" | python3 -c "
import sys, json
d = json.load(sys.stdin)
inp = d.get('tool_input', {})
# Write tool: file_path, Edit tool: file_path
print(inp.get('file_path', ''))
" 2>/dev/null)

if [ -z "$FILE_PATH" ]; then
  exit 0
fi

# 절대 경로로 변환
ABS_PATH=$(realpath "$FILE_PATH" 2>/dev/null || echo "$FILE_PATH")
PROJECT_DIR=$(pwd)

# 프로젝트 디렉토리 하위가 아닌 경우 차단
# 단, ~/.claude/ 경로는 설정 파일이므로 허용
if [[ "$ABS_PATH" != "$PROJECT_DIR"* ]] && [[ "$ABS_PATH" != "$HOME/.claude"* ]]; then
  echo "🚫 프로젝트 외부 경로에 대한 쓰기가 차단되었습니다: $ABS_PATH"
  echo "   현재 프로젝트: $PROJECT_DIR"
  exit 2
fi
