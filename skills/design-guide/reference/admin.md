# admin 앱 패턴 + 톤앤매너

`apps/admin/` — 어드민 대시보드 (Next.js)

---

## 앱 개요

- **성격**: 내부 어드민 도구. 데이터 관리, 박람회 운영, 사용자 관리 등.
- **톤앤매너**: 명확하고 효율적인, 정보 중심의 대시보드. 데이터 밀도 우선.
- **현황**: madix와 masisi 혼용. admin 전용 masisi 컴포넌트(`apps/admin/src/masisi/`) 존재.
- **주요 패턴**: MadixForm + MadixFormFieldByType 폼 패턴, MasisiTable 목록 패턴.

---

## 컴포넌트 구조 (Atomic Design)

```
apps/admin/src/domain/{domainName}/
├── components/
│   ├── atoms/
│   ├── molecules/
│   ├── organisms/
│   ├── templates/
│   └── pages/
└── hooks/
```

예시 도메인: `company`, `company-member`, `subExpo`, `exhibition`, `flightFee`, `blog`, `estimate` 등

---

## admin 전용 masisi 컴포넌트

admin 앱 내부에 별도의 masisi 컴포넌트가 있다. 기존 목록 페이지에서 자주 사용된다.

```
apps/admin/src/masisi/onDemand/
├── table/
│   ├── MasisiTable.tsx          # grid 기반 테이블 (목록 페이지 표준)
│   ├── MasisiTableWithBottomComponent.tsx
│   └── MasisiTableHeaderSortButton.tsx
├── tab/
│   └── MasisiAdminTab.tsx
├── calendar/
│   ├── MasisiCalendar.tsx
│   └── MasisiTimeline.tsx
├── typography/
│   ├── MasisiAdminTypoWithCopyable.tsx
│   └── MasisiEllipsisButHover.tsx
└── ...
```

```tsx
// admin 전용 컴포넌트 import
import MasisiTable from "@/src/masisi/onDemand/table/MasisiTable";
import MasisiAdminTab from "@/src/masisi/onDemand/tab/MasisiAdminTab";
```

---

## 톤앤매너

### 컬러 원칙

- 중립 톤 우선 (`muted`, `secondary` 등)
- 상태 표시는 시맨틱 토큰 엄격히 준수 (`success-soft`, `error-solid` 등)
- CTA만 `primary` 색상 사용

### 타이포그래피

- 데이터 레이블: `text-sm` (`body6_*` 계열 또는 Tailwind)
- 헤더/섹션 제목: `body4_SemiBold` 또는 `body3_SemiBold`
- 폼 레이블: `body6_SemiBold` (`MasisiTypography`)
- 테이블 내 데이터: `text-sm`

### 버튼

- CTA만 `MadixButton variant="default"`
- 일반 액션: `MadixButton variant="outline"` 또는 `variant="secondary"`
- 저장/확인: `MadixButton size="lg" className="w-full"` (폼 하단 전체 너비)

### 간격 / 레이아웃

- 밀도 있는 레이아웃: `gap-4`, `gap-8` 기준
- 폼 내부: `flex flex-col gap-16` (항목 간 4rem)
- 데스크탑 고정 레이아웃 우선 (반응형보다 데이터 밀도 우선)

---

## MasisiTable 목록 페이지 패턴 (기존 코드)

기존 admin 목록 페이지에서 자주 사용되는 패턴. **MasisiTable**은 admin 전용 컴포넌트다.

```tsx
import MasisiTable from "@/src/masisi/onDemand/table/MasisiTable";
import React from "react";

// tableHead: 컬럼 정의 (gridColumn으로 너비 지정)
// tableRows: React.Fragment로 행 데이터
// withLeftSideComponent: 필터/검색 등 상단 좌측 컴포넌트
// withPagination: 페이지네이션 데이터

const ExampleListTable = ({ data, page }: Props) => {
  const tableRows = data.map((item, index) => (
    <React.Fragment key={index}>
      <Typography>{item.name}</Typography>
      <Typography>{item.email}</Typography>
      <Typography>{item.createdAt}</Typography>
    </React.Fragment>
  ));

  return (
    <MasisiTable
      tableHead={[
        { title: "이름", gridColumn: "0.5fr" },
        { title: "이메일", gridColumn: "1fr" },
        { title: "등록일", gridColumn: "1fr" },
      ]}
      tableRows={tableRows}
      withLeftSideComponent={<FilterComponent />}
      withPagination={page}
    />
  );
};
```

---

## MadixDataTable 패턴 (신규 코드)

tanstack table 기반의 madix 데이터 테이블. 컬럼 정의와 데이터를 분리.

