> 스위프트 기본 문법을 이해하고 struct나 class, enum 타입을 만들 수 있다.

열거형은 연관된 값 그룹에 대한 일반적인 타입을 정의한다. 또, 값들을 type-safe한 방식으로 사용할 수 있게 한다.

c 언어에 친숙하다면, c의 enumeration이 연관된 이름을 integer 값의 set에 할당한다는 것을 알 것이다. swift에서의 열거형은 보다 유연하고, 각각의 case가 값을 가질 필요도 없다. 각각의 enumeration case에 값("raw" value로 알려진)이 설정될 경우, string, character 또는 정수, 부동소수점 타입도 값이 될 수 있다.

대신, enumeration case들은 다른 언어들의 집합이나 variants의 동작처럼, 각각 다른 타입의 값들이 저장될 case의 associated values를 명시할 수 있다. 연관된 값들의 공통 집합을 enumeration의 일부로 정의할 수 있다. 각각은 서로 다른 값의 집합을 갖는다.

열거형은 swift에서 일급 타입이다. 전통적으로 클래스에서 쓰이는 기능들을 지원한다.  computed properties를 통해 열거형의 현재 값에 대한 추가 정보를 제공하고, instance method를 통해 열거형이 나타내는 값과 관련된 기능을 제공한다. 또한, 생성자를 정의할 수 있고, 프로토콜을 따르게 할 수 있다.

### 1. Enumeration Syntax
```swift
enum CompassPoint {
    case north
    case south
    case east
    case west
}
enum Planet {
    case mercury, venus, earth, mars, jupiter, saturn, uranus, neptune
    // 늘어 써도 됨
}
var directionToHead = CompassPoint.west 
print(directionToHead) // west
directionToHead = .east // 어떤 변수가 열거형으로 선언되면, (.)으로 다른 case를 정할 수 있다.
print(directionToHead) // east
```

### Matching Enumeration Values with a Switch Statement
```swift
// 각각의 열거형 값을 `switch`문으로 짝을 맞출 수 있다.
directionToHead = .south
switch directionToHead {
case .north:
    print("Lots of planets have a north")
case .south:
    print("Watch out for penguins")
case .east:
    print("Where the sun rises")
case .west:
    print("Where the skies are blue")
}
// Prints "Watch out for penguins"
```

### 2. Associated-Values
```swift
enum Barcode {
    case upc(Int, Int, Int, Int)
    case qrCode(String)
}
var productBarcode = Barcode.upc(8, 85909, 51226, 3)
print(productBarcode) // upc(8, 85909, 51226, 3)
productBarcode = .qrCode("ABCDEFGHIJKLMNOP")
print(productBarcode) // qrCode("ABCDEFGHIJKLMNOP")

// associated values은 switch문의 일부로 추출될 수 있다.
// let 이나 var를 쓰면 case의 body에서 사용할 수 있다.
switch productBarcode {
case .upc(let numberSystem, let manufacturer, let product, let check):
    print("UPC: \(numberSystem), \(manufacturer), \(product), \(check).")
case .qrCode(let productCode):
    print("QR code: \(productCode).")
}

// 모든 associated values를 상수나 변수로 추출하려면, 
// let이나 var를 case 이름 앞에 적으면 된다.
switch productBarcode {
case let .upc(numberSystem, manufacturer, product, check):
    print("UPC : \(numberSystem), \(manufacturer), \(product), \(check).")
case let .qrCode(productCode):
    print("QR code: \(productCode).")
}
```

### 3. Raw Values
서로 다른 타입들의 연관값을 저장하는 열거형을 선언하는 [Associated Values](#Associated-Values)과 달리 같은 타입의 기본값을 제공하는 방법이 있다.

```swift
enum ASCIIControlCharacter: Character {
    case tab = "\t"
    case lineFeed = "\n"
    case carriageReturn = "\r"
}
// Raw values can be strings, characters, or any of the integer or floating-point number types
// 각각의 raw value는 열거형 선언에서 유일해야 한다.
```

#### Implicitly Assigned Raw Values
```swift
enum Planet: Int {
    case mercury = 1, venus, earth, mars, jupiter, saturn, uranus, neptune
}
print(Planet.mercury.rawValue) // 1
print(Planet.earth.rawValue) // 3
enum Planet2: Int {
    case mercury, venus, earth, mars, jupiter, saturn, uranus, neptune
}
print(Planet2.mercury.rawValue) // 0
print(Planet2.earth.rawValue) // 2

enum CompassPoint: String {
    case north, south, east, west
}
print(CompassPoint.north.rawValue) // north
```

#### Initializing from a Raw Value
raw-value 타입으로 정의한 경우, 자동으로 생성자를 받는다. raw value 타입의 값을 받고, 열거형의 케이스 또는 `nil`을 돌려준다. 해당 열거형을 새 인스턴스를 만드는 데에 사용할 수 있다.
```swift
enum Planet: Int {
    case mercury = 1, venus, earth, mars, jupiter, saturn, uranus, neptune
}
let planet = Planet.init(rawValue: 7)
print(planet!) // uranus
```

### 4. Recursive Enumerations
열거형은 다른 열거형의 인스턴스를 하나 또는 다수 케이스의 연관 값으로 가질 수 있다. `indirect` 키워드를 사용해 컴파일러에게 알려줄 수 있다.

```swift
// 특정 케이스 또는 열거형 전체에 적용할 수 있다.
enum ArithmeticExpression {
    case number(Int)
    indirect case addition(ArithmeticExpression, ArithmeticExpression)
    indirect case multiplication(ArithmeticExpression, ArithmeticExpression)
}
indirect enum ArithmeticExpression {
    case number(Int)
    case addition(ArithmeticExpression, ArithmeticExpression)
    case multiplication(ArithmeticExpression, ArithmeticExpression)
}
let five = ArithmeticExpression.number(5) // number(5)
let four = ArithmeticExpression.number(4) // number(4)
let sum = ArithmeticExpression.addition(five, four) 
// addition(__lldb_expr_41.ArithmeticExpression.number(5), __lldb_expr_41.ArithmeticExpression.number(4))
let product = ArithmeticExpression.multiplication(sum, ArithmeticExpression.number(2))
// multiplication(__lldb_expr_43.ArithmeticExpression.addition(__lldb_expr_43.ArithmeticExpression.number(5), __lldb_expr_43.ArithmeticExpression.number(4)), __lldb_expr_43.ArithmeticExpression.number(2))

func evaluate(_ expression: ArithmeticExpression) -> Int {
    switch expression {
    case let .number(value):
        return value
    case let .addition(left, right):
        return evaluate(left) + evaluate(right)
    case let .multiplication(left, right):
        return evaluate(left) * evaluate(right)
    }
}
print(evaluate(product)) // 18
```
