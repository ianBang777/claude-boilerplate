# Design Guide 실전 예시

---

## 예시 1 — myfair 상품 카드 컴포넌트 (Atomic Design + 올바른 import)

**파일 경로**: `apps/myfair/src/domain/exhibition/components/molecules/ExhibitionCard.tsx`

### 수정 전 (잘못된 패턴)

```tsx
// 잘못된 import (배럴 import — 빌드 오류 유발)
import { Button, Badge } from '@myfair/madix'

<div className="p-2 rounded bg-gray-100">
  <span className="text-xs text-blue-500 bg-blue-100 px-1">NEW</span>
  <button className="mt-2 bg-blue-500 text-white text-sm px-3 py-1 rounded">
    참가 신청
  </button>
</div>
```

### 수정 후 (올바른 패턴)

```tsx
// apps/myfair/src/domain/exhibition/components/molecules/ExhibitionCard.tsx

import MasisiTypography from "@myfair/masisi/src/onDemand/typography/MasisiTypography";
import MasisiSvgLoader from "@myfair/masisi/src/onDemand/icon/MasisiSvgLoader";
import { MadixButton } from "@myfair/madix/src/components/ui/button";
import { cn } from "@myfair/madix/src/lib/utils";
import styled from "@emotion/styled";
import palette from "@myfair/common/src/style/palette";
import Image from "next/image";

// Emotion 기반 컨테이너 (myfair 기존 스타일 패턴 유지)
const CardContainer = styled.div`
  display: flex;
  flex-direction: column;
  gap: 1rem;
  padding: 1.5rem;
  border-radius: 1rem;
  border: 1px solid ${palette.gray._200};
  background: ${palette.white._1};
  cursor: pointer;
  transition: all 0.2s ease-in-out;

  &:hover {
    border-color: ${palette.blue._500};
    transform: translateY(-2px);
  }
`;

interface ExhibitionCardProps {
  title: string;
  location: string;
  thumbnailUrl: string;
  isNew?: boolean;
  onApply: () => void;
}

export default function ExhibitionCard({
  title,
  location,
  thumbnailUrl,
  isNew,
  onApply,
}: ExhibitionCardProps) {
  return (
    <CardContainer>
      <div className="relative aspect-[4/3] overflow-hidden rounded-8">
        <Image src={thumbnailUrl} alt={title} fill className="object-cover" />
        {isNew && (
          <span className="absolute top-8 left-8 rounded-4 bg-primary px-6 py-2">
            <MasisiTypography variant="label1_SemiBold" className="text-primary-foreground">
              NEW
            </MasisiTypography>
          </span>
        )}
      </div>

      <div className="flex flex-col gap-4">
        <MasisiTypography variant="body4_SemiBold">{title}</MasisiTypography>
        <div className="flex items-center gap-4">
          <MasisiSvgLoader svgKey="Location" width={14} color={palette.gray._500} />
          <MasisiTypography variant="body6_Regular" className="text-muted-foreground">
            {location}
          </MasisiTypography>
        </div>
      </div>

      <MadixButton variant="default" className="w-full" onClick={onApply}>
        참가 신청
      </MadixButton>
    </CardContainer>
  );
}
```

**변경 포인트**:
- 배럴 import → 파일 경로 직접 import
- 인라인 컬러 → 시맨틱 토큰 + palette
- 인라인 span → `MasisiTypography`
- 인라인 button → `MadixButton`
- 파일 경로: Atomic Design 구조 (`molecules/`)

---

## 예시 2 — admin 폼 페이지 (MadixForm + MadixFormFieldByType)

**파일 경로**: `apps/admin/src/domain/blog/components/organisms/BlogPostForm.tsx`

