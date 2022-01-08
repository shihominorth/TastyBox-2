//
//  MyProfileDM.swift
//  TastyBox-2
//
//  Created by 北島　志帆美 on 2021-11-04.
//

import Foundation
import Firebase
import RxSwift

protocol MyProfileDMProtocol: AnyObject {
    
    static var firestoreService: FirestoreServices { get }
    static var storageService: StorageService { get }
    static func getMyPostedRecipes(user: Firebase.User) -> Observable<[Recipe]>
    static func getMyInfo(user: Firebase.User) -> Observable<(followings:Int, followeds:Int)>
    static func getMyProfileImage(user: Firebase.User) -> Observable<Data>
    
}

class MyProfileDM: MyProfileDMProtocol {
 
    static var firestoreService: FirestoreServices {
        
        return FirestoreServices()
        
    }
 
    static var storageService: StorageService {
        
        return StorageService()
        
    }
    
    static let db = Firestore.firestore()
    static let storage = Storage.storage().reference()
    
    static func getMyProfileImage(user: Firebase.User) -> Observable<Data> {
        
        let path = storage.child("users/\(user.uid)/userImage.jpg")
        
        return storageService.downloadData(path: path)
        
    }
    
    static func getMyPostedRecipes(user: Firebase.User) -> Observable<[Recipe]> {
   
        return getMyPostedRecipesDocuments(user: user)
            .flatMap { docs in
                Recipe.generateNewRecipes(queryDocs: docs)
            }

    }
    
