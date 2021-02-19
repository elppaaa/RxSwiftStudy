//
//  Functions.swift
//  RxSwiftStudy
//
//  Created by JK on 2021/02/17.
//

import Foundation

/// 예제를 묶기 위한 함수
public func example(of description: String, action: () -> Void) {
  print("\n--- Example of:", description, "---")
  action()
}
