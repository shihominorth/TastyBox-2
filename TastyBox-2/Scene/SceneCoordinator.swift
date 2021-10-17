//
//  SceneCoordinator.swift
//  TastyBox-2
//
//  Created by 北島　志帆美 on 2021-08-29.
//

import UIKit
import Photos
import PhotosUI
import RxSwift
import RxCocoa

class SceneCoordinator: NSObject, SceneCoordinatorType {

    
    private var window: UIWindow
    private var currentViewController: UIViewController
    private var semiModalPresenter = SemiModalPresenter()
    
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
            viewController.modalTransitionStyle = .flipHorizontal
            currentViewController.present(viewController, animated: true) {
                subject.onCompleted()
            }
            currentViewController = SceneCoordinator.actualViewController(for: viewController)
            
            
        case .usePresentNC:
            
            guard let navigationController = currentViewController as? UINavigationController else {
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
            
        case .VCAsRoot:
            
            if let nc = currentViewController as? UINavigationController {
                
                currentViewController = SceneCoordinator.actualViewController(for: viewController)
                window.rootViewController = nc
                subject.onCompleted()
                
            }
            
        case .modalHalf:
            
//            if #available(iOS 15.0, *) {
//
//                if let presentationController = viewController.presentationController as? UISheetPresentationController {
//                    presentationController.detents = [.medium(), .large()] /// set here!
//                    presentationController.prefersScrollingExpandsWhenScrolledToEdge = true // ハンドルを表示
//
//                }
//
//                currentViewController.present(viewController, animated: true)
//            }
//            else {
                
                semiModalPresenter.viewController = viewController
               
                currentViewController.present(viewController, animated: true) { [unowned self] in
                    self.currentViewController = SceneCoordinator.actualViewController(for: viewController)
                    self.semiModalPresenter.dissmissDelegate = self
                    subject.onCompleted()
                }

        case .imagePick:
            
            if viewController is PHPickerViewController {

                viewController.modalPresentationStyle = .automatic
                viewController.modalTransitionStyle = .coverVertical
                
                currentViewController.present(viewController, animated: true) {
                    subject.onCompleted()
                }
                
            }
          
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


extension SceneCoordinator: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        currentViewController = viewController
    }
}

extension SceneCoordinator: dismissModalDelegate {
    func dissmiss() {
        self.pop(animated: true)
    }
}
