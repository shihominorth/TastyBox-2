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

final class MyProfileVM: ViewModelBase {
    
    private let sceneCoordinator: SceneCoordinator
    private let apiType: MyProfileDMProtocol.Type
    let user: Firebase.User
    
    let myProfileImageDataSubject: PublishSubject<Data>
    let followingsNumSubject: BehaviorSubject<Int>
    let followersNumSubject: BehaviorSubject<Int>
    let postedRecipesSubject: BehaviorSubject<[Recipe]>
    
    init(sceneCoordinator: SceneCoordinator, user: Firebase.User, apiType: MyProfileDMProtocol.Type = MyProfileDM.self) {
        
        self.sceneCoordinator = sceneCoordinator
        self.user = user
        self.apiType = apiType
        self.myProfileImageDataSubject = PublishSubject<Data>()
        self.postedRecipesSubject = BehaviorSubject<[Recipe]>(value: [])
        self.followingsNumSubject = BehaviorSubject<Int>(value: 0)
        self.followersNumSubject = BehaviorSubject<Int>(value: 0)
        
    }
    
    func getProfileImage() -> Observable<Data> {
        
        return self.apiType.getMyProfileImage(user: user)
        
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
        
        self.sceneCoordinator.transition(to: .recipeScene(scene: .recipe(vm)), type: .push)
            
        
    }
    
    func toMyRelatedUsersVC(isFollowing: Bool) {
        
        let vm = MyRelatedUsersVM(sceneCoordinator: self.sceneCoordinator, user: self.user, isFollowing: isFollowing)
        
        self.sceneCoordinator.transition(to: .profileScene(scene: .myRelatedUsers(vm)), type: .push)
        
    }
}
