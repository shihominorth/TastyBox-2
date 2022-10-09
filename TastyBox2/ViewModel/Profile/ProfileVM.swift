//
//  ProfileVM.swift
//  TastyBox-2
//
//  Created by 北島　志帆美 on 2021-12-20.
//

import Foundation
import Firebase
import RxSwift


final class ProfileVM: ViewModelBase {
   
    private let sceneCoordinator: SceneCoordinator
    private let apiType: ProfileDMProtocol.Type
    let user: Firebase.User
    var recipes: [Recipe]
    var profileUser: User
    let profileImageDataSubject: PublishSubject<Data>
    let followingsNumSubject: BehaviorSubject<Int>
    let followersNumSubject: BehaviorSubject<Int>
    var isFollowingSubject: BehaviorSubject<Bool>
    
    var postedRecipesSubject = BehaviorSubject<[Recipe]>(value: [])

    
    init(sceneCoordinator: SceneCoordinator, user: Firebase.User, publisher: User, apiType: ProfileDMProtocol.Type = ProfileDM.self) {
        
        self.sceneCoordinator = sceneCoordinator
        self.user = user
        self.apiType = apiType
        self.recipes = []
        self.profileUser = publisher
       
        self.isFollowingSubject = BehaviorSubject<Bool>(value: false)
        self.followingsNumSubject = BehaviorSubject<Int>(value: 0)
        self.followersNumSubject = BehaviorSubject<Int>(value: 0)
        self.profileImageDataSubject = PublishSubject<Data>()
        
    }
    
    func getProfileImage() -> Observable<Data> {
        
        return self.apiType.getProfileImage(userID: profileUser.userID)
        
    }
    
    func isFollowingUser() -> Observable<Bool> {
        
        return self.apiType.isFollowing(publisherId: self.profileUser.userID, user: self.user)
        
    }
    
    func getUserPostedRecipes() -> Observable<[Recipe]> {
        
        return self.apiType.getPostRecipes(id: self.profileUser.userID)
        
    }
    
    func getFollowingsNum() -> Observable<(followings: Int, followeds: Int)> {
        
        return self.apiType.getUserInfo(userId: self.profileUser.userID)
    
    }
    
    func followPublisher(user: Firebase.User, publisher: User) -> Observable<Bool> {
        
        if user.uid == publisher.userID {
        
            return Observable.just(false)
        
        }
        
        return self.apiType.followUser(user: user, willFollowUser: publisher).map { true }
        
    }
    
    func unFollowPublisher(user: Firebase.User, publisher: User) -> Observable<Bool> {
        
        if user.uid == publisher.userID {
        
            return Observable.just(false)
        
        }
        
        return self.apiType.unFollowUser(user: user, willUnFollowUser: publisher).map { true }
        
    }
    
    func toRecipeDetail(recipe: Recipe) {
        
        let vm = RecipeVM(sceneCoordinator: self.sceneCoordinator, user: self.user, recipe: recipe)
        
        self.sceneCoordinator.transition(to: .recipeScene(scene: .recipe(vm)), type: .push)
            
        
    }
    
    func toRelatedUsers() {
        
        let vm = RelatedUsersVM(sceneCoordinator: self.sceneCoordinator, user: self.user, isFollowing: false, profileID: self.profileUser.userID)
        
        self.sceneCoordinator.transition(to: .profileScene(scene: .relatedUsers(vm)), type: .push)
        
    }
    
}
