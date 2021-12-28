//
//  FollowersVM.swift
//  TastyBox-2
//
//  Created by 北島　志帆美 on 2021-12-25.
//

import Foundation
import Firebase
import RxSwift


class FollowersVM: ViewModelBase {
    
    let user: Firebase.User
    let apiType: RelatedUsersProtocol.Type
    
    var users: [RelatedUser]
    let usersSubject: BehaviorSubject<[RelatedUser]>
    let userID: String
    weak var showManageUserDelegate: ShowManageUserDelegate?
    
    init(user: Firebase.User, apiType: RelatedUsersProtocol.Type = RelatedUsersDM.self, userID: String) {
        
        self.user = user
        self.apiType = apiType
        self.usersSubject = BehaviorSubject<[RelatedUser]>(value: [])
        self.users = []
        self.userID = userID
        
    }
    
    func getFollowers() -> Observable<[RelatedUser]> {
        
        return self.apiType.getFollowers(user: self.user, userID: self.userID)
        
    }
    
    func updateRelatedUserStatus(isFollowing: Bool, updateUser: User) -> Observable<Bool> {

        if isFollowing {
            
            return self.apiType.unFollowUser(user: self.user, willUnFollowUser: updateUser).map { isFollowing }
        }
        else {
            
            return self.apiType.followUser(user: self.user, willFollowUser: updateUser).map { isFollowing }
            
        }
        
    }
    
    func toManageRelatedUserVC(user: RelatedUser, isFollowing: Bool) {
        
        showManageUserDelegate?.manage(user: user, isFollowing: isFollowing)
        
    }
    
    
}

extension FollowersVM: ManageUserDelegate {
    
    func delete(user: RelatedUser) {
        
        self.apiType.delete(user: self.user, follower: user)
            .withLatestFrom(usersSubject)
            .subscribe(onNext: { [unowned self] users in
                
                let newUsers = users.filter { $0.userID != user.userID }
                
                self.usersSubject.onNext(newUsers)
                
            })
            .disposed(by: disposeBag)
            
        
    }
}
