---
tags: ["verify", "code"]
applies_to: ["code"]
---

# Code Verification Skill

일반 코드 작업 완료 후 필수 검증 절차를 제공합니다.

---

## 필수 검증 항목

### 1. 단위 테스트

```bash
# Node.js
npm test

# Python
pytest

# Go
go test ./...

# Rust
cargo test

# Java
mvn test
```

**확인 사항**:
- 모든 테스트 통과
- 새 코드에 테스트 추가됨

---

### 2. 린트

```bash
# JavaScript/TypeScript
npm run lint

# Python
flake8 . && black --check .

# Go
golangci-lint run

# Rust
cargo clippy
```

**확인 사항**:
- 린트 에러 없음
- 코드 스타일 일관성

---

### 3. 타입 체크 (정적 타입 언어)

```bash
# TypeScript
npx tsc --noEmit

# Python (mypy)
mypy src/

# Go (컴파일로 타입 체크)
go build

# Rust (컴파일로 타입 체크)
cargo check
```

**확인 사항**:
- 타입 에러 없음

---

### 4. 빌드/컴파일

```bash
# Node.js
npm run build

# Python (패키지 빌드)
python -m build

# Go
go build

# Rust
cargo build
```

**확인 사항**:
- 빌드 성공
- 경고 최소화

---

## WORK_LOG 기록 형식

```markdown
## 검증 결과

### 단위 테스트
\`\`\`bash
$ npm test
✓ 15 tests passed
\`\`\`

### 린트
\`\`\`bash
$ npm run lint
✓ No issues
\`\`\`

### 타입 체크
\`\`\`bash
$ npx tsc --noEmit
✓ No errors
\`\`\`

### 빌드
\`\`\`bash
$ npm run build
✓ Built successfully
\`\`\`
```

---

## Reviewer 평가 기준

✅ **승인 조건**:
- 테스트 통과
- 린트 통과
- 타입 체크 통과
- 빌드 성공

❌ **재작업 필요 조건**:
- 테스트 실패
- 린트 에러
- 타입 에러
- 빌드 실패
