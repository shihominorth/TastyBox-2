//
//  PublishRecipeVM.swift
//  TastyBox-2
//
//  Created by 北島　志帆美 on 2021-10-27.
//

import Foundation
import Firebase
import UIKit
import RxSwift

class PublishRecipeVM: ViewModelBase {
    
    let sceneCoodinator: SceneCoordinator
    let user: Firebase.User
    
    let recipeData:[String: Any]
    let instructionsData: [[String: Any]]
    let ingredientsData: [[String: Any]]
    let genresData: [[String: Any]]
    
    let apiType: CreateRecipeDMProtocol.Type
    
    var options:[(Data, String)]
    
    let tappedPublishSubject = PublishSubject<Void>()
    
    init(sceneCoodinator: SceneCoordinator, user: Firebase.User, apiType: CreateRecipeDMProtocol.Type = CreateRecipeDM.self, recipeData: [String: Any], ingredientsData: [[String: Any]], instructionsData: [[String: Any]], genresData: [[String: Any]], isVIP: Bool) {
        
        self.sceneCoodinator = sceneCoodinator
        self.user = user
        self.apiType = apiType
        self.options = []
        
        self.recipeData = recipeData
        self.ingredientsData = ingredientsData
        self.instructionsData = instructionsData
        self.genresData = genresData
        
        if let cancelBtnData = UIImage(systemName: "arrowshape.turn.up.backward")?.convertToData(), let publishNormalBtnData = UIImage(systemName: "square.and.arrow.up")?.convertToData() {
            
            let publishTitle = isVIP ? "Publish VIP Only Recipe" : "Publish Your Recipe"
            var publishBtnData = publishNormalBtnData
            
            if let vipOnlyRecipe = UIImage(systemName: "rosette")?.convertToData() {
                
                publishBtnData = isVIP ? vipOnlyRecipe : publishBtnData
            }
            
            self.options = [(publishBtnData, publishTitle), (cancelBtnData, "Cancel")]
        }
        
    
    }
    
    // upload image and video
    func uploadRecipe() {
        
       let updateRecipe = tappedPublishSubject
            .share(replay: 1, scope: .forever)
            .flatMapLatest { [unowned self] in
                self.apiType.updateRecipe(recipeData: recipeData, ingredientsData: ingredientsData, instructionsData: instructionsData, user: self.user)
            }
            
        let updateGenres = tappedPublishSubject
            .share(replay: 1, scope: .forever)
            .flatMapLatest { [unowned self] in
                self.apiType.updateUserInterestedGenres(genresData: genresData, user: self.user)
            }
    
    updateRecipe
            .subscribe(onNext: { data in
                
                print("succeed to update recipe")
                
            }, onError: { err in
                
                print(err)
                
            })
            .disposed(by: disposeBag)
        
        updateGenres
            .subscribe(onNext: { data in
                
                print("succeed to update genres")
                
            }, onError: { err in
                
                print(err)
                
            })
            .disposed(by: disposeBag)
        
    }
    
}
