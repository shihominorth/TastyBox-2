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
    static func getMyPostedRecipes(user: Firebase.User) -> Observable<[Recipe]>
    
}

class MyProfileDM: MyProfileDMProtocol {
    
    static let db = Firestore.firestore()
    static let storage = Storage.storage().reference()
    
    static func getMyPostedRecipes(user: Firebase.User) -> Observable<[Recipe]> {
        
        return .create { observer in

            db.collection("recipes").whereField("publisherID", isEqualTo: user.uid).addSnapshotListener { snapShot, err in
                
                var recipes: [Recipe] = []
                
                if let err = err {
          
                    observer.onError(err)
          
                }
                else {
                    
                    
                    if let snapShot = snapShot {
                        
                        let documents = snapShot.documents
                        var implementedNum = 0
                        
                        documents.enumerated().forEach { index, doc in
                            
                            implementedNum += 1
                            
                            
                            if let recipe = Recipe(queryDoc: doc, user: user) {
                            
                                recipes.append(recipe)
                           
                            }
                           
                            if documents.count == implementedNum {
                                
                                observer.onNext(recipes)
                                
                            }
                            
                        }
                        
                    }
                    else {
                       
                        observer.onNext([])
                    
                    }
  
                }
            }
            
            return Disposables.create()
        }
        
    }
    

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
