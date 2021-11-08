//
//  Recipe.swift
//  TastyBox-2
//
//  Created by 北島　志帆美 on 2021-09-16.
//

import UIKit
import Firebase
import FirebaseFirestore
import MessageUI
import RxSwift
import RxDataSources
import DifferenceKit

class Recipe {
    
    let recipeID: String
//    let imgURL: URL
//    var imageData: Data
    //    let video: URL?
    var title: String
    let updateDate: Timestamp
    var cookingTime: Int
    //    var image: String?
    var likes: Int
    var serving: Int
    let userID:String
    var genresIDs: [String] = []
    var isVIP: Bool
    
    init?(queryDoc:  QueryDocumentSnapshot, user: Firebase.User) {
        
        let data = queryDoc.data()
        
        guard let id = data["id"] as? String,
              let title = data["title"] as? String,
              let updateDate = data["updateDate"] as? Timestamp,
              let time = data["time"] as? Int,
              let serving = data["serving"] as? Int,
              let isVIP = data["isVIP"] as? Bool,
              let publisherID = data["publisherID"] as? String,
              let genresData = data["genres"] as? [String: Bool]
        else { return nil }
        
        
        self.recipeID = id
        self.title = title
        self.updateDate = updateDate
        self.cookingTime = time
        self.likes = data["likes"] as? Int ?? 0
        self.userID = publisherID
        self.serving = serving
        self.isVIP = isVIP
        self.genresIDs = [String](genresData.keys)
        
//        self.imgURL = Storage.storage().reference().child("users/\(user.uid)/\(self.recipeID)/mainPhoto.jpg")
        
    }
    
    static func generateNewRecipes(queryDocs: [QueryDocumentSnapshot], user: Firebase.User) -> Observable<[Recipe]> {
        
        return .create { observer in
            
            var implementNum = 0
            var recipes: [Recipe] = []
            let disposeBag = DisposeBag()
            
            queryDocs.enumerated().forEach { index, doc in
                
                implementNum += 1
                
                generateNewRecipe(queryDoc: doc, user: user)
                    .catch { err in
                        
                        print(err)
                        
                        if implementNum == queryDocs.count {
                            observer.onNext(recipes)
                        }
                        
                        return .empty()
                    }
                    .subscribe(onNext: { recipe in
                        
                        if let recipe = recipe {
                            recipes.append(recipe)
                        }
                        
                        if implementNum == queryDocs.count {
                            observer.onNext(recipes)
                        }
                        
                    })
                    .disposed(by: disposeBag)
                                
            }
            
            return Disposables.create()
        }
    }
    
    //    static func generateNewRecipe(queryDoc: QueryDocumentSnapshot, user: Firebase.User) -> Observable<Recipe?> {
    //
    //
    //        let documentID = queryDoc.documentID
    //
    //        let getImageObservable = getMyImage(recipeID: documentID, user: user)
    //
    //        return .create { observer in
    //
    //            getImageObservable
    //                .retry { errors in
    //
    //                    return errors.enumerated().flatMap { retryIndex, error -> Observable<Int64> in
    //
    //                        print("got error")
    //                        print(error)
    //
    //                        let e = error as NSError
    //
    //                        if 400..<500 ~= e.code && retryIndex < 3 {
    //
    //                            return .timer(.milliseconds(3000), scheduler: MainScheduler.instance)
    //
    //                        }
    //
    //                        return Observable.error(error)
    //
    //                    }
    //                }
    //                .subscribe(onNext: { data in
    //
    //                    if let recipe = Recipe(queryDoc: queryDoc, imageData: data) {
    //
    //                        observer.onNext(recipe)
    //
    //                    }
    //                    else {
    //
    //                        observer.onNext(nil)
    //
    //                    }
    //
    //                }, onError: { err in
    //
    //                    observer.onError(err)
    //
    //                })
    //                .disposed(by: DisposeBag())
    //
    //            return Disposables.create()
    //        }
    //
    //    }
    
    static func generateNewRecipe(queryDoc: QueryDocumentSnapshot, user: Firebase.User) -> Observable<Recipe?> {
        
        return getMyPostedRecipeImage(recipeID: queryDoc.documentID, user: user)
            .do(onNext: { data in
                
//                guard let recipe = Recipe(queryDoc: queryDoc, imageData: data) else {
//                    return
//                }
                
//                print(recipe)
                
                print(data)
                
            })
            .map { data -> Recipe? in

                guard let recipe = Recipe(queryDoc: queryDoc, imageData: data) else {
                    return nil
                }

                return recipe

            }
//            .retry { errors in
//
//                return errors.enumerated().flatMap { retryIndex, error -> Observable<Int64> in
//
//                    print("got error")
//                    print(error)
//
//                    let e = error as NSError
//
//                    if 400..<500 ~= e.code && retryIndex < 3 {
//
//                        return .timer(.milliseconds(3000), scheduler: MainScheduler.instance)
//
//                    }
//
//                    return Observable.error(error)
//
//                }
//            }
//            .flatMap { data -> Observable<Recipe?> in
//
//                let newRecipe = Observable<Recipe?>.create { observer in
//
//                    if let recipe = Recipe(queryDoc: queryDoc, imageData: data) {
//
//                        observer.onNext(recipe)
//
//                    }
//                    else {
//
//                        observer.onNext(nil)
//
//                    }
//
//                    return Disposables.create()
//                }
//
//                return newRecipe
//            }
      
                
    }
    
