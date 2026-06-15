#!/bin/bash
# claude-boilerplate 연동을 해제하는 스크립트
#
# scripts/sync.sh가 생성한 심링크와 settings.json 복사본을 제거한다.
# 우리 보일러플레이트를 가리키는 심링크만 제거하며,
# 다른 곳을 가리키거나 일반 파일/디렉토리인 경우에는 건드리지 않는다.
#
# 사용법:
#   ./scripts/unsync.sh

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BOILERPLATE_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
CLAUDE_HOME="$HOME/.claude"

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

info()  { echo -e "${GREEN}[INFO]${NC}  $1"; }
warn()  { echo -e "${YELLOW}[WARN]${NC}  $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; }

# 심링크가 보일러플레이트를 가리키는 경우에만 제거
# 일반 파일/디렉토리이거나 다른 곳을 가리키면 경고 출력
safe_unlink() {
  local dest="$1"
  local label="$2"

  if [ ! -e "$dest" ] && [ ! -L "$dest" ]; then
    info "$label: 존재하지 않음, 건너뜁니다."
    return
  fi

  if [ -L "$dest" ]; then
    local link_target
    link_target="$(readlink "$dest")"
    # 보일러플레이트 경로를 가리키는 심링크인지 확인
    if [[ "$link_target" == "$BOILERPLATE_DIR"* ]]; then
      rm "$dest"
      info "제거: $dest -> $link_target"
    else
      warn "$dest 는 다른 경로를 가리킵니다 ($link_target). 건드리지 않습니다."
    fi
  else
    warn "$dest 는 일반 파일/디렉토리입니다. 건드리지 않습니다."
  fi
}

# settings.json 제거 (사용자 확인 후)
remove_settings() {
  local settings_dest="$CLAUDE_HOME/settings.json"

  if [ ! -f "$settings_dest" ]; then
    info "settings.json: 존재하지 않음, 건너뜁니다."
    return
  fi

  read -p "  $settings_dest 를 제거하시겠습니까? (y/N): " -n 1 -r
  echo
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    rm -f "$settings_dest"
    info "제거: $settings_dest"
  else
    info "settings.json 유지."
  fi
}

# sync.sh link_dir이 생성한 .bak.<timestamp> 백업 디렉토리를 감지하고 경로를 안내
notify_backups() {
  local targets=(
    "$CLAUDE_HOME/agents"
    "$CLAUDE_HOME/commands"
    "$CLAUDE_HOME/skills"
    "$CLAUDE_HOME/rules"
    "$CLAUDE_HOME/hooks"
  )

  for dest in "${targets[@]}"; do
    # ${dest}.bak.<숫자> 패턴 검색 (타임스탬프는 Unix epoch 숫자)
    local backups=()
    while IFS= read -r -d '' bak; do
      backups+=("$bak")
    done < <(find "$CLAUDE_HOME" -maxdepth 1 -name "$(basename "$dest").bak.*" -print0 2>/dev/null)

    if [ ${#backups[@]} -eq 0 ]; then
      continue
    fi

    echo
    warn "백업이 남아있습니다: $(basename "$dest")"
    for bak in "${backups[@]}"; do
      info "  백업 경로: $bak"
    done
    info "  필요 시 수동으로 복원하세요: mv <백업경로> $dest"
  done
}

echo
info "===== claude-boilerplate 연동 해제 시작 ====="
info "  BOILERPLATE_DIR: $BOILERPLATE_DIR"
info "  CLAUDE_HOME:     $CLAUDE_HOME"
echo

# 1. 심링크 제거 (보일러플레이트를 가리키는 경우에만)
safe_unlink "$CLAUDE_HOME/CLAUDE.md" "CLAUDE.md"
safe_unlink "$CLAUDE_HOME/agents"    "agents"
safe_unlink "$CLAUDE_HOME/commands"  "commands"
safe_unlink "$CLAUDE_HOME/skills"    "skills"
safe_unlink "$CLAUDE_HOME/rules"     "rules"
safe_unlink "$CLAUDE_HOME/hooks"     "hooks"

echo

# 2. settings.json 제거 (사용자 확인)
info "settings.json 처리:"
remove_settings

# 3. 백업 감지 및 경로 안내 (복원은 수동으로 처리)
notify_backups

echo
info "===== 연동 해제 완료 ====="
