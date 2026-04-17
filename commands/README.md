# Commands

SlashCommand로 직접 호출 가능한 명령어들입니다.

## 개념

Commands는 사용자가 `/command` 형식으로 직접 호출할 수 있는 빠른 실행 명령입니다.
에이전트 파이프라인을 거치지 않고 현재 세션에서 즉시 실행됩니다.

## 목록

| Command | 설명 |
|---|---|
| `/design-token-apply` | 디자인 토큰 변경 시 sementic-token.json 업데이트 및 빌드 자동화 |
| `/figma-impl <url>` | Figma URL로 디자인 컨텍스트를 받아 현재 프로젝트 스택에 맞게 UI 구현 |
| `/init-project` | 새 프로젝트 코드베이스를 분석하고 CLAUDE.md 자동 생성 |
| `/daily-review` | 오늘 변경사항 요약 및 배포 전 확인 포인트 정리 |
| `/create-api-be-to-fe --hash <hash>` | Kotlin 백엔드 커밋 기준으로 TypeScript API 코드 자동 변환 |

## Agents vs Commands

| 측면 | Agents | Commands |
|---|---|---|
| 호출 방식 | Task 도구 (Orchestrator/Secretary가 호출) | SlashCommand (사용자 직접 호출) |
| 실행 컨텍스트 | 독립 컨텍스트 | 현재 세션 |
| 파이프라인 | 에이전트 파이프라인의 일부 | 독립 실행 |
| 사용 시점 | 복잡한 작업 (계획 필요) | 반복적·즉시 실행 작업 |
