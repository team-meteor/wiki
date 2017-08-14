# iOS Unit Testing and UI Testing Tutorial
> [iOS Unit Testing and UI Testing Tutorial](https://www.raywenderlich.com/150073/ios-unit-testing-and-ui-testing-tutorial) 를 재가공하였습니다.   

### What to Test?
어떤 테스트를 진행하기 전에 기본에서 시작하는 것이 중요하다. 어떤 테스트가 필요할까? 만약 기존에 있는 앱을 확장하는 것이 목표라면, 변경할 계획인 요소에서 시작하는 것이 좋다.

일반적으로 아래의 것들을 테스트 하는 것이 좋다.
- 핵심 기능 : 모델 클래스와 메서드, 그들의 컨트롤러와의 상호작용
- 가장 일반적인 UI 워크플로들
- 한계 조건
- 버그 수정

### First Things FIRST : Best Practices for Testing
- Fast: 테스트는 빨라야 한다. 그래야 앱을 실행시키지 않을 수 있다.
- Independent / Isolated: 하나의 테스트는 다른 테스트를 준비하거나 정리해줄 필요가 없다.
- Repeatable: 테스트는 매번 같은 결과를 얻을 수 있어야 한다. 외부 데이터 공급이나 동시성 문제는 경우에 따라 실패할 수 있다.
- Self-validating: 테스트는 완전히 자동이어야 한다. 로그 파일 해석보다는 “pass”나 “fail” 같은 결과가 낫다.
- Timely: 이상적으로, 테스트는 프로덕션 코드를 작성하기 바로 전에 작성되어야 한다.

## Getting Started
**BullsEye**, **HalfTunes** [start projects](https://koenig-media.raywenderlich.com/uploads/2016/12/Starters.zip) 

Let’s start testing!
## Unit Testing in Xcode
### Creating a Unit Test Target
`Command-5`를 누르면 test navigator를 열 수 있다. `+` 버튼을 눌러 `New Unit Test Target`

- `Product\Test`, `Command-U`를 누르면 모든 테스트를 실행한다.
- test navigator에서 화살표를 눌러도 된다.
- gutter에서 다이아몬드 버튼을 눌러도 된다.

### Using XCTAssert to Test Models
```swift
// BullsEye의 클래스와 메소드에 접근할 수 있게 해준다.
@testable import BullsEye 
var gameUnderTest: BullsEyeGame!

// SUT(System Under Test) 객체를 만든다.
// 이를 통해 SUT의 프로퍼티나 메서드에 접근할 수 있다.
gameUnderTest = BullsEyeGame()

// targetValue를 생성한다.
// 게임 점수 계산의 정확도를 테스트할 것이다.
gameUnderTest.startNewGame() 

// tearDown() 에서 super를 부르기 전에 SUT 객체를 해제시키면 된다.
gameUnderTest = nil
```

```swift
func testScoreIsComputed() {
	let guess = gameUnderTest.targetValue + 5 // given
	_ = gameUnderTest.check(guess: guess) // when
	XCTAssertEqual(gameUnderTest.scoreRound, 95, "Score computed from guess is wrong") // then
}
```

Assertions fall into five categories:
- **Unconditional Fail**. Use this when simply reaching a particular branch of code indicates a failure. The only assertion in this category is *XCTFail*.
* **Equality Tests**. Use these to assert a relationship between two items. For example, *XCTAssertEqual* asserts that two expressions have the same value, while *XCTAssertEqualWithAccuracy* asserts that two expressions have the same value within a certain accuracy. This category also includes tests for inequality, such as *XCTAssertNotEqual* and *XCTAssertGreaterThan*.
- **Boolean Tests**. Use these to assert that a Boolean expression evaluates a certain way, for example using *XCTAssertTrue* or *XCTAssertFalse.*
Nil Tests. Use these to assert that an item is or is not nil, for example using *XCTAssertNil* or *XCTAssertNotNil*.
- **Exception Tests**. Use these to assert that evaluating an expression generates an exception or not. You look for any exception to be thrown with *XCTAssertThrows*, or you can look for a specific exception with an assertion like *XCTAssertThrowsSpecific*. You can also assert the inverse, that no exception is thrown when evaluating an expression, using a function like *XCTAssertNoThrow*.

> Given-When-Then 구조는 Behavior Driven Development(BDD)에서 비롯되었다. 대안으로 Arrange-Act-Assert와 Assemble-Activate-Assert가 있다.  

### Debugging a Test
BullsEyeGame에 버그가 있으니 찾아보자. `testScoreIsComputed`를 `testScoreIsComputedWhenGuessGTTarget`로 바꾸고 붙여넣어 보자.

```swift
func testScoreIsComputedWhenGuessGTTarget() {
  let guess = gameUnderTest.targetValue - 5   // 1. given
  _ = gameUnderTest.check(guess: guess)   // 2. when
  XCTAssertEqual(gameUnderTest.scoreRound, 95, "Score computed from guess is wrong")    // 3. then
}
```

breakpoint navigator 에서 `Test Failure Breakpoint`를 만들어 보자. 테스트 메서드가 실패하면 테스트를 멈추게 한다.

![test failure breakpoint](https://koenig-media.raywenderlich.com/uploads/2016/12/AddTestFailureBreakpoint.png)

테스트를 실행하면 `XCTAssertEqual`에서 멈출 것이다.
디버그 콘솔에서 `gameUnderTest`와 `guess`를 보자.

![debug console](https://koenig-media.raywenderlich.com/uploads/2016/12/TestFailure.png)

`guess` 는 `targetValue` - 5 지만, `scoreRound`는 95가 아닌 105다.
일반적인 디버깅 과정을 통해서 좀 더 파헤쳐보자. when 문장과 `BullsEyeGame.swift` 의 `check(_:)`의 `difference`를 생성하는 곳에 브레이크 포인트를 걸자. 

![debug diffence](https://koenig-media.raywenderlich.com/uploads/2016/12/DebugConsole.png)

`difference`가 음수인 것이 문제다. 그래서 100점이 되버린다. 코멘트를 해제하면 절대값으로 계산된다. 틀린 건 지우고, 브레이크 포인트도 날리고 테스트를 하면 성공을 확인할 수 있다.

### Using XCTestExpectation to Test Asynchronous Operations
모델을 테스트하는 것과 테스트 실패를 디버깅하는 것을 배웠으니 `XCTestExpectation`를 이용한 네트워크 작업 테스트를 해보자.

`HalfTunes`를 열자. `URLSession`를 이용해 iTunes API에 쿼리하고 샘플 노래를 다운 받는다. 이것을 `AlamoFire`로 변경한다고 해보자. 뭔가 막히는 것을 알려면, 코드를 바꾸기 전후에 네트워크 작업에 대한 테스트를 작성하고 실행해야 한다.

`URLSession`은 비동기다. 즉시 제어권을 반환하지만, 일정 시간 후에 실제로 작업이 종료된다. 비동기 메서드를 테스트하려면, `XCTestExpectation`을 이용해 테스트가 비동기 작업을 완료할 때까지 기다리게 할 수 있다.

비동기 테스트는 일반적으로 느리기때문에 비교적 빠른 테스트와는 분리하는 것이 좋다.

`New Unit Test Target`를 눌러 `HalfTunesSlowTests`를 만들자. 
```swift
@testable import HalfTunes
var sessionUnderTest: URLSession!
override func setUp() {
	super.setUp()
	sessionUnderTest = URLSession(configuration: URLSessionConfiguration.default)
}
override func tearDown() {
	sessionUnderTest = nil
	super.tearDown()
}
func testValidCallToiTunesGetsHTTPStatusCode200() {
	let url = URL(string: "https://itunes.apple.com/search?media=music&entity=song&term=abba") // given
	// expectation(_:)은 XCTestExpectation 객체를 반환한다.
	let promise = expectation(description: "Status code: 200")
	let dataTask = sessionUnderTest.dataTask(with: url!) { // when
		data, response, error in 
		if let error = error { // then
			XCTFail("Error: \(error.localizedDescription)")
			return
		} else if let statusCode = (response as? HTTPURLResponse)?.statusCode {
			if statusCode == 200 {
				promise.fulfill()
			} else {
				XCTFail("Status code: \(statusCode)")
			}
		}
	}
	dataTask.resume()
	// 모든 expectation이 충족될 때까지 혹은 timeout까지 테스트가 동작하게 합니다.
	waitForExpectations(timeout: 5, handler: nil)
}
```

### Fail Faster

```swift
func testCallToiTunesCompletes() {
	let url = URL(string: "https://itune.apple.com/search?media=music&entity=song&term=abba") // given
	let promise = expectation(description: "Completion handler invoked")
	var statusCode: Int?
	var responseError: Error?
	let dataTask = sessionUnderTest.dataTask(with: url!) { // when
		data, response, error in 
		statusCode = (response as? HTTPURLResponse)?.statusCode
		responseError = error
		promise.fulfill()
	}
	dataTask.resume()
	waitForExpectations(timeout: 5, handelr: nil)
	XCTAssertNil(responseError) // then
	XCTAssertEqual(statusCode, 200)
}
```

1초 정도 후에 completion handler에 진입하면 expectation을 충족하게 된다. 요청이 실패하면 `then` 검증에 실패한다.

테스트를 실행해보자. 1초 후에 테스트를 실패한다. 시간 초과가 아닌 요청 실패로 실패한다.
`url`을 고쳐보자. 그러면 성공한다.

## Faking Objects and Interactions

비동기 테스트는 코드가 API에 대한 올바른 입력을 생성하는 것에 대한 확신을 준다. 아마 `URLSession`이 요청에 대한 제대로 된 응답을 받는지 또는 이 결과가 `UserDefaults`나 CloudKit 데이터베이스를 제대로 업데이트하는지 테스트하고 싶을 것이다.

대부분의 앱은 제어할 수 없는 시스템이나 라이브러리 객체들과 통신하게 되는데, 이 때문에 테스트는 FIRST 원칙의 두 가지를 어기게 된다. 느려지고, 반복이 불가능해진다. 대신, `subs`에서 입력을 가져오거나 `mock` 객체를 업데이트하면서 가짜로 상호작용할 수 있다.

시스템이나 라이브러리에 대한 **의존**이 있을 때 가짜를 사용하자. 해당 부분 역할을 수행할 수 있는 가짜 객체를 만들고, 이를 코드에 **주입**하자. [Dependency Injection · objc.io](https://www.objc.io/issues/15-testing/dependency-injection/)이 이를 위한 몇 가지 방법을 설명하고 있다.

![great pretender](https://koenig-media.raywenderlich.com/uploads/2016/12/fake.png)

### Fake Input From Stub

테스트에서 `updateSearchResults(_:) ` 메서드가 다운받은 데이터를 정확히 파싱하는지, `searchResults.count`가 옳은지를 확인할 것이다. SUT는 view controller이고, stubs과 먼저 받은 데이터를 이용해 이 세션을 속일 것이다.

`New Unit Test Target`를 선택해 `HalfTunesFakeTests`를 만들자.

```swift
@testable import HalfTunes
var controllerUnderTest: SearchViewController!
override func setUp() {
	super.setUp()
	controllerUnderTest = UIStoryboard(name: "Main", bundle: nil)
		.instantiateInitialViewController() as! SearchViewController!
}
override func tearDown() {
	controllerUnderTest = nil
	super.tearDown()
}
```

HalfTunes는 무거운 view controller 문제가 있기 때문에 SUT는 view controller 이다. [Networking with NSOperation as your wingman | William Boles](http://williamboles.me/networking-with-nsoperation-as-your-wingman/) 별도의 모듈로 네트워킹 코드를 옮기는 것이 이 문제를 줄일 수 있고, 테스트를 더 편하게 만들 수 있다.

가짜 세션이 사용할 샘플 JSON 데이터가 필요하다. 몇 개만 있으면 된다. 다음의 url을 사용해 제한된 결과를 받아보자.
```
https://itunes.apple.com/search?media=music&entity=song&term=abba&limit=3
```

파일명을 `abbaData.json`으로 변경 후 `HarlfTunesFakeTests` 그룹에 추가하자.

프로젝트 내에 `DHURLSessionMock.swift` 이 있을 것이다. `URL` 또는 `URLRequest`로 data task를 만들 수 있는 methods(stubs)가 있는  `DHURLSession`이라는 간단한 프로토콜이 정의되어 있다. 이 프로토콜을 따르는 `URLSessionMock ` 도 있다. data, response 그리고 error를 이용해 가짜 `URLSession ` 객체를 만들 수 있는 생성자(initializers)도 포함되어 있다.

`setUp()`내 SUT를 만드는 문장 뒤에서 가짜 data와 response를 만들고, 가짜 객체를 만들자.

```swift
let testBundle = Bundle(for: type(of: self))
let path = testBundle.path(forResurce: "abbaData", ofType: "json")
let data = try? Data(contentsOf: URL(fileURLWithPath: path!), options: .alwaysMapped)
let url = URL(string: "https://itunes.apple.com/search?media=music&entity=song&term=abba")
let urlResponse = HTTPURLResponse(url: url!, statusCode: 200, httpVerion: nil, headerFields: nil)
let sessionMock = URLSessoinMock(data: data, resopnse: urlResponse, error: nil)
```

`setUp()`의 끝에서 가짜 세션을 SUT의 프로퍼티로 삽입하자.

```swift
controllerUnderTest.defaultSession = sessionMock
```

이 테스트에서는 가짜 세션을 직접 사용할 것이지만, 이것은 어떻게 주입 하는지를 보여주고자 함이고, 다른 테스트에서는 view controller의 `defaultSession` 프로퍼티를 사용하는 SUT의 메서드를 호출할 수 있다.

```swift
func test_UpdataSearchResults_ParsesData() {
	let promise = expectation(description: "Status code: 200") // given
	XCTAssertEqual( // when
		controllerUnderTest?.searhResults.count, 
		0, 
		"searchResults should be emplty before the the data task runs") 
	let url = URL(
		string: "https://itunes.apple.com/search?media=music&entity=song&term=abba")
	let dataTask = controllerUnderTask?.defaultSession.dataTask(with: url!) {
		data, respnse, error in
			if let error = error {
				print(error.localizedDescription)
			} else if let httpResponse = resopnse as? HTTPURLResponse {
				if httpResponse.statusCode == 200 {
					promise.fulfill()
					self.controllerUnderTest?.updateSearchResults(data)
				}
			}
	}
	dataTask?.resume()
	waitForExpectations(timeout: 5, handelr: nil)
	
	XCTAssertEqual( // then
		controllerUnderTest?.searhResults.count, 
		3, 
		"Didn't parse 3 items from fake response") 
}
```

stub은 여전히 비동기 메서드인 척 하기 때문에 테스트도 비동기로 작성해야 한다.

*when* assertion은 data task가 실행되기 전에 `searchResults`가 비어있는지 검증하는 것이고, `setUp()`에서 방금 새로운 SUT를 만들었기 때문에 당연히 true여야 한다. 

가짜 데이터는 세 개의 `Track` 객체에 대한 JSON을 가지고 있고, *then* assertion은 view constroller의 `searchResults` 배열이 세 가지 item을 가지고 있는지를 검증한다. 

테스트를 수행하자. 실제 네트워크가 아니기 때문에 아주 빠르게 성공할 것이다.

### Fake Updae to Mock Object

이전 테스트에서는 가짜 객체에서의 입력 때문에 `stub`을 사용했다. 이번에는 코드가 정확히 `UserDefaults`를 업데이트하는지를 `mock object`를 이용해 테스트할 것이다.

`BullsEye` 프로젝트를 다시 열자. 이 앱은 두 가지 게임 스타일이 있다. 하나는 유저가 슬라이더를 움직여서 목표 값을 맞추는 것, 다른 하나는 슬라이더 위치를 이용해 목표 값을 추정하는 것이다. 오른쪽 하단 모서리의 segmented control는 게임 스타일을 변경하고, 맞춰서 user default의 `gameStyle`을 업데이트 한다.

다음 테스트는 앱이 정확히 user default의 `gameStyle` 업데이트하는지를 확인한다.

`New Unit Test Target`을 누르고, `BullsEyeMockTests`라고 만들자.

```swift
@testable import BullsEye
class MockUserDefaults: UserDefaults {
	var gameStyleChanged = 0
	override func set(_ value: Int, forKey defaultName: String) {
		if defaultName == "gameStyle" {
			gameStyleChanged += 1
		}
	}
}
```

`MockUserDefaults`는 `set(_:forKey:)`를 재정의하여 `gameStyleChanged` 플래그를 증가시킨다. `Bool` 변수를 이용하는 방법도 있지만 `Int`를 증가시키는 것이 좀 더 유연하다. 예를 들면, 정확히 한 번 불렸는지 확인할 수도 있다.

`BullsEyeMockTests`에 SUT와 가짜 객체를 선언하자.

```swift
var controllerUnderTest: ViewController!
var mockUserDefaults: MockUserDefaults!
```

`setUp()`에서 SUT와 가짜 객체를 생성하고, SUT의 프로퍼티로 가짜 객체를 주입하자.

```swift
controllerUnderTest = UIStoryboard(name: "Main",bundle: nil)
	.instantiateInitialViewController() as! ViewController!
mockUserDefaults = MockUserDefaults(suiteName: "testing")!
controllerUnderTest.defaults = mockUserDefaults
```

`tearDown()`에서 SUT와 가짜 객체를 해제 하자.

```swift
controllerUnderTest = nil
mockUserDefaults = nil
```

`testExample()`를 삭제하고, 테스트 하나 만들자.

```swift
func testGameStyleCanBeChanged() {
	let segmentedControl = UISegemntControl() // given
	XCTAssertEqual( // when
		mockUserDefaults.gameStyleChanged, 
		0, 
		"gameStyleChanged should be 0 before sendActions"
	)
	segmentedControl.addTarget(
		controllerUnderTest,
		action: #selector(ViewController.chooseGameStyle(_:)),
		for: .valueChanged
	)
	segmentedControl.sendActions(for: .valueChanged)
	
	XCTAssertEqual( // then
		mockUserDefaults.gameStyleChanged,
		1,
		"gameStyle user default wasn't changed"
	)
}
```

*when* assertion은 테스트 메서드가 segmented control을 "taps" 하기 전에 `gameStyleChanged`플래그가 0인지를 검증한다. 그래서 *then* assertion이 참이라면, `set(_:forKey:)`은 정확히 한 번 불린 것이 된다.

테스트를 수행하자. 성공할 것이다.

## UI Testing in Xcode

Xcode7 부터 도입된 UI testing은 상호작용을 기록하는 방법으로 테스트를 수행한다. 쿼리를 통해 UI object를 찾고, 해당 object에 합성된 이벤트를 보낸다. 이 API는 UI object의 프로퍼티나 상태가 기대한 것과 맞는지 비교할 수 있게 한다.

`BullsEyeUITests`로 이름 짓고, `UI Test Target`을 추가하자.

제일 위에 프로퍼티를 하나 추가하자.

```swift
var app: XCUIApplication!
```

`setUp()`에서 다음을 추가하자.

```swift
app = XCUIApplication()
app.launch()
```

`testExample()`를 `testGameStyleSwitch()`로 바꾸자.

![new line](https://koenig-media.raywenderlich.com/uploads/2016/12/UITest.png)

붉은 색 `Record` 버튼을 누르자.
앱이 시뮬레이터에 나타나면, `Slide` segment 스위치와 top label을 **tap**하자. `Record` 버튼을 눌러서 기록을 중지하자.

```swift
let app = XCUIApplication()
app.buttons["Slide"].tap()
app.staticTexts["Get as close as you can to: "].tap()
```

위의 코드가 생겼을 것이고, 다른 것이 있다면 지우자.
좀 바꿔서 해보자.

```swift
// given
let slideButton = app.segmentedControls.buttons["Slide"]
let typeButton = app.segmentedControls.buttons["Type"]
let slideLabel = app.staticTexts["Get as close as you can to: "]
let typeLabel = app.staticTexts["Guess where the slider is: "]

// then
if slideButton.isSelected {
  XCTAssertTrue(slideLabel.exists)
  XCTAssertFalse(typeLabel.exists)
  
  typeButton.tap()
  XCTAssertTrue(typeLabel.exists)
  XCTAssertFalse(slideLabel.exists)
} else if typeButton.isSelected {
  XCTAssertTrue(typeLabel.exists)
  XCTAssertFalse(slideLabel.exists)
  
  slideButton.tap()
  XCTAssertTrue(slideLabel.exists)
  XCTAssertFalse(typeLabel.exists)
}
```

각각의 버튼이 선택되거나 탭되었을 때 옳은 라벨이 존재하는지를 확인할 수 있다. 테스트를 수행해 모든 assertion이 성공하는 것을 확인하자.

## Performance Testing

## Code Coverage

### 100% Coverage?

## Where to Go From Here?













