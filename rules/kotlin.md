---
tags: ["kotlin", "backend", "code"]
applies_to: ["code"]
---

# Kotlin Coding Standards

Kotlin 백엔드 작업 시 적용되는 코딩 기준과 가이드라인입니다.

**참조 시점**:
- Worker: Kotlin 코드 작성 시작 전 필수 참조
- Reviewer: Kotlin 코드 품질 검토 시 기준으로 사용

---

## 파일 구조 원칙

### 하나의 .kt 파일에는 하나의 class를 두는 것을 권장

- [ ] 각 .kt 파일이 **단일 클래스만** 포함하는가?
- [ ] 파일명이 클래스명과 **동일**한가? (예: `UserService.kt` → `class UserService`)
- [ ] 관련된 작은 헬퍼 클래스는 **별도 파일로 분리**되었는가?

**예외**:
- 밀접하게 관련된 sealed class와 그 하위 클래스
- data class와 그 확장 함수만 포함된 파일
- 파일 크기가 매우 작은 경우 (50줄 이내)

**예시**:
```kotlin
// ✅ Good: UserService.kt
class UserService(
    private val userRepository: UserRepository
) {
    fun findUser(id: String): User? = userRepository.findById(id)
}

// ✅ Good (예외): Result.kt
sealed class Result<out T> {
    data class Success<T>(val data: T) : Result<T>()
    data class Error(val message: String) : Result<Nothing>()
}

// ❌ Bad: Services.kt (여러 클래스)
class UserService { ... }
class OrderService { ... }
class ProductService { ... }
```

---

## Kotlin 코딩 스타일

### 네이밍 컨벤션

- [ ] 클래스명: **PascalCase** (예: `UserService`)
- [ ] 함수/변수명: **camelCase** (예: `findUser`, `userId`)
- [ ] 상수: **UPPER_SNAKE_CASE** (예: `MAX_RETRY_COUNT`)
- [ ] 패키지명: **소문자** (예: `com.example.service`)

### Null Safety

- [ ] nullable 타입(`?`)을 **명시적으로** 사용했는가?
- [ ] `!!` (강제 언래핑)을 **최소화**했는가?
- [ ] `let`, `?.`, `?:` 등 안전 호출 연산자를 활용했는가?

**예시**:
```kotlin
// ❌ Bad
val user: User = userRepository.findById(id)!!

// ✅ Good
val user: User? = userRepository.findById(id)
user?.let { processUser(it) }

// ✅ Good
val user: User = userRepository.findById(id) ?: return null
```

### Immutability

- [ ] 가능한 한 `val` 사용했는가? (`var` 최소화)
- [ ] data class의 프로퍼티가 **불변**인가?
- [ ] 컬렉션은 **불변 인터페이스**를 사용했는가? (`List` vs `MutableList`)

**예시**:
```kotlin
// ✅ Good
data class User(
    val id: String,
    val name: String,
    val email: String
)

val users: List<User> = listOf(...)

// ❌ Bad
data class User(
    var id: String,
    var name: String,
    var email: String
)

val users: MutableList<User> = mutableListOf(...)
```

---

## Kotlin 특화 기능 활용

### Data Classes

- [ ] 값 객체(Value Object)는 **data class**로 구현했는가?
- [ ] `equals()`, `hashCode()`, `toString()`, `copy()`가 필요한가?

### Extension Functions

- [ ] 유틸리티 함수를 **확장 함수**로 구현했는가?
- [ ] 확장 함수가 해당 타입의 **응집도를 높이는가**?

**예시**:
```kotlin
// ✅ Good
fun String.isValidEmail(): Boolean {
    return this.matches(Regex("^[A-Za-z0-9+_.-]+@(.+)$"))
}

// Usage
if (email.isValidEmail()) { ... }

// ❌ Bad: 일반 함수
fun isValidEmail(email: String): Boolean { ... }
```

### Higher-Order Functions

- [ ] 반복 로직을 **고차 함수**로 추상화했는가?
- [ ] `map`, `filter`, `fold` 등 표준 라이브러리를 활용했는가?

**예시**:
```kotlin
// ✅ Good
val activeUsers = users.filter { it.isActive }
val userNames = users.map { it.name }

// ❌ Bad
val activeUsers = mutableListOf<User>()
for (user in users) {
    if (user.isActive) {
        activeUsers.add(user)
    }
}
```

### Sealed Classes

- [ ] 제한된 계층 구조는 **sealed class**를 사용했는가?
- [ ] enum 대신 **타입 안전성이 높은 sealed class** 고려했는가?

**예시**:
```kotlin
// ✅ Good
sealed class ApiResult<out T> {
    data class Success<T>(val data: T) : ApiResult<T>()
    data class Error(val code: Int, val message: String) : ApiResult<Nothing>()
    object Loading : ApiResult<Nothing>()
}

when (result) {
    is ApiResult.Success -> handleSuccess(result.data)
    is ApiResult.Error -> handleError(result.message)
    ApiResult.Loading -> showLoading()
}

// ❌ Bad: enum으로는 데이터 전달 어려움
enum class Status { SUCCESS, ERROR, LOADING }
```

---

## 함수형 프로그래밍

### Scope Functions

- [ ] `let`, `run`, `with`, `apply`, `also`를 **적절히** 사용했는가?
- [ ] 스코프 함수가 **가독성을 높이는가**?

