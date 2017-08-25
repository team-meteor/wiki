# Test-Driven iOS Development with Swift 3

**Chapter 1, Your First Unit Tests, Xcode를 사용해 첫 번째 유닛 테스트를 연습하고, TDD를 사용하는 것의 이점에 대해 이야기한다.**  
*Chapter 2*, Planning and Structuring Your Test-Driven iOS App, 이 책을 통해 만들 앱과 Xcode 프로젝트를 세팅하는 법을 소개한다.  
*Chapter 3*, A Test-Driven Data Model, TDD의 데이터 모델에 논의한다.  
*Chapter 4*, A Test-Driven View Contorller, 뷰컨트롤러 테스트를 어떻게 작성할지를 보여줄 것이고, 가짜 객체를 이용해 작은 기능을 격리시키는 법을 설명한다.  
*Chapter 5*, Testing Network Code, stub을 이용해 아직 만들어지지 않은 서버 부분을 가장하는 법을 배울 것이다.  
*Chapter 6*, Putting It All Together, 이전에 개발된 다른 부분들을 합쳐보고, 기능 테스트의 사용을 보여줄 것이다.  
*Chapter 7*, Code Coverage and Continuous Integration, 어떻게 코드 커버리지를 측정하는지와 지속적인 통합에 대해 보여줄 것이다.

> 첫번째 유닛 테스트 만들기  
> TDD 이해하기  
> Xcode에서의 TDD  
> TDD의 장점과 단점

자동화 된 유닛테스트는 로봇이 필요한 테스트를 대신 수행해주는 것이다.

### Important built-in assert functions

`XCTAssertTrue(_:_:file:line:):`  
`XCTAssertFalse(_:_:file:line:):`  
`XCTAssertEqual(_:_:_:file:line:):`  
`XCTAssertEqualWithAccuracy(_:_:accuracy:_:file:line:):`  
`XCTAssertNotEqual(_:_:_:file:line:):`  
`XCTAssertNil(_:_:file:line:):`  
`XCTAssertNotNil(_:_:file:line:):`  
`XCTFail(_:file:line:):`  

```swift
// XCTAssert의 파라메터를 이용해 로그 조작할 수 있다.
XCTAssertEqual(numberOfVowels, 
  4,
  "should find 4 vowels in Dominik", 
  file: "FirstDemoTests.swift", 
  line: 24
)
```

```
FirstDemoTests.swift:24: error: -[FirstDemoTests.FirstDemoTests test_NumberOfVowels_WhenPassedDominik_ReturnsThree] 
: XCTAssertEqual failed: ("Optional(3)") is not equal to ("Optional(4)") - should find 4 vowels in Dominik
```

### Understanding TDD

Robert C. Martin이 TDD에 관한 세 가지 간단한 규칙을 제안했다.

원문

- You are not allowed to write any production code unless it is to pass a failing unit test
- You are not allowed to write any more of a unit test than is sufficient to fail, and compilation failures are failures
- You are not allowed to write any more production code than is sufficient to pass the one failing unit test

번역 ~~뭔말인지 모르겠다~~

- 실패하는 테스트를 통과하지 못한다면 제품 코드를 작성할 수 없다.
- 실패하기 충분한 더 이상의 유닛테스트를 작성할 수 없다. 그리고 컴파일 실패는 실패다.
- 하나의 실패하는 유닛테스트를 통과하기 충분한 더 이상의 제품 코드를 작성할 수 없다.

퍼오기 (테스트 주도 개발 by 채수원)
> 실패하는 테스트를 작성하기 전에는 절대로 제품 코드를 작성하지 않는다.  
> 실패하는 테스트 코드를 한 번에 하나 이상 작성하지 않는다.  
> 현재 실패하고 있는 테스트를 통과하기에 충분한 정도를 넘어서는 제품 코드를 작성하지 않는다.  

아직 선언되지 않은 새로운 클래스나 메소드를 사용하는 기능을 시작할 때, 테스트는 즉시 실패할 것이고, 테스트를 마치기 위한 약간의 코드를 추가해야 되기 때문에 이 규칙은 바보 같은 소리로 들릴 것이다. 하지만 이 규칙을 따르면, 기능을 구현하기 위한 실제로 필요한 코드만을 작성하게 된다. 모든 작성된 코드는 결국 최종 제품의 일부가 되거나 테스트 suite의 일부가 될 것이다.

한 번에 한 가지 기능에 집중하기 때문에 거의 모든 시간 동안 소프트웨어의 한 조각을 가질 것이다. 그래서 상사가 현재 상태에 대한 데모를 요청하면 철저하게 테스트 된 소프트웨어의 일부를 보여줄 수 있다.

### The TDD workflow – red, green, and refactor

일반적인 TDD 작업은 res, green 그리고 refactor 세 단계로 이루어진다. 

