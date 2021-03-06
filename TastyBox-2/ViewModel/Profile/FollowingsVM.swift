//
//  FollowingsVM.swift
//  TastyBox-2
//
//  Created by 北島　志帆美 on 2021-12-22.
//

import Foundation
import Firebase
import RxSwift

final class FolllowingsVM: ViewModelBase {
    
    private let apiType: RelatedUsersProtocol.Type
    let user: Firebase.User
    
    let usersSubject: BehaviorSubject<[RelatedUser]>
    let userID: String
    
    weak var showUserProfileDelegate: ShowUserProfileDelegate?
    
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
    
    func toProfile(user: RelatedUser) {
        
        showUserProfileDelegate?.toProfile(relatedUser: user)
        
    }
    
}
