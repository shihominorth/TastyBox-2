//
//  SceneTransitionType.swift
//  TastyBox-2
//
//  Created by 北島　志帆美 on 2021-08-29.
//

import UIKit
import RxSwift

enum SceneTransitionType {
  // you can extend this to add animated transition types,
  // interactive transitions and even child view controllers!

    case root       // make view controller the root view controller
    case push       // push view controller to navigation stack
    case pushFromBottom
    case modal(presentationStyle: UIModalPresentationStyle?, modalTransisionStyle: UIModalTransitionStyle?, hasNavigationController: Bool)      // present view controller modally
    case usePresentNC
    case VCAsRoot
    case modalHalf
    case imagePick
    case photoPick(completion: (Data) -> Void)
    case videoPick(compeletion: (URL) -> Void)
    case camera(completion: (Data) -> Void)
    case centerCard
}
