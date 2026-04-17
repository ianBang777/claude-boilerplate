# DESIGN.md — MADIX Design System

> MADIX 디자인 시스템의 단일 진실 공급원(Single Source of Truth).
> AI 에이전트는 UI 생성 전 이 파일을 읽고, 여기 정의된 값만 사용하세요. 색상·크기·간격을 임의로 만들지 마세요.

---

## 테마 가이드

### 서비스별 테마

| 서비스 | `<html>` 속성 | primary | 설명 |
|---|---|---|---|
| MYFAIR 기본 (메인 서비스, 해외 박람회 부스 참가/예약) | (없음) | `#2182f3` 블루 | 기본값 |
| 공동관 서비스 (기관 대상 공동관 참가 지원) | `data-theme="pavilion"` | `#10b981` 에메랄드 | |
| 전시부스 서비스 (독립부스, 전시부스 시공·견적) | `data-theme="space-only"` | `#f97316` 오렌지 | |

### 인터뷰 질문 내용

CLAUDE.md의 지시에 따라 아래 두 질문을 순서대로 하세요.

**Q1 — 어떤 서비스를 위한 화면인가요?**

| 번호 | 서비스 | 테마 |
|---|---|---|
| 1 | MYFAIR 기본 (메인 서비스, 해외 박람회 부스 참가/예약) | 기본 |
| 2 | 공동관 서비스 (기관 대상 공동관 참가 지원) | `pavilion` |
| 3 | 전시부스 서비스 (독립부스, 전시부스 시공·견적) | `space-only` |
| 4 | 잘 모르겠어요 | → 요청 내용으로 유추 후 확인 |

**Q2 — 어떤 종류의 화면인가요?**

| 번호 | 화면 유형 | 핵심 토큰 |
|---|---|---|
| 1 | 랜딩 / 마케팅 페이지 | `primary`, `foreground`, `surface` |
| 2 | 정보 수집 폼 (리드 마그넷) | `primary`, `border`, `muted-foreground` |
| 3 | 관리자 / 대시보드 | `surface-subtle`, `border`, `muted` |
| 4 | 컴포넌트 (버튼, 카드, 모달 등) | 아래 토큰 정의 참고 |
| 5 | 기타 (직접 설명) | → AI가 판단 |

---

## Color System

### Semantic Colors — Light Mode

All colors map to Tailwind utility classes and CSS variables.

#### Layout & Surface

| Token | CSS Variable | Hex (Light) | Tailwind | Usage |
|-------|-------------|-------------|----------|-------|
| background | `--background` | `#ffffff` | `bg-background` | Page background |
| foreground | `--foreground` | `#09090b` | `text-foreground` | Primary text |
| surface | `--surface` | `#ffffff` | `bg-surface` | Card/panel background |
| surface-subtle | `--surface-subtle` | `#fafafa` | `bg-surface-subtle` | Slightly off-white backgrounds |
| surface-foreground | `--surface-foreground` | `#09090b` | `text-surface-foreground` | Text on surface |
| surface-foreground-subtle | `--surface-foreground-subtle` | `#71717a` | `text-surface-foreground-subtle` | Secondary text, captions |
| surface-overlay | `--surface-overlay` | `#ffffff` | `bg-surface-overlay` | Modal/drawer background |

#### Interactive Colors

| Token | CSS Variable | Hex (Light) | Tailwind | Usage |
|-------|-------------|-------------|----------|-------|
| primary | `--primary` | `#2182f3` | `bg-primary` | Main CTA buttons, key actions, links |
| primary-foreground | `--primary-foreground` | `#eff6ff` | `text-primary-foreground` | Text on primary buttons |
| primary-hover | `--primary-hover` | `#156ad9` | — | Primary button hover state |
| secondary | `--secondary` | `#f1f5f9` | `bg-secondary` | Secondary buttons, tags |
| secondary-foreground | `--secondary-foreground` | `#156ad9` | `text-secondary-foreground` | Text on secondary elements |
| secondary-hover | `--secondary-hover` | `#e2e8f0` | — | Secondary button hover |
| accent | `--accent` | `#f9fafb` | `bg-accent` | Hover states, subtle highlights |
| accent-foreground | `--accent-foreground` | `#1f2937` | `text-accent-foreground` | Text on accent backgrounds |
| muted | `--muted` | `#fafafa` | `bg-muted` | Disabled backgrounds, subtle fills |
| muted-foreground | `--muted-foreground` | `#71717a` | `text-muted-foreground` | Placeholder text, helper text |
| disabled | `--disabled` | `#d4d4d8` | `bg-disabled` | Disabled control backgrounds |
| disabled-foreground | `--disabled-foreground` | `#a1a1aa` | `text-disabled-foreground` | Disabled text |
| disabled-soft | `--disabled-soft` | `#f4f4f5` | — | Very light disabled backgrounds |

#### Borders & Strokes

