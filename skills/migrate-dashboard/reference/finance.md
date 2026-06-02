# Finance 대시보드 이관 참조 문서

작성일: 2026-06-02
대상: admin `/src/domain/biz/finance` — 재무/매출 수익 대시보드

---

## 생성/수정된 파일 목록

| 파일 | 구분 | 내용 |
|---|---|---|
| `src/domain/biz/finance/types/financeSales.types.ts` | 신규 | DTO 타입 정의 |
| `src/domain/biz/finance/lib/financeSalesAggregate.ts` | 신규 | 월별 → 연/분기 집계 유틸 |
| `src/domain/biz/finance/mocks/financeSalesMock.ts` | 신규 | Mock 데이터 (2023~2025년 36개월) |
| `src/api/query/finance/statistics/useFetchFinanceSalesStatistics.ts` | 신규 | useQuery 훅 |
| `src/domain/biz/finance/components/templates/FinanceDashboardTemplate.tsx` | 수정(완전 재작성) | 대시보드 템플릿 |

---

## CSV → DTO 매핑 결과

원본 대시보드(`SalesRevenuePage.tsx`)는 여러 분리된 `MonthlyRow[]` 시계열을 props로 받았으나,
admin 이관에서는 단일 `FinanceSalesItem[]` 배열로 통합했다.

| 원본 데이터셋 | DTO 필드 | 비고 |
|---|---|---|
| `balancingRows.total_sales` | `monthlyTotalSales` | 회계 인식 월간 총 매출 |
| `finishRows.total_sales` | `participationSales` | FINISH 코호트 매출 |
| `finishRows.total_profit` | `participationProfit` | FINISH 코호트 수익 |
| `finishRows.cnt` | `participationCount` | FINISH 코호트 건수 |
| `exportVoucherSalesRows.total_sales` | `voucherSales` | 수출바우처 매출 |
| `balancing 수익 − 선급금` | `voucherProfitExcludeAdvance` | 수출바우처 수익(선급금 제외) |
| `balancingRows.total_profit` | `voucherProfitIncludeAdvance` | 수출바우처 수익(선급금 포함) |
| `exportVoucherAdvanceCostMonthlyRows.total_sales` | `voucherAdvanceCost` | 수출바우처 선급금 비용 |

### 간소화한 항목

원본에 있던 `finishDailyRows`, `balancingDailyRows`, `exportVoucherSalesDailyRows`, `exportVoucherAdvanceCostDailyRows` (일 단위 동기간 비교 전용)는 현재 이관 범위에서 제외했다. 동기간 비교 KPI가 필요하면 별도 DTO 필드 추가 및 집계 로직 확장이 필요하다.

---

## 집계 전략

| 필터 | 집계 함수 | 반환 버킷 |
|---|---|---|
| `all` | `buildYearlyBuckets` | 전체 연도별 합계 |
| `quarterly` | `buildQuarterlyBuckets(year)` | Q1~Q4 |
| `monthly` | `buildMonthlyBuckets(year)` | 1~12월 |

KPI 수치는 항상 연간 합산(`buildYearSingleBucket`)으로 계산하며, 전년(`year-1`) 대비 증감률을 `calcGrowthRate`로 표시한다.

`period=all`일 때 KPI는 `salesItems`에 있는 가장 최근 연도를 기준으로 계산한다.

---

## [INFO] 항목

- admin 프로젝트에 `LineChartCard`, `KpiCard`, `TrendIndicator`, `BizDashboardFilter`, `BizPeriodType`, `AVAILABLE_BIZ_YEARS`, `bizDashboardSearchParamsSchema` 모두 이미 구현되어 있어 그대로 재사용했다.
- `BizPeriodTypes`는 `"all" | "quarterly" | "monthly"` 3종이며, 원본 대시보드의 `period=yearly`는 존재하지 않는다. 원본의 yearly 로직은 `period=all` 시 단년도 선택으로 처리된다.
- 집계 버킷 타입 `FinanceSalesBucket`은 원본의 `FinBucket` 구조를 참고해 finance 도메인에 맞게 재설계했다 (필드명 camelCase 통일, 수출바우처 관련 필드 추가).