**사용 가이드**:
```kotlin
// let: null 체크 + 변환
user?.let { processUser(it) }

// apply: 객체 초기화
val user = User().apply {
    name = "John"
    email = "john@example.com"
}

// also: 부수 효과 (로깅 등)
val result = calculateResult()
    .also { logger.info("Result: $it") }

// run: 컨텍스트 객체 + 반환값
val isValid = user.run {
    age >= 18 && country == "KR"
}
```

### Lambda 표현식

- [ ] 람다가 **한 줄을 초과**하면 별도 함수로 분리했는가?
- [ ] 파라미터가 하나면 **`it` 대신 명시적 이름** 사용을 고려했는가?

**예시**:
```kotlin
// ✅ Good
users.filter { user -> user.age >= 18 }

// ✅ Good (매우 간단한 경우만 it 허용)
users.filter { it.isActive }

// ❌ Bad (복잡한 로직에 it 사용)
users.filter {
    it.age >= 18 &&
    it.country == "KR" &&
    it.verified &&
    it.balance > 1000
}
```

---

## 에러 처리

### Result 타입

- [ ] 예외 대신 **Result 타입** 사용을 고려했는가?
- [ ] `runCatching`으로 예외를 Result로 변환했는가?

**예시**:
```kotlin
// ✅ Good
fun findUser(id: String): Result<User> = runCatching {
    userRepository.findById(id) ?: throw NotFoundException("User not found")
}

// Usage
findUser(id)
    .onSuccess { user -> processUser(user) }
    .onFailure { error -> handleError(error) }

// ❌ Bad
fun findUser(id: String): User {
    return userRepository.findById(id) ?: throw NotFoundException("User not found")
}
```

### Custom Exceptions

- [ ] 도메인별 예외 클래스를 정의했는가?
- [ ] 예외 메시지가 **구체적**인가?

---

## 코루틴 (비동기 처리)

### Structured Concurrency

- [ ] `suspend` 함수를 적절히 사용했는가?
- [ ] `CoroutineScope`를 명시적으로 관리하는가?
- [ ] `Job`을 취소하는 로직이 있는가?

**예시**:
```kotlin
// ✅ Good
suspend fun fetchUser(id: String): User {
    return withContext(Dispatchers.IO) {
        userRepository.findById(id)
    }
}

// ✅ Good: Scope 관리
class UserService(
    private val scope: CoroutineScope
) {
    fun loadUsers() = scope.launch {
        val users = fetchUsers()
        updateUI(users)
    }
}
```

### Flow

- [ ] 스트림 데이터는 **Flow**를 사용했는가?
- [ ] `collect` 대신 `collectLatest`, `collectIndexed` 등 적절한 연산자를 사용했는가?

---

## 테스트

### 테스트 프레임워크

- [ ] **Kotest** 또는 **JUnit 5** 사용
- [ ] **MockK** for mocking

### 테스트 작성 원칙

- [ ] Given-When-Then 구조를 따르는가?
- [ ] 테스트 함수명이 **동작을 설명**하는가?

**예시**:
```kotlin
// ✅ Good
@Test
fun `should return user when valid id is provided`() {
    // Given
    val userId = "user123"
    every { userRepository.findById(userId) } returns mockUser

    // When
    val result = userService.findUser(userId)

    // Then
    assertThat(result).isEqualTo(mockUser)
}
```

---

## SOLID 원칙 (Kotlin 적용)

### Dependency Injection

- [ ] 생성자 주입을 사용했는가?
- [ ] DI 프레임워크 (Koin, Dagger 등) 활용했는가?

**예시**:
```kotlin
// ✅ Good
class UserService(
    private val userRepository: UserRepository,
    private val emailService: EmailService
) {
    fun registerUser(user: User) {
        userRepository.save(user)
        emailService.sendWelcomeEmail(user.email)
    }
}

// ❌ Bad
class UserService {
    private val userRepository = UserRepository()
    private val emailService = EmailService()
}
```

### Interface Segregation

- [ ] 인터페이스가 **최소한의 메서드**만 포함하는가?
- [ ] Kotlin의 `interface` 활용했는가?

---

## 체크리스트 요약

### 필수 준수 항목 (하나라도 미달 시 재작업)

- [ ] **파일 구조**: 하나의 .kt 파일에 하나의 class
- [ ] **Null Safety**: `!!` 최소화, 안전 호출 연산자 사용
- [ ] **Immutability**: `val` 우선, data class 불변 프로퍼티
- [ ] **네이밍**: Kotlin 컨벤션 준수 (PascalCase, camelCase)
- [ ] **에러 처리**: 빈 catch 블록 없음, 구체적 에러 메시지

### 권장 사항 (개선 제안 가능)

- [ ] **확장 함수**: 유틸리티 로직 확장 함수로 구현
- [ ] **고차 함수**: 반복 로직 추상화
- [ ] **Sealed Class**: 제한된 계층 구조 표현
- [ ] **Scope Functions**: 가독성 향상
- [ ] **코루틴**: 비동기 처리 시 structured concurrency

---

## 참조

- **공통 원칙**: `rules/coding-standards.md` - SOLID, Clean Code 원칙
- **품질 기준**: `rules/quality-standards.md` - 검증 방법
- **태그 시스템**: `rules/tags.md` - kotlin 태그 매핑
