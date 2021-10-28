//
//  CreateRecipeDM.swift
//  TastyBox-2
//
//  Created by 北島　志帆美 on 2021-10-20.
//

import Foundation
import AVFoundation
import Firebase
import RxSwift

protocol CreateRecipeDMProtocol: AnyObject {
    
    static func getThumbnailData(url: URL) -> Observable<Data>
    static func getMyGenresIDs(user: Firebase.User) -> Observable<[String]>
    static func getMyGenres(ids: [String], user: Firebase.User) -> Observable<([Genre], Bool)>
    static func createGenres(genres: [Genre], user: Firebase.User) -> Observable<([Genre], Bool)>
    static func getUserImage(user: Firebase.User) -> Observable<Data>
    static func getUser(user: Firebase.User) -> Observable<User>
    static func createUploadingRecipeData(isVIP: Bool, sections: [RecipeItemSectionModel], user: Firebase.User) -> Observable<[String: Any]>
    static func createInstructionsData(section: RecipeItemSectionModel, user: Firebase.User, recipeID: String) -> Observable<[[String: Any]]>
    static func createIngredientsData(section: RecipeItemSectionModel, user: Firebase.User, recipeID: String) -> Observable<[[String: Any]]> 
    static func createGenresData(sections: [RecipeItemSectionModel]) -> Observable<[[String: Any]]>
    static func updateRecipe(recipeData: [String: Any], ingredientsData: [[String: Any]],  instructionsData: [[String: Any]], user: Firebase.User) -> Observable<[String: Any]>
    static func updateUserInterestedGenres(genresData: [[String: Any]], user: Firebase.User) -> Observable<Void> 

}

class CreateRecipeDM: CreateRecipeDMProtocol {
    
    static let db = Firestore.firestore()
    static let storage = Storage.storage().reference()
    
    static func getThumbnailData(url: URL) -> Observable<Data> {
        
        return Observable.create { observer in
            
            let asset: AVAsset = AVAsset(url: url)
            let imageGenerator = AVAssetImageGenerator(asset: asset)
            
            do {
                let thumbnailImage = try imageGenerator.copyCGImage(at: CMTimeMake(value: 1, timescale: 60) , actualTime: nil)
                
                if let data = thumbnailImage.data {
                    observer.onNext(data)
                }
                
            } catch (let err) {
                observer.onError(err)
            }
            
            return Disposables.create()
            
        }
    }
    
    static func getMyGenresIDs(user: Firebase.User) -> Observable<[String]> {
        
        return Observable.create { observer in
            
            db.collection("users").document(user.uid).collection("genres")
                .addSnapshotListener { snapShot, err in
                    
                    if let err = err {
                        
                        observer.onError(err)
                        
                    }
                    else {
                        
                        if let docs = snapShot?.documents {
                            
                            let ids = docs.map { $0.documentID }
                            observer.onNext(ids)
                        }
                    }
                }
            
            return Disposables.create()
        }
    }
    
    
    static func getMyGenres(ids: [String], user: Firebase.User) -> Observable<([Genre], Bool)> {
        
        return .create { observer in
            
            var inplementCount = ids.count
            var genres:[Genre] = []
            
            ids.enumerated().forEach { index, id in
                
                db.collection("genres").whereField("id", isEqualTo: id).getDocuments { snapShot, err in
                    
                    inplementCount -= 1
                    
                    if let err = err {
                        
                        if inplementCount == 0 {
                            
                            print(err)
                            observer.onNext((genres, true))
                            
                        }
                        else {
                            
                            observer.onError(err)
                        }
                        
                    }
                    else {
                        
                        if let doc = snapShot?.documents.first {
                            
                            if let genre = Genre(document: doc) {
                                
                                genres.append(genre)
                                
                            }
                            
                            if inplementCount == 0 {
                                
                                observer.onNext((genres, true))
                                
                            }
                            else {
                                
                                observer.onNext((genres, false))
                            }
                            
                        }
                        
                    }
                    
                }
                
            }
            
            return Disposables.create()
            
        }
    }
    
    
    static func createGenres(genres: [Genre], user: Firebase.User) -> Observable<([Genre], Bool)> {
        
        return .create { observer in
            
            genres.enumerated().forEach { index, genre in
                
                let data: [String : Any] = [
                    
                    "id": genre.id,
                    "title": genre.title,
                    "count": FieldValue.increment(Int64(1))
                ]
                
                
                db.collection("genres").document(genre.id).setData(data) { err in
                    
                    if let err = err {
                        
                        
                        if index == genres.count - 1 {
                            
                            print(err)
                            
                            observer.onNext((genres, true))
                            
                        }
                        else {
                            
                            observer.onError(err)
                        }
                        
                    }
                    else {
                        
                        db.collection("users").document(user.uid).collection("genres").document(genre.id).setData([
                            
                            "id": genre.id,
                            "usedLatestDate": Date(),
                            "count": FieldValue.increment(Int64(1))
                            
                        ]) { err in
                            
                            if let err = err {
                                
                                
                                if index == genres.count - 1 {
                                    
                                    print(err)
                                    
                                    observer.onNext((genres, true))
                                    
                                }
                                else {
                                    
                                    observer.onError(err)
                                }
                                
                            }
                            else {
                                
                                if index == genres.count - 1 {
                                    
                                    observer.onNext((genres, true))
                                    
                                }
                                else {
                                    
                                    observer.onNext((genres, false))
                                }
                            }
                        }
                        
                    }
                }
            }
            
            return Disposables.create()
            
        }
    }
    
    
    static func getUserImage(user: Firebase.User) -> Observable<Data> {
        
        
        return .create { observer in
            
            self.storage.child("users/\(user.uid)/userImage.jpg").getData(maxSize: 1 * 1024 * 1024) { data, err in
                
                if let err = err {
                    
                    observer.onError(err)
                    
                }
                else {
                    
                    if let data = data {
                        
                        observer.onNext(data)
                        
                    }
                }
                
            }
            
            return Disposables.create()
            
        }
    }
    
