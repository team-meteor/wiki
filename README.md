## iOS Cheat Sheet

iOS에 대한 문서를 만들고 모아봅시다.
[view in gitbook](https://hoemoon.gitbooks.io/ios-cheat-sheet/)

**작성방법**
- [gitbook guide](https://toolchain.gitbook.com/pages.html)
- 작성 후 `done` 처리 해주세요.
- 마음껏 업데이트 해주세요.

### Objective-C
- [ ] NSObject 메소드를 오버라이딩해서 구현해본 경험이 있다.
- [ ] Category와 클래스 구현 상속의 차이를 알고, Category로 확장해봤다.
- [ ] Strong와 Weak 메모리 개념을 설명할 수 있다.
- [ ] 프로퍼티와 instance variable 구조, getter/setter 처리 방식을 설명할 수 있다.

### Swift
- [x] 스위프트 기본 문법을 이해하고 struct나 class, enum 타입을 만들 수 있다.
- [ ] struct와 class를 구분해서 설명할 수 있고, 어떤 경우 사용할지 기준을 갖고 있다.
- [ ] protocol와 extension 개념에 대해 설명할 수 있고, 어떤 경우에 활용하는지 알고 있다.
- [ ] 클로저를 만들어서 고차 함수의 매개변수나 리턴타입으로 전달할 수 있다.

### 앱 아키텍처
- [ ] 스토리보드나 XIB에서 화면 구성을 하고 Outlet을 연결할 수 있다.
- [ ] 코드로 버튼의 특정 이벤트에 타깃/액션을 연결 할 수 있다.
- [ ] NavigationBar나 TabBar를 이용하여 여러 View Controller를 Containing 하는 앱을 만들 수 있다.
- [ ] 앱 델리게이트에서 앱 라이프 사이클에 따라서 값을 저장하거나 불러오는 동작을 구현할 수 있다.
- [ ] UITableViewController나 UICollectionViewController에 대한 Datasource/Delegate 지정할 수 있고 동작 원리를 설명할 수 있다.
- [ ] Autolayout 등을 이용해서 화면 사이즈를 대응하는 뷰를 배치할 수 있다.

### 애니메이션
- [ ] UIView를 직접 움직이는 애니메이션을 만들 수 있다.
- [ ] Animation Callback 시점이나 easing 동작에 대해 설명할 수 있다.
- [ ] Block을 이용한 Animation을 구현할때 동작 순서나 처리 시점을 설명할 수 있다.
- [ ] UIBezierPath, CGPath 등 Core Graphics를 사용하여 직접 그리거나 애니메이션을 작성할 수 있다.

### 데이터관리
- [ ] NS 계열 데이터 클래스들 (NSArray, NSSet, NSDictionary…) 등의 특성과 사용 방법, 장점과 단점에 대해 안다.
- [ ] JSON/XML 데이터와 모델 객체 사이에서 Serialize, Deserialize를 처리할 수 있다.
- [ ] API를 호출하고 응답을 받아 모델 객체를 생성하고, 컨트롤러에 넘기는 형태로 개발해 봤다.

### 네트워크
- [ ] 네트워크 요청을 처리하는 앱을 만들어 본 경험이 있는가
- [ ] 사용해본 네트워크 라이브러리가 있는지?
- [ ] HTTP Request 메소드나 헤더를 변경하려면 어떻게 하는가?

### 메모리 관리
- [x] ARC나 수동 메모리 관리 방법에 대해서 설명할 수 있다.
- [ ] viewDidLoad, viewWillAppear, viewDidDisappear 등 ViewController 메소드 호출 시점에 대해 설명할 수 있다.

### 멀티쓰레드
- [ ] GCD의 동작 원리와 개념을 설명할 수 있다.
- [ ] 이미지 처리나 네트워크 다운로드를 위해 백그라운드 스레드 동작을 처리할 수 있다.
- [ ] 화면이 멈추거나 터치 이벤트에 무반응이 되지 않도록 하기 위해 어떤 스레드를 관리해야 할 지 알고 있다.
- [ ] 일정 간격으로 백라운드에서 실행하는 작업을 만들어본 경험이 있다. 혹은 만들 수 있다.

### Testing
- [ ] printf나 NSLog 로그 출력 이용한 테스트를 할 수 있다.
- [ ] Test Case를 작성해 본 경험이 있다.
- [ ] 항상 Unit Test를 작성해야 한다고 생각하며, 그 이유를 설명할 수 있다.

### 소스 코드 관리
- [ ] Git이나 SVN 등의 소스 관리 도구를 사용해 본 경험이 있다.
- [ ] Git 동작에 대해 이해하고 있고 branch, merge, rebase 등의 명령어를 사용해서 팀 활동을 할 수 있다.

### 프로파일링
- [ ] Profile 도구를 사용하여 CPU나 Memory 사용 변화를 분석한 경험이 있다.
- [ ] Profile 도구를 사용하여 앱의 CPU사용량을 메소드 별로 체크하고 리팩토링 해 본 경험이 있다.
- [ ] Profile 도구를 사용하여 앱의 Memory사용량을 분석해서 Cache나 수동 메모리 방식으로 리팩토링 해본 경험이 있다.

### 팀프로젝트와 개발 방법론