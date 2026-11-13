#!/usr/bin/env bash
#
# delete-comment.sh — 코멘트를 지운다. 되돌릴 수 없다.
#
# 사용:
#   delete-comment.sh <파일 URL 또는 키> <코멘트 id>          # 지울 대상만 보여 주고 멈춘다
#   delete-comment.sh <파일 URL 또는 키> <코멘트 id> --yes    # 사용자가 확인한 뒤에만 실행
#
# --yes 없이 부르면 아무것도 지우지 않고 대상(작성자·내용·딸린 답글 수)만 출력한 뒤 종료 코드 3으로 끝난다.
# 최상위 코멘트를 지우면 딸린 답글까지 스레드 전체가 사라진다.

set -euo pipefail
source "$(dirname "$0")/_common.sh"

if [ "$#" -lt 2 ]; then
  echo "사용법: $0 <파일 URL 또는 키> <코멘트 id> [--yes]" >&2
  exit 1
fi

FILE_KEY=$(to_file_key "$1")
COMMENT_ID="$2"
CONFIRMED=0
[ "${3:-}" = "--yes" ] && CONFIRMED=1

load_figma_token
figma_curl GET "/files/${FILE_KEY}/comments?as_md=true"
fail_on_http_error

TARGET=$(printf '%s' "$RESP" | jq --arg id "$COMMENT_ID" '
  (.comments) as $all
  | ($all[] | select(.id == $id)) as $c
  | { number: $c.order_id, author: ($c.user.handle // "?"), created_at: $c.created_at,
      is_reply: (($c.parent_id // "") != ""), message: $c.message,
      replies: ([ $all[] | select(.parent_id == $id) ] | length) }' 2>/dev/null || true)

if [ -z "$TARGET" ]; then
  echo "id ${COMMENT_ID} 코멘트가 이 파일에 없습니다. get-comments.sh 로 id를 다시 확인해 주세요." >&2
  exit 1
fi

printf '%s' "$TARGET" | jq -r '
  def kst: sub("\\.[0-9]+"; "") | fromdateiso8601 + 32400 | strftime("%Y-%m-%d %H:%M");
    "지울 코멘트",
  "  " + (if .is_reply then "답글" else "#\(.number // "-") 스레드" end) + "  \(.author)  \(.created_at | kst)",
  (.message | split("\n") | map("    " + .) | join("\n")),
  (if .replies > 0 then "  이 스레드의 답글 \(.replies)개도 함께 지워집니다." else empty end)'

if [ "$CONFIRMED" -ne 1 ]; then
  echo
  echo "아직 지우지 않았습니다. 사용자 확인을 받은 뒤 --yes 를 붙여 다시 실행해 주세요."
  exit 3
fi

figma_curl DELETE "/files/${FILE_KEY}/comments/${COMMENT_ID}"
fail_on_http_error
echo "지웠습니다."
