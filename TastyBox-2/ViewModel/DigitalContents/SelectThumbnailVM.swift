//
//  SelectThumbnailVM.swift
//  TastyBox-2
//
//  Created by 北島　志帆美 on 2021-12-17.
//

import Foundation
import Firebase


class SelectThumbnailVM: ViewModelBase {
    
    let sceneCoodinator: SceneCoordinator
    let user: Firebase.User
    let apiType: CreateRecipeDMProtocol.Type
    var imageData: Data
    
    
    init(sceneCoodinator: SceneCoordinator, user: Firebase.User, apiType: CreateRecipeDMProtocol.Type = CreateRecipeDM.self, imageData: Data) {
        
        self.sceneCoodinator = sceneCoodinator
        self.user = user
        self.apiType = apiType
        self.imageData = imageData
        
    }
    
    func selectThumbnail() {
        
        let vm = SelectDigitalContentsVM(sceneCoodinator: self.sceneCoodinator, user: self.user, kind: .recipeMain(.image), isEnableSelectOnlyOneDigitalContentType: true)
        let scene: Scene = .digitalContentsPickerScene(scene: .selectDigitalContents(vm))
        
        self.sceneCoodinator.modalTransition(to: scene, type: .modal(presentationStyle: .fullScreen, modalTransisionStyle: .coverVertical, hasNavigationController: true))
        
//        self.sceneCoodinator.modalTransition(to: scene, type: .push)
        
    }
    
}
