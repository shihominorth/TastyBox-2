//
//  SceneCoordinatorType.swift
//  TastyBox-2
//
//  Created by 北島　志帆美 on 2021-08-29.
//

import UIKit
import RxSwift

protocol SceneCoordinatorType {
  /// transition to another scene
  @discardableResult
  func transition(to scene: UIViewController, type: SceneTransitionType) -> Completable

  /// pop scene from navigation stack or dismiss current modal
  @discardableResult
  func pop(animated: Bool, completion: (() -> Void)?) -> Completable
}

extension SceneCoordinatorType {
  @discardableResult
  func pop() -> Completable {
    return pop(animated: true, completion: nil)
  }
}
