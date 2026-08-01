#!/usr/bin/env bash
#
# wt.sh — git worktree 관리 (client 리포 외부 + 별도 Cursor 창)
#
# 사용: wt.sh <create|list|sync|remove> [args]
#
# 설계:
#   - worktree는 client 리포 밖 형제 폴더(../worktrees/<folder>)에 생성한다.
#     (내부 .claude/worktrees는 파일워처/tsserver 부하로 Cursor를 느리게 함)
#   - 폴더명은 브랜치명의 "/"를 "-"로 치환한 값.
#   - client와 worktree는 .git을 공유하므로 브랜치 ref가 즉시 공유된다.
#
set -euo pipefail

# --- 공통: 메인(client) 리포 루트와 worktree 베이스 경로 해석 ---
# git-common-dir는 linked worktree에서도 항상 메인 .git을 가리킨다.
MAIN_ROOT="$(cd "$(dirname "$(git rev-parse --git-common-dir)")" && pwd)"
WT_BASE="${WT_BASE:-"$(dirname "$MAIN_ROOT")/worktrees"}"

die() { echo "❌ $*" >&2; exit 1; }

# 브랜치명 → 폴더명
folder_of() { echo "${1//\//-}"; }

# 이름(브랜치명 또는 폴더명) → worktree 절대경로
path_of() {
  local name="$1"
  local folder; folder="$(folder_of "$name")"
  echo "$WT_BASE/$folder"
}

cmd_create() {
  local branch="${1:-}"
  [ -n "$branch" ] || die "브랜치명이 필요합니다. 사용: wt.sh create <브랜치명>"

  # 현재(cwd) 브랜치 기준으로 새 브랜치 생성
  local start_point start_branch
  start_point="$(git rev-parse HEAD)"
  start_branch="$(git rev-parse --abbrev-ref HEAD)"

  local path; path="$(path_of "$branch")"
  [ -e "$path" ] && die "이미 존재하는 경로: $path"
  git -C "$MAIN_ROOT" show-ref --verify --quiet "refs/heads/$branch" \
    && die "이미 존재하는 브랜치: $branch"

  mkdir -p "$WT_BASE"
  echo "▶ worktree 생성: $branch  (기준: $start_branch @ ${start_point:0:9})"
  git -C "$MAIN_ROOT" worktree add -b "$branch" "$path" "$start_point"

  echo "▶ 의존성 설치: yarn install"
  ( cd "$path" && yarn install )

  echo "✅ 생성 완료: $path"
  if command -v cursor >/dev/null 2>&1; then
    echo "▶ 새 Cursor 창으로 열기"
    cursor "$path"
  else
    echo "   Cursor로 열기:  cursor \"$path\""
  fi
}

cmd_list() {
  echo "== worktree 목록 (base: $WT_BASE) =="
  local line path branch dirty unpushed ahead
  git -C "$MAIN_ROOT" worktree list --porcelain \
    | awk '/^worktree /{print $2}' \
    | while read -r path; do
        [ -d "$path" ] || continue
        branch="$(git -C "$path" rev-parse --abbrev-ref HEAD 2>/dev/null || echo '?')"
        [ "$branch" = "HEAD" ] && branch="(detached $(git -C "$path" rev-parse --short HEAD 2>/dev/null))"
        dirty="$(git -C "$path" status --porcelain 2>/dev/null | grep -c '' || true)"
        if git -C "$path" rev-parse --verify --quiet '@{u}' >/dev/null 2>&1; then
          unpushed="$(git -C "$path" rev-list --count '@{u}..HEAD' 2>/dev/null || echo '-')"
        else
          unpushed="-"
        fi
        if git -C "$MAIN_ROOT" show-ref --verify --quiet refs/heads/develop; then
          ahead="$(git -C "$path" rev-list --count develop..HEAD 2>/dev/null || echo '-')"
        else
          ahead="-"
        fi
        printf "  %-45s %-30s 미커밋=%s 미푸시=%s develop대비+%s\n" \
          "${path/#$HOME/~}" "$branch" "$dirty" "$unpushed" "$ahead"
      done
}

# sync: worktree의 커밋을 client에서 바로 병합할 수 있게 브랜치를 확인/생성한다.
#   - 정상 브랜치: .git 공유라 client에 이미 존재 → 준비 완료 안내
#   - detached HEAD: 해당 커밋에 브랜치를 생성
#   실제 merge는 사용자가 직접 수행한다.
cmd_sync() {
  local name="${1:-}"
  [ -n "$name" ] || die "worktree 이름이 필요합니다. 사용: wt.sh sync <이름>"
  local path; path="$(path_of "$name")"
  [ -d "$path" ] || die "worktree 없음: $path"

  local wt_branch wt_head short
  wt_branch="$(git -C "$path" rev-parse --abbrev-ref HEAD)"
  wt_head="$(git -C "$path" rev-parse HEAD)"
  short="${wt_head:0:9}"

  local dirty; dirty="$(git -C "$path" status --porcelain | wc -l | tr -d ' ')"
  [ "$dirty" != "0" ] && echo "⚠ worktree에 미커밋 변경 $dirty건 — 커밋해야 sync에 반영됩니다."

  if [ "$wt_branch" = "HEAD" ]; then
    # detached: 폴더명으로 브랜치 생성
    local newb; newb="$(folder_of "$name")"
    git -C "$MAIN_ROOT" show-ref --verify --quiet "refs/heads/$newb" \
      && die "detached HEAD인데 브랜치 '$newb'가 이미 존재합니다. 다른 이름으로 처리하세요."
    git -C "$MAIN_ROOT" branch "$newb" "$wt_head"
    echo "✅ detached HEAD($short)에 브랜치 생성: $newb"
    wt_branch="$newb"
  else
    # 정상 브랜치: 공유 .git이라 client에 이미 존재
    local main_sha; main_sha="$(git -C "$MAIN_ROOT" rev-parse --verify "$wt_branch" 2>/dev/null || echo '')"
    if [ "$main_sha" = "$wt_head" ]; then
      echo "✅ client에 브랜치 '$wt_branch' ($short) 이미 동기화됨 (동일 SHA)."
    else
      echo "⚠ client의 '$wt_branch'가 worktree HEAD와 다릅니다 (client=${main_sha:0:9} vs wt=$short)."
    fi
  fi

  echo
  echo "── 다음: client에서 직접 병합 ──"
  echo "  cd \"$MAIN_ROOT\""
  echo "  git checkout develop && git pull"
  echo "  git merge $wt_branch"
}

cmd_remove() {
  local name="${1:-}"; local force="${2:-}"
  [ -n "$name" ] || die "worktree 이름이 필요합니다. 사용: wt.sh remove <이름> [--force]"
  local path; path="$(path_of "$name")"
  [ -d "$path" ] || die "worktree 없음: $path"

  if [ "$force" = "--force" ]; then
    git -C "$MAIN_ROOT" worktree remove --force "$path"
  else
    git -C "$MAIN_ROOT" worktree remove "$path"
  fi
  echo "✅ worktree 제거: $path (브랜치는 유지됨)"
}

sub="${1:-}"; shift || true
case "$sub" in
  create) cmd_create "$@" ;;
  list)   cmd_list "$@" ;;
  sync)   cmd_sync "$@" ;;
  remove) cmd_remove "$@" ;;
  *) die "알 수 없는 명령: '$sub'. 사용: wt.sh <create|list|sync|remove>" ;;
esac
