# iOS Concurrency with GCD and operations
> [iOS Concurrency with GCD and operations](https://videos.raywenderlich.com/courses/55-ios-concurrency-with-gcd-and-operations/lessons/1) 를 재가공하였습니다.

## FAQ
### 1. what is concurrency?
- 동시에 복수의 업무를 수행하는 것
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
- 운영체제는 thread를 관리한다. GCD, Operation은 복수의 task를 처리할 때 Queue라는 가상의 구조를 사용해서 처리하는 api로서, 개발자가 thread를 직접통제하는 위험을 줄일 수 있다.
- GCD는 보다 간단한 작업에 적합, operation은 복잡한 작업에 적합

### 5. where do tasks run?
- thread 에서 실행된다
- UI task 는 main thread 에서 동작
- non-UI task는 main 이외의 thread에서 동작하게 해서 효율적으로 분배하는 것이 좋다
- iOS에서 추구하는 것은 시스템으로 하여금 thread 를 통제하는 것

### 6. queue, thread?
- GCD, operations는 개발자가 직접 thread를 통제하는 대신에 queue를 사용하게 한다
- 개발자가 task 를 dispatch queue 또는 operation queue에 넣으면 시스템이 thread를 몇개 만들지 결정한다

### 7. async
- 비동기는 task 처리시 현재의 thread를 차단하지 않고 task 실행을 다른 thread에게 넘기고 하던 일을 계속한다.

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

## GCD (업무분담) = DispatchQueue를 사용한다
- serial queue(private): 복수의 task를 처리할 때 task의 완료순서를 보장한다. 각각의 큐에서는 동시에 하나의 task만 실행. 여러개의 serial queue를 만들면 각 큐에서는 동시에 각각 1개의 task만 실행하지만 전체적으로는 동시에 여러 task를 실행한다. 
- serial queue를 사용하면 thread간 충돌이 없기 때문에 concurrency의 여러 문제점 해결 가능
- concurrent queue: 복수의 task 처리시 task 완료 순서를 보장하지 않는다.

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
- 주로 getter, setter 에 사용 (잠시 current thread 를 block 하므로 주의해야 한다)
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
---

## 하나의 task 완료시점을 알고 싶을 때
- closure 를 사용한다

## 연관된 collection of tasks 의 완료시점을 알고 싶을 때
- async 매개변수에 group을 넣기
```swift
//create group
let group = DispatchGroup()

//dispatching to a group
workerQueue.async(group: group) {
    print("task1")
}

//tasks group 이 완료되는 시점 알림
group.notify(queue: DispathQueue.main) {
    print("both tasks have completed")
}

//tasks group 이 완료될때까지 current queue 를 block하고 싶을 때 사용, main queue에서는 호출하지 말 것
group.wait(timeout: DispatchTime.distantFutere)
```

- task 자체가 async 일때
```swift
let wrappedGroup = DispatchGroup()

func asyncWithGroup(_ input: InputType, completionQueue: DispatchQueue, group: DispatchGroup, completion: @escaping(OutputType, Error?)->()) {

    group.enter()

    asyncFunction(input, completionQueue: completionQueue) { result, error in
        completion(result, error)
        group.leave()
    }
}
```
---

## operation
- 추상클래스이기 때문에 BlockOperation으로 구체화하거나 임의로 subclass를 만들어서 사용한다
- 복잡한 이미지 필터링을 수행하는 작업을 operation queue에 넣을 것이다
- selective focus 효과를 감소시키는 필터링 효과(사진이 미니어쳐 처럼 보인다)
- default값은 sync하게 동작

### operation queue에 넣을 operation 생성하기
- 간단한 operation은 Dispatch queue에서 실행되는 클로저 형태와 같다
```swift
let operation = BlockOperation {
    print("operation started")
    print("operation finished")
}
```
- 재사용하고 싶으면 Operation을 상속한다
```swift
class ImageTransformOperation: Operation {
    var inputImage: UIImage?
    var outputImage: UIImage?

    override func main() {
        outputImage = transform(image: inputImage)
    }
}
```
- 상속받은 operation은 input, ouput 프로퍼티를 가질 수 있고 helper method를 가질 수 있다. task를 실행하기 위한 main 메소드를 재정의 해야한다
- Operation class는 task 단위를 나중에 실행하기 위해 포장해놓는 것과 같다. 다른 작업들을 하다가 원하는 시점에 이 task를 실행할 수 있다.
- Operation은 life cycle 을 지닌다
- 초기화 -> isReady -> isExecuting (-> isCancelled) -> isFinished
```swift
open class Operation: NSObject {
    open func start()
    open func main()
    open var isCancelled: Bool { get }
    open func cancel()

    open var isExecuting: Bool { get }
    open var isFinished: Bool { get }
    open var isAsynchronous: Bool { get }
    open var isReady: Bool { get }

    open var completionBlock: ( ()->Swift.Void )?
    open var qualityOfService: QualityOfService
    open var name: String?
}
```
- task를 main thread 이외의 곳에서 동작하게 하려면 dispatch queue or operation queue로 분담해야 한다
- Operation 을 상속하면 operation task의 현재상태를 파악하기 쉽다
- task 가 완료되면 completionblock이 호출된다

### BlockOperation
- Operation은 추상클래스이므로 단독으로 생성될 수 없으며, Operation 인스턴스를 생성하기 위한 가장 간단한 방법으로 BlockOperation class를 사용한다
```swift
open class BlockOperation: Operation {
    public convenience init(block: @escapint () -> Swift.Void)
    open func addExecutionBlock(_ block: @escapiing() -> Swift.Void)
    open var executionBlocks: [() -> Swift.Void] { get }
}
```
- BlockOperation class 는 global queue 에서 복수의 block task 가 concurrent하게 실행되는 것을 관리한다
- Dispatch queue를 사용하지 않으며 Operation dependency, KVO notification, cancelling 등의 장점을 제공한다.
- Dispatch group 과 같이 모든 block task가 완료되는 시점을 알 수 있다
- block tsak가 serial 하게 동작하기를 원한다면 private dispatch queue에 넣거나, operation dependency 를 사용할 수 있다
```swift
var result: Int?

let blockOperation = BlockOperation()

blockOperation.completionBlock {
    print("all finished")
}

blockOperation.addExecutionBlock {
    print("hello")
    sleep(2)
}
blockOperation.addExecutionBlock {
    print("my")
    sleep(2)
}
blockOperation.addExecutionBlock {
    print("name")
    sleep(2)
}
blockOperation.addExecutionBlock {
    print("is")
    sleep(2)
}
blockOperation.addExecutionBlock {
    print("samchon")
    sleep(2)
}

blockOperation.start()

```
- BlockOperation은 global queue에서 concurrent 하게 동작하므로 위의 코드의 출력 순서가 랜덤이다
- completionBlock을 사용하면 Dispatch group과 같이 blockOperation에 포함된 복수의 task가 모두 완료되는 시점을 알 수 있다
- 위와 같이 간단한 task는 BlockOperation으로 가능하지만 input ouput 등이 필요한 복잡한 작업은 임의로 subclass를 만들어야 한다

### Subclassing Operation
- Operation을 보다 정교하게 관리할 수 있다
```swift

let inputImage = UIImage(named: "samchon")

class SubclassOperation: Operation {
    var inputImage: UIImage?
    var outputImage: UIImage?

    override func main() {
        outputImage = filterImage(image: inputImage)
    }
}

let filterImageOperation = subclassOperation()
filterImageOperation.inputImage = inputImage

filterImageOperation.start()

```
- filter작업이 느리기 때문에 수정이 필요하다

### OperationQueue
```swift
open class OperationQueue: NSObject {
    open class var current: OperationQueue? { get }
    open class var main: OperationQueue { get }
    public class let defaultMaxConcurrentOperatinoCount: Int
    open var maxConcurrentOperationCount: Int

    open func addOperation(_ op: Operation)
    open func addOperation(_ block: @escaping () -> Swift.Void)
    open func addOperations(_ ops: [Operation], waitUntilFinished wait: Bool)

    open var operations: [Operation] { get }
    open var operationCount: Int { get }

    //management
    open func cancelAllOperations()
    open func waitUntilAllOperationsAreFinished()

    open var qualityOfServce: QualityOfServic
    open var isSuspended: Bool
    unowned (unsafe) open var underlyingQueue: DispatchQueue?
    open var name: String?
}
```
- main operation queue: UI 관련 operation 실행
- defaultMaxConcurrentOperationCount를 제한할 수 있으며 만약 -1 이면 시스템에게 알아서 하라는 뜻이다. 1이면 serial operation queue가 된다
- qos, dependency 등이 설정된 것에 따라 순서에 맞게 Operation Queue에서 operations이 실행된다. 우선순위가 모두 같다면 넣어진 순서대로 실행된다
- operation은 완료되거나 취소되면 queue를 떠난다
- operation이 큐에 넣어지면 같은 operation을 다른 어떤 큐에도 넣을 수 없다. operation은 1회용이라서 한번 실행되면 재실행할 수 없다.
- 모든 operations가 끝나는 시점을 알고 싶다면 private serial dispatch queue를 사용하거나, wailIntilFinished를 true로 설정하고 completion closure 넣기
- 각 operation마다 다른 qos 설정이 가능하다. default qos 값은 background 이다
- isSuspended 프로퍼티를 사용해 operation queue을 중지할 수 있다. 현재 실행중인 operation은 계속 진행하되 나머지는 실행되지 않는다. 중지된 큐에 새로운 operation을 넣을 수 있지만 isSuspended가 false가 되기 전에는 실행되어지지는 않는다
- KVO 의 디폴트값은 false이다
- 아직 operation queue이 비어있는 상태라면 main queue를 제외한 기존의 dispatch queue는 Operation queue의 underlying queue로서 동작할 수 있다. underlying queue의 qos는 operation queue의 qos를 따른다
- 앞서 보았듯이 개별적인 Operation은 동기적으로 동작하며 main thread를 차단하는 것을 방지하기 위해 Dispatch queue에 넣어서 비동기적으로 동작시킬 수 있었다. 그러나 완전히 concurrent 하게 동작하는 것처럼 하기 위해서는 Operation queue를 활용하는 것이 장점이 많다.
```swift
//빈 operation queue 만들기
let printerQueue = OperationQueue
printerQueue.maxConcurrentOperationCount = 2

printerQueue.addOperation {
    print("hello")
    sleep(3)
}
printerQueue.addOperation {
    print("my")
    sleep(3)
}
printerQueue.addOperation {
    print("name")
    sleep(3)
}
printerQueue.addOperation {
    print("is")
    sleep(3)
}
printerQueue.addOperation {
    print("samchon")
    sleep(3)
}

printerQueue.waitUntilAllOperationsAreFinished()
```
- operation queue에 넣으면 operation.start() 하지 않아도 opearation queue가 준비되면 시작한다
- 앞서 operation을 Dispatch queue에 넣은것처럼 Operation queue에 넣으면 background thread에서 concurret하게 동작한다
- Dispatch group과 같이, operationqueue의  waitUntilAllOperationsAreFinished() 메소드를 사용하면 current queue를 차단하고 모든 업무가 완료될때까지 기다린다
- maxConcurrentCount 프로퍼티를 통해 최대 몇개의 operation을 동시체 처리할 것인지 제한 가능

```swift
let images = ["city", "dark road", "train day", "train dusk", "train night"].map { UIImage(named: "\($0).jpg")}
var filterdImages = [UIImage]

let filterQueue = OperationQueue()

let serialQueue = OperationQueue()
serialQueue.maxConcurrentOperationCount = 1

for image in images {
    let filterOperation = Operation()
    filterOperation.inputImage = image

    filterOperation.completionBlock {
        guard let ouput = filterOperation.outputImage else { return }
        serialQueue.addOperation {
            filteredImages.append(output)
        }
    }

    filterQueue.addOperation(filterOperation)
}

filterQueue.waitUntilAllOperationsAreFinished()
```
