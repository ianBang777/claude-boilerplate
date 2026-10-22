---
name: stibee-to-automail-template
description: 스티비 자동 이메일 한 통을 마이페어 어드민 자동메일 템플릿(제목·본문 HTML)으로 바꾼다. 스티비 id·HTML·파일을 받아 BE·FE develop 기준으로 발송 조건과 변수를 확정하고, 어드민 「HTML 입력하기」 프롬프트로 변환해 그대로 붙여 넣을 title.txt·html.txt 를 만든다. 트리거 - "/stibee-to-automail-template", "스티비 메일 템플릿 변환", "스티비 메일을 자동메일로", "스티비 id 3316120 변환해줘". 여러 통을 한 번에 받을 수 있다.
---

# 스티비 메일 → 자동메일 템플릿 변환

스티비가 보내던 메일 한 통을 어드민 자동메일에 등록할 수 있는 **제목 한 줄 + 본문 HTML** 로 바꾼다. 결과는 결과 폴더의 `title.txt` 와 `html.txt` 두 파일이고, 사용자는 각 파일을 열어 전체 복사한 뒤 어드민에 붙여 넣는다. 저장소 코드는 읽기만 하고 바꾸지 않는다.

변환의 지시문은 `prompt.md` 다. 어드민 「HTML 입력하기」 프롬프트에서 이 스킬이 쓰는 부분만 추린 것이다. 이 문서는 그 프롬프트에 넣을 발송 정보·변수를 develop 에서 찾아 채우고, 변환 결과를 검사하고 저장하는 바깥 절차만 정한다.

## When to Use

- 사용자가 스티비 id·본문 HTML·HTML 파일을 주며 자동메일 템플릿으로 바꿔 달라고 할 때
- 이미 바꾼 템플릿을 화면으로 보고 고칠 점을 말할 때 (8단계만 돈다)

## Input

셋 중 하나이고, 여러 통을 섞어 받을 수 있다. 메일마다 1~7단계를 돈다.

- **스티비 id** (권장): 예 `611583`
- **스티비 본문 HTML** 붙여넣기
- **본문 HTML 이 든 파일 경로**

선택 입력: 발송 조건(`AutoMailTriggerType` 항목 이름). 주면 2단계의 추론을 건너뛴다.

## 경로 표기

| 표기 | 실제 위치 |
|------|-----------|
| `BE/` | `/Users/ian/Documents/repo/myfair-server-kotlin/` |
| `FE/` | `/Users/ian/Documents/repo/client/` |
| `CSV` | `~/dev/MyfairDevVault/_attachments/stibee-auto-emails-<날짜>.csv` 중 가장 최근 것 |
| `결과/` | `~/dev/stibee-automail-templates/<스티비 id 또는 이름>/` |
| `AutoMailTriggerType` | `BE/myfair-persistence/rdb/src/main/kotlin/co/myfair/persistence/rdb/domain/mail/automail/types/AutoMailTriggerType.kt` |
| `automail/` | `BE/myfair-application/mail/src/main/kotlin/co/myfair/application/mail/domain/automail/` |
| 프롬프트 | 이 스킬의 `prompt.md` (원본: `FE/apps/admin/src/domain/autoMail/utils/buildAutoMailHtmlPrompt.ts`) |
| FE 조건 배열 | `FE/packages/core/src/autoMail/types/AutoMailTriggerType.ts` 의 `AutoMailTriggerTypes` |

- **확인 기준은 두 저장소의 origin/develop 이다.** 시작할 때 `git -C <저장소> fetch -q origin develop` 하고, 파일은 `git -C <저장소> show origin/develop:<경로>` 로 읽는다. checkout·브랜치 전환은 하지 않는다 (다른 세션이 워크트리를 쓴다).
- 위 경로는 작성 시점 기준이다. 없으면 `git -C <저장소> grep <심볼> origin/develop` 으로 찾고, 바뀐 경로를 이 표에 고쳐 둔다.

## Steps

### 1. 원본 확보

**스티비 id 로 받았을 때**

