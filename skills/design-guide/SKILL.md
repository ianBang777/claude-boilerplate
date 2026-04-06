---
name: design-guide
description: >
  프로젝트(Documents/repo/client) 내 앱별 톤앤매너에 맞게 디자인 변경을 수행하는 스킬.
  디자인 시스템(madix > masisi)을 우선 적용하며, 기능/핸들러/API 수정은 절대 금지.
  트리거: "디자인 바꿔줘", "UI 수정해줘", "톤앤매너 맞게 변경해줘", "컴포넌트 스타일 고쳐줘" 등
---

# Design Guide Skill

앱별 톤앤매너에 맞게 디자인을 변경할 때 따라야 할 가이드입니다.

상세 구현 지침은 아래 reference 문서를 참조하세요:
- `reference/madix.md` — madix 컴포넌트 라이브러리 사용법 (import 경로, variant/size, 폼 시스템, 시맨틱 토큰)
- `reference/masisi.md` — masisi 컴포넌트 라이브러리 사용법 (onDemand/onSketch 구조, Emotion 기반)
- `reference/myfair.md` — myfair 앱 패턴 + 톤앤매너
- `reference/admin.md` — admin 앱 패턴 + 톤앤매너
- `examples/example.md` — 실전 예시 모음

---

## 프로젝트 구조

```
Documents/repo/client/                    # yarn workspaces monorepo
├── apps/
│   ├── myfair/          # B2C 메인 서비스 (Next.js, localhost:3000)
│   ├── admin/           # 어드민 대시보드 (Next.js)
│   ├── partner/         # 파트너 포털 (Next.js)
│   ├── agency/          # 대행사 B2B 포탈 (Next.js, localhost:3003)
│   └── storybook/       # 컴포넌트 문서화
├── packages/
│   ├── madix/           # 1순위 디자인 시스템 (Radix UI + Tailwind CSS + CVA)
│   ├── masisi/          # 2순위 디자인 시스템 (Emotion + Tailwind 혼용, deprecated 예정)
│   ├── common/          # 공통 유틸, variables.css (색상 팔레트, 커스텀 variant)
│   └── core/            # 도메인 타입/enum
```

### 앱 내부 컴포넌트 구조 (Atomic Design)

```
apps/{appName}/src/domain/{domainName}/
├── components/
│   ├── atoms/
│   ├── molecules/
│   ├── organisms/
│   ├── templates/
│   └── pages/
└── hooks/
```

---

## 절대 금지 사항

> **아래 항목은 요청 범위와 무관하게 절대 수정하지 않는다.**

- 수정 요청 범위 외 컴포넌트 수정
- 이벤트 핸들러(onClick, onChange 등) 로직 수정
- API 호출 코드 수정 (fetch, axios, react-query, swr 등)
- 비즈니스 로직·유틸 함수 수정
- 상태 관리(useState, useReducer, zustand 등) 로직 수정
- props 인터페이스 변경 (스타일 관련 prop 추가는 허용)
- **배럴(barrel) import 사용 금지** — `@myfair/madix`나 `@myfair/masisi`에서 직접 import하는 것은 빌드 오류를 유발한다. 반드시 파일 경로로 직접 import해야 한다.
- 인라인 컬러값 사용 금지 (`text-blue-500`, `bg-gray-100` 등) — 반드시 시맨틱 토큰 사용

---

## import 규칙

배럴 export가 없으므로 **반드시 파일 경로로 직접 import**한다.

```tsx
// madix — 파일 경로 직접 import (Madix prefix 필수)
import { MadixButton } from "@myfair/madix/src/components/ui/button";
import { MadixForm } from "@myfair/madix/src/components/ui/form";
import { MadixFormFieldByType } from "@myfair/madix/src/components/ui/form-field";
import { useMadixForm } from "@myfair/madix/src/hooks/useMadixForm";
import { cn } from "@myfair/madix/src/lib/utils";

// masisi — 파일 경로 직접 import (Masisi prefix 필수)
import MasisiTypography from "@myfair/masisi/src/onDemand/typography/MasisiTypography";
import MasisiSvgLoader from "@myfair/masisi/src/onDemand/icon/MasisiSvgLoader";
import MasisiButton from "@myfair/masisi/src/onDemand/button/MasisiButton";
```

```tsx
// 금지 — 배럴 import
import { Button, Badge } from '@myfair/madix'           // 빌드 오류
import { SomeComponent } from '@myfair/masisi'          // 빌드 오류
```

---

## 디자인 시스템 우선순위

