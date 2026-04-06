# madix 컴포넌트 라이브러리 사용법

`packages/madix` — Radix UI + Tailwind CSS v4 + CVA 기반 1순위 디자인 시스템.

---

## import 패턴

배럴(barrel) export가 없다. **반드시 파일 경로로 직접 import**해야 한다.

```tsx
// 컴포넌트
import { MadixButton } from "@myfair/madix/src/components/ui/button";
import { MadixInput } from "@myfair/madix/src/components/ui/input";
import { MadixTextarea } from "@myfair/madix/src/components/ui/textarea";
import { MadixSelect, MadixSelectContent, MadixSelectItem, MadixSelectTrigger, MadixSelectValue } from "@myfair/madix/src/components/ui/select";
import { MadixCheckbox } from "@myfair/madix/src/components/ui/checkbox";
import { MadixRadio, MadixRadioGroup } from "@myfair/madix/src/components/ui/radio-group";
import { MadixSwitch } from "@myfair/madix/src/components/ui/switch";
import { MadixChipGroup } from "@myfair/madix/src/components/ui/chip-group";
import { MadixLabel } from "@myfair/madix/src/components/ui/label";
import { MadixCard, MadixCardContent, MadixCardHeader, MadixCardTitle } from "@myfair/madix/src/components/ui/card";
import { MadixDialog, MadixDialogContent, MadixDialogHeader, MadixDialogTitle, MadixDialogFooter } from "@myfair/madix/src/components/ui/dialog";
import { MadixDrawer, MadixDrawerContent } from "@myfair/madix/src/components/ui/drawer";
import { MadixTabs, MadixTabsList, MadixTabsTrigger, MadixTabsContent } from "@myfair/madix/src/components/ui/tabs";
import { MadixAccordion, MadixAccordionItem, MadixAccordionTrigger, MadixAccordionContent } from "@myfair/madix/src/components/ui/accordion";
import { MadixPopover, MadixPopoverContent, MadixPopoverTrigger } from "@myfair/madix/src/components/ui/popover";
import { MadixDropdownMenu, MadixDropdownMenuContent, MadixDropdownMenuItem, MadixDropdownMenuTrigger } from "@myfair/madix/src/components/ui/dropdown-menu";
import { MadixTooltip, MadixTooltipContent, MadixTooltipTrigger } from "@myfair/madix/src/components/ui/tooltip";
import MadixPagination from "@myfair/madix/src/components/ui/pagination";
import { MadixSketchTable, MadixSketchTableBody, MadixSketchTableCell, MadixSketchTableHead, MadixSketchTableHeader, MadixSketchTableRow } from "@myfair/madix/src/components/ui/table";
import { MadixDataTable } from "@myfair/madix/src/components/ui/data-table";  // tanstack table 기반
import { MadixSpinner } from "@myfair/madix/src/components/ui/spinner";
import { MadixMutationButton } from "@myfair/madix/src/components/ui/mutation-button";
import { MadixDatePicker } from "@myfair/madix/src/components/ui/date-picker";
import { MadixTimePicker } from "@myfair/madix/src/components/ui/time-picker";
import { MadixMonthPicker } from "@myfair/madix/src/components/ui/month-picker";
import { MadixDateTimePicker } from "@myfair/madix/src/components/ui/datetime-picker";
import { MadixChart } from "@myfair/madix/src/components/ui/chart";
import { MadixDonutPieChart } from "@myfair/madix/src/components/ui/donut-pie-chart";
import { MadixMarquee } from "@myfair/madix/src/components/ui/marquee";
import { MadixKBD } from "@myfair/madix/src/components/ui/kbd";

// 폼 시스템
import { MadixForm, MadixFormControl, MadixFormField, MadixFormItem, MadixFormLabel, MadixFormMessage } from "@myfair/madix/src/components/ui/form";
import { MadixFormFieldByType } from "@myfair/madix/src/components/ui/form-field";
import MadixCheckboxGroupFormField from "@myfair/madix/src/components/ui/checkbox-group";
import { useMadixForm } from "@myfair/madix/src/hooks/useMadixForm";

// 유틸리티
import { cn } from "@myfair/madix/src/lib/utils";
```

---

## 컴포넌트 전체 목록 (37개)

### 폼/입력 컴포넌트

