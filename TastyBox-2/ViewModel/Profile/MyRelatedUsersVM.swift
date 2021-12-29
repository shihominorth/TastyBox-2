//
//  MyRelatedUsersVM.swift
//  TastyBox-2
//
//  Created by 北島　志帆美 on 2021-12-21.
//

import Foundation
import Firebase
import RxSwift

protocol ShowUserProfileDelegate: AnyObject {
    func toProfile(relatedUser: RelatedUser)
}

protocol ManageMyRelatedUserDelegate: AnyObject {
    func manage(user: RelatedUser, isFollowing: Bool)
}

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
        
        self.presenter.followersVM.showUserProfileDelegate = self
        self.presenter.followersVM.manageMyRelatedUserDelegate = self
        self.presenter.followingsVM.showUserProfileDelegate = self
    }
    
 
}

extension MyRelatedUsersVM: ShowUserProfileDelegate {
   
    func toProfile(relatedUser: RelatedUser) {
    
        let myProfileVM = MyProfileVM(sceneCoordinator: self.sceneCoordinator, user: self.user)
        let profileVM = ProfileVM(sceneCoordinator: self.sceneCoordinator, user: self.user, publisher: relatedUser.user)

        let scene: Scene = relatedUser.user.userID == user.uid ? .profileScene(scene: .myProfile(myProfileVM)) : .profileScene(scene: .profile(profileVM))

        self.sceneCoordinator.modalTransition(to: scene, type: .push)
        
    }
    
    
}

extension MyRelatedUsersVM: ManageMyRelatedUserDelegate {

    func manage(user: RelatedUser, isFollowing: Bool) {
        
        let vm = ManageMyRelatedUserVM(sceneCoordinator: self.sceneCoordinator, user: self.user, manageUser: user, isFollowing: isFollowing)
        
        vm.delegate = self.presenter.followersVM
    
        let scene: Scene = .profileScene(scene: .manageRelatedUser(vm))
        
        self.sceneCoordinator.modalTransition(to: scene, type: .modalHalf)
        
    }
    
}


