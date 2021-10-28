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
import RxRelay

class CheckRecipeVM {
    
    let sceneCoodinator: SceneCoordinator
    let user: Firebase.User
    
    let apiType: CreateRecipeDMProtocol.Type
    
    var mainPhoto: Data
    var url: URL? = nil
    var sections: [RecipeItemSectionModel] = []
    let evaluates: [Evaluate]
    let isVIP: Bool
    let instructions: [Instruction]
    var isDisplayed = false
    var isEnded = false
    
    let recipeDataSubject = PublishSubject<[String: Any]>()
    let ingredientsDataSubject = PublishSubject<[[String: Any]]>()
    let instructionsDataSubject = PublishSubject<[[String: Any]]>()
    let genresDataSubject = PublishSubject<[[String: Any]]>()
    
    let disposeBag = DisposeBag()
    
    init(sceneCoodinator: SceneCoordinator, user: Firebase.User, apiType: CreateRecipeDMProtocol.Type = CreateRecipeDM.self, title: String, mainPhoto: Data, video: URL?, time: String, serving: String, isVIP: Bool, genres: [Genre],  ingredients: [Ingredient], instructions: [Instruction]) {
        
        self.sceneCoodinator = sceneCoodinator
        self.user = user
        self.apiType = apiType
        
        self.isVIP = isVIP
        self.evaluates =  [Evaluate(title: "0", imgData: UIImage(systemName: "suit.heart.fill")!.convertToData()!)]
        self.mainPhoto = mainPhoto
        self.instructions = instructions
        
        let mainImageSection: RecipeItemSectionModel = .mainImageData(imgData: mainPhoto, videoURL: video)
        let titleSection: RecipeItemSectionModel = .title(title: title)
        let evaluateSection: RecipeItemSectionModel = .evaluate(evaluates: .evaluate(evaluates))
        let genresSection: RecipeItemSectionModel = .genres(genre: .genres(genres))
        
        guard let time = Int(time), let serving = Int(serving) else { return }
        let timeNServingSection: RecipeItemSectionModel = .timeAndServing(time: time, serving: serving)
        
        let ingredientsItems:[RecipeDetailSectionItem] = ingredients.map { .ingredients($0) }
        let ingredientSection: RecipeItemSectionModel = .ingredients(ingredient: ingredientsItems)
        
        let instructionsItems:[RecipeDetailSectionItem] = instructions.map { .instructions($0) }
        let instructionsSection: RecipeItemSectionModel = .instructions(instruction: instructionsItems)
        
        
        self.sections = [mainImageSection, titleSection, evaluateSection, genresSection, timeNServingSection, ingredientSection, instructionsSection]
        
        
        guard let video = video else {
            self.url = nil
            return
        }
        
        self.url = video
        //        super.init()
        
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
                
                let user = User(id: user.uid, name: name, isVIP: false, imgData: data)
                
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
//
        //            .flatMap({ [unowned self] in
        //            self.apiType.updateUserInterestedGenres(genresData: $0, user: self.user)
        //        })
        
        //            .flatMap { _ in[String: Any]
        //
        //            return Observable.zip(recipeDataSubject.asObservable(), instructionsDataSubject.asObservable())
        //        }
        //        .flatMap { [unowned self] recipeData, instructionData in
        //
        //            self.apiType.updateRecipe(recipeData: recipeData, instructionsData: instructionData, user: self.user)
        //
        //        }
        
    }
    
    
}
