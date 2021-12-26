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
    static func getFollowers(user: Firebase.User, userID: String) -> Observable<[RelatedUser]>
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
                return RelatedUser.generateNewFollowings(documents: $0)
            }
        
        
        
    }
    
    
    static func getFollowers(user: Firebase.User, userID: String) -> Observable<[RelatedUser]> {
        
        var query: Query!
        
        if user.uid == userID {
            
            query = db.collection("users").document(user.uid).collection("followers").whereField("isFollowed", isEqualTo: true)
            
        }
        else {
            
            query = db.collection("users").document(userID).collection("followers").whereField("isFollowed", isEqualTo: true)
            
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
            .flatMapLatest { docs -> Observable<[(DocumentSnapshot, Bool)]> in
                
                let path = db.collection("users").document(userID)
                
                return services.getDocument(path: path)
                    .map { myInfoDoc -> [(DocumentSnapshot, Bool)] in
                        
                        if let data = myInfoDoc.data(), let followingIDs = data["followingsIDs"] as? [String: Bool] {
                            let userInfoTuples: [(DocumentSnapshot, Bool)] = docs.compactMap { doc in
                                
                                let id = doc.documentID
                                
                                guard followingIDs.keys.contains(id) else {
                                    return (doc, false)
                                }
                                
                                return (doc, true)
                            }
                            
                            return userInfoTuples
                        }
                        
                        return docs.map { ($0, false) }
                        
                    }
            }
            .flatMapLatest {
                return RelatedUser.generateNewUsers(userInfoTuples: $0)
            }
        
    }
    
    static func followUser(user: Firebase.User, willFollowUser: User) -> Observable<Void> {
        
        return .zip(addNewFollower(user: user, publisher: willFollowUser).map { _ in }, addNewFollowing(user: user, publisher: willFollowUser), addNewFollowingUnderUser(user: user, publisher: willFollowUser), addNewFollowedUnderUser(user: user, publisher: willFollowUser)) { _, _, _, _ in
            
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
    
    
    static func addNewFollowedUnderUser(user: Firebase.User, publisher: User) -> Observable<Void>  {
        
        let path = db.collection("users").document(publisher.userID)
        
        
        return services.getDocument(path: path)
            .map { data in
                
                if let idsDic = data["followedsIDs"] as? [String: Bool] {
                    
                    var ids = idsDic
                    
                    ids[user.uid] = true
                    
                    let newData = ["followedsIDs": ids]
                    
                    return newData
                    
                }
                
                return ["followedsIDs": [user.uid: true]]
            }
            .flatMapLatest {
                self.services.updateData(path: path, data: $0)
            }
            .map { _ in }
        
    }
    
    static func unFollowUser(user: Firebase.User, willUnFollowUser: User) -> Observable<Void> {
        
        let removeFollowingIDs = removeMyFollowingID(user: user, willUnFollowUser: willUnFollowUser)
        let removeFollowedIDs = removeFollowedsIDs(user: user, willUnFollowUser: willUnFollowUser)
        
        let myFollowingsPath = db.collection("users").document(user.uid).collection("followings").document(willUnFollowUser.userID)
        let publisherFollowerPath = db.collection("users").document(willUnFollowUser.userID).collection("followers").document(user.uid)
        
        let updateStatus = updateFollowerFollowingStatus(followingPath: myFollowingsPath, followerPath: publisherFollowerPath)
        
        return .zip(removeFollowingIDs, removeFollowedIDs, updateStatus) { _, _, _ in
            return
        }
        
    }
    
    fileprivate static func removeMyFollowingID(user: Firebase.User, willUnFollowUser: User) -> Observable<Void> {
        
        let path = db.collection("users").document(user.uid)
        
        return removeFollowingID(path: path, removingUserID: willUnFollowUser.userID)
        
    }
    
    fileprivate static func removeFollowedsIDs(user: Firebase.User, willUnFollowUser: User) -> Observable<Void> {
        
        let path = db.collection("users").document(willUnFollowUser.userID)
        
        return removeFollowerID(path: path, removingUserID: user.uid)
    }
    
    
    static func stopFollowing(followerID: String, user: Firebase.User) -> Observable<Void> {
        
        let myDocPath = db.collection("users").document(user.uid)
        let userDocPath = db.collection("users").document(followerID)
        
        return .zip(removeFollowerID(path: myDocPath, removingUserID: followerID), removeFollowingID(path: userDocPath, removingUserID: user.uid), updateFollowerFollowingStatus(followingPath: userDocPath, followerPath: myDocPath)) { _, _, _ in
            
            return
        }
        
    }
    
    
    static func removeFollowerID(path: DocumentReference, removingUserID: String) -> Observable<Void> {
        
        return services.getDocument(path: path)
            .compactMap { doc  in
                
                if let data = doc.data(), let idsDic = data["followedsIDs"] as? [String: Bool], let index = idsDic.firstIndex(where: { key, _ in
                    
                    return key == removingUserID
                    
                }) {
                    
                    var ids = idsDic
                    
                    ids.remove(at: index)
                    
                    let newData = ["followedsIDs": ids]
                    
                    return newData
                    
                }
                
                return nil
            }
            .flatMapLatest {
                services.updateData(path: path, data: $0).map { _ in }
            }
        
    }
    
    static func removeFollowingID(path: DocumentReference, removingUserID: String) -> Observable<Void> {
        
        return services.getDocument(path: path)
            .compactMap { doc  in
                
                if let data = doc.data(),let idsDic = data["followingsIDs"] as? [String: Bool], let index = idsDic.firstIndex(where: { key, _ in
                    
                    return key == removingUserID
                    
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
    
    fileprivate static func updateFollowerFollowingStatus(followingPath: DocumentReference, followerPath: DocumentReference) -> Observable<Void> {
        
        let updateFollowingStatusData = ["isFollowing": false]
        let updateFollowertatusData = ["isFollowed": false]
        
        return services.updateData(path: followingPath, data: updateFollowingStatusData)
            .flatMapLatest { _ in
                services.updateData(path: followerPath, data: updateFollowertatusData)
            }
            .map { _ in }
        
    }
    
}
