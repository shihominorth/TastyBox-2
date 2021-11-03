//
//  MyProfileVM.swift
//  TastyBox-2
//
//  Created by 北島　志帆美 on 2021-11-04.
//

import Foundation
import Firebase
import RxSwift

class MyProfileVM {
    
    let sceneCoordinator: SceneCoordinator
    let user: Firebase.User
    
    var postedRecipes = BehaviorSubject<[Recipe]>(value: [])
    
    init(sceneCoordinator: SceneCoordinator, user: Firebase.User, apiType: CreateRecipeDMProtocol.Type = CreateRecipeDM.self) {
        
        self.sceneCoordinator = sceneCoordinator
        self.user = user
        
    }
    
    func getMyPostedRecipes(){
        
    }
}
