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
---
## URLRequest
- 네트워킹 앱은 서버에 요청을 보낸다. 그러기 위해서 첫번째로 SessionConfiguration을 사용한다(shared session은 default configuration을 사용). configuratino을 커스터마이징 할 수 있고 그리고 나서 그 configuration을 가지고 session을 생성한다. session은 task를 생성한다. 각각의 task는 URL 또는 URL을 가지고 만들어진 URLRequest를 통해 만들어진다. task는 session configuration의 설정을 이용할 수 있으나 request는 몇몇 configuration 설정을 재정의 할 수 있다.
- URL을 가지고 URLRequest를 만들 수 있다. 또한 session configuration과는 다르게 cachepolicy, timeoutinterval 등을 지정하는 생성자를 사용할 수도 있다.
```swift
init(url: URL)
init(url: URL, cachePolicy: NSURLRequest.CachePolicy, timeoutInterval: TimeInterval)
```
- 요청을 생성하는 두가지 이유가 있다. 첫째로는 요청을 보내기 이전에 HTTP method, header, body를 변경하기 위해서다. HTTP method의 디폴트 값이 get이므로 다른 메소드를 요청하기 위해서는 변경해야 한다. post, put 메소드는 body를 필요로한다. 두번째 이유는 configuration settings를 재정의하기 위함이다. 예를 들어 request는 다른 network service type을 설정할 수 있다. 이 값이 시스템이 요청을 위해 사용할 값이다. 그러나 만약 configuratino의 값이 제한적이라면 문제가 발생한다. 예를 들어 configuration 의 allowsCellularAccess 의 프로퍼티의 bool 값은 true이며 read only한 값이므로, request의 프로퍼티 값을 true로 하면 에러발생한다.

## HTTPHeaders
- HTTPHeader는 요청, 응답에 관한 부가적인 정보를 전달한다. 
- General header = 요청과 응답 둘 다에 적용된다. Cache-Control은 얼마동안 이 정보가 유효한지를 알려주고 Connection keep alive 는 하위 요청에 대해 연결을 유지시켜준다
- Request header = http requests에 사용된다. Accep:application/json 은 서버에게 클라이언트가 JSON을 읽을 수 있다는 것을 알려준다. X-stormpat-agent는 요청 소프트웨어의 버젼 정보를 알려준다.
- Response header = http response에 사용된다. Age는 object가 프록시 캐시에 담겨있는 시간을 알려준다. Server는 요청을 처리하는 소프트웨어를 알려준다.
- Entity header = body의 내용을 알려준다. Content-Language 는 청중을 가리킨다. Content-Encoding은 내용이 압축되는 방식을 나타낸다.

---

## URLSession data task
- 사용자 승인, 토큰 매칭과 같은 짧은 작업을 의미
- 메모리에 response를 저장

### URLSession download task
- 결과물을 메모리가 아닌, 파일에 저장
- 호출결과로 data object 대신에 임시파일 위치의 url 을 받는다
- 다운로드 작업 완료 전에 실패하거나 취소하면, resume data를 저장할 수 있고 다운로드를 재시작할 수 있다.
- data task와는 다르게, 서버쪽 에러를 NSError object로 변환하여 error 파라미터를 통해 전달한다.

```swift
func downloadTask(with: URL, completionHandler: @escaping(URL?, URLResponse?, Error?) -> Void)

func downloadTask(with: URLRequest, completionHandler: @escaping(URL?, URLResponse?, Error?) -> Void)


//delegate 버전은 프로그레스 모니터링 또는 복잡한 response data처리시 사용
func downloadTask(with: URL)
func downloadTask(with: URLRequest)

func cancel(byProducingResumeData: @escaping (Data?) -> Void)
func downloadTask(withResumeData: Data, completionHandler: @escaping(URL?, URLResponse?, Error?) -> Void)
func downloadTask(withResumeData: Data)
```

### URLSession upload task
- 파일을 업로드
- download task와 마찬가지로 completion handler가 있으면 response, data 처리를 위해 delegate 를 사용하지 않는다. 그러나 승인 관련해서는 delegate가 여전히 호출된다.
- download task와 큰 차이점은 URL을 가지고 upload task를 만들 수 없다는 점이다. 왜냐하면 post, put 메소드만 가능하므로 URLRequest를 만들어야한다.
- 업로드될 데이터를 구체화하는 데 필요한 부가적인 파라미터를 갖는다
- 데이터를 http body에 넣는다
- 데이터 말고 파일을 업로드 할 수도 있다.

```swift
//data
func uploadTask(with: URLRequest, from: Data?, completionHandler: @escaping(Data?, URLResponse?, Error?) -> Void)
func uploadTask(with: URLRequest, from: Data)

//file
func uploadTask(with: URLRequest, fromFile: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void)
func uploadTask(with: URLRequest, fromFile: URL)

//streamed request option
func uploadTask(withStreamedRequest: URLRequest)
```

## more complex task 일 때 priority 세팅 필요
- URLSessionConfiguration은 특정 데이터 타입을 전송한다고 운영체제에게 알린다. 그리고 운영체제는 이 정보를 이용해 우선순위를 설정한다.
- URLSessionTask는 서버에게 우선순위 레벨을 요청할 수 있다. (0.0 < priority < 1.0, default = 0.5)
- URLRequest 는 session configuration을 재정의할 수 있다.
- URLSession의 delegateQueue 는 operation queue이다. 중요도에 따라 qos 값을 설정할 수 있다. 

## NSURLRequest.useProtocolCachePolicy
- 용량이 큰 다운로드는 network traffic을 줄이기 위해 cache를 잘 사용해야 한다. 
- default configuration object는 영구 disk 기반의 cache를 사용한다. cache는 네트워크 연결에 대한 앱의 의존성을 감소시키고 performance를 증가시킨다. default cache policy는 http 프로토콜의 cache policy를 사용하는 것이다. 만약 요청에 대한 캐시응답이 없으면 URL loading system은 오리지널 소스로부터 데이터를 가지고 온다. 그렇지 않고 만약 캐시응답이 오래되지 않았다면 URL loading system은 캐시응답을 반환한다. 만약 캐시응답이 오래된 것이라면 URL loading system은 오리지널 소스에게 소스가 변경사항이 있는지를 head 요청을 한다. 그러면 URL loading system은 데이터를 가져오고 그렇지 않으면 캐시응답을 반환한다. 이외의 cache policy value 는 캐시 데이터를 무시하거나 default 워크플로우를 따른다.
---

