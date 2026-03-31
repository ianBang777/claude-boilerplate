# Example: design-token-apply

## 시나리오

`root` 테마의 primary 컬러를 blue에서 indigo로 변경하는 작업 예시입니다.

---

## 사용자 요청

> "root 테마 primary 색상을 blue에서 indigo로 바꿔줘. 폴더는 Desktop/sementic이야."

---

## 수행 과정

### 1단계: 변경된 시맨틱 토큰 파일 확인

`Desktop/sementic/` 폴더 내 파일 목록:
```
root.json
root-dark.json
pavilion.json
pavilion-dark.json
space-only.json
space-only-dark.json
```

`root.json`에서 변경 대상 토큰 확인:
```json
{
  "ring": {
    "value": "{color.blue.500}",
    "type": "color"
  },
  "primary": {
    "value": "{color.blue.500}",
    "type": "color"
  },
  "primary-foreground": {
    "value": "{color.blue.50}",
    "type": "color"
  }
}
```

### 2단계: sementic-token.json에 변경사항 반영

프로젝트 내 `packages/token-parser/sementic-token.json`의 `root` 키 아래 해당 토큰 교체:

**변경 전:**
```json
{
  "root": {
    "ring": { "value": "{color.blue.500}", "type": "color" },
    "primary": { "value": "{color.blue.500}", "type": "color" },
    "primary-foreground": { "value": "{color.blue.50}", "type": "color" }
  }
}
```

**변경 후:**
```json
{
  "root": {
    "ring": { "value": "{color.indigo.500}", "type": "color" },
    "primary": { "value": "{color.indigo.500}", "type": "color" },
    "primary-foreground": { "value": "{color.indigo.50}", "type": "color" }
  }
}
```

### 3단계: token-parser build 실행

```bash
yarn token build:semantic
```

`packages/token-parser/madix.css` 파일이 재생성됩니다.

### 4단계: 변경 사항 보고 (`token-update-report.md` 생성)

---

## 생성되는 보고서 예시 (token-update-report.md)

```markdown
# 디자인 토큰 업데이트 보고

- 변경일시: 2026-03-31 19:30
- 영향받은 테마: root

## 변경된 토큰

| 토큰 | 변경 전 | 변경 후 |
|------|---------|---------|
| ring | {color.blue.500} | {color.indigo.500} |
| primary | {color.blue.500} | {color.indigo.500} |
| primary-foreground | {color.blue.50} | {color.indigo.50} |

## 영향 없는 테마
- root-dark, pavilion, pavilion-dark, space-only, space-only-dark: 변경 없음
```

---

## 토큰 구조 참고

각 테마 파일의 주요 토큰 카테고리:

| 카테고리 | 토큰 예시 |
|----------|-----------|
| 레이아웃 | `border`, `input`, `ring`, `stroke` |
| 배경 | `background`, `surface`, `surface-subtle`, `surface-overlay` |
| 텍스트 | `foreground`, `muted-foreground`, `surface-foreground` |
| 인터랙션 | `primary`, `secondary`, `accent`, `destructive` |
| 상태 | `success-solid/soft`, `warning-solid/soft`, `error-solid/soft`, `info-solid/soft` |
| UI 요소 | `card`, `popover`, `muted`, `disabled` |
| 차트 | `chart-1` ~ `chart-8` |
| 서비스 티어 | `service-lite/standard/pro/smart/expert/custom/exportvoucher` (-soft/-solid/-strong) |

> **참고:** `pavilion` 테마는 primary가 emerald 계열, `root`는 blue 계열로 구성됩니다.
> 라이트/다크 쌍(`root` ↔ `root-dark`)은 항상 함께 변경을 검토하세요.
