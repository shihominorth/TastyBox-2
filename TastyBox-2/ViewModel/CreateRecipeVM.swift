//
//  CreateRecipeVM.swift
//  TastyBox-2
//
//  Created by 北島　志帆美 on 2021-10-16.
//

import Foundation
import Firebase
import RxSwift
import RxCocoa

class CreateRecipeVM: ViewModelBase {
    
    let sceneCoodinator: SceneCoordinator
    let user: Firebase.User
    
    let keyboardOpen = NotificationCenter.default.rx.notification(UIResponder.keyboardWillShowNotification).observe(on: MainScheduler.instance)
    
    let keyboardClose = NotificationCenter.default.rx.notification(UIResponder.keyboardWillHideNotification).observe(on: MainScheduler.instance)
    
    var isUserScrollingRelay = BehaviorRelay<Bool>(value: true)
    
    
    var ingredients = [Ingredient]()
    var instructions = [Instruction]()
    
    
    init(sceneCoodinator: SceneCoordinator, user: Firebase.User) {
        
        self.sceneCoodinator = sceneCoodinator
        self.user = user
        
        super.init()
        
     
            
    }
 
    func isAppendNewIngredient() -> Observable<Bool> {
       
        return Observable.create { [unowned self] observer in
            
            appendNewIngredient()
            
            observer.onNext(true)
            
            return Disposables.create()
        }
      
        
    }
    
    func isAppendNewInstructions() -> Observable<Bool> {
       
        return Observable.create { [unowned self] observer in
            
            appendNewInstructions()
            
            observer.onNext(true)
            
            return Disposables.create()
        }
      
        
    }
    
    
    func appendNewIngredient() {
        
        let uuid = UUID()
        let uniqueIdString = uuid.uuidString.replacingOccurrences(of: "-", with: "")
        
        let indredient = Ingredient(key: uniqueIdString, name: "", amount: "", order: self.ingredients.count)
        
        self.ingredients.append(indredient)
    }
    
    func appendNewInstructions() {
        
        let uuid = UUID()
        let uniqueIdString = uuid.uuidString.replacingOccurrences(of: "-", with: "")
        
        let instruction = Instruction(index: self.instructions.count, imageUrl: "", text: "")
        
        self.instructions.append(instruction)
    }
    
    
}
