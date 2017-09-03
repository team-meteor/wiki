## 5 Testing Network code 

앱스토어에 있는 대부분의 앱은 한 가지 이상의 방법으로 네트워킹을 수행한다. 애플은 네트워크 요청을 위해 `URLSession` 클래스를 제공한다. 이때의 요청은 비동기다. 백그라운드 스레드에서 응답을 받는 것을 의미한다. 이런 방법이 없다면, UI는 멈추고, 서버에서 응답이 도착할 때까지 기다려야 한다.

이 장의 주요 주제는 비동기 API를 테스트하는 법이다. 비동기 API 요청을 테스트하는 두 가지 방법이 있다. 첫째는, 앱이 앱스토어 있을 때 사용하는 되는 방법으로 실제 서버를 이용하는 것이다. 둘째로, 이전 챕터에서 사용했던 `stubs`를 사용할 수 있다.

두 가지 모두 각자의 장점이 있다. 실제 서버로 테스트하는 것은 서버가 문서대로 구현되었는지를 추가로 테스트할 수 있다. 이런 테스트는 완성된 앱의 구현에 가깝고, 최종 버전에서 끝날 버그를  찾기도 쉽다.

한편, `stubs`을 통해 심지어 웹서비스를 만들기도 전에도 앱의 네트워크 레이어를 개발할 수 있다. API와 기대하는 응답에 대한 문서만 있으면 된다. 서버와의 상호작용에 의존하지 않기 때문에 테스트 속도는 아주 빠르다.

이 장에서 다음 주제를 다룰 것이다.

- 실제 웹서비스를 이용한 테스트 구현
- 가짜 웹서비스에 대한 로그인 요청 만들기
- 에러 다루기

### Implementing tests using a web service

이전 장에서 `CLGeocoder`에 대한 stubs를 작성했다. 이제 geocoder가 내장된 `CoreLocation`이 기대한 대로 잘 작동하는지 검증하는 테스트를 작성할 것이다. geocoder에서 좌표를 가져오는 것은 비동기이다. 비동기 인터페이스를 다룰 수 있는 테스트를 작성해야 한다는 것을 의미한다.

`Controller`에 해당 하는 파일을 그루핑하자. 테스트 타겟에 대해서도 똑같이 하자.

이제 테스트를 시작하자. 다음의 테스트를 `InputViewControllerTests`에 추가하자.

```swift
func test_Geocoder_FetchesCoordinates() {
  CLGeocoder().geocodeAddressString("Infinite Loop 1, Cupertino") {
    (placemarks, error) in
    
    let coordinate = placemarks?.first?.location?.coordinate
    guard let latitude = coordinate?.latitude else {
      XCTFail(); return
    }
    
    guard let longitude = coordinate?.longitude else {
      XCTFail(); return
    }
    
    XCTAssertEqualWithAccuracy(latitude, 37.3316, accuracy: 0.0001)
    XCTAssertEqualWithAccuracy(longitude, -122.0300, accuracy: 0.0001)
  }
}
```

테스트를 돌리자. 모두 성공한다. geocoder가 우리 생각처럼 동작하는 듯이 보인다. 잠깐만 기다리자. 우리는 적색 상태를 넘겼다. TDD에서는 실패하는 테스트를 먼저 가져야 한다. 그렇지 않으면 테스트가 실제 동작하는지 확신할 수 없다.

우리는 `CLGeocoder`의 소스에 접근할 수 없고, 테스트 실패를 위해 구현을 변경할 수도 없다. assertion을 바꾸는 것만 할 수 있다. 클로저 내의 assertion을 다음 코드로 변경하자.

테스트를 수행하자. 테스트는 여전히 성공이다. 브레이크 포인트를 걸어 무슨 일이 벌어지고 있는지 확인하자.

테스트를 다시 수행하자. 테스트 수행 중에 디버거는 해당 라인에서 멈추고, 디버거 콘솔을 열어 무슨 일이 진행 중인지 알 수 있다.

디버거는 브레이크 포인트에 절대 닿지 않는다.

