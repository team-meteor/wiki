# iOS Concurrency with GCD and operations
> [iOS Concurrency with GCD and operations](https://videos.raywenderlich.com/courses/55-ios-concurrency-with-gcd-and-operations/lessons/1) 를 재가공하였습니다.

## FAQ
### 1. what is concurrency?
- 동시에 복수의 업무가 수행된다.
- GCD, operations 를 사용해 처리 가능
- 1개의 CPU로는 처리가 힘들다
- 매번 실행되는 순서가 다르다

### 2. why use concurrency?
- UI 를 responsive 하게 유지하기 위해서
- 예를 들어 테이블뷰 스크롤 시 동시에 테이블 내용을 내려받으면서 UI 동작을 자연스럽게 유지하는 것

### 3. how do you use concurrency?
- 서로 다른 resource 에 접근하는 task 는 동시 실행 가능
- 읽기만 하는 task 는 동시 실행 가능
- 같은 resource에 접근하는 task라면 thread safe 해야 한다.

### 4. which to use? GCD(Grand Central Dispatch) or operations?
- GCD는 보다 간단한 작업에 적합, operation은 복잡한 작업에 적합

### 5. where do tasks run?
- thread 에서 실행된다
- UI task 는 main thread 에서 동작
- thread 를 만들 수 있다
- non-UI task는 main 이외의 thread에서 동작하게 해서 효율적으로 분배하는 것이 좋다
- iOS에서 추구하는 것은 시스템으로 하여금 thread 를 통제하는 것

### 6. queue, thread?
- GCD, operations는 개발자가 직접 thread를 통제하는 대신에 queue를 사용하게 한다
- 개발자가 task 를 dispatch queue 또는 operation queue에 넣으면 시스템이 thread를 몇개 만들지 결정한다

### 7. async
- GCD, operation 은 비동기 작업을 다른 thread에서 동작하게 한다

```swift
let queue = DispatchQueue(label: "com.raywenderlich.worker")

queue.async {
    // call slow non-UI task

    DispatchQueue.main.async {
        // UI task
    }
}

```

## concurrency 에서 발생가능한 문제점(실행 순서가 매번 다르다)
- 1, 2 번 문제는 gcd, operation으로 해결 가능

### 1. race condition
- 두개의 thread가 같은 value에 접근할 때 발생
- thread 타이밍 문제
- x-code 의 Thread Sanitizer tool 이용해 디버깅
- serial queue를 이용해 thread간 접근을 제한하여 동시 접근 문제를 해결할 수 있다

### 2. priority inversion
- high priority task 가 low priority task에 접근해야 할 때 high priority task 가 멈추고 low priorty task가 실행되는 현상
- gcd, operation 을 사용하면 low priory task 를 high priority 수준으로 올려서 문제를 해결할 수 있다

### 3. deadlock
- serial queue를 이용해 thread간 접근을 제한하여 동시 접근 문제를 해결할 수 있지만, 둘 다 제한되어 잠들어 버리는 경우

---

## GCD (업무분담)
- GCD는 개발자 대신 thread를 통제한다
- main thread + serial queue  or  main thread + concurrent queue
- serial queue 는 thraed 1개 사용, concurrent queue 는 여러개의 thread 생성가능
- serial queue를 사용하면 thread간 충돌이 없기 때문에 concurrency의 여러 문제점 해결 가능

## concurrent queue와 async 는 같은 것이 아니다
- serial queue or concurrent queue 에서 모두 비동기 업무 처리가 가능하다
- 동기와 비동기의 차이는 queue 상에서 task가 완료될 때 까지 기다리느냐의 차이이다
- serial 과 concurrent의 차이는 thread 갯수 차이이다 (동시에 몇개의 업무가 처리 가능한지의 차이)

## GCD의 queue 종류 (First In First Out, task가 도착하는 순서로 시작한다)

### 1. main
- serial
- 1 thread
- 동기적 업무 처리시 다른 업무 처리불가

### 2. global
- concurrent
- 동기적으로 업무를 처리해도 다른 thread에서 task 처리 가능하다
- 시작순서와 완료순서가 다를 수 있다
- task 특성에 따라 qos를 지정할 수 있다

### 3. private
- serial queue(default) = DispatchQueue(label: "")
- concurrent queue = DispatchQueue(label: "", attributes: .concurrent)

## quality of service(qos) 에 따른 queue의 priority
- userInteractive = UI 관련, 높은 우선순위
- userInitiated = 비동기적 UI 업무 (저장된 문서 열기)
- default
- utility = progress indicator 와 함께 오래 걸리는 업무 (네트워킹)
- background = non UI task
- unspecified

## async
- UI 관련 task는 main queue이고 나머지는 global queue에 분배
- 즉시 return 하므로 task가 언제 완료되는지 모른다

```swift
DispatchQueue.global().async {
    //do expensive synchronous task
    DispathchQueue.main.async {
        //UI task
    }
}
```

## sync
- 주로 getter, setter 에 사용 (잠시 current queue 를 block 하므로 주의해야 한다)
- task가 끝날때까지 current thread를 block 한다. 끝날때 까지 current thread에 다른 업무를 분배할 수 없다
- current queue에서 sync 업무를 분배하면 deadlock에 걸릴 수 있다
- main queue에서 절대 sync 업무 분배하지 않는다 (main thread를 block하기 때문)
- sync 업무는 어느 queue에 분배하든지 실제로는 current queue에서 동작한다
- main queue는 항상 main thread를 사용한다

```swift
private let internalQueue = DispatchQueue(label: "com.raywenderlich")

var name: String {
    get {
        return internalQueue.sync{ internalName }
    }
    set (newName) {
        internalQueue.sync { internalName = newName }
    }
}
```
## sync vs async, serial vs concurrent 의 차이를 이해하자
- sync는 task가 끝날때까지 current thread를 봉쇄하므로 main queue에서 사용해서는 안된다
- async는 task가 끝나기 전에 다른 task를 시작할 수 있다
- serial queue 는 1개의 thread를 사용하므로 동시에 여러개의 task를 처리할 수 없다
- concurrent queue 는 thread 를 여러개 만들 수 있으므로 동시에 여러 업무 처리가 가능하다
---

## sync tasks 를 async로 처리하고 싶을 때

### 1. async로 감싸기
```swift
DispatchQueue.global().async {
    let result = syncFunc()
    result
}
```

### 2. sync task 를 async 로 변형
```swift
//completionQueue 는 주로 main queue
public func asyncSyncFunction(_ input: inputType, runQueue: DispatchQueue, 
    completionQueue: DispatchQueue, completion: @escaping(resultType, error) -> ()) {
        runQueue.async {
            var error: Error?
            error = .none
            let result = syncFunction(input)
            completionQueue.async {
                completion(result, error)
            }
        }
    }
```

### 3. 클로저 안의 tasks 가 동기적이면(체이닝) 순서대로 실행
```swift
DispatchQueue.global().aync {
    let out0 = task0()
    let out1 = task1(inString: out0)
    let out2 = task2(inString: out1)
    print(out2)
}
```

### 4. serial queue에 각각 task를 분리시켜도 동기적으로 순서대로 실행
```swift
DispatchQueue(label: "com").async {
    let out0 = task0()
}
DispatchQueue(label: "com").async {
    let out1 = task1(inString: out1)
}
DispatchQueue(label: "com").async {
    let out2 = task2(inString: out2)
}
```

### 5. 비슷한 독립적인 non-UI task 들을 실행할 때 concurrent queue 사용
- loop를 돌면서 여러개의 thread를 사용해 동시에 여러 task를 실행하지만 순서대로 실행

```swift
let values = [Int](1...12)
for value in values {
    DispatchQueue.global().async {
        randomTask(value)
    }
}
```
