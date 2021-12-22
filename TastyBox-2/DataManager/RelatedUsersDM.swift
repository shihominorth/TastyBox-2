//
//  RelatedUsersDM.swift
//  TastyBox-2
//
//  Created by 北島　志帆美 on 2021-12-22.
//

import Foundation
import Firebase
import RxSwift

protocol RelatedUsersProtocol {
    
    static var services: FireStoreServices { get }
    static func getFollowings(user: Firebase.User, userID: String) -> Observable<[RelatedUser]>
    static func followUser(user: Firebase.User, willFollowUser: User) -> Observable<Void>
    static func unFollowUser(user: Firebase.User, willUnFollowUser: User) -> Observable<Void>
    
}

class RelatedUsersDM: RelatedUsersProtocol {

    static var services: FireStoreServices {
        
        return FireStoreServices()
        
    }
    
    
    static let db = Firestore.firestore()
    static let storage = Storage.storage().reference()
    
    static func getFollowings(user: Firebase.User, userID: String) -> Observable<[RelatedUser]> {
        
        var query: Query!
        
        if user.uid == userID {
            
            query = db.collection("users").document(user.uid).collection("followings").whereField("isFollowing", isEqualTo: true)
            
        }
        else {
            
            query = db.collection("users").document(userID).collection("followings").whereField("isFollowing", isEqualTo: true)
            
        }
        
        return services.getDocuments(query: query)
            .map {
                let ids = $0.compactMap { doc -> String? in
                    
                    let data = doc.data()
                    
                    return data["id"] as? String
                    
                }
                
                let paths: [DocumentReference] = ids.map {
                    return db.collection("users").document($0)
                }
                
                return paths
            }
            .flatMapLatest {
                return services.getDocuments(documentReferences: $0)
            }
            .flatMapLatest {
                return RelatedUser.generateNewUsers(documents: $0)
            }
        
        
        
    }
    
    static func followUser(user: Firebase.User, willFollowUser: User) -> Observable<Void> {
       
        return .zip(addNewFollower(user: user, publisher: willFollowUser).map { _ in }, addNewFollowing(user: user, publisher: willFollowUser), addNewFollowingUnderUser(user: user, publisher: willFollowUser)) { _, _, _ in
            
            return
            
        }
        
    }
    
    static func addNewFollower(user: Firebase.User, publisher: User) -> Observable<Void> {
        
        let data:[String: Any] = [
            
            "id": user.uid,
            "followedDate": Date(),
            "isFollowed": true
        ]
        
        let path = db.collection("users").document(publisher.userID).collection("followers").document(user.uid)
        
        return services.setData(path: path, data: data).map { _ in }
 
    }
    
    static func addNewFollowing(user: Firebase.User, publisher: User) -> Observable<Void>  {
        
        let data:[String: Any] = [
            
            "id": publisher.userID,
            "followingDate": Date(),
            "isFollowing": true
        ]
        
        let path = db.collection("users").document(user.uid).collection("followings").document(publisher.userID)
               
        
        return services.setData(path: path, data: data).map { _ in }
 
    }
    
    static func addNewFollowingUnderUser(user: Firebase.User, publisher: User) -> Observable<Void>  {

        let path = db.collection("users").document(user.uid)
               
        
        return services.getDocument(path: path)
            .map { data in
                
                if let idsDic = data["followingsIDs"] as? [String: Bool] {
                    
                    var ids = idsDic
                    
                    ids[publisher.userID] = true
                    
                    let newData = ["followingsIDs": ids]
                    
                    return newData
                    
                }
                
                return ["followingsIDs": [publisher.userID: true]]
            }
            .flatMapLatest {
                self.services.updateData(path: path, data: $0)
            }
            .map { _ in }
 
    }
    
    static func unFollowUser(user: Firebase.User, willUnFollowUser: User) -> Observable<Void> {
        
        let removeFollowingIDs = removeFollowingIDs(user: user, publisher: willUnFollowUser)

        let updateStatus = updateFollowerFollowingStatus(user: user, publisher: willUnFollowUser)
        
        return .zip(removeFollowingIDs, updateStatus) { _, _ in
            return
        }
        
    }
    
    fileprivate static func removeFollowingIDs(user: Firebase.User, publisher: User) -> Observable<Void> {
        
        let path = db.collection("users").document(user.uid)
        
        return services.getDocument(path: path)
            .compactMap { data  in
                
                if let idsDic = data["followingsIDs"] as? [String: Bool], let index = idsDic.firstIndex(where: { key, _ in
                    
                    return key == publisher.userID
                    
                }) {
                    
                    var ids = idsDic
                    
                    ids.remove(at: index)
                    
                    let newData = ["followingsIDs": ids]
                    
                    return newData
                    
                }
                
                return nil
            }
            .flatMapLatest {
                services.updateData(path: path, data: $0).map { _ in }
            }
    }
    
    
    fileprivate static func updateFollowerFollowingStatus(user: Firebase.User, publisher: User) -> Observable<Void> {
       
        let myFollowingsPath = db.collection("users").document(user.uid).collection("followings").document(publisher.userID)
        let publisherFollowerPath = db.collection("users").document(publisher.userID).collection("followers").document(user.uid)
        let updateFollowingStatusData = ["isFollowing": false]
        let updateFollowertatusData = ["isFollowed": false]
        
        return services.updateData(path: myFollowingsPath, data: updateFollowingStatusData)
            .flatMapLatest { _ in
                services.updateData(path: publisherFollowerPath, data: updateFollowertatusData)
            }
            .map { _ in }
    
    }
    
}
