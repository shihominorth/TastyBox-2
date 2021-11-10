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

class RecipeVM: ViewModelBase {
    
    let sceneCoordinator: SceneCoordinator
    let user: Firebase.User
    let apiType: MyProfileDMProtocol.Type
    let recipe: Recipe
    
    var isDisplayed = false
    var isEnded = false
    
    let isExpandedSubject = BehaviorRelay<Bool>(value: false)
    
    init(sceneCoordinator: SceneCoordinator, user: Firebase.User, apiType: MyProfileDMProtocol.Type = MyProfileDM.self, recipe: Recipe) {
        
        self.sceneCoordinator = sceneCoordinator
        self.user = user
        self.apiType = apiType
        self.recipe = recipe
        
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
