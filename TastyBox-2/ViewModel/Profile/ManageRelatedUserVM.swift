//
//  ManageRelatedUserVM.swift
//  TastyBox-2
//
//  Created by 北島　志帆美 on 2021-12-26.
//

import Foundation
import Firebase

class ManageRelatedUserVM: ViewModelBase {
    
    let sceneCoordinator: SceneCoordinator
    let user: Firebase.User
    let apiType: ProfileDMProtocol.Type
    let manageUser: RelatedUser
    
    
    init(sceneCoordinator: SceneCoordinator, user: Firebase.User, apiType: ProfileDMProtocol.Type = ProfileDM.self, manageUser: RelatedUser, isFollowing: Bool) {
        
        self.sceneCoordinator = sceneCoordinator
        self.user = user
        self.apiType = apiType
                                        
        self.manageUser = manageUser
        
    }
    
}
