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
    
    static func getRefrigeratorItems(userID: String) -> Single<[Ingredient]>
    static func getShoppinglist(userID: String) -> Single<([ShoppingItem], [QueryDocumentSnapshot])>
    static func addIngredient(id: String?, name: String, amount: String, userID: String, lastIndex: Int, listName: List) -> Completable
    static func editIngredient(edittingItem: Ingredient, name: String, amount: String, userID: String, listName: List) -> Completable
    static func moveIngredient(userID: String, items: [Ingredient], listName: List) -> Observable<Bool>
    //    static func removeDeletingItem(items: [ShoppingItem], deletingItem: Ingredient) -> Observable<[Ingredient]>
    static func filterDifferentOrder(items: [Ingredient], deletingItem: Ingredient) -> Observable<([Ingredient], Ingredient)>
    static func moveIngredient(userID: String, items: [Ingredient], deletingItem: Ingredient, listName: List) -> Observable<(Bool?, Ingredient)> //    static func deleteIngredient(item: Ingredient, userID: String, listName: List) -> Completable
    static func deleteIngredient(item: Ingredient, userID: String, listName: List) -> PublishSubject<Ingredient>
    static func deleteIngredients(items: [DeletingIngredient], userID: String, listName: List) -> Observable<DeletingIngredient>
    static func boughtItems(userID: String, items: [ShoppingItem]) -> Observable<Bool>
    static func filterDifferencntBoughtStatus(docs: [QueryDocumentSnapshot], processedItems: [ShoppingItem]) -> Observable<[ShoppingItem]>
    static func isBoughtShoppinglistItems(processedItems: [ShoppingItem], userID: String) -> Observable<(Bool, ShoppingItem)>
    static func getRefrigeratorDocsCount(userID: String) -> PublishSubject<Int>
    //    static func boughtIngredient(userID: String, item: ShoppingItem) -> Observable<Bool>
    static func searchIngredients(text: String, userID: String, listName: List)
    
}

class RefrigeratorDM: RefrigeratorProtocol {
    
    static let db = Firestore.firestore().collection("users")
    
