# URLSession Tutorial: Getting Started
> [URLSession Tutorial: Getting Started](https://www.raywenderlich.com/158106/urlsession-tutorial-getting-started) 번역 및 재가공

- http data 요청하는 방법을 배우고 URLSession을 이용해 파일을 다운로드하는 것을 실습해보자
- 앱이 서버로부터 데이터를 다루는지, 소셜미디어 상태를 업데이트 하는지, 디스크에 파일을 다운로드 하는 작업 등은 모바일 앱의 HTTP 네트워크 요청이 행하는 마법이다. 네트워크가 요청하는 거대한 작업을 수행하기 위해서 애플은 URLSession이라는 것을 제공한다. 이것은 HTTP를 충족하는 컨텐츠의 업로드 다운로드에 대한 완벽한 네트워크 API이다.
- 이번 튜토리얼에서는 Half Tunes app을 만들 것이다. 현재 상태의 이 앱은 iTunes Search API를 다루고 노래의 앞부분 30초를 다운로드할 수 있다. 이후 완성된 앱은 background transfer를 지원할 것이며 사용자가 다운로드를 중지하거나 재시작, 취소할 수 있을 것이다.

## Getting started
- 프로젝트를 다운로드 받아라. 이미 노래를 검색하고 검색결과를 보여주고, 네트워크 서비스, 트랙 저장 및 재생하는 UI를 포함한다. 따라서 앱의 네트워크 부분에만 집중할 수 있을 것이다.
앱을 실행해보자. 빈 테이블뷰 위에 서치바가 보일 것이다.
서치바에 쿼리를 입력하고 서치 버튼을 누르자. 뷰는 여전히 비어있는 상태이지만 걱정하지마라. 이제 URLSession 을 사용해서 바꾸면 되니까.

## Overview of URLSession
- 시작하기 전에 URLSession과 구성 클래스에 대해 살펴보는 것이 중요하다. 아래의 도표를 살펴보자. URLSession은 기술적으로 http와 https 기반의 요청을 처리하는 클래스이다. URLSession은 http 요청을 주고받는 임무를 수행하는 중요한 오브젝트이다. URLSessionConfiguration을 이용해서 생성할 수 있고 3가지 종류가 있다.
- .default : disk-persisted global cache, credential, cookie storage object를 사용한다.
- .ephemeral : default 와 비슷하지만 모든 세션관련 데이터를 메모리에 저장한다. private session으로 불린다
- .background : background 에서 업로드와 다운로드 작업을 수행한다. 심지어 앱이 서스펜드 또는 종료된 상태에서도 전송작업이 유지된다

- URLSessionConfiguration은 timeout value, caching policy, http header와 같은 세션 프로퍼티의 값을 설정할 수 있게 해준다.
- URLSessionTask는 추상클래스이다. 세션은 데이터 가져오기 파일 업로드 다운로드 등의 작업을 수행하기 위해 하나 또는 여러개의 task를 생성할 수 있다. session task의 3가지 타입이 존재한다
- DataTask : 서버에서 메모리로 데이터를 요청하는 get 
- UploadTask : 디스크에서 웹으로 파일 업로드하는 post, put
- DownloadTask : 원격에서 임시url로 파일을 다운로드

- task를 suspend하거나 재시작하거나 취소할 수 있다. downloadtask는 나중에 재시작하기 위해 중지하는 부가적인 능력도 있다
- 일반적으로 URLSession은 두가지 방식으로 데이터를 반환하는데 task가 완료되는 시점에 completion handler를 통해 반환하거나, 세션 생성시 설정해놓은 delegate 메소드 호출을 통해 반환할 수 있다.
- 이제 URLSession에 대해 훑어보았으니 실습할 준비가 되었다

## Data Task
- 사용자가 검색창에 입력한 쿼리에 대한 data task를 생성하자. SearchVC+SearchBarDelegate.swift 에서 searchBarSearchButtonClicked(_:) 메소드는 먼저 status bar에서 사용자에게 진행상황을 보여주는 네트워크 인디케이터를 활성화한다. 그리고나서 QueryService.swift에 있는 비어있는 메소드 getSearchResults(searchTerm:completion:)를 호출한다.
Networking/QueryService.swift 파일에서 다음과 같이 수정하자
```swift
// 1
let defaultSession = URLSession(configuration: .default)
// 2
var dataTask: URLSessionDataTask?
```
- 1. default configuratoni을 사용하여 URLSession을 생성했다
- 2. datatask 변수를 선언했다. 우리는 iTunes 웹서비스에게 get 요청을 하기 위해 사용할 것이다. data task는 사용자가 새로운 검색어를 입력할 때마다 재생성될 것이다.

- 다음으로 getSearchResults(searchTerm:completion:) 의 빈 메소드를 다음과 같이 수정해보자
```swift
func getSearchResults(searchTerm: String, completion: @escaping QueryResult) {
  // 1
  dataTask?.cancel()
  // 2
  if var urlComponents = URLComponents(string: "https://itunes.apple.com/search") {
    urlComponents.query = "media=music&entity=song&term=\(searchTerm)"
    // 3
    guard let url = urlComponents.url else { return }
    // 4
    dataTask = defaultSession.dataTask(with: url) { data, response, error in
      defer { self.dataTask = nil }
      // 5
      if let error = error {
        self.errorMessage += "DataTask error: " + error.localizedDescription + "\n"
      } else if let data = data,
        let response = response as? HTTPURLResponse,
        response.statusCode == 200 {
        self.updateSearchResults(data)
        // 6
        DispatchQueue.main.async {
          completion(self.tracks, self.errorMessage)
        }
      }
    }
    // 7
    dataTask?.resume()
  }
}

```
- 1. 사용자의 새로운 검색어를 위해 이미 존재하는 data task를 취소한다. 왜냐하면 재사용해야하니까
- 2. 쿼리 URL에 사용자의 검색어를 포함시키기 위해서 URLComponents를 생성한다. baseURL과 query를 지정한다
- 3. urlComponents의 url 속성이 nil일 수 있으므로 옵셔널바인딩 한다
- 4. 위에서 만든 urlSession으로부터 datatask를 생성하고 이를 위해 위에서 만든 쿼리 url을 사용하고 데이터 반환시 어떤 처리를 할지 completion handler를 넣는다
- 5. 에러가 발생한다면 에러처리를 하고, 성공한다면 updateSearchResults(_:)를 호출한다. 이 메소드는 반환된 데이터를 tracks 배열 형태로 파싱한다.
- 6. 파싱한 track을 completion handler에 전달하는 작업을 메인큐에서 수행한다
- 7. 모든 task는 suspended상태이므로 resume()을 호출해야 업무를 시작한다

- SearchVC+SearchBarDelegate.swift 파일에 있는 getSearchResults(searchTerm:completion:)를 살펴보자. 인디케이터를 숨긴 후에 결과값을 searchResults에 저장한다. 그리고 나서 테이블뷰를 업데이트한다.

- Note : 요청메소드의 디폹트값은 get이다. 만약 post, put, delete를 하고 싶다면 url을 포함하는 URLRequest를 생성하고 그것의 http method를 맘대로 설정해주면 된다. 그리고나서 url로 data task를 생성하는 대신에  URLRequeset를 포함하는 data task를 만들면 된다.

- 앱을 실행해보자. 아무 노래나 검색해보자. 테이블뷰에 결과가 나타날 것이다.
- URLSession을 사용해서 앱에 작은 기능이 생겼다.

## Download Task
- 노래검색결과를 볼수 있게 되어 좋다. 그러나 다운로드를 할 수 있다면 더 좋지 않을까. 이것은 우리의 다음 과제이다. download task를 사용해서 로컬파일에 노래를 저장하기 쉬울 것이다.

### download class
- 복수의 다운로드 작업을 쉽게 다루려면 다운로드 상태를 통제하는 커스텀 모델을 만들어야한다.
- Download.swift파일을 모델 그룹에 만들고 다음과 같이 수정하자

```swift
class Download {

  var track: Track
  init(track: Track) {
    self.track = track
  }

  // Download service sets these values:
  var task: URLSessionDownloadTask?
  var isDownloading = false
  var resumeData: Data?

  // Download delegate sets this value:
  var progress: Float = 0

}
```
- Download 모델의 프로퍼티를 살펴보자
- track : 다운로드할 트랙. 트랙의 url은 Download의 unique identifire로서 역할 (딕셔너리의 키값)
- task : 트랙을 다운로드하는 download task
- isDownloading : 다운로드 작업이 진행상태인지 중지상태인지
- resumeData : 사용자가 다운로드 중지시 데이터를 저장한다. 만약 호스트서버가 지원하면 앱은 중지한 다운로드를 나중에 재시작할 수 있다
- progress : 다운로드 진행률

- Networking/DownloadService.swift 파일에서 다음 프로퍼티를 클래스 상단에 추가하자
```swift
var activeDownloads: [URL: Download] = [:]
```
- 이 딕셔너리는 url과 Download를 맵핑한 형태이다

### URLSessionDownloadDelegate
- 위에서처럼 completion handler를 사용해서 download task를 만들 수 있다. 그러나 이번에는 다운로드 진행상황을 모니터링 하고 싶을 때 custom delegate를 사용해야 가능하다
- 일반적으로 delegate는 ViewController에 적용한다
- 여러 delegate protocol 종류가 있다. URLSessionDownloadDelegate는 download task에 한정하여 이벤트를 처리한다.
- 이제 SearchViewController 에 session delegate를 적용할 것이다. controller그룹에 SearchVC+URLSessionDelegates.swift 파일을 만들고 extension을 만들자
```swift
extension SearchViewController: URLSessionDownloadDelegate {

  func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, 
    didFinishDownloadingTo location: URL) { 
    print("Finished downloading to \(location).")
  }

}
```
- urlSession(_:downloadTask:didFinishDownloadingTo:) 은 URLSessionDownloadDelegate 메소드 중 유일하게 옵셔널이 아니다. 다운로드가 끝날 때 호출된다. 이제 다운로드가끝나면 메시지를 프린트할 것이다.

### Creating a Download Task
- 