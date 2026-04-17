---
tags: ["verify", "pulumi", "infra"]
applies_to: ["infra"]
---

# Pulumi Verification Skill

Pulumi 인프라 코드 작업 완료 후 필수 검증 절차를 제공합니다.

---

## 목적

- Worker가 Pulumi 작업 완료 후 이 Skill을 호출하여 검증 수행
- `pulumi preview`를 통한 사전 검증으로 배포 전 문제 발견
- 검증 결과를 WORK_LOG.md에 기록하여 Reviewer가 평가

---

## 필수 검증 항목

### 1. Pulumi Preview 실행

**명령어**:
```bash
pulumi preview
```

**확인 사항**:
- 에러 없음
- 경고(warning) 검토 및 해결 또는 정당화
- 변경 사항(추가/수정/삭제 리소스) 확인

**예시**:
```bash
$ pulumi preview
Previewing update (dev):

     Type                    Name                Plan
 +   pulumi:pulumi:Stack     myapp-dev           create
 +   ├─ aws:iam:Role         lambda-role         create
 +   ├─ aws:lambda:Function  handler             create
 +   └─ aws:s3:Bucket        logs                create

Resources:
    + 4 to create

Duration: 5s
```

---

### 2. 에러 확인

**검증 기준**:
- 에러 발생 시 → **즉시 수정 후 재실행**
- 에러 0건이 될 때까지 반복

**일반적인 에러**:
- 리소스 이름 중복
- IAM 권한 부족
- 리전 미지정
- 필수 속성 누락

---

### 3. 경고(Warning) 처리

**검증 기준**:
- 경고 발생 시 → **해결하거나 정당화**
- 무시하는 경우 → WORK_LOG에 이유 명시

**일반적인 경고**:
- S3 버킷 버저닝 미설정
- 암호화 미설정
- 퍼블릭 액세스 허용
- 로그 보관 기간 미설정

**정당화 예시**:
```markdown
- 경고: S3 버킷 버저닝 미설정
- 정당화: 로그 전용 버킷으로 버저닝 불필요. 수명 주기 정책으로 30일 후 자동 삭제.
```

---

### 4. 리소스 변경 검토

**검증 기준**:
- 추가(+): 의도한 리소스만 추가되는지 확인
- 수정(~): 의도하지 않은 속성 변경 없는지 확인
- 삭제(-): **특히 주의** - 의도한 삭제인지 재확인

**주의 사항**:
- 삭제 작업은 프로덕션 데이터 손실 가능
- 수정 작업은 기존 리소스 재생성(교체) 유발 가능
- `replace` 표시가 있는 경우 특히 신중히 검토

---

### 5. 보안 설정 확인

**검증 기준**:
- IAM 역할: 최소 권한 원칙 준수
- 네트워크 규칙: 불필요한 포트 오픈 금지
- 암호화: 민감 데이터는 암호화 설정
- 퍼블릭 액세스: 필요한 경우만 허용

**체크리스트**:
- [ ] IAM 역할에 `*` 권한 없음
- [ ] 보안 그룹 0.0.0.0/0 최소화
- [ ] S3 버킷 퍼블릭 액세스 차단 (필요 시 제외)
- [ ] 데이터베이스 암호화 활성화
- [ ] Secrets는 AWS Secrets Manager 사용

---

### 6. 비용 영향 검토

**검증 기준**:
- 새 리소스 추가 시 예상 비용 명시
- 리소스 타입 변경 시 비용 증감 확인

**WORK_LOG 기록 예시**:
```markdown
## 비용 영향
- Lambda 함수 3개 추가: 예상 월 $5 (100만 요청 기준)
- S3 버킷 1개 추가: 예상 월 $1 (10GB 기준)
- 총 예상 증가: 월 $6
```

---

## WORK_LOG 기록 형식

```markdown
## 검증 결과

### Pulumi Preview
\`\`\`bash
$ pulumi preview
Previewing update (dev):

     Type                    Name                Plan
 +   pulumi:pulumi:Stack     myapp-dev           create
 +   ├─ aws:iam:Role         lambda-role         create
 +   ├─ aws:lambda:Function  handler             create
 +   └─ aws:s3:Bucket        logs                create

Resources:
    + 4 to create

Duration: 5s
\`\`\`

### 에러 확인
- 에러: 없음 ✓

### 경고 처리
- 경고: 1건
  - S3 버킷 버저닝 미설정
  - 정당화: 로그 전용 버킷으로 버저닝 불필요. 수명 주기 정책으로 30일 후 자동 삭제.

### 리소스 변경
- **추가 (4개)**:
  - Stack: myapp-dev
  - IAM Role: lambda-role
  - Lambda Function: handler
  - S3 Bucket: logs
- **수정**: 없음
- **삭제**: 없음

### 보안 설정
- IAM 역할: 최소 권한 (Lambda 실행 + S3 쓰기만) ✓
- 네트워크: VPC 내부 통신만 ✓
- 암호화: S3 버킷 SSE-S3 활성화 ✓
- 퍼블릭 액세스: 모두 차단 ✓

### 비용 영향
- Lambda 함수 3개: 예상 월 $5 (100만 요청 기준)
- S3 버킷 1개: 예상 월 $1 (10GB 기준)
- 총 예상 증가: 월 $6
```

---

## 검증 실패 시 조치

### 에러 발생 시
1. 에러 메시지 확인
2. 코드 수정
3. `pulumi preview` 재실행
4. 에러 0건 확인

### 경고 발생 시
1. 경고 원인 파악
2. 다음 중 선택:
   - **해결**: 코드 수정 후 재실행
   - **정당화**: WORK_LOG에 무시하는 이유 명시

### 의도하지 않은 변경 발견 시
1. 코드 리뷰로 원인 파악
2. 의도한 변경만 남도록 수정
3. `pulumi preview` 재실행
4. 변경 사항 재확인

---

## 검증 불가능한 경우

### AWS 자격증명 없음 (로컬 환경)
```markdown
## 검증 결과

### Pulumi Preview
- **실행 불가**: AWS 자격증명 없음 (로컬 환경)
- **대안**: 코드 리뷰로 리소스 정의 확인

### 코드 리뷰 결과
- Lambda 함수 3개:
  - handler: runtime=nodejs20.x, memory=256MB ✓
  - timeout: 30초 ✓
  - role: lambda-role 참조 ✓
- IAM 역할:
  - 정책: AWSLambdaExecute, S3WriteAccess ✓
  - 최소 권한 원칙 준수 ✓
- S3 버킷:
  - 이름: myapp-logs-{randomId} ✓
  - 암호화: SSE-S3 ✓
  - 수명 주기: 30일 후 삭제 ✓
```

---

## Reviewer 평가 기준

Reviewer는 WORK_LOG.md의 "검증 결과"를 확인하여:

✅ **승인 조건**:
- `pulumi preview` 실행됨
- 에러 0건
- 경고 해결 또는 정당화됨
- 리소스 변경이 의도한 것과 일치
- 보안 설정 적절함
- 비용 영향 명시됨

❌ **재작업 필요 조건**:
- `pulumi preview` 미실행
- 에러 존재
- 경고 무시 (정당화 없음)
- 의도하지 않은 리소스 변경
- 보안 이슈 존재
- 비용 영향 미명시

---

## 참고

- 이 Skill은 Worker가 Pulumi 작업 완료 후 호출
- 검증 결과는 WORK_LOG.md에 위 형식으로 기록
- Reviewer는 이 기준으로 검증 결과 평가
