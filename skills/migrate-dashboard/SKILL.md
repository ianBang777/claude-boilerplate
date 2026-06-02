---
name: migrate-dashboard
description: >
  대시보드 프로젝트의 특정 페이지를 admin 대시보드로 이관한다.
  UI 이식 + CSV 데이터를 대체하는 API 연동을 함께 처리한다.
tags: ["typescript", "frontend", "backend", "api"]
applies_to: ["code"]
---

# migrate-dashboard

로컬 CSV 데이터를 사용하는 대시보드 페이지를 분석하여,
실제 프로젝트의 admin 대시보드 경로에 동일한 UI를 구현하고
CSV를 대체하는 API를 연동한다.

---

## 프로젝트 경로

| 역할 | 경로 |
|---|---|
| 대시보드 원본 프로젝트 | `documents/repo/myfair-biz-dashboard-repo` |
| Admin 대시보드 프로젝트 | `documents/repo/client/apps/admin` |

---

## 트리거 조건

다음 중 하나에 해당할 때 이 스킬을 사용한다.

- "대시보드 이관해줘"
- "대시보드 프로젝트 → admin으로 옮겨줘"
- "CSV 대시보드를 API 기반으로 전환해줘"
- 특정 대시보드 페이지 경로 + API DTO를 함께 제공받은 경우

---

## 입력 파라미터

이 스킬을 실행하기 위해 다음 정보가 반드시 필요하다.
누락된 항목이 있으면 작업을 시작하지 않고 요청한다.

| 파라미터 | 설명 | 예시 |
|---|---|---|
| `source_page` | 이관할 대시보드 프로젝트의 페이지 도메인 경로 | `finance/sales` |
| `target_path` | admin 대시보드에서의 목적지 경로 | `dashboard/biz/finance` |
| `api_dto` | CSV를 대체하는 API의 응답 DTO (타입 정의 또는 JSON 샘플) | `FinanceSalesResponse` |

**선택 입력**:

| 파라미터 | 설명 |
|---|---|
| `api_endpoint` | 이미 구현된 API 경로 — 예: `GET /api/v1/stats/finance/sales`. 없으면 mock 데이터로 구현 |

---

## 실행 단계

### 1단계: 소스 페이지 분석

대시보드 프로젝트의 `src/domain/{source_page}/` 및 `src/app/{source_page}/` 를 읽고 다음을 파악한다.

**UI 구조 파악**:
- 컴포넌트 트리 (차트·KPI 카드·테이블 구성)
- 연도/분기/월 필터 사용 방식 (`useUrlFilters` 훅 참조)
- 집계 로직 위치 (`fin-buckets.ts` 등 lib/ 유틸 확인)
- 차트 종류 및 시리즈 구성 (단일 라인, 다중 라인, 바 차트 등)

**의존 파일 추적**:
- 임포트된 컴포넌트·유틸·타입 재귀 파악
- admin 프로젝트에 이미 동일하거나 유사한 컴포넌트가 있는지 확인

---

### 2단계: CSV-DTO 필드 매핑 및 데이터 충족 여부 확인

이 단계가 **이관의 핵심**이다. CSV 컬럼과 API DTO 필드가 1:1로 일치하지 않는 것이 일반적이며, 이를 정확히 분석해야 한다.

#### 2-1. 매핑 표 작성

CSV에서 사용하는 필드와 DTO 필드를 대조하여 다음 표를 작성한다.

```
| CSV 컬럼       | DTO 필드        | 관계         | 변환 방법                        |
|----------------|-----------------|--------------|----------------------------------|
| date           | year, month     | 1:1 분리     | `${year}-${String(month).padStart(2,'0')}`|
| total_sales    | sales           | 1:1          | -                                |
| total_profit   | (없음)          | 파생값       | sales - purchase 로 프론트 계산  |
| cnt            | count           | 1:1 (이름 다름) | -                             |
```