    static func getMyPostedRecipeImage(recipeID: String, user: Firebase.User) -> Observable<Data> {
        
        return .create { observer in
            
            let storage = Storage.storage().reference()
            
            storage.child("users/\(user.uid)/\(recipeID)/mainPhoto.jpg").getData(maxSize: 1 * 1024 * 1024) { data, err in
                
                if let err = err {
                    
                    observer.onError(err)
                    
                } else {
                    
                    if let data = data {
                        
                        observer.onNext(data)
                    }
                    
                }
                
            }
            
            return Disposables.create()
        }
        
        
    }
    
    
    //    init?(documentSnapshot:  DocumentSnapshot) {
    //
    //        guard let data = documentSnapshot.data() else { return nil }
    //
    //        guard let id = data["id"] as? String, let title = data["title"] as? String else { return nil }
    //
    //        self.id = id
    //        self.title = title
    //
    //    }
    
    
}

extension Recipe: Differentiable {
    
    var differenceIdentifier: String {
        return self.recipeID
    }
    
    func isContentEqual(to source: Recipe) -> Bool {
        
        return self.recipeID == source.recipeID
        
    }
}

struct Instruction {
    
    
    var id: String
    var index: Int
    var imageData: Data
    var text: String
}

struct Comment {
    var userId: String
    var text: String
    var time: Timestamp
}

struct Evaluate {
    
    var title: String
    var imgName: String
    
}


enum RecipeDetailSectionItem {
    case imageData(Data, URL?), title(String), evaluate([Evaluate]), timeAndServing(Int, Int), user(User), genres([Genre]), ingredients(Ingredient), instructions(Instruction) //likes(Int), serving(Int), videoURL(URL),
}

enum RecipeItemSectionModel {
    
    case mainImageData(imgData: Data, videoURL: URL?)
    case title(title: String)
    case evaluate(evaluates: RecipeDetailSectionItem)
    case timeAndServing(time: Int, serving: Int)
    case user(user: User)
    case genres(genre: RecipeDetailSectionItem)
    case ingredients(ingredient: [RecipeDetailSectionItem])
    case instructions(instruction: [RecipeDetailSectionItem])
    
}


extension RecipeItemSectionModel: SectionModelType {
    
    typealias Item = RecipeDetailSectionItem
    
    var items: [RecipeDetailSectionItem] {
        
        switch self {
            
        case .mainImageData(let imgData, let videoURL):
            return [RecipeDetailSectionItem.imageData(imgData, videoURL)]
            
        case .title(let title):
            
            return [RecipeDetailSectionItem.title(title)]
            
        case .evaluate(let evaluates):
            
            return [evaluates]
            
            
        case .timeAndServing(let time, let serving):
            
            return [RecipeDetailSectionItem.timeAndServing(time, serving)]
            
        case .user(let user):
            
            return [RecipeDetailSectionItem.user(user)]
            
        case .genres(let genres):
            
            return [genres]
            
        case .ingredients(let ingredients):
            
            return ingredients.map { $0 }
            
        case .instructions(let instructions):
            
            return instructions.map { $0 }
        }
    }
    
    var title: String {
        
        switch self {
        case .ingredients:
            return "Ingredients"
        case .instructions:
            return "Instructions"
        default:
            return ""
        }
    }
    
    init(original: RecipeItemSectionModel, items: [RecipeDetailSectionItem]) {
        
        switch original {
            
        case let .mainImageData(imgData, videoURL):
            
            self = .mainImageData(imgData: imgData, videoURL: videoURL)
            
        case let .title(title):
            
            self = .title(title: title)
            
        case let .evaluate(evaluates):
            
            self = .evaluate(evaluates: evaluates)
            
        case let .timeAndServing(time, serving):
            
            self = .timeAndServing(time: time, serving: serving)
            
        case let .user(user):
            
            self = .user(user: user)
            
        case let .genres(genres):
            
            self = .genres(genre: genres)
            
        case .ingredients(_):
            
            self = .ingredients(ingredient: items)
            
        case .instructions(_):
            
            self = .instructions(instruction: items)
        }
        //        switch original {
        
        //        case .mainImageData:
        //            self = .mainImageData(content: items)
        //
        //        case .videoURL:
        //            self = .videoURL(content: items)
        
        //        case .title:
        //            self = .title(content: items)
        //
        //        case .timeAndServing(content: items):
        //
        //            self = .timeAndServing(content: items)
        //
        //        case .likes:
        //            self = .likes(content: items)
        //
        //        case .serving:
        //
        //            self = .likes(content: items)
        //        case .evaluate(content: items):
        //            self = .evaluate(content: items)
        //
        //        case .user:
        //
        //            self = .likes(content: items)
        
        //        case .evaluate:
        //
        //            self = .evaluate(content: items)
        //
        //        case .genresSection:
        //
        //            self = .genresSection(content: items)
        
        //        case .isVIP:
        //
        //            self = .isVIP(content: items)
        
        //        case .ingredientSection:
        //
        //            self = .ingredientSection(content: items)
        
        //        case .instructionSection:
        //
        //            self = .instructionSection(content: items)
        //        }
    }
    
}
