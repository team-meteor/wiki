# Test-Driven iOS Development with Swift 3

*Chapter 1*, Your First Unit Tests, Xcode를 사용해 첫 번째 유닛 테스트를 연습하고, TDD를 사용하는 것의 이점에 대해 이야기한다.  
*Chapter 2*, Planning and Structuring Your Test-Driven iOS App, 이 책을 통해 만들 앱과 Xcode 프로젝트를 세팅하는 법을 소개한다.  
**Chapter 3, A Test-Driven Data Model, TDD의 데이터 모델에 논의한다.**  
*Chapter 4*, A Test-Driven View Contorller, 뷰컨트롤러 테스트를 어떻게 작성할지를 보여줄 것이고, 가짜 객체를 이용해 작은 기능을 격리시키는 법을 설명한다.  
*Chapter 5*, Testing Network Code, stub을 이용해 아직 만들어지지 않은 서버 부분을 가장하는 법을 배울 것이다.  
*Chapter 6*, Putting It All Together, 이전에 개발된 다른 부분들을 합쳐보고, 기능 테스트의 사용을 보여줄 것이다.  
*Chapter 7*, Code Coverage and Continuous Integration, 어떻게 코드 커버리지를 측정하는지와 지속적인 통합에 대해 보여줄 것이다.


iOS 앱은 종종 MVC 패턴으로 개발된다. 이 패턴에서 각각의 class, struct 또는 enum은 모델 객체, 뷰 또는 뷰컨트롤러이다. 모델 객체는 데이터를 저장하는 것에 대한 책임이 있다. 이들은 UI를 표시하는 것으로부터 독립적이어야 한다. 예를 들어, iOS앱과 mac의 command-line 툴에서 같은 모델 객체를 사용할 수 있어야 한다.

뷰 객체는 데이터를 표시한다. 객체를 유저에게 표시하는 책임이 있다. 뷰는 현재 실행되고 있는 앱에게 특별하다. 크로스플랫폼 어플리케이션에서 뷰 객체는 공유될 수 없다. 각각의 플랫폼에서 뷰 레이어에 대한 각자의 구현이 필요하다.

컨트롤러 객체는 모델과 뷰 객체 사이에서 상호작용한다. 모델 객체를 볼 수 있게 만드는 것에 책임이 있다.

가장 쉬운 디자인 패턴 중 하나이고, 애플의 샘플코드에서 일반적으로 사용하기 때문에 MVC 패턴을 todo 앱에 사용할 것이다. 

이 장에서 TDD와 함께 앱의 모델 레이어에서 시작할 것이다.

- Implementing the ToDoItem struct
- Implementing the Location struct
- Implementing the ItemManager class

### Implementing the TodoItem struct