**관계 유형 분류**:
- `1:1`: 필드명이나 포맷만 다름 → 단순 변환
- `파생값`: DTO의 다른 필드들로 계산 가능 → 프론트 계산 로직 작성
- `집계 필요`: DTO가 월별 데이터인데 화면에서 분기/연도별 집계 필요 → 프론트 집계 유틸 작성
- `누락`: DTO에 없고 계산도 불가능 → **`[ASK]`** 처리

#### 2-2. 불일치 항목 처리 원칙

**`[ASK]` — 구현 전 사용자에게 반드시 공지하고 확인**:
- DTO에 해당 데이터가 없고 다른 필드로도 계산이 불가능한 경우
- 어떤 필드가 누락됐는지, 화면에서 어떤 용도로 쓰였는지 명시하여 공지

```
[ASK] CSV의 `total_profit` 필드가 DTO에 없습니다.
      화면: 매출이익 KPI 카드 및 이익 추이 차트에 사용
      확인: DTO의 `sales - purchase` 로 프론트 계산해도 되는지,
            아니면 백엔드에서 profit 필드를 추가해야 하는지 결정이 필요합니다.
```

**`[INFO]` — 공지만 하고 자동 처리**:
- 필드명이 다르지만 값이 같은 경우 → 매핑 후 진행
- 타입/포맷이 다른 경우 → 변환 유틸 작성 후 진행
- DTO가 월별 데이터만 있어 연도별/분기별을 프론트에서 집계하는 경우 → 집계 유틸 작성 후 진행

**[ASK] 항목이 있으면 사용자 확인 전까지 구현을 시작하지 않는다.**

---

### 3단계: 기간 필터 및 집계 전략 결정

대부분의 대시보드는 **연도별 / 분기별 / 월별** 필터와 **2023년부터의 연도 선택**을 제공한다.

#### 3-1. DTO 응답 단위 확인

| DTO 응답 단위 | 처리 방법 |
|---|---|
| 월별 데이터 배열 | 연도별/분기별은 프론트에서 집계 (`aggregateByPeriod` 유틸 작성) |
| 연도별 데이터 배열 | 그대로 사용, 월별/분기별은 별도 API 필요 여부 확인 |
| 단일 집계값 | 기간 필터 UI를 숨기거나 비활성화 |

#### 3-2. 집계 유틸 작성 위치

DTO가 월별 데이터만 내려올 경우, 아래 위치에 집계 유틸을 작성한다.

```
src/domain/biz/{domain}/lib/aggregate.ts
```

연도별: 월별 데이터를 연도로 그룹핑 후 합산
분기별: 월별 데이터를 Q1(1-3월), Q2(4-6월), Q3(7-9월), Q4(10-12월)로 그룹핑 후 합산

#### 3-3. 필터 컴포넌트 재사용

admin 프로젝트의 `BizDashboardFilter` 컴포넌트를 그대로 사용한다.
연도 범위는 `AVAILABLE_BIZ_YEARS` 상수 (2023년~현재)를 따른다.

---

### 4단계: admin 코드베이스 파악

`target_path` 기준으로 admin 프로젝트의 구조를 파악한다.

**확인 항목**:
- `src/domain/biz/common/` 하위 공통 컴포넌트 목록 (LineChartCard, KpiCard, TrendIndicator 등)
- 이관 대상 차트 종류가 공통 컴포넌트로 이미 구현됐는지 확인
- 기존 `dashboard/biz/` 페이지의 파일 구조 및 네이밍 컨벤션

---

### 5단계: 구현 계획 수립

| 항목 | 내용 |
|---|---|
| 생성할 파일 | 경로 및 컴포넌트명 목록 |
| 재사용할 기존 컴포넌트 | admin 공통 컴포넌트 (LineChartCard, KpiCard 등) |
| 새로 작성할 공통 컴포넌트 | 필요한 차트 타입이 공통 컴포넌트에 없는 경우 |
| 집계 유틸 | DTO가 월별 데이터인 경우 집계 유틸 경로 |
| API 훅 | TanStack Query 훅 위치 및 명칭 |
| 타입 파일 | DTO 타입 정의 위치 |
| [ASK] 항목 | 구현 전 사용자 확인이 필요한 사항 |

