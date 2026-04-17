#!/bin/bash
# claude-boilerplate를 ~/.claude/에 심링크로 연동
#
# 사용법:
#   ./scripts/sync.sh          # 심링크 생성/갱신
#   ./scripts/sync.sh remove   # 심링크 제거

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

# 파일 심링크 생성 (기존 항목은 덮어씀)
link_file() {
  local src="$1"
  local dest="$2"

  [ -f "$src" ] || { warn "$src 없음, 건너뜁니다."; return; }
  rm -f "$dest"
  ln -s "$src" "$dest"
  info "링크: $dest -> $src"
}

# 디렉토리 심링크 생성 (기존 항목은 덮어씀)
link_dir() {
  local src="$1"
  local dest="$2"

  [ -d "$src" ] || { warn "$src 없음, 건너뜁니다."; return; }

  if [ -L "$dest" ]; then
    rm "$dest"
  elif [ -e "$dest" ]; then
    warn "$dest 가 일반 디렉토리로 존재합니다. 백업 후 교체합니다."
    mv "$dest" "${dest}.bak.$(date +%s)"
  fi

  ln -s "$src" "$dest"
  info "링크: $dest -> $src"
}

# 심링크 제거
unlink_path() {
  local dest="$1"
  if [ -L "$dest" ]; then
    rm "$dest"
    info "제거: $dest"
  fi
}

create_links() {
  mkdir -p "$CLAUDE_HOME"

  # CLAUDE.md가 존재하면 삭제 여부 확인
  if [ -L "$CLAUDE_HOME/CLAUDE.md" ] || [ -f "$CLAUDE_HOME/CLAUDE.md" ]; then
    warn "$CLAUDE_HOME/CLAUDE.md 가 존재합니다. boilerplate CLAUDE.md로 대체됩니다."
    read -p "삭제하시겠습니까? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
      rm -f "$CLAUDE_HOME/CLAUDE.md"
      info "제거: $CLAUDE_HOME/CLAUDE.md"
    else
      info "CLAUDE.md 유지."
    fi
  fi

  # CLAUDE.md 심링크
  link_file "$BOILERPLATE_DIR/CLAUDE.md" "$CLAUDE_HOME/CLAUDE.md"

  # 각 디렉토리 심링크
  link_dir "$BOILERPLATE_DIR/agents"   "$CLAUDE_HOME/agents"
  link_dir "$BOILERPLATE_DIR/commands" "$CLAUDE_HOME/commands"
  link_dir "$BOILERPLATE_DIR/skills"   "$CLAUDE_HOME/skills"
  link_dir "$BOILERPLATE_DIR/rules"    "$CLAUDE_HOME/rules"
  link_dir "$BOILERPLATE_DIR/hooks"    "$CLAUDE_HOME/hooks"

  # settings.json: ${PROJECT_ROOT}를 실제 경로로 치환해서 복사
  local settings_src="$BOILERPLATE_DIR/settings.json"
  local settings_dest="$CLAUDE_HOME/settings.json"

  if [ -f "$settings_src" ]; then
    sed "s|\${PROJECT_ROOT}|$BOILERPLATE_DIR|g" "$settings_src" > "$settings_dest"
    info "settings.json 생성 (PROJECT_ROOT=$BOILERPLATE_DIR)"
  else
    warn "settings.json 없음, 건너뜁니다."
  fi

  echo
  info "동기화 완료."
  info "  CLAUDE.md -> $CLAUDE_HOME/CLAUDE.md"
  info "  agents    -> $CLAUDE_HOME/agents"
  info "  commands  -> $CLAUDE_HOME/commands"
  info "  skills    -> $CLAUDE_HOME/skills"
  info "  rules     -> $CLAUDE_HOME/rules"
  info "  hooks     -> $CLAUDE_HOME/hooks"
  info "  settings.json (복사, PROJECT_ROOT 치환됨)"
}

remove_links() {
  unlink_path "$CLAUDE_HOME/CLAUDE.md"
  unlink_path "$CLAUDE_HOME/agents"
  unlink_path "$CLAUDE_HOME/commands"
  unlink_path "$CLAUDE_HOME/skills"
  unlink_path "$CLAUDE_HOME/rules"
  unlink_path "$CLAUDE_HOME/hooks"
  info "심링크 제거 완료."
}

if [ "${1:-}" = "remove" ]; then
  remove_links
else
  create_links
fi
