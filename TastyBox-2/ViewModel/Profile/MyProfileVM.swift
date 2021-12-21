//
//  MyProfileVM.swift
//  TastyBox-2
//
//  Created by 北島　志帆美 on 2021-11-04.
//

import Foundation
import Firebase
import RxSwift
import RxCocoa
import SCLAlertView

class MyProfileVM: ViewModelBase {
    
    let sceneCoordinator: SceneCoordinator
    let user: Firebase.User
    let apiType: MyProfileDMProtocol.Type
    
    let followingsNumSubject: BehaviorSubject<Int>
    let followedSubject: BehaviorSubject<Int>
    let postedRecipesSubject: BehaviorSubject<[Recipe]>
    
    init(sceneCoordinator: SceneCoordinator, user: Firebase.User, apiType: MyProfileDMProtocol.Type = MyProfileDM.self) {
        
        self.sceneCoordinator = sceneCoordinator
        self.user = user
        self.apiType = apiType
        self.postedRecipesSubject = BehaviorSubject<[Recipe]>(value: [])
        self.followingsNumSubject = BehaviorSubject<Int>(value: 0)
        self.followedSubject = BehaviorSubject<Int>(value: 0)
        
    }
    
    func getMyPostedRecipes() -> Observable<[Recipe]> {
        
        return self.apiType.getMyPostedRecipes(user: self.user)
            .catch { err in
                
                err.handleStorageError()?.showErrNotification()
                
                print(err)
                
                return .empty()
            }
        
        
    }
    
    func getMyFollowings() -> Observable<(followings:Int, followeds:Int)> {
        return self.apiType.getMyInfo(user: self.user)
    }
    
    
    func toRecipeDetail(recipe: Recipe) {
        
        let vm = RecipeVM(sceneCoordinator: self.sceneCoordinator, user: self.user, recipe: recipe)
        
        self.sceneCoordinator.modalTransition(to: .recipeScene(scene: .recipe(vm)), type: .push)
            
        
    }
    
    func toMyRelatedUsersVC(isFollowing: Bool) {
        
        self.sceneCoordinator.modalTransition(to: .profileScene(scene: .relatedUsers), type: .push)
        
    }
}