```tsx
import { MadixDataTable } from "@myfair/madix/src/components/ui/data-table";

interface ExhibitionRow {
  id: number;
  title: string;
  status: string;
  startDate: string;
}

const columns = [
  {
    accessorKey: "title",
    header: "박람회명",
    size: 300,
    cell: ({ row }: { row: ExhibitionRow }) => (
      <span className="font-medium">{row.title}</span>
    ),
  },
  {
    accessorKey: "status",
    header: "상태",
    cell: ({ row }: { row: ExhibitionRow }) => (
      <span className={row.status === "ACTIVE" ? "text-success-soft-foreground" : "text-muted-foreground"}>
        {row.status}
      </span>
    ),
  },
  {
    accessorKey: "startDate",
    header: "시작일",
    cell: ({ row }: { row: ExhibitionRow }) => <span>{row.startDate}</span>,
  },
];

<MadixDataTable
  columns={columns}
  data={exhibitions}
  pagination={{
    page: pageData,
    onPageChange: handlePageChange,
  }}
/>
```

---

## MadixForm + MadixFormFieldByType 폼 패턴 (권장)

admin에서 등록/수정 폼 구현 시 표준 패턴. 실제 `FlightFeeSaveOrUpdateForm`, `SubExpoRequiredInfoForm` 등에서 사용된다.

```tsx
import { MadixButton } from "@myfair/madix/src/components/ui/button";
import { MadixForm } from "@myfair/madix/src/components/ui/form";
import { MadixFormFieldByType } from "@myfair/madix/src/components/ui/form-field";
import { useMadixForm } from "@myfair/madix/src/hooks/useMadixForm";
import MasisiTypography from "@myfair/masisi/src/onDemand/typography/MasisiTypography";
import { z } from "zod";

const schema = z.object({
  title: z.string().min(1, "제목을 입력해주세요"),
  type: z.string().min(1, "유형을 선택해주세요"),
  startDate: z.string().optional(),
  endDate: z.string().optional(),
  description: z.string().optional(),
});

type FormData = z.infer<typeof schema>;

interface Props {
  defaultValues?: FormData;
  onSubmit: (data: FormData) => void;
}

const ExampleAdminForm = ({ defaultValues, onSubmit }: Props) => {
  const form = useMadixForm<FormData>({
    schema,
    defaultValues: defaultValues ?? {
      title: "",
      type: "",
      startDate: "",
      endDate: "",
      description: "",
    },
    mode: "onChange",
  });

  return (
    <MadixForm form={form} onSubmit={onSubmit}>
      <div className="flex flex-col gap-16">
        {/* 섹션 구분 */}
        <MasisiTypography variant="body4_SemiBold">기본 정보</MasisiTypography>

        <MadixFormFieldByType
          control={form.control}
          name="title"
          label="제목"
          fieldType="simple"
          fieldProps={{ placeholder: "제목을 입력하세요" }}
          required
        />

        <MadixFormFieldByType
          control={form.control}
          name="type"
          label="유형"
          fieldType="select"
          fieldProps={{
            options: [
              { label: "공지", value: "notice" },
              { label: "이벤트", value: "event" },
            ],
            placeholder: "유형을 선택하세요",
          }}
          required
        />

        <MadixFormFieldByType
          control={form.control}
          name="startDate"
          label="시작일"
          fieldType="datePicker"
          fieldProps={{}}
        />

        <MadixFormFieldByType
          control={form.control}
          name="endDate"
          label="종료일"
          fieldType="datePicker"
          fieldProps={{}}
        />

        <MadixFormFieldByType
          control={form.control}
          name="description"
          label="설명"
          fieldType="textarea"
          fieldProps={{ placeholder: "설명을 입력하세요" }}
        />

        {/* 저장 버튼: 하단 전체 너비 */}
        <MadixButton
          size="lg"
          className="w-full"
          type="submit"
          loading={form.formState.isSubmitting}
        >
          저장
        </MadixButton>
      </div>
    </MadixForm>
  );
};
```

### onInvalid 처리 (스낵바 알림)

```tsx
import useStoreAdminSnackbar from "@/src/store/useStoreAdminSnackbar";

const { showErrorSnackbar } = useStoreAdminSnackbar();

<MadixForm
  form={form}
  onSubmit={onSubmit}
  onInvalid={() => showErrorSnackbar("항목을 입력해주세요.\n붉게 표기된 입력 폼을 확인해주세요.")}
>
```

---

## 주의사항

- 테이블, 리스트, 필터가 많으므로 데이터 밀도 우선
- 반응형보다 데스크탑 고정 레이아웃 우선 (min-w 지정 허용)
- 통계/수치 강조 시 `font-mono` 또는 `font-semibold` 사용 가능
- admin 전용 masisi 컴포넌트(`@/src/masisi/onDemand/...`)는 admin 앱 내부에서만 import
- MadixFormFieldByType는 deprecated가 아닌 정상 사용 컴포넌트 — 폼 구현의 표준 패턴
