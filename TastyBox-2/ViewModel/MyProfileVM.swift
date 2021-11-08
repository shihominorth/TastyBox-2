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
    
    
    var postedRecipesSubject = BehaviorSubject<[Recipe]>(value: [])
    
    init(sceneCoordinator: SceneCoordinator, user: Firebase.User, apiType: MyProfileDMProtocol.Type = MyProfileDM.self) {
        
        self.sceneCoordinator = sceneCoordinator
        self.user = user
        self.apiType = apiType
        
    }
    
    func getMyPostedRecipes(){
        
//        DispatchQueue.global(qos: .background).async { [unowned self] in
//
//            DispatchQueue.main.async {
                
                self.apiType.getMyPostedRecipes(user: self.user)
                    .subscribe(onNext: { recipes in
                        
                        self.postedRecipesSubject.onNext(recipes)
                        
                    }, onError: { err in
                        
                        guard let reason = err.handleStorageError() else { return }
                        
                        SCLAlertView().showTitle(
                            reason.reason, // Title of view
                            subTitle: reason.solution,
                            timeout: .none, // String of view
                            completeText: "Done", // Optional button value, default: ""
                            style: .error, // Styles - see below.
                            colorStyle: 0xA429FF,
                            colorTextButton: 0xFFFFFF
                        )
                        
                    })
                    .disposed(by: self.disposeBag)
                
//            }
//        }
//        
        
    }
    
    
    func toRecipeDetail(recipe: Recipe) {
        
        let vm = RecipeVM(sceneCoordinator: self.sceneCoordinator, user: self.user, recipe: recipe)
        
        self.sceneCoordinator.modalTransition(to: .recipeScene(scene: .recipe(vm)), type: .push)
        
    }
    
    
}
