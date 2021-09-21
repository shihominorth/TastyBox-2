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
    static func getRefrigeratorDetail(userID: String)
    static func deleteData(name: String, indexPath: IndexPath)
    static func searchIngredients(text: String)

}

class RefrigeratorDM: RefrigeratorProtocol {

   static let db = Firestore.firestore()
    
//    var delegate: getIngredientRefrigeratorDataDelegate?
    
    var ingredients:[RefrigeratorItem] = []
    
    static func editIngredient(name: String, amount: String, userID: String) {
        
        db.collection("user").document(userID).collection("refrigerator").document(name).setData(
            [ "name": name,
              "amount": amount,], merge: true)
    }
    
    static func addIngredient(name: String, amount: String, userID: String) -> Completable {
        
        return Completable.create { completable in
            
            self.db.collection("user").document(userID).collection("refrigerator").document(name).setData([
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
    
   static func getRefrigeratorDetail(userID: String) {
        
        db.collection("user").document(userID).collection("refrigerator").addSnapshotListener { querySnapshot, error in
            if error != nil {
                print("Error getting documents: \(String(describing: error))")
            } else {
                
//                self.ingredients.removeAll()
                
                //For-loop
                for document in querySnapshot!.documents {
                                        
                    
//                    let name = data["name"] as? String
//                    let amount = data["amount"] as? String
//
                    if let ingredient = RefrigeratorItem(document: document) {
                    
//                       self.ingredients.append(ingredient)
                    }
                    
                }
                
                if querySnapshot?.documents.count == 0 {
//                    self.delegate?.gotData(ingredients: self.ingredients)
                }
                
            }
            
//            self.delegate?.gotData(ingredients: self.ingredients)
            
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


