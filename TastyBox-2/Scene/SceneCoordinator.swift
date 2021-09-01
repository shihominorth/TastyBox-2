//
//  SceneCoordinator.swift
//  TastyBox-2
//
//  Created by 北島　志帆美 on 2021-08-29.
//

import UIKit
import RxSwift
import RxCocoa

class SceneCoordinator: NSObject, SceneCoordinatorType {
  
  private var window: UIWindow
  private var currentViewController: UIViewController
  
  required init(window: UIWindow) {
    self.window = window
    currentViewController = window.rootViewController!
  }
  
  static func actualViewController(for viewController: UIViewController) -> UIViewController {
    if let navigationController = viewController as? UINavigationController {
      return navigationController.viewControllers.first!
    } else {
      return viewController
    }
  }
  
  @discardableResult
  func transition(to viewController: UIViewController, type: SceneTransitionType) -> Completable {
    
    let subject = PublishSubject<Void>()
   
    switch type {
    case .root:
      currentViewController = SceneCoordinator.actualViewController(for: viewController)
      window.rootViewController = viewController
      subject.onCompleted()
      
    case .push:
      guard let navigationController = currentViewController.navigationController else {
        fatalError("Can't push a view controller without a current navigation controller")
      }
      
      // Challenge 3: set ourselves as the navigation controller's delegate. This needs to be done
      // prior to `navigationController.rx.delegate` as it takes care of preserving the configured delegate
      navigationController.delegate = self
      
      // one-off subscription to be notified when push complete
      _ = navigationController.rx.delegate
        .sentMessage(#selector(UINavigationControllerDelegate.navigationController(_:didShow:animated:)))
        .map { _ in }
        .bind(to: subject)
      
      navigationController.pushViewController(viewController, animated: true)
      
      // Challenge 3: we don't need this line anymore
      // currentViewController = SceneCoordinator.actualViewController(for: viewController)
      
    case .modal:
      viewController.modalPresentationStyle = .fullScreen
        viewController.modalTransitionStyle = .coverVertical
      currentViewController.present(viewController, animated: true) {
        subject.onCompleted()
      }
      currentViewController = SceneCoordinator.actualViewController(for: viewController)
    }
    return subject.asObservable()
      .take(1)
        .ignoreElements().asCompletable()
  }
  
  @discardableResult
  func pop(animated: Bool) -> Completable {
    let subject = PublishSubject<Void>()
    
    if let presenter = currentViewController.presentingViewController {
      // dismiss a modal controller
      currentViewController.dismiss(animated: animated) {
        self.currentViewController = SceneCoordinator.actualViewController(for: presenter)
        subject.onCompleted()
      }
    } else if let navigationController = currentViewController.navigationController {
      // challenge 3: we don't need to set ourselves as delegate of the navigation controller again,
      // as this has been done during the push transition
      
      // navigate up the stack
      // one-off subscription to be notified when pop complete
      _ = navigationController.rx.delegate
        .sentMessage(#selector(UINavigationControllerDelegate.navigationController(_:didShow:animated:)))
        .map { _ in }
        .bind(to: subject)
      guard navigationController.popViewController(animated: animated) != nil else {
        fatalError("can't navigate back from \(currentViewController)")
      }

      // challenge 3: we don't need this line anymore
      // currentViewController = SceneCoordinator.actualViewController(for: navigationController.viewControllers.last!)
      
    } else {
      fatalError("Not a modal, no navigation controller: can't navigate back from \(currentViewController)")
    }
    return subject.asObservable()
      .take(1)
        .ignoreElements().asCompletable()
  }
  
}

// challenge 3: navigation controller delegate
extension SceneCoordinator: UINavigationControllerDelegate {
  func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
    currentViewController = viewController
  }
}
