//
//  SemiModalDismissAnimatedTransition.swift
//  TastyBox-2
//
//  Created by 北島　志帆美 on 2021-10-08.
//

import UIKit

/// セミモーダルのdismissのアニメーター
final class SemiModalDismissAnimatedTransition: NSObject {
}

// MARK: - UIViewControllerAnimatedTransitioning
extension SemiModalDismissAnimatedTransition: UIViewControllerAnimatedTransitioning {

    /// transitionの時間
    /// - Parameter transitionContext:
    /// - Returns:
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.4
    }

    /// アニメーションtransition
    /// - Parameter transitionContext:
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
       
        UIView.animate(
            withDuration: transitionDuration(using: transitionContext),
            delay: 0.0,
            options: .curveEaseInOut,
            animations: {
                guard let fromView = transitionContext.view(forKey: .from) else { return }
                // Viewを下にスライドさせる
                fromView.center.y = UIScreen.main.bounds.size.height + fromView.bounds.height / 2
            },
            completion: { _ in
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            }
        )
    }
}
