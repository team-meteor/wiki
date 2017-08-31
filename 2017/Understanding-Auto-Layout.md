# Understanding Auto Layout

오토 레이아웃은 해당 뷰의 constraints에 근거해, 뷰계층에 있는 모든 뷰의 크기와 위치를 동적으로 계산한다. 예를 들어, 버튼을 구속할 수 있고, 버튼은 이미지뷰의 가로 방향 가운데로 정렬된다. 또,  버튼의 윗부분이 이미지뷰의 밑부분 8point 아래로 항상 유지된다. 이미지뷰의 크기나 위치가 변하면 버튼의 위치도 자동으로 이에 맞춰진다.

디자인에 대한 구속 기반의 접근은 유저 인터페이스를 내부, 외부 변화에 동적으로 대응할 수 있게 한다.

### External Changes
외부 변화는 슈퍼뷰의 크기나 모양이 변할 때 발생한다. 각각에 변화에 따라 가용한 공간을 가장 잘 쓰도록 뷰계층의 레이아웃을 갱신해야 한다. 다음은 일반적인 외부 변화의 원인들이다.

- 사용자가 윈도우의 크기를 바꾼다(OS X)
- 사용자가 아이패드의 Split View 에 진입하거나 빠져나온다(iOS)
- 사용자가 기기를 회전시킨다(iOS)
- active call과 audio recording 바가 생기거나 없어진다(iOS)
- 다른 크기 클래스를 지원할 때
- 다른 스크린 사이즈를 지원할 때

대부분의 변화는 런타임에 발생하고, 앱이 동적으로 대응해야 한다. 이외의 다른 화면 크기 지원 같은 경우는 다양한 환경에 적응하는 앱을 나타낸다. 일반적으로 런타임에 화면 크기가 변하지 않지만, 적응형 인터페이스를 만드는 것은 앱이 여러 기기에서도 동일하게 동작하게 한다. 또한, 오토 레이아웃은 iPad의 Slide Over, Split View를 구성하는 주요 요소이다.

### Internal Changes
내부 변화는 유저 인터페이스 내의 뷰나 컨트롤러의 사이즈가 변경될 때 발생한다.

다음은 일반적인 내부 변화의 원인들이다.
- 앱의 변화에 따라 표시되는 내용
- 앱이 국제화를 지원한다.
- 앱이 Dynamic Type을 지원한다.

앱의 컨텐츠가 변하면, 새로운 컨텐츠는 이전과는 다른 레이아웃이 필요하다. 이는 텍스트나 이미지를 보여주는 앱에서 흔하게 발생한다. 예를 들어, 뉴스앱은 각각의 기사의 사이즈에 대응해야 한다. 비슷하게 사진 콜라주는 넓은 길이의 이미지 크기와 원래 크기를 다뤄야 한다.

국제화는 앱이 다른 언어, 지역, 문화에도 적응할 수 있게 만드는 과정이다.  국제화 된 앱의 레이아웃은 이러한 차이점을 고려하여 앱이 지원하는 모든 언어 및 지역에서 올바르게 표시되어야한다.

국제화는 레이아웃에 대한 세 가지 주요 영향을 갖는다. 첫째, 유저 인터페이스를 다른 언어로 번역할 때, 라벨에는 다른 양의 공간이 필요하다. 독일어의 경우 일반적으로 영어보다 꽤 많은 공간이 필요하다. 일본어는 반대이다.

둘째, 언어가 바뀌지 않더라도 지역에 따라서 날짜나 숫자 표시 방식이 바뀔 수 있다. 언어 변경에 비해 일반적으로 사소한 변경이지만, 유저 인터페이스는 여전히 이 작은 변화에 대응해야 한다.

세번째, 언어 변경은 텍스트 크기뿐만 아니라 레이아웃의 조직에도 영향을 줄 수 있다. 다른 언어는 다른 방향의 레이아웃을 사용한다. 영어의 경우 왼쪽에서 오른쪽이지만,  아라비아어나 히브리어는 반대다. 일반적으로 유저 인터페이스 요소의 순서는 이 순서에 맞춰야 한다. 만약 버튼이 영어에서는 오른쪽 밑에 있다면, 아라비아에서는 왼쪽 밑이어야 한다.

마지막으로, iOS 앱이 dynamic type을 지원한다면, 사용자는 글자 크기를 변경할 수 있다. 이는 문자가 있는 모든 요소의 높이와 넓이를 변경시킬 수 있다. 사용자가 앱 구동 중에 글자 크기를 바꾼다면 글자와 레이아웃 둘다 적응해야 한다.

### Auto Layout Versus Frame-Based Layout

유저 이터페이스를 레이아웃 하는 세 가지 주요 접근법이 있다. programmatically 레이아웃 할 수 있고, 외부 변화에 자동으로 대응하도록 autoresizing masks을 사용할 수 있고, Auto Layout을 이용할 수 있다.