```tsx
// apps/admin/src/domain/blog/components/organisms/BlogPostForm.tsx

import { MadixButton } from "@myfair/madix/src/components/ui/button";
import { MadixForm } from "@myfair/madix/src/components/ui/form";
import { MadixFormFieldByType } from "@myfair/madix/src/components/ui/form-field";
import MadixCheckboxGroupFormField from "@myfair/madix/src/components/ui/checkbox-group";
import { useMadixForm } from "@myfair/madix/src/hooks/useMadixForm";
import MasisiTypography from "@myfair/masisi/src/onDemand/typography/MasisiTypography";
import useStoreAdminSnackbar from "@/src/store/useStoreAdminSnackbar";
import { z } from "zod";

const schema = z.object({
  title: z.string().min(1, "제목을 입력해주세요"),
  category: z.enum(["notice", "guide", "news"] as const, {
    required_error: "카테고리를 선택해주세요",
  }),
  publishDate: z.string().optional(),
  tags: z.array(z.string()).min(1, "태그를 최소 1개 선택해주세요"),
  content: z.string().min(10, "내용을 10자 이상 입력해주세요"),
});

type BlogPostFormData = z.infer<typeof schema>;

interface Props {
  defaultValues?: Partial<BlogPostFormData>;
  onSubmit: (data: BlogPostFormData) => Promise<void>;
}

export default function BlogPostForm({ defaultValues, onSubmit }: Props) {
  const { showErrorSnackbar } = useStoreAdminSnackbar();

  const form = useMadixForm<BlogPostFormData>({
    schema,
    defaultValues: {
      title: "",
      publishDate: "",
      tags: [],
      content: "",
      ...defaultValues,
    },
    mode: "onChange",
  });

  return (
    <MadixForm
      form={form}
      onSubmit={onSubmit}
      onInvalid={() => showErrorSnackbar("필수 항목을 확인해주세요.")}
    >
      <div className="flex flex-col gap-16">
        <MasisiTypography variant="body4_SemiBold">게시글 정보</MasisiTypography>

        {/* 텍스트 입력 */}
        <MadixFormFieldByType
          control={form.control}
          name="title"
          label="제목"
          fieldType="simple"
          fieldProps={{ placeholder: "게시글 제목을 입력하세요" }}
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
              { label: "공지사항", value: "notice" },
              { label: "가이드", value: "guide" },
              { label: "뉴스", value: "news" },
            ],
            placeholder: "카테고리 선택",
          }}
          required
        />

        {/* 날짜 선택 */}
        <MadixFormFieldByType
          control={form.control}
          name="publishDate"
          label="발행일"
          fieldType="datePicker"
          fieldProps={{}}
        />

        {/* 체크박스 그룹 */}
        <MadixCheckboxGroupFormField
          control={form.control}
          name="tags"
          label="태그"
          labelVariant="body6_SemiBold"
          wrapperClassName="flex flex-wrap gap-8"
          options={[
            { label: "박람회", value: "exhibition" },
            { label: "수출바우처", value: "export-voucher" },
            { label: "신규", value: "new" },
          ]}
          required
        />

        {/* 텍스트에어리어 */}
        <MadixFormFieldByType
          control={form.control}
          name="content"
          label="내용"
          fieldType="textarea"
          fieldProps={{ placeholder: "내용을 입력하세요", className: "min-h-[200px]" }}
          required
        />

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
}
```

---

## 예시 3 — admin 목록 테이블 페이지

**파일 경로**: `apps/admin/src/domain/company/components/templates/CompanyListTable.tsx`

```tsx
// apps/admin/src/domain/company/components/templates/CompanyListTable.tsx

import MasisiTable from "@/src/masisi/onDemand/table/MasisiTable";
import { MadixButton } from "@myfair/madix/src/components/ui/button";
import MasisiTypography from "@myfair/masisi/src/onDemand/typography/MasisiTypography";
import MasisiSvgLoader from "@myfair/masisi/src/onDemand/icon/MasisiSvgLoader";
import React from "react";

interface CompanyRow {
  id: number;
  name: string;
  email: string;
  memberCount: number;
  createdAt: string;
  status: "active" | "inactive";
}

interface Props {
  data: CompanyRow[];
  page: any; // MadixPageProps
  onDetail: (id: number) => void;
}

export default function CompanyListTable({ data, page, onDetail }: Props) {
  const tableRows = data.map((company, index) => (
    <React.Fragment key={company.id}>
      <MasisiTypography variant="body6_Regular">{company.name}</MasisiTypography>
      <MasisiTypography variant="body6_Regular">{company.email}</MasisiTypography>
      <MasisiTypography variant="body6_Regular">
        {company.memberCount.toLocaleString()}명
      </MasisiTypography>
      <MasisiTypography variant="body6_Regular">{company.createdAt}</MasisiTypography>
      <span
        className={
          company.status === "active"
            ? "text-success-soft-foreground"
            : "text-muted-foreground"
        }
      >
        <MasisiTypography variant="label1_SemiBold">
          {company.status === "active" ? "활성" : "비활성"}
        </MasisiTypography>
      </span>
      <MadixButton
        variant="outline"
        size="sm"
        onClick={() => onDetail(company.id)}
      >
        상세
      </MadixButton>
    </React.Fragment>
  ));

  return (
    <MasisiTable
      tableHead={[
        { title: "회사명", gridColumn: "1fr" },
        { title: "이메일", gridColumn: "1.5fr" },
        { title: "회원수", gridColumn: "0.5fr" },
        { title: "등록일", gridColumn: "1fr" },
        { title: "상태", gridColumn: "4rem" },
        { title: "관리", gridColumn: "4rem" },
      ]}
      tableRows={tableRows}
      withPagination={page}
    />
  );
}
```

