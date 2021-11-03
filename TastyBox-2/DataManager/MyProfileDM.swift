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
                
                if let err = err {
                    observer.onError(err)
                }
                else {
                    
                }
            }
            
            return Disposables.create()
        }
        
    }
}
