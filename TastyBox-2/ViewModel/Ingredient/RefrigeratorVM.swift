//
//  RefrigeratorVM.swift
//  TastyBox-2
//
//  Created by 北島　志帆美 on 2021-09-21.
//

import Foundation
import Firebase
import RxSwift
import RxCocoa
import Action

enum List {
    case shopping, refrigerator
}

class RefrigeratorVM: ViewModelBase {
    
    let sceneCoodinator: SceneCoordinator
    let apiType: RefrigeratorProtocol.Type

    var user: FirebaseAuth.User!
    var err = NSError()

    var items: Observable<[RefrigeratorItem]>!
    
    init(sceneCoodinator: SceneCoordinator, apiType: RefrigeratorProtocol.Type = RefrigeratorDM.self, user: FirebaseAuth.User) {
        self.sceneCoodinator = sceneCoodinator
        self.apiType = apiType
        self.user = user
    }
    
    func toAddItem() -> CocoaAction {
        
        return CocoaAction { _ in
            
            let vm = EditItemRefrigeratorVM(sceneCoodinator: self.sceneCoodinator, user: self.user, item: nil)
            let vc = IngredientScene.edit(vm).viewController()
            
            return self.sceneCoodinator.transition(to: vc, type: .push).asObservable().map { _ in }
        }
    }
    
    func getItems(listName: List) {
       
        items = self.apiType.getRefrigeratorDetail(userID: self.user.uid).asObservable()
    }
}
