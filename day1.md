# Day1

----

RxSwift란?

`ReactvieX`(이하 Rx). Microsoft에서 만든 반응형 프로그래밍을 위한 프레임워크. Rx의 특징으로 나오는 키워드는 observable, asynchronous, functional, … 

관찰 가능한 객체를 만들어 연결해주는, 비동기 처리를 도와주는 프레임워크라고 할 수 있다.

RxSwift는 이러한 reactive 프레임워크의 스위프트 버전이다. 

일반적으로 UI구성 요소들은 비동기로 처리되어야 한다. 데이터 주고받거나 처리하기 위해 화면이 멈추는 것은 적절한 사용자 환경이 아닐 것이다. 또 앱은 순서가 정해져있기보다는 사용자의 입력이나 환경에 의해 순서가 달라질 수도 있기 때문이다.

기본적으로 ios에서 비동기적으로 코드를 작성하는 방법은 NotificationCenter 사용, Delegate pattern, Grand Centeral Dispatch(GCD), Closures 등이 존재한다.

`RxSwift`에서는 기본적으로 `Observable`이라는 클래스를 이용해 데이터를 전달한다. 생성된 `Observable` 객체를 `operator`를 통해 연산하고, 필요시에 schedulers를 이용해 작업의 매커니즘을 추상화 한다. 관찰자(`Observer`)가 실시간으로 `ObservableType` 객체에 반응하고 처리할수 있도록 한다.

`ObservableType` 프로토콜은 `next`, `completed`, `error` 세가지 타입의 이벤트가 방출되며, `observer`는 이들 유형만 수신하여 처리한다. 

- `next`: 최신 / 다음 데이터를 __전달__하는 이벤트
- `completed`: 성공적으로 일련의 이벤트들을 종료시키는 이벤트. 즉, `Observable`(생산자)가 성공적으로 생명주기를 완료했으며, 추가적인 이벤트가 없음을 의미
- `error`: `Observable`이 에러를 발생하였으며, 추가적인 이벤트가 없음을 의미

---

UI Event와 같은 경우는 지속적으로 사용자의 동작에 Action이 수행되어야 한다. 예시로 기기의 가로 / 세로 모드에 반응하는 코드가 있다. (실제 코드가 아닌 느낌을 나타낸 것.)
```swift
UIDevice.rx.orientation
 	.subscribe(onNext: { current in
 		switch current {
 			case .landscape:
 				... re-arrange UI for landscape
 			case .portrait:
 				... re-arrange UI for portrait
 		}
 	})
```



UIDeviceOrientationDidChange observer를 추가하여, 방향 전환을 관리할 수 있는 callback method가 사용된다. 

해당 이벤트는 일시적인 이벤트가 아닌 사용자가 앱을 사용하는 동안 언제 일어날 지 모르는 이벤트이기 때문에 관찰하고 있어야 한다.

ObservableType과 Observable 클래스의 구현은 기본적인 흐름은 동일하지만 여러 기능들이 미리 구현되어 있다. 이러한 메서드를 `Operators`(연산자)라고 한다.



---

## Schedulers

`DispatchQueue`와 동일하게 사용되는 개념. 훨씬 강력하고 다루기 쉬움.

이미 여러가지 스케줄러가 정의되어 있어 사용하기만 하면 됨.



---

## App Architecture

앱 아키텍처와는 관련이 없지만, 조금더 유연한 설계가 가능한 것으로 생각함. Microsoft의 MVVM 아키텍쳐는 데이터 바인딩을 제공하는 플랫폼에서 이벤트 기반 소프트웨어 용으로 개발되었기 때문에 RxSwift와 MVVM 패턴은 아주 잘 맞는다. (ViewModel과 ViewController간의 바인딩.)



---

## RxCocoa

Rxswift 를 이요해 Cocoa 기반 프레임워크를 다룰 수 있도록 지원함. UI 관련 클래스(`UISwitch`, `UITextField`, …)를 `rx` 를 이용해 바인딩 할 수 있음.





## Ref

---

- https://github.com/pilgwon/RxSwift/blob/KoreanDocumentation/Documentation/Why.md
- https://github.com/fimuxd/RxSwift/blob/master/Lectures/01_HelloRxSwift/Ch.1%20Hello%20RxSwift.md