| Token | CSS Variable | Hex | Tailwind | Usage |
|-------|-------------|-----|----------|-------|
| border | `--border` | `#0000000F` | `border-border` | Default border color |
| stroke | `--stroke` | `#0000000F` | `stroke-stroke` | SVG strokes, dividers |
| input | `--input` | `#0000000F` | `border-input` | Form input borders |
| ring | `--ring` | `#2182f3` | `ring-ring` | Focus rings |

#### Utility

| Token | CSS Variable | Hex | Tailwind | Usage |
|-------|-------------|-----|----------|-------|
| card | `--card` | `#ffffff` | `bg-card` | Card container background |
| card-foreground | `--card-foreground` | `#09090b` | `text-card-foreground` | Text inside cards |
| popover | `--popover` | `#ffffff` | `bg-popover` | Dropdowns, tooltips, popovers |
| popover-foreground | `--popover-foreground` | `#09090b` | `text-popover-foreground` | Text in popovers |
| destructive | `--destructive` | `#ef4444` | `bg-destructive` | Delete, danger actions |
| destructive-hover | `--destructive-hover` | `#dc2626` | — | Destructive button hover |

### Status Colors

Use `*-solid` for badges/filled states, `*-soft` for backgrounds, `*-soft-foreground` for text on soft backgrounds.

| Semantic | Solid | Solid FG | Soft | Soft FG |
|----------|-------|----------|------|---------|
| success | `#22c55e` | `#f0fdf4` | `#f0fdf4` | `#15803d` |
| warning | `#f59e0b` | `#fffbeb` | `#fffbeb` | `#b45309` |
| error | `#ef4444` | `#fef2f2` | `#fef2f2` | `#b91c1c` |
| info | `#0ea5e9` | `#f0f9ff` | `#f0f9ff` | `#0369a1` |

Tailwind: `bg-success-solid`, `text-success-soft-foreground`, `bg-warning-soft`, etc.

### Service Tier Colors

Each MADIX service tier has its own color set: `soft` (background), `solid` (main), `strong` (text/dark variant).

| Tier | Soft | Solid | Strong | Tailwind prefix |
|------|------|-------|--------|-----------------|
| Lite | `#ffefc6` | `#ffb800` | `#a85905` | `service-lite-*` |
| Smart | `#cff5e9` | `#10b981` | `#098b67` | `service-smart-*` |
| Expert | `#dbe4ff` | `#1d4ed8` | `#032fac` | `service-expert-*` |
| Custom | `#f1f5f9` | `#64748b` | `#475569` | `service-custom-*` |
| Export Voucher | `#def9f4` | `#14b8a6` | `#08897b` | `service-exportvoucher-*` |
| Standard | `#f3e8ff` | `#a855f7` | `#9333ea` | `service-standard-*` |
| Pro | `#e0e7ff` | `#6366f1` | `#4f46e5` | `service-pro-*` |

기본 서비스 등급: Lite / Smart / Expert. Export Voucher는 '수출바우처' 키워드가 나올 때 사용.
Standard / Pro는 더 이상 제공하지 않으므로 데이터로만 존재.

Usage: `bg-service-lite-soft text-service-lite-strong`

### Dark Mode Overrides

Key differences in `.dark`:

| Token | Light | Dark |
|-------|-------|------|
| background | `#ffffff` | `#09090b` |
| foreground | `#09090b` | `#fafafa` |
| surface | `#ffffff` | `#09090b` |
| surface-subtle | `#fafafa` | `#27272a` |
| primary | `#2182f3` | `#156ad9` |
| border | `#e4e4e7` | `#71717a` |
| muted-foreground | `#71717a` | `#52525b` |
| disabled | `#d4d4d8` | `#3f3f46` |

---

## Typography

**Font family:** Pretendard (`--font-sans`)

```css
:root {
  --font-sans: "Pretendard Variable", Pretendard, -apple-system, BlinkMacSystemFont, system-ui, sans-serif;
}
body { font-family: var(--font-sans); }
```

CDN: `https://cdn.jsdelivr.net/gh/orioncactus/pretendard@v1.3.9/dist/web/variable/pretendardvariable-dynamic-subset.min.css`

### Type Scale

| Name | Size | Line Height | Tailwind |
|------|------|-------------|----------|
| 3xs | 11px | 16px | `text-3xs` |
| 2xs | 12px | 18px | `text-2xs` |
| xs | 13px | 20px | `text-xs` |
| sm | 14px | 20px | `text-sm` |
| base (md) | 16px | 24px | `text-base` |
| lg | 18px | 26px | `text-lg` |
| xl | 20px | 28px | `text-xl` |
| 2xl | 24px | 34px | `text-2xl` |
| 3xl | 28px | 38px | `text-3xl` |
| 4xl | 32px | 48px | `text-4xl` |
| 5xl | 40px | 56px | `text-5xl` |
| 6xl | 48px | 64px | `text-6xl` |
| 7xl | 56px | 72px | `text-7xl` |

