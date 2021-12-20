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
    
}