**[ASK] 항목이 하나라도 있으면 사용자 확인 후 구현을 시작한다.**

---

### 6단계: 구현

#### 6-1. 공통 차트 컴포넌트 추가 (필요한 경우)

현재 admin 공통 컴포넌트로 `LineChartCard`만 구현되어 있다.
소스 페이지에서 다른 차트 타입(바 차트, 파이 차트 등)이 필요한 경우,
**새로운 공통 컴포넌트를 먼저 작성**하고 해당 페이지에서 사용한다.

```
공통 컴포넌트 위치: src/domain/biz/common/components/atoms/
```

새 공통 컴포넌트 작성 원칙:
- 기존 `LineChartCard` 패턴을 따른다 (props 네이밍, 타입 정의 방식)
- recharts를 직접 사용하지 않고 공통 래퍼 컴포넌트를 통해 사용한다
- `yTickFormatter`, `height` 등 공통 커스터마이징 props를 제공한다

#### 6-2. 타입 정의

`api_dto` 기준으로 TypeScript 타입을 작성한다.
`skills/typescript/SKILL.md` 원칙을 따른다 (`any` 금지, `enum` 금지 → Union Type 사용).

```
타입 파일 위치: src/domain/biz/{domain}/types/ 또는 src/api/pages/{domain}/statistics/
```

#### 6-3. 집계 유틸 (DTO가 월별 데이터인 경우)

```typescript
// src/domain/biz/{domain}/lib/aggregate.ts
export function aggregateByPeriod<T>(
  monthlyData: T[],
  period: BizPeriodType,
  getYear: (row: T) => number,
  getMonth: (row: T) => number,
  sumFields: (acc: T, cur: T) => T,
): T[]
```

#### 6-4. API 연동 전략

`api_endpoint` 제공 여부에 따라 두 가지 경로로 구현한다.

**Case A: `api_endpoint` 있음 (API 이미 존재)**

기존 admin 프로젝트의 Repository + useQuery 패턴을 따른다.

```typescript
// src/api/query/{domain}/useFetch{Domain}Statistics.ts
export function useFetch{Domain}Statistics(params: {Domain}SearchRequest) {
  return useQuery({
    queryKey: ["{domain}-statistics", params],
    queryFn: () => {Domain}StatisticsRepository.findAll(params),
  });
}
```

**Case B: `api_endpoint` 없음 (API 미구현)**

mock 데이터를 만들어 UI를 먼저 완성한다.
실제 API가 연결될 때 훅의 `queryFn`만 교체하면 되도록 인터페이스를 동일하게 구성한다.

mock 데이터 위치:
```
src/domain/biz/{domain}/mocks/{domain}Mock.ts
```

```typescript
// src/domain/biz/{domain}/mocks/{domain}Mock.ts
// DTO 타입 기반으로 현실적인 샘플 데이터 작성 (2023년 1월~현재월 월별 데이터)
export const {DOMAIN}_MOCK_DATA: {Domain}MonthlyItem[] = [
  { year: 2023, month: 1, sales: 12000000, purchase: 8000000 },
  { year: 2023, month: 2, sales: 13500000, purchase: 8500000 },
  // ...
];

// src/api/query/{domain}/useFetch{Domain}Statistics.ts
export function useFetch{Domain}Statistics(_params: {Domain}SearchRequest) {
  return useQuery({
    queryKey: ["{domain}-statistics-mock"],
    queryFn: async () => {DOMAIN}_MOCK_DATA,  // TODO: API 연결 시 교체
  });
}
```

결과 보고 시 mock 여부를 명시한다:
```
[MOCK] API 미구현으로 mock 데이터 사용 중 — API 연결 시 useFetch{Domain}Statistics의 queryFn 교체 필요
```