    static func getMyPostedRecipesDocuments(user: Firebase.User) -> Observable<[QueryDocumentSnapshot]> {
        
        return .create { observer in

            // addSnapshotlistener cause pushing recipe detail vc when liked recipe.
            // should be useful below.
            
//            let listener = db.collection("cities").addSnapshotListener { querySnapshot, error in
//                // ...
//            }
//
//            // ...
//
//            // Stop listening to changes
//            listener.remove()
            
            
            db.collection("recipes").whereField("publisherID", isEqualTo: user.uid).getDocuments { snapShot, err in
                
                
                if let err = err {
          
                    observer.onError(err)
          
                }
                else {
                    
                    
                    if let snapShot = snapShot {
                        
                        let documents = snapShot.documents
                       
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
    
    static func generateNewRecipes(queryDocs: [QueryDocumentSnapshot], user: Firebase.User) -> Observable<[Recipe]> {
        
        return .create { observer in
            
            
            
//            var implementNum = 0
//            var recipes: [Recipe] = []
//            let disposeBag = DisposeBag()
            
//            DispatchQueue.global(qos: .background).async  {
            
//            queryDocs.enumerated().forEach { index, doc in
                
//                implementNum += 1
                
//                generateNewRecipe(queryDoc: doc, user: user)
//                    .debug("recipe gotten")
//                    .catch { err in
//
//                        print(err)
//
//                        if implementNum == queryDocs.count {
//                            observer.onNext(recipes)
//                        }
//
//                        return .empty()
//                    }
//                    .subscribe(onNext: { recipe in
//
//                        if let recipe = recipe {
//                            recipes.append(recipe)
//                        }
//
//                        if implementNum == queryDocs.count {
//                            observer.onNext(recipes)
//                        }
//
//                    })
//                    .disposed(by: disposeBag)
                                
//            }
//            }
            
            return Disposables.create()
        }
    }
    

    static func getMyInfo(user: Firebase.User) -> Observable<(followings:Int, followeds:Int)> {
        
        let path = db.collection("users").document(user.uid)
        
        return firestoreService.getDocument(path: path)
            .map {

                if let data = $0.data() {
                    
                    let followingIds = data["followingsIDs"] as? [String:Bool]
                    let followedIds = data["followedsIDs"] as? [String:Bool]
                    
                    let followingIdsCount: Int = followingIds?.count ?? 0
                    let followedIdsCount: Int = followedIds?.count ?? 0
                
                    return (followingIdsCount, followedIdsCount)
                
                }
                
                return (0, 0)
                
            }
        
    }
    
//    static func generateNewRecipe(queryDoc: QueryDocumentSnapshot, user: Firebase.User) -> Observable<Recipe> {
//
//        let imageData = <#value#>
//
//
//            let documentID = queryDoc.documentID
//
////            let getImageObservable = getMyPostedRecipeImage(recipeID: documentID, user: user)
//
//            return .create { observer in
//
//                getMyPostedRecipeImage(recipeID: queryDoc.documentID, user: user, completion: { data in
//
////                    observer.onNext(data)
//
//                    if let recipe = Recipe(queryDoc: queryDoc, imageData: data) {
//
//                        observer.onNext(recipe)
//
//                    }
//
//                }, errBlock: { err in
//
//                    observer.onError(err)
//
//                })
//
//            .map { data in
//
//                if let recipe = Recipe(queryDoc: queryDoc, imageData: data) {
//
//                    return recipe
//
//                }
//
//                return nil
//            }
                
//                    .subscribe(onNext: { data in
//
//                        if let recipe = Recipe(queryDoc: queryDoc, imageData: data) {
//
//                            observer.onNext(recipe)
//
//                        }
//                        else {
//
//                            observer.onNext(nil)
//
//                        }
//
//                    }, onError: { err in
//
//                        observer.onError(err)
//
//                    })
//                    .disposed(by: DisposeBag())
//
//                return Disposables.create()
//            }
//
//        }
    
//    static func generateNewRecipe(queryDoc: QueryDocumentSnapshot, user: Firebase.User) -> Observable<Recipe?> {
//
//        return getMyPostedRecipeImage(recipeID: queryDoc.documentID, user: user)
//            .observe(on: MainScheduler.instance)
//            .debug("image gotten")
//            .flatMapLatest { data -> Observable<Recipe> in
//
//                let recipeObservable = Observable<Recipe>.create { observer in
//
//                    if let recipe = Recipe(queryDoc: queryDoc, imageData: data) {
//
//                        observer.onNext(recipe)
//                    }
//                    return Disposables.create()
//                }
//
//                return recipeObservable
//
//            }
//            .retry { errors in
//
//                return errors.enumerated().flatMap { retryIndex, error -> Observable<Int64> in
//
//                    print("got error")
//                    print(error)
//
//                    let e = error as NSError
//
//                    if 400..<500 ~= e.code && retryIndex < 3 {
//
//                        return .timer(.milliseconds(3000), scheduler: MainScheduler.instance)
//
//                    }
//
//                    return Observable.error(error)
//
//                }
//            }
//            .flatMap { data -> Observable<Recipe?> in
//
//                let newRecipe = Observable<Recipe?>.create { observer in
//
//                    if let recipe = Recipe(queryDoc: queryDoc, user: data) {
//
//                        observer.onNext(recipe)
//
//                    }
//                    else {
//
//                        observer.onNext(nil)
//
//                    }
//
//                    return Disposables.create()
//                }
//
//                return newRecipe
//            }
      
                
//    }
//
   
//    static func getMyPostedRecipeImage(recipeID: String, user: Firebase.User, completion: @escaping (Data) -> Void, errBlock: @escaping (Error) -> Void) {
//
//            let storage = Storage.storage().reference()
//
//            storage.child("users/\(user.uid)/\(recipeID)/mainPhoto.jpg").getData(maxSize: 1 * 1024 * 1024) { data, err in
//
//                if let err = err {
//
//                    errBlock(err)
//
//                } else {
//
//                    if let data = data {
//
//                       completion(data)
//                    }
//
//                }
//
//            }
//
//
//
//    }
    

//    static func getMyPostedRecipeImage(recipeID: String, user: Firebase.User) -> Observable<Data> {
//
//        return .create { observer in
//
//            let storage = Storage.storage().reference()
//
//            storage.child("users/\(user.uid)/\(recipeID)/mainPhoto.jpg").getData(maxSize: 1 * 1024 * 1024) { data, err in
//
//                if let err = err {
//
//                    observer.onError(err)
//
//                } else {
//
//                    if let data = data {
//
//                        observer.onNext(data)
//                    }
//
//                }
//
//            }
//
//            return Disposables.create()
//        }
//
//
//    }

//    func getMyImage(recipeID: String, user: Firebase.User) -> Observable<Data> {
//        
//        return .create { observer in
//           
//            let storage = Storage.storage().reference()
//            
//            storage.child("users/\(user.uid)/\(recipeID)/mainPhoto.jpg").getData(maxSize: 1 * 1024 * 1024) { data, err in
//               
//                if let err = err {
//                    
//                    observer.onError(err)
//                    
//                } else {
//               
//                    if let data = data {
//                        
//                        observer.onNext(data)
//                    }
//                    
//                }
//                
//            }
//            
//            return Disposables.create()
//        }
//        
//    }
    
    
}
