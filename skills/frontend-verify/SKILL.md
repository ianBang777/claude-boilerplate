---
tags: ["verify", "frontend"]
applies_to: ["code"]
---

# Frontend Verification Skill

프론트엔드 작업 완료 후 필수 검증 절차를 제공합니다.

---

## 필수 검증 항목

### 1. 빌드

```bash
# React/Vue/Angular
npm run build
# 또는
yarn build

# Next.js
npm run build && npm run start
```

**확인 사항**:
- 빌드 에러 없음
- 번들 크기 확인
- 소스맵 생성 확인

---

### 2. 린트

```bash
npm run lint
# 또는
npx eslint src/
```

**확인 사항**:
- 린트 에러 0건
- 경고 최소화
- 포맷팅 일관성

---

### 3. 타입 체크 (TypeScript)

```bash
npx tsc --noEmit
```

**확인 사항**:
- 타입 에러 없음
- any 타입 최소화

---

### 4. 렌더링 테스트

**브라우저 또는 테스트로 확인**:
```bash
npm run dev
# 브라우저에서 http://localhost:3000 접속

# 또는 컴포넌트 테스트
npm run test:component
```

**확인 사항**:
- 주요 컴포넌트 렌더링 성공
- 콘솔 에러 없음
- 기본 상호작용 동작

---

## WORK_LOG 기록 형식

```markdown
## 검증 결과

### 빌드
\`\`\`bash
$ npm run build
✓ Built in 4.2s
dist/index.html  1.2 kB
dist/assets/index.js  245 kB
\`\`\`

### 린트
\`\`\`bash
$ npm run lint
✓ No issues found
\`\`\`

### 타입 체크
\`\`\`bash
$ npx tsc --noEmit
✓ No errors
\`\`\`

### 렌더링 테스트
- UserList 컴포넌트: 정상 렌더링 ✓
- UserDetail 컴포넌트: 정상 렌더링 ✓
- 콘솔 에러: 없음 ✓
```

---

## Reviewer 평가 기준

✅ **승인 조건**:
- 빌드 성공
- 린트 통과
- 타입 체크 통과
- 렌더링 성공

❌ **재작업 필요 조건**:
- 빌드 실패
- 린트 에러
- 타입 에러
- 렌더링 실패
