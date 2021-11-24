//
//  IngredientsVM.swift
//  TastyBox-2
//
//  Created by 北島　志帆美 on 2021-11-21.
//

import Foundation
import Firebase
import RxSwift

class IngredientsVM: ViewModelBase {
    
    let user: Firebase.User
    let apiType: MainDMProtocol.Type
    
    let recipesSubject: BehaviorSubject<[Recipe]>
   
    let ingredientCollectionViewSubject: BehaviorSubject<[Ingredient]>
    let ingredientSubject: BehaviorSubject<[Ingredient]>
    
    let selectedIngredientSubject: BehaviorSubject<Int>
    
    let selectedRecipeSubject: PublishSubject<Recipe>

    weak var delegate: RankingVMDelegate?
    
    init(user: Firebase.User, apiType: MainDMProtocol.Type = MainDM.self) {
        
        self.user = user
        self.apiType = apiType
     
        self.selectedRecipeSubject = PublishSubject<Recipe>()
        self.selectedIngredientSubject = BehaviorSubject<Int>(value: 0)
     
        self.recipesSubject = BehaviorSubject<[Recipe]>(value: [])
     
        self.ingredientSubject = BehaviorSubject<[Ingredient]>(value: [])
        self.ingredientCollectionViewSubject = BehaviorSubject<[Ingredient]>(value: [])
    }
    
    func getRefrigeratorIngredients() -> Observable<[Ingredient]> {

        return self.apiType.getRefrigeratorIngredients(user: self.user)

    }
    
    func getRecipes(allIngredients: [Ingredient]) -> Observable<[Recipe]> {
        
        if allIngredients.isEmpty {
            
            return Observable<[Recipe]>.just([])
            
        }
        else {
           
            return self.apiType.getRecipesUsedIngredients(allIngredients: allIngredients)

        }
        
    }
    
    func getRecipes(ingredient: Ingredient) -> Observable<[Recipe]> {
        
        return self.apiType.getRecipesUsedIngredient(ingredient: ingredient)
        
    }
}