`geocodeAddressString(_:completionHandler:)`이 비동기이기 때문이다. 해당 클로저는 언젠가 미래에 다른 쓰레드에서 호출되고, 테스트 실행은 진행된다. 콜백 블럭이 실행되기도 전에 테스트는 끝나고, assertion은 끝내 호출되지 않는다. 테스트가 비동기로 동작하도록 바꿔야 한다.

다음 코드로 바꿔보자.

```swift
func test_Geocoder_FetchesCoordinates() {
  let geocoderAnswered = expectation(description: "Geocoder")
  
  CLGeocoder().geocodeAddressString("Infinite Loop 1, Cupertino") {
    (placemarks, error) in
    
    let coordinate = placemarks?.first?.location?.coordinate
    guard let latitude = coordinate?.latitude else {
      XCTFail(); return
    }
    
    guard let longitude = coordinate?.longitude else {
      XCTFail(); return
    }

    XCTAssertEqualWithAccuracy(latitude, 0.0, accuracy: 0.0001)
    XCTAssertEqualWithAccuracy(longitude, 0.0, accuracy: 0.0001)
    
    geocoderAnswered.fulfill()
  }
  waitForExpectations(timeout: 3, handler: nil)
}
```

`expectation(description:)`를 이용해 expectation을 만들었다. 테스트 마지막에 3초 타임아웃과 함께 `waitForExpectations(timeout:handler:)`를 호출한다. 테스트 러너가 이 지점에서 멈추고 expectation이 만족되거나 타임아웃이 끝날때까지 기다리는 것을 의미한다. 만약 모든 타임아웃이 지나도록 모든 expectation이 만족되지 않는다면 테스트를 실패한다. 콜백 클로저에서 assertion이 호출된 이후에 expectation을 만족한다.

이제 테스트를 다시 해보자. assertion에 맞지 않는 값을 넣었기 떄문에 마지막 테스트는 실패한다. 다음으로 바꾸자.

```swift
XCTAssertEqualWithAccuracy(latitude, 37.3316, accuracy: 0.0001)
XCTAssertEqualWithAccuracy(longitude, -122.0300, accuracy: 0.0001)
```

테스트를 다시 돌리자. 모든 테스트가 통과하고, `GLGeocoder`는 예상대로 동작한다.

우리는 방금 `XCTest`로 비동기 API를 테스트 하는 법을 봤다. 이는 다양한 측면의 iOS 개발에 사용될 수 있다(예를 들어 `NSNotification` 보내기, 웹서버에서 데이터 가져오기, 백그라운드에서 데이터베이스에 데이터 쓰기 등). 비동기 작업일 발생할 때마다, 우리는 expectation을 추가하고, 비동기 콜백이 실행되었을 때 이것이 만족되도록 만들 수 있다.

이는 매우 강력하다. 하지만 단위 테스트는 빠르고, 신뢰할 수 있어야 한다는 것을 잊지 말자. 웹서버를 테스트에 이용하는 것은 테스트를 약하고, 느리게 만든다. 만약 웹서버가 3초 이상을 필요로 한다면, 테스트를 실패한다. 그리고 테스트를 수행할 때 항상 인터넷이 연결되어 있어야 한다.

다음 섹션에서 우리는 stubs을 이용해 테스트를 강하고 빠르게 만들 것이다. 완성된 웹서버 없이도 앱의 네트워크 계층을 만들 수 있다는 것은 추가적이 이점이다. 완성된 API 문서만 있으면 된다.

### Implementing a login request

동료가 웹서비스를 만들고 있지만 아직 끝내지 않았다고 가정하자. 하지만 우리는 이미 API가 어떻게 생겼는지 알고 있다. 로그인을 위한 endpoint가 있을 것이다. `https://asesometodos.com/login` 일 것이다. 사용자이름과 비밀번호 두 개를 인자로 받고, 다음 API요청에 사용될 token을 반환한다.

우리는 로그인 요청에서 받은 토큰이 토큰 struct에 들어가는지 테스트를 통해 검증해야 한다.

`APIClientTests`를 만들자.

