//
//  EditShoppingItemController.swift
//  TastyBox-2
//
//  Created by 北島　志帆美 on 2021-10-08.
//

import UIKit
import RxSwift

protocol KeyboardStatusProtocol {
    static var isOpenOnce: Bool { get }
    static func countUpOpen()
}

enum KeyboardOpenStatus: KeyboardStatusProtocol {
 
    case open, close
    
    static var isOpenOnce: Bool = false
    
    static func countUpOpen() {
       
    }
}

/// セミモーダル表示のレイアウト実装
final class SemiModalPresentationController: UIPresentationController {
    
    private var keyboardHeight: CGFloat = 0.0
    private let disposeBag = DisposeBag()
    private var isKeyboardShown = false
    private var keyboardOpenStatus: KeyboardOpenStatus = .close
    
    // MARK: Override Properties
    /// 表示transitionの終わりのViewのframe
    override var frameOfPresentedViewInContainerView: CGRect {
        
        guard let containerView = containerView else { return CGRect.zero }
        var presentedViewFrame = CGRect.zero
        let containerBounds = containerView.bounds
        presentedViewFrame.size = self.size(forChildContentContainer: self.presentedViewController, withParentContainerSize: containerBounds.size)
        
        presentedViewFrame.origin.x = containerBounds.size.width - presentedViewFrame.size.width
        
//        if isKeyboardShown {
//            presentedViewFrame.origin.y = UIScreen.main.bounds.maxY - presentedViewFrame.size.height
//        }
//        else {
        presentedViewFrame.origin.y = containerBounds.size.height - presentedViewFrame.size.height - keyboardHeight
//        }
        

       

        return presentedViewFrame
    }
    
    // MARK: Private Properties
    /// オーバーレイ
    private let overlay: SemiModalOverlayView
    
    /// インジケータ
    private let indicator: SemiModalIndicatorView
    
    
    
    /// セミモーダルの高さのデフォルト比率
    private let presentedViewControllerHeightRatio: CGFloat = 0.5
    
    // MARK: Initializer
    init(presentedViewController: UIViewController, presenting presentingViewController: UIViewController?, overlayView: SemiModalOverlayView, indicator: SemiModalIndicatorView) {
        self.overlay = overlayView
        self.indicator = indicator
        
        super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
        
        let _ = NotificationCenter.default.rx.notification(UIResponder.keyboardWillShowNotification)
            .observe(on: MainScheduler.asyncInstance)
            .subscribe(onNext: { [unowned self] notification in
                
                if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue, let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval, let curveNumber = notification.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber
                {
                    
                    let curve: UIView.AnimationOptions = UIView.AnimationOptions(rawValue: UInt(truncating: curveNumber))
                    
                    guard let presentedView = presentedView else {
                        return
                    }
                    
                    self.keyboardHeight = keyboardSize.height
                    let frame = frameOfPresentedViewInContainerView
                    
                    UIView.animate(
                        withDuration: duration,
                        delay: 0.0,
                        options: [.beginFromCurrentState, .allowUserInteraction, curve],
                        animations: {
                            presentedView.frame = frame
                            presentedView.layoutIfNeeded()
                        })
                    { [unowned self] isCompleted in
                        
                        if isCompleted {
                            self.isKeyboardShown = true
                        }
                    }
                    
                }
            })
            .disposed(by: self.disposeBag)
        
        
        NotificationCenter.default.rx.notification(UIResponder.keyboardWillHideNotification)
            .observe(on: MainScheduler.asyncInstance)
            .subscribe(onNext: {  [unowned self] notification in
                
                
                if  let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue, let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval, let curveNumber = notification.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber
                {

                    let curve: UIView.AnimationOptions = UIView.AnimationOptions(rawValue: UInt(truncating: curveNumber))
                    guard let presentedView = presentedView else {
                        return
                    }

                    self.keyboardHeight = 0.0
                    let frame = frameOfPresentedViewInContainerView


                    UIView.animate(
                        withDuration: duration,
                        delay: 0.0,
                        options: [.beginFromCurrentState, .allowUserInteraction, curve],
                        animations: {
                            presentedView.frame = frame
                            presentedView.layoutIfNeeded()
                        })  { [unowned self] isCompleted in

                            if isCompleted {
                                self.isKeyboardShown = false
                            }
                        }

                }
                
            })
            .disposed(by: self.disposeBag)
    }
    
    // MARK: Override Functions
    /// 表示されるViewのサイズ
    /// - Parameters:
    ///   - container: コンテナ
    ///   - parentSize: 親Viewのサイズ
    /// - Returns: サイズ
    override func size(forChildContentContainer container: UIContentContainer, withParentContainerSize parentSize: CGSize) -> CGSize {
        // delegateで高さが指定されていれば、そちらを優先する
        if let delegate = presentedViewController as? SemiModalPresenterDelegate {
            return CGSize(width: parentSize.width, height: delegate.semiModalContentHeight)
        }
        // 上記でなければ、高さは比率で計算する
        return CGSize(width: parentSize.width, height: parentSize.height * self.presentedViewControllerHeightRatio)
    }
    
    
    /// Subviewsのレイアウト
    override func containerViewWillLayoutSubviews() {
        guard let containerView = containerView else { return }
        
        // overlay
        // containerViewと同じ大きさで、一番上のレイヤーに挿入する
        overlay.frame = containerView.bounds
        containerView.insertSubview(overlay, at: 0)
        
        // presentedView
        // frameの大きさ設定、左上と右上を角丸にする
        presentedView?.frame = frameOfPresentedViewInContainerView
        presentedView?.layer.cornerRadius = 10.0
        presentedView?.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        
        // indicator
        // 中央上部に配置する
        indicator.frame = CGRect(x: 0, y: 0, width: 60, height: 8)
        presentedViewController.view.addSubview(indicator)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            indicator.centerXAnchor.constraint(equalTo: presentedViewController.view.centerXAnchor),
            indicator.topAnchor.constraint(equalTo: presentedViewController.view.topAnchor, constant: -16),
            indicator.widthAnchor.constraint(equalToConstant: indicator.frame.width),
            indicator.heightAnchor.constraint(equalToConstant: indicator.frame.height)
        ])
    }
    
    /// presentation transition 開始
    override func presentationTransitionWillBegin() {
        presentedViewController.transitionCoordinator?.animate(alongsideTransition: { _ in
            self.overlay.isActive = true
        }, completion: nil)
    }
    
    /// dismiss transition 開始
    override func dismissalTransitionWillBegin() {
        self.presentedViewController.transitionCoordinator?.animate(alongsideTransition: { _ in
            self.overlay.isActive = false
        }, completion: nil)
    }
    
    /// dismiss transition 終了
    /// - Parameter completed:
    override func dismissalTransitionDidEnd(_ completed: Bool) {
        if completed {
            overlay.removeFromSuperview()
        }
    }
    
}
