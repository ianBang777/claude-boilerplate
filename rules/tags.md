---
tags: ["meta", "tag-system"]
applies_to: ["all"]
---

# Tag System

**이 파일은 태그 시스템의 Single Source of Truth (SSOT)입니다.**

Tags를 전달받은 모든 에이전트는 이 파일을 참조하여 작업에 필요한 Rules/Skills를 결정합니다.

---

## 태그 사용 원칙

1. **명확성**: 태그명은 작업 내용을 명확히 표현
2. **일관성**: 팀 전체가 동일한 태그 사용
3. **최소화**: 필요한 태그만 선택 (2-5개 권장)
4. **계층성**: 구체적 태그 → 일반적 태그 순서로 선택

---

## 태그 목록 및 매핑

### 언어/프레임워크

| Tag | 설명 | Rules | Skills |
|-----|------|-------|--------|
| **typescript** | TypeScript 코드 작성 | coding-standards.md | - |
| **kotlin** | Kotlin 코드 작성 | coding-standards.md | kotlin/SKILL.md |

### 도메인/계층

| Tag | 설명 | Rules | Skills |
|-----|------|-------|--------|
| **backend** | 백엔드 작업 (서버 사이드) | coding-standards.md, quality-standards.md | - |
| **frontend** | 프론트엔드 작업 (UI/UX) | coding-standards.md, quality-standards.md | frontend-verify.md |
| **api** | API 개발 (RESTful/GraphQL) | coding-standards.md | - |
| **database** | 데이터베이스 작업 | quality-standards.md | - |
| **infra** | 인프라 작업 | quality-standards.md | - |

### 인프라 기술

| Tag | 설명 | Rules | Skills |
|-----|------|-------|--------|
| **aws** | AWS 클라우드 리소스 | quality-standards.md | - |
| **pulumi** | Pulumi IaC | quality-standards.md | pulumi-verify.md |
| **docker** | Docker 컨테이너 | quality-standards.md | - |

### 아키텍처/패턴

| Tag | 설명 | Rules | Skills |
|-----|------|-------|--------|
| **oop** | 객체지향 프로그래밍 (SOLID) | coding-standards.md | - |
| **functional** | 함수형 프로그래밍 | coding-standards.md | - |
| **clean-code** | 클린코드 원칙 강조 | coding-standards.md | - |
| **solid** | SOLID 원칙 강조 | coding-standards.md | - |

### 작업 유형

| Tag | 설명 | Rules | Skills |
|-----|------|-------|--------|
| **code** | 일반 코드 작성 | coding-standards.md, quality-standards.md | code-verify.md |
| **refactor** | 리팩토링 | coding-standards.md | - |
| **bugfix** | 버그 수정 | coding-standards.md | - |
| **test** | 테스트 작성 | quality-standards.md, testing-standards.md | - |
| **docs** | 문서 작성 | - | - |

### 검증/품질

| Tag | 설명 | Rules | Skills |
|-----|------|-------|--------|
| **verify** | 검증 작업 강조 | quality-standards.md | (작업 유형별 *-verify.md, README.md 참조) |
| **quality** | 품질 기준 강조 | quality-standards.md | - |

---

## 사용 방법

Tags를 전달받은 에이전트는 작업 시작 시 이 파일을 기반으로 필요한 Rules/Skills를 결정합니다.

### 로딩 프로세스

1. `rules/tags.md` 읽기
2. Tags에 매칭되는 모든 Rules/Skills 확인
3. 해당 문서들을 순서대로 읽기 (Rules → Skills 순)
4. 중복 문서는 한 번만 읽기
5. 문서 내용을 참고하여 작업 수행

### 경로 규칙

- Rules 컬럼 파일: `rules/[파일명]` 경로에서 로드
- Skills 컬럼 파일: `skills/[파일명]` 경로에서 로드

### 예시

```
Tags: ["typescript", "api", "oop"]

자동 로드:
  1. rules/coding-standards.md
  2. rules/quality-standards.md
```

---

## 태그 조합 예시

### TypeScript 백엔드 API 개발
```
Tags: ["typescript", "backend", "api", "oop"]

자동 로드:
  - rules/coding-standards.md
  - rules/quality-standards.md
```

### Pulumi AWS 인프라 구축
```
Tags: ["pulumi", "aws", "infra"]

자동 로드:
  - rules/quality-standards.md
  - skills/pulumi-verify.md
```

### React 프론트엔드 개발
```
Tags: ["typescript", "frontend", "oop"]

자동 로드:
  - rules/coding-standards.md
  - rules/quality-standards.md
  - skills/frontend-verify.md
```

### 레거시 코드 리팩토링
```
Tags: ["typescript", "refactor", "clean-code"]

자동 로드:
  - rules/coding-standards.md
```

### 데이터베이스 마이그레이션
```
Tags: ["database"]

자동 로드:
  - rules/quality-standards.md
```

### Kotlin 백엔드 API 개발
```
Tags: ["kotlin", "backend", "api", "oop"]

자동 로드:
  - rules/coding-standards.md
  - rules/quality-standards.md
  - skills/kotlin/SKILL.md
```

---

## 새 태그 추가 절차

1. **태그 정의**: 위 테이블에 새 행 추가 (적절한 카테고리 선택)
2. **매핑 추가**: Rules/Skills 컬럼에 참조 문서 추가
3. **메타데이터 추가**: 해당 Rules/Skills 파일의 YAML frontmatter에 태그 추가
   ```yaml
   ---
   tags: ["new-tag", "existing-tag"]
   applies_to: ["code"]
   ---
   ```
4. **팀 공유**: 새 태그 추가를 팀에 공지

---

## 태그 네이밍 규칙

- **소문자 사용**: `typescript` (O), `TypeScript` (X)
- **하이픈 연결**: `clean-code` (O), `cleanCode` (X)
- **단수형 사용**: `api` (O), `apis` (X)
- **표준 약어 허용**: `aws`, `db` (도메인 표준인 경우)
- **일반 용어 우선**: 축약 최소화

---

## 로드 순서

동일한 문서가 여러 태그에 매칭되어도 **중복 로드하지 않음**.

### 우선순위
1. Rules (원칙) 먼저
2. Skills (실행 가이드) 나중
3. 각 카테고리 내에서 알파벳 순

### 예시
```
Tags: ["typescript", "oop", "api"]

로드 순서:
  1. rules/coding-standards.md (중복 제거)
  2. rules/quality-standards.md
```

---

## 주의사항

### 태그 남용 금지
- 너무 많은 태그 → 불필요한 문서 로드 → 컨텍스트 낭비
- 작업에 **실제로 필요한 태그만** 선택

### 태그 일관성 유지
- 팀 전체가 동일한 태그 사용
- 신규 태그 추가 시 팀 합의

### 태그 업데이트
- Rules/Skills 내용 변경 시 태그도 확인
- 더 이상 관련 없는 태그는 제거
