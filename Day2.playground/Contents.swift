
import UIKit
import PlaygroundSupport
import RxSwift
import RxCocoa

/// 예시를 작성하기 위한 함수.
public func example(of description: String, action: () -> Void) {
  print("\n--- Example of:", description, "---")
  action()
}


/// 비동기적으로 데이터를 처리함
/// just, of, from 을 이용한 기본 예시

/// Observable.~~~ 은 데이터를 어떻게 흘려 보낼 것인지에 대해 작성 (데이터의 방출을 정의)
/// 이후 subscribe, bind 와 같은 함수는 들어오는 데이터를 어떻게 처리할 것인지. (방출되는 데이터의 처리)의
/// subscribe 이전에는 그저 Observable 클래스에 감싸져 있는 상태.
/// subscribe 이후 데이터가 흐름.

example(of: "just of, from") {
  let one = 1
  let two = 2
  let three = 3
  
  // Create Observable Object
  let observable1 = Observable.just(one)
  print("Observable 1 - just(Int) ")
  // Subscribe Observable Sequence
  observable1.subscribe(onNext: { print($0) })
  print()
  
  let observable2 = Observable.of(one, two, three)
  print("Observable 2 - of(...Int) ")
  observable2.subscribe(onNext: { print($0) })
  print()

  let observable3 = Observable.of([one, two, three])
  print("Observable 3 - of([Int]) ")
  observable3.subscribe(onNext: { print($0) })
  print()

  let observable4 = Observable.from([one, two, three])
  print("Observable 4 - from([Int]) ")
  observable4.subscribe(onNext: { print($0) })
  print()
}

/// Iterator
/// Swift의 기본 iterator

example(of: "Swift Iterator") {
  let sequence = 0..<3
  var iterator = sequence.makeIterator()
  while let n = iterator.next() { print(n) }
}

/// Subscribe
/// 이벤트를 통해 값이 순서대로 넘어오고, 마지막에는 completed로 종료됨.
/// .subscribe는 @escaping 클로저로 Int 타입을 Event로 갖는다.
/// .subscribe 는 Disposable을 반환한다.
/// 출력된 값을 보면 Observable은 각 요소에 대해 .next 이벤트를 방출하고,
/// 최종적으로 .completed 를 방출한다.

example(of: "subscribe") {
  let one = 1
  let two = 2
  let three = 3
  
  /// Event 처리
  print("Print Event")
  let observable = Observable.of(one, two, three)
  observable.subscribe({ event in
    print(event)
  })
  
  print("\n")
  
  /// .onNext Event 처리1
  print("Print .next Element")
  observable.subscribe { event in
    if let element = event.element {
      print(element)
    }
  }
  
  print("\n")
  
  /// .onNext Event 처리2
  print("Print Observable onNext")
  observable.subscribe(onNext: { element in
    print(element)
  })
}

/// Event의 Case별 처리
/// 비어있으므로 Element는 출력되지 않음.
/// onNext, onCompleted, onError 를 매개변수로 처리할 수 있음.

example(of: "empty") {
  let observable = Observable<Void>.empty()
  observable.subscribe(
    onNext: { element in print(element) },
    onCompleted: { print("Completed") }
  )
}

/// never인 상태에서는 아무것도 출력되지 않음.
/// .next, .complete 모두 출력되지 않음.
example(of: "never") {
  let observable = Observable<Any>.never()
  observable.subscribe(
    onNext: { element in
      print(element)
    },
    onCompleted: {
      print("Completed")
    })
}


/// ragne
example(of: "range") {
  let observable = Observable<Int>.range(start: 1, count: 10)
  observable.subscribe(onNext: { i in
    let n = Double(i)
    let fibonacci = Int(((pow(1.61803, n) - pow(0.61803, n)) / 2.23606).rounded())
    print(fibonacci)
  })
}