    static func getUser(user: Firebase.User) -> Observable<User> {
        
        return .create {  observer in
            
            db.collection("users").document(user.uid).getDocument { doc, err in
                
                if let err = err {
                    
                    observer.onError(err)
                    
                }
                else {
                    
                    self.storage.child("users/\(user.uid)/userImage.jpg").getData(maxSize: 1 * 1024 * 1024) { data, err in
                        
                        if let err = err {
                            
                            observer.onError(err)
                            
                        }
                        else {
                            
                            if let data = data {
                                
                                if let doc = doc, let user = User(document: doc, imgData: data) {
                                    
                                    observer.onNext(user)
                                    
                                }
                            }
                        }
                        
                    }
                }
                
            }
            
            return Disposables.create()
        }
    }
    
    
    static func createUploadingRecipeData(isVIP: Bool, sections: [RecipeItemSectionModel], user: Firebase.User) -> Observable<[String: Any]> {
        
        return .create {  observer in
            
            var data:[String: Any] = [:]
            var tempItems:[RecipeDetailSectionItem] = []
            var genresDic:[String: Bool] = [:]
            var ingredientsDic:[String: Bool] = [:]
            
            let uuid = UUID()
            let uniqueIdString = uuid.uuidString.replacingOccurrences(of: "-", with: "")
            
            
            data["id"] = uniqueIdString
            data["publisherID"] = user.uid
            data["isVIP"] = isVIP
            
            
            let newSections: [RecipeItemSectionModel] = sections.compactMap {
                
                switch $0 {
                case .title, .timeAndServing, .instructions:
                    return $0
                    
                case let .genres(genres):
                    
                    tempItems.append(genres)
                    
                case let .ingredients(ingredients):
                    
                    tempItems.append(contentsOf: ingredients)
                    
                    
                default:
                    break
                }
                
                return nil
            }
            
            
            newSections.forEach {
                
                switch $0 {
                    
                case .title(let title):
                
                    data["title"] = title
                    
                    
                case .timeAndServing(let time, let serving):
                    
                    data["time"] = time
                    data["serving"] = serving
                    
                default:
                    break
                }
                
            }
            
            tempItems.forEach {
                
                switch $0 {
                case let .genres(genres):
                    
                    genres.forEach {
                        genresDic[$0.title.capitalized] = true
                    }
                    
//                    data["genres"] = genresDic
                    
                case let .ingredients(ingredient):
                    
                    
                    ingredientsDic[ingredient.name] = true
                    genresDic[ingredient.name] = true
                    
                default:
                    break
                }
            }
            
            data["genres"] = genresDic
            data["ingredients"] = ingredientsDic
            
            observer.onNext(data)
            
            return  Disposables.create()
            
        }
    }
    
    static func createGenresData(sections: [RecipeItemSectionModel]) -> Observable<[[String: Any]]>  {
        
        return .create { observer in
            
            var items: [RecipeDetailSectionItem] = []
            var result: [[String: Any]] = []
            
            sections.forEach { section in
                
                switch section {
                case let .genres(genres):
                    
                    items.append(genres)
                    
                case let .ingredients(ingredients):
                    
                    items.append(contentsOf: ingredients)
                    
                default:
                    break
                }
                
            }
            
            
            items.forEach { item in
                
                switch item {
                case let .genres(genres):
                    
                    genres.forEach { genre in
                        
                        var data:[String: Any] = [:]
                        
                        data["id"] = genre.id
                        data["name"] = genre.title
                        
                        
                        result.append(data)
                    }
                    
                case let .ingredients(ingredient):
                    
                    var data:[String: Any] = [:]
                    
                    let uuid = UUID()
                    let uniqueIdString = uuid.uuidString.replacingOccurrences(of: "-", with: "")
                    
                    data["id"] = uniqueIdString
                    data["name"] = ingredient.name
                    
                    result.append(data)
                    
                    
                default:
                    break
                }
                
                
            }
            
            observer.onNext(result)
            
            return  Disposables.create()
        }
    }
    