### Font Weight

| Name | Value | Tailwind |
|------|-------|----------|
| regular | 400 | `font-regular` |
| medium | 500 | `font-medium` |
| semibold | 600 | `font-semibold` |
| bold | 700 | `font-bold` |

### Recommended Text Pairings

- **Page title:** `text-3xl font-semibold text-foreground`
- **Section heading:** `text-xl font-semibold text-foreground`
- **Card title:** `text-base font-semibold text-foreground`
- **Body:** `text-sm font-regular text-foreground`
- **Caption / helper:** `text-xs font-regular text-muted-foreground`
- **Button:** `text-lg font-semibold`
- **Label:** `text-xs font-medium text-foreground`
- **Badge text:** `text-2xs font-medium`

---

## Spacing

Base unit: **4px grid**. All spacing values are multiples of 4px.

| Token | px | Tailwind |
|-------|----|----------|
| 0.5 | 2px | `p-0.5` |
| 1 | 4px | `p-1` |
| 1.5 | 6px | `p-1.5` |
| 2 | 8px | `p-2` |
| 2.5 | 10px | `p-2.5` |
| 3 | 12px | `p-3` |
| 4 | 16px | `p-4` |
| 5 | 20px | `p-5` |
| 6 | 24px | `p-6` |
| 7 | 28px | `p-7` |
| 8 | 32px | `p-8` |
| 9 | 36px | `p-9` |
| 10 | 40px | `p-10` |
| 11 | 44px | `p-11` |
| 12 | 48px | `p-12` |
| 14 | 56px | `p-14` |
| 16 | 64px | `p-16` |
| 18 | 72px | `p-18` |
| 20 | 80px | `p-20` |
| 24 | 96px | `p-24` |

**Common patterns:**
- Inline padding (button, chip): `px-3 py-1.5` or `px-4 py-2`
- Card padding: `p-4` or `p-6`
- Section gap: `gap-4` or `gap-6`
- Page section spacing: `py-8` or `py-12`

---

## Border Radius

| Name | Value | Tailwind | Usage |
|------|-------|----------|-------|
| none | 0 | `rounded-none` | Sharp edges |
| 0.5 | 2px | `rounded-[2px]` | Subtle rounding |
| sm | 4px | `rounded-sm` | Small elements (chips, badges) |
| DEFAULT | 6px | `rounded` | Default (inputs, buttons) |
| md | 8px | `rounded-md` | Cards, panels |
| lg | 12px | `rounded-lg` | Large cards, modals |
| xl | 16px | `rounded-xl` | Feature cards |
| 2xl | 24px | `rounded-2xl` | Hero sections |
| 3xl | 32px | `rounded-3xl` | Large decorative elements |
| full | 9999px | `rounded-full` | Pills, avatars, circular buttons |

**Common patterns:**
- Button / Input: `rounded` (6px)
- Card: `rounded-md` (8px) or `rounded-lg` (12px)
- Badge / chip: `rounded-full` or `rounded-sm`
- Avatar: `rounded-full`
- Modal: `rounded-lg` (12px)

---

## Chart Colors

Use in order for multi-series charts.

| Index | Hex | Tailwind |
|-------|-----|----------|
| chart-1 | `#ea580c` | `text-chart-1` |
| chart-2 | `#0d9488` | `text-chart-2` |
| chart-3 | `#164e63` | `text-chart-3` |
| chart-4 | `#eab308` | `text-chart-4` |
| chart-5 | `#f59e0b` | `text-chart-5` |
| chart-6 | `#84cc16` | `text-chart-6` |
| chart-7 | `#ec4899` | `text-chart-7` |
| chart-8 | `#0ea5e9` | `text-chart-8` |

---

## 빠른 참조 (사람용)

> 코드를 몰라도 됩니다. Claude Code에 아래 내용을 포함해서 말해주세요.

| 용도 | 토큰 이름 | 색상 |
|---|---|---|
| 메인 버튼, 핵심 액션 | `primary` | 테마 메인 색상 |
| 일반 텍스트 | `foreground` | 거의 검정 |
| 페이지 / 카드 배경 | `background` / `surface` | 흰색 계열 |
| 흐린 텍스트, 설명 | `muted-foreground` | 회색 |
| 구분선, 테두리 | `border` | 연한 선 |
| 삭제 / 위험 버튼 | `destructive` | 빨간색 |

**프롬프트 예시:**
- 새 화면: `"DESIGN.md 읽고, [전시부스 서비스]의 [랜딩 페이지] 만들어줘"`
- 수정: `"DESIGN.md 기준으로 [수정할 내용] 바꿔줘. 토큰만 써줘"`
- 컴포넌트: `"DESIGN.md 참고해서 [공동관 서비스] 버튼 컴포넌트 만들어줘"`

---

*Last updated: 2026-04-10 | Source: MADIX Design Token System (Figma variables + globals.css)*
