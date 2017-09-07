# networking with URLSession
> [networking with URLSession](https://videos.raywenderlich.com/courses/67-networking-with-urlsession/lessons/1) 번역 및 재가공

## url
- url = Uniform Resource Locator = 정보의 주소값

## http
- http = HyperText Trnsfer Protocol = 하이퍼텍스트 형태(json)의 정보를 주고받는 규약
- post = create
- get = read
- put = update
- delete = delete
- head = get headers only

- request = client 가 server에게 보내는 메시지 (header + body)
- response = server 가 client의 요청에 응답하는 메시지 (header + body) header에 status code가 있다
- content-type = header에 명시되는 데이터의 형태. text(json, web form, html), binary(pdf, image, multipart)

## URLSession
- URLSession API는 URLSession class 를 중심으로 많은 class를 갖는다
- session을 만들기 위해서는 URLSessionConfiguration 인스턴스가 필요하다 이 인스턴스는 network sevice type, timeout, caching, HTTP header를 통제한다.
- session을 만들었다면 데이터를 전송하기 위해 URLSessionTask 인스턴스 만들어라. 하나의 session에 복수의 task를 만드는 것이 효율적이다. 서버의 response를 처리하기 위한 completion handler를 task에 붙일 수 있다. 그렇지 않으면 Delegate를 적용해서 progress 모니터링, response data 처리, 승인 등을 다룰 수 있다.
- 기본적인 요청을 위해서는 싱글톤 session이면 충분하다. URLSession.shared 는 configuration 인스턴스도 만들 수 없고 Delegate도 적용할 수 없으므로 URLSessionTask의 completion handler를 사용해야한다.
- 다른 configuration 또는 다른 delegate를 적용하기 위해 복수의 session을 만들 수 있다. 예를 들어 당신의 앱에서 유저가 비디오를 다운로드하고 시청할 수 있게 한다면 너는 networkServieType = .video 로 지정해 운영체제에게 우선순위나, 배터리 수명과 관련된 것을 알릴 수 있다. 만약 유저가 특정 에피소드를 시청한다면 당신은 미리 다음 에피소드를 준비하기를 원할 것이다. 이러한 task의 경우에는 networkServieType - .background로 지정되어 사용자가 에피소드 다운로드를 background에서 할 수 있도록 해준다.

## URLSessionConfiguration
- URLSessionConfiguration class 는 여러종류가 있다. 
default값은 persistent disc-based cache를 사용한다. 그리고 유저의 키체인에 credential을 저장한다. 
ephemeral 값은 default랑 비슷하지만 디스크에 credential, 쿠키, cache data 등을 저장하지 않는다. 이것은 privacy 보호에 유용하다. 왜냐하면 데이터가 유지되지 않기 때문이다. 
background 값은 앱이 background에서 동작하는 동안 data를 전송한다. identifier를 지정해서 시스템이 끝나거나 재시작할 때 재실행되도록 알려야한다.
- configuration 객체 만들 때 프로퍼티를 커스터마이징 할 수 있다. 그리고 반드시 session 인스턴스를 생성하기 전에 변경해야 한다. 세션 인스턴스를 만든 후 configuration object의 프로퍼티를 변경하는 것은 기존 session에 효과가 없다. 

## URLSession task
- URLSessionDataTask = response in memory, not supported in background session
- URLSessionUploadTask = easier to prvide request body
- URLSessionDownloadTask = response written to file on disk

### URLSessionDataTask 생성하는 4가지 메소드
```swift
//단지 적은양의 데이터를 읽을 때 간단한 방법. default request 는 get, 승인 관련 다루는 delegate도 호출된다
func dataTask(with: URL, completionHandler: @escaping(Data?, URLResponse?, Error?) -> Void)
```

```swift
//적은 양의 데이터를 업로드할 때
func dataTask(with: URLRequest, completionHandler: @escaping(Data?, URLResponse?, Error?) -> Void)
```

```swift
//복잡한 데이터를 다루고 progress 모니터링 할 때, delegate 사용
func dataTask(with: URL)
```
```swift
//복잡한 데이터를 다루고 progress 모니터링 할 때, delegate 사용
func dataTask(with: URLRequest)
```

```swift
let urlString = "https://itunes.apple.com/search?media=music&entity=song&term=abba"
let url = URL(string: urlString)
// url?.baseURL 은 nil


//: `baseURL` is useful for building REST API urls.
let baseURL = URL(string: "https://itunes.apple.com")
let relativeURL = URL(string: "search", relativeTo: baseURL)

// relativeURL?.baseURL 은 "https://itundes.apple.com"



//: ### URLComponents & URL-encoding
//url 안전하게 인코딩 되었는지 확인하기
var urlComponents = URLComponents(string: "https://itunes.apple.com/search?media=music&entity=song")
var queryItem = URLQueryItem(name: "term", value: "crowded house")

//space 문자를 인코딩하기
urlComponents?.queryItems?.append(queryItem)
urlComponents?.url


//: URL-encode "smiling cat face with heart-shaped eyes"
//이모티콘을 인코딩하기
queryItem = URLQueryItem(name: "emoji", value: "😀")
urlComponents?.queryItems?.append(queryItem)
urlComponents?.url
```

## REST API
- REpresentational State Transfer Application Program Interface
- REST 는 cloud application 에 유용하다. 왜냐하면 모든 호출이 stateless 하기 때문이다. 어떠한 요청이라도 component의 인스턴스에 연결될 수 있다. 그래서 만약어떤 것이 실패한다면 component는 자유롭게 재배포될 수 있다. REST API는 원하는 데이터에 접근하기 위한 URL을 만드는데 가장 쉬운 방법이다. 이는 열거형 타입의 중요한 역할이다. 예를 들어 JSON placeholder database는 comment를 갖는 post 를 생성하는 user를 갖는다.
이것들은 userId, postId로 연결되어 있다. REST API의 baseURL을 알면 여기에다가 path를 덧붙여서 get allPosts, getPostWithId, getCommentsForPost 등을 할 수 있다. 만약 당신의 앱이 백엔드 서버에 접근한다면 효율적인 REST API를 디자인해야한다.
- 대부분의 REST API는 JSON(JavaScript Object Notation) 형태로 주고받는다. 사람이 읽을 수 있는 형태로 데이터를 전송한다. JSON은 몇개 안되는 타입을 갖는다. string, boolean, array, object/dict, null, number. apple은 JSONSerialization class를 제공한다.
```swift
let task = session.dataTask(with: url!) {
    data, respnse, error in

    if error != nil {
        //used for client-side errors
    }
    //used for server-side errors

    (response as? NSHTTPURLResponse)?.statusCode
}
```
- 요청이 완료 되면 sessio task의 completion handler에 response 가 전달된다. 요청이 http 요청이라면 http url response를 전달하고 error 도 전달한다. 언제 어떻게 error 파라미터가 사용되는지 이해하는 것이 중요하다. 클라이언트 쪽 에러(호스트에 연결이 안된다거나)가 있다면 error 파라미터가 사용될 것이다. 하지만 서버쪽 에러(404 not found)라면 서버로부터 특정 response가 반환될 것이고 error 파라미터는 사용되지 않을 것이다. 서버는 http url response의 statusCode를 사용해 error를 알린다. 이 statusCode는 요청이 성공하지 못했을지라도 유용한 정보를 담고 있다. 그리고 우리가 짠 코드가 성공과 실패 상황 모두 처리해야 한다. 
- 이 모든 것을 간단한 session task로 합칠 수 있다. shared session을 사용하는 것이다. datatask는 suspended 상태로 시작하므로 resume()을 호출해야 실행된다
```swift
let session = URLSession.shared
let url = URL(string: "https://jsonplaceholder.typicode.com/posts/1")
let dataTask = session.dataTask(with: url) {data, respnse, error in
    //client side error check

    //server side error check

    // if no error, process data

    DispatchQueue.main.async {
        // update UI
    }
}
dataTask?.resume()
```
