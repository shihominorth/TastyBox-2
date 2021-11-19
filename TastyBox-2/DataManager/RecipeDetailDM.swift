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
    static func likeRecipe(user: Firebase.User, recipe: Recipe, isLiked: Bool) -> Observable<Bool>
    static func addNewMyLikedRecipe(user: Firebase.User, recipe: Recipe) -> Observable<Bool>
    static func getLikedNum(recipe: Recipe) -> Observable<Int> 
    static func isLikedRecipe(user: Firebase.User, recipe: Recipe) -> Observable<Bool> 
}

class RecipeDetailDM: RecipeDetailProtocol {
    
    static let db = Firestore.firestore()
    
    private static var listenisILiked: ListenerRegistration!
    
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
                    
                    if let doc = doc as? QueryDocumentSnapshot, let user = User(document: doc) {
                        observer.onNext(user)
                    }
                    
                }
            }
            
            return Disposables.create()
        }
    }
    
    static func getLikedNum(recipe: Recipe) -> Observable<Int> {
        
        return .create { observer in
            
            db.collection("recipes").document(recipe.recipeID).getDocument { doc, err in
                
                if let err = err {
                    
                    observer.onError(err)
                    
                }
                else {
                    
                    if let data = doc?.data(), let likes = data["likes"] as? Int {
                    
                        observer.onNext(likes)
                    
                    }
                    else {
                        
                        observer.onNext(0)
                    
                    }
                }
                
            }
            
            return Disposables.create()
        }
    }
    
    
    static func isLikedRecipe(user: Firebase.User, recipe: Recipe) -> Observable<Bool> {
        
        return .create { observer in
            
            db.collection("users").document(user.uid).collection("likedRecipes").document(recipe.recipeID).addSnapshotListener { doc, err in
                
                if let err = err {
                   
                    observer.onError(err)
                
                }
                else {
                    
                    if let doc = doc, let data = doc.data() {
                        
                        if let isLiked = data["isLiked"] as? Bool {
                            
                            observer.onNext(isLiked)
                            
                        }
                        else {
                       
                            observer.onNext(false)
                        
                        }
                        
                    }
                    else {
                    
                        observer.onNext(false)
                    
                    }
                    
                    
                }
            }
            
            return Disposables.create()
        }
    }
    
    static func likeRecipe(user: Firebase.User, recipe: Recipe, isLiked: Bool) -> Observable<Bool> {
        
        return manageRecipeLikedNum(user: user, recipe: recipe, isLiked: isLiked)
            .flatMapLatest { isLiked in
                manageMyLikedRecipes(isLiked: isLiked, user: user, recipe: recipe)
            }
            
    }
    
    static func manageRecipeLikedNum(user: Firebase.User, recipe: Recipe , isLiked: Bool) -> Observable<Bool> {
        
        return .create { observer in
            
            let value = isLiked ? FieldValue.increment(Int64(-1)) : FieldValue.increment(Int64(1))
            
            
            db.collection("recipes").document(recipe.recipeID).updateData([
                
                "likes": value
                
            ]) { err in
                
                if let err = err {
                    observer.onError(err)
                }
                else {
                    observer.onNext(!isLiked)
                }
            }
            
            return Disposables.create()
        }
        
    }
    
    static func manageMyLikedRecipes(isLiked: Bool, user: Firebase.User, recipe: Recipe) -> Observable<Bool> {
        
        return .create { observer in
            
            db.collection("users").document(user.uid).collection("likedRecipes").document(recipe.recipeID).updateData([

                "isLiked": isLiked,
                "lastLikedDate": Date()
                
            ]) { err in
                
                if let err = err {
                    
                    observer.onError(err)
                
                }
                else {
                    
                    observer.onNext(isLiked)
                }
            }
            
            return Disposables.create()
        }
    }
    
    static func addNewMyLikedRecipe(user: Firebase.User, recipe: Recipe) -> Observable<Bool> {
        
        return .create { observer in
            
            db.collection("users").document(user.uid).collection("likedRecipes").document(recipe.recipeID).setData([
                
                "id": recipe.recipeID,
                "isLiked": true,
                "lastLikedDate": Date()
                
            ], merge: true) { err in
                
                if let err = err {
                    
                    observer.onError(err)
                
                }
                else {
                    
                    observer.onNext(true)
                }
            }
            
            
            return Disposables.create()
        }
        
    }
    
    
    // dont listen the liked number of recipe. no need to update at real time. if we listen it, we have to update the number every time other user liked or unliked.
//    static func listenRecipeIfILiked(user: Firebase.User, recipe: Recipe)  -> Observable<Bool> {
//        
//        
//        return .create { observer in
//           
//            listenisILiked = db.collection("users").document(user.uid).collection("likedRecipes").document(recipe.recipeID).addSnapshotListener { doc, err in
//                
//                if let err = err {
//                    
//                    observer.onError(err)
//                    
//                }
//                else {
//                    
//                    if let data = doc?.data(), let isLiked = data["isLiked"] as? Bool {
//                        
//                        observer.onNext(isLiked)
//                        
//                    }
//                    else {
//                    
//                        observer.onNext(false)
//                    
//                    }
//                }
//                
//            }
//            
//            
//            return Disposables.create()
//        }
// 
//    }

    
    static func removeListener() {
        
        listenisILiked.remove()
        
    }
}
