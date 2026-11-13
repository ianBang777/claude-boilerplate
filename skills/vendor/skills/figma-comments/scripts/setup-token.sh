#!/usr/bin/env bash
#
# setup-token.sh — Figma 개인 액세스 토큰이 키체인에 있는지 확인하고, 없으면 등록한다.
#
# 사용:
#   setup-token.sh            # 있으면 "등록됨"만 알리고, 없으면 등록 절차를 진행
#   setup-token.sh --check    # 확인만 한다 (있으면 0, 없으면 2로 종료)
#   setup-token.sh --replace  # 이미 있어도 새 토큰으로 바꾼다
#
# 토큰 입력은 키체인 프롬프트로만 받는다. 터미널에서 직접 실행해야 한다
# (Claude Code 입력창에서는 앞에 ! 를 붙인다).

set -euo pipefail
source "$(dirname "$0")/_common.sh"

MODE="${1:-}"

has_token() {
  security find-generic-password -a "$USER" -s "$KEYCHAIN_SERVICE" >/dev/null 2>&1
}

if [ "$MODE" = "--check" ]; then
  if has_token; then
    echo "Figma 토큰이 키체인에 등록되어 있습니다."
    exit 0
  fi
  echo "Figma 토큰이 키체인에 없습니다. setup-token.sh 로 등록해 주세요." >&2
  exit 2
fi

if has_token && [ "$MODE" != "--replace" ]; then
  echo "Figma 토큰이 이미 키체인에 등록되어 있습니다. 바꾸려면 --replace 를 붙여 다시 실행해 주세요."
  exit 0
fi

cat <<'GUIDE'
Figma 개인 액세스 토큰을 키체인에 등록합니다.

토큰이 없다면 먼저 발급해 주세요.
  Figma → 설정(Settings) → 보안(Security) → Personal access tokens → Generate new token
  권한(scope)
    - File content: Read-only
    - Comments: Read and write   (읽기만 쓸 거면 Read-only)
  만료일을 정해 두는 것을 권합니다.
GUIDE

if [ -t 0 ]; then
  echo
  echo "아래 프롬프트에 토큰(figd_로 시작)을 붙여 넣어 주세요. 확인을 위해 한 번 더 묻습니다."
  echo "입력한 글자는 화면에 보이지 않습니다."
  # -U: 이미 있으면 덮어쓴다. -w 를 값 없이 마지막에 두면 키체인이 직접 입력을 받는다.
  security add-generic-password -U -a "$USER" -s "$KEYCHAIN_SERVICE" -l "Figma API token" -w
else
  # Claude Code 입력창의 ! 처럼 터미널 입력이 없을 때는 macOS 입력 대화상자로 받는다.
  echo
  echo "화면에 뜨는 입력창에 토큰(figd_로 시작)을 붙여 넣어 주세요. 입력한 글자는 가려집니다."
  TOKEN=$(osascript -e 'text returned of (display dialog "Figma 개인 액세스 토큰을 붙여 넣어 주세요." & return & "키체인(figma-api-token)에 저장합니다." default answer "" with hidden answer with title "Figma 토큰 등록" buttons {"취소", "저장"} default button "저장" cancel button "취소")' 2>/dev/null) || {
    echo "등록을 취소했습니다." >&2
    exit 1
  }
  TOKEN=$(printf '%s' "$TOKEN" | tr -d '[:space:]')
  # 토큰은 영문·숫자·_·- 로만 이뤄진다. 아니면 잘못 붙여 넣은 것으로 보고 멈춘다.
  if ! [[ "$TOKEN" =~ ^figd_[A-Za-z0-9_-]+$ ]]; then
    echo "토큰 형식이 아닙니다 (figd_로 시작해야 합니다). 다시 실행해 주세요." >&2
    exit 1
  fi
  # 토큰을 명령줄 인자로 넘기면 프로세스 목록에 잠깐 보이므로, security 대화형 모드에 표준 입력으로 넘긴다.
  printf 'add-generic-password -U -a "%s" -s "%s" -l "Figma API token" -w "%s"\n' "$USER" "$KEYCHAIN_SERVICE" "$TOKEN" | security -i >/dev/null
  unset TOKEN
fi

# /me 는 토큰 권한에 따라 403 이 날 수 있어, 401(토큰 자체가 무효)일 때만 실패로 본다.
load_figma_token
figma_curl GET "/me"
if [ "$HTTP_CODE" = "401" ]; then
  echo "등록은 했지만 Figma가 이 토큰을 인식하지 못했습니다 (HTTP 401). 토큰을 확인한 뒤 --replace 로 다시 등록해 주세요." >&2
  exit 1
fi
echo "등록했습니다. 실제 권한은 첫 코멘트 조회 때 확인됩니다."
