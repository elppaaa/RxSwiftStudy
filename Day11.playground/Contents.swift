import UIKit
import PlaygroundSupport
import RxSwift
import RxCocoa

class TimelineView<E>: TimelineViewBase, ObserverType where E: CustomStringConvertible {
  static func make() -> TimelineView<E> {
    return TimelineView(width: 400, height: 100)
  }
  public func on(_ event: Event<E>) {
    switch event {
    case .next(let value):
      add(.Next(String(describing: value)))
    case .completed:
      add(.Completed())
    case .error(_):
      add(.Error())
    }
  }
}
// window
/*
 window 는 buffer와 유사하나, array 를 방출하는 buffer 와 다르게 Observable 을 방출한다.
 */
  let elementsPerSecond = 3
  let windowTimeSpan: RxTimeInterval = .seconds(4)
  let windowMaxCount = 10
  let sourceObservable = PublishSubject<String>()
  
  let sourceTimeline = TimelineView<String>.make()

let delayInSeconds = 1.5
let delayedTimeline = TimelineView<String>.make()


  let stack = UIStackView.makeVertical([
    UILabel.makeTitle("window"),
    UILabel.make("Emitted elements (\(elementsPerSecond) per sec.):"),
    delayedTimeline,
    sourceTimeline,
    UILabel.make("Windowed observables (at most \(windowMaxCount) every \(windowTimeSpan) sec:")
  ])
  
  /*
   source Observable이 주기적으로 방출하도록 함.
   */
  let timer = DispatchSource.timer(interval: 1.0 / Double(elementsPerSecond), queue: .main) {
    sourceObservable.onNext("🍎")
  }
  
  timer.suspend()
  timer.resume()
  
  _ = sourceObservable.subscribe(sourceTimeline)
  
  _ = sourceObservable
    .window(timeSpan: windowTimeSpan, count: windowMaxCount, scheduler: MainScheduler.instance)
    /*
     window 가 4초 마다 새로운 observable 을 방출하고, 그떄마다 flatMap을 통해 새로운 timelineView가 추가된다.
     */
    .flatMap { windowedObservable -> Observable<(TimelineView<Int>, String?)> in
      let timeline = TimelineView<Int>.make()
      stack.insert(timeline, at: 4)
      stack.keep(atMost: 8)
      return windowedObservable
        /*
         반환된 observable 들을 timeline 과 value 를 조합한 튜플로 매핑하고,
         concat 으로 하나의 튜플로 연결한다.
         */
        .map { value in (timeline, value) }
        .concat(Observable.just((timeline, nil)))
    }
    /*
     튜플을 구독하여 타임라인에 표시, value가 nil일 때는 sequence가 종료되었음을 의미
     */
    .subscribe(onNext: { tuple in
      let (timeline, value) = tuple
      if let value = value {
        timeline.add(.Next(value))
      } else {
        timeline.add(.Completed(true))
      }
    })
  
  let hostView = setupHostView()
  hostView.addSubview(stack)
  hostView


//let delayInSeconds = 1.5
//let delayedTimeline = TimelineView<Int>.make()

/*
 delaySubscription
 구독을 시작한 후 요소를 받기 시점을 지연하는 역할을 수행함.
 
 지연이 시작된 이후에 사용자가 필요한 데이터를 처리하고 observable 이 이어서 처리할 수 있도록 명령함.
 
Rx 에서 observable 을 'cold', 'hot' 이라고 명명하는데, cold는 observable 요소들을 등록할때 방출이 시작되고,
 hot 은 observable 들이 어떤 시점에서 영구적으로 작동하는 것이다.
 구독을 지연시켰을 때, 'cold' observable 이라면 지연에 따른 차이가 없을 것이지만,
 'hot' observable 이라면 일정 요소를 건너 띄게 될 수 있다.
 */

//_ = sourceObservable
//  .delaySubscription(.seconds(3), scheduler: MainScheduler.instance)
//  .subscribe(delayedTimeline)


_ = sourceObservable
  .delay(.seconds(3), scheduler: MainScheduler.instance)
  .subscribe(delayedTimeline)


// MARK: - time operators

let ex1 = {
  _ = Observable<Int>
    .timer(.seconds(3), scheduler: MainScheduler.instance)
    .flatMap { _ in
      sourceObservable.delay(.seconds(3), scheduler: MainScheduler.instance)
    }
    .subscribe(delayedTimeline)
  /*
   trigger 를 구성할 때에 dispatchsource.timer 함수를 임의로 구현해서 사용하는 것보다는
   Rxsiwft에서 observable에 임의로 구현되어 있는 함수를 사용하는 것이 조금 더 직관적으로 함수의 내용을 확인할 수 있음.
   flatMap을 사용하기 전에 timeout 연산자의 주된 목적인 시간 초과 오류에 대해 구분하는 것이 조금 더 나은 것 같음.
   */
}



// MARK: - time out

/*
 timeout 연산자의 주된 목적은 타이머를 시간 초과 오류 조건에 대해 구분하는 것이다.
 time out 연산자가 실행되면 RxError.TimeoutError 라는 에러 이벤트를 방출한다.
 에러가 잡히지 않으면 sequence 를 완전 종료한다.
 */
example(of: "timeout") {
  let button = UIButton(type: .system)
  button.setTitle("Press me now!", for: .normal)
  button.sizeToFit()
  
  let tapsTimeline = TimelineView<String>.make()
  
  let stack = UIStackView.makeVertical([
    button,
    UILabel.make("Taps on button above"),
    tapsTimeline
  ])
  
  let _ = button
    .rx.tap
    .map { _ in "●" }
    .timeout(.seconds(5), scheduler: MainScheduler.instance)
    .subscribe(tapsTimeline)
  
  let hostView = setupHostView()
  hostView.addSubview(stack)
  hostView
}

