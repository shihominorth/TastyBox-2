//
//  FollowingsVM.swift
//  TastyBox-2
//
//  Created by 北島　志帆美 on 2021-12-22.
//

import Foundation
import Firebase
import RxSwift

class FolllowingsVM: ViewModelBase {
    
    let user: Firebase.User
    let apiType: RelatedUsersProtocol.Type
    
    let usersSubject: BehaviorSubject<[RelatedUser]>
    let userID: String
    
    init(user: Firebase.User, apiType: RelatedUsersProtocol.Type = RelatedUsersDM.self, userID: String) {
        
        self.user = user
        self.apiType = apiType
        self.usersSubject = BehaviorSubject<[RelatedUser]>(value: [])
        self.userID = userID
        
    }
    
    
    func getFollowings() -> Observable<[RelatedUser]> {
        
        return self.apiType.getFollowings(user: self.user, userID: userID)
        
    }
    
    func updateRelatedUserStatus(isFollowing: Bool, updateUser: User) -> Observable<Bool> {

        if isFollowing {
            
            return self.apiType.unFollowUser(user: self.user, willUnFollowUser: updateUser).map { isFollowing }
        }
        else {
            
            return self.apiType.followUser(user: self.user, willFollowUser: updateUser).map { isFollowing }
            
        }
        
    }
    
}