| 컴포넌트 | 파일 | 설명 |
|---------|------|------|
| `MadixButton` | `button.tsx` | 기본 버튼 (variant/size 지원) |
| `MadixMutationButton` | `mutation-button.tsx` | 비동기 액션 버튼 (로딩 상태 내장) |
| `MadixInput` | `input.tsx` | 텍스트 입력 |
| `MadixTextarea` | `textarea.tsx` | 멀티라인 입력 |
| `MadixSelect` | `select.tsx` | 드롭다운 선택 |
| `MadixCheckbox` | `checkbox.tsx` | 체크박스 |
| `MadixRadioGroup` / `MadixRadio` | `radio-group.tsx` | 라디오 그룹 |
| `MadixSwitch` | `switch.tsx` | 토글 스위치 |
| `MadixChipGroup` | `chip-group.tsx` | 칩 그룹 선택 |
| `MadixLabel` | `label.tsx` | 레이블 |
| `MadixDatePicker` | `date-picker.tsx` | 날짜 선택 |
| `MadixTimePicker` | `time-picker.tsx` | 시간 선택 |
| `MadixMonthPicker` | `month-picker.tsx` | 월 선택 |
| `MadixDateTimePicker` | `datetime-picker.tsx` | 날짜+시간 선택 |

### 레이아웃/UI 컴포넌트

| 컴포넌트 | 파일 | 설명 |
|---------|------|------|
| `MadixCard` | `card.tsx` | 카드 컨테이너 |
| `MadixSketchTable` (+ 서브컴포넌트) | `table.tsx` | 기본 테이블 |
| `MadixDataTable` | `data-table.tsx` | tanstack table 기반 데이터 테이블 |
| `MadixPagination` | `pagination.tsx` | 페이지네이션 |
| `MadixAccordion` | `accordion.tsx` | 아코디언 |
| `MadixTabs` | `tabs.tsx` | 탭 |
| `MadixDialog` | `dialog.tsx` | 모달 다이얼로그 |
| `MadixDrawer` | `drawer.tsx` | 사이드 드로워 |
| `MadixPopover` | `popover.tsx` | 팝오버 |
| `MadixDropdownMenu` | `dropdown-menu.tsx` | 드롭다운 메뉴 |
| `MadixContextMenu` | `context-menu.tsx` | 컨텍스트 메뉴 |
| `MadixMenuBar` | `menu-bar.tsx` | 메뉴바 |
| `MadixTooltip` | `tooltip.tsx` | 툴팁 |
| `MadixMarquee` | `marquee.tsx` | 마퀴 (자동 스크롤) |
| `MadixKBD` | `kbd.tsx` | 키보드 단축키 표시 |
| `MadixSpinner` | `spinner.tsx` | 로딩 스피너 |

### 차트

| 컴포넌트 | 파일 | 설명 |
|---------|------|------|
| `MadixChart` | `chart.tsx` | 차트 (recharts 기반) |
| `MadixDonutPieChart` | `donut-pie-chart.tsx` | 도넛/파이 차트 |

### 폼 시스템

| 컴포넌트 | 파일 | 설명 |
|---------|------|------|
| `MadixForm` | `form.tsx` | 폼 래퍼 (react-hook-form FormProvider) |
| `MadixFormField` | `form.tsx` | 개별 필드 래퍼 (Controller) |
| `MadixFormControl` | `form.tsx` | 폼 컨트롤 슬롯 |
| `MadixFormItem` | `form.tsx` | 필드 + 레이블 + 메시지 묶음 |
| `MadixFormLabel` | `form.tsx` | 폼 레이블 |
| `MadixFormMessage` | `form.tsx` | 검증 오류 메시지 |
| `MadixFormFieldByType` | `form-field.tsx` | 타입별 폼 필드 통합 컴포넌트 |
| `MadixCheckboxGroupFormField` | `checkbox-group.tsx` | 체크박스 그룹 폼 필드 |

---

## CVA 기반 variant/size 시스템

madix 컴포넌트는 `class-variance-authority(CVA)`로 variant를 정의한다.

### MadixButton

```tsx
import { MadixButton } from "@myfair/madix/src/components/ui/button";

// variant: default | secondary | destructive | outline | ghost | link
// size: xs | sm | default(md) | lg | xl | icon

<MadixButton variant="default" size="default">저장</MadixButton>
<MadixButton variant="outline" size="sm">취소</MadixButton>
<MadixButton variant="destructive">삭제</MadixButton>
<MadixButton variant="ghost" size="icon" icon="Close" />  // icon prop으로 MasisiSvgKey 사용 가능
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
import { useMadixForm } from "@myfair/madix/src/hooks/useMadixForm";
import { z } from "zod";

const schema = z.object({
  title: z.string().min(1, "제목을 입력해주세요"),
  email: z.string().email("올바른 이메일 형식이 아닙니다"),
});

type FormData = z.infer<typeof schema>;

const form = useMadixForm<FormData>({
  schema,
  defaultValues: { title: "", email: "" },
  mode: "onChange",  // 기본값, 생략 가능
});
```

