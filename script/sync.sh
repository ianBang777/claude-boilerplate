#!/usr/bin/env sh

set -eu

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd -P)"
BOILERPLATE_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd -P)"

# 연동할 대상 프로젝트 경로 (인자로 전달하거나 기본값 사용)
TARGET_PROJECT="${1:-${HOME}/Documents/repo/client}"
TARGET_CLAUDE_DIR="${TARGET_PROJECT}/.claude"

# sync_subdir <src_dir> <target_dir>
# src 내 항목들을 target에 per-item 심링크로 연결
sync_subdir() {
  src_dir="$1"
  target_dir="$2"

  [ -d "${src_dir}" ] || return 0

  mkdir -p "${target_dir}"

  # 소스에 없어진 스테일 심링크 제거
  for link in "${target_dir}"/*; do
    [ -L "${link}" ] || continue
    name="$(basename "${link}")"
    if [ ! -e "${src_dir}/${name}" ]; then
      rm "${link}"
      printf 'Removed stale symlink: %s\n' "${link}"
    fi
  done

  # 심링크 생성/갱신
  for src in "${src_dir}"/*; do
    [ -e "${src}" ] || continue
    name="$(basename "${src}")"
    ln -sf "${src}" "${target_dir}/${name}"
    printf 'Linked: %s\n  -> %s\n' "${target_dir}/${name}" "${src}"
  done
}

main() {
  if [ ! -d "${TARGET_PROJECT}" ]; then
    printf 'Error: 대상 프로젝트를 찾을 수 없습니다: %s\n' "${TARGET_PROJECT}" >&2
    printf '사용법: %s [프로젝트 경로]\n' "$0" >&2
    exit 1
  fi

  printf 'Syncing to: %s\n\n' "${TARGET_CLAUDE_DIR}"

  sync_subdir "${BOILERPLATE_ROOT}/skills"   "${TARGET_CLAUDE_DIR}/skills"
  sync_subdir "${BOILERPLATE_ROOT}/commands" "${TARGET_CLAUDE_DIR}/commands"
  sync_subdir "${BOILERPLATE_ROOT}/agents"   "${TARGET_CLAUDE_DIR}/agents"

  printf '\nDone.\n'
}

main "$@"
