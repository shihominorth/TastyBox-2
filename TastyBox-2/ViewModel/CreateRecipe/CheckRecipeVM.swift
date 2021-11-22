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
    let mainPhotoDataString: Data
    let videoUrlString: String?
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
    
    init(sceneCoodinator: SceneCoordinator, user: Firebase.User, apiType: CreateRecipeDMProtocol.Type = CreateRecipeDM.self, title: String, mainPhoto: Data, video: URL?, time: String, serving: String, isVIP: Bool, genres: [Genre],  ingredients: [Ingredient], instructions: [Instruction]) {
        
        self.sceneCoodinator = sceneCoodinator
        self.user = user
        self.apiType = apiType
        
        self.title = title
        self.mainPhotoDataString = mainPhoto.base64EncodedData()
        self.videoUrlString = video?.absoluteString
        self.genres = genres
        self.isVIP = isVIP
        self.ingredients = ingredients
        self.instructions = instructions

        guard let time = Int(time), let serving = Int(serving) else { return }
        self.time = time
        self.serving = serving
        
        
        evaluations = [.like, .report]

                
        let imgString = mainPhoto.base64EncodedString()
        let videoString = video?.absoluteString
        
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
 
        var recipeId = ""
        
        self.apiType.createUploadingRecipeData(isVIP: isVIP, sections: self.sections, user: self.user).do(onNext: { [unowned self] in
            
            self.recipeDataSubject.onNext($0)
            
        }).do(onNext: {
            
            guard let id = $0["id"] as? String else {
                return
            }
            
            recipeId = id
            
        }).flatMap ({ [unowned self] _ in
            
            self.apiType.createIngredientsData(section: sections[6], user: self.user, recipeID: recipeId)
            
        }).do (onNext: { [unowned self] in
                
            self.ingredientsDataSubject.onNext($0)
                
        }).flatMap ({ [unowned self] _ in
            
            self.apiType.createInstructionsData(section: sections[7], user: self.user, recipeID: recipeId)
            
        }).do(onNext: { [unowned self] in
            
            self.instructionsDataSubject.onNext($0)
            
        }).flatMap ({ [unowned self] _ in
            
            self.apiType.createGenresData(sections: [sections[3], sections[6]])
            
        }).do(onNext: {
            
            self.genresDataSubject.onNext($0)
            
        }).flatMap { [unowned self] _ in

            return Observable.combineLatest(self.recipeDataSubject.asObservable(), self.ingredientsDataSubject.asObservable(), self.instructionsDataSubject.asObservable(), self.genresDataSubject.asObservable())

        }
        .subscribe(onNext: { [unowned self] recipeData, ingredientsData, instructionsData, genresData in
            
            let vm = PublishRecipeVM(sceneCoodinator: self.sceneCoodinator, user: self.user, recipeData: recipeData, ingredientsData: ingredientsData, instructionsData: instructionsData, genresData: genresData, isVIP: self.isVIP,  video: self.url, mainImage: self.mainPhoto, instructions: instructions)
            
            self.sceneCoodinator.modalTransition(to: .createReceipeScene(scene: .publishRecipe(vm)), type: .modalHalf)
        
        }, onError: { err in

            print(err)

        })
        .disposed(by: disposeBag)

        
    }
   
    func setIngredientIDs(recipeId: String) -> Observable<[String: Any]> {
        
        if case let .ingredients(items) = sections[6] {
      
            let ingredients: [Ingredient] = items.compactMap { item in
                
                if case let .ingredients(ingredient) = item {
                    
                    return ingredient
                    
                }
                else {
                    
                    return nil
                    
                }
            }
            
            return self.apiType.getIngredientIDs(ingredients: ingredients)
                .flatMapLatest { [unowned self] in
                   
                    let createDataStream = self.apiType.createIngredientsData(ingredients: $0, user: self.user, recipeID: recipeId)
                    
                    // 02はingredientsをgenresとしてのデータにする
                    // self.apiType.createGenresData(sections: [sections[3], sections[6]]) は
                    // createGenresDataとconvertToGenresDataに分ける。
                    // 引数の方がGenre/Ingredientと違うため。
                    // ingredientsはgenresとしても扱う
                    
                    return Observable.zip(createDataStream, <#T##O2#>) { ingredientData, genresData in
                       
                        self.ingredientsDataSubject.onNext(ingredientData)
                        
                        return genresData
                    }

                }
            
        }
        
        return Observable<[String: Any]>.just([:])
        
    }
    
}

extension ObservableType {

}
