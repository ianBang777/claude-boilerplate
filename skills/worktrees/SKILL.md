---
name: worktrees
description: git worktree를 client 리포 외부(../worktrees)에 만들어 별도 Cursor 창으로 관리한다. 서브커맨드 create/list/sync/remove. 트리거: "/worktrees", "worktree 만들어줘", "워크트리 목록", "워크트리 동기화" 등.
---

# worktrees — git worktree 관리 (외부 폴더 + 별도 Cursor 창)

worktree를 **client 리포 밖**(`../worktrees/<folder>`)에 만들어 **별도 Cursor 창**으로 연다. 내부 `.claude/worktrees`에 두면 파일워처·인덱싱·tsserver가 복사본까지 물어 Cursor가 느려지므로 외부로 분리한다.

**드라이버**: `scripts/wt.sh` (이 skill 폴더 기준). 모든 git 작업은 이 스크립트로 수행한다.

- worktree 경로: `<client의 부모>/worktrees/<folder>` (예: `/Users/ian/Documents/repo/worktrees/`)
- 폴더명 = `A`,`B`,`C`… 알파벳 슬롯 (create 시 빈 첫 글자 자동 할당). worktree를 rebase 후 재사용하므로 브랜치명 기반 폴더명은 쓰지 않는다.
- client와 worktree는 `.git`을 공유 → 브랜치 ref가 즉시 공유됨

## 서브커맨드

스크립트 실행 시 **경로는 절대경로**로 호출한다: `bash ~/.claude/skills/worktrees/scripts/wt.sh <sub> [args]`. (실제 실행 시 `~`를 펼친 절대경로 사용.)

### `/worktrees create <브랜치명>`
현재 브랜치 기준으로 새 worktree를 **빈 알파벳 슬롯**(A,B,C…)에 만들고 `yarn install` 후 새 Cursor 창으로 연다.
```
bash ~/.claude/skills/worktrees/scripts/wt.sh create <브랜치명>
```
- 기준: **명령을 실행하는 현재 위치의 HEAD**(현재 브랜치). 다른 기준이 필요하면 먼저 그 브랜치로 checkout한 뒤 실행하도록 안내.
- 브랜치명은 사용자가 준 그대로 사용. 없으면 물어본다.

### `/worktrees list`
등록된 worktree와 각 상태(브랜치·미커밋·미푸시·develop 대비 커밋수)를 출력.
```
bash ~/.claude/skills/worktrees/scripts/wt.sh list
```

### `/worktrees sync <이름>`
worktree의 커밋을 client에서 **직접 병합할 수 있도록 브랜치를 확인/동기화**한다. **실제 merge는 하지 않는다**(사용자가 직접). `<이름>`은 폴더명(알파벳 슬롯).
```
bash ~/.claude/skills/worktrees/scripts/wt.sh sync <이름>
```
- 정상 브랜치: `.git` 공유라 client에 **이미 동일 SHA로 존재** → "준비됨" + 병합 명령 안내.
- detached HEAD: 그 커밋에 `wt-<폴더명>` 브랜치 생성.
- 스크립트가 안내한 병합 명령(`git merge <브랜치>`)은 **사용자가 직접 실행**하도록 그대로 전달한다. 이 skill이 대신 merge/push하지 않는다.
- sync 후 **worktree를 제거할지 물어본다**(그때그때 다름). 제거 원하면 `remove` 실행.

### `/worktrees remove <이름>`
worktree 작업 폴더를 제거(브랜치는 유지). 미커밋이 있으면 git이 막는다.
```
bash ~/.claude/skills/worktrees/scripts/wt.sh remove <이름> [--force]
```
- **되돌리기 어려운 작업**: 실행 전 해당 worktree에 미커밋/미푸시가 없는지 `list`로 확인하고 사용자에게 확인받는다. `--force`는 사용자가 명시 승인한 경우에만.

## 실행 규칙

- 인자(브랜치명/이름)가 없으면 추측하지 말고 물어본다.
- **파괴적 작업(remove, --force)** 전에는 상태를 보여주고 확인받는다. create/list/sync는 바로 실행 가능.
- 스크립트 출력(경로·SHA·다음 명령)을 사용자에게 그대로 요약해 전달한다.
- merge·push는 이 skill의 책임이 아니다 — 사용자가 직접 한다.
