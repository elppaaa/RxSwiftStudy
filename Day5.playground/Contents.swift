import UIKit
import RxSwift
import RxCocoa


// ignoring operators
/*
 .next event 무시 .completed, .error 같은 정지 이벤트는 허용.
 String 값을 뱉는 Subject와 DisposeBag을 만듬.
 strikes subject 를 구독. 구독전에 .ignoreElements() 를 넣는다면,
 completed 시에 출력.
 */
example(of: "ignore Elements") {
  let strikes = PublishSubject<String>()
  let disposeBag = DisposeBag()
  
  strikes.ignoreElements()
    .subscribe { event in
      print(event, "You're out!")
    }
    .disposed(by: disposeBag)
  
  strikes.onNext("X")
  strikes.onNext("X")
  strikes.onNext("X")
  
  strikes.onCompleted()
}


// element(at:)
/*
 요소들 중, at 번째 요소를 방출한다.
 아래 example 에서도, 2번째 요소인 "Element 2" 가 출력된다.
 */
example(of: "element at") {
  let strikes = PublishSubject<String>()
  let disposeBag = DisposeBag()
  
  strikes.element(at: 2)
    .subscribe(onNext: { event in
      print(event, "You're out!")
    })
    .disposed(by: disposeBag)
  
  strikes.onNext("Element 0")
  strikes.onNext("Element 1")
  strikes.onNext("Element 2")
}

// filter(of:)
/*
 ignoreElements element(at:) 은 observable 의 요소들을 필터링 하여 방출.
 filter 은 필터링 요구사항이 한 가지 이상일 때 사용할 수 있음.
 
 sequence 에서 2로 나누어 떨어지는 요소들만 filter에서 걸려 subscribe로 전달된다.
 */

example(of: "filter") {
  let disposeBag = DisposeBag()
  
  Observable.of(1, 2, 3, 4, 5, 6)
    .filter { int -> Bool in
      int % 2 == 0
    }
    .subscribe(onNext: {
      print($0)
    })
    .disposed(by: disposeBag)
}

// skip
/*
 초반 n개의 요소를 skip하게 해준다.
 
 A, B, C 는 skip되고 뒤의 D, E, F가 출력된다.
 */

example(of: "skip") {
  let disposeBag = DisposeBag()
  
  Observable.of("A", "B", "C", "D", "E", "F")
    .skip(3)
    .subscribe(onNext: {
      print($0)
    })
    .disposed(by: disposeBag)
}

// skipWhile
/*
 해당 조건이 false가 될때까지 skip하고,
 skip 된 이후는 지속적으로 방출한다.
 
 2까지는 true이기 때문에 넘어가지 않고, 3부터 false로 방출됨.
 */

example(of: "skipWhile") {
  let disposeBag = DisposeBag()
  
  Observable.of(2, 2, 3, 4, 4)
    .skip(while: { int -> Bool in
      int % 2 == 0
    })
    .subscribe(onNext: {
      print($0)
    })
    .disposed(by: disposeBag)
}

// skip(until:)
/*
 until 매개변수인 Observable이 방출되기 전까지 무시된다.
 따라서 subject의 방출이 무시되다가,
 trigger.onNext("X")가 방출되면 이후 subject.onNext("C") 가 방출된다.
 */
example(of: "skipUntil") {
  let disposeBag = DisposeBag()
  
  let subject = PublishSubject<String>()
  let trigger = PublishSubject<String>()
  
  subject
    .skip(until: trigger)
    .subscribe(onNext: {
      print($0)
    })
    .disposed(by: disposeBag)
  
  subject.onNext("A")
  subject.onNext("B")
  
  trigger.onNext("X")
  subject.onNext("C")
}


//take
/*
 take 는 skipping과는 반대되는 개념이다.
 take 개수만큼의 요소를 방출한다.
 아래는 take(3) 이므로, 1, 2, 3 이 출력된다.
 */

example(of: "take") {
  let disposeBag = DisposeBag()
  
  Observable.of(1, 2, 3, 4, 5, 6)
    .take(3)
    .subscribe(onNext: {
      print($0)
    })
    .disposed(by: disposeBag)
}

// take(while:), enumerated
/*
 enumerated: index, value 두개의 인자로 방출함.
 take(while:) take를 진행하는데(방출), 언제까지에 대한 조건이 while에 들어감.
 이후, while 에서 event의 element(값) 만을 취해 subscribe 진행한다.
 */
example(of: "takeWhile") {
  let disposeBag = DisposeBag()
  
  Observable.of(2, 2, 4, 4, 6, 6)
    .enumerated()
    .take(while: { index, value in
      value % 2 == 0 && index < 3
    })
    .map { $0.element }
    .subscribe(onNext: {
      print($0)
    })
    .disposed(by: disposeBag)
}

// take(until:)
/*
 take(until:)은 skip(until:)과 반대로 동작한다.
 until에 해당하는 Observable이 구독되기 전까지의 이벤트값만 받게 된다.
 trigger에 값이 추가된 후, subject의 값은 방출되지 않는다.
 */

example(of: "takeUntil") {
  let disposeBag = DisposeBag()
  
  let subject = PublishSubject<String>()
  let trigger = PublishSubject<String>()
  
  subject
    .take(until: trigger)
    .subscribe(onNext: {
      print($0)
    })
    .disposed(by: disposeBag)
  
  subject.onNext("1")
  subject.onNext("2")
  
  trigger.onNext("X")
  subject.onNext("3")
}
