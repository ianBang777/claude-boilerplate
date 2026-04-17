# /create-api-be-to-fe

`~/Documents/repo/myfair-server-kotlin` 의 특정 커밋 해시를 시작점으로,
그 이후 커밋들에서 추가·변경된 Controller / DTO / Enum 을 분석하여
`~/Documents/repo/client` 의 TypeScript 코드로 변환한다.

## 옵션

`--hash` 가 없으면 작업을 시작하지 않고 해시를 요청한다.

```
/create-api-be-to-fe --hash <커밋해시>
```

---

## 실행 순서

### 1단계: 커밋 시작점 찾기

```bash
cd ~/Documents/repo/myfair-server-kotlin

# 해시 이후 커밋 목록 확인
git log <해시>..HEAD --oneline

# 해시 이후 변경된 파일 목록
git diff <해시>..HEAD --name-only
```

변경 파일 중 아래 패턴에 해당하는 파일만 대상으로 한다.

| 패턴                         | 설명                |
| ---------------------------- | ------------------- |
| `*Controller.kt`             | API 엔드포인트 정의 |
| `*Request.kt`                | 요청 DTO            |
| `*Response.kt`               | 응답 DTO            |
| `*Dto.kt`                    | 공용 DTO            |
| `enum class` 를 포함한 `.kt` | 도메인 열거형       |

비즈니스 로직(`Service`, `Repository`, `Command`, `Entity`)은 변환 대상에서 제외한다.

---

### 2단계: 변경사항 분석 (병렬 실행)

대상 파일 각각에 대해 다음을 병렬로 파악한다.

1. **도메인** — 패키지 경로(`co.myfair.api.domain.{domain}`)에서 추출
2. **종류** — Controller / Request DTO / Response DTO / Enum
3. **엔드포인트** — Controller의 경우 HTTP 메서드 + 경로 (`@GetMapping`, `@PostMapping` 등)
4. **필드 목록** — `data class` 의 각 프로퍼티 이름·타입·nullable 여부
5. **FE 기존 파일 존재 여부** — `packages/api/src/{domain}/` 에 해당 *Api, *Api2, types 파일이 있는지 확인

---

### 3단계: 배치 위치 결정

파일 성격에 따라 아래 규칙으로 출력 경로를 결정한다.

#### `packages/core/src/{domain}/`에 배치하는 것

- **Enum** — HTTP와 무관한 순수 도메인 상태값
  - Kotlin `enum class` → TypeScript union type
  - 경로: `packages/core/src/{domain}/enums/{EnumName}.ts`
  - 예: `ParticipationStatus.ts`, `MfVoucherType.ts`

#### `packages/api/src/{domain}/`에 배치하는 것

- **Request DTO** — API 요청 body / query parameter 타입
  - 경로: `packages/api/src/{domain}/types/{TypeName}.ts` 또는 `types.ts`
- **Response DTO** — API 응답 body 타입
  - 경로: `packages/api/src/{domain}/types/{TypeName}.ts` 또는 `types.ts`
- **Api2 메서드** — Controller 엔드포인트를 FetchApi 호출로 래핑
  - 경로: `packages/api/src/{domain}/{Domain}Api2.ts`
  - 해당 도메인의 `*Api2.ts`가 이미 존재하면 **새 파일을 만들지 않고 기존 파일에 메서드를 추가**한다.

#### 판단이 애매한 경우

- Enum이 Request/Response DTO 안에서만 쓰이고 독립적 의미가 없다면 → `packages/api/src/{domain}/types/` 에 함께 배치
- 여러 도메인에서 공유될 수 있는 기본 타입이라면 → `packages/api/src/commonTypes.ts` 참조 후 결정

---

### 4단계: TypeScript 변환

#### Kotlin → TypeScript 타입 매핑

| Kotlin                    | TypeScript              |
| ------------------------- | ----------------------- |
| `String`                  | `string`                |
| `Int`, `Long`, `Double`   | `number`                |
| `Boolean`                 | `boolean`               |
| `T?`                      | `T \| null`             |
| `List<T>`                 | `T[]`                   |
| `Map<K, V>`               | `Record<K, V>`          |
| `enum class Foo { A, B }` | `type Foo = "A" \| "B"` |

- `@JsonProperty("key")` 가 있으면 해당 key를 필드명으로 사용한다.
- `companion object`, `fun`, `init` 블록 등 로직은 변환하지 않는다.
- validation 어노테이션(`@NotBlank`, `@Email` 등)은 주석으로만 남긴다.

#### Api2 메서드 패턴

```typescript
// packages/api/src/{domain}/{Domain}Api2.ts
import { CustomResponse } from "../commonTypes";
import FetchApi from "../FetchApi";
import { SomeRequest, SomeResponse } from "./types";

export default class {Domain}Api2 {
  static async {methodName}(
    fetch: FetchApi,
    data: SomeRequest,
  ): Promise<CustomResponse<SomeResponse>> {
    return await fetch.post(`/api/v1/endpoint`, data);
  }
}
```

#### Enum 패턴

```typescript
// packages/core/src/{domain}/enums/{EnumName}.ts
export type {EnumName} = "VALUE_A" | "VALUE_B" | "VALUE_C";
```

#### Response / Request 타입 패턴

```typescript
// packages/api/src/{domain}/types.ts (또는 types/{TypeName}.ts)
export interface {TypeName}Response {
  fieldA: string;
  fieldB: number | null;
}

export interface {TypeName}Request {
  fieldA: string;
  fieldB: number;
}
```

---

### 5단계: 작업 요약 출력

작업 완료 후 아래 형식으로 출력한다.

```markdown
## BE → FE 변환 요약

### 생성·수정된 파일

| 파일 경로             | 작업               | 변환 원본         |
| --------------------- | ------------------ | ----------------- |
| packages/core/src/... | 신규               | SomeDomain.kt     |
| packages/api/src/...  | 신규               | SomeRequest.kt    |
| packages/api/src/...  | 수정 (메서드 추가) | SomeController.kt |

### 확인 필요

- [BLOCK] ...
- [WARN] ...
```

---

## 유의사항

- `*Api2.ts` 파일이 이미 존재하면 새로 만들지 않고 메서드만 추가한다. (`api-architecture.mdc` 참고)
- Controller 경로가 `*ControllerPath.kt` 같은 별도 파일에 정의된 경우, 해당 파일도 함께 확인하여 실제 경로를 사용한다.
- nullable 여부(`?`)는 반드시 반영한다. 누락 시 런타임 오류 원인이 된다.
- `packages/core`는 HTTP 레이어에 의존하지 않는 순수 도메인 개념만 둔다. FetchApi나 CustomResponse를 import하지 않는다.
- 변환 대상이 없으면(해당 범위 커밋에 Controller/DTO/Enum 변경 없음) 그 사실을 명시하고 종료한다.
