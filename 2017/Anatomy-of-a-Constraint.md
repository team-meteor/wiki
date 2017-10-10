# Anatomy of a Constraint

뷰 계층의 레이아웃은 일련의 선형 방정식으로 정의된다. 각각의 constraints는 하나의 방정식을 표현한다. 단 하나의 가능한 해결책을 갖는 일련의 방정식을 선언하는 것이 목표다.

다음은 방정식의 예제다.

![equation-example](https://developer.apple.com/library/content/documentation/UserExperience/Conceptual/AutolayoutPG/Art/view_formula_2x.png)

이 constraints는 빨간 뷰의 leading edge가 파란 뷰의 trailing edge 보다 8.0 포인트 뒤여야 한다는 것을 말한다. 이 방정식은 몇 가지 부분이 있다:

- item 1. 이 경우 빨간 뷰이다. 아이템은 view나 layout guide 여야 한다. 
- attribute 1. 첫번째 아이템의 구속되는 요소이다. 이 경우 빨간 뷰의 leading edge.
- relationship. 왼쪽과 오른쪽의 관계이다. equal, greater than or equal, less than or equal 세 가지가 가능핟. 이 경우는 equal.
- multiplier. attribute 2의 값에 이 부동 소수점 숫자를 곱한다. 이 경우 1.0
- item2. 이 방정식의 두 번째 아이템. 이 경우 파란뷰. 첫째 아이템과 달리 공백이 가능하다.
- attribute 2. 두 번째 아이템에서 구속되는 요소이다. 이 경우 trailing egde이다. 두번째 아이템이 비면 당연히 요소도 없다.
- constant. 상수, 부동 소수점 offset. 이 경우 8.0이며, attribute 2에 더해진다. 

대부분의 constraints는 유저 인터페이스 상의 두 아이템 간의 관계를 정의한다. 이 아이템은 view들 또는 layout guide들을 표현한다. Constraints 한 아이템의 서로 다른 요소의 관계를 정의할 수도 있다. 예를 들어, 한 아이템의 높이와 너비의 비율을 정할 수 있다. 아이템의 높이나 너비에 상수를 할당하는 것도 가능하다. 상수값을 사용할 때는 당연히 두 번째 아이템은 비게 되고, attribute는 `Not An Attribute`가 되고, multiplier는 0.0이 된다. 

### Auto Layout Attributes

