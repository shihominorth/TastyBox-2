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

final class EditItemRefrigeratorVM: ViewModelBase {
    
    private let sceneCoodinator: SceneCoordinator
    private let apiType: RefrigeratorProtocol.Type
    
    var user: FirebaseAuth.User!
    var err = NSError()
    
    var item: Ingredient!
    var lastIndex: Int!
    
    var name = BehaviorRelay<String>(value: "")
    var amount = BehaviorRelay<String>(value: "")
    
    var isEnableDone = BehaviorRelay(value: false)
    
    
    init(sceneCoodinator: SceneCoordinator, apiType: RefrigeratorProtocol.Type = RefrigeratorDM.self, user: FirebaseAuth.User,  item: Ingredient?, lastIndex: Int) {
        self.sceneCoodinator = sceneCoodinator
        self.apiType = apiType
        self.user = user
        self.lastIndex = lastIndex
        
        self.item = item
 
    }
    
    
    func addItem(name: String, amount: String) {
        
        self.apiType.askHasIngredient(name: name)
            .flatMapLatest { id in
               
                self.apiType.addIngredient(id: id, name: name, amount: amount, userID: self.user.uid, lastIndex: self.lastIndex, listName: .refrigerator)
           
            }
            .catch { err in
                
                print("Error writing document: \(err)")
                err.handleFireStoreError()?.generateErrAlert()
                
                return .empty()
            }
            .subscribe(onNext: { _ in
               
                self.sceneCoodinator.pop(animated: true)
            
            })
            .disposed(by: self.disposeBag)
        
    }
    
    func editItem(name: String, amount: String) {
        
        self.apiType.editIngredient(edittingItem: self.item, name: name, amount: amount, userID: self.user.uid, listName: .refrigerator)
            .catch { err in
                
                print("Error writing document: \(err)")
                err.handleFireStoreError()?.generateErrAlert()
                
                return .empty()
            }
            .subscribe(onNext: { _ in
                print("Document successfully written!")
                
                self.sceneCoodinator.pop(animated: true)
                
            }, onDisposed: {
                print("disposed")
            })
            .disposed(by: disposeBag)
    }
}
