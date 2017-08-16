# Test-Driven iOS Development with Swift 3

*Chapter 1*, Your First Unit Tests, Xcode를 사용해 첫 번째 유닛 테스트를 연습하고, TDD를 사용하는 것의 이점에 대해 이야기한다.  
**Chapter 2, Planning and Structuring Your Test-Driven iOS App, 이 책을 통해 만들 앱과 Xcode 프로젝트를 세팅하는 법을 소개한다.**  
*Chapter 3*, A Test-Driven Data Model, TDD의 데이터 모델에 논의한다.  
*Chapter 4*, A Test-Driven View Contorller, 뷰컨트롤러 테스트를 어떻게 작성할지를 보여줄 것이고, 가짜 객체를 이용해 작은 기능을 격리시키는 법을 설명한다.  
*Chapter 5*, Testing Network Code, stub을 이용해 아직 만들어지지 않은 서버 부분을 가장하는 법을 배울 것이다.  
*Chapter 6*, Putting It All Together, 이전에 개발된 다른 부분들을 합쳐보고, 기능 테스트의 사용을 보여줄 것이다.  
*Chapter 7*, Code Coverage and Continuous Integration, 어떻게 코드 커버리지를 측정하는지와 지속적인 통합에 대해 보여줄 것이다.

---

TDD에서, 테스트를 작성하는 동안에는 실제 코드에 대해서는 생각하지 않아야 한다. 테스트 할 '단위 코드'가 그것을 어떻게 수행할 지가 아닌 무엇을 해야 하는지를 설명해야 한다. 테스트를 깨지 않은 채로 구현을 변경할 수 있어야 한다. 

이를 연습하기 위해, 책의 남은 부분에서 간단한 to-do 리스트 앱을 개발할 것이다. 이 앱은 의도적으로 지루하고 쉽다. 복잡한 구현이 아닌 TDD 워크플로에 집중하길 바란다. 흥미로운 앱은 이 책의 중요한 점 즉, TDD 하는 법에서 관심을 분산하게 만들 것이다.

이 장에서는 우리가 만들 앱이 최종적으로 어떻게 보이는지 알려줄 것이다.

> The task list view  
> The task detail view  
> The task input view  
> The structure of an app  
> Getting started with Xcode  
> Setting up useful Xcode behaviors for testing  

The task list view 

![task list view](images/1708163308.png)
