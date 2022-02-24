//
//  TutorialVM.swift
//  TastyBox-2
//
//  Created by 北島　志帆美 on 2021-09-17.
//

import Foundation

class TutorialVM: ViewModelBase {

    let sceneCoodinator: SceneCoordinator
    let apiType: LoginMainProtocol.Type
    
    var explainations: [Tutorial]
    
    init(sceneCoodinator: SceneCoordinator, apiType: LoginMainProtocol.Type = LoginMainDM.self) {
        
        self.sceneCoodinator = sceneCoodinator
        self.apiType = apiType
        self.explainations = []
        
    }
    
    func toLogin() {
        
        let vm = LoginMainVM(sceneCoodinator: self.sceneCoodinator)
        let scene: Scene = .loginScene(scene: .main(vm))
        
        self.sceneCoodinator.transition(to: scene, type: .modal(presentationStyle: .fullScreen, modalTransisionStyle: .crossDissolve, hasNavigationController: false))
        
    }
    
}
