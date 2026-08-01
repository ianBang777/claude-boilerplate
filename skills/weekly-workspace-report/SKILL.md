---
name: weekly-workspace-report
description: 주간 워크스페이스 사용자 리포트(경로별 조회수·사용자·전주 대비·4주 흐름·이상 신호)를 BigQuery에서 생성해 옵시디언 볼트에 마크다운으로 저장한다. 트리거: "/weekly-workspace-report", "주간 워크스페이스 리포트", "워크스페이스 주간 보고서". 매주 화요일 Desktop 예약 작업으로 자동 실행하는 용도.
---

# 주간 워크스페이스 리포트 생성

`metrics.daily_workspace_view`(GA4 이벤트 일별 집계)에서 **직전 완결 주(월~금)**의 경로별 사용 지표를 뽑아, 고정 포맷의 마크다운 리포트를 옵시디언 볼트에 저장한다. 날짜는 실행 시점 기준으로 **자동 계산**되므로 매주 그대로 재실행하면 된다.

## 사전 조건

- **BigQuery MCP**(`toolbox-bigquery`)의 `execute_sql`이 사용 가능해야 한다. 없으면 중단하고 사용자에게 알린다.
- 저장 폴더: `/Users/ian/Documents/MyfairDevVault/Reports/워크스페이스 주간 리포트/` (없으면 생성).

## 절차

### 1) 날짜 계산

아래 쿼리로 대상 주간·비교 주간·오늘 날짜를 얻는다.

```sql
SELECT
  CURRENT_DATE('Asia/Seoul') AS today,
  DATE_SUB(DATE_TRUNC(CURRENT_DATE('Asia/Seoul'), WEEK(MONDAY)), INTERVAL 7 DAY) AS tgt_mon,
  DATE_ADD(DATE_SUB(DATE_TRUNC(CURRENT_DATE('Asia/Seoul'), WEEK(MONDAY)), INTERVAL 7 DAY), INTERVAL 4 DAY) AS tgt_fri,
  DATE_SUB(DATE_TRUNC(CURRENT_DATE('Asia/Seoul'), WEEK(MONDAY)), INTERVAL 14 DAY) AS prev_mon,
  DATE_SUB(DATE_TRUNC(CURRENT_DATE('Asia/Seoul'), WEEK(MONDAY)), INTERVAL 10 DAY) AS prev_fri;
```

- `tgt_mon`~`tgt_fri` = 대상 주간(월~금). `prev_mon`~`prev_fri` = 직전 주(전주 대비 비교용).
- 일별 표의 요일 컬럼 날짜는 `tgt_mon + 0..4일`이다 (항상 월·화·수·목·금 순서).

### 2) 주간 집계 조회

```sql
WITH d AS (
  SELECT DATE_SUB(DATE_TRUNC(CURRENT_DATE('Asia/Seoul'), WEEK(MONDAY)), INTERVAL 7 DAY) AS tgt_mon
),
agg AS (
  SELECT
    v.section,
    SUM(IF(v.date BETWEEN d.tgt_mon AND DATE_ADD(d.tgt_mon, INTERVAL 4 DAY), v.page_views, 0)) AS pv_w4,
    SUM(IF(v.date BETWEEN DATE_SUB(d.tgt_mon, INTERVAL 7 DAY) AND DATE_SUB(d.tgt_mon, INTERVAL 3 DAY), v.page_views, 0)) AS pv_w3,
    SUM(IF(v.date BETWEEN DATE_SUB(d.tgt_mon, INTERVAL 14 DAY) AND DATE_SUB(d.tgt_mon, INTERVAL 10 DAY), v.page_views, 0)) AS pv_w2,
    SUM(IF(v.date BETWEEN DATE_SUB(d.tgt_mon, INTERVAL 21 DAY) AND DATE_SUB(d.tgt_mon, INTERVAL 17 DAY), v.page_views, 0)) AS pv_w1,
    SUM(IF(v.date BETWEEN d.tgt_mon AND DATE_ADD(d.tgt_mon, INTERVAL 4 DAY), v.users, 0)) AS u_w4,
    SUM(IF(v.date BETWEEN DATE_SUB(d.tgt_mon, INTERVAL 7 DAY) AND DATE_SUB(d.tgt_mon, INTERVAL 3 DAY), v.users, 0)) AS u_w3
  FROM `myfair-1538640722158.metrics.daily_workspace_view` v CROSS JOIN d
  GROUP BY v.section
)
SELECT
  a.section,
  COALESCE(s.name_ko, IF(a.section='other','기타', a.section)) AS name_ko,
  a.pv_w4,
  ROUND(a.pv_w4 / NULLIF(MAX(IF(a.section='ALL', a.pv_w4, NULL)) OVER (), 0) * 100, 1) AS pv_share,
  ROUND(SAFE_DIVIDE(a.pv_w4 - a.pv_w3, a.pv_w3) * 100, 1) AS pv_wow,
  CAST(ROUND(a.u_w4 / 5) AS INT64) AS avg_daily_users,
  ROUND(SAFE_DIVIDE(a.u_w4 - a.u_w3, a.u_w3) * 100, 1) AS u_wow,
  a.pv_w1, a.pv_w2, a.pv_w3,
  a.u_w4, a.u_w3,
  ROUND(SAFE_DIVIDE(a.pv_w4 - (a.pv_w1 + a.pv_w2 + a.pv_w3) / 3, (a.pv_w1 + a.pv_w2 + a.pv_w3) / 3) * 100, 1) AS anomaly_pct
FROM agg a
LEFT JOIN `myfair-1538640722158.metrics.dashboard_section` s ON s.section = a.section
ORDER BY a.pv_w4 DESC;
```

