#!/usr/bin/env bash
#
# get-comments.sh — Figma 파일의 코멘트를 스레드 단위로 보여 준다.
#
# 사용:
#   get-comments.sh <파일 URL 또는 키>                     # 미해결 스레드만, 읽기 쉬운 목록
#   get-comments.sh <파일 URL 또는 키> --include-resolved  # 해결된 스레드까지
#   get-comments.sh <파일 URL 또는 키> --json              # 가공한 JSON (다른 처리에 쓸 때)
#
# 목록의 #번호는 Figma 화면에 보이는 코멘트 번호(order_id)이고, id 는 답글·삭제에 쓰는 값이다.

set -euo pipefail
source "$(dirname "$0")/_common.sh"

if [ "$#" -lt 1 ]; then
  echo "사용법: $0 <파일 URL 또는 키> [--include-resolved] [--json]" >&2
  exit 1
fi

FILE_KEY=$(to_file_key "$1"); shift
INCLUDE_RESOLVED=0
AS_JSON=0
while [ "$#" -gt 0 ]; do
  case "$1" in
    --include-resolved) INCLUDE_RESOLVED=1 ;;
    --json) AS_JSON=1 ;;
    *) echo "알 수 없는 옵션: $1" >&2; exit 1 ;;
  esac
  shift
done

load_figma_token
figma_curl GET "/files/${FILE_KEY}/comments?as_md=true"
fail_on_http_error

# 최상위 코멘트를 스레드로 보고, 답글은 parent_id 로 묶는다. 해결 여부는 최상위 코멘트 기준이다.
THREADS=$(printf '%s' "$RESP" | jq --argjson keepResolved "$INCLUDE_RESOLVED" '
  (.comments) as $all
  | [ $all[] | select((.parent_id // "") == "") ] as $roots
  | {
      threads: [
        $roots[]
        | select($keepResolved == 1 or .resolved_at == null)
        | . as $root
        | {
            id, number: .order_id, author: (.user.handle // "?"), created_at,
            resolved: (.resolved_at != null), node: (.client_meta.node_id // null),
            message,
            replies: [ $all[] | select(.parent_id == $root.id)
                       | { id, author: (.user.handle // "?"), created_at, message } ]
          }
      ] | sort_by(.created_at),
      summary: {
        total: ($roots | length),
        open: ([ $roots[] | select(.resolved_at == null) ] | length),
        resolved: ([ $roots[] | select(.resolved_at != null) ] | length)
      }
    }')

if [ "$AS_JSON" -eq 1 ]; then
  printf '%s\n' "$THREADS"
  exit 0
fi

printf '%s' "$THREADS" | jq -r '
  def kst: sub("\\.[0-9]+"; "") | fromdateiso8601 + 32400 | strftime("%Y-%m-%d %H:%M");
    "스레드 \(.summary.total)개 · 미해결 \(.summary.open)개 · 해결 \(.summary.resolved)개\n",
  (if (.threads | length) == 0 then "보여 줄 스레드가 없습니다." else empty end),
  (.threads[]
    | "#\(.number // "-")  \(.author)  \(.created_at | kst)"
      + (if .node then "  · 노드 \(.node)" else "" end)
      + (if .resolved then "  · 해결됨" else "" end)
      + "  (id \(.id))",
      (.message | split("\n") | map("    " + .) | join("\n")),
      (.replies[] | "    └ \(.author)  \(.created_at | kst)  (id \(.id))",
                    (.message | split("\n") | map("      " + .) | join("\n"))),
      "")'
