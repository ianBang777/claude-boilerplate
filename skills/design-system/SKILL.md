---
name: design-system
description: >
  프로젝트 디자인 시스템 구조와 컴포넌트 라이브러리 사용 가이드.
  Madix(Radix+Tailwind)와 Masisi(Emotion) 기반 컴포넌트 체계를 안내한다.
---

# Design System Guide

프로젝트 디자인 시스템의 구조와 컴포넌트 라이브러리 사용 가이드입니다.

## 컴포넌트 라이브러리 우선순위

1. **Madix** (1순위) — Radix UI + Tailwind 기반, `reference/madix.md` 참조
2. **Masisi** (2순위) — Emotion 기반 커스텀 컴포넌트, `reference/masisi.md` 참조
3. **직접 구현** (최후 수단) — 위 두 라이브러리에 없는 경우에만

## 폴더 구조 (Atomic Design)

```
src/
├── atoms/          # 가장 작은 단위 (Button, Input, Icon 등)
├── molecules/      # atoms 조합 (SearchBar, FormField 등)
├── organisms/      # molecules 조합 (Header, ProductCard 등)
├── templates/      # 레이아웃 (PageLayout, SectionLayout 등)
└── pages/          # 실제 페이지
```

## 타이포그래피 필수 규칙

**`p`, `h1`~`h6`, `span` 태그를 직접 사용하지 않는다. 반드시 `MasisiTypography`를 사용한다.**

```tsx
// ❌ Bad
<p className="text-sm">일반 텍스트</p>
<h2 className="text-lg font-bold">제목</h2>
<span className="text-primary">강조</span>

// ✅ Good
<MasisiTypography variant="body5_Regular">일반 텍스트</MasisiTypography>
<MasisiTypography variant="body2_Bold" as="h2">제목</MasisiTypography>
<MasisiTypography variant="body5_Regular" className="text-primary">강조</MasisiTypography>
```

variant 체계는 `reference/masisi.md` 참조.

---

## 디자인 토큰 사용 원칙

- 인라인 색상값 금지: `text-[#123456]` ❌
- 시맨틱 토큰 필수: `text-primary`, `bg-muted`, `border-default` ✅
- 간격·타이포 토큰 준수: `text-sm`, `font-medium`, `gap-4` ✅

## Tailwind 반응형 variant

프로젝트 커스텀 variant를 사용합니다:

```
pc:      → 데스크톱
tablet:  → 태블릿
mobile:  → 모바일 (기본값)
```

예시: `text-sm mobile:text-xs pc:text-base`

## 참조 문서

- `reference/madix.md` — Madix 컴포넌트 목록 및 사용법
- `reference/masisi.md` — Masisi 컴포넌트 목록 및 사용법
