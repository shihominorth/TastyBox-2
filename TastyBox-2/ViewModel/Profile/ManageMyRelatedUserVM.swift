//
//  ManageRelatedUserVM.swift
//  TastyBox-2
//
//  Created by 北島　志帆美 on 2021-12-26.
//

import Foundation
import Firebase

protocol ManageUserDelegate: AnyObject {
    func delete(follower: RelatedUser)
}

final class ManageMyRelatedUserVM: ViewModelBase {
    
    private let sceneCoordinator: SceneCoordinator
    private let apiType: MyProfileDMProtocol.Type
    
    let user: Firebase.User
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
                self.delegate?.delete(follower: manageUser)
        })
        
    }
    
    func cancel() {
        
        self.sceneCoordinator.pop(animated: true)
    
    }
}
