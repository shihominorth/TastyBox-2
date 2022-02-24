//
//  AboutViewModel.swift
//  TastyBox-2
//
//  Created by 北島　志帆美 on 2021-09-01.
//

import Foundation
import Action

enum isFrom {
    case main, registerEmail
}

final class AboutViewModel {
    
    let sceneCoodinator: SceneCoordinator
    let isAgreed: Bool
    
    //必要なさそう
    let prevVC: isFrom
  
    
    init(sceneCoodinator: SceneCoordinator, prevVC: isFrom, isAgreed: Bool) {
        self.sceneCoodinator = sceneCoodinator
        self.prevVC = prevVC
        self.isAgreed = isAgreed
    }
    
//    func agreeAction() -> CocoaAction {
//        return CocoaAction { _ in
//
//            let viewModel = DiscoveryViewModel()
//
//            return self.sceneCoodinator.transition(to: <#T##UIViewController#>, type: <#T##SceneTransitionType#>)
//
//        }
//    }
    
}
