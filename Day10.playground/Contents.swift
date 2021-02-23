import UIKit
import PlaygroundSupport
import RxSwift

// Support code -- DO NOT REMOVE
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

let example1 = {
  let elementsPerSecond = 1
  let maxElements = 5
  let replayedElements = 1
  let replayDelay: TimeInterval = 3
  
  /*
   elementsPerSecond 에서 요소들을 방출할 observable 을 만듦.
   방출된 요소의 개수와, 몇개의 요소를 새로운 구독자에게 "다시 재생"할지 제어할 필요가 있음.
   observable 을 방출하기 위해서, Observable 을 생성한다.
   DispatchSource 를 이용해 interval 마다 value가 1씩 증가하여 방출하도록 한다.
   */
  let sourceObservable = Observable<Int>.create { observer in
    var value = 1
    let timer = DispatchSource.timer(interval: 1.0 / Double(elementsPerSecond), queue: .main) {
      if value <= maxElements {
        observer.onNext(value)
        value += 1
      }
    }
    return Disposables.create {
      timer.suspend()
    }
  }
  /*
   replay 연산자를 이용해 source observable 에 의해
   방출된 마지막 replayedElements 에 대한 기록을 새로운 sequence로 생성해낸다.
   */
  .replay(replayedElements)
  
  // 이벤트가 방출되는 것을 실시간으로 시각화 하여 볼 수 있음.
  let sourceTimeline = TimelineView<Int>.make()
  let replayedTimeline = TimelineView<Int>.make()
  
  let stack = UIStackView.makeVertical([
    UILabel.makeTitle("replay"),
    UILabel.make("Emit \(elementsPerSecond) per second: "),
    sourceTimeline,
    UILabel.make("Replay \(replayedElements) after \(replayDelay) sec:"),
    replayedTimeline
  ])
  
  /*
   ObserverType 을 채택한 TimelineView 클래스를 이용해 sourceObservalbe을 구독한다.
   
   일정 시간 뒤에 sourceObservable을 다시 구독한다. 두번째 타임라인에 두번째 구독을 통해 받은 요소들을 볼 수 있다.
   reply가 connectable observalbe 을 생성하기 때문에 아이템을 받기 시작하려면 기본 소스에 연결해야 한다.
   */
  
  _ = sourceObservable.subscribe(sourceTimeline)
  
  DispatchQueue.main.asyncAfter(deadline: .now() + replayDelay) {
    _ = sourceObservable.subscribe(replayedTimeline)
  }
  
  /*
   connectable observable 은 connect() 메서드가 호출되기 전까지 방출을 하지 않는다.
   */
  _ = sourceObservable.connect()
  
  let hostView = setupHostView()
  hostView.addSubview(stack)
  hostView
}
/*
 타임라인을 보면 두번째 구독자가 3, 4 요소들을 동시에 받았는데,
 구독하는 시간에 따라 마지막 버퍼인 3과 구독 후 받은 4를 동시에 받은 것이다.
 replayedElement 개수 만큼 버퍼를 갖기 때문에 개수를 늘리면 한번에 더 많은 값이 방출된다.
 
 
 replayAll() 함수를 호출해 모든 데이터를 방출할 수도 있으나,
 버퍼할 요소가 계속해서 쌓이게 되면, 혹은 해당 observable 이 dispose 되지 않는다면 메모리 부족으로 막히게 될것이다.
 */

//example1()





let example2 = {
  let bufferTimeSpan: RxTimeInterval = .seconds(4)
  let bufferMaxCount = 2
  
  let sourceObservable = PublishSubject<String>()
  
  let sourceTimeline = TimelineView<String>.make()
  let bufferedTimeline = TimelineView<Int>.make()
  
  let stack = UIStackView.makeVertical([
    UILabel.makeTitle("buffer"),
    UILabel.make("Emitted elements:"),
    sourceTimeline,
    UILabel.make("Buffered elements (at most \(bufferMaxCount) every \(bufferTimeSpan) seconds: "),
    bufferedTimeline
  ])
  
  /*
   sourceTimeline에서 sourceObservable을 구독한다.
   
   bufferedTimeline도 sourceObservable 을 구독한다.
   bufferTimeSpan 이 만료되기 전에 받아졌으면, 연산자는 버퍼 요소들을 방출하고 타이머를 초기화한다.
   지연 시간동안 받은 요소가 없으면 array는 비게된다.
   bufferMaxCount 만큼의 요소들을 버퍼에 가질 수 있음
   */
  _ = sourceObservable.subscribe(sourceTimeline)
  
  sourceObservable
    .buffer(timeSpan: bufferTimeSpan, count: bufferMaxCount, scheduler: MainScheduler.instance)
    .map { $0.count }
    .subscribe(bufferedTimeline)
  
  let hostView = setupHostView()
  hostView.addSubview(stack)
  hostView
  
  
    DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
      sourceObservable.onNext("🍎")
      sourceObservable.onNext("🍎")
      sourceObservable.onNext("🍎")
    }
}
/*
 최초의 버퍼 타임라인은 빈 array를 방출함.(source observable 이 비어있을 때)
 이후 세개의 요소(사과)가 source observable에 푸쉬되고,
 버퍼 타임라인은 최대 개수인 2개를 가진 array를 갖는다.
 4초가 지나고, 한개의 source observable 의 마지막 요소가 방출된다.
 */

example2()

