//
//  MyRelatedUsersVM.swift
//  TastyBox-2
//
//  Created by 北島　志帆美 on 2021-12-21.
//

import Foundation
import Firebase
import RxSwift

class MyRelatedUsersVM: ViewModelBase {
    
    let sceneCoordinator: SceneCoordinator
    let user: Firebase.User
    let apiType: MyProfileDMProtocol.Type
    let selectIndexSubject: BehaviorSubject<Int>
    
    let presenter: RelatedUserPresenter
    
    init(sceneCoordinator: SceneCoordinator, user: Firebase.User, apiType: MyProfileDMProtocol.Type = MyProfileDM.self, isFollowing: Bool) {
        
        self.sceneCoordinator = sceneCoordinator
        self.user = user
        self.apiType = apiType
        
        let index = isFollowing ? 0 : 1
        
        self.selectIndexSubject = BehaviorSubject<Int>(value: index)
        self.presenter = RelatedUserPresenter(userId: self.user.uid, user: self.user, isMyRelatedUsers: true)
        
        super.init()
        
        self.presenter.followersVM.delegate = self
                
    }
    
 
}

extension MyRelatedUsersVM: ManageRelatedUserDelegate {
   
    func manage(user: RelatedUser, isFollowing: Bool) {
        
        let vm = ManageRelatedUserVM(sceneCoordinator: self.sceneCoordinator, user: self.user, manageUser: user, isFollowing: isFollowing)
    
        let scene: Scene = .profileScene(scene: .manageRelatedUser(vm))
        
        self.sceneCoordinator.modalTransition(to: scene, type: .modalHalf)
        
    }

}
