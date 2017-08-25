# Grand Central Dispatch Tutorial for Swift 3: Part 1/2
> [Grand Central Dispatch Tutorial for Swift 3: Part 1/2](https://www.raywenderlich.com/148513/grand-central-dispatch-tutorial-swift-3-part-1) 를 번역하였습니다.

## update note
- GCD는 동시에 여러 task를 수행할 때 필요한 low level api 이다. GCD는 cpu 고비용 작업을 background에 분담하여 앱의 반응성을 향상시킬 수 있다. lock, thread 작업에 비해 더 쉬운 멀티태스킹 모델이다.
swift3에서 GCD는 새로운 class, data structure 를 포함하여 C 기반 api에서 Swift기반 api로 진화했다
이번 튜토리얼에서 GCD를 샅샅이 배울 것이다. chapter1 에서는 GCD가 무엇인지, 기본 GCD function에 대해 다루고, chapter2 에서는 좀 더 난이도 있는 GCD function을 다룬다.
여기서는 GooglyPuff라는 앱을 다룰 것이다. 이 앱은 thread가 안전하지 않은 상태의 앱으로서 core image api를 사용해서 얼굴이미지를 인식하고 이미지 위에 돌아가는 눈을 오버레이한다. 사진앱에 있는 사진에 위 효과를 적용시킬 수도 있고 인터넷에서 다운로드한 이미지에 적용할 수도 있다. 이제 GCD를 사용하여 다른 thread에서 안전하게 코드를 호출하도록 앱을 개선해야 한다.

## getting started
- 프로젝트 파일을 실행하자. 홈 화면은 비어있는 화면 상태이다. + 버튼을 클릭하여 Le Internet을 선택하면 인터넷에서 이미지를 다운로드한다. 이미지를 클릭하면 디테일뷰에서 이미지 위에 눈 이미지가 올라간다.

### 이 튜토리얼에서 주로 사용할 class
- PhotoCollectionViewController: initial viewcontroller 로서 사진들의 썸네일 제공
- PhotoDetailViewController: PhotoCollectionViewController에서 선택한 이미지 제공 및 이미지 위에 눈 이미지를 붙이는 효과
- Photo: 사진의 프로퍼티 관련 프로토콜. 이미지, 썸네일, 상태 제공. Photo 프로토콜을 적용하는 두 클래스 DownloadPhoto(URL로부터 photo 인스턴스 생성), AssetPhoto(PHAsset을 이용한 photo 인스턴스 생성)
- PhotoManager: 모든 Photo 객체를 통제

- 이 앱에는 몇가지 문제점이 있다. 앱 실행시 다운로드 완료 알림 기능이 미완료된 상태이므로 chapter2 에서 개선할 것이다.
- chapter1 에서는 돌아가는 눈을 이미지 위에 올리는 작업을 최적화하는 것과 PhotoManager class를 thread safe 하게 개선할 것이다.

## GCD 개념
- 가상의 dispatch queue를 이용하여 task 처리 방식을 지정함으로써 간접적으로 thread를 관리하는 api
- GCD를 이해하기 위해서는 concurrency 와 threading에 연관된 개념에 익숙해질 필요가 있다

### Concurrency(동시 구조), parallelism(동시 처리)
- iOS 운영체제에서는 process 또는 application이 하나 이상의 thread로 구성된다. 각각의 thread는 운영체제 스케줄러가 독립적으로 운영한다. 각 thread는 동시에 실행할 수 있지만 운영체제가 이를 결정한다.
- cpu가 1개인 single core device라면 time-slicing(동시에 하나의 thread만 실행가능하므로 각각의 thread를 왔다갔다하면서 task를 처리하는 방식)을 통해 멀티태스킹?을 구현한다. 동시에 1개의 thread만 동작하고 context switch를 통해 다른 thread를 실행한다
- cpu가 2개 이상인 multicore device라면 동시에 복수의 thread를 실행한다.
- GCD api는 shared thread pool을 간접적으로 관리한다. task를 dispatch queue에 분담하고 어느 thread 상에서 처리할 것인지를 결정한다.
- 코드 짤 때 동시에 처리해야하는 부분이 있고 그렇지 않은 부분이 있다. 이럴 때 GCD를 사용해서 멀티태스킹을 잘 배분해야한다.
- GCD는 얼마나 많은 동시처리가 필요한지 결정한다. 이 때 주의할 점은 concurrency 구조를 만족한다고 해서 반드시 동시처리를 실행하는 것은 아니라는 점이다. 하지만 동시처리를 하면 concurrency를 만족한다. concurrency는 구조적인 것이고 parallelism은 수행관련이다.

## Queue
- task를 동기적 또는 비동기적으로 처리할 수 있다
- First in, first out 을 보장하는 가상의 큐로서 thread 상에서 동작한다.
- queue에 들어가는 순으로 task가 시작하는 순서를 보장한다
- DispatchQueue는 thread safe 하다. 즉 동시에 여러 thread 에 접근이 가능하다. 이것이 바로 GCD의 장점이다. 이를 위해서는 tasks 를 의도에 알맞은 queue에 분배해야 한다
- serial queue(private): 각각의 큐에서는 동시에 하나의 task만 실행. 여러개의 serial queue를 만들면 각 큐에서는 동시에 각각 1개의 task만 실행하지만 전체적으로는 동시에 여러 task를 실행한다.
- concurrent: 각 큐에서 동시에 여러 task 실행 가능하므로 global concurrent queue의 우선순위가 4가지 있다(high, default, low, background)
- task 시작시점은 GCD가 결정한다. serial이면 앞의 task가 끝날때까지 기다려야하고 concurrent라면 앞의 task가 끝나기 전에 시작할 수 있다.

### queue 종류 3가지
- Main queue: main thread 상에서 동작하는 것을 보장한다, serial queue로서 UI task 를 담당
- global queue: concurrent, QoS(quality of service)를 지정해서 간접적으로 task의 우선순위(high, default, low, background)를 부여. shared resource
- custom queue: serial or concurrent. unshared resource

#### QoS(quality of service)의 4가지 class
- user-interactive: 가장 높은 우선순위의 task에 지정한다. 예를 들어 UI 업데이트, 이벤트 처리, 빠른 처리를 요구하는 task에 주로 사용. 업무의 양이 적어야 하며 main thread에서 동작하는 것을 보장.
- user-initiated: UI 관련 비동기 업무에 사용. task의 우선순위가 high로 결정되며 global queue에서 동작하는 것을 보장
- utility: UI 관련이지만 오래걸리는 업무에 사용. task의 우선순위가 low로 결정되며 global queue에서 동작하는 것을 보장
- background: non-UI 업무에 사용. task 우선순위가 제일 낮은 단계인 background로 결정되며 global queue에서 동작하는 것을 보장.

## queue에 task를 추가하는 방식 2가지
- 동기 = 큐에 task를 추가하기 위해 기다린다
- 비동기 = 큐에 task를 추가하기 위해 예약해놓고 다른 일하러 간다

## task 관리
- dispatch queue에 넣어진 task는 DispatchWorkItem으로 캡슐화되어 qos class 또는 새로운 thread에 넣을지 등을 관리할 수 있다

## background task 처리
- 앱을 실행해서 photo detail view가 나타날때까지 얼마나 걸리는지 보자. viewDidLoad 작업이 오래걸리는 상황이다. 이 때 사진이 로드 되는 것은 빨리 처리하고, 눈 이미지를 생성하여 사진 위에 눈 이미지를 올리는 작업은 global queue를 사용하여 qos를 user-initiated 로 처리하는 것이 좋겠다. 이때 눈 이미지를 사진 위에 올리는 UI작업은 main thread에서 동작해야 함

PhotoDetailViewController.swift 파일을 열고 viewDidLoad()에서 다음 두 줄을 수정하자
```swift
let overlayImage = faceOverlayImageFromImage(image)
fadeInNewImage(overlayImage)
```
```swift
DispatchQueue.global(qos: .userInitiated).async { // 1
  let overlayImage = self.faceOverlayImageFromImage(self.image)

  DispatchQueue.main.async { // 2
    self.fadeInNewImage(overlayImage) // 3
  }
}
```
- 위에서 task를 background global queue로 옮겨서 비동기로 실행하도록 변경하였다. 이는 viewDidLoad() 메소드가 main thread에서 더 빨리 완료되도록 하고 화면에 로딩이 빠르게 한다. 한편 얼굴인식은 좀 더 늦게 완료될 것이다.
- 얼굴인식이 완료되어 overlayImage를 만들면 UIImageView에 업데이트 해야하기 때문에 main queue에 새로운 클로저를 더한다. 항상 main thread 에서 UIKit 에 접근해야 한다
- 마침내 눈을 이미지 위에 넣는 것을 업데이트한다
- 이전보다 PhotoDetailView가 더 빠르게 로드되는 것을 확인할 수 있을 것이다. 엄청 큰 이미지를 로드할지라도 이미지를 로드하는 것은 그리 오래걸리지 않을 것이다.
- 일반적으로 네트워크 기반 또는 cpu 집중 업무를 수행할 때에는 오래 걸리므로 background 에서 처리하도록 해서 current thread를 막지 않도록 하는 것이 좋다.

## queue + async
- main queue: UI task
- global queue: non-UI task
- custom serial queue: task 완료 순서를 보장받고 싶을 때

## task 실행 지연시키기
- DispatchQueue는 task 실행 지연이 가능하다. 특정 시점에 task가 실행하도록 할 때 사용해라. 
이 앱 사용자들이 처음에 뭘 해야할 지 혼란스러워 할 가능성이 있다. 사진이 한장도 없을 때 사용자에게 알림을 주는 것이 좋다. 사용자의 시점이 어디로 향할지 고려해야 한다. 너무 빨리 알림을 주면 사용자가 이를 인지하지 못할 수 있다. 알림 전에 1초 정도 간격을 두는 것이 좋다.
PhotoCollectionViewController.swift를 열고 showOrHideNavPrompt()를 다음과 같이 채워라
```swift
let delayInSeconds = 1.0 // 1
DispatchQueue.main.asyncAfter(deadline: .now() + delayInSeconds) { // 2
  let count = PhotoManager.sharedManager.photos.count
  if count > 0 {
    self.navigationItem.prompt = nil
  } else {
    self.navigationItem.prompt = "Add photos with faces to Googlyify them!"
  }
}
```
- delayInSeconds 지연시간 지정하기
- 사진 갯수 세어서 알림하는 작업은 1초 지연 후 하도록 asyncAfter를 사용
- showOrHideNavPrompt() 메소드는 뷰가 로드될때마다 실행하도록 viewDidAppear에 넣는다
- 어떻게 asyncAfter 사용해야할지 궁금하니? 일반적으로 main queue에서 사용하는 것이 좋다. Timer는 왜 안쓰는지 궁금하니? Timer는 주로 반복적인 task일 때 사용한다. timer 보다 asyncAfter를 사용하는 것이 코드가 더욱 심플하다.

## singleton 생성할 때 thread safe 보장하는 방법
- singleton은 thread safe 하지 않다. 왜냐하면 복수의 controller에서 동시에 singleton에 접근하기 때문이다. 앱에서 PhotoManager class는 싱글톤이기 때문에 위 문제를 고려해야 한다.
- thread safe 라면 복수의 thread에서 호출되더라도 충돌이 일어나지 않는 반면, thread unsafe 라면 동시에 하나의 접근만 허용해야 한다.
- swift는 전역변수 생성할 때에 생성이 완료될 때 까지 다른 thread의 접근을 차단하여 thread safe를 보장한다. 따라서 singleton 인스턴스 생성시 이를 이용하여 thread safe를 보장받을 수 있다
```swift
private let _sharedManager = PhotoManager()

class PhotoManager {
  class var sharedManager: PhotoManager {
    return _sharedManager
  }
}
```
- sharedManager 는 처음에 한번만 인스턴스를 생성한다. public sharedManager 변수는 private _sharedManager 변수를 리턴한다. swift 는 이 작업의 thread safe를 보장한다. 싱글톤 내부 데이터를 잘 다루기 위해서 여전히 thread safe 문제를 고려해야 한다. 데이터 접근을 동기화하는 등의 방법을 사용해 싱글톤 내부에 접근해야 한다.

## 싱글톤 내부 데이터를 읽고 쓸 때 thread safe 보장하는 방법
- 스위프트에서 let 은 상수이며 읽기전용으로 thread safe 하다. 반면에 var 는 변할 수 있고 데이터타입이 정해지지 않으면 thread safe하지 않다. array나 dictionary 처럼 컬렉션 타입은 변수일 때 thread unsafe 하다
- 복수의 thread가 array 변수를 동시에 읽을 수 있을지라도 하나의 thread가 그것을 읽는 동안 다른 thread가 쓸 때는 안전하지 못하다. 싱글톤은 이를 방지할 수 없다.

- PhotoManager.swift파일에서 addPhoto(_:)를 살펴보자. photos array를 변화시키는 쓰기 메소드이다
```swift
func addPhoto(_ photo: Photo) {
  _photos.append(photo)
  DispatchQueue.main.async {
    self.postContentAddedNotification()
  }
}
```
- 아래는 photos getter 이다.
```swift
//array는 구조체이므로 call by value이다. 즉 복사본을 리턴한다. 스위프트는 필요시에만 복사본을 만드므로 메모리 이슈는 걱정하지 않아도 된다
fileprivate var _photos: [Photo] = []
var photos: [Photo] {
  return _photos
}
```
- 위에서는 읽기와 쓰기가 동시에 진행될 때 thread safe 하지 못하다. GCD는 dispatch barriers 를 사용하여 read/write lock을 생성하여 위의 이슈를 해결할 수 있다. Dispatch barrier 는 concurrent queue에서 작업할 때 병목현상을 유발하여 마치 serial하게 동작하도록 하는 func group이다. DispatchWorkItem을 queue에 넣을 때 barrier task로 지정할 수 있다. barrier task가 시작하기 전에 이전의 task가 모두 완료되어야하고 barrier task가 완료된 후에는 다시 병목현상이 해결된다.
- global concurrent queue는 공공의 큐이기 때문에 barrier를 사용할 때 주의해야하며 custom concurrent queue 에서 특정 시점에 serial 하게 하고 싶을 때 dispatch barrier를 사용하는 것이 바람직하다.
- PhotoManager.swift 파일을 열고 _photos 위에 다음과 같이 custom concurrent queue를 만들자
```swift
fileprivate let concurrentPhotoQueue =
  DispatchQueue(
    label: "com.raywenderlich.GooglyPuff.photoQueue", // 1
    attributes: .concurrent) // 2
```
- 디버깅시 편하도록 label을 붙이는데 보통 DNS 주소를 거꾸로 하는 방식을 사용한다
- addPhoto(_:) 를 다음의 코드로 대체하자(쓰기 부분을 thread safe 하게)
```swift
func addPhoto(_ photo: Photo) {
  concurrentPhotoQueue.async(flags: .barrier) { // 1
    self._photos.append(photo) // 2
    DispatchQueue.main.async { // 3
      self.postContentAddedNotification()
    }
  }
}
```
- 위에서처럼 custom concurrent queue를 만들어서 그 안에서 serial하게 동작하도록 barrier flag를 표시하면 동시에 읽고 쓰더라도 thread safe 하다.
- noti를 날리는 메소드는 UI 관련 일이므로 main thread에서 동작해야 한다.
- getter(읽기) 역시 concurrentPhotoQueue에서 동작해야만 thread safe를 보장한다. 이 때 읽기와 쓰기가 서로를 동시에 기다리는 deadlock 현상이 발생하지 않도록 주의해야한다.

### queue + sync
- main queue: deadlock 위험
- global queue: 바람직
- custom serial queue: deadlock 위험

- PhotoManager.swift 파일 열고 photos getter 수정해라
```swift
var photos: [Photo] {
  var photosCopy: [Photo]!
  concurrentPhotoQueue.sync { // 1
    photosCopy = self._photos // 2
  }
  return photosCopy
}
```
- 위에서 만들었던 concurrentQueue에서 sync로 수행
- photosCopy를 만들어서 이것을 리턴