#### 6-5. 컴포넌트 이식

- admin 공통 컴포넌트(`LineChartCard`, `KpiCard`, `TrendIndicator`)를 우선 재사용한다.
- CSV props를 API 응답 타입으로 교체한다.
- `BizDashboardFilter`로 연도/기간 필터를 처리한다.
- 대시보드 프로젝트의 인라인 스타일·하드코딩 색상을 admin 디자인 토큰으로 교체한다.

#### 6-6. 페이지 파일

```
src/app/(layout)/dashboard/biz/{target_path}/page.tsx     ← 진입점 (metadata만)
src/domain/biz/{domain}/components/pages/{Domain}DashboardPage.tsx
src/domain/biz/{domain}/components/templates/{Domain}DashboardTemplate.tsx
```

---

### 7단계: 검증

**추가 확인 항목** (대시보드 이관 특화):
- [ ] 차트/KPI 카드가 API 데이터로 정상 렌더링되는가?
- [ ] 연도별/분기별/월별 필터 전환이 정상 작동하는가?
- [ ] DTO가 월별 데이터인 경우 집계 결과가 올바른가? (CSV 값과 비교)
- [ ] 로딩·에러 상태가 처리되는가?
- [ ] admin 레이아웃(사이드바, 헤더)과 충돌 없이 렌더링되는가?
- [ ] 기존 admin 페이지에 사이드 이펙트가 없는가?

---

### 8단계: 결과 보고

```markdown
## 대시보드 이관 완료

### 생성·수정된 파일

| 파일 경로 | 작업 | 설명 |
|---|---|---|
| src/app/(layout)/dashboard/biz/{target}/page.tsx | 신규 | 진입점 |
| src/domain/biz/{domain}/components/... | 신규 | 페이지·템플릿 컴포넌트 |
| src/domain/biz/common/components/atoms/{Chart}.tsx | 신규 | 공통 차트 컴포넌트 (추가된 경우) |
| src/domain/biz/{domain}/lib/aggregate.ts | 신규 | 기간 집계 유틸 (추가된 경우) |
| src/api/query/{domain}/useFetch*.ts | 신규 | API 훅 |

### CSV → DTO 매핑 요약

| CSV 컬럼 | DTO 필드 | 처리 |
|---|---|---|
| total_sales | sales | 1:1 |
| total_profit | sales - purchase | 프론트 계산 |

### [ASK] 사용자 확인 결과

| 항목 | 결정 |
|---|---|
| ... | ... |
```

---

## 에이전트 위임 구조

```
Developer
├── analyzer       ← 소스 페이지 분석 + CSV-DTO 매핑 표 작성
├── fe-dev         ← UI 이식, 집계 유틸, API 훅, 공통 컴포넌트, 페이지 작성
│     └── (be-dev) ← API 엔드포인트가 미구현인 경우에만 추가
└── qa             ← 집계 로직 검증 (CSV vs API 결과값 비교)
```

**[ASK] 항목이 있으면 analyzer가 결과 보고 후, 사용자 확인을 받고 fe-dev를 호출한다.**

---

## 레퍼런스: finance/sales → dashboard/biz/finance 이관 예시

실제 이관 사례를 참고한다.

### 파일 구조 대응

| 대시보드 원본 | Admin 이관 결과 |
|---|---|
| `src/app/finance/sales/page.tsx` | `src/app/(layout)/dashboard/biz/finance/page.tsx` |
| `src/domain/finance-sales/components/SalesRevenuePage.tsx` | `src/domain/biz/finance/components/templates/FinanceDashboardTemplate.tsx` |
| `src/domain/finance-sales/lib/fin-buckets.ts` | `src/domain/biz/finance/lib/aggregate.ts` (연도/분기 집계) |
| `src/components/shell/hooks/useUrlFilters.ts` | `src/domain/biz/common/components/molecules/BizDashboardFilter.tsx` |

