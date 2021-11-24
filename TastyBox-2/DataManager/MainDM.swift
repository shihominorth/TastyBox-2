//
//  MainDM.swift
//  TastyBox-2
//
//  Created by 北島　志帆美 on 2021-11-19.
//

import Foundation
import Firebase
import RxSwift
import UIKit

protocol MainDMProtocol {
    static func getPastTimelines(user: Firebase.User, date: Date, limit: Int) -> Observable<[Recipe]>
    static func getFutureTimelines(user: Firebase.User, date: Date, limit: Int) -> Observable<[Recipe]> 
    static func getRecipesRanking() -> Observable<[Recipe]>
    static func getRefrigeratorIngredients(user: Firebase.User) -> Observable<[Ingredient]>
    static func getRecipesUsedIngredient(ingredient: Ingredient) -> Observable<[Recipe]>
    static func getRecipesUsedIngredients(allIngredients: [Ingredient]) -> Observable<[Recipe]>
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
    
    static func getRefrigeratorIngredients(user: Firebase.User) -> Observable<[Ingredient]> {
        
        return getRefrigeratorIngredientDocuments(user: user)
            .flatMapLatest {
                Ingredient.generateNewIngredients(queryDocs: $0)
            }
        
        
    }
    
    static func getRefrigeratorIngredientDocuments(user: Firebase.User) -> Observable<[QueryDocumentSnapshot]> {
        
        let query = db.collection("users").document(user.uid).collection("refrigerator")
        
        return getDocuments(query: query)

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
        
        let query = db.collection("recipes").whereField("genres.\(ingredient.id)", isEqualTo: true)
        
        return getRecipes(query: query)

    }
      
    static func getRecipesUsedIngredients(allIngredients: [Ingredient]) -> Observable<[Recipe]> {
        
        var query: Query = db.collection("recipes")
        
        var limitLoop = 1
        var max = 0
        // ingredients.countが４以下だとmaxが１またはそれ以下になるためクラッシュしてしまう。
        if allIngredients.isEmpty {
            
            return .just([])
            
        }
        else if allIngredients.count == 1 {
            
            let query = db.collection("recipes").whereField("genres.\(allIngredients[0].id)", isEqualTo: true)
            
            return getRecipes(query: query)
            
        }
        else if allIngredients.count < 5 {
            
            // if count is 3
            
            var queries: [Query] = []

            //　全てのingredientsを含んだrecipeを呼ぶクエリ
            var allIngeredientContainsQuery = db.collection("recipes").whereField("genres.\(allIngredients[0].id)", isEqualTo: true)

            if allIngredients.count > 1 {

                for index in 1 ..< allIngredients.count {

                    allIngeredientContainsQuery = allIngeredientContainsQuery.whereField("genres.\(allIngredients[index].id)", isEqualTo: true)

                }

            }


            queries.append(allIngeredientContainsQuery)
            
            // 2個 Ingredientが含まれてるrecipeを探す
            let multipleIngredientsContainsQuery = self.getRecipesByAllWays(allIngredients: allIngredients)
            queries.append(contentsOf: multipleIngredientsContainsQuery)
            
            
            // 一つ一つ調べる
            for ingredient in allIngredients {

                let query = db.collection("recipes").whereField("genres.\(ingredient.id)", isEqualTo: true)

                queries.append(query)

            }

            var getRecipesStream = getRecipes(query: queries[0])
            
            queries.enumerated().forEach { index, query in
                
                if index != 1 {
                    
                    getRecipesStream = getRecipesStream
                        .flatMap({ recipes in
                            
                            return getRecipes(query: query)
                                .map { newRecipes in
                                    
                                    var result = recipes
                                    result.append(contentsOf: newRecipes)
                                    
                                    return result
                                    
                                }
                            
                        })
                    
                }
                
            }
            
            return getRecipesStream
            
//            max = 1
        }
//        else if allIngredients.count >= 5 {
           
//            max = Int.random(in: 1 ... allIngredients.count)
         
            let queries = getQueries(searchIngredientsOnceNumLimit: 3, ingredients: allIngredients)
            
            var getRecipesStream = getRecipes(query: queries[0])
            
            queries.enumerated().forEach { index, query in
                
                if index != 1 {
                    
                    getRecipesStream = getRecipesStream
                        .flatMap({ recipes in
                            
                            return getRecipes(query: query)
                                .map { newRecipes in
                                    
                                    var result = recipes
                                    result.append(contentsOf: newRecipes)
                                    
                                    return result
                                    
                                }
                            
                        })
                    
                }
                
            }
            
            return getRecipesStream
        
//        }
//        else  {
//
//            let thirtyPercentOfIngredientsCount = Int(round(Double(allIngredients.count) * 0.3))
//
//            max = thirtyPercentOfIngredientsCount
//
//        }
//
//        if max == 1 {
//
//            limitLoop = 1
//
//        }
//        else {
//
//            let ramdomLimit = Int.random(in: 1 ... max)
//            limitLoop = ramdomLimit
//        }
//
//        var selectedIndice:[Int] = []
//
//        var randomIndex = Int.random(in: 0 ..< allIngredients.count)
//
//
//        while !selectedIndice.contains(randomIndex) {
//
//            if selectedIndice.contains(randomIndex) {
//
//                randomIndex = Int(arc4random_uniform(UInt32(allIngredients.count - 1)))
//
//            }
//            else {
//
//                selectedIndice.append(randomIndex)
//
//            }
//
//        }
//
//
//        for _ in 0 ..< limitLoop {
//
//            let id = allIngredients[randomIndex].id
//
//            query = query.whereField("genres.\(id)", isEqualTo: true)
//        }
//
//        return getRecipes(query: query)
           
    }
    
