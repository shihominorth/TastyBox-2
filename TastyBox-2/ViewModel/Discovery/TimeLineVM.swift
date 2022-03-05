//
//  TimeLineVM.swift
//  TastyBox-2
//
//  Created by 北島　志帆美 on 2021-11-28.
//

import Foundation
import Firebase
import RxSwift

final class TimelineVM: ViewModelBase {
    
    private let apiType: MainDMProtocol.Type
    let user: Firebase.User

    let postsSubject:PublishSubject<[Timeline]>
    var recipes: [Recipe]
    var publishers: [String: User]
    weak var delegate: toRecipeDetailDelegate?
    
    init(user: Firebase.User, apiType: MainDMProtocol.Type = MainDM.self) {
        
        self.user = user
        self.apiType = apiType
        self.postsSubject = PublishSubject<[Timeline]>()
        self.recipes = []
        self.publishers = [:]
    }
    
    func getMyTimeline() -> Observable<[Timeline]> {
        
        return self.apiType.getPastTimelines(user: self.user, date: Date(), limit: 20)
        
    }
    
    func getPublisher(publisherIds: [String]) -> Observable<[String: User]> {
        
        return self.apiType.getPublishers(ids: publisherIds)
        
    }
    
    func getRecipe(recipeIds: [String]) -> Observable<[Recipe]> {
        
        return self.apiType.getRecipes(ids: recipeIds)
        
    }
    
    func toRecipeDetail(recipe: Recipe) {
        
        self.delegate?.selectedRecipe(recipe: recipe)
        
    }
    
}
