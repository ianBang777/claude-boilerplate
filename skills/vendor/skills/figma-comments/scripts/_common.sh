#!/usr/bin/env bash
#
# 다른 스크립트가 source 해서 쓰는 공통 함수.
# 토큰은 macOS 키체인에서만 읽고, 화면·파일·명령줄 인자에 남기지 않는다.

KEYCHAIN_SERVICE="figma-api-token"
FIGMA_API="https://api.figma.com/v1"

# 키체인에서 토큰을 꺼낸다. 없으면 등록 방법을 안내하고 종료 코드 2로 끝낸다.
load_figma_token() {
  FIGMA_TOKEN=$(security find-generic-password -a "$USER" -s "$KEYCHAIN_SERVICE" -w 2>/dev/null || true)
  if [ -z "$FIGMA_TOKEN" ]; then
    {
      echo "Figma 토큰이 키체인에 없습니다."
      echo "터미널에서 아래 명령으로 먼저 등록해 주세요 (Claude Code 입력창이면 앞에 ! 를 붙입니다)."
      echo "  bash $(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/setup-token.sh"
    } >&2
    exit 2
  fi
}

# Figma URL 또는 파일 키를 받아 파일 키만 돌려준다.
to_file_key() {
  echo "$1" | sed -E 's#.*/(design|file|board)/([A-Za-z0-9]+).*#\2#'
}

# curl 호출. 토큰을 명령줄 인자 대신 표준 입력 설정으로 넘겨 프로세스 목록에 보이지 않게 한다.
# 사용: figma_curl <메서드> <경로> [JSON 본문]
# 응답 본문은 RESP, HTTP 상태 코드는 HTTP_CODE 전역 변수에 담는다.
# $(...) 로 감싸 부르면 서브셸이라 HTTP_CODE 가 사라지므로 그냥 호출한다.
figma_curl() {
  local method="$1" path="$2" body="${3:-}"
  local out
  out=$(mktemp)
  local args=(-s -o "$out" -w '%{http_code}' -X "$method" --config -)
  if [ -n "$body" ]; then
    args+=(-H "Content-Type: application/json" --data-binary "$body")
  fi
  HTTP_CODE=$(printf 'header = "X-Figma-Token: %s"\n' "$FIGMA_TOKEN" | curl "${args[@]}" "${FIGMA_API}${path}")
  RESP=$(cat "$out")
  rm -f "$out"
}

# HTTP 오류를 한국어로 풀어 보여 주고 종료한다.
fail_on_http_error() {
  local resp="$RESP"
  case "$HTTP_CODE" in
    200|204) return 0 ;;
    401|403)
      echo "Figma가 요청을 거부했습니다 (HTTP ${HTTP_CODE})." >&2
      echo "토큰이 만료됐거나, 이 작업에 필요한 권한(Comments 읽기/쓰기, File content 읽기)이 없습니다." >&2
      echo "토큰을 다시 발급해 setup-token.sh --replace 로 바꿔 주세요." >&2 ;;
    404)
      echo "파일이나 코멘트를 찾지 못했습니다 (HTTP 404). 파일 키·코멘트 id를 확인해 주세요." >&2 ;;
    429)
      echo "요청이 너무 많아 Figma가 잠시 막았습니다 (HTTP 429). 잠시 후 다시 시도해 주세요." >&2 ;;
    *)
      echo "Figma API 오류 (HTTP ${HTTP_CODE}): $(printf '%s' "$resp" | jq -r '.err // .message // "알 수 없음"' 2>/dev/null)" >&2 ;;
  esac
  exit 1
}
