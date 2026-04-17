---
tags: ["task", "agents"]
applies_to: ["agents"]
---

# Task 실행 규칙

Task 도구를 사용하여 서브에이전트를 호출할 때 따라야 할 규칙입니다.
모든 에이전트(Secretary, Strategist, Plan-Reviewer, Worker, Reviewer)가 준수합니다.

---

## Task 도구 사용 원칙

### 독립된 컨텍스트 실행
- 각 서브에이전트는 **별도 Task로 호출** (분리가 핵심)
- 이전 대화 내역을 포함하지 않음
- 파일 기반 통신으로만 정보 전달

**왜 중요한가?**:
- "만드는 AI"와 "평가하는 AI" 완전 분리
- 자기평가의 편향 제거
- 컨텍스트 오염 방지

### 필수 파일 읽기 지시

**Task 프롬프트 구조**:
```
subagent_type: "general-purpose"
description: "[작업 요약]"
prompt: |
  1. agents/[agent-name].md 파일을 읽고 역할을 파악하라.
  2. rules/core-principles.md 파일을 읽고 공통 원칙을 따라라.
  3. [필요한 입력 파일]을 읽어라.
  4. [작업 수행]
  5. 결과를 [출력 파일]에 저장하라.
```

**필수 요소**:
- ✅ 에이전트 정의 파일 읽기 (`agents/[name].md`)
- ✅ 공통 원칙 읽기 (`rules/core-principles.md`)
- ✅ 입력 파일 지정 (SPEC.md, PLAN.md 등)
- ✅ 출력 파일 지정 (명시적으로)

---

## 파일 기반 통신

### 통신 파일 목록

| 파일 | 생성자 | 내용 | 다음 단계 |
|------|--------|------|----------|
| **SPEC.md** | Strategist | 문제 분석, 접근 방법, 실행 계획 | Plan-Reviewer → Worker |
| **PLAN.md** | Plan-Reviewer | 승인/재수립 판정, 피드백 | Secretary 판정 |
| **WORK_LOG.md** | Worker | 작업 결과물, 변경 파일 목록, 주의사항 | Reviewer |
| **QA_REPORT.md** | Reviewer | 품질 검토 결과, 승인/재작업 판정 | Secretary 판정 |

### 파일 읽기/쓰기 규칙

**읽기**:
- Task 호출 시 필요한 파일만 읽도록 지시
- 전체 대화 내역 포함 금지 (컨텍스트 비용 절감)

**쓰기**:
- 각 에이전트는 **자신의 출력 파일만 작성**
- 덮어쓰기 전 기존 파일 확인 (재작업 시)
- 명확한 구조 (Markdown 형식)

**예시**:
```
잘못된 지시:
"SPEC.md를 참고해서 작업하라" ← 파일 읽기 누락

올바른 지시:
"SPEC.md 파일을 읽어라. 이것이 실행할 계획이다." ← 명시적 읽기 지시
```

---

## 단계 완료 후 검증

### Secretary 체크리스트

각 Task 완료 후:
1. **파일 존재 확인**:
   ```bash
   ls SPEC.md  # 또는 PLAN.md, WORK_LOG.md, QA_REPORT.md
   ```

2. **파일 내용 읽기**:
   - 예상 형식대로 작성되었는가?
   - 필수 섹션이 모두 있는가?

3. **에러 처리**:
   - 파일 없음 → Task 재실행
   - 형식 오류 → 피드백 후 재실행
   - 내용 부족 → 구체적 지시 후 재실행

---

## 재실행 및 피드백

### 재수립/재작업 시 프롬프트

**Strategist 재호출 (2회차 이상)**:
```
agents/shared/strategist.md와 rules/core-principles.md를 읽어라.

사용자 요청: [원래 요구사항]

SPEC.md (이전 계획)를 읽어라.
PLAN.md (Plan-Reviewer 피드백)를 읽어라.

PLAN.md의 "재수립 지시"를 모두 반영하여 SPEC.md를 수정하라.
```

**Worker 재호출 (2회차 이상)**:
```
agents/shared/worker.md와 rules/core-principles.md를 읽어라.

SPEC.md (원래 계획)를 읽어라.
WORK_LOG.md (현재 작업)를 읽어라.
QA_REPORT.md (Reviewer 피드백)를 읽어라.

QA_REPORT.md의 "재작업 지시"를 모두 반영하여 작업을 수정하라.
수정 완료 후 WORK_LOG.md를 업데이트하라.
```

**핵심**: 이전 결과 + 피드백 모두 제공

---

## 에러 처리

### Task 실행 실패 시

**증상**:
- Task가 응답 없음
- 파일이 생성되지 않음
- 형식이 완전히 틀림

**대응**:
1. Task 프롬프트 검토 (파일 읽기 지시 누락?)
2. 더 구체적 지시로 재실행
3. 2회 실패 시 사용자에게 보고

### 컨텍스트 오버플로우

**증상**:
- "작업이 완료되었습니다" (실제 미완성)
- 요구사항 일부 누락
- 이전 지시 무시

**대응**:
- 파일 요약본 생성하여 전달
- Task 완전 재시작

---

## Best Practices

1. **프롬프트는 명시적으로**
   - ❌ "계획을 수립하라"
   - ✅ "agents/shared/strategist.md를 읽고, 사용자 요청을 분석하여, SPEC.md에 저장하라"

2. **파일 읽기는 항상 명령형**
   - ❌ "SPEC.md 참고"
   - ✅ "SPEC.md 파일을 읽어라"

3. **출력 파일은 명확히**
   - ❌ "결과를 저장하라"
   - ✅ "결과를 WORK_LOG.md에 저장하라"

4. **재실행 시 피드백 포함**
   - 이전 결과물 + 개선 지시 모두 제공
   - "왜 재작업하는지" 명확히
