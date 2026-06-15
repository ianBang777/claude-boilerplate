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
| `review-uncommitted` | 커밋되지 않은 변경을 심각도 기반으로 리뷰 |
| `review-checklist` | 작업 완료·PR 전 위반 신호 점검 게이트 (00~05 규칙 기반) |
| `daily-review` | 오늘 변경 요약 + 배포 전 확인 포인트 (`/daily-review`) |
| `create-api-be-to-fe` | Kotlin 백엔드 커밋 → TypeScript API 코드 변환 (`--hash` 필요) |
| `design-token-apply` | 디자인 토큰 변경 → sementic-token.json 갱신 + build 자동화 |
| `design-system` | 디자인 시스템 구조·컴포넌트 라이브러리(Madix·Masisi) 가이드 |
| `figma-impl` | Figma URL을 받아 현재 스택에 맞게 UI 구현 |
| `kotlin` | Kotlin 백엔드 코딩 기준·가이드 |
| `support-tech-classifier` | Slack support-tech 메시지 분석 → Notion 태스크 등록 |
| `support-tech-reaction` | Slack 리액션 이벤트 처리 → Notion 태스크 업데이트 |
