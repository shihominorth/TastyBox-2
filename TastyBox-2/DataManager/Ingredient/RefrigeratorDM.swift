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
  
    static func addIngredient(name: String, amount: String, userID: String) -> Completable
    static func editIngredient(name: String, amount: String, userID: String)
    static func getRefrigeratorDetail(userID: String) -> Single<[RefrigeratorItem]>
    static func deleteData(name: String, indexPath: IndexPath)
    static func searchIngredients(text: String)

}

class RefrigeratorDM: RefrigeratorProtocol {

   static let db = Firestore.firestore()
    
//    var delegate: getIngredientRefrigeratorDataDelegate?
    
    var ingredients:[RefrigeratorItem] = []
    
    static func editIngredient(name: String, amount: String, userID: String) {
        
        db.collection("users").document(userID).collection("refrigerator").document(name).setData(
            [ "name": name,
              "amount": amount,], merge: true)
    }
    
    static func addIngredient(name: String, amount: String, userID: String) -> Completable {
        
        return Completable.create { completable in
            
            self.db.collection("users").document(userID).collection("refrigerator").document(name).setData([
                "name": name,
                "amount": amount,
                
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
    
    static func getRefrigeratorDetail(userID: String)  -> Single<[RefrigeratorItem]> {
        
        
        return Single.create { single in
           
            db.collection("users").document(userID).collection("refrigerator").addSnapshotListener { querySnapshot, err in

                if let err = err {
                
                    single(.failure(err))
               
                } else {
                    
                    let ingredients = querySnapshot?.documents.map { doc  -> RefrigeratorItem in
                        
                        if let ingredient = RefrigeratorItem(document: doc) {
                            return ingredient
                        }
                        
                        return RefrigeratorItem(name: "", amount: "", key: "")
                    }
                    .filter { $0.name != "" && $0.amount != "" && $0.key != "" }
                    
                    single(.success(ingredients ?? []))
                    
                }
                
            }
            return Disposables.create()
        }
        
    }
    
   static func deleteData(name: String, indexPath: IndexPath) {
        
        guard let uid = Auth.auth().currentUser?.uid else { return }
        db.collection("user").document(uid).collection("refrigerator").document(name).delete()
            { err in
                if let err = err {
                    print("Error updating document: \(err)")
                } else {
                    print("Document successfully updated")
                }
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


