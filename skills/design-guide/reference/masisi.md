# masisi 컴포넌트 라이브러리 사용법

`packages/masisi` — Emotion(CSS-in-JS) 기반 2순위 디자인 시스템.

> **주의**: masisi는 deprecated 예정이다. madix에 없는 컴포넌트가 필요할 때만 사용한다. 신규 컴포넌트는 madix로 구현하는 것을 권장한다.

---

## 디렉토리 구조

```
packages/masisi/src/
├── onDemand/          # 실서비스용 컴포넌트 (import 경로)
│   ├── button/        # MasisiButton, MasisiMutationButton 등
│   ├── callout/
│   ├── chart/
│   ├── field/         # MasisiCheckbox, MasisiInput, MasisiSelect 등
│   ├── icon/          # MasisiSvgLoader, MasisiIconButton
│   ├── input/         # MasisiInput 계열 (deprecated 경로, field/ 사용 권장)
│   ├── label/
│   ├── layout/        # MasisiAccordion, MasisiSection 등
│   ├── link/
│   ├── marker/
│   ├── pagination/
│   ├── popover/
│   ├── segmentedControl/
│   ├── tag/           # MasisiOnOffTag
│   ├── toggle/
│   ├── typography/    # MasisiTypography (핵심)
│   ├── Divider.tsx
│   ├── DividerWithText.tsx
│   └── MasisiStepper.tsx
├── onSketch/          # 디자인 단계 컴포넌트 (SVG 등 정적 에셋 포함)
│   ├── button/
│   ├── svgs/          # 262개 SVG 파일 (MasisiSvgLoader가 참조)
│   └── ...
├── styles/
├── variants/          # MasisiTypographyTailwindVariants 등
├── constants/         # MasisiElevationVariant 등
└── wrapper/           # MasisiZIndexWrapper
```

**onDemand vs onSketch**:
- `onDemand/` — 프로덕션 코드에서 import하는 컴포넌트. 실서비스에서 사용.
- `onSketch/` — SVG, 로티 등 정적 에셋 및 스케치 단계 컴포넌트. `MasisiSvgLoader`가 내부적으로 참조함.

---

## import 패턴

배럴 export가 없다. **반드시 파일 경로로 직접 import**한다.

```tsx
// 타이포그래피 (가장 많이 사용)
import MasisiTypography from "@myfair/masisi/src/onDemand/typography/MasisiTypography";

// SVG 아이콘
import MasisiSvgLoader, { MasisiSvgKey } from "@myfair/masisi/src/onDemand/icon/MasisiSvgLoader";

// 버튼
import MasisiButton from "@myfair/masisi/src/onDemand/button/MasisiButton";
import MasisiMutationButton from "@myfair/masisi/src/onDemand/button/MasisiMutationButton";
import MasisiTextButton from "@myfair/masisi/src/onDemand/button/MasisiTextButton";
import MasisiIconButton from "@myfair/masisi/src/onDemand/icon/MasisiIconButton";

// 입력 필드
import MasisiInput from "@myfair/masisi/src/onDemand/field/MasisiInput";
import MasisiSelect from "@myfair/masisi/src/onDemand/field/MasisiSelect";
import MasisiCheckbox from "@myfair/masisi/src/onDemand/field/MasisiCheckbox";
import MasisiTextarea from "@myfair/masisi/src/onDemand/field/MasisiTextarea";
import MasisiDatePicker from "@myfair/masisi/src/onDemand/field/MasisiDatePicker";

// 레이아웃
import MasisiAccordion from "@myfair/masisi/src/onDemand/layout/MasisiAccordion";
import MasisiSection from "@myfair/masisi/src/onDemand/layout/MasisiSection";

// 스텝퍼
import MasisiStepper from "@myfair/masisi/src/onDemand/MasisiStepper";

// 구분선
import { Divider } from "@myfair/masisi/src/onDemand/Divider";

// 유틸리티
import { mergeClasses } from "@myfair/masisi/src/libs/mergeClasses";

// 상수
import MasisiElevationVariant from "@myfair/masisi/src/constants/MasisiElevationVariant";

// 래퍼
import MasisiZIndexWrapper from "@myfair/masisi/src/wrapper/MasisiZIndexWrapper";
```

---

## Emotion 기반 스타일링

masisi는 Emotion(CSS-in-JS)으로 스타일을 정의한다. madix의 Tailwind 클래스와 스타일 체계가 다르다.

```tsx
import styled from "@emotion/styled";
import { css } from "@emotion/react";
import palette from "@myfair/common/src/style/palette";

// styled component 패턴
const Container = styled.div`
  display: flex;
  flex-direction: column;
  gap: 1rem;
  padding: 1.5rem;
  border-radius: 1rem;
  background: ${palette.white._1};
  border: 1px solid ${palette.gray._200};
`;

// 조건부 스타일
const Button = styled.button<{ isActive: boolean }>`
  background: ${(props) => props.isActive ? palette.blue._500 : palette.gray._100};
  
  &:hover {
    opacity: 0.8;
  }
`;
```

**주의**: masisi 컴포넌트를 수정할 때는 Tailwind 클래스가 아닌 Emotion 스타일 패턴을 유지해야 한다. 단, 래퍼 div에 Tailwind 클래스를 추가하는 것은 가능하다.

---

## MasisiTypography

텍스트 렌더링 컴포넌트. myfair 앱에서 가장 많이 사용된다.