`ALL` 행이 전체 합계이자 헤드라인 소스다. `pv_share`는 이미 전체 대비 %.

### 3) 일별 매트릭스 조회

```sql
WITH d AS (
  SELECT DATE_SUB(DATE_TRUNC(CURRENT_DATE('Asia/Seoul'), WEEK(MONDAY)), INTERVAL 7 DAY) AS tgt_mon
)
SELECT
  COALESCE(s.name_ko, IF(v.section='other','기타', v.section)) AS name_ko,
  v.section,
  SUM(IF(DATE_DIFF(v.date, d.tgt_mon, DAY)=0, v.page_views, 0)) AS mon_pv, SUM(IF(DATE_DIFF(v.date, d.tgt_mon, DAY)=0, v.users, 0)) AS mon_u,
  SUM(IF(DATE_DIFF(v.date, d.tgt_mon, DAY)=1, v.page_views, 0)) AS tue_pv, SUM(IF(DATE_DIFF(v.date, d.tgt_mon, DAY)=1, v.users, 0)) AS tue_u,
  SUM(IF(DATE_DIFF(v.date, d.tgt_mon, DAY)=2, v.page_views, 0)) AS wed_pv, SUM(IF(DATE_DIFF(v.date, d.tgt_mon, DAY)=2, v.users, 0)) AS wed_u,
  SUM(IF(DATE_DIFF(v.date, d.tgt_mon, DAY)=3, v.page_views, 0)) AS thu_pv, SUM(IF(DATE_DIFF(v.date, d.tgt_mon, DAY)=3, v.users, 0)) AS thu_u,
  SUM(IF(DATE_DIFF(v.date, d.tgt_mon, DAY)=4, v.page_views, 0)) AS fri_pv, SUM(IF(DATE_DIFF(v.date, d.tgt_mon, DAY)=4, v.users, 0)) AS fri_u
FROM `myfair-1538640722158.metrics.daily_workspace_view` v
CROSS JOIN d
LEFT JOIN `myfair-1538640722158.metrics.dashboard_section` s ON s.section = v.section
WHERE v.date BETWEEN d.tgt_mon AND DATE_ADD(d.tgt_mon, INTERVAL 4 DAY)
GROUP BY name_ko, v.section
ORDER BY SUM(v.page_views) DESC;
```

## 렌더링 규칙

**모든 수치는 쿼리 결과로 계산한다. 아래 값은 형식 예시일 뿐 복사 금지.**

- **숫자 포맷**: 1000 이상은 천단위 콤마(5,518). 사용자는 "N명".
- **정렬**: 쿼리 결과 순서(조회수 desc) 그대로. `ALL`(대시보드 전체)이 맨 위.
- **변화 화살표 (화살표에만 색, 숫자는 기본색)** — `pv_wow` / `u_wow` 부호 기준:
  - 양수: `<span style="color:#e5484d">▲</span> +12.3%`
  - 음수: `<span style="color:#3b82f6">▼</span> −12.3%` (마이너스는 U+2212 `−`)
  - 0: `<span style="color:#868e96">—</span> 0.0%`
- **최근 4주 흐름 (스파크라인)**: 입력 `[pv_w1, pv_w2, pv_w3, pv_w4]`, 문자 `▁▂▃▄▅▆▇█`(index 0~7).
  - `max==min`이면 `▄▄▄▄`.
  - 아니면 각 값 `level = round((v-min)/(max-min)*7)`, 해당 index 문자. 4글자를 백틱으로 감싼다(예: `` `▂▁▃█` ``).
- **경로 라벨**: `name_ko` 사용(이미 `dashboard_section` 공식명, `other`→기타).

### 저트래픽 묶기

`ALL` 제외, `pv_w4 < 20`인 경로들을 **기타(저트래픽)** 한 행으로 접는다.
- 조회수 = 그 경로들 `pv_w4` 합, 비중 = 합/전체(ALL pv_w4)×100(반올림 1자리).
- 조회수 변화 = `(Σpv_w4 − Σpv_w3)/Σpv_w3 ×100`.
- 일평균 사용자 = `round(Σu_w4/5)`, 사용자 변화 = `(Σu_w4 − Σu_w3)/Σu_w3 ×100`.
- 4주 흐름 = `[Σpv_w1, Σpv_w2, Σpv_w3, Σpv_w4]`로 스파크라인.
- 각주에 접힌 경로를 `name_ko(pv_w4)` 형태로 나열.
- 접힌 경로가 없으면 이 행·각주 생략.

