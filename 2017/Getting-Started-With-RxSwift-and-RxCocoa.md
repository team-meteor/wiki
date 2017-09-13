# Getting Started With RxSwift and RxCocoa

정확히 말한 대로 코드가 동작하는 것은 훌륭하다. 프로그램에서 뭔가를 바꾸라, 코드에게 업데이트를 말하고, 실제로 그렇게 된다. 좋은 코드다!

객체 중심 시대의 대부분의 프로그래밍은 명령형이었다. 코드는 프로그램이 무엇을 해야 하는지 말해야 하고, 변경 사항을 따르는 다양한 방법을 가져야 한다. 하지만 일반적으로 뭔가가 변할 때, 시스템에게 활발히 이야기해야 한다.

그게 동작하는 한 괜찮다, 하지만 앱의 무엇이 변하면, 자동으로 코드가 업데이트하는 뭔가가 있는 게 더 낫지 않을까? 이것이 reactive 프로그래밍의 기본적인 아이디어다. 직접 뭔가를 하라고 하는 게 아니라, 어플리케이션에 데이터 변화에 반응할 수 있다. 특정한 상태를 관리하는 것보다 사용 가능한 로직에 집중하는 것을 쉽게 만든다.

대개 [Key-Value Oservation](https://developer.apple.com/library/ios/documentation/Cocoa/Conceptual/KeyValueObserving/KeyValueObserving.html)과 setter나 `didSet` 메서드를 정의하는 식으로 평범한 Objective-C 또는 swift로 할 수 있다. 하지만 때때로 이들 메서드를 정확히 설정하는 것은 귀찮다. 이런 문제를 해결하고자, reactive 프로그래밍을 쉽게 만드는 몇 가지 프레임워이 있다.

> Note: 더 많은 배경 지식을 원한다면, Rui Peres이 쓴 주요 프레임웍의 차이점에 대한 [article](https://www.raywenderlich.com/126522/reactivecocoa-vs-rxswift)이 있다. 댓글도 흥미롭다.

오늘은 `Rxswift`와 그 친구 `RxCocoa`를 쓸 것이다. 명령에서 reative.

## What are RxSwift and RxCocoa?

RxSwift와 RxCocoa는 ReactiveX의 일부이다.

Rxswift는 swift와 상호작용하는 프레임웍인 반면, RxCocoa는 iOS와 macOS에서 사용되는 Cocoa API가 reactive 기술을 사용할 수 있게 돕는 프레임웍이다.

ReactiveX 프레임웍은 다양한 언어에 걸쳐 반복적으로 사용되는 특정한 task에 대한 일반적인 어휘를 제공한다. 각각의 새로운 언어에 일반적인 task를 어떻게 적용할지 고민할 시간에 해당 언어의 문법에 집중하기 쉽게 만든다.

### Observables and Observers

두 가지 개념을 알아야 한다.
- `Observable`은 변화에 대한 알림을 발생하는 무언가이다.
- `Observer`은 변화가 발생하면 이를 통지받기 위해 Observable을 구독할 수 있는 무언가이다.

하나의 Observable을 여러 개의 Observer가 수신할 수 있다. Observable이 변경되면 그것의 모든 Observer가 통지 받는 것을 의미한다.

### The DisposeBag

`DisposeBag`라는 RxSwift과 RxCocoa 에는 ARC와 메모리 관리를 다루는 추가적인 도구가 있다. Observer의 객체는 그것의 부모 객체가 메모리에서 해제되면 가상의 "가방"으로 버려진다.

DisposeBag을 프로퍼티로 가진 객체의 `deinit()`이 호출되면, 그 가방은 비워지고, 각각의 폐기 가능한 Observer는 자동으로 관찰하고 있던 것의 구독을 멈춘다. 이를 통해 ARC는 메모리를 회수한다.

DisposeBag 없다면 두 가지 중 하나의 결과를 얻을 것이다. Observer가 retain cycle을 만들면서 무한히 감시하는 상태가 되거나, 메모리에서 해제되면서 crash가 발생할 수 있다.

훌륭한 ARC 시민이 되려면, Observable 객체를 설정할 때 `DisposeBag`에 추가하는 것을 기억하자. 그래야 깔끔하게 처리된다.

## Getting Started

```
어떤 앱인지에 대한 설명
```

### The Starting Point: Non-reactive

어떤 앱인지 확인했고, 어떻게 동작하는지 설명할 차례다. `ChocolatesOfTheWorldViewController.swift`을 열자. 전형적인 `UITableViewDelegate`과 `UITableViewDataSource`를 볼 수 있다.

`updateCartButton()`라는 메서드는 현재 카트에 있는 초콜렛 수로 카트 버튼을 업데이트 한다. 뷰 컨트롤러가 보여지려 할때 `viewWillAppear(_:)`에서, 새로운 초콜렛이 카트에 추가된 후에 `tableView(_:didSelectRowAt:)`에서 호출된다. 

카운터를 변경하는 두 가지 명령형 방법이다. 명시적으로 이들을 호출해야 한다.

지금은 값을 변경하는 위치를 추적해야 하지만, 이를 반응형 기법을 이용하도록 코드를 다시 작성할 것이다. 이 방법으로 카운트가 변하는 위치나 방법에 상관없이 버튼은 스스로 업데이트될 것이다.

### RxSwift: Making the Cart Count Reactive

카트의 아이템들을 레퍼런스하는 모든 메서드들은 `ShoppingCart.sharedCart` 싱글톤을 이용한다. `ShoppingCart.swift`을 열면, 


