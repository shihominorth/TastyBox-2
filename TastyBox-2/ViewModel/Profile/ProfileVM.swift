//
//  ProfileVM.swift
//  TastyBox-2
//
//  Created by 北島　志帆美 on 2021-12-20.
//

import Foundation
import Firebase
import RxSwift


class ProfileVM: ViewModelBase {
   
    let sceneCoordinator: SceneCoordinator
    let user: Firebase.User
    let apiType: ProfileDMProtocol.Type
    var recipes: [Recipe]
    var publisher: User
    
    var postedRecipesSubject = BehaviorSubject<[Recipe]>(value: [])
    
    init(sceneCoordinator: SceneCoordinator, user: Firebase.User, publisher: User, apiType: ProfileDMProtocol.Type = ProfileDM.self) {
        
        self.sceneCoordinator = sceneCoordinator
        self.user = user
        self.apiType = apiType
        self.recipes = []
        self.publisher = publisher
        
    }
    
    func getUserPostedRecipes() -> Observable<[Recipe]> {
        
        return self.apiType.getPostRecipes(id: self.publisher.userID)
        
    }
    
    
    func toRecipeDetail(recipe: Recipe) {
        
        let vm = RecipeVM(sceneCoordinator: self.sceneCoordinator, user: self.user, recipe: recipe)
        
        self.sceneCoordinator.modalTransition(to: .recipeScene(scene: .recipe(vm)), type: .push)
            
        
    }
    
}
