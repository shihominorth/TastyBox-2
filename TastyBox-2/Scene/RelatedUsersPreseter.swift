//
//  RelatedUsersPreseter.swift
//  TastyBox-2
//
//  Created by 北島　志帆美 on 2021-12-21.
//

import UIKit
import Firebase

class RelatedUserPresenter {
    
    let user: Firebase.User
    var followingsVC: FollowingsViewController
    var followedsVC: FollowersViewController
    
    init(userId: String, user: Firebase.User, isMyRelatedUsers: Bool) {
      
        let storyBoard = UIStoryboard(name: "Profile", bundle: nil)
        
        let followingsVM = FolllowingsVM(user: user, userID: userId)
        let followingsVC = storyBoard.instantiateViewController(withIdentifier: "followingsVC") as! FollowingsViewController
        
        self.user = user
        
        self.followingsVC = followingsVC
        self.followingsVC.bindViewModel(to: followingsVM)
        
        let followedsVM = FollowersVM(user: self.user, userID: userId)
        let followedsVC = storyBoard.instantiateViewController(withIdentifier: "followedsVC") as! FollowersViewController
        
        self.followedsVC = followedsVC
        self.followedsVC.bindViewModel(to: followedsVM)
        
        
        
        
    }
    

}
