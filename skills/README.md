# Skills

도메인 전문 가이드 및 검증 절차를 제공하는 모듈입니다.

---

## 개념

Skills는 특정 기술/도메인에 특화된 작업 방법과 검증 절차를 제공합니다.

**역할**:
- "이 기술로 어떻게 작업하는가?"에 대한 구체적 방법
- Rules를 해당 도메인에 적용하는 방법
- 실행 가능한 명령어와 예시 코드 포함

---

## Skills 목록

### 검증 Skills (Worker/Reviewer 사용)

| Skill | 검증 대상 |
|---|---|
| **code-verify** | 일반 코드 검증 (테스트, 린트, 빌드) |
| **frontend-verify** | 프론트엔드 검증 (빌드, 타입 체크) |
| **pulumi-verify** | Pulumi 인프라 검증 (preview, 에러/경고) |

### 코드 리뷰 Skills

| Skill | 설명 |
|---|---|
| **code-review** | 변경된 코드 리뷰 및 심각도 분류 |
| **review-uncommitted** | 커밋 전 변경사항 리뷰 |
| **commit-convention** | Conventional Commits 규칙에 따른 커밋 메시지 작성 |

### 기술 도메인 Skills

| Skill | 설명 |
|---|---|
| **supabase** | Supabase 패턴 및 베스트 프랙티스 |
| **figma-impl** | Figma 디자인 구현 가이드 (references 포함) |
| **design-guide** | 앱별 톤앤매너 디자인 변경 가이드 |
| **design-system** | 디자인 시스템 구조 및 컴포넌트 라이브러리 |

---

## Worker 사용 방법 (검증 Skills)

작업 완료 후 해당 검증 Skill을 호출:

```
Pulumi 작업 시    → Skill("pulumi-verify")
프론트엔드 작업 시 → Skill("frontend-verify")
일반 코드 작업 시  → Skill("code-verify")
```

---

## 작업 유형별 검증 기준

| 작업 유형 | Skill | 주요 검증 항목 |
|---|---|---|
| Pulumi (인프라) | `pulumi-verify` | pulumi preview, 에러/경고, 보안 설정 |
| 프론트엔드 | `frontend-verify` | 빌드, 린트, 타입 체크, 렌더링 |
| 일반 코드 | `code-verify` | 단위 테스트, 린트, 타입 체크, 빌드 |

---

## 태그 매핑

`rules/tags.md` 참조 — 작업 태그에 따라 필요한 Skills가 자동으로 로드됩니다.
