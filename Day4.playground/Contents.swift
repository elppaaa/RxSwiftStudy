//: A UIKit based Playground for presenting user interface

import UIKit
import PlaygroundSupport
import RxSwift
import RxCocoa


/// 예제를 묶기 위한 함수
public func example(of description: String, action: () -> Void) {
  print("\n--- Example of:", description, "---")
  action()
}

/// 에러 타입 열거형.
enum MyError: Error {
  case anError
}

/// subscriber 라벨링을 위한 함수.
func print<T: CustomStringConvertible>(label: String, event: Event<T>) {
  print(label, event.element ?? event.error ?? event)
}

//Subject
/*
 개발에서 주로 필요한것은 실시간으로 Observable 에 새로운 값을 수동으로 추가하고
 subscriber에게 방출하는 것이다.
 Observable 이자 Observer 인 것이 필요한데, 이것이 Subject 이다.
 
 PublishSubject 는 받은 정보를 가능하면 먼저 수정한 다음에 subscriber 에게 배포한다.
 아래 예제에서는 해당 정보가 String 타입이며, 받는 정보 / 배포하는 정보 모두 String 타입이다.
 
 PublishSubject 는 현재 subscriber 에게만 이벤트를 방출하기 때문에 구독되어 있는 상태가 아니라면,
 해당 값을 얻을 수 없다.
 
 .on(.next(_:)) 는 새로운 .next 이벤트를 subject 에게 삽입하고 이벤트 내의 값들을 파라미터로 통과시킨다.
 subject.on(.next(_:)) 와 같이 표현 하였고, 동일한 기능을 축약형으로 subject.onNext(_:) 할 수 있다.
 */
example(of: "PublishSubject") {
  let subject = PublishSubject<String>()
  subject.onNext("Is anyone listening?")
  
  let subscriptionOne = subject
    .subscribe(onNext: { string in
      print(string)
    })
  
  subject.on(.next("1"))
  subject.onNext("2")
}



/*
 Subject = Observable + Observer (기능이 그렇다.)
 subject는 .next 이벤트를 받고, 이런 이벤트를 수신할 때마다 subscriber 에게 방출하ㅁ.
 RxSwift에는 4 가지 타입의 subject가 존재함.
 
 PublishSubject: 빈 상태로 시작하여 새로운 값만을 subscriber 에게 방출.
 BehaviorSubject: 하나의 초기값을 가진 상태로 시작하여, 새로운 subscriber 에게 초기값 또는 최신값을 방출.
 RelaySubject: 버퍼를 두고 초기화 하며, 버퍼 사이즈 만큼의 값들을 유지하면서 새로운 subscriber 에게 방출.
 Variable: BehaviorSubject 를 래핑하고, 현재의 값을 상태로 보존함. 가장 최신 / 초기 값만을 새로운 subscriber 에게 방출.
 
 Subject가 종료되었을 때에 존재하는 구독자에게만 종료 이벤트를 줄 뿐만 아니라
 이후에 구독한 subscriber 에게도 종료 이벤트를 알려줌.
 */


example(of: "PublishSubject") {
  let subject = PublishSubject<String>()
  subject.onNext("Is anyone listening?")
  
  let subscriptionOne = subject
    .subscribe(onNext: { string in
      print("1)", string)
    })
  subject.on(.next("1"))
  subject.onNext("2")
  
  let subscriptionTwo = subject
    .subscribe({ event in
      print("2)", event.element ?? event)
    })
  // subscriptionOne, subscriptionTwo 모두 구족 중이므로, 두번 출력된다.
  subject.onNext("3")
  subscriptionOne.dispose()
  
  // subscriptionOne 을 dispose 하고, subjectㅇ에 4를 추가하면
  subject.onNext("4")
  subject.onCompleted()
  subject.onNext("5")
  subscriptionTwo.dispose()
  
  let disposeBag = DisposeBag()
  
  //disposeBag 호출된 이후 onNext 는 호출되지 않음.
  subject.subscribe {
    print("3)", $0.element ?? $0)
  }
  .disposed(by: disposeBag)
  subject.onNext("?")
}

// BehaviorSubject
/*
 Behavior Subject 는 뷰를 항상 최신의 데이터로 미리 채우기에 용이하다.
 */
example(of: "BehaviorSubject") {
  
  
  // subject 생성. subject는 항상 최신의 값을 방출하기 때문에 초기값이 존재해야 함.
  let subject = BehaviorSubject(value: "Initial value")
  let disposeBag = DisposeBag()
  
  subject.onNext("X")
  subject.subscribe {
    print(label: "1)", event: $0)
  }
  .disposed(by: disposeBag)
  
  subject.onError(MyError.anError)
  
  subject.subscribe {
    print(label: "2)", event: $0)
  }
  .disposed(by: disposeBag)
  // 두개의 구독 (label 1, 2)에 대해 error 가 표시되게 된다.
}

// Relay Subject
/*
 Relay Subject 생성시 선택한 특정 크기까지, 방출하는 요소를 일시적으로 캐시 / 버퍼.
 그런 다음 해당 버퍼를 새 구독자에게 방출함.
 
 RelaySubject 에서 버퍼들은 메모리가 가지고 있기 때문에 메모리를 크게 차지하는 값들은 큰 사이즈로 버퍼를 가지는 것에 부담이 있다.
 
 아래 예시 에서도 1, 2, 3 요소가 subject에 추가되었으나, bufferSize에 맞게 2개(2, 3)만 보여진다.
 subject.onNext("4") 에서 보면, 기존 구독자 1, 2는 새롭게 추가된 값인 4를 받고, 새 구독자인 3은 
 버퍼 사이즈 2개 만큼의 최근 값인 3, 4를 받게 된다.
 
 subject.onError(MyError.anError) 를 추가하게 되면, 에러를 통해 종료되었음에도, 새 구독자에게 값을 보내준다.
 subject가 종료되었음에도 버퍼는 돌아다니고 있기 때문에, error 를 추가한 다음 dispose하여 이벤트의 재 방출을 막아야 한다.
 
 subejct에 명시적으로 dispose를 호출하게 되면 새로운 구독자는 에러 이벤트만 받는다. */

example(of: "RelaySubject") {
  let subject = ReplaySubject<String>.create(bufferSize: 2)
  let disposeBag = DisposeBag()
  
  subject.onNext("1")
  subject.onNext("2")
  subject.onNext("3")
  
  subject.subscribe {
    print(label: "1)", event: $0)
  }
  .disposed(by: disposeBag)
  
  subject.subscribe {
    print(label: "2)", event: $0)
  }
  .disposed(by: disposeBag)
  
  subject.onNext("4")
  subject.subscribe {
    print(label: "3)", event: $0)
  }
  .disposed(by: disposeBag)
  
  subject.onError(MyError.anError)
  subject.dispose()
}