### 요약(한눈에 보기)

- 전체 조회수 = `ALL.pv_w4`, 직전 주 = `ALL.pv_w3`, 변화 = `ALL.pv_wow`.
- 전체 일평균 사용자 = `ALL.avg_daily_users`, 직전 주 = `round(ALL.u_w3/5)`, 변화 = `ALL.u_wow`.
- 많이 늘어난 곳: `ALL` 제외·`pv_w4>=20`·`pv_wow>0` 중 `pv_wow` 상위 4개 → `이름 +X.X%`.
- 많이 줄어든 곳: 같은 조건에서 `pv_wow<0` 중 하위(가장 큰 감소) 4개 → `이름 −X.X%`.

### 이상 신호

`ALL` 제외, `pv_w4 >= 20` 이고 `abs(anomaly_pct) >= 40`인 경로.
- `anomaly_pct > 0` → 급등, `< 0` → 급락.
- 3주 평균 = `round((pv_w1+pv_w2+pv_w3)/3)`.
- 형식: `🔺 **{이름}** 급등 — 3주 평균 {avg}회 → 이번 주 {pv_w4}회 (**+{anomaly_pct}%**)` (급락은 🔻, 부호 −).
- 해당 없으면 "이상 신호: 없음." 급등·급락 각각 없으면 그 줄 생략.

## 리포트 템플릿

아래 뼈대에 값을 채운다. `{tgt_mon}`, `{tgt_fri}` 등은 1)의 결과. 일별 표 헤더 날짜는 `M/D`(예: 6/29).

```markdown
---
type: workspace-weekly-report
week_start: {tgt_mon}
week_end: {tgt_fri}
compare_prev: {prev_mon} ~ {prev_fri}
generated: {today}
source: bigquery / metrics.daily_workspace_view
tags:
  - 리포트/워크스페이스주간
---

# 📊 워크스페이스 주간 리포트

**대상 주간** {tgt_mon}(월) ~ {tgt_fri}(금) · 영업일 5일
**비교 대상** 직전 주 {prev_mon} ~ {prev_fri} (영업일 5일)
**생성일** {today}

---

## 한눈에 보기

- **전체 조회수 {ALL.pv_w4}회** (직전 주 {ALL.pv_w3}회, {화살표}{ALL.pv_wow}%)
- **전체 일평균 사용자 {ALL.avg_daily_users}명** (직전 주 {round(ALL.u_w3/5)}명, {화살표}{ALL.u_wow}%)
- 📈 **많이 늘어난 곳**: {상위4 이름 +%} (조회수, 직전 주 대비)
- 📉 **많이 줄어든 곳**: {하위4 이름 −%}

---

## 경로별 주간 집계

| 경로 | 조회수 | 비중 | 조회수 변화 | 일평균 사용자 | 사용자 변화 | 최근 4주 흐름 |
|---|--:|--:|--:|--:|--:|:--|
| **대시보드 전체** | **{ALL.pv_w4}** | **100%** | {화살표+굵게} | **{ALL.avg_daily_users}명** | {화살표+굵게} | `{스파크라인}` |
| {각 경로 행 …} |
| 기타(저트래픽)¹ | … |

<sub>¹ 주간 조회수 20회 미만을 묶음: {접힌 경로 name_ko(pv_w4) 나열}.</sub>

---

## ⚠️ 이상 신호

직전 3주 평균 대비 **±40% 이상** 벗어난 경로 (주간 조회수 20회 이상만):

- {🔺/🔻 급등/급락 항목들}

급락 신호: 없음.

---

## 일별 상세

<sub>각 셀 = **조회수 / 당일 접속자수**</sub>

| 경로 | 월 {M/D} | 화 {M/D} | 수 {M/D} | 목 {M/D} | 금 {M/D} |
|---|--:|--:|--:|--:|--:|
| {일별 매트릭스: 각 셀 "pv / u"} |

---

<sub>경로 이름 출처: BigQuery `metrics.dashboard_section` (name_ko). `기타`=other(대시보드 정의 외 경로).</sub>
<sub>데이터: BigQuery `metrics.daily_workspace_view` (GA4 events 일별 집계)</sub>
```

## 저장

- 경로: `/Users/ian/Documents/MyfairDevVault/Reports/워크스페이스 주간 리포트/{tgt_mon} 워크스페이스 주간 리포트.md`
- 폴더가 없으면 만들고, 같은 파일이 있으면 덮어쓴다(재실행 시 최신화).

## 완료 보고

저장 경로와 헤드라인 한 줄(전체 조회수·사용자 변화, 이상 신호 건수)을 사용자에게 보고한다.

## 주의

- **일별 사용자 합 ≠ 주간 순사용자.** "일평균 사용자"는 순인원(중복 제거)이 아니라 하루 평균 규모다. 순사용자 지표는 이 리포트에 넣지 않는다.
- 대상 주에 트래픽이 없던 경로는 쿼리에 안 잡히면 표기하지 않는다(정상).
- 값 계산은 항상 쿼리 결과 기준. 이 문서의 숫자·예시를 복사하지 않는다.
