# myfair 앱 패턴 + 톤앤매너

`apps/myfair/` — B2C 메인 서비스 (Next.js, localhost:3000)

---

## 앱 개요

- **성격**: B2C 마켓플레이스. 박람회 참가 신청, 부스 예약, 상품 탐색 등.
- **톤앤매너**: 따뜻하고 친근한, 신뢰감 있는 마켓플레이스. 감성적인 요소 중시.
- **현황**: masisi + Emotion styled 기반이 아직 많다. 신규 코드에서 madix로 전환 진행 중.

---

## 컴포넌트 구조 (Atomic Design)

```
apps/myfair/src/domain/{domainName}/
├── components/
│   ├── atoms/          # 최소 단위 (버튼, 텍스트 등)
│   ├── molecules/      # atoms 조합 (카드, 필터 등)
│   ├── organisms/      # molecules 조합 (섹션, 폼 등)
│   ├── templates/      # 레이아웃 템플릿
│   └── pages/          # 페이지 컴포넌트
└── hooks/
```

예시 도메인: `main`, `company`, `exhibition`, `member`, `estimate`, `pricing`, `search`, `blog`, `account` 등

---

## 톤앤매너

### 컬러 원칙

- `primary` 토큰 위주 (파란색 계열)
- myfair 전용 accent 색상 (`palette.myfair.accent`) — 기존 Emotion 코드에서 사용
- 인라인 컬러값 금지, 시맨틱 토큰 사용 (신규 코드)

### 타이포그래피

- **masisi 기반 코드**: `MasisiTypography`를 `variant` prop으로 사용
  - 본문: `body5_Regular`, `body6_Regular`
  - 제목: `body2_Bold`, `body3_SemiBold`
  - 레이블: `body6_SemiBold`, `label1_SemiBold`
- **madix 기반 신규 코드**: Tailwind 클래스 직접 사용 (`text-base font-semibold` 등)

### 버튼

- 기본 CTA: `MadixButton variant="default"` (신규 코드) 또는 `MasisiButton variant="primary"`
- 보조 액션: `MadixButton variant="outline"` 또는 `MasisiButton variant="ghost"`
- 위험 액션: `MadixButton variant="destructive"`

### 간격 / 모서리 / 그림자

- 여유로운 padding (최소 `p-4 = 1rem` 이상)
- 카드 간 gap: `gap-16` 이상 (4rem)
- 모서리: `rounded-[1rem]` (Emotion) 또는 `rounded-xl` (Tailwind) — 부드러운 느낌
- 그림자: `MasisiElevationVariant.md` 또는 `shadow-md` — 과하지 않게
- 이미지 포함 시: `object-cover`, aspect-ratio 유지 필수

---

## 주요 패턴

### MasisiTypography 활용 (기존 코드)

myfair 기존 코드에서 가장 자주 등장하는 패턴. Emotion styled와 함께 사용된다.

```tsx
import MasisiTypography from "@myfair/masisi/src/onDemand/typography/MasisiTypography";

// 카드 제목
<MasisiTypography variant="body2_SemiBold">{data.title}</MasisiTypography>

// 본문
<MasisiTypography variant="body5_Regular">{data.description}</MasisiTypography>

// 레이블 (폼 레이블 등)
<MasisiTypography variant="body6_SemiBold">제목</MasisiTypography>

// 커스텀 색상 추가 (className 사용)
<MasisiTypography variant="body5_Regular" className="text-primary">
  강조 텍스트
</MasisiTypography>
```

### Emotion + palette 패턴 (기존 코드 유지)

기존 myfair 코드의 스타일 방식. 수정 시 동일 패턴으로 유지한다.

```tsx
import styled from "@emotion/styled";
import palette from "@myfair/common/src/style/palette";
import MasisiElevationVariant from "@myfair/masisi/src/constants/MasisiElevationVariant";

const Card = styled.div`
  padding: 1.5rem;
  border: 1px solid ${palette.gray._200};
  border-radius: 1rem;
  background: ${palette.white._1};
  box-shadow: ${MasisiElevationVariant.md};
  cursor: pointer;
  transition: all 0.2s ease-in-out;

  &:hover {
    transform: scale(1.03);
    border-color: ${palette.blue._500};
  }
`;
```

### madix 컴포넌트 사용 (신규 코드)

신규 파일에서는 madix로 구현하되, 기존 파일과의 일관성 유지를 우선한다.

```tsx
import { MadixButton } from "@myfair/madix/src/components/ui/button";
import { MadixDialog, MadixDialogContent, MadixDialogHeader, MadixDialogTitle, MadixDialogFooter } from "@myfair/madix/src/components/ui/dialog";
import { MadixMutationButton } from "@myfair/madix/src/components/ui/mutation-button";
import MasisiSvgLoader from "@myfair/masisi/src/onDemand/icon/MasisiSvgLoader";

// 확인 다이얼로그 패턴 (ConfirmModal 참고)
<MadixDialog open={isOpen}>
  <MadixDialogContent>
    <MadixDialogHeader>
      <MasisiSvgLoader svgKey="InfoFill" width={32} />
      <MadixDialogTitle>확인</MadixDialogTitle>
    </MadixDialogHeader>
    <p className="text-muted-foreground">계속 진행하시겠습니까?</p>
    <MadixDialogFooter>
      <MadixButton variant="outline" onClick={onCancel}>취소</MadixButton>
      <MadixMutationButton onClick={onConfirm}>확인</MadixMutationButton>
    </MadixDialogFooter>
  </MadixDialogContent>
</MadixDialog>
```

### 반응형 (커스텀 variant)

```tsx
// myfair는 pc/tablet/mobile 커스텀 variant 사용
<div className="flex flex-col pc:flex-row gap-8 pc:gap-16">
  <section className="w-full pc:w-1/2">
    {/* ... */}
  </section>
</div>

// pc: = min-width: 769px 이상
// tablet: = max-width: 768px 이하
// mobile: = max-width: 520px 이하
```

---

## 마이그레이션 방향

| 상황 | 처리 방법 |
|------|----------|
| 기존 파일 수정 | 기존 Emotion 패턴 유지 (masisi + styled-components 혼용 허용) |
| 신규 파일 생성 | madix 우선. masisi는 madix에 없는 컴포넌트만 사용 |
| MasisiTypography 교체 | 아직 불필요. myfair에서는 MasisiTypography 계속 사용 |

---

## 주의사항

- 상품 카드, 리뷰, 사용자 프로필 등 감성적 요소에 딱딱한 스타일 지양
- 이미지가 포함된 경우 `object-cover`, aspect-ratio 유지 필수
- 기존 Emotion styled 컴포넌트를 불필요하게 Tailwind로 교체하지 않는다
- `palette.myfair.accent` 색상은 myfair 전용 브랜드 색상 — 임의 변경 금지