    static func addIngredient(id: String?, name: String, amount: String, userID: String, lastIndex: Int, listName: List) -> Completable {
        
        return Completable.create { completable in
            
            var data:[String:Any] = [:]
            let uuid = UUID()
            let uniqueIdString = uuid.uuidString.replacingOccurrences(of: "-", with: "")
            
            switch listName {
            case .refrigerator:
                data = [
                    
                    "id": id ?? uniqueIdString,
                    "name": name,
                    "amount": amount,
                    "order": lastIndex,
                ]
                
            case .shoppinglist:
                
                data = [
                    
                    "id": uniqueIdString,
                    "name": name,
                    "amount": amount,
                    "order": lastIndex,
                    "isBought": false
                ]
            }
            
            print(listName.rawValue)
            
            self.db.document(userID).collection(listName.rawValue).document(id ?? uniqueIdString).setData(data, merge: true) { err in
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
            
            db.document(userID).collection(listName.rawValue).document(edittingItem.id).updateData(
                
                [
                    "name": name,
                    "amount": amount
                    
                ]) { err in
                
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
            
            let movedItems:[Ingredient] = items.enumerated().compactMap { index, item -> Ingredient? in
                
                if index != item.order {
                    item.order = index
                    return item
                }
                else {
                    return nil
                }
                
            }
            
            movedItems.enumerated().forEach { index, item in
                
                db.document(userID).collection(listName.rawValue).document(item.id).updateData([
                    
                    "order": item.order
                    
                ]) { err in
                    
                    if let err = err {
                        
                        observer.onError(err)
                        
                    } else {
                        
                        if index == movedItems.count - 1 {
                            
                            observer.onNext(true)
                            
                        }
                        else {
                            
                            observer.onNext(false)
                            
                        }
                    }
                    
                }
            }
            
            //            items.enumerated().forEach { index, item in
            //
            //                if item.order != index {
            //
            //                    db.document(userID).collection(listName.rawValue).document(item.id).setData([
            //
            //                        "order": index,
            //                        "ordered": true
            //
            //                    ], merge: true) { err in
            //
            //                        if let err = err {
            //
            //                            observer.onError(err)
            //
            //                        } else {
            //
            //                            if index == items.count - 1 {
            //
            //                                observer.onNext(true)
            //
            //                            }
            //                            else {
            //
            //                                observer.onNext(false)
            //
            //                            }
            //                        }
            //
            //                    }
            //                }
            //            }
            
            return Disposables.create()
        }
        
    }
    
    
    static func filterDifferentOrder(items: [Ingredient], deletingItem: Ingredient) -> Observable<([Ingredient], Ingredient)> {
        
        print("before ordered deleting item \(deletingItem.name)")
        
        return Observable.create { observer in
            
            let removedItems = items.filter { $0.id != deletingItem.id }
            
            let movedItems:[Ingredient] = removedItems.enumerated().compactMap { index, item -> Ingredient? in
                
                if index != item.order {
                    item.order = index
                    return item
                }
                else {
                    return nil
                }
                
            }
            
            observer.onNext((movedItems, deletingItem))
            
            return Disposables.create()
        }
    }
    
    static func moveIngredient(userID: String, items: [Ingredient], deletingItem: Ingredient, listName: List) -> Observable<(Bool?, Ingredient)> {
        
        return Observable.create { observer in
            
            print("move after delete \(deletingItem.name)")
            let movedItems:[Ingredient] = items.enumerated().compactMap { index, item -> Ingredient? in
                
                if index != item.order {
                    item.order = index
                    return item
                }
                else {
                    return nil
                }
                
            }
            
            print("------------")
            print("count")
            print(movedItems.count)
            
            if movedItems.isEmpty  {
                print("no need to move item \(deletingItem.name)")
                observer.onNext((nil, deletingItem))
            }
            else  {
                
                print("there are moving items")
                print(deletingItem.name)
                movedItems.enumerated().forEach { index, item in
                    
                    db.document(userID).collection(listName.rawValue).document(item.id).updateData([
                        
                        "order": item.order
                        
                    ]) { err in
                        
                        if let err = err {
                            
                            observer.onError(err)
                            
                        } else {
                            
                            if index == movedItems.count - 1 {
                                
                                observer.onNext((true, deletingItem))
                                
                            }
                            else {
                                
                                observer.onNext((false, deletingItem))
                                
                            }
                        }
                    }
                }
            }
            
            return Disposables.create()
        }
    }
    
    // -> single<([ingredient], [querydocumentsnapshot]> でもあり
    static func getRefrigeratorItems(userID: String)  -> Single<[Ingredient]> {
        
        var results:[RefrigeratorItem] = []
        
        return Single.create { single in
            
            db.document(userID).collection("refrigerator").addSnapshotListener { querySnapshot, err in
                
                if let err = err {
                    
                    single(.failure(err))
                    
                } else {
                    
                    let orderedIngredients = querySnapshot?.documents.map { doc  -> RefrigeratorItem in
                        
                        if let ingredient = RefrigeratorItem(document: doc) {
                            return ingredient
                        }
                        
                        return RefrigeratorItem(key: "", name: "", amount: "", order: 0)
                    }
                    .filter { $0.name != "" && $0.amount != "" && $0.id != "" }
                    
                    //                    single(.success(ingredients ?? []))
                    
                    if let ingredients = orderedIngredients {
                        results.append(contentsOf: ingredients)
                    }
                    
                    db.document(userID).collection("refrigerator").whereField("ordered", isEqualTo: false).addSnapshotListener { querySnapshot, err in
                        
                        if let err = err {
                            
                            single(.failure(err))
                            
                        } else {
                            
                            let unorderedIngredients = querySnapshot?.documents.enumerated().map { index, doc  -> RefrigeratorItem in
                                
                                if let ingredient = RefrigeratorItem(document: doc, index: results.count + index + 1) {
                                    
                                    return ingredient
                                }
                                
                                return RefrigeratorItem(key: "", name: "", amount: "", order: 0)
                            }
                            .filter { $0.name != "" && $0.amount != "" && $0.id != "" }
                            
                            if let ingredients = unorderedIngredients {
                                results.append(contentsOf: ingredients)
                            }
                            
                            single(.success(results))
                        }
                    }
                }
                
            }
            return Disposables.create()
        }
        
    }
    
    static func getShoppinglist(userID: String) -> Single<([ShoppingItem], [QueryDocumentSnapshot])> {
        
        var ingredients:[ShoppingItem] = []
        var resultDocs:[QueryDocumentSnapshot] = []
        
        return Single.create { single in
            
            db.document(userID).collection("shoppinglist").whereField("isBought", isEqualTo: false).addSnapshotListener { querySnapshot, err in
                
                if let err = err {
                    
                    single(.failure(err))
                    
                } else {
                    
                    
                    let shoppinglist = querySnapshot?.documents.map { doc  -> ShoppingItem in
                        
                        if let ingredient = ShoppingItem(document: doc) {
                            return ingredient
                        }
                        
                        return ShoppingItem(name: "", amount: "", key: "", isBought: false, order: 0)
                    }
                    .filter { $0.name != "" && $0.amount != "" && $0.id != "" }
                    
                    if let shoppinglist = shoppinglist {
                        ingredients.append(contentsOf: shoppinglist)
                        ingredients = ingredients.sorted { $0.order < $1.order }
                    }
                    
                    if let docs = querySnapshot?.documents {
                        resultDocs.append(contentsOf: docs)
                    }
                    
                    let calendar = Calendar.current
                    let components = calendar.dateComponents([.year, .month, .day], from: Date())
                    let start = calendar.date(from: components)!
                    
                    if let end = calendar.date(byAdding: .day, value: 7, to: start) {
                        
                        db.document(userID).collection("shoppinglist").whereField("boughtDate", isLessThan: end).addSnapshotListener { querySnapshot, err in
                            
                            if let err = err {
                                
                                
                                single(.success((ingredients, resultDocs)))
                                single(.failure(err))
                                
                            } else {
                                
                                let shoppinglist = querySnapshot?.documents.map { doc  -> ShoppingItem in
                                    
                                    if let ingredient = ShoppingItem(document: doc) {
                                        return ingredient
                                    }
                                    
                                    return ShoppingItem(name: "", amount: "", key: "", isBought: false, order: 0)
                                }
                                .filter { $0.name != "" && $0.amount != "" && $0.id != "" }
                                .filter { $0.isBought }
                                
                                if let shoppinglist = shoppinglist {
                                    ingredients.append(contentsOf: shoppinglist)
                                    ingredients = ingredients.sorted { $0.order < $1.order }
                                    
                                }
                                
                                if let docs = querySnapshot?.documents {
                                    resultDocs.append(contentsOf: docs)
                                }
                                
                                single(.success((ingredients, resultDocs)))
                                
                                
                            }
                            
                        }
                        
                        
                    }
                    
                    
                    
                }
                
            }
            return Disposables.create()
        }
        
    }
    
    //    static func deleteIngredient(item: Ingredient, userID: String, listName: List) -> Completable {
    //
    //        return Completable.create { completable in
    //
    //
    //            db.document(userID).collection(listName.rawValue).document(item.id).delete() { err in
    //
    //                if let err = err {
    //
    //                    completable(.error(err))
    //
    //                } else {
    //
    //                    completable(.completed)
    //
    //                }
    //            }
    //            return Disposables.create()
    //        }
    //    }
    
    static func deleteIngredient(item: Ingredient, userID: String, listName: List) -> PublishSubject<Ingredient> {
        
        let subject = PublishSubject<Ingredient>()
        
        
        db.document(userID).collection(listName.rawValue).document(item.id).delete() { err in
            
            if let err = err {
                
                subject.onError(err)
                
            } else {
                
                subject.onNext(item)
                
            }
        }
        return subject
    }
    
    static func deleteIngredients(items: [DeletingIngredient], userID: String, listName: List) -> Observable<DeletingIngredient> {
        
        
        return Observable.create { observer in
            
            items.enumerated().forEach { index, ingredient in
                
                db.document(userID).collection(listName.rawValue).document(ingredient.item.id).delete() { err in
                    
                    if let err = err {
                        
                        print(ingredient.index, ingredient.item)
                        observer.onError(err)
                        
                    } else {
                        
                        print("deleted \(ingredient.item.id) \(ingredient.item.name)")
                       
                            
                        observer.onNext(ingredient)
                            

                    }
                }
                
            }
            return Disposables.create()
        }
    }
    // when bought an item its order would be next index than an last item that is not bought
    static func boughtItems(userID: String, items: [ShoppingItem]) -> Observable<Bool> {
        
        let today = Date()
        let uuid = UUID()
        let uniqueIdString = uuid.uuidString.replacingOccurrences(of: "-", with: "")
        
        return Observable.create { observer in
            
            
            db.document(userID).collection("refrigerator").getDocuments { querySnapShot, err in
                
                if let err = err {
                    
                    observer.onError(err)
                    
                }
                else {
                    
                    if let docsNum = querySnapShot?.documents.count {
                        
                        
                        items.enumerated().forEach { index, item in
                            
                            db.document(userID).collection("shoppinglist").document(item.id).updateData([
                                
                                "boughtDate": today,
                                "isBought": false
                                //                                "order":
                                
                            ]) { err in
                                
                                if let err = err {
                                    
                                    print("failed to update the data of \(item.id) in shppinglist")
                                    print(item.id)
                                    print(item)
                                    observer.onError(err)
                                    
                                }
                                else {
                                    
                                    db.document(userID).collection("refrigerator").document(item.id).setData([
                                        
                                        "id": uniqueIdString,
                                        "name": item.name,
                                        "amount": item.amount,
                                        "order": docsNum + index + 1
                                        
                                    ], merge: true) { err in
                                        
                                        if let err = err {
                                            
                                            print("failed to update the data of \(item.id) in refrigerator")
                                            print(item.id)
                                            print(item)
                                            observer.onError(err)
                                            
                                        }
                                        else {
                                            
                                            
                                            if index == items.count - 1 {
                                                observer.onNext(true)
                                            }
                                            
                                        }
                                    }
                                    
                                }
                            }
                            
                            
                        }
                    }
                }
            }
            
            
            
            return Disposables.create()
        }
        
    }
    
    static func filterDifferencntBoughtStatus(docs: [QueryDocumentSnapshot], processedItems: [ShoppingItem]) -> Observable<[ShoppingItem]> {
        
        return Observable.create { observer in
            // documentをShoppinglistに変換
            let originalShoppinglist: [ShoppingItem] = docs.map { doc  -> ShoppingItem in
                
                if let ingredient = ShoppingItem(document: doc) {
                    return ingredient
                }
                
                return ShoppingItem(name: "", amount: "", key: "", isBought: false, order: 0)
            }
            .filter { $0.name != "" && $0.amount != "" && $0.id != "" }
            .sorted { $0.order < $1.order }
            
            // isBoughtの値が変わった要素のみ取り出す。
            // compactMapはnilで返すとその要素は新しい配列に入らない。
            
            let changedBoughtStatusItems = processedItems.compactMap { item -> ShoppingItem? in
                
                guard let compareItem: ShoppingItem = originalShoppinglist.first(where: { $0.id == item.id }) else {
                    return nil
                }
                
                if compareItem.isBought != item.isBought {
                    return item
                }
                else {
                    return nil
                }
            }
            observer.onNext(changedBoughtStatusItems)
            
            return Disposables.create()
        }
    }
    
    static func isBoughtShoppinglistItems(processedItems: [ShoppingItem], userID: String) -> Observable<(Bool, ShoppingItem)> {
        
        return Observable.create { observer in
            
            
            let today = Date()
            
            // そのアイテムを買った場合
            //            ・shoppinglistのそのアイテムのisBoughtをtrueにし、いつ買ったかを書き込む。
            //            　・refrigeratorの中にそのアイテムの新しいドキュメントを作る
            // そのアイテムを買っていない場合、
            //            ・shoppinglistのそのアイテムのisBoughtをfalseにする。boughtDateは削除する。
            //            ・refrigeratorの中のそのアイテムのドキュメントは削除する
            
            processedItems.enumerated().forEach { index, item in
                
                var data: [String : Any] = [:]
                
                if item.isBought {
                    data = [
                        
                        "boughtDate": today,
                        "isBought": true
                    ]
                }
                else {
                    data = [
                        
                        "boughtDate": FieldValue.delete(),
                        "isBought": false
                        
                    ]
                }
                
                db.document(userID).collection("shoppinglist").document(item.id).updateData(data) { err in
                    
                    if let err = err {
                        
                        print(item.id)
                        print(item.name)
                        observer.onError(err)
                    }
                    else {
                        
                        if index == processedItems.count - 1 {
                            observer.onNext((true, item))
                        }
                        else {
                            observer.onNext((false, item))
                        }
                    }
                    
                }
            }
            
            return Disposables.create()
        }
        
    }
    
    static func getRefrigeratorDocsCount(userID: String) -> PublishSubject<Int> {
        
        let subject = PublishSubject<Int>()
        
        db.document(userID).collection("refrigerator").getDocuments { querySnapShot, err in
            
            if let err = err {
                subject.onError(err)
            }
            else {
                
                if let count = querySnapShot?.documents.count {
                    subject.onNext(count)
                }
            }
        }
        
        return subject
    }
    
    
    
    static func searchIngredients(text: String, userID: String, listName: List) {
        
        db.document(userID).collection(listName.rawValue).whereField("name", isEqualTo: text).getDocuments{ (querySnapshot, err) in
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

