# Grand Central Dispatch Tutorial for Swift 3: Part 2/2
> [Grand Central Dispatch Tutorial for Swift 3: Part 2/2](https://www.raywenderlich.com/148515/grand-central-dispatch-tutorial-swift-3-part-2) 를 번역하였습니다.

## updated note
- chapter1에서는 concurrency, threading, GCD 동작방식에 대해 살펴보았습니다. 또한 dispatch barrier와 sync 를 사용하여 싱글톤 객체를 읽고 쓸 때 thread safe를 보장하도록 수정하였습니다. 또한 dispatch queue를 사용하여 알림을 지연시켜 사용자가 알림을 보다 잘 인지할 수 있게 개선하고 viewDidLoad()에서 cpu 고비용 task 를 async로 처리하여 보다 빠르게 로드될 수 있도록 하였습니다.
- chapter2에서는 이전 앱을 계속 사용할 것입니다. 앞으로 dispatch group, canceling dispath block, asynchronous testing techniques, dispatch source에 대해 다룰 것입니다.

## getting started
- 앱을 실행시켜보자. + 버튼을 눌러 Le internet 을 클릭하면 이미지들이 미처 다운로드가 완료되기 전에 다운로드 완료 알림이 먼저 뜰 것이다. 이것부터 수정해보자.

## Dispatch Groups
- PhotoManger.swift 파일을 열어 downloadPhotosWithCompletion(_:)을 살펴보자
```swift
func downloadPhotosWithCompletion(
  _ completion: BatchPhotoDownloadingCompletionClosure?) {
  var storedError: NSError?
  for address in [overlyAttachedGirlfriendURLString,
                  successKidURLString,
                  lotsOfFacesURLString] {
                    let url = URL(string: address)
                    let photo = DownloadPhoto(url: url!) {
                      _, error in
                      if error != nil {
                        storedError = error
                      }
                    }
                    PhotoManager.sharedManager.addPhoto(photo)
    }
    
    completion?(storedError)
}
```
- 알림은 completion closure에서 발생한다. 사진들을 다운로드하는 반복문을 모두 돈 후에 호출이 된다. 사진 다운로드는 DownloadPhoto(url:) 메소드가 시작한다. 이 메소드는 곧바로 리턴하지만 실제 다운로드는 비동기로 작업한다. 그러므로 completion이 호출될 때 모든 사진이 다운로드 완료되었다는 보장이 없다.
- 모든 사진이 다운로드 완료된 후 completion closure가 호출되도록 해야한다. 어떻게 다운로드 완료시점을 체크할 수 있을까?
- dispatch group을 사용해야 한다. 복수의 task를 그룹화하여 task가 모두 완료되기를 기다리게 할 수 있다. 그룹핑할 수 있는 task는 동기 또는 비동기 처리가 가능하며 심지어 다른 큐에서 동작할 수 있다.
- wait 메소드는 그룹에 포함된 모든 task가 완료될 때까지 current thread를 막는다
- PhotoManager.swift에서 downloadPhotosWithCompletion(_:)을 다음과 같이 수정해라

## dispatch group의 wait() 사용하기
- dispathc group의 wait() 메소드는 동기적 completion closure 이다.
- wait()를 사용하면 current thread를 차단하여 group의 모든 tasks가 완료될 때까지 기다렸다가 완료 시점을 알려준다
- wait() 사용시에는 main thread를 차단하는 것을 방지하기 위해 global queue에 task를 넣어야한다.
```swift
DispatchQueue.global(qos: .userInitiated).async { // 1
  var storedError: NSError?
  let downloadGroup = DispatchGroup() // 2
  for address in [overlyAttachedGirlfriendURLString, 
                  successKidURLString,
                  lotsOfFacesURLString] {
    let url = URL(string: address)
    downloadGroup.enter() // 3
    let photo = DownloadPhoto(url: url!) {
      _, error in
      if error != nil {
        storedError = error
      }   
      downloadGroup.leave() // 4
    }   
    PhotoManager.sharedManager.addPhoto(photo)
  }   
      
  downloadGroup.wait() // 5
  DispatchQueue.main.async { // 6
    completion?(storedError)
  }   
}
```
- wait 메소드는 current thread를 차단하므로 main thread상에서 동작하면 안된다. 따라서 background queue에서 async로 동작하도록 묶어준다
- 다운로드 task들을 그루핑할 dispatch group을 만든다
- enter() 메소드를 이용해 task가 시작했다는 것을 group에게 알린다. 
- leave()는 해당 task가 완료되었다고 group에게 알린다. 이 때 enter() 호출빈도와 leave()호출 빈도가 같아야 한다.
- 모든 task가 완료될 때까지 wait()를 이용해 current thread 를 차단한다. wait(timeout:) 을 이용하면 특정 시간 이후부터 current thread 를 차단할 수 있다
- wait() 메소드 이후에는 모든 다운로드 tasks가 완료되었다는 것을 보장받으므로 compeltion closure를 호출해도 좋다.
- 앱을 다시 실행해보면 모든 이미지가 다운로드 완료된 이후에 완료알림이 뜰 것이다.

### note
- 네트워크 업무가 너무 빨리 발생하면 언제 completion closure 언제 호출되는지 판별하기가 어렵다. 디바이스로 앱을 실행한다면 설정 앱에서 네트워크 설정을 통해 네트워크 업무를 일부러 느리게 해서 이를 확인할 수 있다. Network Link Conditioner 에 가서 활성화 하고 프로필에서 "very bad network"선택하면 된다.
- 시뮬레이터로 실행중이라면 Xcode의 advanced tolls에서 network link conditioner를 사용해서 네트워크 속도를 조절할 수 있다. 이를 통해 통신 속도가 낮은지 적절한지에 따라 앱에 어떤 변화가 일어나는지 미리 확인할 수 있는 좋은 도구이다.

- Dispatch group은 모든종류의 큐에서 사용하기 좋다. wait()를 사용할 때에는 main thread를 차단하면 안되기 때문에 조심해야한다. 비동기처리 방식이 dispatch group을 사용하기 적절하다
- 현재의 해결방법도 좋지만 가능하다면 thread 차단을 안하는 것이 제일 좋다. 이제부터는 thread를 차단하지 않고 비동기적으로 완료시점을 알리는 방법을 살펴보자

## dispatch group의 notify 사용하기
- wait()를 사용해서 current thread를 차단하는것 보다 task 완료시점을 알 수 있는 더 좋은 방법이 있다. PhotoManager.swift파일을 열고 downloadPhotosWithCompletion(_:) 을 아래와 같이 바꿔보자
```swift
// 1
var storedError: NSError?
let downloadGroup = DispatchGroup()
for address in [overlyAttachedGirlfriendURLString,
                successKidURLString,
                lotsOfFacesURLString] {
  let url = URL(string: address)
  downloadGroup.enter()
  let photo = DownloadPhoto(url: url!) {
    _, error in
    if error != nil {
      storedError = error
    }   
    downloadGroup.leave()
  }   
  PhotoManager.sharedManager.addPhoto(photo)
}   
    
downloadGroup.notify(queue: DispatchQueue.main) { // 2
  completion?(storedError)
}

```
- 여기서는 wait()를 사용하지 않으므로 main thread를 차단할 위험성이 없기 때문에 굳이 global queue에 task를 넣어둘 필요는 없다
- dispatch group의 notify(queue:work:) 메소드는 비동기 completion closure 로서 동작한다. group의 task가 모두 완료되어 그룹에 더이상의 task 가 남아있지 않을 때 호출이 된다. completion closure가 main queue에서 동작하도록 할 수도 있다.
- 이 방법은 thread를 차단하지 않으므로 wait를 사용하는 것 보다 좀 더 바람직한 방법이다.
- 앱을 실행해보면 아까와 같은 결과이나 내부적으로는 보다 thread safe 한 코드이다.

## Concurrecncy Looping
- PhotoManager의 downloadPhotosWithCompletion(_:)을 다시 살펴보자. 반복문을 돌면서 3개의 이미지를 다운로드한다. 이 반복문을 concurrently하게 동작하도록해서 속도를 좀 더 향상시켜보자
- DispatchQueue.concurrentPerform(iterations:execute:)를 사용하면 된다. 이것은 동기적 처리이며 모든 업무가 종료되었을 때 리턴한다. task 양에 따라 적정한 반복횟수를 결정하는 것이 중요하다. 각 반복횟수마다 너무 적은 task를 분담하면 비효율적이다. striding이라는 기술을 이용해서 각 반복마다 복수의 task를 처리할 수 있다.
- 언제 사용해야 할까? serial queue에서는 아무런 효과가 없다. 따라서 concurrent queue에서 반복문이 필요하고 이 과정을 추적할 필요가 있을 때 사용하자.
- PhotoManager.swift 파일에서 downloadPhotosWithCompletion(_:) 안의 for 반복문을 다음과 같이 수정해보자
```swift
var storedError: NSError?
let downloadGroup = DispatchGroup()
let addresses = [overlyAttachedGirlfriendURLString,
                 successKidURLString,
                 lotsOfFacesURLString]
let _ = DispatchQueue.global(qos: .userInitiated)
DispatchQueue.concurrentPerform(iterations: addresses.count) {
  i in
  let index = Int(i)
  let address = addresses[index]
  let url = URL(string: address)
  downloadGroup.enter()
  let photo = DownloadPhoto(url: url!) {
    _, error in
    if error != nil {
      storedError = error
    }
    downloadGroup.leave()
  }
  PhotoManager.sharedManager.addPhoto(photo)
}
downloadGroup.notify(queue: DispatchQueue.main) {
  completion?(storedError)
}
```
- 앱을 실행해보면 여전히 잘 동작한다. 디바이스에서 실행하면 아주 약간이지만 이미지 다운로드가 빨라진 것을 확인할 수 있을 것이다. 근데 이게 정말 할만한 가치가 있는 작업이니?
실재로 위의 경우에는 별로 효과가 없다. 이유를 살펴보자
- 각 반복마다 적정한 task를 분담해야 하는데 현재는 그렇지 못한 상태이기 때문이다
- 리팩토링 시간이 부족하다면 현저하게 효과가 있는 것에 집중해라. instrument를 사용하여 앱을 프로파일링 해서 어디서 가장 오래걸리는 task가 있는지 확인해라.
- 일반적으로 코드최적화 과정이 오히려 코드를 더욱 복잡하게 할 수 있으니 과연 이 과정이 효과가 그만큼 있는지 생각해라.

## Cancelling Dispatch blocks
- 지금까지 큐에 넣은 task를 취소하는 것은 배우지 않았다. 이제 dispatch block objects에 대해 배워보자. task 가 큐의 head에 도달해서 실행을 시작하기 전에만 task를 취소할 수 있다는 것을 명심해라. 위의 앱에서 이미지를 다운로드 시작한 후 몇개의 이미지 다운로드를 취소하려고 한다고 가정해보자. PhotoManager.swift 파일에서 downloadPhotosWithCompletion(_:)을 다음과 같이 수정하자
```swift
var storedError: NSError?
let downloadGroup = DispatchGroup()
var addresses = [overlyAttachedGirlfriendURLString,
                 successKidURLString,
                 lotsOfFacesURLString]
addresses += addresses + addresses // 1

//task를 block이라고 하나보다
var blocks: [DispatchWorkItem] = [] // 2

for i in 0 ..< addresses.count {
  downloadGroup.enter()

  let block = DispatchWorkItem(flags: .inheritQoS) { // 3
    let index = Int(i)
    let address = addresses[index]
    let url = URL(string: address)
    let photo = DownloadPhoto(url: url!) {
      _, error in
      if error != nil {
        storedError = error
      }
      downloadGroup.leave()
    }
    PhotoManager.sharedManager.addPhoto(photo)
  }

  blocks.append(block)
  DispatchQueue.main.async(execute: block) // 4
}

for block in blocks[3 ..< blocks.count] { // 5
  let cancel = arc4random_uniform(2) // 6
  if cancel == 1 {
    block.cancel() // 7
    downloadGroup.leave() // 8
  }
}

downloadGroup.notify(queue: DispatchQueue.main) {
  completion?(storedError)
}
```
- 기존의 이미지 주소를 복사해서 총 6개의 이미지 주소를 포함하는 배열을 만든다
- dispatch block object를 담을 array를 만들어 놓는다
- DispatchWorkItem 인스턴스를 생성하고 이 task가 들어갈 queue 의 QoS를 상속하도록 한다. task 생성되면 호출될 completion closure를 붙인다.
- completion closure에서는 생성된 task를 main queue에 비동기 방식으로 넣는다. main queue 는 serial queue이기 때문에 이전 task의 다운로드가 완료될때까지 기다리므로 task 를 취소하기가 훨씬 용이하다.
- tasks가 담긴 배열에서 4,5,6 번째 task를 취소가능 대상으로 설정했다.
- 0과 1 중 하나를 랜덤으로 선택하기 위해 arc4random_uniform()을 사용한다
- 랜덤숫자가 1이면 task 를 취소한다. 큐에 여전히 존재하는, 아직 실행되지 않은 task만 취소가 가능하다. 실행중인 task는 취소가 불가능하다
- dispatch group에서 취소된 task를 뺀다.
- 앱을 실행해서 이미지를 다운로드 해보자. 3개 이상의 이미지를 다운로드하는 것을 볼 수 있다. 초과된 이미지 갯수는 앱을 실행할때마다 다르다. 추가적인 이미지 다운로드 task중 일부가 다운로드를 시작하기 전에 취소가 된다.
---

## Miscellaneous GCD Fun
- 아직 잡다한 메소드들이 더 남았다. 자주 사용하지는 않을지라도, 엄청 도움이 될 것이다.

### Testing Asynchronous code
- 이상하게 들릴 것이다. Xcode에 test기능이 있다는 것을 알고 있었니? 테스트 코드는 복잡한 구조의 코드를 짤 때 매우 중요하다.
- 테스트는 XCTestCase의 하위클래스에서 수행된다. test로 시작하는 이름의 메소드를 모두 실행한다. 테스트는 main thread에서 동작한다. 따라서 테스트는 serial하게 순서대로 동작한다.
- 주어진 테스트 메소드가 완료되자마자 XCTest는 다음 테스트를 실행시킨다. 이전 test에서 비동기적으로 동작하는 작업들의 완료와는 관계없이 다음 테스트 메소드가 실행한다.
- 네트워크 통신 업무는 main thread 를 차단하는 것을 원치 않기 때문에 주로 비동기처리 업무이다. 이러한 비동기 메소드들은 테스트하기가 까다롭다.

## 비동기 작업을 테스트하기

### 1. Semaphores (신호기)
- 이것은 오래된 신호 방법이다. 운영체제의 복잡성 상에서 동작하기 때문에 까다로운 주제이다. 만약 이걸 공부하고 싶으면 semaphore 이론을 찾아보길 바란다.
- GooglyPuffTests.swift 파일을 열고 downloadImageURLWithString(_:)을 다음과 같이 수정해보자
```swift
let url = URL(string: urlString)
let semaphore = DispatchSemaphore(value: 0) // 1
let _ = DownloadPhoto(url: url!) {
  _, error in
  if let error = error {
    XCTFail("\(urlString) failed. \(error.localizedDescription)")
  }   
  semaphore.signal() // 2
}
let timeout = DispatchTime.now() + .seconds(defaultTimeoutLengthInSeconds)
if semaphore.wait(timeout: timeout) == .timedOut { // 3
  XCTFail("\(urlString) timed out")
} 
```
- semaphore 신호기를 생성하고 초기값을 0으로 설정한다. 이 신호값은 신호를 보내지 않고도 신호에 접근 가능한 갯수를 나타낸다
- 이미지 다운로드가 완료되면 completion closure에서 신호를 보낸다. 그러면 신호 숫자가 증가하고, 따라서 신호값이 증가한다.
- 주어진 timeout 동안 신호를 기다린다. 이것은 신호값 증가가 완료될때 까지 current thread를 차단하는 것이다. 리턴값이 0 이 아니라면(fail이면) 타임아웃이 끝난 것이다. 위의 경우에서는 네트워크 통신이 10초 이상 걸리면 실패로 간주된다.
- cmd + U 를 눌러 테스트를 실행해보면 성공할 것이다. 
- 네트워크를 비활성화되도록 설정한 후 다시 테스트해보자. 디바이스에서 실행한다면 비행기모드를 켜고 시뮬레이터로 실행한다면 통신을 끄고 테스트해보자. 10초 후에 실패라고 뜰 것이다.
- 위의 테스트가 하찮은 작업일지도 모르지만 만약 서버팀과 함께 일하는 경우 이러한 기초 테스트를 통해 비난을 면할 수 있다.

### 2. Expectations
- 