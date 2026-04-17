#!/bin/bash
# settings.json의 ${PROJECT_ROOT}를 실제 경로로 치환하여 .claude/settings.json 생성

PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SETTINGS_SRC="$PROJECT_ROOT/settings.json"
SETTINGS_DEST="$PROJECT_ROOT/.claude/settings.json"

mkdir -p "$PROJECT_ROOT/.claude"

sed "s|\${PROJECT_ROOT}|$PROJECT_ROOT|g" "$SETTINGS_SRC" > "$SETTINGS_DEST"

echo "✓ .claude/settings.json 생성 완료"
echo "  PROJECT_ROOT: $PROJECT_ROOT"
