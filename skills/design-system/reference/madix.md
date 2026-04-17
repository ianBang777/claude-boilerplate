# Madix 컴포넌트 라이브러리

`packages/madix` — Radix UI + Tailwind CSS v4 + CVA 기반 1순위 디자인 시스템.

---

## 컴포넌트 전체 목록

### 폼/입력 컴포넌트

| 컴포넌트 | 설명 |
|---------|------|
| `MadixButton` | 기본 버튼 (variant/size 지원) |
| `MadixMutationButton` | 비동기 액션 버튼 (로딩 상태 내장) |
| `MadixInput` | 텍스트 입력 |
| `MadixTextarea` | 멀티라인 입력 |
| `MadixSelect` | 드롭다운 선택 |
| `MadixCheckbox` | 체크박스 |
| `MadixRadioGroup` / `MadixRadio` | 라디오 그룹 |
| `MadixSwitch` | 토글 스위치 |
| `MadixChipGroup` | 칩 그룹 선택 |
| `MadixLabel` | 레이블 |
| `MadixDatePicker` | 날짜 선택 |
| `MadixTimePicker` | 시간 선택 |
| `MadixMonthPicker` | 월 선택 |
| `MadixDateTimePicker` | 날짜+시간 선택 |

### 레이아웃/UI 컴포넌트

| 컴포넌트 | 설명 |
|---------|------|
| `MadixCard` | 카드 컨테이너 |
| `MadixSketchTable` (+ 서브컴포넌트) | 기본 테이블 |
| `MadixDataTable` | tanstack table 기반 데이터 테이블 |
| `MadixPagination` | 페이지네이션 |
| `MadixAccordion` | 아코디언 |
| `MadixTabs` | 탭 |
| `MadixDialog` | 모달 다이얼로그 |
| `MadixDrawer` | 사이드 드로워 |
| `MadixPopover` | 팝오버 |
| `MadixDropdownMenu` | 드롭다운 메뉴 |
| `MadixContextMenu` | 컨텍스트 메뉴 |
| `MadixMenuBar` | 메뉴바 |
| `MadixTooltip` | 툴팁 |
| `MadixMarquee` | 마퀴 (자동 스크롤) |
| `MadixKBD` | 키보드 단축키 표시 |
| `MadixSpinner` | 로딩 스피너 |

### 차트

| 컴포넌트 | 설명 |
|---------|------|
| `MadixChart` | 차트 (recharts 기반) |
| `MadixDonutPieChart` | 도넛/파이 차트 |

### 폼 시스템

| 컴포넌트 | 설명 |
|---------|------|
| `MadixForm` | 폼 래퍼 (react-hook-form FormProvider) |
| `MadixFormField` | 개별 필드 래퍼 (Controller) |
| `MadixFormControl` | 폼 컨트롤 슬롯 |
| `MadixFormItem` | 필드 + 레이블 + 메시지 묶음 |
| `MadixFormLabel` | 폼 레이블 |
| `MadixFormMessage` | 검증 오류 메시지 |
| `MadixFormFieldByType` | 타입별 폼 필드 통합 컴포넌트 |
| `MadixCheckboxGroupFormField` | 체크박스 그룹 폼 필드 |

---

## MadixButton

```tsx
// variant: default | secondary | destructive | outline | ghost | link
// size: xs | sm | default(md) | lg | xl | icon

<MadixButton variant="default" size="default">저장</MadixButton>
<MadixButton variant="outline" size="sm">취소</MadixButton>
<MadixButton variant="destructive">삭제</MadixButton>
<MadixButton variant="ghost" size="icon" icon="Close" />
```

**variant 설명**:
- `default` — primary 색상 (파란색 채우기)
- `secondary` — 회색 채우기
- `destructive` — 빨간색 채우기 (위험 액션)
- `outline` — 테두리만
- `ghost` — 배경 없음, hover 시 accent
- `link` — 텍스트 링크 스타일

---

## 폼 시스템

### useMadixForm

`react-hook-form` + `zod` 조합을 내장한 커스텀 훅. `zodResolver`가 자동 설정된다.

```tsx
const schema = z.object({
  title: z.string().min(1, "제목을 입력해주세요"),
  email: z.string().email("올바른 이메일 형식이 아닙니다"),
});

type FormData = z.infer<typeof schema>;

const form = useMadixForm<FormData>({
  schema,
  defaultValues: { title: "", email: "" },
});
```

### MadixForm + MadixFormFieldByType (권장 패턴)

`MadixFormFieldByType`은 `fieldType` prop으로 다양한 입력 유형을 지원하는 통합 폼 필드 컴포넌트다.

