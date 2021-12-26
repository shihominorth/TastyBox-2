//
//  RelatedUsersVM.swift
//  TastyBox-2
//
//  Created by 北島　志帆美 on 2021-12-23.
//

import Foundation
import Firebase
import RxSwift


protocol ManageRelatedUserDelegate: AnyObject {
    
    func manage(user: RelatedUser, isFollowing: Bool)
//    func toProfile(user: User)
    
}

class RelatedUsersVM: ViewModelBase {
    
    let sceneCoordinator: SceneCoordinator
    let user: Firebase.User
    let apiType: ProfileDMProtocol.Type
    let selectIndexSubject: BehaviorSubject<Int>
    
    let presenter: RelatedUserPresenter
    
    init(sceneCoordinator: SceneCoordinator, user: Firebase.User, apiType: ProfileDMProtocol.Type = ProfileDM.self, isFollowing: Bool, profileID: String) {
        
        self.sceneCoordinator = sceneCoordinator
        self.user = user
        self.apiType = apiType
        
        let index = isFollowing ? 0 : 1
        
        self.selectIndexSubject = BehaviorSubject<Int>(value: index)
                
        self.presenter = RelatedUserPresenter(userId: profileID, user: self.user, isMyRelatedUsers: false)
        
        super.init()
        
        self.presenter.followersVM.delegate = self
                
        
    }
    

}

extension RelatedUsersVM: ManageRelatedUserDelegate {
   
    func manage(user: RelatedUser, isFollowing: Bool) {
        
        let vm = ManageRelatedUserVM(sceneCoordinator: self.sceneCoordinator, user: self.user, manageUser: user, isFollowing: isFollowing)
    
        let scene: Scene = .profileScene(scene: .manageRelatedUser(vm))
        
        self.sceneCoordinator.modalTransition(to: scene, type: .modalHalf)
        
    }

}
