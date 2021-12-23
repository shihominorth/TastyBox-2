//
//  ProfileDM.swift
//  TastyBox-2
//
//  Created by 北島　志帆美 on 2021-12-20.
//

import Foundation
import Firebase
import RxSwift

protocol ProfileDMProtocol: AnyObject {
    
    static var firestoreService: FireStoreServices { get }
    static func getPostRecipes(id: String) -> Observable<[Recipe]>
    static func isFollowing(publisherId: String, user: Firebase.User) -> Observable<Bool>
    static func followPublisher(user: Firebase.User, publisher: User) -> Observable<Void>
    static func unFollowPublisher(user: Firebase.User, publisher: User) -> Observable<Void>
    static func getUserInfo(userId: String) -> Observable<(followings:Int, followeds:Int)>

}

class ProfileDM: ProfileDMProtocol {
    
    static let db = Firestore.firestore()
    
    static var firestoreService: FireStoreServices {
        
        return FireStoreServices()
        
    }
    
    static func getPostRecipes(id: String) -> Observable<[Recipe]> {
        
        let query = db.collection("recipes").whereField("publisherID", isEqualTo: id)
        
        
        return firestoreService.getDocuments(query: query)
            .flatMapLatest {
                Recipe.generateNewRecipes(queryDocs: $0)
            }
        
    }
    
    static func getUserInfo(userId: String) -> Observable<(followings:Int, followeds:Int)> {
        
        let path = db.collection("users").document(userId)
        
        return firestoreService.getDocument(path: path)
            .map {

                if let data = $0.data() {
                    
                    let followingIds = data["followingsIDs"] as? [String:Bool]
                    let followedIds = data["followedsIDs"] as? [String:Bool]
                    
                    let followingIdsCount: Int = followingIds?.count ?? 0
                    let followedIdsCount: Int = followedIds?.count ?? 0
                
                    return (followingIdsCount, followedIdsCount)
                
                }
                
                return (0, 0)
                
            }
        
    }
    
    
    static func isFollowing(publisherId: String, user: Firebase.User) -> Observable<Bool> {
        
        let path = db.collection("users").document(user.uid)
       
        return firestoreService.getDocument(path: path)
            .map { data in
                if let ids = data["followingsIDs"] as? [String: Bool], let isFollowingPublisher = ids[publisherId] {
                    return isFollowingPublisher
                }
                return false
            }
        
    }
    
    static func followPublisher(user: Firebase.User, publisher: User) -> Observable<Void> {
       
        return .zip(addNewFollower(user: user, publisher: publisher).map { _ in }, addNewFollowing(user: user, publisher: publisher), addNewFollowingUnderUser(user: user, publisher: publisher)) { _, _, _ in
            
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
        
        return firestoreService.setData(path: path, data: data).map { _ in }
 
    }
    
    static func addNewFollowing(user: Firebase.User, publisher: User) -> Observable<Void>  {
        
        let data:[String: Any] = [
            
            "id": publisher.userID,
            "followingDate": Date(),
            "isFollowing": true
        ]
        
        let path = db.collection("users").document(user.uid).collection("followings").document(publisher.userID)
               
        
        return firestoreService.setData(path: path, data: data).map { _ in }
 
    }
    
    static func addNewFollowingUnderUser(user: Firebase.User, publisher: User) -> Observable<Void>  {

        let path = db.collection("users").document(user.uid)
               
        
        return firestoreService.getDocument(path: path)
            .map { data -> [String: Any] in
                
                if let idsDic = data["followingsIDs"] as? [String: Bool] {
                    
                    var ids = idsDic
                    
                    ids[publisher.userID] = true
                    
                    let newData = ["followingsIDs": ids]
                    
                    return newData
                    
                }
                
                return ["followingsIDs": [publisher.userID: true]]
            }
            .flatMapLatest {
                self.firestoreService.updateData(path: path, data: $0)
            }
            .map { _ in }
 
    }
    
    
 

    
    static func unFollowPublisher(user: Firebase.User, publisher: User) -> Observable<Void> {
        
        let removeFollowingIDs = removeFollowingIDs(user: user, publisher: publisher)

        let updateStatus = updateFollowerFollowingStatus(user: user, publisher: publisher)
        
        return .zip(removeFollowingIDs, updateStatus) { _, _ in
            return
        }
        
    }
    
    fileprivate static func removeFollowingIDs(user: Firebase.User, publisher: User) -> Observable<Void> {
        
        let path = db.collection("users").document(user.uid)
        
        return firestoreService.getDocument(path: path)
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
                firestoreService.updateData(path: path, data: $0).map { _ in }
            }
    }
    
    
    fileprivate static func updateFollowerFollowingStatus(user: Firebase.User, publisher: User) -> Observable<Void> {
       
        let myFollowingsPath = db.collection("users").document(user.uid).collection("followings").document(publisher.userID)
        let publisherFollowerPath = db.collection("users").document(publisher.userID).collection("followers").document(user.uid)
        let updateFollowingStatusData = ["isFollowing": false]
        let updateFollowertatusData = ["isFollowed": false]
        
        return firestoreService.updateData(path: myFollowingsPath, data: updateFollowingStatusData)
            .flatMapLatest { _ in
                firestoreService.updateData(path: publisherFollowerPath, data: updateFollowertatusData)
            }
            .map { _ in }
    
    }
    
}
