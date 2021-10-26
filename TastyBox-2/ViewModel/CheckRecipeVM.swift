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

class CheckRecipeVM {
    
    let sceneCoodinator: SceneCoordinator
    let user: Firebase.User
    
    let apiType: CreateRecipeDMProtocol.Type
    
    
    var sections: [RecipeItemSectionModel] = []
    let evaluates: [Evaluate]
    let isVIP: Bool
    
    let disposeBag = DisposeBag()
    
    init(sceneCoodinator: SceneCoordinator, user: Firebase.User, apiType: CreateRecipeDMProtocol.Type = CreateRecipeDM.self, title: String, mainPhoto: Data, video: URL?, time: String, serving: String, isVIP: Bool, genres: [Genre],  ingredients: [Ingredient], instructions: [Instruction]) {

        self.sceneCoodinator = sceneCoodinator
        self.user = user
        self.apiType = apiType
        self.isVIP = isVIP
        self.evaluates =  [Evaluate(title: "0", imgData: UIImage(systemName: "suit.heart.fill")!.convertToData()!)]
        
        let mainImageSection: RecipeItemSectionModel = .mainImageData(imgData: mainPhoto, videoURL: video)
        let titleSection: RecipeItemSectionModel = .title(title: title)
        let evaluateSection: RecipeItemSectionModel = .evaluate(evaluates: .evaluate(evaluates))
        let genresSection: RecipeItemSectionModel = .genres(genre: .genres(genres))
//        let userSection: RecipeItemSectionModel = .user(user: user)
        
        guard let time = Int(time), let serving = Int(serving) else { return }
        let timeNServingSection: RecipeItemSectionModel = .timeAndServing(time: time, serving: serving)
        
        let ingredientsItems:[RecipeDetailSectionItem] = ingredients.map { .ingredients($0) }
        let ingredientSection: RecipeItemSectionModel = .ingredients(ingredient: ingredientsItems)
        
        let instructionsItems:[RecipeDetailSectionItem] = instructions.map { .instructions($0) }
        let instructionsSection: RecipeItemSectionModel = .instructions(instruction: instructionsItems)
        

        self.sections = [mainImageSection, titleSection, evaluateSection, genresSection, timeNServingSection, ingredientSection, instructionsSection]

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
    
    
}
