---
name: figma-comments
description: "Figma 디자인 파일의 코멘트를 REST API로 읽고, 달고, 답글을 달고, 지운다. 공식 Figma MCP·플러그인 API(use_figma)로는 디자인 파일 코멘트에 접근할 수 없어서 이 스킬을 쓴다. 트리거 - '피그마 코멘트 확인해줘', '시안 코멘트 읽어줘', '이 파일 코멘트 보여줘', '코멘트 몇 번 반영', '피그마에 코멘트 달아줘', '이 노드에 코멘트 남겨줘', '코멘트에 답글 달아줘', '피그마 코멘트 지워줘', 'get Figma comments'. 토큰은 macOS 키체인(figma-api-token)에서 읽는다."
---

# figma-comments — Figma 코멘트 읽기·달기·답글·삭제

디자이너가 시안에 남긴 코멘트를 읽어 작업에 반영하거나, 작업 결과를 코멘트로 남길 때 쓴다.
코멘트는 Figma **REST API**에만 있어서, 공식 Figma MCP·`use_figma`로는 읽을 수 없다.

원본: [southleft/figma-console-mcp-skills](https://github.com/southleft/figma-console-mcp-skills)의
`figma-comments`(MIT, `LICENSE` 참고). 토큰을 키체인에서 읽고, 토큰을 명령줄에 노출하지 않으며,
삭제 전 확인 단계를 두고, 안내를 한국어로 바꿨다.

스크립트 위치: 이 파일과 같은 폴더의 `scripts/`. 아래 예시의 `$S`는 그 절대 경로다.

---

## 1. 시작 전 — 토큰 확인 (매번 먼저)

```bash
bash $S/setup-token.sh --check
```

| 결과 | 할 일 |
| --- | --- |
| 종료 코드 0 (등록되어 있음) | 바로 2단계로 간다 |
| 종료 코드 2 (없음) | **멈추고** 사용자에게 아래 등록 절차를 안내한다 |

**토큰 등록 안내 (사용자가 직접 한다)**

1. Figma → 설정 → 보안 → Personal access tokens에서 토큰을 발급한다.
   권한은 File content 읽기, Comments 읽기·쓰기(읽기만 쓸 거면 읽기만). 만료일을 정해 두기를 권한다.
2. Claude Code 입력창에 아래를 입력한다. 키체인 프롬프트가 토큰을 받는다.
   ```
   ! bash <S 절대 경로>/setup-token.sh
   ```
3. 등록되면 `--check`로 다시 확인하고 이어서 진행한다.

지켜야 할 것
- 토큰을 대화창에 붙여 달라고 하지 않는다. 사용자가 붙여 넣으면 그 토큰은 기록에 남으니 폐기를 권하고,
  새 토큰을 위 절차로 등록하게 한다.
- 키체인 값을 직접 꺼내 출력하거나(`security find-generic-password -w`), 파일·환경 변수에 옮기지 않는다.
  토큰은 스크립트 안에서만 쓴다.
- 토큰을 바꿀 때는 `setup-token.sh --replace`.

---

## 2. 파일 키

URL을 그대로 넘겨도 된다. 스크립트가 `/design/<키>/`·`/file/<키>/` 부분을 꺼낸다.

```
https://www.figma.com/design/CWMtYLKd6yxA6BBrJoFa10/...  →  CWMtYLKd6yxA6BBrJoFa10
```

---

## 3. 읽기

```bash
bash $S/get-comments.sh <URL 또는 키>                     # 미해결 스레드만
bash $S/get-comments.sh <URL 또는 키> --include-resolved  # 해결된 것까지
bash $S/get-comments.sh <URL 또는 키> --json              # 가공한 JSON
```

출력 예

```
스레드 12개 · 미해결 7개 · 해결 5개

#44  lisa  2026-11-12 14:03  · 노드 2529:1209  (id 1234567890)
    참고 이미지는 고정 크기로 보여 주세요.
    └ ian  2026-11-12 15:10  (id 1234567999)
      반영했습니다.
```

- `#번호`는 Figma 화면의 코멘트 번호다. 사용자가 "44번 코멘트"라고 하면 이 번호를 찾는다.
- `노드`는 코멘트가 고정된 레이어 id다. 시안을 볼 때 이 id로 Figma MCP `get_design_context`·`get_screenshot`을 부르면
  코멘트가 가리키는 화면을 바로 확인할 수 있다.
- `id`는 답글·삭제에 쓰는 값이다.

---

## 4. 달기·답글 — 실행 전 확인

디자이너에게 바로 보이는 작업이다. **실행 전에 보낼 내용과 위치(파일 전체 / 노드 / 어느 스레드의 답글)를
사용자에게 보여 주고 확인을 받은 뒤** 실행한다.

```bash
bash $S/post-comment.sh <URL 또는 키> "내용"                          # 파일 전체에
bash $S/post-comment.sh <URL 또는 키> "내용" --node 2529:1209         # 노드에 고정 (--x --y 로 위치 조정)
bash $S/post-comment.sh <URL 또는 키> "내용" --reply <스레드 id>       # 답글
```

- `@이름`은 Figma 화면에서만 동작한다. API로 넣으면 글자로만 남고 알림이 가지 않는다.
- 답글은 최상위 코멘트(스레드) id에 단다. 답글의 id에는 달 수 없다.

---

## 5. 삭제 — 항상 확인 후 진행

되돌릴 수 없다. 최상위 코멘트를 지우면 답글까지 스레드 전체가 사라진다.

1. `--yes` 없이 먼저 부른다. 아무것도 지우지 않고 대상만 보여 준 뒤 종료 코드 3으로 끝난다.
   ```bash
   bash $S/delete-comment.sh <URL 또는 키> <코멘트 id>
   ```
2. 출력된 대상(번호·작성자·내용·함께 지워질 답글 수)을 **사용자에게 그대로 보여 주고, AskUserQuestion으로
   삭제 여부를 묻는다.** 여러 개를 지울 때도 한 번에 묶어 보여 주되 목록 전체를 확인받는다.
3. 사용자가 삭제를 고른 경우에만 `--yes`를 붙여 다시 실행한다.
   ```bash
   bash $S/delete-comment.sh <URL 또는 키> <코멘트 id> --yes
   ```

사용자가 앞서 "지워줘"라고 했더라도 2단계 확인은 건너뛰지 않는다. 무엇이 지워지는지는 1단계 출력을 보고서야
알 수 있기 때문이다.

---

## 6. 오류

| 메시지 | 원인과 조치 |
| --- | --- |
| 토큰이 키체인에 없습니다 | 1단계 등록 절차 |
| 요청을 거부했습니다 (401·403) | 토큰 만료 또는 권한 부족. 쓰기·삭제는 Comments 쓰기 권한이 필요하다. 새로 발급해 `--replace` |
| 찾지 못했습니다 (404) | 파일 키·코멘트 id 확인. 파일에 접근 권한이 없는 계정의 토큰이어도 404가 난다 |
| 잠시 막았습니다 (429) | 요청 한도 초과. 잠시 뒤 다시 |

---

## 참고

- 해결(resolve) 처리는 REST API에 없다. 해결은 사용자가 Figma에서 직접 해야 한다.
- 엔드포인트: `GET/POST /v1/files/:key/comments`, `DELETE /v1/files/:key/comments/:id`
