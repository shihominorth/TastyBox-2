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
    static func getDetailInfo(recipe: Recipe) -> Observable<([Genre], User, [Ingredient], [Instruction])>
}

class RecipeDetailDM: RecipeDetailProtocol {
    
    static let db = Firestore.firestore()
    
    static func getDetailInfo(recipe: Recipe) -> Observable<([Genre], User, [Ingredient], [Instruction])> {
        
        return Observable.zip(getGenres(genresIDs: recipe.genresIDs), getPublisher(publisherID: recipe.userID), getIngredients(recipeID: recipe.recipeID), getInstructions(recipeID: recipe.recipeID))

    }
    
    static func getGenres(genresIDs: [String]) -> Observable<[Genre]> {
        
        return getGenreDocuments(genresIDs: genresIDs)
            .flatMapLatest { docs in
                Genre.generateGenres(documents: docs)
            }
    
    }
    
    static func getGenreDocuments(genresIDs: [String]) -> Observable<[DocumentSnapshot]> {
        
        return .create { observer in
            
            var implementedCount = 0
            var docs:[DocumentSnapshot?] = []
            
            if genresIDs.isEmpty {
        
                observer.onNext([])
                
            } else {
                
                genresIDs.enumerated().forEach { index, id in
                   
                    db.collection("genres").document(id).getDocument { doc, err in
                        
                        implementedCount += 1
                        
                        if let err = err {
                        
                            observer.onError(err)
                        
                        }
                        else {
                            
                            docs.append(doc)
                            
                            if implementedCount == genresIDs.count - 1 {
                                
                                let result = docs.compactMap { $0 }
                                
                                observer.onNext(result)
                            }

                        }
                    }
               
                }
            }
            
        
            
            return Disposables.create()
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
    
    static func getPublisher(publisherID: String) -> Observable<User> {
        
        return .create { observer in
            
            db.collection("users").document(publisherID).getDocument { doc, err in
                
                if let err = err {
                    
                    observer.onError(err)
                
                }
                else {
                    
                    if let doc = doc, let user = User(document: doc) {
                        observer.onNext(user)
                    }
                    
                }
            }
            
            return Disposables.create()
        }
    }
    
}
