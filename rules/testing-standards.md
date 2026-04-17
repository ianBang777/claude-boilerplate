# Testing Standards

테스트 작성 시 준수해야 할 핵심 원칙.

---

## 좋은 단위 테스트의 4대 요소

1. **회귀 방지**: 버그 발견 능력
2. **리팩터링 내성**: 구현 변경 시 깨지지 않음
3. **빠른 피드백**: 실행 속도
4. **유지보수성**: 이해하고 수정하기 쉬움

**핵심**: 구현이 아닌 최종 결과(동작)를 검증하라.

---

## 테스트 대상: 도메인 모델과 알고리즘

**테스트 해야 할 것**:
- 복잡도가 높거나 중요한 도메인 로직
- 알고리즘 (계산, 변환, 검증 등)

**테스트하지 말아야 할 것**:
- 단순 CRUD (DB/API 호출만)
- Getter/Setter
- 프레임워크 코드

```python
# ✅ Good - 도메인 로직 테스트
def test_order_total_with_discount():
    order = Order()
    order.add_item(100, quantity=2)  # 200
    order.apply_discount(0.1)         # 10% 할인

    assert order.total() == 180

# ❌ Bad - 단순 CRUD 테스트
def test_user_repository_save():
    user = User(name="John")
    repository.save(user)  # DB 호출만 확인

    assert repository.find_by_id(user.id) == user
```

---

## 목(Mock) 사용 원칙

### 관리 의존성 vs 비관리 의존성

**관리 의존성** (애플리케이션 내부):
- 실제 객체 사용 (Mock 금지)
- 예: 도메인 모델, 서비스, 유틸리티

**비관리 의존성** (외부 시스템):
- Mock 사용
- 예: DB, 외부 API, 메시지 큐, SMTP

```python
# ✅ Good - 외부 의존성만 Mock
def test_user_registration():
    mock_email_gateway = Mock()
    mock_database = Mock()

    # 실제 도메인 객체 사용
    user_controller = UserController(mock_database, mock_email_gateway)

    user_controller.register("user@example.com")

    # 외부 시스템 호출만 검증
    mock_email_gateway.send_welcome_email.assert_called_once()
    mock_database.save_user.assert_called_once()

# ❌ Bad - 내부 로직까지 Mock
def test_order_process():
    mock_calculator = Mock()  # 도메인 로직을 Mock
    mock_calculator.calculate_total.return_value = 100

    order = Order(mock_calculator)
    # 실제 계산 로직이 테스트되지 않음
```

---

## 테스트 구조: AAA 패턴

모든 테스트는 명확히 3단계로 구분:

```python
def test_purchase_succeeds_when_enough_inventory():
    # Arrange - 준비
    store = Store()
    store.add_inventory(Product.Shampoo, 10)
    customer = Customer()

    # Act - 실행
    success = customer.purchase(store, Product.Shampoo, 5)

    # Assert - 검증
    assert success == True
    assert store.get_inventory(Product.Shampoo) == 5
```

**원칙**:
- Act는 한 줄 (하나의 동작만 테스트)
- Given-When-Then으로도 표현 가능
- 단계 사이 빈 줄로 구분

---

## 출력 기반 테스트 우선

**테스트 스타일 우선순위**:
1. **출력 기반**: 입력 → 출력 (부작용 없음)
2. **상태 기반**: 상태 변경 검증
3. **통신 기반**: Mock을 통한 호출 검증

```python
# 1. 출력 기반 (Best) - 함수형
def test_discount_calculation():
    price = calculate_discount(100, customer_type="Premium")
    assert price == 90

# 2. 상태 기반 (Good) - 객체 상태 확인
def test_product_added_to_cart():
    cart = ShoppingCart()
    cart.add_product(product)
    assert len(cart.products) == 1

# 3. 통신 기반 (Last Resort) - 외부 시스템만
def test_email_sent_on_registration():
    mock_gateway = Mock()
    service = UserService(mock_gateway)

    service.register("user@example.com")

    mock_gateway.send_email.assert_called_once()
```

---

## 험블 객체 패턴

복잡한 로직과 외부 의존성을 분리:

```python
# ❌ Bad - 로직과 I/O 혼재
class OrderService:
    def process_order(self, order_id):
        order = self.db.get_order(order_id)  # I/O
        total = order.calculate_total()       # 로직
        self.db.save_order(order)             # I/O
        self.email.send(order.email, total)   # I/O

# ✅ Good - 로직 분리
class Order:  # 도메인 로직 (테스트 쉬움)
    def calculate_total(self):
        return sum(item.price for item in self.items)

    def apply_discount(self, rate):
        self.discount = self.subtotal() * rate

class OrderService:  # 오케스트레이션만 (통합 테스트)
    def process_order(self, order_id):
        order = self.db.get_order(order_id)
        # Order 객체가 로직 수행
        self.db.save_order(order)
        self.email.send(order.email, order.total())
```

---

## 리팩터링 내성 확보

**구현 세부사항 테스트 금지**:

```python
# ❌ Bad - 내부 메서드 테스트
def test_normalize_is_called():
    spy = Mock(wraps=calculator)
    spy.normalize(data)
    assert spy.normalize.called  # 구현 세부사항

# ✅ Good - 최종 결과 테스트
def test_calculates_correct_average():
    result = calculator.calculate_average([1, 2, 3, 999])
    assert result == 2  # 정규화 결과만 검증
```

**원칙**:
- private 메서드 테스트 금지
- 중간 상태 검증 금지
- 호출 순서 검증 최소화

---

## 단위 테스트 vs 통합 테스트

**단위 테스트**:
- 도메인 모델, 알고리즘
- 빠름, 격리됨
- 외부 의존성 Mock

**통합 테스트**:
- 외부 시스템과의 상호작용
- 실제 DB/API 사용
- 느리지만 신뢰도 높음

```python
# 단위 테스트 - 도메인 로직
def test_order_discount_logic():
    order = Order()
    order.add_item(100)
    order.apply_vip_discount()
    assert order.total() == 80

# 통합 테스트 - 전체 플로우
def test_order_processing_flow(test_db):
    # 실제 DB 사용
    order_service = OrderService(test_db, real_payment_gateway)

    order_id = order_service.create_order(customer_id=1)
    order_service.process_payment(order_id)

    order = test_db.get_order(order_id)
    assert order.status == "Paid"
```

---

## 핵심 체크리스트

**테스트 작성 시**:
- [ ] 최종 결과(동작)를 검증하는가?
- [ ] 내부 구현이 바뀌어도 깨지지 않는가?
- [ ] 관리 의존성은 실제 객체를 사용하는가?
- [ ] 비관리 의존성만 Mock했는가?
- [ ] AAA 패턴이 명확히 구분되는가?
- [ ] Act가 한 줄인가?

**테스트 대상 선택 시**:
- [ ] 복잡도 또는 중요도가 높은가?
- [ ] 도메인 로직 또는 알고리즘인가?
- [ ] 단순 CRUD는 제외했는가?

**리팩터링 시**:
- [ ] 구현 변경 시 테스트가 깨지는가? → 나쁜 테스트
- [ ] 동작 변경 시 테스트가 깨지는가? → 좋은 테스트

---

## References

- "단위 테스트" (Vladimir Khorikov)
- Test Pyramid: https://martinfowler.com/articles/practical-test-pyramid.html
