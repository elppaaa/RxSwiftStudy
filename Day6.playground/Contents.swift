//: A UIKit based Playground for presenting user interface
  
import UIKit
import PlaygroundSupport
import RxSwift
import RxRelay

/// 예제를 묶기 위한 함수
public func example(of description: String, action: () -> Void) {
  print("\n--- Example of:", description, "---")
  action()
}

/*
 distinctUntilChanged 는 이전에 방출된 것과 동일한지 확하여 prevent.
 기본적으로 구현되어 있으며 커스터마이징 할 수 있음.
 
 아래는 커스텀된 예시.
 NSNumber -> word로 변경하여, 중복된 요소가 존재하는지 확인함.(ten / one hundred ten, ....)
 a, b, c 순서로 비교를 진행한다고 했을 때,
 a 와 b를 비교하고, b가 중복되었다면 b의 방출이 막힘.
 그 다음 비교를 진행할 때에는 a 와 c를 비교함.
 */
example(of: "distinctUntilChanged(_:)") {
  let disposeBag = DisposeBag()
  
  let formatter = NumberFormatter()
  formatter.numberStyle = .spellOut
  
  Observable<NSNumber>.of(10, 110, 20, 200, 210, 310)
    .distinctUntilChanged({ a, b in
      guard let aWords = formatter.string(from: a)?.components(separatedBy: " "),
            let bWords = formatter.string(from: b)?.components(separatedBy: " ")
      else { return false }
      
      var containsMatch = false
      
      for aWord in aWords {
        for bWord in bWords {
          if aWord == bWord {
            containsMatch = true
            break
          }
        }
      }
      return containsMatch
    })
    .subscribe(onNext: {
      print($0)
    })
    .disposed(by: disposeBag)
}


// share
/*
 Observable 을 두개 구독한 것을 보면
 첫번째 구독과 두번째 구독이 element가 출력되는 것이 다른 것을 볼 수 있다.
 subscribe를 호출할 때마다 구독을 위해 새로운 Observable이 생성되는데, 이때마다 동일한 결과를 보장하지는 않는다.
 또, Observable 도 같은 요소의 sequence 를 생성하지 않기 때문에 구독에 대해 동일한 중복 요소를 생성해야 하고, 이것은 비생산적이다. -> share 를 이용해 여러개의 구독을 이용할 수 있다.
 */
example(of: "element not share") {
  var start = 0
  func getStartNumber() -> Int {
    start += 1
    return start
  }
  
  
  let numbers = Observable<Int>.create { observer in
    let start = getStartNumber()
    observer.onNext(start)
    observer.onNext(start + 1)
    observer.onNext(start + 2)
    observer.onCompleted()
    return Disposables.create()
  }
  
  numbers
    .subscribe(onNext: { el in
      print("element [\(el)]")
    }, onCompleted: {
      print("--------------")
    })
  
  numbers
    .subscribe(onNext: { el in
      print("element [\(el)]")
    }, onCompleted: {
      print("--------------")
    })
}

/*
 Observable이 share 되었을 때의 예제
 */

example(of: "element share") {
  let bag = DisposeBag()
  let numbers = Observable<Int>.create { observer in
    observer.onNext(1)
    observer.onNext(2)
    observer.onNext(3)
    observer.onNext(4)
    observer.onCompleted()
    return Disposables.create()
  }
  .share()
  
  numbers
    .subscribe(onNext: { el in
      print("element [\(el)]")
    }, onCompleted: {
      print("--------------")
    })
    .disposed(by: bag)

  numbers
    .subscribe(onNext: { el in
      print("element [\(el)]")
    }, onCompleted: {
      print("--------------")
    })
    .disposed(by: bag)
}


// Transforming Operators

/*
 sequence를 array 요소로 넣어 방출한다. */

example(of: "toArray") {
  let bag = DisposeBag()
  
  Observable.of("A", "B", "C")
    .toArray()
    .subscribe { print($0) }
    .disposed(by: bag)
}

/*
 Swift 표준 라이브러리에서의 map과 동일하다.
 아래 예제에서는 숫자에서 단어 / Int -> String으로 변환됨.
 */

example(of: "map") {
  let bag = DisposeBag()
  
  let formatter = NumberFormatter()
  formatter.numberStyle = .spellOut
  
  Observable<NSNumber>.of(123, 4, 56)
    .map {
      formatter.string(from: $0) ?? ""
    }
    .subscribe(onNext: {
      print($0)
    })
    .disposed(by: bag)
}


/*
 index를 사용할 수 있음.
 아래는 index 값에 따라 integer를 변경함.
 */
example(of: "enumerated and map") {
  let bag = DisposeBag()
  
  Observable.of(1, 2, 3, 4, 5, 6)
    .enumerated()
    .map { index, integer in
      index > 2 ? integer * 2 : integer
    }
    .subscribe(onNext: {
      print($0)
    })
    .disposed(by: bag)
}
