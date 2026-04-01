#!/usr/bin/env sh

set -eu

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd -P)"
BOILERPLATE_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd -P)"

# 인자가 있으면 해당 프로젝트의 .claude, 없으면 전역 ~/.claude
if [ $# -gt 0 ]; then
  TARGET_PROJECT="$1"
  TARGET_CLAUDE_DIR="${TARGET_PROJECT}/.claude"
else
  TARGET_PROJECT=""
  TARGET_CLAUDE_DIR="${HOME}/.claude"
fi

# unsync_subdir <src_dir> <target_dir>
# target 내 항목 중 src를 가리키는 심링크만 제거
unsync_subdir() {
  src_dir="$1"
  target_dir="$2"

  [ -d "${target_dir}" ] || return 0

  for link in "${target_dir}"/*; do
    [ -L "${link}" ] || continue
    dest="$(readlink "${link}")"
    case "${dest}" in
      "${src_dir}/"*)
        rm "${link}"
        printf 'Removed: %s\n' "${link}"
        ;;
    esac
  done
}

main() {
  if [ -n "${TARGET_PROJECT}" ] && [ ! -d "${TARGET_PROJECT}" ]; then
    printf 'Error: 대상 프로젝트를 찾을 수 없습니다: %s\n' "${TARGET_PROJECT}" >&2
    printf '사용법: %s [프로젝트 경로]\n' "$0" >&2
    exit 1
  fi

  printf 'Unsyncing from: %s\n\n' "${TARGET_CLAUDE_DIR}"

  unsync_subdir "${BOILERPLATE_ROOT}/skills"   "${TARGET_CLAUDE_DIR}/skills"
  unsync_subdir "${BOILERPLATE_ROOT}/commands" "${TARGET_CLAUDE_DIR}/commands"
  unsync_subdir "${BOILERPLATE_ROOT}/agents"   "${TARGET_CLAUDE_DIR}/agents"

  printf '\nDone.\n'
}

main "$@"
