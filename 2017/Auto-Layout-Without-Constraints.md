# Auto Layout Without Constraints

스택뷰는 constraints의 복잡함 없이 오토레이아웃을 사용할 수 있는 쉬운 방법을 제공한다. 하나의 스택뷰는 UI의 row 또는 column을 정의한다. 스택뷰는 그것의 프로퍼티에 따라 뷰를 배열한다.

- axis: (UIStackView only) 스택뷰의 방향을 정의한다. 수직 또는 수평
- orientation: (NSStackView only) 스택뷰의 방향을 정의한다. 수직 또는 수평
- distribution: axis 따른 뷰의 레이아웃을 정의한다.
- alignment: 스택뷰의 axis에 수직인 뷰들의 레이아웃을 정의한다.
- spacing: 이웃 뷰들과의 간격을 결정한다.

스택뷰를 사용하려면, 수직 또는 수평 스택뷰 중 하나를 캔버스에 끌어놔야 한다. 그 다음 컨텐츠를 스택뷰에 넣으면 된다.

객체가 intrinsic 크기를 가지고 있다면, 스택뷰에서 그 크기로 나타날 것이다. 만약 없다면, 인터페이스 빌더가 기본 크기를 제공한다. 객체의 크기를 변경할 수 있고, 인터페이스 빌더는 사이즈를 유지하기 위해 constraints를 더할 수 있다.

레이아웃을 미세 조정하려면, Attributes inspector를 이용해 스택뷰의 프로퍼티를 수정할 수 있다. 예를 들어 다음 예는 8 포인트의 spacing과 Fills Equally distribution.

![stackview1](https://developer.apple.com/library/content/documentation/UserExperience/Conceptual/AutolayoutPG/Art/IB_StackView_Simple_2x.png)

스택뷰는 content-hugging와 compression-resistance 프로퍼티로 조정된 레이아웃을 기반으로 삼을 수 있다. Size inspector에서 수정할 수 있다.

> 정렬된 뷰에 직접 constraints를 더해서 레이아웃을 수정할 수 있다. 하지만 가능한 충돌을 피하고 싶을 것이다. 일반적인 경험에 따르면, 주어진 치수에 대해 뷰의 크기가 intrinsic content size로 돌아간다면 , 해당 치수에 대해 안전하게 constraint를 추가할 수 있다. constraints 충돌에 대한 추가정보는 [Unsatisfiable](https://developer.apple.com/library/content/documentation/UserExperience/Conceptual/AutolayoutPG/ConflictingLayouts.html#//apple_ref/doc/uid/TP40010853-CH19-SW1).

부가적으로, 스택뷰를 중첩해서 좀더 복잡한 레이아웃을 만들 수 있다.

![stackview2](https://developer.apple.com/library/content/documentation/UserExperience/Conceptual/AutolayoutPG/Art/IB_StackView_NestedStacks_2x.png)

일반적으로 최대한 많은 뷰를 스택뷰로 관리하자. 스택뷰로 원하는 목적이 불가능할 때, constraints를 만들자.

