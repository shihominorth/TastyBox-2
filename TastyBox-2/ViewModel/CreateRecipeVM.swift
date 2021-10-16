//
//  CreateRecipeVM.swift
//  TastyBox-2
//
//  Created by 北島　志帆美 on 2021-10-16.
//

import Foundation
import Firebase

class CreateRecipeVM: ViewModelBase {
    
    let sceneCoodinator: SceneCoordinator
    let user: Firebase.User
    
    init(sceneCoodinator: SceneCoordinator, user: Firebase.User) {
        
        self.sceneCoodinator = sceneCoodinator
        self.user = user
            
    }
    
    
}
