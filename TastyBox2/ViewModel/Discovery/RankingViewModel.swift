//
//  RankingVM.swift
//  TastyBox-2
//
//  Created by 北島　志帆美 on 2021-11-18.
//

import Foundation
import Firebase
import RxSwift

protocol toRecipeDetailDelegate: AnyObject {
    func selectedRecipe(recipe: Recipe)
}

final class RankingViewModel: ViewModelBase {
    let user: Firebase.User
    let apiType: MainDMProtocol.Type
    
    var recipesSubject = BehaviorSubject<[Recipe]>(value: [])
    var pubishers: [String: User] = [:]
    var recipeRanking: [(recipeID: String, rank: Int)] = []
    
    let selectedRecipeSubject: PublishSubject<Recipe>

    weak var delegate: toRecipeDetailDelegate?
    
    init(user: Firebase.User, apiType: MainDMProtocol.Type = MainDM.self) {
        self.user = user
        self.apiType = apiType
        self.selectedRecipeSubject = PublishSubject<Recipe>()
    }
    
    func getRecipesRanking() -> Observable<[Recipe]> {
        return self.apiType.getRecipesRanking()
            .do(onNext: { [unowned self] recipes in
                
                let ranking = Dictionary(grouping: recipes, by: { $0.likes })
                    .sorted(by: { $0.key > $1.key })
                    .enumerated()
                    .flatMap { (offset, elem) in
                        elem.value.map { (recipeID: $0.recipeID, rank: offset + 1 )}
                    }
                
                self.recipeRanking = ranking
            })
    }
    
    func getPublisher(recipes: [Recipe]) -> Observable<[String: User]> {
        let ids = recipes.map { $0.userID }

        return self.apiType.getPublishers(ids: ids)
            .do(onNext: { [unowned self] dic in
                
                self.pubishers = dic
                
            })
    }
}
