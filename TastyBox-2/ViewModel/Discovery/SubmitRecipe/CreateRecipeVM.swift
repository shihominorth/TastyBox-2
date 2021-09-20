//
//  CreateRecipeVM.swift
//  TastyBox-2
//
//  Created by 北島　志帆美 on 2021-09-21.
//

import Foundation
import Firebase

class CreateRecipeVM {

  
    let sceneCoodinator: SceneCoordinator
    let apiType: LoginMainProtocol.Type
    var user: FirebaseAuth.User?
    var err = NSError()
    
    
    init(sceneCoodinator: SceneCoordinator, apiType: LoginMainProtocol.Type = LoginMainDM.self) {
        self.sceneCoodinator = sceneCoodinator
        self.apiType = apiType
    }
    

}
