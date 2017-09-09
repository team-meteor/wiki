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
- 이제 파일 다운로드할 준비가 되었다. download task를 처리할 session 먼저 만들어보자. Controller/SearchViewController.swift 파일에서 viewDidLoad() 앞에 아래의 코드를 추가하자

```swift
lazy var downloadsSession: URLSession = {
  let configuration = URLSessionConfiguration.default
  return URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
}()
```
- default configuration을 사용해서 세션을 생성하였다. 그리고 이벤트를 처리할 viewcontroller에 대해서 delegate를 지정하였다. 이는 task의 진행상황을 모니터링하는 데에 유용하다.
- delegate queue를 nil로 지정한 것은 세션이 serial operation queue를 사용하도록 한다.
- lazy를 사용한 것은 view controller가 초기화된 이후에 세션이 생성되도록 하여 delegate를 지정한 self 즉 viewController를 인식할 수 있게 해준다
- 이제 viewDidLoad()의 끝에 다음을 추가하자
```swift
downloadService.downloadsSession = downloadsSession
```
- DownloadService의 downloadsSession 프로퍼티를 설정하였다
- 위에서 구성한 세션과 delegate를 통해 마침내 유저가 트랙 다운로드 요청시 download task를 생성할 준비를 마쳤다
- Networking/DownloadService.swift 파일에서 tartDownload(_:) 를 다음과 같이 수정하자
```swift
func startDownload(_ track: Track) {
  // 1
  let download = Download(track: track)
  // 2
  download.task = downloadsSession.downloadTask(with: track.previewURL)
  // 3
  download.task!.resume()
  // 4
  download.isDownloading = true
  // 5
  activeDownloads[download.track.previewURL] = download
}
```
- 유저가 테이블뷰 셀의 다운로드 버튼을 누르면 TrackCellDelage를 적용받는 SearchViewController는 그 셀에 대한 특정 트랙을 인식하고 startDownload(_:) 를 호출한다. 
- 1. 특정 트랙에 대한 Download를 생성
- 2. 새로운 session을 이용해 트랙의 preview url를 포함하는 download task를 생성한다. 그리고 이 task를 Download의 task 프로퍼티에 넣는다
- 3. resume() 호출하여 task 시작한다
- 4. 다운로드가 진행중이라고 설정
- 5. url 과 Donwload를 activeDownloads 딕셔너리에 맵핑한다

- 앱을 실행해서 다운로드 버튼을 눌러보자. 잠시 후 디버그 콘솔에 다운로드 완료 메시지를 볼 수 있을 것이다. 다운로드 버튼은 남아있으나 곧 고칠것이다. 이제 노래를 재생해보자

## Saving and playing the track
- download 완료시 delagate 메소드인 urlSession(_:downloadTask:didFinishDownloadingTo:) 메소드는 임시파일 위치 url을 전달된다. 출력메시지에서 이를 확인할 수 있다. 이제 이를 반환하기 전에 샌드박스 폴더의 영구적 위치에 옮겨야 한다. SearchVC+URLSessionDelegates 에서 urlSession(_:downloadTask:didFinishDownloadingTo:) 내의 프린트를 다음으로 수정하자
```swift
// 1
guard let sourceURL = downloadTask.originalRequest?.url else { return }
let download = downloadService.activeDownloads[sourceURL]
downloadService.activeDownloads[sourceURL] = nil
// 2
let destinationURL = localFilePath(for: sourceURL)
print(destinationURL)
// 3
let fileManager = FileManager.default
try? fileManager.removeItem(at: destinationURL)
do {
  try fileManager.copyItem(at: location, to: destinationURL)
  download?.track.downloaded = true
} catch let error {
  print("Could not copy file to disk: \(error.localizedDescription)")
}
// 4
if let index = download?.track.index {
  DispatchQueue.main.async {
    self.tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .none)
  }
}
```
- 1. 다운로드가 완료된 task로부터 요청 url을 추출하고 그에 상응하는 Download를 찾아서 딕셔너리에서 제거한다.
- 2. SearchViewController.swift 에 있는 헬퍼 메소드인 localFilePath(for:) 를 사용하여 영구 로컬 파일 url을 생성한다. 
- 3. FileManager를 사용해서 다운로드한 파일을 임시폴더에서 destinationURL로 이동시켜야한다. 우선 복사하기 전에 destinationURL에 혹시라도 있을 item을 지우고, 복사해서 이동시킨 후 다운로드 트랙의 downloaded 프로퍼티를 true로 변경한다
- 4. 마지막으로 다운로드 트랙의 index를 사용하여 테이블뷰의 해당 셀을 reload 한다.
- 앱을 실행하고 트랙을 다운로드해서 다운로드가 완료되었을 때 콘솔에 로컬파일 저장위치가 프린트되는 것을 확인할 수 있다. 다운로드 버튼은 사라진다. 왜냐하면 delegate 메소드에서 트랙의 downloaded 프로퍼티를 true로 했기 때문이다. 트랙을 클릭하면 AVPlayerViewController를 통해 재생되는 노래를 들을 수 있다.

