import UIKit
import RxSwift
import RxCocoa

// TODO: flatMap, flatmap first, event subscribing



/*
 flatmap은 각 Observable 의 변화를 게속 observing 한다.
 새로운 Observable을 관찰해도 이전에 관찰했던 Observable 계속해서 관찰한다.
 
 아래 예제에서는 두개의 Student 객체 ryan, charlotte 이 존재하는데,
 student.onNext(ryan) 을 호출해 ryan의 value를 구독한다.
 student.onNext(charlotte) 까지 호출하고 나면,
 student.subscribe 에서, ryan, charlotte 둘이 방출하는 값을 구독한다.
 */

example(of: "flatMap") {
  struct Student {
    var score: BehaviorSubject<Int>
  }
  let bag = DisposeBag()
  let ryan = Student(score: BehaviorSubject(value: 80))
  let charlotte = Student(score: BehaviorSubject(value: 90))
  let student = PublishSubject<Student>()
  
  student
    .flatMap { $0.score }
    .subscribe(onNext: { print($0) })
    .disposed(by: bag)

  student.onNext(ryan)
  ryan.score.onNext(85)
  student.onNext(charlotte)
  ryan.score.onNext(95)
  charlotte.score.onNext(100)
}

//flatMapLatest
/*
	 flatMap 에서 가장 최신의 값만을 확인하고 싶을 때에는 flatMapLatest을 사용한다.
 1
	 flatMap 에서의 코드와 다른 점은 ryan 점수인 85가 반영되지 않는다는 것.
 */
example(of: "flatMapLatest") {
  let bag = DisposeBag()
  struct Student {
    var score: BehaviorSubject<Int>
  }
  
  let ryan = Student(score: BehaviorSubject(value: 80))
  let charlotte = Student(score: BehaviorSubject(value: 90))
  
  let student = PublishSubject<Student>()
  
  student
    .flatMapLatest { $0.score }
    .subscribe(onNext: {
      print($0)
    })
    .disposed(by: bag)
  
  student.onNext(ryan)
  ryan.score.onNext(85)
  student.onNext(charlotte)
  ryan.score.onNext(95)
  charlotte.score.onNext(100)
	
  student
    .flatMapLatest { $0.score }
    .subscribe(onNext: {
      print($0)
    })
    .disposed(by: bag)
}

example(of: "map and flatMap") {
  let bag = DisposeBag()
  let numberObservable = Observable<Int>.of(10, 20, 30, 40)
  
  let observableAfterMap = numberObservable.map { String($0) }
  let observableAfterFlatMap = numberObservable.flatMap { Observable<String>.just(String($0 * 2)) }
  
  observableAfterMap
    .subscribe { print($0) }
    .disposed(by: bag)
  
  observableAfterFlatMap
    .subscribe { print($0) }
    .disposed(by: bag)
}

/*
 materialize 를 호출하여 Observable<T> -> Observable<Event<T>> 로 변경된다.
 dematerialize 를 호출하여 Observable<Event<T>> -> Observable<T> 로 변경된다.
 
 
에러는 여전히 studentScore 의 종료를 발생시키지만, 바깥은 student observable 을 그대로 살리기 때문에 student.onNext(charlotte)을 했을 때, charlotte.onNext(100) 을 방출했을 때, subscribe 이 가능하다.
 dematerialize 를 이용해 studentScore 의 observable 을 원래 모양으로 리턴하고, 방출할 수 있도록 한다.
 */
example(of: "materialize and dematerialize") {
	enum MyError: Error {
		case anError
	}
  struct Student {
    var score: BehaviorSubject<Int>
  }

	let bag = DisposeBag()
	let ryan = Student(score: BehaviorSubject(value: 80))
	let charlotte = Student(score: BehaviorSubject(value: 100))

	let student = BehaviorSubject(value: ryan)


	let studentScore = student
    .flatMapLatest { $0.score.materialize() }

	studentScore
    .filter {
      guard $0.error == nil else {
        print($0.error!)
        return false
      }
      return true
    }
    .dematerialize()
		.subscribe(onNext: { print($0) })
		.disposed(by: bag)
  
  ryan.score.onNext(85)
  ryan.score.onError(MyError.anError)
  ryan.score.onNext(90)
  
  student.onNext(charlotte)
}
