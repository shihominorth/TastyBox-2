//
//  MainDM.swift
//  TastyBox-2
//
//  Created by 北島　志帆美 on 2021-11-19.
//

import Foundation
import Firebase
import RxSwift

protocol MainDMProtocol {
    static func getPastTimelines(user: Firebase.User, date: Date, limit: Int) -> Observable<[Recipe]>
    static func getFutureTimelines(user: Firebase.User, date: Date, limit: Int) -> Observable<[Recipe]> 
    static func getRecipesRanking() -> Observable<[Recipe]>
    static func getRecipesUsedIngredient(ingredient: Ingredient) -> Observable<[Recipe]>
    static func getRecipesUsedIngredientsInAll(ingredients: [Ingredient]) -> Observable<[Recipe]>
    static func getVIPRecipes(ingredient: Ingredient) -> Observable<[Recipe]>
    static func getPublishers(ids: [String]) -> Observable<[String: User]>
}

class MainDM: MainDMProtocol {
    
    static let db = Firestore.firestore()
    static let storage = Storage.storage().reference()
    
    //check if result has same recipes as recipes in viewModel
   // it is likely to get same recipes
    
    // why default num is 20 limits?
    // it is likely to get same recipes so need to get the rest for getting 20 recipes
    static func getPastTimelines(user: Firebase.User, date: Date, limit: Int = 20) -> Observable<[Recipe]> {
        
       let query = db.collection("users").document(user.uid).collection("timeline").order(by: "updateDate", descending: true).whereField("updateDate", isLessThanOrEqualTo: date).limit(to: limit)

        return getTimelineRecipeIds(query: query)
            .flatMapLatest { ids in
                getTimeLineRecipeDocuments(ids: ids)
            }
            .flatMapLatest { docs in
                Recipe.generateNewRecipes(queryDocs: docs)
            }
        
    }
    
    static func getFutureTimelines(user: Firebase.User, date: Date, limit: Int = 20) -> Observable<[Recipe]> {
        
       let query = db.collection("users").document(user.uid).collection("timeline").order(by: "updateDate", descending: true).whereField("updateDate", isGreaterThanOrEqualTo: date).limit(to: limit)

        return getTimelineRecipeIds(query: query)
            .flatMapLatest { ids in
                getTimeLineRecipeDocuments(ids: ids)
            }
            .flatMapLatest { docs in
                Recipe.generateNewRecipes(queryDocs: docs)
            }
        
    }
    
    static func getTimeLineRecipeDocuments(ids: [String]) -> Observable<[QueryDocumentSnapshot]> {
    
        return .create { observer in
            
            var implementedNum = 0
            var documents:[QueryDocumentSnapshot] = []
            
            ids.forEach { id in
                                
                getRecipeDocument(id: id, completion: { doc in
                   
                    implementedNum += 1
                    
                    if let doc = doc {
                        documents.append(doc)
                    }
                    
                    if implementedNum == ids.count {
                        observer.onNext(documents)
                    }
                    
                }, errBlock: { err in
                    
                    print(err)
                    
                    implementedNum += 1
 
                    if implementedNum == ids.count {
                        observer.onNext(documents)
                    }
                    
                })
                
            }
            
            return Disposables.create()
        }
        
    }
    
    static func getTimelineRecipeIds(query: Query) -> Observable<[String]> {
        
        return .create { observer in
            
          query.getDocuments { snapShot, err in
                
                if let err = err {
                    
                    observer.onError(err)
                
                }
                else {
                    
                    if let queryDocs = snapShot?.documents {
                    
                        let ids: [String] = queryDocs.compactMap {
                            
                            let data = $0.data()
                           
                            guard let id = data["id"] as? String else {
                                return nil
                            }
                            
                           return id
                            
                        }
                        
                        let notDuplecatedIds = Array(Set(ids))
                        
                        
                        observer.onNext(notDuplecatedIds)
                   
                    }
                    else {
                        
                        observer.onNext([])
                        
                    }
                    
                }
                
            }
            
            return Disposables.create()
        }
    }
    
    
    static func getVIPRecipes(ingredient: Ingredient) -> Observable<[Recipe]> {
        
        let query = db.collection("recipes").whereField("isVIP", isEqualTo: true).limit(to: 20)
        
        return getRecipes(query: query)

    }
    
