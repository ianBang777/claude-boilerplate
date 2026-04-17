---
description: Figma URL로 디자인 컨텍스트를 받아 현재 프로젝트 스택에 맞게 UI를 구현할 때 쓰는 슬래시 커맨드.
---

# /figma-impl

Figma URL을 받아 해당 디자인을 현재 프로젝트에 구현합니다.

## 옵션

URL 없이 호출하면 작업을 시작하지 않고 URL을 요청합니다.

```
/figma-impl <figma-url>
/figma-impl https://www.figma.com/design/FILE_KEY/...?node-id=NODE_ID
```

---

## 실행 순서

### 1단계: URL 파싱

Figma URL에서 `fileKey`와 `nodeId`를 추출합니다.

- `figma.com/design/:fileKey/...?node-id=:nodeId` 형식에서 추출
- `nodeId`의 `-`를 `:`로 변환 (예: `6216-7502` → `6216:7502`)
- FigJam URL(`figma.com/board/...`)은 `get_figjam` 도구를 사용

### 2단계: 디자인 컨텍스트 수집 (병렬)

[references/figma-tools.md](references/figma-tools.md)

### 3단계: 코드베이스 파악 (병렬)

디자인에 등장하는 컴포넌트·스타일과 관련된 기존 코드를 탐색합니다.

- 동일하거나 유사한 컴포넌트가 이미 존재하는지 확인
- 프로젝트의 색상·간격·타이포그래피 토큰 체계 파악
- 공통 UI 컴포넌트 라이브러리 위치 및 사용 패턴 확인
- 레이아웃 컨벤션 (className 구조, 반응형 처리 방식 등)

### 4단계: 구현 계획 수립

| 항목               | 내용                           |
| ------------------ | ------------------------------ |
| 생성할 파일        | 경로 및 컴포넌트명             |
| 재사용할 기존 코드 | 프로젝트 내 기존 컴포넌트·토큰 |
| 주의사항           | 디자인 어노테이션, 제약사항    |

계획이 불명확하거나 기존 컴포넌트와 충돌 가능성이 있으면 구현 전에 확인합니다.

### 5단계: 구현

[references/implementation-rules.md](references/implementation-rules.md)

### 6단계: 구현 결과 보고

[references/report-template.md](references/report-template.md)

---

## 유의사항

- 디자인 어노테이션이 있으면 반드시 반영합니다.
- 구현 범위가 단일 컴포넌트를 넘어 페이지·레이아웃 전체인 경우, 범위를 먼저 확인합니다.
- 디자인과 기존 코드 사이에 충돌이 있으면 구현 전에 어떻게 처리할지 확인합니다.
- 색상은 디자인 토큰 사용 (hex 하드코딩 금지)
- 텍스트는 **디자인 시스템의 Typography** 사용
- `get_design_context` Figma 출력 코드는 레퍼런스일 뿐이며 최종 코드가 아닙니다.
  - Figma 출력 코드는 **레퍼런스만으로 사용**하고, 프로젝트 컨벤션 우선