```tsx
import MasisiTypography from "@myfair/masisi/src/onDemand/typography/MasisiTypography";

// 기본 사용
<MasisiTypography variant="body5_Regular">일반 텍스트</MasisiTypography>
<MasisiTypography variant="body6_SemiBold">레이블</MasisiTypography>
<MasisiTypography variant="body2_Bold">제목</MasisiTypography>

// as prop으로 HTML 태그 지정
<MasisiTypography variant="h2" as="h2">페이지 제목</MasisiTypography>

// 커스텀 className 추가 가능
<MasisiTypography variant="body5_Regular" className="text-primary">
  강조 텍스트
</MasisiTypography>
```

### variant 체계

| 그룹 | variant 예 | 설명 |
|------|-----------|------|
| heading | `h1`, `h2`, `h3`, `h4` | 큰 제목 |
| body1 | `body1_Regular/Medium/SemiBold/Bold` | 매우 큰 본문 |
| body2 | `body2_Regular/Medium/SemiBold/Bold` | 큰 본문 |
| body3 | `body3_Regular/Medium/SemiBold/Bold` | 중간 본문 |
| body4 | `body4_Regular/Medium/SemiBold/Bold` | 소형 본문 |
| body5 | `body5_Regular/Medium/SemiBold/Bold` | 기본 본문 (기본값) |
| body6 | `body6_Regular/Medium/SemiBold/Bold` | 작은 본문 |
| label1 | `label1_Regular/Medium/SemiBold` | 레이블 |
| label2 | `label2_Regular/Medium/SemiBold` | 작은 레이블 |
| label3 | `label3_Regular/Medium/SemiBold` | 매우 작은 레이블 |

`_Leading` suffix가 붙은 variant는 line-height가 추가된다 (예: `body5_Regular_Leading`).

---

## MasisiSvgLoader

262개의 자체 SVG 아이콘을 렌더링하는 컴포넌트. SVG는 `onSketch/svgs/`에 위치한다.

```tsx
import MasisiSvgLoader, { MasisiSvgKey } from "@myfair/masisi/src/onDemand/icon/MasisiSvgLoader";

// 기본 사용
<MasisiSvgLoader svgKey="Close" width={20} />

// 컬러 지정 (CSS currentColor 기반)
<MasisiSvgLoader svgKey="InfoFill" width={24} color="blue" />

// 클릭 이벤트
<MasisiSvgLoader svgKey="Arrow" width={16} onClick={handleClick} />

// 회전 (문자열로 전달)
<MasisiSvgLoader svgKey="Arrow" width={16} rotation="90" />

// 그레이스케일
<MasisiSvgLoader svgKey="Star" width={20} grayScale />

// 접근성
<MasisiSvgLoader svgKey="Close" width={16} ariaLabel="닫기" />
```

**MasisiSvgKey**: `keyof typeof MasisiSvg` — 실제 키 목록은 `packages/masisi/src/onDemand/icon/MasisiSvgLoader.tsx`에서 확인. 자주 사용하는 키: `Close`, `Arrow`, `InfoFill`, `CheckFill`, `Warning`, `Star`, `Search`, `Plus`, `Minus` 등.

---

## MasisiButton

```tsx
import MasisiButton from "@myfair/masisi/src/onDemand/button/MasisiButton";

// variant: accent | primary | secondary | ghost | negative | staticWhite | lightGreen | ...
// size: xs | sm | md | lg | xl
<MasisiButton variant="primary" size="md">저장</MasisiButton>
<MasisiButton variant="ghost" size="sm" icon="Close">닫기</MasisiButton>
<MasisiButton variant="negative" full>전체 너비 버튼</MasisiButton>
```

---

## mergeClasses 유틸리티

masisi 내부 유틸리티. Emotion 기반 컴포넌트에서 className 합성에 사용.

```tsx
import { mergeClasses } from "@myfair/masisi/src/libs/mergeClasses";

const className = mergeClasses("base", isActive && "active", customClass);
```

---

## MasisiElevationVariant

그림자(elevation) 상수.

```tsx
import MasisiElevationVariant from "@myfair/masisi/src/constants/MasisiElevationVariant";

// CSS 인 JS에서 사용
const Container = styled.div`
  box-shadow: ${MasisiElevationVariant.md};
`;
```

---

## admin 전용 masisi 컴포넌트

admin 앱에는 `apps/admin/src/masisi/onDemand/` 에 admin 전용 masisi 컴포넌트가 있다.

```
apps/admin/src/masisi/onDemand/
├── calendar/
│   ├── MasisiCalendar.tsx
│   └── MasisiTimeline.tsx
├── dropdown/
│   └── MasisiAdminDropdownMenu.tsx
├── layout/
│   └── MasisiAdminPropertyListWithCopyable.tsx
├── link/
│   └── MasisiAdminLinkWithCopyable.tsx
├── popover/
│   ├── MasisiAdminHelpPopover.tsx
│   └── MasisiAdminPopover.tsx
├── tab/
│   └── MasisiAdminTab.tsx
├── table/
│   ├── MasisiTable.tsx
│   ├── MasisiTableHeaderSortButton.tsx
│   └── MasisiTableWithBottomComponent.tsx
└── typography/
    ├── MasisiAdminTypoWithCopyable.tsx
    └── MasisiEllipsisButHover.tsx
```

admin 앱에서 사용 시:
```tsx
import MasisiTable from "@/src/masisi/onDemand/table/MasisiTable";
import MasisiAdminTab from "@/src/masisi/onDemand/tab/MasisiAdminTab";
```