---

## [MOCK] 항목

- `financeSalesMock.ts`: 2023~2025년 36개월 mock 데이터. 연도별 약 10% YoY 성장 반영. **API 구현 후 삭제 필요.**
- `useFetchFinanceSalesStatistics.ts`: queryFn에서 mock 데이터를 반환. **API 연결 시 Repository 호출로 교체 필요.**

---

## 특이사항

### 동기간 비교(YoY same-period) 미구현
원본 대시보드는 일 단위 `DailyRow`와 `SamePeriodConfig`를 활용한 동기간 비교 KPI를 제공한다. 현재 이관에서는 이 기능을 제외하고 연간 단순 비교(`buildYearSingleBucket`)만 구현했다.

필요 시 다음 작업이 추가로 필요하다:
1. `FinanceSalesItem`에 일 단위 필드 추가 또는 별도 daily DTO 설계
2. `buildSalesKpiDailyInputs` 유사 어댑터 구현
3. `compareSamePeriod` 유틸 admin 프로젝트 내 구현 또는 공유 패키지 이동

### 수출바우처 선급금 스냅샷 제외
원본에는 진행 중 수출바우처 참가신청의 선급금 스냅샷(`exportVoucherAdvanceCost.total_advance_cost`, `participation_cnt`) KPI 카드가 있었다. 이는 월별 시계열이 아닌 단건 스냅샷이므로 현재 DTO에 미포함. 필요 시 별도 API 엔드포인트와 useQuery 훅 추가.

---

## 코드베이스 설명

### 원본 소스 파일 구조

```
myfair-biz-dashboard-repo/src/domain/finance-sales/
├── lib/
│   ├── fin-buckets.ts       ← 집계 유틸 (버킷 생성·합산·수익률·건당 계산)
│   ├── sales-kpi.ts         ← 동기간 KPI 계산 (SalesKpiModel, buildSalesKpiDailyInputs)
│   ├── num-utils.ts         ← 숫자 안전 변환 유틸
│   └── sales-kpi.test.ts    ← KPI 단위 테스트
└── components/
    └── SalesRevenuePage.tsx ← 메인 페이지 컴포넌트 (차트+KPI 렌더링)
```

| 파일 | 역할 |
|---|---|
| `fin-buckets.ts` | `MonthlyRow[]`를 월/분기/연도 `FinBucket`으로 집계. `buildMonthlyBucketsFullYear`, `buildQuarterlyBuckets`, `buildYearSingleBucket`, `buildYearlyTotals`, `buildChartBuckets`, `buildVoucherBuckets`, `bucketMarginPs`, `bucketMarginFpFs`, `bucketAvgSalesMan`, `bucketAvgProfitMan` 제공 |
| `sales-kpi.ts` | 일 단위 DailyRow 5종(balancingSales, balancingProfit, finish, voucherSales, advanceCost)을 `SamePeriodConfig`와 결합해 동기간 KPI(`SalesKpiModel`) 계산 |
| `SalesRevenuePage.tsx` | props로 7종 MonthlyRow 배열 + 1개 스냅샷을 받아 period/year 필터에 따라 버킷 집계 → KPI·차트 렌더링 |

### Admin 이관 결과 파일 구조

```
client/apps/admin/src/domain/biz/finance/
├── types/
│   └── financeSales.types.ts        ← DTO 타입 (FinanceSalesItem)
├── lib/
│   └── financeSalesAggregate.ts     ← 집계 유틸 (FinanceSalesBucket 기반)
├── mocks/
│   └── financeSalesMock.ts          ← Mock 데이터 (2023~2025 36개월)
└── components/
    ├── pages/
    │   └── FinanceDashboardPage.tsx ← 진입점 (Suspense 래퍼)
    └── templates/
        └── FinanceDashboardTemplate.tsx ← 메인 템플릿
```

