#!/bin/bash
# ~/.claude/ 초기화 후 boilerplate 동기화
#
# 사용법:
#   ./scripts/init.sh        # 초기화 후 sync
#   ./scripts/init.sh --dry  # 실제 삭제 없이 대상 목록만 출력

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_HOME="$HOME/.claude"
DRY_RUN=false

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

info()  { echo -e "${GREEN}[INFO]${NC}  $1"; }
warn()  { echo -e "${YELLOW}[WARN]${NC}  $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; }

[ "${1:-}" = "--dry" ] && DRY_RUN=true

# sync.sh가 관리하는 항목
MANAGED_NAMES=(CLAUDE.md agents commands skills rules hooks settings.json)

# ── 1. 초기화 대상 수집 ──────────────────────────────────────────────────────

targets=()

# 관리 항목 (symlink·파일·디렉토리 모두)
for name in "${MANAGED_NAMES[@]}"; do
  path="$CLAUDE_HOME/$name"
  [ -e "$path" ] || [ -L "$path" ] && targets+=("$path")
done

# sync.sh가 생성한 .bak.* 찌꺼기 (관리 항목 이름 기반)
while IFS= read -r -d '' bak; do
  targets+=("$bak")
done < <(find "$CLAUDE_HOME" -maxdepth 1 \( -name "*.bak.*" \) -print0 2>/dev/null)

# ── 2. 대상 출력 ─────────────────────────────────────────────────────────────

if [ ${#targets[@]} -eq 0 ]; then
  info "초기화할 항목이 없습니다."
  exit 0
fi

echo
warn "다음 항목을 삭제합니다:"
for t in "${targets[@]}"; do
  if [ -L "$t" ]; then
    echo "  [symlink] $t -> $(readlink "$t")"
  elif [ -d "$t" ]; then
    echo "  [dir]     $t"
  else
    echo "  [file]    $t"
  fi
done
echo

if $DRY_RUN; then
  info "--dry 모드: 실제 삭제하지 않습니다."
  exit 0
fi

# ── 3. 확인 ──────────────────────────────────────────────────────────────────

read -p "계속하시겠습니까? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
  info "취소되었습니다."
  exit 0
fi

# ── 4. 삭제 ──────────────────────────────────────────────────────────────────

for t in "${targets[@]}"; do
  if [ -L "$t" ] || [ -f "$t" ]; then
    rm -f "$t" && info "삭제: $t"
  elif [ -d "$t" ]; then
    rm -rf "$t" && info "삭제: $t"
  fi
done

# ── 5. sync 실행 ──────────────────────────────────────────────────────────────

echo
info "sync.sh 실행 중..."
bash "$SCRIPT_DIR/sync.sh"