### MadixForm + MadixFormFieldByType (권장 패턴)

`MadixFormFieldByType`은 `fieldType` prop으로 다양한 입력 유형을 지원하는 통합 폼 필드 컴포넌트다. **deprecated가 아닌 정상 사용 컴포넌트**다.

```tsx
import { MadixForm } from "@myfair/madix/src/components/ui/form";
import { MadixFormFieldByType } from "@myfair/madix/src/components/ui/form-field";
import { MadixButton } from "@myfair/madix/src/components/ui/button";
import { useMadixForm } from "@myfair/madix/src/hooks/useMadixForm";
import { z } from "zod";

const schema = z.object({
  title: z.string().min(1, "제목 필수"),
  category: z.string().min(1, "카테고리 선택"),
  startDate: z.string().optional(),
  note: z.string().optional(),
});

type FormData = z.infer<typeof schema>;

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

**MadixFormFieldByType fieldType 목록**:
- `simple` — 텍스트/이메일/비밀번호/숫자 input
- `select` — 드롭다운 선택
- `datePicker` — 날짜 선택
- `dateTimePicker` — 날짜+시간 선택
- `timePicker` — 시간 선택
- `radioGroup` — 라디오 그룹
- `textarea` — 멀티라인 입력

### MadixForm props

```tsx
<MadixForm
  form={form}           // useMadixForm 반환값 (필수)
  onSubmit={handleSubmit}  // 검증 성공 시 콜백
  onInvalid={handleInvalid}  // 검증 실패 시 콜백 (errorInfos: MadixFieldErrorInfo[] 전달)
  className="..."
>
```

### MadixFormField (저수준 — 커스텀 입력 시 사용)

```tsx
import { MadixForm, MadixFormControl, MadixFormField, MadixFormItem, MadixFormLabel, MadixFormMessage } from "@myfair/madix/src/components/ui/form";

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

## 유틸리티

### cn()

`tailwind-merge` 기반 className 합성 함수. 조건부 클래스에 사용.

```tsx
import { cn } from "@myfair/madix/src/lib/utils";

<div className={cn("base-class", isActive && "active-class", className)} />
```

---

## 시맨틱 토큰 전체 목록

`packages/madix/src/styles/madix.css` 기준 (`:root` 기본 테마).

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
| `--success-solid-foreground` | 성공 진한 위 텍스트 |
| `--success-soft-foreground` | 성공 옅은 위 텍스트 |
| `--warning-solid` | 경고 진한 배경 (amber) |
| `--warning-soft` | 경고 옅은 배경 |
| `--warning-solid-foreground` | 경고 진한 위 텍스트 |
| `--warning-soft-foreground` | 경고 옅은 위 텍스트 |
| `--error-solid` | 에러 진한 배경 (red) |
| `--error-soft` | 에러 옅은 배경 |
| `--error-solid-foreground` | 에러 진한 위 텍스트 |
| `--error-soft-foreground` | 에러 옅은 위 텍스트 |
| `--info-solid` | 정보 진한 배경 (sky) |
| `--info-soft` | 정보 옅은 배경 |
| `--info-solid-foreground` | 정보 진한 위 텍스트 |
| `--info-soft-foreground` | 정보 옅은 위 텍스트 |

### UI 요소

| 토큰 | 설명 |
|------|------|
| `--border` | 기본 테두리 |
| `--input` | 입력 필드 테두리 |
| `--ring` | 포커스 링 |
| `--stroke` | 구분선 |
| `--muted` | 비활성/배경 (gray-50) |
| `--muted-foreground` | 비활성 텍스트 |
| `--disabled` | 비활성화 배경 |
| `--disabled-foreground` | 비활성화 텍스트 |

### 카드/팝오버

| 토큰 | 설명 |
|------|------|
| `--card` | 카드 배경 |
| `--card-foreground` | 카드 텍스트 |
| `--popover` | 팝오버 배경 |
| `--popover-foreground` | 팝오버 텍스트 |

### 차트

`--chart-1` ~ `--chart-8` — 차트 색상 시리즈

### 서비스 등급

서비스 플랜별 색상. 각각 `-soft`, `-solid`, `-strong` 세 단계 제공.

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

madix.css에 정의된 테마 variant:

```tsx
// dark 테마 — .root-dark 클래스 적용 시
<div className="dark:bg-background dark:text-foreground" />

// pavilion 테마 — .pavilion 클래스 적용 시
<div className="pavilion:bg-primary" />

// space-only 테마 — .space-only 클래스 적용 시
```

테마별 토큰 값은 `packages/madix/src/styles/madix.css`의 `.root-dark` 섹션 참조.
