//
//  AboutViewModel.swift
//  TastyBox-2
//
//  Created by 北島　志帆美 on 2021-09-01.
//

import Foundation

enum isFrom {
    case main, registerEmail
}

class AboutViewModel {
    
    let sceneCoodinator: SceneCoordinator
    let isAgreed: Bool
    
    //必要なさそう
    let prevVC: isFrom
  
    
    init(sceneCoodinator: SceneCoordinator, prevVC: isFrom, isAgreed: Bool) {
        self.sceneCoodinator = sceneCoodinator
        self.prevVC = prevVC
        self.isAgreed = isAgreed
    }
    
    
}