## Pausing, Resuming, and Cancelling Downloads
- 만약 다운로드 하던것을 중지하고 싶다면 또는 취소하고 싶다면? 이번 섹션에서는 중지, 재시작, 취소 기능을 적용해서 유저에게 다운로드에 대한 완벽한 통제권을 제공할 것이다. 먼저 취소기능부터 시작하자. DownloadService.swift 에서 cancelDownload(_:) 메소드를 다음과 같이 수정하자
```swift
func cancelDownload(_ track: Track) {
  if let download = activeDownloads[track.previewURL] {
    download.task?.cancel()
    activeDownloads[track.previewURL] = nil
  }
}

```
- 다운로드를 취소하기 위해서 진행중인 다운도르가 담긴 딕셔너리에서 상응하는 Download를 찾아서 cancel() 호출한다. 그리고나서 딕셔너리에서 그 downlaod object를 제거한다
- 다운로드 중지는 취소 개념과 유사하다. 중지기능은 download task를 취소하는 것은 같지만, 호스트 서버가 지원한다면 이후에 재시작하기 위한 정보를 담는 resume data를 생성해야한다.
- Note : 특정 조건에서만 다운로드를 재시작할 수 있다. 예를 들어 처음에 요청한 이후로 정보가 변하면 안된다.
- 이제 pauseDownload(_:)를 다음과 같이 채워보자
```swift
func pauseDownload(_ track: Track) {
  guard let download = activeDownloads[track.previewURL] else { return }
  if download.isDownloading {
    download.task?.cancel(byProducingResumeData: { data in
      download.resumeData = data
    })
    download.isDownloading = false
  }
}
```
- 취소기능과의 가장 큰 차이점은 cancel() 호출 대신에 cancel(byProducingResumeData:) 를 호출한다는 점이다. 나중에 재시작하는데 필요한 resume data를 생성하기 위해 클로저를 포함한다. 또한 isDownloading 프로퍼티를 false 로 설정한다. 중지 기능이 완성되었으니 재시작 기능을 추가해보자
- resumeDownload(_:) 메소드를 다음과 같이 채우자
```swift
func resumeDownload(_ track: Track) {
  guard let download = activeDownloads[track.previewURL] else { return }
  if let resumeData = download.resumeData {
    download.task = downloadsSession.downloadTask(withResumeData: resumeData)
  } else {
    download.task = downloadsSession.downloadTask(with: download.track.previewURL)
  }
  download.task!.resume()
  download.isDownloading = true
}
```
- 유저가 다운로드를 재시작할 때, resume data를 체크해야한다. resume data가 발견되면 이를 가지고 downloadTask(withResumeData:) 메소드를 이용해 새로운 download task를 생성한다. 만약 resume data가 없으면, download URL를 이용해서 새로운 download task를 만든다.
- resume data를 이용하는 것과 donwload URL를 이용하는 두 경우 모두 resume() 호출을 통해 task 를 시작하고 isDownloading 을 true로 설정한다.
- 이제 한가지 할 일만 남았다. 중지버튼, 재시작버튼, 취소버튼을 적절하게 숨기거나 보여주어야 한다. 그러기 위해서 TrackCell의 configure(track:downloaded:) 메소드는 해당 트랙이 다운로드 진행중인지 알아야 한다.
- TrackCell.swift 에서 configure(track:downloaded:) 를 다음과 같이 수정하자
```swift
func configure(track: Track, downloaded: Bool, download: Download?) {
```
-  SearchViewController.swift 에서 tableView(_:cellForRowAt:) 안의 cell을 다음과 같이 수정하자
```swift
cell.configure(track: track, downloaded: track.downloaded, 
  download: downloadService.activeDownloads[track.previewURL])
```
- activeDownloads 딕셔너리에서 해당 track의 download object를 추출한다.
- TrackCell.swift 에서 configure(track:downloaded:download:) 메소드에 있는 TODO 두가지 중에 첫번째를 다음과 같이 추가하자
```swift
var showDownloadControls = false
```
- 두번째에는 다음과 같이 추가하자
``` swift
if let download = download {
  showDownloadControls = true
  let title = download.isDownloading ? "Pause" : "Resume"
  pauseButton.setTitle(title, for: .normal)
}
```
- download object가 nil 이 아니면 현재 다운로드 진행중이라는 의미이다. 따라서 cell은 중지/재시작, 취소 버튼을 보여주어야 한다. 중지와 재시작은 같은 버튼을 공유하기 때문에 토글로 구현하면 된다. if 구문 아래에 다음을 추가하자
```swift
pauseButton.isHidden = !showDownloadControls
cancelButton.isHidden = !showDownloadControls
```
- 다운로드가 진행중일 때에만 버튼을 보이게 만들었다 아래의 메소드를 그 다음과 같이 수정하자
```swift
downloadButton.isHidden = downloaded
```
```swift
downloadButton.isHidden = downloaded || showDownloadControls
```
- 만약 트랙이 다운로드 중이라면 다운로드 버튼을 숨기도록 하였다. 앱을 실행하고 다운로드를 해보면 중지, 재시작, 취소가 가능해졌다
- Note : 만약 다운로드를 재시작하고 중지하고 다시 재시작한 후에 멈춘다면 이상한 버그이다. 이는 download session configuration 을 URLSessionConfiguration.background(withIdentifier: "bgSessionConfiguration")으로 변경하면 버그가 사라질 것이다.

## Showing Download Progress
