//
//  User.swift
//  TastyBox-2
//
//  Created by 北島　志帆美 on 2021-08-26.
//

import Foundation
import Firebase
import RxSwift

class User {
   
    var userID: String
    var name: String
    var imageURLString: String
    var cuisineType: String?
    var familySize: Int?
    var isVIP: Bool?
    
    init(id: String, name: String, isVIP: Bool, imgURLString: String) {
       
        self.userID = id
        self.name = name
        self.isVIP = isVIP
        self.imageURLString = imgURLString
    
    }
    
    init?(queryDoc:  QueryDocumentSnapshot) {
        
        let data = queryDoc.data()
        
        guard let id = data["id"] as? String,
              let name = data["userName"] as? String,
              let isVIP = data["isVIP"] as? Bool,
              let imgURL = data["imgString"] as? String
        else {
            return nil
        }
        
        self.userID = id
        self.name = name
        self.isVIP = isVIP
        self.imageURLString = imgURL

    }
    
    init?(document:  DocumentSnapshot) {
       
        guard
            let data = document.data(),
            let id = data["id"] as? String,
            let name = data["userName"] as? String,
            let isVIP = data["isVIP"] as? Bool,
            let imgURL = data["imgString"] as? String
        else {
            return nil
        }

        self.userID = id
        self.name = name
        self.isVIP = isVIP
        self.imageURLString = imgURL

    }

    static func generateNewUsers(queryDocs: [QueryDocumentSnapshot]) -> Observable<[User]> {
    
        return .create { observer in
            
            let users = queryDocs.compactMap { doc in
            
                return User(queryDoc: doc)
            
            }
            
            observer.onNext(users)
            
            return Disposables.create()
        }
    }
    
    static func generateNewUsers(documents: [DocumentSnapshot]) -> Observable<[User]> {
    
        return .create { observer in
            
            let users = documents.compactMap { doc in
            
                return User(document: doc)
            
            }
            
            observer.onNext(users)
            
            return Disposables.create()
        }
    }
    
}

struct  AllergicFoodData {
    var allergicFood: String
    var checkedFood: Bool?
}



struct AllFoodList {
    var allFood:[AllergicFoodData]
}