전통적으로, 앱은 뷰계층에서 각각의 뷰의 프레임을 programmatically 유저 인터페이스를 레이아웃했다. 프레임은 상위뷰 좌표 체계에서 뷰의 origin, height, and width 이다.

![frame](https://developer.apple.com/library/content/documentation/UserExperience/Conceptual/AutolayoutPG/Art/layout_views_2x.png)

유저 인터페이스를 레이아웃 하려면, 뷰계층에서 모든 뷰의 크기와 위치를 계산해야 한다. 그리고 변화가 발생하면 영향을 받는 모든 뷰의 프레임을 다시 계산해야 한다.

여러 면에서 programmatically 뷰의 프레임을 정의하는 것은 유연하고 강력하다. 변경이 발생하면 문자 그대로 원하는 것을 변경할 수 있다. 하지만 모든 변화를 관리해야 하기 때문에 단순한 유저 인터페이스 변화도 상당한 노력이 필요하다. 진정한 적응형 유저 인터페이스를 만드는 것은 어려움을 한 단계 더 증가 시킨다.

autoresizing masks은 이런 노력을 돕는다. autoresizing masks은 상위뷰가 변할 때 해당뷰 프레임의 변화를 정의한다. 이는 외부 변화에 적응하는 레이아웃 만들기를 간단하게 만든다.

하지만 autoresizing masks은 상대적으로 작은 부분만 지원한다. 일반적으로 복잡한 UI의 경우 programmatic 변경으로 autoresizing masks를 보완해야 한다. 또, autoresizing masks은 외부 변화에마 적응한다. 내부 변화를 지원하지 않는다.

autoresizing masks은 programmatic 레이아웃의 반복적인 개선이지만, 오토레이아웃은 완전히 다른 패러다임이다. 뷰의 프레임을 생각하는 대신, 그들의 관계를 생각하자.

![auto](https://developer.apple.com/library/content/documentation/UserExperience/Conceptual/AutolayoutPG/Art/layout_constraints_2x.png)

특별한 행동에 대한 구속의 집합을 디자인하는 논리는 절차 또는 객체 지향 코드를 적는 데에 쓰이는 논리와는 완전히 다르다. 다행히 오토레이아웃을 마스터하는 것과 다른 프로그래밍 작업을 마스터하는 것은 다르지 않다. 두 가지 단계가 있다. 첫 번째는 구속 기반 레이아웃 밑의 논리를 이해하는 것이고, 다음은 API를 배우는 것이다. 여러분은 다른 프로그래밍 작업에서 이 단계를 이미 수행했다. 오토레이아웃도 예외가 아니다.

이 가이드는 나머지는 쉽게 오토레이아웃으로 전환하는 것을 돕도록 만들어졌다. [Auto Layout Guide: Auto Layout Without Constraints](https://developer.apple.com/library/content/documentation/UserExperience/Conceptual/AutolayoutPG/AutoLayoutWithoutConstraints.html#//apple_ref/doc/uid/TP40010853-CH8-SW1)은 UI 기반 오토레이아웃을 만드는 것을 단순화하는 고수준 추상화를 설명한다. [Auto Layout Guide: Anatomy of a Constraint](https://developer.apple.com/library/content/documentation/UserExperience/Conceptual/AutolayoutPG/AnatomyofaConstraint.html#//apple_ref/doc/uid/TP40010853-CH9-SW1)은 오토레이아웃과의 이론적인 배경을 제공한다. [Auto Layout Guide: Working with Constraints in Interface Builder](https://developer.apple.com/library/content/documentation/UserExperience/Conceptual/AutolayoutPG/WorkingwithConstraintsinInterfaceBuidler.html#//apple_ref/doc/uid/TP40010853-CH10-SW1)는 오토레이아웃을 만드는 도구에 대해 설명하고, [Auto Layout Guide: Programmatically Creating Constraints](https://developer.apple.com/library/content/documentation/UserExperience/Conceptual/AutolayoutPG/ProgrammaticallyCreatingConstraints.html#//apple_ref/doc/uid/TP40010853-CH16-SW1)와 [Auto Layout Guide: Stack Views](https://developer.apple.com/library/content/documentation/UserExperience/Conceptual/AutolayoutPG/LayoutUsingStackViews.html#//apple_ref/doc/uid/TP40010853-CH3-SW1)는 API를 자세히 설명한다. 마지막으로 [Auto Layout Guide: Stack Views](https://developer.apple.com/library/content/documentation/UserExperience/Conceptual/AutolayoutPG/LayoutUsingStackViews.html#//apple_ref/doc/uid/TP40010853-CH3-SW1) 넓은 범위의 예제를 제공하고, [Auto Layout Guide: Types of Errors](https://developer.apple.com/library/content/documentation/UserExperience/Conceptual/AutolayoutPG/TypesofErrors.html#//apple_ref/doc/uid/TP40010853-CH22-SW1)는 뭔가 잘못됐을 때의 조언과 해결도구를 제공한다.