| 파일 | 역할 |
|---|---|
| `financeSales.types.ts` | `FinanceSalesItem` (월별 단일 DTO): `year`, `month`, `monthlyTotalSales`, `participationSales`, `participationProfit`, `participationCount`, `voucherSales`, `voucherProfitExcludeAdvance`, `voucherProfitIncludeAdvance`, `voucherAdvanceCost` |
| `financeSalesAggregate.ts` | `FinanceSalesItem[]`를 `FinanceSalesBucket`으로 집계. `buildMonthlyBuckets`, `buildQuarterlyBuckets`, `buildYearlyBuckets`, `buildYearSingleBucket`, `buildPeriodBuckets`, `calcParticipationMargin`, `calcAvgSalesPerCount`, `calcAvgProfitPerCount`, `calcGrowthRate` 제공 |
| `FinanceDashboardTemplate.tsx` | `useFetchFinanceSalesStatistics(year)` 훅에서 데이터를 받아 period/year 필터 적용 → KPI·차트 렌더링 |

### 원본 fin-buckets.ts vs admin financeSalesAggregate.ts 구조 비교

| 항목 | 원본 (fin-buckets.ts) | admin (financeSalesAggregate.ts) |
|---|---|---|
| 버킷 타입 | `FinBucket { label, order, sales, profit, cnt }` | `FinanceSalesBucket { label, order, totalSales, participationSales, participationProfit, participationCount, voucherSales, voucherProfitExcludeAdvance, voucherProfitIncludeAdvance, voucherAdvanceCost }` |
| 입력 타입 | `MonthlyRow` (7종 분리 배열) | `FinanceSalesItem` (단일 통합 배열) |
| 월별 버킷 | `buildMonthlyBucketsFullYear(allRows, year)` | `buildMonthlyBuckets(items, year)` |
| 분기 버킷 | `buildQuarterlyBuckets(allRows, year)` | `buildQuarterlyBuckets(items, year)` |
| 연도 합계 | `buildYearSingleBucket(allRows, year)` | `buildYearSingleBucket(items, year)` |
| 연도별 시계열 | `buildYearlyTotals(allRows)` | `buildYearlyBuckets(items)` |
| cur/prev 쌍 | `buildChartBuckets(allRows, period, year, prevYear)` | `buildPeriodBuckets(items, period, year)` (내부에서 prevYear 자동 계산) |
| 수익률 | `bucketMarginFpFs(b)`, `bucketMarginPs(b)` | `calcParticipationMargin(b)` |
| 건당 매출/수익 | `bucketAvgSalesMan(b)`, `bucketAvgProfitMan(b)` | `calcAvgSalesPerCount(b)`, `calcAvgProfitPerCount(b)` |
| 동기간 합산 | `sumYearRowsWithCap(allRows, year, maxMonth)` | **미구현** |

**핵심 차이**: 원본은 데이터셋별로 분리된 `MonthlyRow[]`를 받지만, admin은 모든 필드를 통합한 `FinanceSalesItem[]` 단일 배열로 운영한다. 원본의 7개 시계열이 admin의 1개 통합 DTO로 합쳐진 구조다.

### KpiCard 비교 지표 계산 방법 (전년 동기간 합산 로직)

원본 `SalesRevenuePage.tsx`의 KPI 카드 sub 텍스트 패턴:

```tsx
// 생성 함수
const prevLabelText = (formattedPrev: string): string =>
  kpi.isFullPeriod
    ? `vs ${compareYear} (${formattedPrev})`
    : `vs ${compareYear} 동기간 ~${kpi.endMonth}/${kpi.endDay} (${formattedPrev})`;

// 카드 sub 예시
sub={
  <span className="text-zinc-500">
    <YoYBadge cur={kpi.totalSales} prev={kpi.prevTotalSales} /> · {prevLabelText(formatKRW(kpi.prevTotalSales))}
  </span>
}
```

**동기간 계산 흐름**:
1. 클라이언트 `today = { year, month, day }` (렌더 시 1회 계산)
2. `buildSamePeriodConfig(scope, kpiYear, today)` → `SamePeriodConfig` 생성
3. `buildSalesKpiDailyInputs({...DailyRows})` → 5종 일별 배열을 통합 shape으로 어댑팅
4. `buildSalesKpi(inputs, samePeriodConfig)` → `SalesKpiModel` 산출
   - `isFullPeriod`: today가 집계 기간 내에 있으면 false (진행 중), 완료된 기간이면 true
   - `endMonth` / `endDay`: 비교 윈도우의 마지막 날 (라벨용)
   - `prevTotalSales` 등: 전년 동기간(1월 1일 ~ endDate)의 합산값

