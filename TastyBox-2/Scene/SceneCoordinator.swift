//
//  SceneCoordinator.swift
//  TastyBox-2
//
//  Created by 北島　志帆美 on 2021-08-29.
//

import UIKit
import AVFoundation
import Firebase
import Photos
import PhotosUI
import RSKImageCropper
import RxSwift
import RxCocoa
import SafariServices
import SwiftMessages

class SceneCoordinator: NSObject, SceneCoordinatorType {
    private var window: UIWindow
    private var currentViewController: UIViewController
    private var semiModalPresenter: SemiModalPresenter
    
    private let disposeBag: DisposeBag
    
    required init(window: UIWindow) {
        self.window = window
        currentViewController = window.rootViewController!
        semiModalPresenter = SemiModalPresenter()
        disposeBag = DisposeBag()
    }
    
    static func actualViewController(for viewController: UIViewController) -> UIViewController {
        if let navigationController = viewController as? UINavigationController {
            return navigationController.viewControllers.first!
        } else {
            return viewController
        }
    }
    
    
    @discardableResult
    func transition(to scene: Scene, type: SceneTransitionType) -> Completable {
        let subject = PublishSubject<Void>()
        let viewController = scene.viewController()
        
        switch type {
        case .root:
            currentViewController = SceneCoordinator.actualViewController(for: viewController)
            window.rootViewController = viewController
            subject.onCompleted()
            
        case .push:
            
            guard let navigationController = currentViewController.navigationController else {
                fatalError("Can't push a view controller without a current navigation controller")
            }
            
            navigationController.delegate = self
            
            _ = navigationController.rx.delegate
                .sentMessage(#selector(UINavigationControllerDelegate.navigationController(_:didShow:animated:)))
                .map { _ in }
                .bind(to: subject)
            
            DispatchQueue.main.async {
                navigationController.pushViewController(viewController, animated: true)
            }
            
        case .pushFromBottom:
            
            guard let navigationController = currentViewController.navigationController else {
                fatalError("Can't push a view controller without a current navigation controller")
            }
            
            navigationController.delegate = self
            
            _ = navigationController.rx.delegate
                .sentMessage(#selector(UINavigationControllerDelegate.navigationController(_:didShow:animated:)))
                .map { _ in }
                .bind(to: subject)
            
            let transition = CATransition()
            transition.duration = 0.5
            transition.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            transition.type = .push
            transition.subtype = .fromLeft
            navigationController.view.layer.add(transition, forKey: kCATransition)
            navigationController.pushViewController(viewController, animated: false)
            
            
        case let .modal(presentationStyle, transitionStyle, hasNavigationController):
            
            viewController.modalPresentationStyle = presentationStyle ?? .fullScreen
            viewController.modalTransitionStyle =  transitionStyle ?? .flipHorizontal
            
            if hasNavigationController {
                
                if let navigationController = viewController as? UINavigationController {
                    
                    navigationController.delegate = self
                    
                    currentViewController.present(viewController, animated: true) {
                        subject.onCompleted()
                    }
                    
                    currentViewController = SceneCoordinator.actualViewController(for: viewController)
                }
            }
            else {
                
                guard let navigationController = currentViewController.navigationController else {
                    fatalError("Can't push a view controller without a current navigation controller")
                }
                
                navigationController.delegate = self
                
                currentViewController.present(viewController, animated: true) {
                    subject.onCompleted()
                }
                
                currentViewController = SceneCoordinator.actualViewController(for: viewController)
            }
            
            
        case .modalHalf:
            
            semiModalPresenter.viewController = viewController
            
            currentViewController.present(viewController, animated: true) { [unowned self] in
                self.currentViewController = SceneCoordinator.actualViewController(for: viewController)
                self.semiModalPresenter.dissmissDelegate = self
                subject.onCompleted()
            }
            
        case .photoPick(let completion):
            
            if let viewController = viewController as? PHPickerViewController {
                
                if !(currentViewController is PHPickerViewController)  {
                    
                    viewController.modalPresentationStyle = .automatic
                    viewController.modalTransitionStyle = .coverVertical
                    
                    currentViewController.present(viewController, animated: true) {
                        
                        subject.onCompleted()
                    }
                    
                    viewController.rx.imageData
                        .subscribe(onNext: { data in
                            
                            completion(data)
                            
                        })
                        .disposed(by: disposeBag)
                }
                
                
            }
            
        case .videoPick(let compeltion):
            
            if let viewController = viewController as? PHPickerViewController {
                
                if !(currentViewController is PHPickerViewController)  {
                    
                    viewController.modalPresentationStyle = .automatic
                    viewController.modalTransitionStyle = .coverVertical
                    
                    currentViewController.present(viewController, animated: true) {
                        subject.onCompleted()
                    }
                    
                    viewController.rx.videoUrl
                        .subscribe(onNext: { url in
                            compeltion(url)
                        })
                        .disposed(by: disposeBag)
                }
            }
        case .camera(let completion):
            
            if let viewController = viewController as? UIImagePickerController {
                
                currentViewController.present(viewController, animated: true) {
                    subject.onCompleted()
                    
                }
                
                viewController.rx.imageData
                    .subscribe(onNext: { data in
                        
                        completion(data)
                        
                    })
                    .disposed(by: disposeBag)
            }
            
        case .centerCard:
            
            let segue = CenterCardSegue(identifier: nil, source: currentViewController, destination: viewController) { [unowned self] in
                
                self.currentViewController = SceneCoordinator.actualViewController(for: viewController)
                subject.onCompleted()
                
            }
            
            if let viewController = viewController as? ReportViewController {
                
                let numCells = CGFloat(viewController.viewModel.reasons.count)
                let cellHeight = 43.5
                
                let headerFooterHeight = 45.0
                
                let viewControllerHeight = cellHeight * numCells + headerFooterHeight * 2.0
                
                segue.containerView.heightAnchor.constraint(equalToConstant: viewControllerHeight).isActive = true
            }
            
            segue.perform()
            
        case .web:
            
            currentViewController.present(viewController, animated: true) {
                subject.onCompleted()
            }
            
        default:
            break
        }
        
        return subject.asObservable()
            .take(1)
            .ignoreElements().asCompletable()
    }
    
    
    @discardableResult
    func pop(animated: Bool, completion: (() -> Void)? = nil) -> Completable {
        let subject = PublishSubject<Void>()
        
        
        if let presenter = currentViewController.presentingViewController {
            // dismiss a modal controller
            currentViewController.dismiss(animated: animated) {
                self.currentViewController = SceneCoordinator.actualViewController(for: presenter)
                subject.onCompleted()
                completion?()
            }
            
        } else if let navigationController = currentViewController.navigationController {
            _ = navigationController.rx.delegate
                .sentMessage(#selector(UINavigationControllerDelegate.navigationController(_:didShow:animated:)))
                .map { _ in }
                .bind(to: subject)
            guard navigationController.popViewController(animated: animated) != nil else {
                fatalError("can't navigate back from \(currentViewController)")
            }
        } else {
            fatalError("Not a modal, no navigation controller: can't navigate back from \(currentViewController)")
        }
        
        
        return subject.asObservable()
            .take(1)
            .ignoreElements().asCompletable()
    }
    
    
    @discardableResult
    func userDismissed(completion: ((Bool) -> Void)? = nil) -> Completable {
        
        let subject = PublishSubject<Void>()
        
        DispatchQueue.main.async {
            
            if let window = UIApplication.shared.windows.filter({ $0.isKeyWindow }).first, let rootViewController = window.rootViewController  {
                
                
                var topController = rootViewController
                
                while let newTopController = topController.presentedViewController {
                    topController = newTopController
                }
                
                
                self.currentViewController = SceneCoordinator.actualViewController(for: topController)
                
                subject.onCompleted()
                
                completion?(true)
                
            }
            else {
                
                completion?(false)
                
            }
        }
        
        return subject.asObservable()
            .take(1)
            .ignoreElements().asCompletable()
    }
    
    //    @discardableResult
    func dismissedViewControllerUnderNavigationController(viewController: UIViewController) {
        currentViewController = viewController
    }
    
    func cropImage(cropMode: RSKImageCropMode, imageData: Data) -> Observable<Data> {
        
        guard let image = UIImage(data: imageData) else { return Observable.just(imageData) }
        
        let imageCropVC = RSKImageCropViewController(image: image, cropMode: cropMode)
        
        imageCropVC.moveAndScaleLabel.text = "Triming"
        imageCropVC.cancelButton.setTitle("Cancel", for: .normal)
        imageCropVC.chooseButton.setTitle("Done", for: .normal)
        
        currentViewController.present(imageCropVC, animated: true)
        return imageCropVC.rx.imageData.map { $0 }
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