---

## 예시 4 — MasisiSvgLoader + 다이얼로그 (myfair/admin 공통)

**파일 경로**: `apps/myfair/src/common/app/components/molecules/AlertDialog.tsx`

```tsx
// apps/myfair/src/common/app/components/molecules/AlertDialog.tsx

import { MadixButton } from "@myfair/madix/src/components/ui/button";
import { MadixMutationButton } from "@myfair/madix/src/components/ui/mutation-button";
import {
  MadixDialog,
  MadixDialogContent,
  MadixDialogDescription,
  MadixDialogFooter,
  MadixDialogHeader,
  MadixDialogTitle,
} from "@myfair/madix/src/components/ui/dialog";
import { cn } from "@myfair/madix/src/lib/utils";
import MasisiSvgLoader, { MasisiSvgKey } from "@myfair/masisi/src/onDemand/icon/MasisiSvgLoader";
import MasisiTypography from "@myfair/masisi/src/onDemand/typography/MasisiTypography";

type AlertType = "info" | "success" | "warning" | "error";

const alertConfig: Record<AlertType, { svgKey: MasisiSvgKey; colorClass: string }> = {
  info: { svgKey: "InfoFill", colorClass: "text-info-solid" },
  success: { svgKey: "CheckFill", colorClass: "text-success-solid" },
  warning: { svgKey: "Warning", colorClass: "text-warning-solid" },
  error: { svgKey: "WarningFill", colorClass: "text-error-solid" },
};

interface AlertDialogProps {
  open: boolean;
  type?: AlertType;
  title: string;
  description?: string;
  confirmText?: string;
  cancelText?: string;
  onConfirm: () => void | Promise<void>;
  onCancel: () => void;
}

export default function AlertDialog({
  open,
  type = "info",
  title,
  description,
  confirmText = "확인",
  cancelText = "취소",
  onConfirm,
  onCancel,
}: AlertDialogProps) {
  const { svgKey, colorClass } = alertConfig[type];

  return (
    <MadixDialog open={open} onOpenChange={(v) => !v && onCancel()}>
      <MadixDialogContent className="max-w-md">
        <MadixDialogHeader>
          <div className="flex items-center gap-8">
            <MasisiSvgLoader
              svgKey={svgKey}
              width={24}
              className={colorClass}
              ariaLabel={type}
            />
            <MadixDialogTitle>{title}</MadixDialogTitle>
          </div>
        </MadixDialogHeader>

        {description && (
          <MadixDialogDescription>
            <MasisiTypography variant="body5_Regular" className="text-muted-foreground">
              {description}
            </MasisiTypography>
          </MadixDialogDescription>
        )}

        <MadixDialogFooter className="gap-8">
          <MadixButton variant="outline" onClick={onCancel}>
            {cancelText}
          </MadixButton>
          <MadixMutationButton onClick={onConfirm}>
            {confirmText}
          </MadixMutationButton>
        </MadixDialogFooter>
      </MadixDialogContent>
    </MadixDialog>
  );
}
```

---

## 예시 5 — Tailwind v4 커스텀 variant 활용 (myfair 반응형)

