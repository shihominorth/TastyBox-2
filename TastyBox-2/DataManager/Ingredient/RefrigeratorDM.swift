//
//  RefrigeratorDataManager.swift
//  TastyBox-2
//
//  Created by 北島　志帆美 on 2021-09-21.
//

import Foundation
import Firebase
import RxSwift
import RxCocoa

protocol RefrigeratorProtocol: AnyObject {
    
    static func getIngredients(userID: String) -> Single<[RefrigeratorItem]>
    static func addIngredient(name: String, amount: String, userID: String, lastIndex: Int) -> Completable
    static func editIngredient(edittingItem: Ingredient, name: String, amount: String, userID: String) -> Completable
    static func moveIngredient(userID: String, items: [Ingredient]) -> Observable<Bool>
    static func deleteIngredient(item: RefrigeratorItem, userID: String) -> Completable
    static func deleteIngredients(items: [DeletingIngredient], userID: String) -> Observable<(Bool, DeletingIngredient)>
    static func searchIngredients(text: String)
    
}

class RefrigeratorDM: RefrigeratorProtocol {
    
    
    static let db = Firestore.firestore()
    
    //    var ingredients:[RefrigeratorItem] = []
    
    static func addIngredient(name: String, amount: String, userID: String, lastIndex: Int) -> Completable {
        
        return Completable.create { completable in
            
            self.db.collection("users").document(userID).collection("refrigerator").document().setData([
                
                "name": name,
                "amount": amount,
                "order": lastIndex
                
            ], merge: true) { err in
                if let err = err {
                    
                    completable(.error(err))
                    
                } else {
                    
                    completable(.completed)
                }
                
            }
            return Disposables.create()
        }
        
    }
    
    static func editIngredient(edittingItem: Ingredient, name: String, amount: String, userID: String) -> Completable {
        
        return Completable.create { completable in
            
            db.collection("users").document(userID).collection("refrigerator").document(edittingItem.key).setData(
                
                [ "name": name,
                  "amount": amount], merge: true) { err in
                
                if let err = err {
                    
                    completable(.error(err))
                    
                } else {
                    
                    completable(.completed)
                }
                
            }
            
            
            return Disposables.create()
        }
    }
    
    static func moveIngredient(userID: String, items: [Ingredient]) -> Observable<Bool> {
        
        
        return Observable.create { observer in
            
            items.enumerated().forEach { index, item in
                
                if item.order != index {
                    
                    db.collection("users").document(userID).collection("refrigerator").document(item.key).setData([
                        
                        "order": index
                        
                    ], merge: true) { err in
                       
                        if let err = err {
                            
                            observer.onError(err)
                            
                        } else {
                            
                            if index == items.count - 1 {
                                
                                observer.onNext(true)
                                
                            }
                            else {
                                
                                observer.onNext(false)
                                
                            }
                        }
                        
                    }
                }
            }
            
            return Disposables.create()
        }
        
    }

    
    static func getIngredients(userID: String)  -> Single<[RefrigeratorItem]> {
        
        
        return Single.create { single in
           
            db.collection("users").document(userID).collection("refrigerator").addSnapshotListener { querySnapshot, err in

                if let err = err {
                
                    single(.failure(err))
               
                } else {
                    
                    let ingredients = querySnapshot?.documents.map { doc  -> RefrigeratorItem in
                        
                        if let ingredient = RefrigeratorItem(document: doc) {
                            return ingredient
                        }
                        
                        return RefrigeratorItem(key: "", name: "", amount: "", order: 0)
                    }
                    .filter { $0.name != "" && $0.amount != "" && $0.key != "" }
                    
                    single(.success(ingredients ?? []))
                    
                }
                
            }
            return Disposables.create()
        }
        
    }
    
    static func deleteIngredient(item: RefrigeratorItem, userID: String) -> Completable {
        
        return Completable.create { completable in
            
            let key = item.key
            
            db.collection("users").document(userID).collection("refrigerator").document(key).delete() { err in
                
                if let err = err {
                    
                    completable(.error(err))
                    
                } else {
                    
                    completable(.completed)
                    
                }
            }
            return Disposables.create()
        }
    }
    
    static func deleteIngredients(items: [DeletingIngredient], userID: String) -> Observable<(Bool, DeletingIngredient)> {
        
       
        return Observable.create { observer in
            
            items.enumerated().forEach { index, ingredient in
                
                db.collection("users").document(userID).collection("refrigerator").document(ingredient.item.key).delete() { err in
                    
                    if let err = err {
                        
                        print(ingredient.index, ingredient.item)
                        observer.onError(err)
                        
                    } else {
                        
                        if index == items.count - 1 {
                            
                            observer.onNext((true, ingredient))
                        
                        }
                        else {
                        
                            observer.onNext((false, ingredient))
                        
                        }
                    }
                }
                
            }
            return Disposables.create()
        }
    }
    
   static func searchIngredients(text: String) {
        
        let uid = (Auth.auth().currentUser?.uid)!
        
        db.collection("user").document(uid).collection("refrigerator").whereField("name", isEqualTo: text).getDocuments{ (querySnapshot, err) in
            //the data has returned from firebase and is valid
            
            if let err = err {
                print("Error updating document: \(err)")
            } else {
                print("Document successfully updated")
                
//                self.ingredients.removeAll()
                
                if !querySnapshot!.isEmpty {
                    
                    for document in querySnapshot!.documents {
                        
                        let data = document.data()
                        
                        print("data count: \(data.count)")
                        
                        if let ingredient = RefrigeratorItem.init(document: document) {
                        
//                            self.ingredients.append(ingredient)
                        }
                        
                    }
                    
                } else {
                    print("No Ingredients found")
                }
                
            }
        }
        
    }
    
}


