#!/bin/bash
# Claude Code 작업 완료 시 macOS 알림

PROJECT=$(basename "$PWD")
BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "N/A")

/opt/homebrew/bin/terminal-notifier \
  -title "Claude Code" \
  -message "작업완료 ($PROJECT) → $BRANCH" \
  -sound Glass
