# CLAUDE.md

## Communication

- 모든 응답은 한국어로 작성한다.
- 응답 길이는 작업 성격에 맞게 조정한다 (코드 작업: 간결, 논의: 상세).
- 불필요한 인사말, 감탄사 생략한다.

---

## Task Process

**시작 전**:
1. 즉시 실행하지 않고 문제 정의, 목표, 방법, 불확실한 점을 먼저 정리한다.
2. 문제, 목표가 확실해질 때까지 확인한다.
3. 계획 확인 후 실행한다.

**완료 후**:
1. 작업 내용을 요약 보고한다.
2. 사용자에게 보고서 작성 여부를 확인한다.



작업 시 아래 공용 규칙을 항상 따른다. 충돌 시 우선순위는
[.claude/rules/README.md](./.claude/rules/README.md)를 따른다.

- @.claude/rules/00-agent-harness.md — 작업 방식 (최상위)
- @.claude/rules/01-general-engineering.md — 일반 개발 기본기
- @.claude/rules/02-oop-design.md — 객체지향 · 설계
- @.claude/rules/03-tdd.md — 테스트 주도 개발
- @.claude/rules/04-frontend.md — 프론트엔드
- @.claude/rules/05-typescript.md — TypeScript 기본 규칙
- @.claude/rules/06-review-checklist.md — 완료 게이트 (리뷰 체크리스트)