1. CSV 에서 그 행을 찾아 제목·분류·환경·주소록·BE 설정 키·BE 메일 클래스를 읽는다.
2. live 판을 기준으로 한다. 환경이 dev(제목 앞 `[TEST]`)면 같은 BE 메일 클래스의 live 행을 찾아 그 id 로 바꿀지 묻는다.
3. 분류가 「이관 대상」이 아니면(배치 대량 발송·스티비 내부·코드 미호출·옛 주소) 그대로 진행할지 묻는다.
4. 본문을 스티비에서 읽는다. 로그인된 크롬 탭이 필요하므로 Playwright MCP extension 모드(메모리 `playwright-mcp-extension-mode`)로 `stibee.com` 탭에 붙고, 페이지 안 `fetch` 로 내부 API 를 부른다.
   - 인증: 헤더 `accesstoken` 에 `localStorage.satellizer_token`. **토큰 값은 페이지 안에서만 쓰고 대화·파일·로그에 남기지 않는다.**
   - 메타: `GET https://stibee.com/api/v1.0/emails/{id}` (`subject`·`listName`).
   - 본문: `GET https://stibee.com/api/v1.0/editor/{id}/contents/html` (`text/html` 로 발송용 HTML 전체가 온다. `/emails/{id}` 응답에는 본문이 없다).
   - 연결이 안 되거나 본문을 못 찾으면 HTML 붙여넣기를 요청한다.

**HTML·파일로 받았을 때**: 제목은 사용자에게 받거나, id 를 알면 CSV 에서 찾는다.

어느 경우든 `결과/original.html`(본문 그대로)과 `결과/original-title.txt` 를 저장한다.

### 2. 발송 조건 확정

- 사용자가 지정했으면 그대로 쓴다.
- 아니면 추론하고 **근거와 함께 확인을 받는다** (AskUserQuestion). 단서:
  - CSV 의 BE 메일 클래스(예 `JoinCompanyRequestMail`)를 BE develop 에서 grep 한다. `AutoMailTriggerType` 항목 위 주석이나 이관 커밋 메시지에 남아 있는 경우가 많다.
  - 제목·주소록·보내는 때가 항목의 `koName`·`description` 과 맞는지 본다.

확정한 항목이 아래 둘 중 하나라도 없으면 멈추고 안내한다.

| 확인 | 없을 때 |
|------|---------|
| `AutoMailTriggerType` 에 있는가 | 등록할 수 없다. BE 이관(BE `.claude/skills/stibee-mail-migration`)을 먼저 하라고 안내한다 |
| FE 조건 배열에 있는가 | 어드민에서 골라도 `null` 이 되어 저장이 막힌다. core 추가를 먼저 하라고 안내한다 |

### 3. 발송 정보·변수 모으기

- 발송 정보: 항목의 `koName`(발송 조건)·`description`(보내는 때)·`receiverDescription`(받는 사람).
- 변수:
  1. `automail/spec/AutoMailTriggerTypeSpec.kt` 에서 그 조건의 spec 을 찾는다.
  2. `automail/trigger/<조건>/spec/*MailSpec.kt` 의 `variables` 가 묶는 `MailVariablesFrom*` 를 따라간다.
  3. `automail/mailvariables/MailVariablesFrom*.kt` 의 `key`·`koName` 을 모은다. `.from(pick = …)` 으로 묶여도 key 는 그대로다.

이 결과는 `report.md` 에 적고 대화에는 올리지 않는다. 사용자가 보고 판단할 것은 4단계의 질문에서 함께 보여 준다.

### 4. 변환

1. `prompt.md` 를 읽고 `{발송 정보}`·`{변수}` 를 3단계 결과로 채운다. 형식은 그 자리에 적힌 대로다.
2. 채운 프롬프트를 지시로 삼아 **작업 A(스티비 옮기기)** 로 본문을 바꾼다.
   - 프롬프트 2절대로, 판단이 갈리는 것은 HTML 을 만들기 전에 한 번에 모아 추천 답과 함께 묻는다 (AskUserQuestion). 없으면 묻지 않는다.
   - 프롬프트 5절 「결과물 검토」를 통과시킨 뒤 확정한다.