**Red**  
실패하는 테스트를 작성하는 것으로 시작한다. 아직 구현되지 않은 필수 기능이나 확실히 확신하고 싶은 케이스를 테스트 하는데에 필요하다. red라는 이름은 대부분의 IDE가 실패하는 테스트를 가리키는 방법에서 가지고 왔다. Xcode는 흰색 x가 있는 붉은 색 다이아몬드를 이용한다.

이 단계에서 작성하는 테스트가 처음에는 실패하는 것이 매우 중요하다. 그렇지 않으면 이 테스트가 작동하는지, 구현해야 할 기능을 진짜로 테스트하는지 확신할 수 없다. 항상 통과하는 테스트가 될 수 있고, 그렇다면 쓸모 없게 된다. 또는 해당 기능이 이미 구현되어있을 수도 있다. 어느 쪽이든 코드에 대한 통찰을 얻을 수 있다.

**Green**   
녹색 단계에서, 가장 간단한 통과하는 테스트를 작성할 수 있다. 작성한 코드가 좋은지 깨끗한지는 중요하지 않다. 코드는 멍청할 수도 심지어 틀릴 수도 있다. 모든 테스트를 통과하는 것만으로 충분하다. *green*이라는 이름은 대부분의 IDE가 통과하는 테스트를 표시하는 방식을 표현한다. Xcode는 흰색 체크마크가 있는 녹색 다이아몬드를 사용한다.

테스트를 통과하는 간단한 코드 작성을 시도하는 것이 가장 중요하다. 이를 통해 실제로 필요한 코드만을 작성할 수 있고, 가능한 가장 쉬운 구현 코드를 만들게 된다. 여기서 쉽다는 말은 읽기 쉽고, 이해하기 쉽고, 변경하기 쉽다는 의미이다.

종종 가장 쉬운 구현은 충분하지 않을 수 있지만 하지만 여전히 모든 테스트를 통과하기에는 충분하다. 이는 다음 개발으로 이끌 또 다른 실패하는 테스트가 필요하다는 의미이다.

**Refactor**  
녹색 단계에서 모든 테스트를 다시 통과하는 코드를 작성했다. 언급했듯 녹색 단계에서는 코드를 어떻게 보이는지는 중요하지 않다. 이 리팩터 단계에서 코드를 개선할 것이다. 중복을 제거하고, 일반 값을 추출하는 등을 할 것이다. 가능한 코드를 좋게 만드는 데에 필요한 것을 하면 된다. 이 테스트는 리팩토링 과정에서 기존에 구현된 것들을 중단하지 않아도 되게 한다.

마지막 리팩터 단계로부터 몇 줄의 코드만 작성했다면 코드를 깨끗하게 만드는 데는 많은 시간이 걸리지 않을 것이다.

### An example of TDD

블로깅 플랫폼을 만든다고 해보자. 새 포스트를 작성할 때, 사용자는 헤드라인을 포스트에 삽입할 것이다. 헤드라인의 모든 단어는 대문자로 시작해야 한다.

TDD를 시작하려면 실패하는 테스트가 필요하다. 다음의 질문은 테스트를 작성할 때 고려해야 하는 것들이다.

- Precondition: 메서드를 실행하기 전 시스템의 상태는?
- Invocation: 메서드의 시그니처는 어때야 하는가? 메서드의 입력 파라매터는 무언인가?
- Assertion: 기대하는 메서드의 실행 결과는 무엇인가?

블로깅앱을 예로 들때, 다음의 답이 가능하다.

- Precondition: 없음.
- Invocation: 문자열을 입력받고 문자열을 반환한다. 이름은 `makeHeadline`
- Assertion: 결과문자는 같아야하지만, 문자들의 첫글자가 대문자여야 한다.

*Red - example 1*

Open FirstDemoTests.swift, and add the following code to the FirstDemoTests class:

```swift
func test_MakeHeadline_ReturnsStringWithEachWordStartCapital() {
  let viewController = ViewController()
  let string = "this is A test headline"
  let headline = viewController.makeHeadline(from: string)
}
```

아무것도 테스트하지 않기 때문에 아직 완벽한 테스트가 아니다. `assertion`이 없다. 하지만 컴파일 에러가 났기 때문에 이 지점에서 테스트를 작성하는 것을 멈춰야 한다.

TDD를 따를때, 컴파일 에러를 해결할 코드를 추가해야한다. 코드가 테스트에서 컴파일되지 않는 것은 테스트가 실패하고 있다는 것을 기억하자. 그리고 실패하는 테스트는 더 이상 실패하지 않을 때까지 코드를 작성해야 하는 것을 의미한다.

`ViewController.swift`를 열고 다음 메서드를 `ViewController` 클래스에 추가하자.

```swift
func makeHeadline(from string: String) {}
```

