# Skills

특정 도메인·작업에 특화된 절차와 가이드를 제공하는 모듈입니다.

## 개념

Skills는 "이 작업을 어떻게 수행하는가"에 대한 구체적 절차·검증 방법을 담습니다.
점진적 공개(progressive disclosure) 방식이라, 메타데이터(name·description)만 항상
로드되고 **본문은 Claude가 관련 있다고 판단할 때만** 컨텍스트에 들어옵니다. 따라서
반복되는 체크리스트·다단계 절차는 CLAUDE.md가 아니라 여기에 둡니다.

> 커스텀 슬래시 커맨드는 Skills로 통합되었습니다. `skills/<name>/SKILL.md`는
> `/<name>`으로도 호출됩니다.

## 작성 규칙

각 스킬은 `skills/<name>/SKILL.md` 형태이며, frontmatter에 **`name`과
`description`이 필수**입니다. `description`은 Claude가 스킬을 언제 쓸지 판단하는
근거이므로 트리거 상황을 구체적으로 적습니다.

```yaml
---
name: my-skill
description: 무엇을 하는지 + 언제 트리거되는지.
---
```

## 목록

| Skill | 설명 |
|---|---|
| `commit-convention` | staged 변경을 분석해 Conventional Commits 메시지 작성 |
| `review-checklist` | 작업 완료·PR 전 위반 신호 점검 게이트 (CLAUDE.md·01~05 기반) |
| `adversarial-review` | 계획·문서·설계를 별도 세션 N개로 공격하고 판사 세션이 거른 비판만 반영 (`/adversarial-review`) |
| `daily-review` | 오늘 변경 요약 + 배포 전 확인 포인트 (`/daily-review`) |
| `create-api-be-to-fe` | Kotlin 백엔드 커밋 → TypeScript API 코드 변환 (`--hash` 필요) |
| `design-token-apply` | 디자인 토큰 변경 → sementic-tokens.json 갱신 + build 자동화 |
| `kotlin` | Kotlin 백엔드 코딩 기준·가이드 |
| `todo` | 옵시디언 볼트 데일리 할 일 관리 — 요약·추가·완료·노트·히스토리 (`/todo`) |
| `refine-commits` | 브랜치 커밋 전체를 되돌려 관심사 단위로 재구성 (`/refine-commits`, 명시 호출 전용) |
| `stibee-to-automail-template` | 스티비 자동 이메일 → 어드민 자동메일 템플릿(제목·본문 HTML) 변환·검수 (`/stibee-to-automail-template`) |

## 외부 스킬 (`vendor/`)

남이 만든 스킬은 `vendor/`에 모은다. 이 폴더는 `.claude-plugin/plugin.json`을 가진
로컬 플러그인이라 Claude Code가 제자리에서 플러그인으로 읽고, 안의 스킬은
`/vendor:<name>`으로 호출된다. 직접 만든 스킬과 이름이 겹쳐도 네임스페이스가 달라
둘 다 로드된다.

- 받은 스킬은 `vendor/skills/<name>/SKILL.md`에 **실제 파일로 복사**한다. 플러그인
  폴더 밖을 가리키는 심볼릭 링크는 Claude Code가 거부한다.
- `npx skills add … --copy`는 `~/.claude/skills/<name>`에 평평하게 떨어뜨리므로 받은
  뒤 `vendor/skills/`로 옮긴다. `-g` 기본값(심볼릭 링크)은 이 폴더가 링크 경유라
  깨진 링크를 만든다.
- 묶음째 끄려면 settings의 `enabledPlugins`에 `"vendor@skills-dir": false`.

| Skill | 출처 |
|---|---|
| `computer-use` · `orca-cli` · `orchestration` | stablyai/orca |
| `find-skills` | vercel-labs/skills |
| `vercel-react-best-practices` · `web-design-guidelines` | vercel-labs/agent-skills |
| `humanizer` (한국어판) | DaleSeo/korean-skills |
| `kordoc` | chrisryugj/kordoc (`plugins/kordoc/skills/kordoc`, 실행 시 `npx -y kordoc@<고정 버전>`) |
| `baoyu-diagram` | JimLiu/baoyu-skills (PNG 변환 스크립트는 bun 필요) |
