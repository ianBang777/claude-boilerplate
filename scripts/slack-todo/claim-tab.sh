#!/bin/bash
# Orca 자동화 `슬랙 → 투두 제안`이 실행 첫 단계에서 부른다.
# 자동화는 매일 새 세션으로 뜨고 triage 질문에서 답을 기다리므로, 답하지 못한 전날
# 세션이 탭으로 쌓인다. 제안은 TodoList에 누적돼 있어 전날 탭을 닫아도 잃는 것이 없다.
# --reuse-session 대신 이렇게 하는 이유: 전날 세션이 질문 창을 띄운 채 살아 있으면
# 다음날 프롬프트가 그 입력칸으로 들어간다.
# 탭 제목으로 고르지 않는 이유: CLI로 바꾼 제목은 Claude가 설정하는 창 제목에 가려
# `terminal list`에 드러나지 않는다. 직전 실행이 남긴 핸들 하나만 닫는다.
set -euo pipefail

ORCA=/Applications/Orca.app/Contents/Resources/bin/orca
STATE_FILE="$HOME/.local/state/slack-todo/last-terminal-handle"
DRY_RUN=${1:-}

: "${ORCA_TERMINAL_HANDLE:?Orca 터미널 안에서만 실행한다}"

previous_handle=$(cat "$STATE_FILE" 2>/dev/null || true)

is_live() {
  "$ORCA" terminal list --json | HANDLE="$1" python3 -c '
import json, os, sys
terminals = json.load(sys.stdin)["result"]["terminals"]
sys.exit(0 if any(t["handle"] == os.environ["HANDLE"] for t in terminals) else 1)
'
}

if [ -n "$previous_handle" ] && [ "$previous_handle" != "$ORCA_TERMINAL_HANDLE" ] && is_live "$previous_handle"; then
  if [ "$DRY_RUN" = "--dry-run" ]; then
    echo "닫을 예정: $previous_handle"
  else
    "$ORCA" terminal close --terminal "$previous_handle" --tab >/dev/null
    echo "닫음: $previous_handle"
  fi
else
  echo "닫을 이전 탭 없음"
fi

if [ "$DRY_RUN" != "--dry-run" ]; then
  mkdir -p "$(dirname "$STATE_FILE")"
  echo "$ORCA_TERMINAL_HANDLE" > "$STATE_FILE"
fi
