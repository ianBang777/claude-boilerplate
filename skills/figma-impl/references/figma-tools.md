# Figma MCP — 컨텍스트 수집

```
get_design_context(fileKey, nodeId)   ← 컴포넌트 구조, 스타일, Code Connect 힌트
get_variable_defs(fileKey)            ← Figma 디자인 토큰 (색상, 간격, 타이포그래피 변수)
```

## 방식

반환된 코드는 React + Tailwind 기반 레퍼런스입니다. 시각적 추측에 의존하지 않고, 반환된 구조와 토큰 값을 기반으로 구현합니다.

## 유의사항

반환된 데이터가 단순 출력형 코드일 경우(p, span 등의 태그) 무시하고 디자인 시스템으로 전환해서 사용해야 합니다.