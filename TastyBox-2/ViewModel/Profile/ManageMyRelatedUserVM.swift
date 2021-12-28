//
//  ManageRelatedUserVM.swift
//  TastyBox-2
//
//  Created by 北島　志帆美 on 2021-12-26.
//

import Foundation
import Firebase

protocol ManageUserDelegate: AnyObject {
    func delete(user: RelatedUser)
}

class ManageMyRelatedUserVM: ViewModelBase {
    
    let sceneCoordinator: SceneCoordinator
    let user: Firebase.User
    let apiType: MyProfileDMProtocol.Type
    let manageUser: RelatedUser
    weak var delegate: ManageUserDelegate?
    
    init(sceneCoordinator: SceneCoordinator, user: Firebase.User, apiType: MyProfileDMProtocol.Type = MyProfileDM.self, manageUser: RelatedUser, isFollowing: Bool) {
        
        self.sceneCoordinator = sceneCoordinator
        self.user = user
        self.apiType = apiType
                                        
        self.manageUser = manageUser
        
    }
    
    func delete() {
        
        self.sceneCoordinator.pop(animated: true, completion: { [unowned self] in
                self.delegate?.delete(user: manageUser)
        })
        
    }
    
    func cancel() {
        
        self.sceneCoordinator.pop(animated: true)
    
    }
}
