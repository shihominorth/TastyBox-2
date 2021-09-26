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
    
    static func getIngredients(userID: String, listName: List) -> Single<[Ingredient]>
    static func addIngredient(name: String, amount: String, userID: String, lastIndex: Int, listName: List) -> Completable
    static func editIngredient(edittingItem: Ingredient, name: String, amount: String, userID: String, listName: List) -> Completable
    static func moveIngredient(userID: String, items: [Ingredient], listName: List) -> Observable<Bool>
    static func deleteIngredient(item: Ingredient, userID: String, listName: List) -> Completable
    static func deleteIngredients(items: [DeletingIngredient], userID: String, listName: List) -> Observable<(Bool, DeletingIngredient)>
    static func searchIngredients(text: String, userID: String, listName: List)
    
}

class RefrigeratorDM: RefrigeratorProtocol {
    
    static let db = Firestore.firestore()
    
    static func addIngredient(name: String, amount: String, userID: String, lastIndex: Int, listName: List) -> Completable {
        
        return Completable.create { completable in
            
            var data:[String:Any] = [:]
            
            switch listName {
            case .refrigerator:
                data = [
                    
                    "name": name,
                    "amount": amount,
                    "order": lastIndex
                    
                ]
                
            case .shoppinglist:
                
                data = [
                    
                    "name": name,
                    "amount": amount,
                    "order": lastIndex,
                    "isBought": false
                ]
            }
            
            print(listName.rawValue)
            
            self.db.collection("users").document(userID).collection(listName.rawValue).document().setData(data, merge: true) { err in
                if let err = err {
                    
                    completable(.error(err))
                    
                } else {
                    
                    completable(.completed)
                }
                
            }
            return Disposables.create()
        }
        
    }
    
    static func editIngredient(edittingItem: Ingredient, name: String, amount: String, userID: String, listName: List) -> Completable {
        
        return Completable.create { completable in
            
            db.collection("users").document(userID).collection(listName.rawValue).document(edittingItem.key).setData(
                
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
    
    static func moveIngredient(userID: String, items: [Ingredient], listName: List) -> Observable<Bool> {
        
        
        return Observable.create { observer in
            
            items.enumerated().forEach { index, item in
                
                if item.order != index {
                    
                    db.collection("users").document(userID).collection(listName.rawValue).document(item.key).setData([
                        
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
    
    
    static func getIngredients(userID: String, listName: List)  -> Single<[Ingredient]> {
        
        
        return Single.create { single in
            
            db.collection("users").document(userID).collection(listName.rawValue).addSnapshotListener { querySnapshot, err in
                
                if let err = err {
                    
                    single(.failure(err))
                    
                } else {
                    
                    switch listName {
                    case .refrigerator:
                        
                        let ingredients = querySnapshot?.documents.map { doc  -> RefrigeratorItem in
                            
                            if let ingredient = RefrigeratorItem(document: doc) {
                                return ingredient
                            }
                            
                            return RefrigeratorItem(key: "", name: "", amount: "", order: 0)
                        }
                        .filter { $0.name != "" && $0.amount != "" && $0.key != "" }
                        
                        single(.success(ingredients ?? []))
                        
                    case .shoppinglist:
                        
                        let ingredients = querySnapshot?.documents.map { doc  -> ShoppingItem in
                            
                            if let ingredient = ShoppingItem(document: doc) {
                                return ingredient
                            }
                            
                            return ShoppingItem(name: "", amount: "", key: "", isBought: false, order: 0)
                        }
                        .filter { $0.name != "" && $0.amount != "" && $0.key != "" }
                        
                        single(.success(ingredients ?? []))
                        
                    }
                    
                }
                
            }
            return Disposables.create()
        }
        
    }
    
    static func deleteIngredient(item: Ingredient, userID: String, listName: List) -> Completable {
        
        return Completable.create { completable in
            
            let key = item.key
            
            db.collection("users").document(userID).collection(listName.rawValue).document(key).delete() { err in
                
                if let err = err {
                    
                    completable(.error(err))
                    
                } else {
                    
                    completable(.completed)
                    
                }
            }
            return Disposables.create()
        }
    }
    
    static func deleteIngredients(items: [DeletingIngredient], userID: String, listName: List) -> Observable<(Bool, DeletingIngredient)> {
        
        
        return Observable.create { observer in
            
            items.enumerated().forEach { index, ingredient in
                
                db.collection("users").document(userID).collection(listName.rawValue).document(ingredient.item.key).delete() { err in
                    
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
    
    static func searchIngredients(text: String, userID: String, listName: List) {
        
        db.collection("user").document(userID).collection(listName.rawValue).whereField("name", isEqualTo: text).getDocuments{ (querySnapshot, err) in
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


