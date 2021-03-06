//
//  User.swift
//  TastyBox-2
//
//  Created by 北島　志帆美 on 2021-08-26.
//

import Foundation
import DifferenceKit
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

extension User: Differentiable {
    
    func isContentEqual(to source: User) -> Bool {
        
        return self.userID == source.userID
        
    }
    
    var differenceIdentifier: String {
        return self.userID
    }
}


class RelatedUser {
    
    let isRelatedUserSubject: BehaviorSubject<Bool>
    let user: User
    
    init(isRelatedUser: Bool, user: User) {
        
        self.isRelatedUserSubject = BehaviorSubject<Bool>(value: isRelatedUser)
        self.user = user
        
    }
   
    
    init?(document:  DocumentSnapshot, isRelatedUser: Bool) {
       
        guard
            let user = User(document: document)
        else {
            return nil
        }

        self.isRelatedUserSubject = BehaviorSubject<Bool>(value: isRelatedUser)
        self.user = user

    }
    
    static func generateNewFollowings(documents: [DocumentSnapshot]) -> Observable<[RelatedUser]> {
        
        return .create { observer in
            
            let users = documents.compactMap { doc in
            
                return RelatedUser(document: doc, isRelatedUser: true)
            
            }
            
            observer.onNext(users)
            
            return Disposables.create()
        }
        
    }
    
    static func generateNewUsers(userInfoTuples: [(DocumentSnapshot, Bool)]) -> Observable<[RelatedUser]> {
        
        return .create { observer in
            
            let users = userInfoTuples.compactMap { userInfo in
            
                return RelatedUser(document: userInfo.0, isRelatedUser: userInfo.1)
            
            }
            
            observer.onNext(users)
            
            return Disposables.create()
        }
    
    }

}

extension RelatedUser: Differentiable {
    
    func isContentEqual(to source: RelatedUser) -> Bool {
        
        return self.user.userID == source.user.userID
        
    }
    
    var differenceIdentifier: String {
        return self.user.userID
    }
    
}
