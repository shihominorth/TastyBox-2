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
    static var services: FireStoreServices { get }
    static func getDetailInfo(recipe: Recipe) -> Observable<([Genre], User, [Ingredient], [Instruction])>
    static func likeRecipe(user: Firebase.User, recipe: Recipe, isLiked: Bool) -> Observable<Bool>
    static func addNewMyLikedRecipe(user: Firebase.User, recipe: Recipe) -> Observable<Bool>
    static func getLikedNum(recipe: Recipe) -> Observable<Int> 
    static func isLikedRecipe(user: Firebase.User, recipe: Recipe) -> Observable<Bool>
    static func followPublisher(user: Firebase.User, publisher: User) -> Observable<Void>
    static func unFollowPublisher(user: Firebase.User, publisher: User) -> Observable<Void>
    static func isFollowingPublisher(user: Firebase.User, publisherID: String) -> Observable<Bool>
}

class RecipeDetailDM: RecipeDetailProtocol {
    
    static let db = Firestore.firestore()
    static var services: FireStoreServices {
        return FireStoreServices()
    }
    
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
                            
                            let result = docs.compactMap { $0 }
                            
                            if genresIDs.count == 1 {
                                
                                observer.onNext(result)
                                
                            }
                            else if implementedCount == genresIDs.count - 1 {
                                
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
    
    static func isFollowingPublisher(user: Firebase.User, publisherID: String) -> Observable<Bool> {
        
        let path = db.collection("users").document(user.uid)
        
        return services.getDocument(path: path)
            .map { data in
                if let ids = data["followingsIDs"] as? [String: Bool], let isFollowingPublisher = ids[publisherID] {
                    return isFollowingPublisher
                }
                return false
            }
        
    }
    
    static func followPublisher(user: Firebase.User, publisher: User) -> Observable<Void> {
        
        return .zip(addNewFollower(user: user, publisher: publisher).map { _ in }, addNewFollowing(user: user, publisher: publisher), addNewFollowingUnderUser(user: user, publisher: publisher), addNewFollowedUnderUser(user: user, publisher: publisher)) { _, _, _, _ in
            
            return
            
        }
        
    }
    
    static func addNewFollower(user: Firebase.User, publisher: User) -> Observable<Void> {
        
        let data:[String: Any] = [
            
            "id": user.uid,
            "followedDate": Date(),
            "isFollowed": true
        ]
        
        let path = db.collection("users").document(publisher.userID).collection("followers").document(user.uid)
        
        return services.setData(path: path, data: data).map { _ in }
        
    }
    
    static func addNewFollowing(user: Firebase.User, publisher: User) -> Observable<Void>  {
        
        let data:[String: Any] = [
            
            "id": publisher.userID,
            "followingDate": Date(),
            "isFollowing": true
        ]
        
        let path = db.collection("users").document(user.uid).collection("followings").document(publisher.userID)
        
        
        return services.setData(path: path, data: data).map { _ in }
        
    }
    
    static func addNewFollowingUnderUser(user: Firebase.User, publisher: User) -> Observable<Void>  {
        
        let path = db.collection("users").document(user.uid)
        
        
        return services.getDocument(path: path)
            .map { data in
                
                if let idsDic = data["followingsIDs"] as? [String: Bool] {
                    
                    var ids = idsDic
                    
                    ids[publisher.userID] = true
                    
                    let newData = ["followingsIDs": ids]
                    
                    return newData
                    
                }
                
                return ["followingsIDs": [publisher.userID: true]]
            }
            .flatMapLatest {
                self.services.updateData(path: path, data: $0)
            }
            .map { _ in }
        
    }
    
    
    static func addNewFollowedUnderUser(user: Firebase.User, publisher: User) -> Observable<Void>  {
        
        let path = db.collection("users").document(publisher.userID)
        
        
        return services.getDocument(path: path)
            .map { data in
                
                if let idsDic = data["followedsIDs"] as? [String: Bool] {
                    
                    var ids = idsDic
                    
                    ids[user.uid] = true
                    
                    let newData = ["followedsIDs": ids]
                    
                    return newData
                    
                }
                
                return ["followedsIDs": [user.uid: true]]
            }
            .flatMapLatest {
                self.services.updateData(path: path, data: $0)
            }
            .map { _ in }
        
    }
    
    
    
    static func unFollowPublisher(user: Firebase.User, publisher willUnFollowUser: User) -> Observable<Void> {
        
        let removeFollowingIDs = removeFollowingIDs(user: user, publisher: willUnFollowUser)
        let removeFollowedIDs = removeFollowedsIDs(user: user, publisher: willUnFollowUser)
        
        let updateStatus = updateFollowerFollowingStatus(user: user, publisher: willUnFollowUser)
        
        return .zip(removeFollowingIDs, removeFollowedIDs, updateStatus) { _, _, _ in
            return
        }
        
    }
    
    fileprivate static func removeFollowingIDs(user: Firebase.User, publisher: User) -> Observable<Void> {
        
        let path = db.collection("users").document(user.uid)
        
        return services.getDocument(path: path)
            .compactMap { doc  in
                
                if let data = doc.data(), let idsDic = data["followingsIDs"] as? [String: Bool], let index = idsDic.firstIndex(where: { key, _ in
                    
                    return key == publisher.userID
                    
                }) {
                    
                    var ids = idsDic
                    
                    ids.remove(at: index)
                    
                    let newData = ["followingsIDs": ids]
                    
                    return newData
                    
                }
                
                return nil
            }
            .flatMapLatest {
                services.updateData(path: path, data: $0).map { _ in }
            }
    }
    
    fileprivate static func removeFollowedsIDs(user: Firebase.User, publisher: User) -> Observable<Void> {
        
        let path = db.collection("users").document(publisher.userID)
        
        return services.getDocument(path: path)
            .compactMap { doc  in
                
                if let data = doc.data(), let idsDic = data["followedsIDs"] as? [String: Bool], let index = idsDic.firstIndex(where: { key, _ in
                    
                    return key == user.uid
                    
                }) {
                    
                    var ids = idsDic
                    
                    ids.remove(at: index)
                    
                    let newData = ["followedsIDs": ids]
                    
                    return newData
                    
                }
                
                return nil
            }
            .flatMapLatest {
                services.updateData(path: path, data: $0).map { _ in }
            }
    }
    
    
    fileprivate static func updateFollowerFollowingStatus(user: Firebase.User, publisher: User) -> Observable<Void> {
        
        let myFollowingsPath = db.collection("users").document(user.uid).collection("followings").document(publisher.userID)
        let publisherFollowerPath = db.collection("users").document(publisher.userID).collection("followers").document(user.uid)
        let updateFollowingStatusData = ["isFollowing": false]
        let updateFollowertatusData = ["isFollowed": false]
        
        return services.updateData(path: myFollowingsPath, data: updateFollowingStatusData)
            .flatMapLatest { _ in
                services.updateData(path: publisherFollowerPath, data: updateFollowertatusData)
            }
            .map { _ in }
        
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
