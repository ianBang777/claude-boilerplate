---
name: commit-convention
description: 현재 staged 변경사항을 분석하고 Conventional Commits 규칙에 따라 커밋 메시지를 작성합니다.
---

# Commit Convention

현재 staged 변경사항을 분석하고 Conventional Commits 규칙에 따라 커밋 메시지를 작성합니다.

## 실행 순서

1. `git diff --staged`로 변경사항을 분석합니다.
2. 변경의 **목적(why)**을 파악합니다. 무엇(what)은 diff가 설명합니다.
3. 아래 규칙에 따라 커밋 메시지를 작성합니다.
4. 커밋 전 사용자에게 메시지를 보여주고 확인을 받습니다.

## 커밋 메시지 규칙

```
<type>(<scope>): <subject>

[body - 선택사항, why에 집중]
```

### type

| type | 사용 시점 |
|---|---|
| `feature` | 새로운 기능 추가 |
| `fix` | 버그 수정 |
| `refactor` | 기능 변경 없는 코드 개선 |
| `style` | 포맷팅, 세미콜론 등 (로직 변경 없음) |
| `test` | 테스트 추가 또는 수정 |
| `chore` | 빌드, 의존성, 설정 변경 |
| `docs` | 문서 변경 |
| `perf` | 성능 개선 |

### scope
변경된 모듈·기능 영역을 소문자로 작성합니다. (예: `auth`, `product`, `api`, `ui`)

### subject
- 명령형으로 작성합니다. ("추가한다", "수정한다" → "추가", "수정")
- 50자 이내
- 끝에 마침표 없음

## 예시

```
feat(auth): 소셜 로그인 기능 추가

Google OAuth 연동. 기존 이메일 로그인과 동일한 세션 구조 사용.
```

```
fix(product): 재고 0일 때 주문 버튼 비활성화 누락 수정
```

```
refactor(api): axios 인스턴스 공통 설정 분리
```
