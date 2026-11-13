#!/usr/bin/env bash
#
# post-comment.sh — 코멘트를 단다. 파일 전체, 특정 노드에 고정, 기존 스레드 답글 중 하나.
#
# 사용:
#   post-comment.sh <파일 URL 또는 키> "<내용>"
#   post-comment.sh <파일 URL 또는 키> "<내용>" --node 695:313 [--x 40 --y 12]
#   post-comment.sh <파일 URL 또는 키> "<내용>" --reply <스레드 id>
#
# 디자이너에게 바로 보이는 작업이므로, 실행 전에 내용을 사용자에게 보여 주고 확인을 받는다.
# @이름 은 Figma 화면에서만 동작하는 멘션이라, API로 넣으면 글자로만 남고 알림이 가지 않는다.

set -euo pipefail
source "$(dirname "$0")/_common.sh"

if [ "$#" -lt 2 ]; then
  echo "사용법: $0 <파일 URL 또는 키> \"<내용>\" [--node <노드 id> [--x N] [--y N]] [--reply <스레드 id>]" >&2
  exit 1
fi

FILE_KEY=$(to_file_key "$1"); shift
MESSAGE="$1"; shift
NODE_ID=""; X=0; Y=0; REPLY_TO=""
while [ "$#" -gt 0 ]; do
  case "$1" in
    --node) NODE_ID="$2"; shift 2 ;;
    --x) X="$2"; shift 2 ;;
    --y) Y="$2"; shift 2 ;;
    --reply) REPLY_TO="$2"; shift 2 ;;
    *) echo "알 수 없는 옵션: $1" >&2; exit 1 ;;
  esac
done

# 노드에 고정할 때 Figma는 node_offset 을 반드시 요구한다. 기본값은 노드 왼쪽 위(0,0).
BODY=$(jq -n --arg message "$MESSAGE" --arg node "$NODE_ID" --argjson x "$X" --argjson y "$Y" --arg reply "$REPLY_TO" '
  { message: $message }
  + (if $node != "" then { client_meta: { node_id: $node, node_offset: { x: $x, y: $y } } } else {} end)
  + (if $reply != "" then { comment_id: $reply } else {} end)')

load_figma_token
figma_curl POST "/files/${FILE_KEY}/comments" "$BODY"
fail_on_http_error

printf '%s' "$RESP" | jq -r '"코멘트를 달았습니다. #\(.order_id // "-") (id \(.id))"'
