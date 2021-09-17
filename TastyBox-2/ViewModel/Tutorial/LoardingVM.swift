//
//  LoardingVM.swift
//  TastyBox-2
//
//  Created by 北島　志帆美 on 2021-09-17.
//

import Foundation

class LoardingVM: ViewModelBase {

    let sceneCoodinator: SceneCoordinator
    let apiType: LoginMainProtocol.Type
    
    init(sceneCoodinator: SceneCoordinator, apiType: LoginMainProtocol.Type = LoginMainDM.self) {
        self.sceneCoodinator = sceneCoodinator
        self.apiType = apiType
        
        
    }
}