여전히 에러는 남아있다. 테스트 타겟이 이 변화를 알도록 컴파일 해야 한다. 테스트를 실행해서 이 변화가 충분히 테스트를 통과시키는지 확인해야 한다. 헤드라인 상수가 더이상 사용되지 않는다는 경고가 발생하고, 그것을 `_`으로 바꾸자. 다음의 `assert` 함수를 테스트 마지막에 추가하자.

```swift
XCTAssertEqual(headline, "This Is A Test Headline")
```

또 다른 컴파일 에러가 발생한다. `makeHeadline(from:)`은 아무것도 반환하지 않는다. 그러나 `XCTAssertEqual`은 같은 타입의 표현식에서만 사용될 수 있다. 다른 타입의 두 표현식이 서로 같을 수 없다는 것은 말이 된다.

`ViewController`로 돌아가서 좀 바꾸자.

```swift
func makeHeadline(from string: String) -> String {
  return ""
}
```

*Green - example 1*

이제 메서드는 빈 문자열을 반환한다. 이는 테스트가 컴파일 되는 데에 충분하다. 테스트해보자. 테스트는 실패할 것이다. 하지만 이번에는 컴파일 에러가 아니라 assertion 실패 때문이다. 빈 문자열이 `"This Is A Test Headline"`와 같지 않다는 것은 놀랍지 않다. TDD를 따르면, 구현으로 돌아가서 테스트를 통과하게 하는 가장 간단한 코드를 추가해야 한다.

```swift
func makeHeadline(from string: String)-> String {
  return "This Is A Test HeadLine"
}
```

이 코드는 멍청하고 틀렸지만, 테스트를 통과시킬 가장 단순한 코드다. 테스트를 실행하고, 이것이 실제 케이스임을 확신하자.

방금 적은 코드가 우리가 구현하고자 하는 기능에 대해 쓸모없을 지라도 여전히 가치가 있다. 다른 테스트가 필요하다는 것을 말해준다.

*Refactor - example 1*

테스트를 더 작성하기 전에, 기존 코드를 리팩토링할 필요가 있다. 제품 코드에는 리팩토링 할 게 없다. 이 코드는 더 단순해지거나 더 우아해질 수 없다. 테스트 케이스에서, 두 개의 테스트 메서드가 있다. 둘 다 `ViewController` 인스턴스를 생성하면서 시작한다. 이는 중복된 코드이고, 좋은 리팩토링 대상이다.

`FirstDemoTests` 클래스의 첫 부분에 다음 프로퍼티를 추가하자.

```swift
var viewController: ViewController!
```

`setUp()` 메서드는 각각의 테스트가 실행되기 전에 호출된다는 것을 기억하자. 그래서 이 곳이 viewController 프로퍼티를 초기화하기에 가장 좋은 장소이다.

```swift
override func setUp() {
  super.setUp()
  viewController = ViewController()
}
```

이제 각각의 테스트에서 `let viewController = ViewController()`를 지우면 된다.

*Red - example 2*

이전 섹션에서 언급했듯, 제품 코드는 특정한 하나의 헤드라인을 검사하는 테스트만 통과하기 때문에 또 다른 테스트가 필요하다. 그러나 우리가 구현하고 싶은 기능은 가능한 모든 헤드라인에 대해 작동해야 한다. 다음 테스트를 `FirstDemoTests`에 추가하자.

```swift
func test_makeHeadline_ReturnsStringWithEachWordStartCapital2() {
  let string = "Here is another Example"
  let headline = viewController.makeHeadline(from: string)
  XCTAssertEqual(headline, "Here Is Another Example")
}
```

테스트를 실행하면 분명히 실패한다. 녹색으로 만들어 보자.

*Green - example 2*

`ViewController.swift`를 열고 `makeHeadline(from:)`을 다음 코드로 교체하자.

```swift
func makeHeadline(from string: String) -> String {
  let words = string.components(separatedBy: " ")
  var headline = ""
  for var word in words {
    let firstCharacter = word.remove(at: word.startIndex)
    headline += "\(String(firstCharacter).uppercased())\(word) "
  }
  headline.remove(at: headline.index(before: headline.endIndex))
  return headline
}
```

1. 문자열을 단어로 나눈다.
2. 각 단어를 순회하면서 첫 번째 글짜를 지우고, 대문자로 바꾼다. 그것을 단어 앞에 붙인다. 뒷 공백을 더해서 문자열에 더한다.
3. 마지막 공백을 지우고 문자열을 반환한다.

테스트를 돌리면 성공한다. 

*Refactor - example 2*

이 기능에 대한 두 가지 테스트를 보자. 읽기 힘들다. 덜 구조화되어 있다. 이걸 깨끗하게 해보자.

