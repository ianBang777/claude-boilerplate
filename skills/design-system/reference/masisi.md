# Masisi 컴포넌트 라이브러리

`packages/masisi` — Emotion(CSS-in-JS) 기반 2순위 디자인 시스템.

> **주의**: masisi는 deprecated 예정이다. madix에 없는 컴포넌트가 필요할 때만 사용한다.

---

## MasisiTypography ⭐ 필수

**텍스트에 `p`, `h1`~`h6`, `span` 태그를 직접 사용하지 않는다. 반드시 `MasisiTypography`를 사용한다.**

```tsx
// 기본 사용
<MasisiTypography variant="body5_Regular">일반 텍스트</MasisiTypography>
<MasisiTypography variant="body6_SemiBold">레이블</MasisiTypography>
<MasisiTypography variant="body2_Bold">제목</MasisiTypography>

// as prop으로 시맨틱 HTML 태그 지정
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

262개의 자체 SVG 아이콘을 렌더링하는 컴포넌트.

```tsx
// 기본 사용
<MasisiSvgLoader svgKey="Close" width={20} />

// 컬러 지정
<MasisiSvgLoader svgKey="InfoFill" width={24} color="blue" />

// 클릭 이벤트
<MasisiSvgLoader svgKey="Arrow" width={16} onClick={handleClick} />

// 회전
<MasisiSvgLoader svgKey="Arrow" width={16} rotation="90" />

// 그레이스케일
<MasisiSvgLoader svgKey="Star" width={20} grayScale />

// 접근성
<MasisiSvgLoader svgKey="Close" width={16} ariaLabel="닫기" />
```

자주 사용하는 `MasisiSvgKey`: `Close`, `Arrow`, `InfoFill`, `CheckFill`, `Warning`, `Star`, `Search`, `Plus`, `Minus` 등.

---

## MasisiButton

```tsx
// variant: accent | primary | secondary | ghost | negative | staticWhite | lightGreen
// size: xs | sm | md | lg | xl
<MasisiButton variant="primary" size="md">저장</MasisiButton>
<MasisiButton variant="ghost" size="sm" icon="Close">닫기</MasisiButton>
<MasisiButton variant="negative" full>전체 너비 버튼</MasisiButton>
```

---

## Emotion 스타일링

masisi 컴포넌트를 수정할 때는 Tailwind 클래스가 아닌 Emotion 패턴을 유지한다.

```tsx
import styled from "@emotion/styled";
import palette from "@myfair/common/src/style/palette";

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
  &:hover { opacity: 0.8; }
`;
```

단, 래퍼 div에 Tailwind 클래스를 추가하는 것은 가능하다.

---

## MasisiElevationVariant

```tsx
const Container = styled.div`
  box-shadow: ${MasisiElevationVariant.md};
`;
```

---

## admin 전용 컴포넌트

admin 앱에는 `apps/admin/src/masisi/onDemand/`에 admin 전용 컴포넌트가 있다.

```
apps/admin/src/masisi/onDemand/
├── calendar/    MasisiCalendar, MasisiTimeline
├── dropdown/    MasisiAdminDropdownMenu
├── layout/      MasisiAdminPropertyListWithCopyable
├── link/        MasisiAdminLinkWithCopyable
├── popover/     MasisiAdminHelpPopover, MasisiAdminPopover
├── tab/         MasisiAdminTab
├── table/       MasisiTable, MasisiTableHeaderSortButton, MasisiTableWithBottomComponent
└── typography/  MasisiAdminTypoWithCopyable, MasisiEllipsisButHover
```

admin 앱에서 사용 시 `@/src/masisi/onDemand/...` 경로로 import.
