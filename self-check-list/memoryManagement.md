# Automatic Reference Couting
- 컴파일 과정시 인스턴스가 생성되면 count가 증가하고 scope를 벗어나거나 nil이 되면 object가 소멸되면서 count가 감소한다. count가 최종적으로 0 이 되면 더이상 특정 object가 사용되지 않는다고 인식하고 메모리에서 배제된다.

```swift
class Myclass{}
func foo(c: Myclass) {
  ...
} do {
  let c0: Myclass = Myclass()   //retain(c0)
  var c1: Myclass? = c0         //retain(c1)
  foo(c0)                       //retain(c), release(c)
  c1 = nil                      //release(c1)
}                               //release(c0)
```
---

# 수동 메모리 관리의 필요성
- object가 서로 참조하는 경우 순환참조가 생성되어 scope를 벗어나거나 값이 nil 이 되어도 reference count가 0이 되지 않는 현상이 발생한다.
---

## 순환참조 방지하기

### weak 참조방식
- 아무런 지정을 하지 않은 경우 참조방식의 default값은 strong 참조이다. strong 참조방식은 reference counting이 증가하나, weak 참조는 reference counting이 증가하지 않는다.

### unowned 참조방식
- weak 참조방식과 같이 reference counting이 증가하지 않는다. 차이점은 weak 참조는 referece counting이 0 이 될 때 nil 값으로 변경되므로 optional이지만, unowned 참조방식은 값이 변경되지 않으므로 메모리에서 해제되었을 시 존재하지 않는 메모리를 참조하는 경우가 발생할 수 있어 주의해야 한다.
---

## closure
- closure 역시 참조방식이므로 메모리 누수에 유의해야 합니다. 탈출 클로저 같은 경우 scope를 벗어나도 reference 를 유지하므로 이런 경우에는 capture list 기능을 사용해서 메모리 누수를 방지할 수 있다.
- capture list는 클로저 내부에서 사용할 referece type을 캡처링하는 방식을 나타내는 것이다. 이 때 weak or unowned 방식을 선언하면 된다.

```swift
lazy var someClosure: () -> String = { 
  [unowned self, weak delegate = self.delegate!] in 
  // closure body goes here 
}
```
