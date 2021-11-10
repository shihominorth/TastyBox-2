//
//  RecipeDetailDM.swift
//  TastyBox-2
//
//  Created by 北島　志帆美 on 2021-11-08.
//

import Foundation
import Firebase
import RxSwift

protocol RecipeDetailProtocol: AnyObject {
    static func getIngredients(recipeID: String) -> Observable<[Ingredient]>
}

class RecipeDetailDM: RecipeDetailProtocol {
    
    static let db = Firestore.firestore()
    
    static func getDetailInfo(recipeID: String) -> Observable<([Ingredient], [Instruction])> {
        
        return Observable.zip(getIngredients(recipeID: recipeID), getInstructions(recipeID: recipeID)) { ingredients, instructions in
            
            return (ingredients, instructions)
        }
        
    }
    
  
    static func getIngredients(recipeID: String) -> Observable<[Ingredient]> {
        
        return getIngredientsDocuments(recipeID: recipeID)
            .flatMap { docs in
                Ingredient.generateNewIngredients(queryDocs: docs)
            }
    }
    
    static func getIngredientsDocuments(recipeID: String) -> Observable<[QueryDocumentSnapshot]> {
        
        
        return .create { observer in
           
            db.collection("recipes").document(recipeID).collection("ingredients").getDocuments { snapShot, err in

                if let err = err {
                
                    observer.onError(err)
                
                }
                else {
                    
                    if let documents = snapShot?.documents {
                    
                        observer.onNext(documents)
                    
                    }
                    else {
                      
                        observer.onNext([])
                    
                    }
                    
                }
                
            }
        
            
            return Disposables.create()
        }
    
        
    }
    
    static func getInstructions(recipeID: String) -> Observable<[Instruction]> {
       
        return getInstructionsDocuments(recipeID: recipeID)
            .flatMapLatest { docs in
                Instruction.generateNewInstructions(queryDocs: docs)
            }
    
    }
    
    static func getInstructionsDocuments(recipeID: String)  -> Observable<[QueryDocumentSnapshot]> {
        
        return .create { observer in
            
            db.collection("recipes").document(recipeID).collection("instructions").getDocuments { snapShot, err in

                if let err = err {
                
                    observer.onError(err)
                
                }
                else {
                    
                    if let documents = snapShot?.documents {
                    
                        observer.onNext(documents)
                    
                    }
                    else {
                      
                        observer.onNext([])
                    
                    }
                    
                }
                
            }
            
            return Disposables.create()
        }
        
    }
    
}