**admin에서 월별 배열로 근사 구현하는 방법**:

```typescript
// today 기준 전년 동기간 합산 (월별 근사)
function buildSamePeriodKpi(
  items: FinanceSalesItem[],
  year: number,
  today: { month: number; day: number },
): { prev: FinanceSalesBucket; isFullPeriod: boolean; endMonth: number; endDay: number } {
  const prevYear = year - 1;
  const isCurrentYear = year === new Date().getFullYear();
  // 진행 중인 달 제외 (현재 연도이고 today.month가 아직 끝나지 않은 경우)
  const maxMonth = isCurrentYear ? today.month - 1 : 12;
  const isFullPeriod = !isCurrentYear || today.month === 1;

  const prevBucket = emptyBucket(`${prevYear}년`, prevYear);
  for (const item of items) {
    if (item.year === prevYear && item.month <= maxMonth) {
      accumulateItem(prevBucket, item);
    }
  }
  return {
    prev: prevBucket,
    isFullPeriod,
    endMonth: today.month,
    endDay: today.day,
  };
}
```

비교 문구 포맷:
```typescript
const prevLabel = isFullPeriod
  ? `vs ${prevYear} (${formatEok(prevValue)})`
  : `vs ${prevYear} 동기간 ~${endMonth}/${endDay} (${formatEok(prevValue)})`;
```

### 현재 미구현 항목 및 이유

| 미구현 항목 | 원본 위치 | 미구현 이유 |
|---|---|---|
| 전년 동기간 비교 KPI sub 문구 | `prevLabelText()` + `SalesKpiModel` | 일 단위 DailyRow 5종이 필요. 현재 DTO는 월별만 내려옴 |
| 수출바우처 선급금 비용 KPI 카드 | 섹션 "수출바우처만" 4번째 카드 | `exportVoucherAdvanceCost` 스냅샷이 월별 시계열이 아닌 단건. 별도 API 필요 |
| "참가신청 건 당" 섹션 전체 | KPI 3개 + 차트 3개 | 이관 시 누락됨. `FinanceSalesBucket`에 `participationCount` 필드는 있으므로 추가 API 없이 구현 가능 |
| 기간별 수익률(수출바우처 선급금 제외) 차트 | `profitRatePsExChart` | 이관 시 누락됨. `voucherAdvanceCost` 필드 존재하므로 추가 API 없이 구현 가능 |
| 기간별 수익(수출바우처 선급금 제외) 차트 | `profitNetChart` | 이관 시 누락됨. `voucherAdvanceCost` 필드 존재하므로 추가 API 없이 구현 가능 |
| 기간별 수익률(수출바우처 선급금 포함) 차트 | `profitRatePsChart` | 이관 시 누락됨. 기존 필드로 구현 가능 |
| 섹션 원문 텍스트 | 소스 `<h2>` 섹션명 | 에이전트가 임의 텍스트("핵심 성과 지표") 생성 — 원문은 "매출 · 수익(수출바우처 포함)", "수출바우처만", "참가신청 건 당" |

**추가 API 없이 구현 가능한 항목** (FinanceSalesBucket 기존 필드 활용):
- "참가신청 건 당" 섹션: `participationCount`, `participationSales`, `participationProfit` 활용
- 수익률(선급금 제외) 차트: `(participationProfit - voucherAdvanceCost) / totalSales * 100`
- 수익(선급금 제외) 차트: `voucherProfitIncludeAdvance - voucherAdvanceCost` (= `voucherProfitExcludeAdvance`)

**별도 API가 필요한 항목**:
- 전년 동기간 비교 문구: 일 단위 DailyRow를 내려주는 엔드포인트 추가 또는 DTO에 YTD 필드 추가
- 수출바우처 선급금 스냅샷 KPI: 진행 중 건의 실시간 선급금 합계 전용 엔드포인트