우리는 로그인 기능을 몇 개의 작은 기능으로 나눌 것이다. 이전에 언급했듯 로그인은 사용자 이름과 비밀번호를 쿼리 파라메터로 넘기면서, `https://asesometodos.com/login`에 대한 HTTPS 요청을 만들어야 한다.

다음 코드를 `APIClientTests`에 추가하자.

```swift
func test_Login_UsesExpectedURL() {
  let sut = APIClient()
}
```

정적 분석기가 `APIClient`가 필요하다 말할 것이다. `APIClient.swift`를 추가하자.

```swift
class APIClient {
  
}
```

이거면 정적분석기를 행복하게 만드는 데에 충분할 것이다.

서버 쪽이 아직 끝나지 않았기 때문에 네트워크 요청을 가장하는 가짜 URL session을 주입할 수 있어야 한다. 다음 코드를 추가하자.

```swift
let mockURLSession = MockURLSession()
```

클래스가 없기 때문에 컴파일은 불가능하다. 다음 코드를 `APIClientTests.swift`의 클래스 정의 밖에 추가하자.

```swift
extension APIClientTests {
  class MockURLSession {
    var url: URL?
    func dataTask(
      with url: URL,
      completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void)
      -> URLSessionTask {
        
        self.url = url
        return URLSession.shared.dataTask(with: url)
    }
  }
}
```

이 모의 클래스는 네트워크 요청 구현에 사용할 `dataTask(with:completionHandler:)` 메서드를 구현하고 있다. 이 모의 클래스는 URL을 캐치한다. 이를 통해 테스트에서 URL을 확인할 수 있다. 다음에는 모의 클래스를 실제 구현에 주입하고 싶을 것이다. 다음 코드를 `test_Login_UsesExpectedURL()`의 마지막에 추가하자.

```swift
sut.session = mockURLSession
```

`APIClient`를 열어서 `session` 프로퍼티를 추가해서 컴파일 되도록 만들자.

```swift
lazy var session: URLSession = URLSession.shared
```

다시 테스트를 수행하자. 여전히 컴파일이 안 된다. `APIClientTests.MockURLSession`을 `URLSession`에 할당할 수 없기 때문이다. `URLSession`나 모의 클래스의 인스턴스를 할당하려면 session 의 타입을 바꿔야 한다. 프로토콜을 이용하면 된다. 다음 코드를 `APIClient.swift`에 추가하자.

```swift 
protocol SessionProtocol {
  func dataTask(
    with url: URL,
    completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void)
    -> URLSessionTask
}
```

`URLSession`은 이미 이 프로토콜을 구현하고 있다. 다음 코드를 `APIClient.swift`에 추가해서 프로토콜을 준수하도록 만들자. 

```swift
extension URLSession: SessionProtocol {}
```

다음, 모의 클래스가 해당 프로토콜을 준수한다는 것을 컴파일러에게 알려야 한다. 다음처럼 바꾸자.

```swift
class MockURLSession: SessionProtocol {
  // ...
}
```

마지막으로, `session` 프로퍼티의 타입을 바꾸자. `APIClient`에서 `URLSession` 타입을 `SessionProtocol`으로 바꾸자.

```swift
lazy var session: SessionProtocol = URLSession.shared
```

테스트를 수행하자. 이제 테스트는 컴파일되고, 다음으로 가자. `APIClient`는 로그인 메서드가 필요하다. 다음을 `test_Login_UsesExpectedURL()`에 추가하자.

```swift
let completion = { (token: Token?, error: Error?) in }
    sut.loginUser(withName: "dasdom",
                  password: "1234",
                  completion: completion)
```

`loginUser(withName:password:completion:)`과 `Token`이 없기 때문에 컴파일은 불가능하다. `APIClient`를 열어서 다음을 추가하자.

```swift
func loginUser(withName username: String,
                 password: String,
                 completion: @escaping (Token?, Error?) -> Void) {   
}
```

`Token.swift` 파일을 만들고 다음을 추가하자.

```swift
struct Token { }
```

다시 컴파일하면 성공할 것이다.

로그인 메서드가 예상하는 host를 사용하는지 확인하는 테스트를 만들자. `test_Login_UsesExpectedURL()` 마지막에 다음을 추가하자.