3. 원본 프롬프트가 바뀌었는지 의심되면 FE develop 의 원본과 `prompt.md` 를 비교해 맞춘다. 매번 하지는 않는다.
4. 제목도 바꾼다. 스티비 변수(`$%fairTitle%$` 등)를 본문과 같은 대응으로 바꾸고, 맞는 변수가 없으면 확인 필요로 남긴다. `(광고)` 표기는 그대로 둔다.
5. 함께 챙긴다.
   - 변수 대응표: 스티비 변수·고정 값 → 바꾼 변수, 맞는 변수가 없는 것.
   - 교체할 이미지: `stibee.com` 이미지의 원래 주소·위치·용도. **업로드는 사용자가 한다.** 공개 도메인(MYFAIR_OFFICIAL 등)의 CloudFront 주소를 받으면 본문에 바꿔 넣고 「교체 필요」 주석을 지운다.
   - 광고성 메일: 주소록이 「광고성 메일 수신 동의」이거나 제목에 `(광고)` 가 있으면 `(광고)` 표기와 수신거부 안내·링크를 본다. 스티비가 넣던 수신거부 링크(스티비 전용 치환자)는 우리 메일 모듈에서 동작하지 않으므로 확인 필요로 띄운다.

### 5. 기계 검사

프롬프트 5절 「결과물 검토」를 `title.txt`·`html.txt` 를 대상으로 grep 으로 다시 확인한다. 어긋나면 고친 뒤 다시 검사한다.

### 6. 눈으로 비교

`original.html` 과 `html.txt` 를 로컬 크롬 헤드리스로 찍어 Read 로 열어 비교한다. 로그인이 필요 없으므로 Playwright MCP(extension 모드는 연결 대기에 걸린다)는 쓰지 않는다. 본문이 길면 `--window-size` 높이를 늘린다.

```bash
C="/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
"$C" --headless=new --disable-gpu --hide-scrollbars --user-data-dir=<임시 폴더>/chrome-original \
  --window-size=700,1150 --screenshot=<결과>/original.png "file://<결과>/original.html"
cp <결과>/html.txt <임시 폴더>/body.html
"$C" --headless=new --disable-gpu --hide-scrollbars --user-data-dir=<임시 폴더>/chrome-body \
  --window-size=700,1150 --screenshot=<결과>/body.png "file://<임시 폴더>/body.html"
```

문구·색·여백·배치·이미지 색과 크기의 차이만 짚는다. 의도한 차이(로고 교체 등)는 `report.md` 에 적고, 의도하지 않은 차이는 고친 뒤 5단계부터 다시 한다.

### 7. 결과 출력

`결과/` 에 저장한다.

| 파일 | 내용 |
|------|------|
| `title.txt` | 제목 한 줄. 줄 끝 개행 없음 |
| `html.txt` | 본문 전체, `<!DOCTYPE html>` 부터 `</html>` 까지. `.txt` 라 열면 텍스트로 보이고 전체 복사하면 끝난다 |
| `report.md` | 발송 조건, 변수 대응표, 교체할 이미지, 눈으로 비교한 차이, 확인 필요 항목 |

대화에는 아래만 쓴다. 제목·본문·변수표·요약표를 대화에 올리지 않는다.

- `title.txt` 와 `html.txt` 의 절대 경로 한 줄씩
- 확인 필요 항목이 있으면 한 줄씩 (없으면 쓰지 않는다)
- 여러 통이면 메일마다 위 묶음을 반복한다

### 8. 수정 요청

사용자가 화면을 보고 고칠 점을 말하면 `prompt.md` 의 **작업 C(수정하기)** 로 고친다. 바꿀 부분만 바꾸고 나머지는 한 글자도 바꾸지 않는다. 5단계 검사를 다시 돌리고 7단계 형식으로 다시 알린다.

### 9. 마무리 안내

한 줄로 알린다. 어드민에서 자동메일 생성 → 발송 조건 선택 → `title.txt` 붙여넣기 → 「HTML 입력하기」에 `html.txt` 붙여넣기 → 저장 → 「테스트 발송」으로 실제 메일 앱에서 확인. 원하면 볼트 「스티비 내재화 — 메일 이관 현황」에 변환 완료를 표시한다.

## 따를 규칙

- 변환의 판단 기준은 `prompt.md` 가 정한다. 이 문서는 그와 어긋나는 규칙을 두지 않는다. 어긋나면 `prompt.md` 를 따르고 이 문서를 고친다.
- 묻는 것은 AskUserQuestion 으로, 추천 답을 첫 번째 선택지에 둔다.

## 하지 않는 것

- 저장소 코드 수정·커밋·checkout·브랜치 전환
- 이미지 업로드 (사용자가 한다)
- 스티비 토큰을 대화·파일·로그에 남기기
- 제목·본문 HTML 을 대화에 출력하기