**파일 경로**: `apps/myfair/src/domain/pricing/components/organisms/PricingSection.tsx`

```tsx
// apps/myfair/src/domain/pricing/components/organisms/PricingSection.tsx

import MasisiTypography from "@myfair/masisi/src/onDemand/typography/MasisiTypography";
import { MadixButton } from "@myfair/madix/src/components/ui/button";
import { MadixCard, MadixCardContent, MadixCardHeader, MadixCardTitle } from "@myfair/madix/src/components/ui/card";
import { cn } from "@myfair/madix/src/lib/utils";

interface PricingTier {
  name: string;
  price: string;
  features: string[];
  isPopular?: boolean;
  onSelect: () => void;
}

interface PricingSectionProps {
  tiers: PricingTier[];
}

export default function PricingSection({ tiers }: PricingSectionProps) {
  return (
    <section className="flex flex-col gap-32 py-48">
      {/* 섹션 헤더 */}
      <div className="flex flex-col items-center gap-12 text-center">
        <MasisiTypography variant="body2_Bold">요금제 안내</MasisiTypography>
        <MasisiTypography variant="body5_Regular" className="text-muted-foreground">
          비즈니스에 맞는 플랜을 선택하세요
        </MasisiTypography>
      </div>

      {/* 가격 카드 그리드 */}
      {/* pc: min-width 769px, tablet: max-width 768px, mobile: max-width 520px */}
      <div className="grid grid-cols-1 tablet:grid-cols-2 pc:grid-cols-3 gap-16">
        {tiers.map((tier) => (
          <MadixCard
            key={tier.name}
            className={cn(
              "relative flex flex-col gap-16 p-24",
              tier.isPopular && "border-primary shadow-md",
            )}
          >
            {tier.isPopular && (
              <span className="absolute -top-12 left-1/2 -translate-x-1/2 rounded-full bg-primary px-12 py-4">
                <MasisiTypography variant="label1_SemiBold" className="text-primary-foreground">
                  인기
                </MasisiTypography>
              </span>
            )}

            <MadixCardHeader className="p-0">
              <MadixCardTitle>
                <MasisiTypography variant="body3_SemiBold">{tier.name}</MasisiTypography>
              </MadixCardTitle>
              <MasisiTypography variant="body1_Bold" className="text-primary">
                {tier.price}
              </MasisiTypography>
            </MadixCardHeader>

            <MadixCardContent className="flex flex-col gap-8 p-0">
              <ul className="flex flex-col gap-8">
                {tier.features.map((feature) => (
                  <li key={feature} className="flex items-center gap-8">
                    <span className="text-success-solid">✓</span>
                    <MasisiTypography variant="body6_Regular">{feature}</MasisiTypography>
                  </li>
                ))}
              </ul>

              <MadixButton
                variant={tier.isPopular ? "default" : "outline"}
                className="mt-16 w-full"
                onClick={tier.onSelect}
              >
                시작하기
              </MadixButton>
            </MadixCardContent>
          </MadixCard>
        ))}
      </div>
    </section>
  );
}
```

**커스텀 variant 핵심**:
- `pc:grid-cols-3` — 769px 이상에서 3열
- `tablet:grid-cols-2` — 768px 이하에서 2열
- 기본(모바일): 1열 (`grid-cols-1`)

---

## 보고 형식 템플릿

```markdown
## 디자인 변경 완료 보고

- 대상 앱: [myfair / admin / partner / agency / ...]
- 수정 파일: [파일 경로]

### 변경 내역
| 변경 항목 | 변경 전 | 변경 후 | 사용 패키지 |
|-----------|---------|---------|------------|
| 버튼 | 인라인 className | MadixButton variant="default" | madix |
| 텍스트 | 인라인 span | MasisiTypography variant="body5_Regular" | masisi |
| import | 배럴 import | 파일 경로 직접 import | - |

### 금지 항목 확인
- [ ] 수정 범위 외 컴포넌트 수정 없음
- [ ] 핸들러/이벤트 로직 수정 없음
- [ ] API 호출 코드 수정 없음
- [ ] 상태 관리 로직 수정 없음
- [ ] 배럴 import 사용 없음
- [ ] 인라인 컬러값 사용 없음
```
