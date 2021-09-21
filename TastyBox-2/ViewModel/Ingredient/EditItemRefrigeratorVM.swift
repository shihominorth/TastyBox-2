//
//  AddItemRefrigeratorVM.swift
//  TastyBox-2
//
//  Created by 北島　志帆美 on 2021-09-21.
//

import Foundation
import Action
import Firebase
import RxSwift
import RxCocoa

class EditItemRefrigeratorVM: ViewModelBase {
    
    let sceneCoodinator: SceneCoordinator
    let apiType: RefrigeratorProtocol.Type
    var user: FirebaseAuth.User!
    var err = NSError()
    let item: Ingredient!
    
    
    init(sceneCoodinator: SceneCoordinator, apiType: RefrigeratorProtocol.Type = RefrigeratorDM.self, user: FirebaseAuth.User,  item: Ingredient?) {
        self.sceneCoodinator = sceneCoodinator
        self.apiType = apiType
        self.item = item
    }
    
    lazy var addItem: Action<(String, String), Swift.Never> = { this in
        
        
        return Action { name, amount in
           
            return Observable.create { observer in
                
                self.apiType.addIngredient(name: name, amount: amount, userID: self.user.uid)
                    .subscribe(onCompleted: {
                        
                        print("Document successfully written!")
                        
//                        self.sceneCoodinator.pop(animated: true)
                        
                    }, onError: { err in
                        
                        print("Error writing document: \(err)")
                        
//                        guard let err
                    })
                    .disposed(by: self.disposeBag)
                
                return Disposables.create()
            }
        }
        
    }(self)
}
