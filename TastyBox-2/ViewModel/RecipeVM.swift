//
//  RecipeVM.swift
//  TastyBox-2
//
//  Created by 北島　志帆美 on 2021-11-08.
//

import Foundation
import Firebase
import RxSwift
import RxRelay
import DifferenceKit
import RxDataSources

class RecipeVM: ViewModelBase {

    typealias Section = ArraySection<RecipeDetailSectionItem.RawValue, RecipeDetailSectionItem>
    
    let sceneCoordinator: SceneCoordinator
    let user: Firebase.User
    let apiType: MyProfileDMProtocol.Type
    let recipe: Recipe
    let sections: [Section]
    
    
    var isDisplayed = false
    var isEnded = false
    
    let isExpandedSubject = BehaviorRelay<Bool>(value: false)
    
    init(sceneCoordinator: SceneCoordinator, user: Firebase.User, apiType: MyProfileDMProtocol.Type = MyProfileDM.self, recipe: Recipe) {
        
        self.sceneCoordinator = sceneCoordinator
        self.user = user
        self.apiType = apiType
        self.recipe = recipe
        
        self.sections = generateSections(recipe: recipe)
        
    }
    
    func generateSections(recipe: Recipe) -> [Section] {
        
        var resultSections: [Section] = []

        let imageElement: RecipeDetailSectionItem = .imageData(recipe.imgURL, recipe.videoURL)
        let imageSection = Section(model: imageElement.rawValue, elements: [imageElement])
        
        resultSections.append(imageElement)
        
        let titleElement: RecipeDetailSectionItem = .title(recipe.title)
        let titleSection = Section(model: titleElement.rawValue, elements: [titleElement])
        
        resultSections.append(titleSection)
        
        
        
        let evaluatesElement: RecipeDetailSectionItem = .evaluates([])
        let evaluatesSection = Section(model: evaluatesElement.rawValue, elements: [evaluatesElement])
        
        resultSections.append(evaluatesSection)
        
        // get genres from recipe.genresIDs
        let genresElement: RecipeDetailSectionItem = .genres([])
        let genresSection = Section(model: genresElement.rawValue, elements: [genresElement])
        
        resultSections.append(genresSection)
        
        // get publishers from recipe.publisherID
        let publisherElement: RecipeDetailSectionItem = .publisher(<#T##User#>)
        let publisherSection = Section(model: publisherElement.rawValue, elements: [publisherElement])
        
        resultSections.append(publisherSection)
        
        
        let timeAndServingElement: RecipeDetailSectionItem = .timeAndServing(recipe.cookingTime, recipe.serving)
        let timeAndServingSection = Section(model: timeAndServingElement.rawValue, elements: [timeAndServingElement])
        
        resultSections.append(timeAndServingSection)
        
       
        let ingredientElement: [RecipeDetailSectionItem] = []
        let ingredientSection = Section(model: RecipeDetailSectionItem.ingredients.rawValue, elements: ingredientElement)
        
        resultSections.append(ingredientSection)
        
    
        let instructionElement: [RecipeDetailSectionItem] = []
        let instructionSection = Section(model: RecipeDetailSectionItem.instructions.rawValue, elements: instructionElement)
        
        resultSections.append(ingredientSection)
        
        
        return resultSections
    }
    
    
//    func completeSections() -> Observable<[RecipeItemSectionModel]> {
//
//        return self.apiType.getUserImage(user: user)
//            .flatMap { [unowned self] in
//                self.createMyTempUserInfo(data: $0)
//            }
//            .flatMap { [unowned self] in
//                self.createUserSection(user: $0)
//            }
//
//    }
//
//    func createMyTempUserInfo(data: Data) -> Observable<User> {
//
//        return .create { [unowned self] observer in
//
//            if let name = user.displayName {
//
//                let user = User(id: user.uid, name: name, isVIP: false, imgData: data)
//
//                observer.onNext(user)
//            }
//
//            return Disposables.create()
//        }
//    }
//
//    func createUserSection(user: User) -> Observable<[RecipeItemSectionModel]> {
//
//        return .create { [unowned self] observer in
//
//            let userSection: RecipeItemSectionModel = .user(user: user)
//
//            self.sections.insert(userSection, at: 4)
//
//            observer.onNext(self.sections)
//
//            return Disposables.create()
//        }
//    }
}