    // ways:　通り
    // 2 ingredients
    static func getRecipesByAllWays(allIngredients: [Ingredient]) -> [Query] {
        
        var source:[[Int]] = []
        var queries:[Query] = []

        for index in 0 ..< allIngredients.count - 1 {

            for pairingIndex in (index + 1) ..< allIngredients.count - 1 {

                let arr = [index, pairingIndex]

                if !source.contains(arr) {

                    source.append(arr)

                }

            }

        }
        
        source.forEach { pair in
            
            var query = db.collection("recipes").whereField("genres.\(allIngredients[pair[0]].id)", isEqualTo: true)
            print("db.collection(recipes).whereField(genres.\(allIngredients[pair[0]].id), isEqualTo: true)")
            
            query = query.whereField("genres.\(allIngredients[pair[1]].id)", isEqualTo: true)
            
            queries.append(query)
            
        }
        
       return queries
        
    }
    
    static func getQueries(numQuery: Int = 5, searchIngredientsOnceNumLimit: Int, ingredients: [Ingredient]) -> [Query] {
        
        var tempQueries:[Query] = []
        
        for _ in 0 ..< numQuery {
            
            let searchIngredientsOnceNum = Int.random(in: 0 ..< searchIngredientsOnceNumLimit)

            var randomIndice:[Int] = []
            

            let firstSearchIngredientsOnceNum = Int.random(in: 0 ..< searchIngredientsOnceNumLimit)
            randomIndice.append(firstSearchIngredientsOnceNum)
            
            var query = db.collection("recipes").whereField("genres.\(ingredients[firstSearchIngredientsOnceNum].id)", isEqualTo: true)
            
            for _ in 1 ..< searchIngredientsOnceNum {
                
                var randomIndex: Int {
                  
                    var result = Int.random(in: 0 ..< searchIngredientsOnceNumLimit)
                    
                    while randomIndice.contains(result) {
                        
                        result = Int.random(in: 0 ..< searchIngredientsOnceNumLimit)
                        
                        
                    }
                    
                    randomIndice.append(result)
                    
                    return result
                }
                
                query = query.whereField("genres.\(ingredients[randomIndex].id)", isEqualTo: true)
                
            }
            
            tempQueries.append(query)
        }
        
        let queries = Dictionary(grouping: tempQueries, by: { $0 }).keys
        
        return Array<Query>(queries)
        
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
        
        return getDocuments(query: query)
            .flatMapLatest { docs in
                Recipe.generateNewRecipes(queryDocs: docs)
            }
    }
    
    static func getDocuments(query: Query) -> Observable<[QueryDocumentSnapshot]> {
        
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