1. **madix** (`packages/madix`) — 항상 1순위. Radix UI + Tailwind CSS + CVA 기반.
2. **masisi** (`packages/masisi`) — madix에 없을 때만 사용. Emotion 기반. deprecated 예정.
3. **직접 구현** — 두 패키지 모두에 없는 경우에만 허용. 반드시 사유 명시.

### 컴포넌트 탐색 순서

1. `packages/madix/src/components/ui/` 에서 컴포넌트 검색
2. 없으면 `packages/masisi/src/onDemand/` 에서 검색
3. 사용 전 해당 앱의 기존 코드에서 사용 예시 참고

---

## 컴포넌트 네이밍 규칙

- **madix 컴포넌트**: 모두 `Madix` prefix (`MadixButton`, `MadixForm`, `MadixDialog` 등)
- **masisi 컴포넌트**: 모두 `Masisi` prefix (`MasisiTypography`, `MasisiSvgLoader`, `MasisiButton` 등)
- 네이밍 없이 `Button`, `Form` 등으로 사용 금지

---

## Tailwind v4 핵심 사항

- CSS 기반 설정 — `tailwind.config.js` 없음
- spacing 단위: `0.25rem` → `gap-4 = 1rem`, `px-16 = 4rem`
- **커스텀 variant** (`packages/common/src/style/variables.css`):
  - `pc:` — min-width: 769px 이상
  - `tablet:` — max-width: 768px 이하
  - `mobile:` — max-width: 520px 이하
- **테마 variant** (`packages/madix/src/styles/madix.css`):
  - `dark:` — `.root-dark` 클래스 적용 시
  - `pavilion:` — `.root-pavilion` 클래스 적용 시

---

## 시맨틱 토큰 체계

시맨틱 토큰은 `packages/madix/src/styles/madix.css`에 정의되어 있다. 상세 목록은 `reference/madix.md` 참조.

**핵심 토큰 카테고리**:
- 기본: `primary`, `foreground`, `background`, `secondary`
- 표면: `surface`, `surface-subtle`, `surface-foreground`
- 상태: `success-solid/soft`, `warning-solid/soft`, `error-solid/soft`, `info-solid/soft` (각각 `-foreground` 페어)
- UI: `border`, `input`, `ring`, `muted`, `muted-foreground`, `disabled`, `disabled-foreground`
- 카드/팝오버: `card`, `card-foreground`, `popover`, `popover-foreground`

**인라인 컬러값 사용 지양**:
```tsx
className="text-blue-500 bg-gray-100"

// 권장
className="text-primary bg-muted"
```

---

## 작업 순서

1. 수정 대상 파일 및 컴포넌트 확인
2. 앱 판별 — `apps/` 하위 폴더명 기준
3. 해당 앱의 reference 파일 읽기 (`reference/myfair.md` 또는 `reference/admin.md`)
4. 디자인 시스템 컴포넌트 탐색 (madix → masisi 순)
5. 폼 컴포넌트 포함 여부 판단 → 해당 시 `reference/madix.md`의 폼 가이드 적용
6. 변경 범위 요약 보고

---

## 공통 디자인 원칙

### 반응형

- myfair: `pc:`, `tablet:`, `mobile:` 커스텀 variant 사용 (mobile-first)
- admin/partner: 데스크탑 고정 레이아웃 우선, 필요 시 `tablet:` 사용

### 접근성

- 버튼/인터랙티브 요소에 aria-label 또는 명시적 텍스트 필수
- 아이콘 단독 사용 시 `aria-hidden="true"` + sr-only 텍스트 병행
- 색상만으로 상태를 표현하지 않음 (텍스트/아이콘 병행)

### 애니메이션

- `transition-colors`, `transition-opacity` 정도만 허용
- 복잡한 애니메이션은 기존 코드에 있는 경우만 유지, 새로 추가 금지

---

## 변경 범위 보고 형식

```markdown
## 디자인 변경 완료 보고

- 대상 앱: [myfair / admin / partner / agency / ...]
- 수정 파일: [파일 경로]

### 변경 내역
| 변경 항목 | 변경 전 | 변경 후 | 사용 패키지 |
|-----------|---------|---------|------------|
| 버튼 | 인라인 className | MadixButton variant="default" | madix |
| 타이포 | 인라인 span | MasisiTypography variant="body5_Regular" | masisi |

### 금지 항목 확인
- [ ] 수정 범위 외 컴포넌트 수정 없음
- [ ] 핸들러/이벤트 로직 수정 없음
- [ ] API 호출 코드 수정 없음
- [ ] 상태 관리 로직 수정 없음
- [ ] 배럴 import 사용 없음
```
