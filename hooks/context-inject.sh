#!/bin/bash
# UserPromptSubmit - 매 프롬프트에 현재 컨텍스트 자동 주입

BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "N/A")
DATE=$(date "+%Y-%m-%d %H:%M (KST)")
PROJECT=$(basename "$PWD")

python3 -c "
import json
context = {
    'additionalContext': f'[자동 주입] 프로젝트: $PROJECT | 브랜치: $BRANCH | 시각: $DATE'
}
print(json.dumps(context))
"