```swift
func test_MakeHeadline_ReturnsStringWithEachWordStartCapital() {
  let input = "this is A test headline"
  let exprectedOutput = "This Is A Test Headline"
  let headline = viewController.makeHeadline(from: input)
  XCTAssertEqual(headline, exprectedOutput)
}

func test_MakeHeadline_ReturnsStringWithEachWordStartCapital2() {
  let input = "Here is another Example"
  let exprectedOutput = "Here Is Another Example"
  let headline = viewController.makeHeadline(from: input)
  XCTAssertEqual(headline, exprectedOutput)
}
```

이제 테스트들을 쉽게 읽고, 이해할 수 있다. 이들은 논리적인 구조를 따른다. Precondition, Invocation, and Assertion.

모든 테스트를 통과하지만, 이전에 했던 테스트와 같은 것을 테스트하는지 알 수 없다. 대부분의 경우, 테스트를 리팩토링하면서 변경하는 코드는 테스트가 불필요하다. 그러나 때때로 테스트가 잘 작동하는지 확인하는 것이 좋다. 이는 실패하는 테스트를 다시 만들어야 한다는 것을 의미한다. `makeHeadline(from:)`으로 가서 아래 라인을 주석처리 하자.

```swift
headline.remove(at: headline.index(before: headline.endIndex))
```

다시 테스트하자. 두 개의 테스트는 실패한다.

주석 처리를 해제한 후 다시 테스트를 통과시켜보자. 이제 실제 코드를 리팩토링 해야 한다. 지금 구현된 코드는 Objective-C에서 swift로 번역한 것처럼 보인다. 스위프트는 읽기 쉬운 더 적은 코드를 작성할 수 있는 많은 개념을 제공한다. 좀 더 스위프트스럽게 만들어보자. 

```swift
func makeHeadline(from string: String) -> String {
  let words = string.components(separatedBy: " ")
  let headlineWords = words.map { (word) -> String in
    var mutableWord = word
    let first = mutableWord.remove(at: mutableWord.startIndex)
    return String(first).uppercased() + mutableWord
  }
  return headlineWords.joined(separator: " ")
}
```

리팩토링 한 것이 문제 없는지 다시 테스트해보자. 모든 테스트가 성공할 것이다.

### A recap

앞의 내용이 의미없어 보일 수고, 어떤 단계를 생략하고 싶을 수 있다. 그러면 그것은 더 이상 TDD가 아니다. TDD의 아름다운 점은 단계들이 아주 쉽기 때문에 그것에 대해서 생각하지 않아야 한다는 것이다. 단지 다음 단계만을 생각하자.

단계와 규칙이 매우 쉽기 때문에 단계가 실제로 어떤 의미가 있는지 고민하는데에 에너지를 쓰지 말자. 기억해야 하는 것은 red, green 그리고 refactor 이다. 결과로 테스트를 작성하고, 테스트를 통과시키고, 코드를 개선하는 것 따위의 어려운 부분에 집중할 수 있다.

### TDD 장단점

The advantages of TDD

- You only write code that is nedded.
- More modular design
- Easier to maintain
- Easier to refactor
- High test Coverage
- Tests document the code
- Less debugging

The disadvantages of TDD

- No silver bullet
- It seems slower at the beginnig
- All the members of a team need to do it
- Tests need to be maintained when requirements change

### What to test

어떤 걸 테스트해야 할까? TDD를 사용하고, 앞서 이야기한 규칙을 따른다면 답은 쉽다 전부. 실패하는 테스트가 있을 때에만 코드를 작성해야 한다.

현실에서 이는 쉽지 않다. 예를 들어, 버튼의 위치와 색이 테스트되어야 할까? 뷰의 계층 구조가 테스트 되어야 할까? 아닐 것이다. 버튼의 색과 정확한 위치는 앱의 기능에 중요하지 않다. 개발 초기 단계에서 이들은 바뀌는 경향이 높다. 버튼과 라벨은 오토레이아웃, 지역화 등 많은 조건에 의존적이다. 

일반적으로 사용자에게 유용한 기능과 작동해야 하는 기능을 테스트 해야 한다. 사용자는 버튼이 오른쪽에서 정확히 20포인트 떨어져 있는지는 관심 없다. 모든 사용자는 버튼이 예상한 대로 동작하는 것과 앱이 이쁜 것에 관심이 있다.

추가적으로, 앱 전체를 유닛 테스트하지 않는 것이 좋다. 유닛 테스트는 작은 단위의 계산을 테스트하기 위한 것이다. 이들은 빨라야하고 믿을만 해야 한다. 데이터베이스에 접근하기, 네트워킹은 실제로 완료된 앱을 구동하는 integration test로 진행해야 한다. 유닛테스트보다 훨씬 적게 수행되기 때문에 integration test는 느려도 된다. 보통은 개발 마지막 출시 전에 또는 테스트 완료 시간이 상관없는 CI 시스템의 서버에서 매일 밤 수행된다.












