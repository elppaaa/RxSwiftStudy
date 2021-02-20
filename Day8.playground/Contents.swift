import UIKit
import PlaygroundSupport
import RxSwift

// Observable.startWith(_:)
/*
 Observalbe 객체가 초기값을 갖도록 한다.
 1으로 시작해서 뒤이어 2, 3, 4가 나온다.
 */
example(of: "startWith") {
  let numbers = Observable.of(2, 3, 4)
  
  let observable = numbers.startWith(1)
  
  observable.subscribe(onNext: { print($0) })
}

// Observable.concat(_:)
/*
 두개의 sequence 를 하나로 합침.
 */

example(of: "Observable.concat") {
  let first = Observable.of(1, 2, 3)
  let second = Observable.of(4, 5, 6)
  
  let observable = Observable.concat([first, second])
  
  observable.subscribe(onNext: { print($0) })
}

example(of: "concat") {
  let germanCities = Observable.of("Berlin", "Munich", "Frankfurt")
  let spanishCities = Observable.of("Madrid", "Barcelona", "Valencia")
  
  let observable = germanCities.concat(spanishCities)
  observable.subscribe(onNext: { print($0) })
}

// concatMap(_:)
/*
 concatMap 은 각각의 sequence 가 다음 sequence 가 구독되기 전에 합쳐짐.
 
 아래 예제를 보면, 배열에 담겨있는 sequence 객체를 순서대로 꺼내고,
 concatMap 을 이용해 합쳐 observable 변수에 담는다.
 */

example(of: "concatMap") {
  let sequences = [
    "Germany": Observable.of("Berlin", "Munich", "Frankfurt"),
    "Spain": Observable.of("Madrid", "Barcelona", "Valencia")
  ]
  
  let observable = Observable.of("Germany", "Spain")
    .concatMap({ country in
      sequences[country] ?? .empty()
    })
  
  _ = observable.subscribe(onNext: { print($0) })
}

// MARK: - 합치기

// merge
/*
 
 merge() 는 obserbable 각각의 요소들이 도착하는 대로 받아서 방출한다.
 모든 내부 sequence 들이 완료되었을때, merge 된 observable 또한 완료된다.
 
 
 left, right 두개의 subject 를 생성하고, 이것을 observable 로 source 변수에 담는다.
 source:  Observable<Observable<String>>
 
 source.merge() 로 두개의 observable 을 합친다.
 observable: Observable<String>
 
 repeat - while 을 이용해 left / right 의 PublishSubject 를 이용해 데이터를 방출한다.
 */
example(of: "merge") {
  let left = PublishSubject<String>()
  let right = PublishSubject<String>()
  
  let source = Observable.of(left.asObservable(), right.asObservable())
  let observable = source.merge()
  
  // 위 두줄 대신 아래와 같이 작성하는 것이 조금 더 보기 좋은 것 같음.
  //  let observable = Observable.merge([left.asObservable(), right.asObservable()])
  let disposable = observable.subscribe(onNext: { print($0) })
  
  var leftValues = ["Berlin", "Munich", "Frankfurt"]
  var rightValues = ["Madrid", "Barcelona", "Valencia"]
  
  repeat {
    if arc4random_uniform(2) == 0 {
      if !leftValues.isEmpty {
        left.onNext("Left: " + leftValues.removeFirst())
      }
    } else if !rightValues.isEmpty {
      right.onNext("Right: " + rightValues.removeFirst())
    }
  } while !leftValues.isEmpty || !rightValues.isEmpty
  
  disposable.dispose()
}

// combineLatest
/*
 두개의 Observable 을 합쳐서 제공받는다.
 
 첫번째, left.onNext(_:) 를 호출했을 때는 멈추어 있고,
 right.onNext(_:) 도 1회 이상 호출 된 이후, 가장 최근 방출된 left/right 를 합쳐 방출된다.
 */

example(of: "combineLast") {
  let left = PublishSubject<String>()
  let right = PublishSubject<String>()
  
  let observable = Observable.combineLatest(left, right) { lastLeft, lastRight in
    "\(lastLeft) \(lastRight)"
  }
  
  let disposable = observable.subscribe(onNext: { print($0) })
  
  print("> Sending a value to Left")
  left.onNext("Hello, ")
  print("> Sending a value to Right")
  right.onNext("world")
  print("> Sending another value to Right")
  right.onNext("RxSwift")
  print("> Sending another value to Left")
  left.onNext("Have a good day,")
  
  disposable.dispose()
}

example(of: "combine user choice and value") {
  let choice: Observable<DateFormatter.Style> = Observable.of(.short, .long)
  let dates = Observable.of(Date())
  
  let observable = Observable.combineLatest(choice, dates) { (format, when) -> String in
    let formatter = DateFormatter()
    formatter.dateStyle = format
    return formatter.string(from: when)
  }
  
  observable.subscribe(onNext: { print($0) })
}

// zip
/*
 zip 에서 각각의 Observable이 방출되기를 기다린다.
 각각의 새 값으로 클로저를 호출하는데, 마지막의 Vienna 는 출력되지 않는다.
 observable 이 새 값을 방출할때까지 기다리다가, 둘 중 하나의 sequence 가 완료되면 zip 또한 완료된다.
 (더 긴 observable 이 남아있어도 이것을 기다리지는 않는 것.)
 */
example(of: "zip") {
  enum Weather {
    case cloudy, sunny
  }
  
  let left: Observable<Weather> = Observable.of(.sunny, .cloudy, .cloudy, .sunny)
  let right = Observable.of("Lisbon", "Copenhagen", "London", "Madrid", "Vienna")
  
  let observable = Observable.zip(left, right) { weather, city in
    return "It's \(weather) in \(city)"
  }
  
  observable.subscribe(onNext: { print($0) })
}

// MARK: - Triggers
// withLatestFrom
/*
 
 두개의 PublishSubject 를 생성한다.
 button.withLatestFrom(textField) 는 button 을 방출할때,
 textField 의 가장 마지막으로 방출된 요소를 방출시킨다.
 button 이 방출시킬 때, textField 의 latest element 가 방출되는 것.
 */
example(of: "withLatestFrom") {
  let button = PublishSubject<Void>()
  let textField = PublishSubject<String>()
  
  let observable = button.withLatestFrom(textField)
  _ = observable.subscribe(onNext: { print($0) })
  
  textField.onNext("Par")
  textField.onNext("Pari")
  button.onNext(())
  textField.onNext("Paris")
  button.onNext(())
  button.onNext(())
}


/*
 button.onNext(_:) 를 여러번 호출해도, textField 에서 가장 마지막에 방출했던 것 1회만 방출한다.
 withLatestFrom + observable.distinctUntilChanged() 를 조합하면 동일하게 동작하도록 구현할 수 있다.
 */
example(of: "sample") {
  let button = PublishSubject<Void>()
  let textField = PublishSubject<String>()
  
  let observable = textField.sample(button)
  _ = observable.subscribe(onNext: { print($0) })
  
  textField.onNext("Par")
  textField.onNext("Pari")
  button.onNext(())
  textField.onNext("Paris")
  button.onNext(())
  button.onNext(())
}

example(of: "withLatestFrom + distinctUntilChanged") {
  let button = PublishSubject<Void>()
  let textField = PublishSubject<String>()
  
  let observable = button.withLatestFrom(textField)
  _ = observable
    .distinctUntilChanged()
    .subscribe(onNext: { print($0) })
  
  textField.onNext("Par")
  textField.onNext("Pari")
  button.onNext(())
  textField.onNext("Paris")
  button.onNext(())
  button.onNext(())
}
