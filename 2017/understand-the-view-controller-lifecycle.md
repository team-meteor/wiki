# Understand the View Controller Lifecycle
> [Work with View Controllers
](https://developer.apple.com/library/content/referencelibrary/GettingStarted/DevelopiOSAppsSwift/WorkWithViewControllers.html) 일부 번역

UIViewController 클래스 또는 서브 클래스의 객체는 뷰계층을 관리하는 메서드를 포함한다. iOS는 뷰컨트롤러의 상태가 변하는 적절한 시점에 자동으로 이들 메서드들을 호출한다. 뷰컨트롤러의 서브 클래스는 만들 때, UIViewController에 정의된 메서드들을 상속하게 되고, 각각의 메서드에 대해 원하는 동작을 추가할 수 있다. 시스템이 이들은 언제 호출할지 아는 것은 중요하다. 그래야 필요한 작업 중에 적절한 순서에 뷰를 준비하고, 해제할 수 있다.

An object of the UIViewController class (and its subclasses) comes with a set of methods that manage its view hierarchy. iOS automatically calls these methods at appropriate times when a view controller transitions between states. When you create a view controller subclass (like the ViewController class you’ve been working with), it inherits the methods defined in UIViewController and lets you add your own custom behavior for each method. It’s important to understand when the system calls these methods, so you can set up or tear down the views you’re displaying at the appropriate step in the process—something you’ll need to do later in the lessons.

![life-cycle](https://developer.apple.com/library/content/referencelibrary/GettingStarted/DevelopiOSAppsSwift/Art/WWVC_vclife_2x.png)

iOS calls the UIViewController methods as follows:

`viewDidLoad()` : 뷰컨트롤러의 content view(최상위뷰)가 생성되거나 스토리보드에서 로드될 때 불린다. 이 메서드가 호출될 시점에 뷰 컨트롤러의 outlet은 유효한 값을 가지는 것이 보장된다. 뷰컨트롤러에 필요한 추가적인 setup을 수행할 때 사용하자. 일반적으로 컨텐츠뷰가 처음 생성될 때, 딱 한 번 불린다. 하지만, 뷰컨트롤러가 처음 인스턴스화 될 때, 컨텐츠뷰가 반드시 생성되는 것은 아니다. 대신, 시스템 또는 다른 코드가 프로퍼티에 처음 접근할 때 lazy 하게 생성된다.

- viewDidLoad()—Called when the view controller’s content view (the top of its view hierarchy) is created and loaded from a storyboard. The view controller’s outlets are guaranteed to have valid values by the time this method is called. Use this method to perform any additional setup required by your view controller. Typically, iOS calls viewDidLoad() only once, when its content view is first created; however, the content view is not necessarily created when the controller is first instantiated. Instead, it is lazily created the first time the system or any code accesses the controller’s view property.

`viewWillAppear()` : 컨텐츠뷰가 뷰계층에 추가되기 바로 직전에 호출된다. 컨텐츠뷰가 스크린에 나타나기 바로 직전에 필요한 작업을 격발시킬 때 사용하자. 이름에도 불구하고, 시스템이 호출하기 때문에 실제로 컨텐츠뷰가 표시되는 것을 보장하지 않는다. 해당뷰는 다른 뷰에 의해 가려질 수 있다. 이 메서드는 단순히 컨텐츠뷰가 뷰계층에 이제 막 추가되는 것을 가리킨다.

- viewWillAppear()—Called just before the view controller’s content view is added to the app’s view hierarchy. Use this method to trigger any operations that need to occur before the content view is presented onscreen. Despite the name, just because the system calls this method, it does not guarantee that the content view will become visible. The view may be obscured by other views or hidden. This method simply indicates that the content view is about to be added to the app’s view hierarchy.

`viewDidAppear()` : 컨텐츠뷰가 뷰계층에 추가된 직후에 호출된다. 데이터를 받아오거나 애니메이션 보여주기 따위의 뷰가 화면에 나타나자마자 처리해야 할 작업을 격발시킬 때 사용하자. 이름에도 불구하고, 시스템이 호출하기 때문에 실제 컨텐츠뷰가 표시되는 것을 보장하지 않는다. 해당뷰는 다른 뷰에 의해 가려질 수 있다. 이 메서드는 단순히 컨텐츠뷰가 뷰계층에 추가되었다는 것을 가리킨다.

- viewDidAppear()—Called just after the view controller’s content view has been added to the app’s view hierarchy. Use this method to trigger any operations that need to occur as soon as the view is presented onscreen, such as fetching data or showing an animation. Despite the name, just because the system calls this method, it does not guarantee that the content view is visible. The view may be obscured by other views or hidden. This method simply indicates that the content view has been added to the app’s view hierarchy.

`viewWillDisappear()` : 뷰컨트롤러의 컨텐츠뷰가 뷰계층에서 삭제되기 바로 직전에 호출된다. 변경사항을 반영하거나 first responder 상태 해제 따위의 cleanup 작업을 수행할 때 사용하자. 이름에도 불구하고, 시스템은 컨텐츠뷰가 사라지거나 가려져도 이 메서드를 호출하지 않는다. 컨텐츠뷰가 뷰계층에서 삭제될 때만 호출된다.

- viewWillDisappear()—Called just before the view controller’s content view is removed from the app’s view hierarchy. Use this method to perform cleanup tasks like committing changes or resigning the first responder status. Despite the name, the system does not call this method just because the content view will be hidden or obscured. This method is only called when the content view is about to be removed from the app’s view hierarchy.

`viewDidDisappear()` : 뷰컨트롤러의 컨텐츠뷰가 뷰 계층에서 삭제된 후에 호출된다. 추가적인 해제 작업을 수행할 때 사용하자. 이름에도 불구하고,  시스템은 컨텐츠뷰가 사라지거나 가려져도 이 메서드를 호출하지 않는다. 컨텐츠뷰가 뷰계층에서 삭제되고 난 후에만 호출된다.

- viewDidDisappear()—Called just after the view controller’s content view has been removed from the app’s view hierarchy. Use this method to perform additional teardown activities. Despite the name, the system does not call this method just because the content view has become hidden or obscured. This method is only called when the content view has been removed from the app’s view hierarchy.