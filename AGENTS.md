# Agents

이 저장소는 Task 기반 멀티에이전트 하네스입니다.
대화가 시작되면 **Orchestrator**가 요청을 분석하고 **팀 에이전트**에 위임합니다.

---

## 전체 구조

```
AGENTS.md (이 파일)         ← 동작 방식 개요
├── agents/
│   ├── orchestrator.md     ← 진입점: 요청 분석 및 팀 에이전트 위임
│   ├── secretary/
│   │   └── index.md        ← Secretary 팀: Task 기반 8단계 파이프라인
│   ├── developer/
│   │   └── index.md        ← Developer 팀: 개발 작업 specialist 조합 실행
│   ├── shared/             ← 여러 팀이 공유하는 서브에이전트
│   │   ├── strategist.md
│   │   ├── plan-reviewer.md
│   │   ├── worker.md       ← 코드 작업 시 specialist 에이전트에 위임
│   │   └── reviewer.md
│   └── specialist/         ← 도메인 전문 에이전트 (팀 에이전트가 호출)
│       ├── infra-engineer.md
│       ├── fe-dev.md          ← TypeScript 작업 시 skills/typescript/SKILL.md 참조
│       ├── be-dev.md
│       ├── qa.md
│       ├── analyzer.md
│       ├── oracle.md
│       └── tutor.md
├── rules/                  ← 모든 에이전트가 따르는 공통 원칙
├── skills/                 ← 도메인별 검증 가이드 및 작업 스킬
├── commands/               ← SlashCommand로 직접 호출하는 명령어
└── hooks/                  ← 자동화 스크립트 (Bash 검증, 로깅 등)
```

---

## 에이전트 개요

### Orchestrator (기본 진입점)
모든 요청의 시작점. 요청의 유형과 복잡도를 분석하고 **팀 에이전트(Secretary/Developer)** 에 위임합니다.
specialist 에이전트를 직접 호출하지 않습니다.

→ `agents/orchestrator.md`

### Secretary 팀
계획 수립이 필요한 복잡한 작업을 위한 8단계 자동 파이프라인.
계획 수립 → 사용자 승인 → 실행 → 품질 검토를 자동화합니다.

→ `agents/secretary/index.md`

### Developer 팀
코드 개발 요청을 받아 작업 난이도에 따라 specialist 에이전트를 조합해 실행합니다.
analyzer로 구조를 파악하고, oracle에 설계를 자문하며, 도메인 specialist에 구현을 위임합니다.

→ `agents/developer/index.md`

### 공유 서브에이전트 (shared/)
Secretary 팀이 사용하는 범용 에이전트.

| 에이전트 | 역할 |
|---|---|
| **Strategist** | 문제 분석 및 SPEC.md 계획 수립 |
| **Plan-Reviewer** | 계획 검토 및 승인/재수립 판정 |
| **Worker** | 코드·문서·인프라 실행 (필요 시 specialist 위임) |
| **Reviewer** | 결과물 품질 검토 및 승인/재작업 판정 |

### 전문 에이전트 (specialist/)
도메인 특화 에이전트. **Developer 팀 또는 Worker가 호출합니다.**

| 에이전트 | 전문 분야 |
|---|---|
| **Infra-Engineer** | AWS/Pulumi 인프라 설계 및 구축 |
| **fe-dev** | Next.js / TypeScript / React 개발 (`skills/typescript` 참조) |
| **be-dev** | Spring Boot / Kotlin / Supabase 백엔드 |
| **qa** | 테스트 설계 및 버그 탐지 |
| **analyzer** | 코드베이스 분석 (읽기 전용) |
| **oracle** | 설계 및 아키텍처 자문 |
| **tutor** | 에이전트/커맨드 실행 순서 안내 |

---

## 기본 워크플로우

### 개발 작업 (버그 픽스, 기능 구현)
```
Orchestrator → Developer 팀
  └── [단순] fe-dev 또는 be-dev
  └── [중간] analyzer → fe-dev 또는 be-dev
  └── [복잡] oracle → analyzer → fe-dev + be-dev (병렬) → qa
```

### 계획이 필요한 작업 (신규 기능, 설계 변경)
```
Orchestrator → Secretary 팀 (8단계 파이프라인)
  └── Worker → specialist 에이전트 위임
```

### Secretary 팀 파이프라인 (8단계)
```
Step 0: 요구사항 파악
Step 1-3: 자동 계획 수립 및 검토 (Strategist → Plan-Reviewer)
Step 4: 사용자 승인 ← 유일한 수동 개입
Step 5-7: 자동 실행 및 검토 (Worker → Reviewer)
Step 8: 최종 전달
```

---

## 파일 기반 통신

서브에이전트 간 결과는 파일로 전달됩니다.

| 파일 | 생성자 | 내용 |
|---|---|---|
| `SPEC.md` | Strategist | 문제 분석 및 실행 계획 |
| `PLAN.md` | Plan-Reviewer | 계획 승인/재수립 판정 |
| `WORK_LOG.md` | Worker | 작업 결과 및 변경 파일 목록 |
| `QA_REPORT.md` | Reviewer | 품질 검토 결과 및 판정 |

---

## 참조 문서

| 경로 | 내용 |
|---|---|
| `rules/core-principles.md` | 모든 에이전트 공통 원칙 |
| `rules/task-execution.md` | Task 도구 사용 규칙 |
| `rules/file-protocol.md` | 파일 형식 및 통신 프로토콜 |
| `rules/quality-standards.md` | 품질 기준 |
| `rules/coding-standards.md` | 코딩 원칙 (SOLID, Clean Code) |
| `rules/tags.md` | 태그 시스템 (작업별 자동 문서 로드) |
| `skills/README.md` | 검증 Skill 인덱스 |
