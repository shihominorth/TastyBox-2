//
//  CheckRecipeVM.swift
//  TastyBox-2
//
//  Created by 北島　志帆美 on 2021-10-24.
//

import Foundation
import Firebase
import UIKit
import RxSwift
import RxCocoa
import RxRelay

class CheckRecipeVM {
    
    let sceneCoodinator: SceneCoordinator
    let user: Firebase.User
    
    let apiType: CreateRecipeDMProtocol.Type
    
    //    var mainPhoto: Data
    //    var url: URL? = nil
    var sections: [RecipeItemSectionModel] = []
    let evaluations: [Evaluation]
    //    let isVIP: Bool
    //    let instructions: [Instruction]
    var isDisplayed = false
    var isEnded = false
    
    let isExpandedSubject = BehaviorRelay<Bool>(value: false)
    
    let isExpandedDiffenreceSubject = ReplaySubject<Bool>.create(bufferSize: 1)
    var diffenrenceIsExpandedSubject: Observable<Bool> {
        return Observable.zip(isExpandedDiffenreceSubject, isExpandedDiffenreceSubject.skip(1)) { previous, current in
            return  previous != current
        }
        
    }
    
    let title: String
    let mainPhotoData: Data
    let videoUrl: URL?
    let time: Int
    let serving: Int
    let isVIP: Bool
    let genres: [Genre]
    
    let ingredients: [Ingredient]
    let instructions: [Instruction]
    
    let recipeDataSubject = BehaviorSubject<[String: Any]>(value: [:])
    let ingredientsDataSubject = BehaviorSubject<[[String: Any]]>(value: [])
    let instructionsDataSubject = BehaviorSubject<[[String: Any]]>(value: [])
    let genresDataSubject = BehaviorSubject<[[String: Any]]>(value: [])
    
    let disposeBag = DisposeBag()
    
    init(sceneCoodinator: SceneCoordinator, user: Firebase.User, apiType: CreateRecipeDMProtocol.Type = CreateRecipeDM.self, title: String, mainPhoto: Data, videoUrl: URL?, time: Int, serving: Int, isVIP: Bool, genres: [Genre],  ingredients: [Ingredient], instructions: [Instruction]) {
        
        
        self.sceneCoodinator = sceneCoodinator
        self.user = user
        self.apiType = apiType
        
        self.title = title
        self.mainPhotoData = mainPhoto
        self.videoUrl = videoUrl
        self.evaluations = [.like, .report]
        self.time = time
        self.serving = serving
        self.genres = genres
        self.isVIP = isVIP
        self.ingredients = ingredients
        self.instructions = instructions
      
        
        let imgString = mainPhoto.base64EncodedString()
        let videoString = videoUrl?.absoluteString
        
        let mainImageSection: RecipeItemSectionModel = .mainImageData(imgURLString: imgString, videoURLString: videoString)
        let titleSection: RecipeItemSectionModel = .title(title: title)
        let evaluateSection: RecipeItemSectionModel = .evaluate(evaluates: .evaluates(evaluations))
        
        var temp: [Genre] = []
        
        
        temp.append(contentsOf: genres)
        let genresSection: RecipeItemSectionModel = .genres(genre: .genres(temp))
        
        let timeNServingSection: RecipeItemSectionModel = .timeAndServing(time: time, serving: serving)
        
        let ingredientsItems:[RecipeDetailSectionItem] = ingredients.map { .ingredients($0) }
        let ingredientSection: RecipeItemSectionModel = .ingredients(ingredient: ingredientsItems)
        
        let instructionsItems:[RecipeDetailSectionItem] = instructions.map { .instructions($0) }
        let instructionsSection: RecipeItemSectionModel = .instructions(instruction: instructionsItems)
        
        
        self.sections = [mainImageSection, titleSection, evaluateSection, genresSection, timeNServingSection, ingredientSection, instructionsSection]
        
        
    }
    
    
    func completeSections() -> Observable<[RecipeItemSectionModel]> {
        
        return self.apiType.getUserImage(user: user)
            .flatMap { [unowned self] in
                self.createMyTempUserInfo(data: $0)
            }
            .flatMap { [unowned self] in
                self.createUserSection(user: $0)
            }
        
    }
    
    func createMyTempUserInfo(data: Data) -> Observable<User> {
        
        return .create { [unowned self] observer in
            
            if let name = user.displayName {
                
                let imgString = data.base64EncodedString()
                
                let user = User(id: user.uid, name: name, isVIP: false, imgURLString: imgString)
                
                observer.onNext(user)
            }
            
            return Disposables.create()
        }
    }
    
    func createUserSection(user: User) -> Observable<[RecipeItemSectionModel]> {
        
        return .create { [unowned self] observer in
            
            let userSection: RecipeItemSectionModel = .user(user: user)
            
            self.sections.insert(userSection, at: 4)
            
            observer.onNext(self.sections)
            
            return Disposables.create()
        }
    }
    
    func uploadRecipe() {

        let vm = PublishRecipeVM(sceneCoodinator: self.sceneCoodinator, user: self.user, title: self.title, serving: self.serving, time: self.time, isVIP: self.isVIP, video: self.videoUrl, mainImageData: self.mainPhotoData, genres: genres, ingredients: ingredients, instructions: instructions)
        
        let scene = Scene.createReceipeScene(scene: .publishRecipe(vm))
        
        self.sceneCoodinator.modalTransition(to: scene, type: .modalHalf)
        
    }
    
   
    
}

extension ObservableType {
    
}
