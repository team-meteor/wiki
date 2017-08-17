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