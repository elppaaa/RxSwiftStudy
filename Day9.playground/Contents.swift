import UIKit
import PlaygroundSupport
import RxSwift

// MARK: - Switches

// amb
/*
 두 개의 observable 을 구독하다가 먼저 방출하는 observable 이 생기면,
 다른 observable 은 구독을 중단한다.
 
 아래 예제를 보면 observable 은 left, right 모두를 구독한다.
 left 가 먼저 방출되었고, right 는 구독이 중단되어 right의 방출만 출력되었다.
 */

example(of: "amb") {
  let left = PublishSubject<String>()
  let right = PublishSubject<String>()
  
  let observable = left.amb(right)
  let disposable = observable.subscribe(onNext: { value in
    print(value)
  })
  
  left.onNext("Lisbon")
  right.onNext("Copenhagen")
  left.onNext("London")
  left.onNext("Madrid")
  right.onNext("Vienna")

  disposable.dispose()
}


// switchLatest
/*
 마지막으로 들어온 sequence 의 요소만 구독한다.
 아래 예제에서도 source 에서 다른 Subject 를 넘길 때, 이전 것들은 구독하지 않는 것을 볼 수 있다.
 */
example(of: "switchLatest") {
  let one = PublishSubject<String>()
  let two = PublishSubject<String>()
  let three = PublishSubject<String>()
  
  let source = PublishSubject<Observable<String>>()
  
  let observable = source.switchLatest()
  let disposable = observable.subscribe(onNext: { print($0) })
  
  source.onNext(one)
  one.onNext("Some text form sequence one")
  two.onNext("Some text from sequence two")
  
  source.onNext(two)
  two.onNext("More text from sequence two")
  one.onNext("and also from sequence one")
  
  source.onNext(three)
  two.onNext("Why don't you see me?")
  one.onNext("I'm alone, help me")
  three.onNext("Hey it's three. I win")
  
  source.onNext(one)
  one.onNext("Nope It's me, one!")
  
  disposable.dispose()
}

// MARK: - 요소 간 결합

//reduce
/*
 source observable 이 값을 방출할때 마다 값을 가공한다.
 observable 이 complete 되었을 때 값을 방출하고 완료된다.
 */
example(of: "reduce") {
  let source = Observable.of(1, 3, 5, 7, 9)
  
  let observable = source.reduce(0, accumulator: +)
  observable.subscribe(onNext: { print($0) })
  
  let observable2 = source.reduce(0) { summary, newValue in
    return summary + newValue
  }
  observable2.subscribe(onNext: { print($0) })
}

// scan
/*
 reduce(_:accumulator:) 와 동일하게 작동하지만, Observable 을 반환한다.
 sequence 를 방출할때마다 accumulator 연산을 수행해 반환한다.
 */
example(of: "scan") {
  let source = Observable.of(1, 3, 5, 7, 9)
  
  let observable = source.scan(0, accumulator: +)
  observable.subscribe(onNext: { print($0) })
}

/*
 zip 연산자를 이용해서, 현재값과 현재 총합을 동시에 출력.
 */
example(of: "zip - scan") {
  let source = Observable.of(1, 3, 5, 7, 9)
  let observable = source.scan(0, accumulator: +)
  
  let _ = Observable.zip(source, observable) { current, total in
    return "\(current) \(total)"
  }
  .subscribe(onNext: { print($0) })
}

