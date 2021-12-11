//
//  RecipeVM.swift
//  TastyBox-2
//
//  Created by 北島　志帆美 on 2021-11-08.
//

import Foundation
import DifferenceKit
import Firebase
import RxSwift
import RxCocoa
import RxRelay
import SCLAlertView
import RxDataSources

class RecipeVM: ViewModelBase {

    typealias Section = ArraySection<RecipeDetailSectionItem.RawValue, RecipeDetailSectionItem>
    
    let sceneCoordinator: SceneCoordinator
    let user: Firebase.User
    let apiType: RecipeDetailProtocol.Type
    let recipe: Recipe
    var sections: [Section]
    var evaluations:[Evaluation]
    
    var isDisplayed = false
    var isEnded = false
    
    let isExpandedSubject = BehaviorRelay<Bool>(value: false)
    let selectedEvaluationSubject = PublishSubject<Int>()
    let isLikedRecipeSubject = BehaviorSubject<Bool>(value: false)
    let isHiddenFollowSubject = BehaviorSubject<Bool>(value: false)
    let isFollowingSubject = BehaviorSubject<Bool>(value: false)
    let tappedFollowBtn = BehaviorSubject<Bool>(value: false)
    
    
    init(sceneCoordinator: SceneCoordinator, user: Firebase.User, apiType: RecipeDetailProtocol.Type = RecipeDetailDM.self, recipe: Recipe) {
        
        self.sceneCoordinator = sceneCoordinator
        self.user = user
        self.apiType = apiType
        self.recipe = recipe
        self.sections = []
        
        evaluations = [.like, .report]

    }
    
    func getRecipeDetailInfo(recipe: Recipe) -> Observable<[Section]> {
               
        return self.apiType.getDetailInfo(recipe: recipe)
            .flatMapLatest { [unowned self] genres, publisher, ingredients, instructions in
                self.generateSections(recipe: recipe, genres: genres, publisher: publisher, ingredients: ingredients, instructions: instructions)
            }
        
    }
    
    func generateSections(recipe: Recipe, genres: [Genre],  publisher: User, ingredients: [Ingredient], instructions: [Instruction]) -> Observable<[Section]> {
        
        
        return .create { observer in
            
            var resultSections: [Section] = []

            let imageElement: RecipeDetailSectionItem = .imageData(recipe.imgString, recipe.videoURL)
            let imageSection = Section(model: imageElement.rawValue, elements: [imageElement])
            
            resultSections.append(imageSection)
            
            let titleElement: RecipeDetailSectionItem = .title(recipe.title)
            let titleSection = Section(model: titleElement.rawValue, elements: [titleElement])
            
            resultSections.append(titleSection)
            
            
            
            let evaluatesElement: RecipeDetailSectionItem = .evaluates(self.evaluations)
            let evaluatesSection = Section(model: evaluatesElement.rawValue, elements: [evaluatesElement])
            
            resultSections.append(evaluatesSection)
            
            // get genres from recipe.genresIDs
            let genresElement: RecipeDetailSectionItem = .genres(genres)
            let genresSection = Section(model: genresElement.rawValue, elements: [genresElement])
            
            resultSections.append(genresSection)
            
            // get publishers from recipe.publisherID
            let publisherElement: RecipeDetailSectionItem = .publisher(publisher)
            let publisherSection = Section(model: publisherElement.rawValue, elements: [publisherElement])

            resultSections.append(publisherSection)
            
            
            let timeAndServingElement: RecipeDetailSectionItem = .timeAndServing(recipe.cookingTime, recipe.serving)
            let timeAndServingSection = Section(model: timeAndServingElement.rawValue, elements: [timeAndServingElement])
            
            resultSections.append(timeAndServingSection)
            
            let ingredientElements: [RecipeDetailSectionItem] = ingredients.map { ingredient in
                return .ingredients(ingredient)
            }
                
            let ingredientSection = Section(model: "ingredients", elements: ingredientElements)

            resultSections.append(ingredientSection)
            
        
            let instructionElement: [RecipeDetailSectionItem] = instructions.map { instruction in
                return .instructions(instruction)
            }
            
            let instructionSection = Section(model: "instructions", elements: instructionElement)

            resultSections.append(instructionSection)
            
            observer.onNext(resultSections)
            
            return Disposables.create()
        }
        
       
    }
    
    func isFollowingPublisher() -> Observable<Bool> {
        
        return self.apiType.isFollowingPublisher(user: user, publisherID: recipe.userID)
        
    }
    
    
    
//    func isLikedRecipe(resultSetions: [Section]) -> Observable<[Section]> {
//
//        return self.apiType.isLikedRecipe(user: self.user, recipe: self.recipe)
//            .catch { err in
//
//                print(err)
//
//                return Observable.just(false)
//            }
//            .flatMapLatest { isLiked -> Observable<[Section]> in
//
//                let newSections = Observable<[Section]>.create { [unowned self] observer in
//
////                    let imgName = isLiked ? "suit.heart.fill": "suit.heart"
//
////                    self.evaluations[0] = Evaluate(title: "\(self.recipe.likes)\nLikes", imgName: imgName)
//
//                    let evaluatesElement: RecipeDetailSectionItem = .evaluates(self.evaluations)
//                    let evaluatesSection = Section(model: evaluatesElement.rawValue, elements: [evaluatesElement])
//
//
//                    var result = resultSetions
//                    result.insert(evaluatesSection, at: 2)
//
//                    result.remove(at: 3)
//
//
//                    observer.onNext(result)
//
//                    return Disposables.create()
//                }
//
//                return newSections
//            }
//    }
    
    func isLikedRecipe() -> Observable<Bool> {
        
        return self.apiType.isLikedRecipe(user: self.user, recipe: self.recipe)
            .catch { err in
                
                print(err)
                
                return Observable.just(false)
            }
         
    }
    
    func getLikedNum() -> Observable<Int> {
        return self.apiType.getLikedNum(recipe: recipe)
            .catch { err in
                
                print(err)
                
                return Observable.just(0)
            }
    }
    
    
    func evaluateRecipe(isLiked: Bool) -> Observable<Bool> {
        
        return self.apiType.likeRecipe(user: self.user, recipe: self.recipe, isLiked: isLiked)
        
    }
    
    func addNewMyLikedRecipes() -> Observable<Bool> {
        
        return self.apiType.addNewMyLikedRecipe(user: self.user, recipe: self.recipe)
    
    }
    
    func followPublisher(user: Firebase.User, publisher: User) -> Observable<Bool> {
        
        if user.uid == publisher.userID {
        
            return Observable.just(false)
        
        }
        
        return self.apiType.followPublisher(user: user, publisher: publisher).map { true }
        
    }
    
    func unFollowPublisher(user: Firebase.User, publisher: User) -> Observable<Bool> {
        
        if user.uid == publisher.userID {
        
            return Observable.just(false)
        
        }
        
        return self.apiType.unFollowPublisher(user: user, publisher: publisher).map { true }
        
    }
    
    func toReportVC() {
        
        let vm = ReportVM(kind: .recipe, id: recipe.recipeID, sceneCoordinator: sceneCoordinator)
        
        let scene: Scene = .reportScene(scene: .report(vm))
        
        
        self.sceneCoordinator.modalTransition(to: scene, type: .centerCard)
        
    }
    
//    func selectedReason() -> <#return type#> {
//    
//        return
//        
//    }
    
    
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