### CSV-DTO 매핑 예시 (finance/sales)

대시보드 CSV (`balancing-sales-by-year-month/data.csv`):
```
year, month, total_sales, total_profit, cnt
```

Admin DTO 예시:
```typescript
interface FinanceSalesMonthlyItem {
  year: number;
  month: number;
  sales: number;    // total_sales에 대응
  purchase: number; // total_profit은 sales - purchase로 프론트 계산
  count: number;    // cnt에 대응 (이름 다름)
}
```

**[INFO]** `total_profit` = `sales - purchase` 로 프론트에서 계산하여 처리함.

### 기간 필터 — BizDashboardFilter 사용

```typescript
// src/domain/biz/common/schema/bizDashboardSearchParamsSchema.ts
export const AVAILABLE_BIZ_YEARS = [2023, 2024, 2025]; // 2023년부터
export const BIZ_PERIOD_OPTIONS = ["all", "quarterly", "monthly"] as const;
export type BizPeriodType = (typeof BIZ_PERIOD_OPTIONS)[number];
```

```tsx
// FinanceDashboardTemplate.tsx
const searchParams = useSearchParams();
const { year, period } = parseSearchParamsWithZod(bizDashboardSearchParamsSchema, searchParams);

<BizDashboardFilter />  {/* 연도/기간 필터 UI — URL searchParams 자동 동기화 */}
```

### 월별 데이터 집계 패턴

DTO가 월별 배열로 내려오는 경우, 연도별/분기별은 프론트에서 집계한다.

```typescript
// src/domain/biz/finance/lib/aggregate.ts
function aggregateByQuarter(monthlyRows: FinanceSalesMonthlyItem[]) {
  // Q1(1-3월), Q2(4-6월), Q3(7-9월), Q4(10-12월) 그룹핑 후 합산
}

function aggregateByYear(monthlyRows: FinanceSalesMonthlyItem[]) {
  // 연도로 그룹핑 후 합산
}
```

### API 훅 패턴

```typescript
// src/api/query/finance/useFetchFinanceStatistics.ts
export function useFetchFinanceStatistics(params: FinanceByPeriodSearchRequest) {
  return useQuery({
    queryKey: ["finance-statistics", params],
    queryFn: () => FinanceStatisticsRepository.findAllBalancingByFinanceYear(params),
  });
}
```

### 공통 차트 컴포넌트 — LineChartCard

```tsx
// src/domain/biz/common/components/atoms/LineChartCard.tsx
<LineChartCard
  title="매출 추이"
  hint="월별 매출 및 전년 동기 비교"
  data={chartData}  // { xLabel, sales, prevSales }[]
  xKey="xLabel"
  lines={[
    { dataKey: "sales", name: "매출", color: "#3b82f6" },
    { dataKey: "prevSales", name: "전년", color: "#94a3b8" },
  ]}
  yTickFormatter={(v) => formatKRW(v)}
/>
```

**다른 차트 타입이 필요한 경우**: `LineChartCard` 패턴을 참고하여
`src/domain/biz/common/components/atoms/` 에 새 공통 컴포넌트를 먼저 작성한다.

---

## 유의사항

- CSV 로딩 코드(`fs`, `loadCsv`, `process.cwd()`)는 완전히 제거하고 API 훅으로 대체한다.
- 대시보드 프로젝트의 전역 스타일·테마(`chart-theme.ts` 등)는 가져오지 않는다.
- admin 프로젝트의 디자인 토큰 및 `@myfair/madix` 컴포넌트를 따른다.
- **[ASK] 항목은 반드시 사용자에게 먼저 공지하고 확인 후 구현한다.**
- 새 차트 타입이 필요하면 해당 페이지에 인라인으로 작성하지 않고 공통 컴포넌트로 먼저 만든다.
- admin 레이아웃 그룹 `(layout)` 아래에 페이지를 배치하여 사이드바·헤더가 자동 적용되도록 한다.
