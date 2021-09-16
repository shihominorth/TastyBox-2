//
//  DiscoveryViewModel.swift
//  TastyBox-2
//
//  Created by 北島　志帆美 on 2021-09-01.
//

import Foundation
import Firebase

class DiscoveryVM {
    
//    let apiType: RegisterMyInfoProtocol.Type
    let sceneCoodinator: SceneCoordinator
    let user: Firebase.User
    
    init(sceneCoodinator: SceneCoordinator, user:  Firebase.User) {
        
        self.sceneCoodinator = sceneCoodinator
//        self.apiType = apiType
        
        self.user = user
        
       
    }
    
}