```tsx
function ExampleForm({ onSubmit }: { onSubmit: (data: FormData) => void }) {
  const form = useMadixForm<FormData>({
    schema,
    defaultValues: { title: "", category: "", startDate: "", note: "" },
  });

  return (
    <MadixForm form={form} onSubmit={onSubmit}>
      <div className="flex flex-col gap-16">
        {/* 텍스트 입력 */}
        <MadixFormFieldByType
          control={form.control}
          name="title"
          label="제목"
          fieldType="simple"
          fieldProps={{ placeholder: "제목을 입력하세요" }}
          required
        />

        {/* 셀렉트 */}
        <MadixFormFieldByType
          control={form.control}
          name="category"
          label="카테고리"
          fieldType="select"
          fieldProps={{
            options: [
              { label: "공지", value: "notice" },
              { label: "FAQ", value: "faq" },
            ],
            placeholder: "선택하세요",
          }}
          required
        />

        {/* 날짜 선택 */}
        <MadixFormFieldByType
          control={form.control}
          name="startDate"
          label="시작일"
          fieldType="datePicker"
          fieldProps={{}}
        />

        {/* 텍스트에어리어 */}
        <MadixFormFieldByType
          control={form.control}
          name="note"
          label="메모"
          fieldType="textarea"
          fieldProps={{ placeholder: "메모를 입력하세요" }}
        />

        <MadixButton type="submit">저장</MadixButton>
      </div>
    </MadixForm>
  );
}
```

**fieldType 목록**:
- `simple` — 텍스트/이메일/비밀번호/숫자 input
- `select` — 드롭다운 선택
- `datePicker` — 날짜 선택
- `dateTimePicker` — 날짜+시간 선택
- `timePicker` — 시간 선택
- `radioGroup` — 라디오 그룹
- `textarea` — 멀티라인 입력

### MadixFormField (저수준 — 커스텀 입력 시)

```tsx
<MadixFormField
  control={form.control}
  name="fieldName"
  render={({ field }) => (
    <MadixFormItem>
      <MadixFormLabel>레이블</MadixFormLabel>
      <MadixFormControl>
        <MadixInput {...field} placeholder="입력" />
      </MadixFormControl>
      <MadixFormMessage />
    </MadixFormItem>
  )}
/>
```

---

## cn() 유틸리티

`tailwind-merge` 기반 className 합성 함수.

```tsx
<div className={cn("base-class", isActive && "active-class", className)} />
```

---

## 시맨틱 토큰 전체 목록

### 기본

| 토큰 | Tailwind 클래스 예 | 설명 |
|------|------------------|------|
| `--primary` | `text-primary`, `bg-primary` | 주 색상 (blue) |
| `--primary-foreground` | `text-primary-foreground` | primary 위의 텍스트 |
| `--secondary` | `bg-secondary` | 보조 색상 |
| `--secondary-foreground` | `text-secondary-foreground` | secondary 위의 텍스트 |
| `--foreground` | `text-foreground` | 기본 텍스트 색상 |
| `--background` | `bg-background` | 기본 배경 |
| `--accent` | `bg-accent` | 강조 배경 |
| `--accent-foreground` | `text-accent-foreground` | 강조 위의 텍스트 |
| `--destructive` | `bg-destructive`, `text-destructive` | 위험/삭제 색상 (red) |

### 표면

| 토큰 | 설명 |
|------|------|
| `--surface` | 기본 표면 (흰색) |
| `--surface-subtle` | 미묘한 표면 (gray-50) |
| `--surface-foreground` | 표면 위 텍스트 |
| `--surface-foreground-subtle` | 표면 위 미묘한 텍스트 |
| `--surface-overlay` | 오버레이 표면 |
| `--surface-foreground-overlay` | 오버레이 위 텍스트 |

### 상태

| 토큰 | 설명 |
|------|------|
| `--success-solid` | 성공 진한 배경 (green) |
| `--success-soft` | 성공 옅은 배경 |
| `--warning-solid` | 경고 진한 배경 (amber) |
| `--warning-soft` | 경고 옅은 배경 |
| `--error-solid` | 에러 진한 배경 (red) |
| `--error-soft` | 에러 옅은 배경 |
| `--info-solid` | 정보 진한 배경 (sky) |
| `--info-soft` | 정보 옅은 배경 |

### UI 요소

| 토큰 | 설명 |
|------|------|
| `--border` | 기본 테두리 |
| `--input` | 입력 필드 테두리 |
| `--ring` | 포커스 링 |
| `--muted` | 비활성/배경 (gray-50) |
| `--muted-foreground` | 비활성 텍스트 |
| `--disabled` | 비활성화 배경 |
| `--disabled-foreground` | 비활성화 텍스트 |

### 서비스 등급

각각 `-soft`, `-solid`, `-strong` 세 단계.

| 서비스 | 색상 |
|--------|------|
| `service-lite-*` | 골드 (amber) |
| `service-standard-*` | 보라 (purple) |
| `service-pro-*` | 인디고 |
| `service-smart-*` | 에메랄드 |
| `service-expert-*` | 짙은 파랑 |
| `service-custom-*` | 슬레이트 |
| `service-exportvoucher-*` | 청록 (teal) |

---

## 테마 시스템

```tsx
// dark 테마 — .root-dark 클래스 적용 시
<div className="dark:bg-background dark:text-foreground" />

// pavilion 테마 — .pavilion 클래스 적용 시
<div className="pavilion:bg-primary" />
```
