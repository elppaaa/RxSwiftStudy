import UIKit
import PlaygroundSupport
import RxSwift
import RxCocoa

/// 예제를 묶기 위한 함수
public func example(of description: String, action: () -> Void) {
  print("\n--- Example of:", description, "---")
  action()
}



/*
 Observable 은 subscription을 받기 전까지는 아무 일도 일어나지 않음.
 subscription 이 있어야 Observable 의 emitting 이 발생
 
 String에 대한 Observable 생성
 해당 인스턴스를 subscribe를 이용해 Disposable 객체를 반환
 구독을 취소하고 싶으면 dispose() 함수를 호출.
 구독을 취소하거나, dispose() 한 뒤에는 이벤트 emitting 이 멈춤.
 요소가 무한히 존재한다면, dispose를 호출해야 completed가 출력됨.
 */
example(of: "dispose") {
  let observable = Observable.of("A", "B", "C")
  let subscription = observable.subscribe({ event in
    print(event)
  })
  subscription.dispose()
}


/*
 DisposeBag.disposables 에 Disposable 객체들이 배열로 존재한다.
 DisposeBag 내부에서 이러한 Disposable 객체들을 관리할 수 있다.
 disposebag 을 subscription 에 추가하거나
  수동으로 관리하다가 메모리 누수가 발생하는 것을 막기 위해 사용함.
 */
example(of: "DisposeBag") {
  let disposeBag = DisposeBag()
  
  Observable.of("A", "B", "C")
    .subscribe {
      print($0)
    }
    .disposed(by: disposeBag)
}


/*
 create는 @escaping 클로저로 동작함.
 create 를 이용하여 Observable Sequence를 생성함.
 escaping 내부에서는 AnyObserver 를 취한 뒤 Disposable 을 반환한다.
 .next 이벤트를 Observer 에 추가한다 coCompleted 또한 on(.completed) 를 생략한다.
 
 onCompleted 를 통해서 해당 Observable 은 종료되었으므로, 그 다음 onNext 는 방출되지 않음.
 
 1
 Completed
 Disposed
 */
example(of: "create") {
  let disoposeBag = DisposeBag()

  Observable<String>.create({ observer -> Disposable in
    observer.onNext("1")
    observer.onCompleted()
    observer.onNext("?")
    return Disposables.create()
  })
  .subscribe (onNext: { print($0) },
              onError: { print($0) },
              onCompleted: { print("Completed") },
              onDisposed: { print("Disposed") }
  ).disposed(by: disoposeBag)
}


/*
 에러를 추가했을때 데이터 처리.
 Error 이후 Completed, next 는 처리되지 않고, Error 후 Dispose 됨.
 
 1
 anError
 Disposed
 */

example(of: "create + Error") {
  enum MyError: Error {
    case anError
  }
  
  let disposeBag = DisposeBag()
  
  Observable<String>.create({ observer -> Disposable in
    observer.onNext("1")
    
    observer.onError(MyError.anError)
    observer.onCompleted()
    observer.onNext("?")
    return Disposables.create()
  })
  .subscribe(
    onNext: { print($0) },
    onError: { print($0) },
    onCompleted: { print("Completed") },
    onDisposed: { print("Disposed") }
  )
  .disposed(by: disposeBag)
}


// Observable Factory
/*
 Observable 이 반환할 Bool 값을 생성.
 Observable.deferred 연산자를 이용하여 Int facotry Observable 을 생성함.
 flip 의 값에 따라 다른 Observable 을 반환하도록 함.
 
 factory 의 구독을 4번 반복하 반복한 값을 출력함. (번갈아가며 Observable이 생성됨)
 deferred 는 Swift 기본 문법에서 lazy var 와 유사한 느낌이며 Observable 을 반환한다.
 */
example(of: "deferred") {
  let disposeBag = DisposeBag()
  
  var flip = false
  let factory: Observable<Int> = Observable.deferred {
    flip = !flip
    if flip {
      return Observable.of(1,2,3)
    } else {
      return Observable.of(4,5,6)
    }
  }
  
  for _ in 0...3 {
    factory.subscribe(onNext: {
      print($0, terminator: "")
    })
    .disposed(by: disposeBag)
    print()
  }
}


/*
 Trait.
 일반적인 Observable 보다 좁은 범위의 Observable 을 선택적으로 사용.
 Single, Maybe, Completable 세 가지가 존재하며,
 loadText 함수는 name 에 해당하는 파일을 읽어 Single 인스턴스를 반환한다.
 Single 은 .success, .failure 두가지의 이벤트를 방출한다.
 성공 또는 실패로 확인될 수 있는 1회성인 프로세스에서 주로 사용한다.
 Completable 은 .completed, .failue 만을 방출한다.
 Maybe 는 .success(value) .completed, .error 방출.
 */

example(of: "Single") {
  // 발생할 수 있는 에러를 enum을 통해 정의
  enum FileReadError: Error {
    case fileNotFound, unreadable, encodingFailed
  }
  
  let disposeBag = DisposeBag()

  func loadText(from name: String) -> Single<String> {
    return Single.create { single in
      let disposable = Disposables.create()

      guard let path = Bundle.main.path(forResource: name, ofType: "txt") else {
        single(.failure(FileReadError.fileNotFound))
        return disposable
      }
      
      guard let data = FileManager.default.contents(atPath: path) else {
        single(.failure(FileReadError.unreadable))
        return disposable
      }
      
      guard let contents = String(data: data, encoding: .utf8) else {
        single(.failure(FileReadError.encodingFailed))
        return disposable
      }
      
      single(.success(contents))
      return disposable
    }
  }
  
  // 함수 호출 -> subscribe
  loadText(from: "CopyRight")
    .subscribe {
      switch $0 {
      case .success(let string):
        print(string)
      case .failure(let error):
        print(error)
      }
    }
    .disposed(by: disposeBag)
}