    static func getRecipesRanking() -> Observable<[Recipe]> {
        
        let query = db.collection("recipes").order(by: "likes", descending: true).limit(to: 10)

        return getRecipes(query: query)
           
    }
    
    static func getRecipesUsedIngredient(ingredient: Ingredient) -> Observable<[Recipe]> {
        
        let query = db.collection("recipes").whereField("ingredients.\(ingredient.id)", isEqualTo: true)
        
        return getRecipes(query: query)

    }
    
    static func getRecipesUsedIngredientsInAll(ingredients: [Ingredient]) -> Observable<[Recipe]> {
        
        var query: Query = db.collection("recipes")
        
        let thirtyPercentOfIngredientsCount = Int(round(Double(ingredients.count) * 0.3))

        let ramdomLimit = Int.random(in: 1 ... thirtyPercentOfIngredientsCount)

        for _ in 0 ..< ramdomLimit {
            
            let randomIndex = Int(arc4random_uniform(UInt32(ingredients.count - 1)))
            let id = ingredients[randomIndex].id
            
            query = query.whereField("id", isEqualTo: id)
        }
        
        return getRecipes(query: query)
           
    }
    
    static func getPublishers(ids: [String]) -> Observable<[String: User]> {

        return getPublisherDocuments(ids: ids)
            .flatMapLatest { docs in
                User.generateNewUsers(documents: docs)
            }
            .map { users in
               
                var dic: [String: User] = [:]
                users.forEach { user in
                    dic[user.userID] = user
                }
                
                return dic
            }
    }
    
    
    static func getRecipes(query: Query) -> Observable<[Recipe]> {
        
        return getRecipeDocuments(query: query)
            .flatMapLatest { docs in
                Recipe.generateNewRecipes(queryDocs: docs)
            }
    }
    
    static func getRecipeDocuments(query: Query) -> Observable<[QueryDocumentSnapshot]> {
        
        return .create { observer in
            
            query.getDocuments { snapShot, err in
              
                if let err = err {
                
                    observer.onError(err)
                
                }
                else {
                    
                    if let docs = snapShot?.documents {
                        
                        observer.onNext(docs)
                    }
                    else {
                    
                        observer.onNext([])
                    
                    }
                    
                }
            
            }
            
            
            return Disposables.create()
        }
       
    }
    
    static func getRecipeDocument(id: String, completion: @escaping (QueryDocumentSnapshot?) -> Void, errBlock: @escaping (Error) -> Void){
        
            
        db.collection("recipes").document(id).getDocument { doc, err in
              
                if let err = err {
                
                    errBlock(err)
                
                }
                else {
                    
                    let doc = doc as? QueryDocumentSnapshot
                    completion(doc)
                    
                }
            
            }
            
       
    }
    
    
    static func getPublisherDocuments(ids: [String]) -> Observable<[DocumentSnapshot]> {
        
        return .create { observer in
            
            
            let notDuplecateIds = Array(Set(ids))
            
            var docs:[DocumentSnapshot] = []
            var implementedNum = 0
            
            notDuplecateIds.enumerated().forEach { index, id in
                
               
               generateNewPubishers(publisherID: id, completion: { doc in
                
                   implementedNum += 1
                  
                      
                   docs.append(doc)

                    if implementedNum == notDuplecateIds.count {
                        
                        observer.onNext(docs)
                    }
                    
                }, errBlock: { err in
                    
                    implementedNum += 1
                    
                    print(err)
                    
                    if implementedNum == notDuplecateIds.count {
                        
                        observer.onNext(docs)
                    }
                    
                })
                
            }
            
            
            return Disposables.create()
        }
        
    }
    
    //なぜかQueryDocumentSnapshotにキャストできない
    // 上ではできるのに
    static func generateNewPubishers(publisherID: String, completion: @escaping (DocumentSnapshot) -> Void, errBlock: @escaping (Error) -> Void) {
        
        db.collection("users").document(publisherID).getDocument { doc, err in
            
            if let err = err {
                
                errBlock(err)
                
            }
            else {
                
                if let doc = doc {
                    
                    completion(doc)
                    
                }
                
                
            }
        }
        
    }
    
}