    static func createInstructionsData(section: RecipeItemSectionModel, user: Firebase.User, recipeID: String) -> Observable<[[String: Any]]>  {
        
        return .create { observer in
            
            var tempItems:[RecipeDetailSectionItem] = []
            var result: [[String: Any]] = []
            
            switch section {
            case let .instructions(instructions):
                
                tempItems.append(contentsOf: instructions)
                
                
            default:
                break
            }
            
            tempItems.forEach { item in
                
                var data:[String: Any] = [:]
                
                switch item {
                case let .instructions(instruction):
                    
                    let uuid = UUID()
                    let uniqueIdString = uuid.uuidString.replacingOccurrences(of: "-", with: "")
                    
                    data["id"] = uniqueIdString
                    data["index"] = instruction.index
                    data["text"] = instruction.text
                    data["imageURL"] = "users/\(user.uid)/recipes/\(recipeID)/\(uniqueIdString)/instructionImage.jpg"
                    
                    result.append(data)
                    
                default:
                    break
                }
            }
            
            observer.onNext(result)
            
            return  Disposables.create()
        }
    }
    
   
    static func createIngredientsData(section: RecipeItemSectionModel, user: Firebase.User, recipeID: String) -> Observable<[[String: Any]]> {
        
        return .create { observer in
            
            var tempItems:[RecipeDetailSectionItem] = []
            var result: [[String: Any]] = []
            
            switch section {
            case let .ingredients(ingredients):
                
                tempItems.append(contentsOf: ingredients)
                
                
            default:
                break
            }
            
            tempItems.enumerated().forEach { index, item in
                
                var data:[String: Any] = [:]
                
                switch item {
                case let .ingredients(ingredient):
                    
                    data["id"] = ingredient.id
                    data["name"] = ingredient.name
                    data["amount"] = ingredient.amount
                    data["index"] = index
                    
                    result.append(data)
                    
                default:
                    break
                }
            }
            
            observer.onNext(result)
            
            return Disposables.create()
        }
    }
    
    static func updateRecipe(recipeData: [String: Any], ingredientsData: [[String: Any]],  instructionsData: [[String: Any]], user: Firebase.User) -> Observable<[String: Any]>  {
        
        return .create { observer in
            
            guard let recipeId = recipeData["id"] as? String else { return Disposables.create() }
            
            
            db.collection("recipes").document(recipeId).setData(recipeData, merge: true) { err in
                
                if let err = err {
                    
                    observer.onError(err)
                }
                else {
                    
                    ingredientsData.forEach {
                        
                        guard let ingredientID = $0["id"] as? String else { return }
                        
                        db.collection("recipes").document(recipeId).collection("ingredients").document(ingredientID).setData($0, merge: true) { err in
                            
                            if let err = err {
                                
                                observer.onError(err)
                            }
                            else {
                                
                                instructionsData.forEach {
                                    
                                    guard let instructionID = $0["id"] as? String else { return }
                                    
                                    db.collection("recipes").document(recipeId).collection("instructions").document(instructionID).setData($0, merge: true) { err in
                                        
                                        if let err = err {
                                            
                                            observer.onError(err)
                                        }
                                        else {
                                            
                                            observer.onNext(recipeData)
                                        }
                                    }
                                }
                            }
                        }
                    }
    
                }
            }
            
            return  Disposables.create()
            
        }
    }
    
    static func updateUserInterestedGenres(genresData: [[String: Any]], user: Firebase.User) -> Observable<Void> {
        
        return .create { observer in
            
            var ids:[String: Bool] = [:]
            var idsData: [String: Any] = [:]
            
            genresData.forEach { data in
                
                guard let genreID = data["id"] as? String else { return }
                
                db.collection("genres").document(genreID).setData(data, merge: true) { err in
                    
                    if let err = err {
                        
                        observer.onError(err)
                    }
                    
                }
                
                ids[genreID] = true
            }
            
            idsData["genres"] = ids
                
            
            db.collection("users").document(user.uid).updateData(idsData) { err in
                
                if let err = err {
                    
                    observer.onError(err)
                }
                else {
                    
                    observer.onNext(())
                    
                }
            }
            
            
            return  Disposables.create()
        }
        
    }
    //
    //    func labelingImage(data: Data) {
    //
    //        let options = VisionObjectDetectorOptions()
    //
    //        let visionImage = VisionImage(data: data)
    //        visionImage.orientation = image.imageOrientation
    //        let labeler = ImageLabeler.imageLabeler(options: options)
    //
    //            labeler.process(image) { labels, error in
    //
    //                guard error == nil else {
    //                    print(error!)
    //                    return
    //
    //                }
    //                guard let labels = labels else { return }
    //
    //                // Task succeeded.
    //                // ...
    //                for (index, label) in labels.enumerated() {
    //                    let labelText = label.text
    //
    //                    if labelText == "Cuisine" || labelText == "Food" || labelText == "Recipe" || labelText == "Cooking" || labelText == "Dish" || labelText == "Ingredient" {
    //
    //
    //                    } else {
    //                        self.labels.append(labelText)
    //                    }
    //
    //                    if index == labels.count - 1 {
    //                        print(self.labels)
    //                        self.delegate?.passLabeledArray(arr: self.labels)
    //                    }
    //                }
    //            }
    //        }
}
