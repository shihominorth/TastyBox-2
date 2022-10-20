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
import UIKit
import Photos

protocol CreateRecipeDMProtocol: AnyObject {
    
    static var firestoreServices: FirestoreServices { get }
    static func getThumbnailData(url: URL) -> Observable<Data>
    static func getMyGenresIDs(user: Firebase.User) -> Observable<[String]>
    static func getMyGenres(ids: [String], user: Firebase.User) -> Observable<([Genre], Bool)>
    static func searchGenres(searchWord: String) -> Observable<[Genre]>
    static func filterNotSearchedGenres(genres: [Genre], txt: String) -> Observable<([Genre], [String])>
    static func isFirebaseKnowsGenres(word: String, completion: @escaping (Genre?) -> Void, errBlock: @escaping (Error) -> Void)
    static func registerNewGenres(genres: [String], user: Firebase.User) -> Observable<[Genre]>
    static func isUserInterested(genres: [Genre], user: Firebase.User) -> Observable<[Genre]>
    static func createGenres(genres: [Genre], user: Firebase.User) -> Observable<([Genre], Bool)>
    static func getUserImage(user: Firebase.User) -> Observable<Data>
    static func getUser(user: Firebase.User) -> Observable<User>

    static func convertToIngredientsData(ingredients: [Ingredient]) -> Observable<[[String: Any]]>

    static func convertToGenresData(genres: [Genre]) -> Observable<[[String: Any]]>
    static func convertToGenresData(ingredients: [Ingredient]) -> Observable<[[String: Any]]>
    
    //MARK: convert to basic info
    static func convertToUploadingRecipeData(title: String, time: Int, serving: Int, isVIP: Bool, user: Firebase.User) -> Observable<[String: Any]>
    static func convertToBasicInfoDic(genres: [Genre]) -> Observable<[String: Bool]>
    static func convertToBasicInfoDic(ingredients: [Ingredient]) -> Observable<[String: Bool]>
    
//    static func convertToGenresData(sections: [RecipeItemSectionModel]) -> Observable<[[String: Any]]>
    //    static func createUploadingRecipeData(isVIP: Bool, sections: [RecipeItemSectionModel], user: Firebase.User) -> Observable<[String: Any]>
//    static func convertToInstructionsData(section: RecipeItemSectionModel, user: Firebase.User) -> Observable<[[String: Any]]>
    static func convertToInstructionData(instructions: [Instruction]) -> Observable<[[String: Any]]> 
    //    static func createIngredientsData(section: RecipeItemSectionModel, user: Firebase.User, recipeID: String) -> Observable<[[String: Any]]>

    static func updateRecipe(recipeData: [String: Any], ingredientsData: [[String: Any]],  instructionsData: [[String: Any]], user: Firebase.User) -> Observable<[String: Any]>
    static func getIngredientIDs(ingredients: [Ingredient]) -> Observable<[Ingredient]> 
    static func generateGenresIDs(genresData: [[String: Any]], user: Firebase.User) -> Observable<[String: Bool]>
    //    static func updateUserInterestedGenres(ids: [String: Any], user: Firebase.User, completion: @escaping () -> Void, errBlock: @escaping (Error) -> Void)
    static func uploadIngredientsAsGenres(data: [[String: Any]], user: Firebase.User) -> Observable<Bool> 
    static func updateUserInterestedGenres(ids: [String: Any], user: Firebase.User) -> Observable<Void>
    static func compressData(imgData: [Data]) -> Observable<[Data]>
    static func uploadImages(mainPhoto: Data, videoURL: URL?, user: Firebase.User, recipeID: String) -> Observable<Void>
    static func startUpload(instructions: [Instruction], user: Firebase.User, recipeID: String) -> Observable<Int>
    static func updateTimeLines(data: [String: Any], user: Firebase.User) -> Observable<Bool> 
    
}

final class CreateRecipeDM: CreateRecipeDMProtocol {

    static let db = Firestore.firestore()
    static let storage = Storage.storage().reference()
    
    static var firestoreServices: FirestoreServices {
        return FirestoreServices()
    }
    
    static func getThumbnailData(url: URL) -> Observable<Data> {
        
        return .create { observer in
            
            let asset = AVAsset(url: url)
            let imageGenerator = AVAssetImageGenerator(asset: asset)
            imageGenerator.appliesPreferredTrackTransform = true
            
            do {
                let thumbnailCGImage = try imageGenerator.copyCGImage(at: CMTimeMake(value: 1, timescale: 60), actualTime: nil)
               
                guard let data = thumbnailCGImage.data else {
                    return
                }
                
                observer.onNext(data)
                
            } catch (let err) {
                observer.onError(err)
            }
            return Disposables.create()
        }
    }
    
    static func getMyGenresIDs(user: Firebase.User) -> Observable<[String]> {
        
        return .create { observer in
            
            db.collection("users").document(user.uid).collection("genres")
                .getDocuments { snapShot, err in
                    
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
    
    
    static func searchGenres(searchWord: String) -> Observable<[Genre]> {
        
        return .create { observer in
            
            var query = db.collection("genres").limit(to: 100)
            let arr = Array(searchWord.lowercased())
            
            arr.forEach {
                query = query.whereField("searchChar.\($0)", isEqualTo: true)
            }
            
            //            db.collection("genres").whereField("name", isEqualTo: searchWord.capitalized).getDocuments { snapShot, err in
            
            query.getDocuments { snapShot, err in
                
                if let err = err {
                    
                    observer.onError(err)
                    
                }
                
                else {
                    
                    if let docs = snapShot?.documents {
                        
                        if docs.exists {
                            
                            let genres = docs.compactMap { doc -> Genre? in
                                
                                if let genre = Genre(document: doc) {
                                    
                                    return genre
                                    
                                }
                                else {
                                    return nil
                                }
                                
                            }
                            
                            observer.onNext(genres)
                            
                        }
                        else {
                            
                            observer.onNext([])
                            
                        }
                        
                    }
                }
            }
            
            
            return Disposables.create()
        }
    }
    
    // filter not searched txt and selected genre array,
    // later not searched txt should search if firestore knows each txt as genre,
    // if knows, get doc, genenate genre, then append to selected genres
    // if not knows genenate new genre, then apepend to selected genres
    
    // sort result genres by text in text view in search genre vc, then pass them.
    
    // check if there is under genres collection at first (cause to get genre id to register my interested genres). if not add it.
    // check if registered my instereted genres secondally, if no, add it.
    
    static func filterNotSearchedGenres(genres: [Genre], txt: String) -> Observable<([Genre], [String])> {
        
        return .create { observer in
            
            var selectedArr:[Genre] = []
            var notSearchedarr:[String] = []
            
            var arrTxt = txt.components(separatedBy: "#").filter { $0 != "" }
            arrTxt = arrTxt.map { $0.filter { char in
                
                return char != " "
                
            } }
            
            arrTxt.forEach { txt in
                
                if let matchedGenre = genres.first(where: { $0.title == txt }) {
                    
                    selectedArr.append(matchedGenre)
                    
                }
                else {
                    
                    notSearchedarr.append(txt)
                }
            }
            
            
            observer.onNext((selectedArr, notSearchedarr))
            
            return Disposables.create()
        }
        
    }
    
    static func isFirebaseKnowsGenres(word: String, completion: @escaping (Genre?) -> Void, errBlock: @escaping (Error) -> Void) {
        
        //        words.forEach { word in
        //            query doesn't work
        var query = db.collection("genres").limit(to: 30)
        let arr = Array(Set(word.lowercased()))
        
        
        arr.forEach {
            query = query.whereField("searchChar.\($0)", isEqualTo: true)
        }
        
        //        var query = db.collection("genres").whereField("searchChar.H", isEqualTo: true)
        query.getDocuments { snapShot, err in
            
            if let err = err {
                
                errBlock(err)
                
            }
            
            else {
                
                if let docs = snapShot?.documents {
                    
                    if docs.exists {
                        
                        let genres = docs.compactMap { doc -> Genre? in
                            
                            if let genre = Genre(document: doc) {
                                
                                return genre
                                
                            }
                            else {
                                return nil
                            }
                            
                        }
                        
                        if let genre = genres.first(where: { $0.title == word} ) {
                            
                            completion(genre)
                        }
                        else {
                            completion(nil)
                        }
                        
                    }
                    else {
                        
                        completion(nil)
                        
                    }
                    
                }
            }
        }
        //        }
    }
    
    static func isUserInterested(genres: [Genre], user: Firebase.User) -> Observable<[Genre]> {
        
        return .create { observer in
            
            var finishedGenres: [Genre] = []
            
            if genres.isEmpty {
                
                observer.onNext([])
                
            } else {
                
                genres.enumerated().forEach { index, genre in
                    
                    registerUserInterestedGenres(genre: genre, user: user, completion: {
                        
                        addMyGenreAsID(user: user, id: genre.id) {
                            
                            finishedGenres.append(genre)
                            
                            if genres.count == finishedGenres.count {
                                
                                observer.onNext(finishedGenres)
                            }
                            
                        } errBlock: { err in
                        
                            print(err)
                            
                            finishedGenres.append(genre)
                            
                            if genres.count == finishedGenres.count {
                                
                                observer.onNext(finishedGenres)
                            }
                            
                        }

                        
                    }, errBlock: { err in
                        
                        print(err)
                        
                        if genres.count == finishedGenres.count {
                            
                            observer.onNext(finishedGenres)
                            
                        }
                        
                    })
                    
                }
                
            }
            
            return Disposables.create()
            
        }
        
    }
    
    static func registerUserInterestedGenres(genre: Genre, user: Firebase.User, completion: @escaping () -> Void, errBlock: @escaping (Error) -> Void) {
        
        db.collection("users").document(user.uid).collection("genres").document(genre.id).updateData([
            
//            "id": genre.id,
            "usedLatestDate": Date(),
            "count": FieldValue.increment(Int64(1))
            
        ]) { myGenreErr in
            
            if let myGenreErr = myGenreErr {
                
                if myGenreErr.convertToNSError().code == 5 {
                    
                    db.collection("users").document(user.uid).collection("genres").document(genre.id).setData([

                        "id": genre.id,
                        "usedLatestDate": Date(),
                        "count": FieldValue.increment(Int64(1))

                    ]) { setDataErr in

                        if let setDataErr = setDataErr {

                            errBlock(setDataErr)

                        }
                        else {
                            completion()
                        }

                    }
                    
                }
                else {
                    
                    errBlock(myGenreErr)

                }
               
            }
            else {
                
               
               completion()
                
            }
        }
        
    }
    
    static func addMyGenreAsID(user: Firebase.User, id: String, completion: @escaping () -> Void, errBlock: @escaping (Error) -> Void) {
       
        db.collection("users").document(user.uid).getDocument { snapShot, err in
            
            if let err = err {
                
                errBlock(err)
                
            }
            else {
                
                var newDic:[String: Bool] = [:]
                
                if let data = snapShot?.data(), let value = data["genres"] as? [String: Bool] {
                    
                    newDic = value
                    newDic[id] = true
                   
                    
                    db.collection("users").document(user.uid).updateData([
                        
                        "genres": newDic
                        
                    ]){ err in
                        
                        if let err = err {
                            
                            errBlock(err)
                            
                        }
                        else {
                            
                            completion()
                            
                        }
                    }
                }
                else {
                    
                    newDic[id] = true

                    db.collection("users").document(user.uid).updateData([
                        
                        "genres": newDic
                        
                    ]){ err in
                        
                        if let err = err {
                            
                            errBlock(err)
                            
                        }
                        else {
                            
                            completion()
                            
                        }
                    }
                    
                }
                
                
                
            }
            
        }
    }
    
    static func registerNewGenres(genres: [String], user: Firebase.User) -> Observable<[Genre]> {
        
        return .create { observer in
            
            var finishedGenres: [String] = []
            var registeredGenres: [Genre] = []
            
            if genres.isEmpty {
                
                observer.onNext([])
                
            } else {
                
                genres.enumerated().forEach { index, txt in
                    
                    
                    let uuid = UUID()
                    let uniqueIdString = uuid.uuidString.replacingOccurrences(of: "-", with: "")
                    
                    let arrGenre = Array(txt.lowercased())
                    var dicGenre:[String: Bool] = [:]
                    
                    arrGenre.forEach {
                        
                        let key = String($0)
                        dicGenre[key] = true
                        
                    }
                    
                    
                    let data: [String : Any] = [
                        
                        "id": uniqueIdString,
                        "title": txt,
                        "count": FieldValue.increment(Int64(1)),
                        "usedLatestDate": Date(),
                        "searchChar": dicGenre
                    ]
                    
                    let genre = Genre(id: uniqueIdString, title: txt)
                    
                    registerUnderGenres(data: data, user: user, completion: {
                        
                        
                        registerUserInterestedGenres(genre: genre, user: user, completion: {
                            
                            finishedGenres.append(txt)
                            registeredGenres.append(genre)
                            
                            if genres.count == finishedGenres.count {
                                
                                observer.onNext(registeredGenres)
                            }
                            
                            
                        }, errBlock: { err in
                            
                            print(err)
                            
                            finishedGenres.append(txt)
                            registeredGenres.append(genre)
                            
                            if genres.count == finishedGenres.count {
                                
                                observer.onNext(registeredGenres)
                            }
                            
                            
                        })
                        
                    }, errBlock: { err in
                        
                        print(err)
                        
                        finishedGenres.append(txt)
                        registeredGenres.append(genre)
                        
                        if genres.count == finishedGenres.count {
                            
                            observer.onNext(registeredGenres)
                        }
                        
                        
                    })
                    
                }
                
            }
            
            return Disposables.create()
            
        }
    }
    
    static func uploadIngredientsAsGenres(data: [[String: Any]], user: Firebase.User) -> Observable<Bool> {
        
        return .create { observer in
            
            var finishedDataNum = 0
            
            data.forEach { element in
               
                updateUnderGenres(data: element, user: user, completion: {
                    
                    finishedDataNum += 1
                    
                    let isComepleted = data.count == finishedDataNum
                    
                    observer.onNext(isComepleted)
               
                }, errBlock: { err in
                    
                    if err.convertToNSError().code == 5 {
                        
                        registerUnderGenres(data: element, user: user) {
                            
                            finishedDataNum += 1
                            
                            let isComepleted = data.count == finishedDataNum
                            
                            observer.onNext(isComepleted)
                           
                            
                        } errBlock: { err in
                          
                            finishedDataNum += 1
                            
                            print(err)
                            
                            let isComepleted = data.count == finishedDataNum
                            
                            observer.onNext(isComepleted)
                        }

                        
                    }
                    else {
                        
                        finishedDataNum += 1
                        
                        print(err)
                        
                        let isComepleted = data.count == finishedDataNum
                        
                        observer.onNext(isComepleted)
                        
                    }
                    
                   
                   
                })
            }
            
            return Disposables.create()
        }
       
        
    }
    
    static func updateUnderGenres(data: [String: Any], user: Firebase.User, completion: @escaping () -> Void, errBlock: @escaping (Error) -> Void) {
        
        guard let id = data["id"] as? String else { return }
        
        db.collection("genres").document(id).updateData(data) { err in
            
            if let err = err {
                
                errBlock(err)
                
                
            }
            else {
                
                completion()
            }
        }
    }
    
    static func registerUnderGenres(data: [String: Any], user: Firebase.User, completion: @escaping () -> Void, errBlock: @escaping (Error) -> Void) {
        
        guard let id = data["id"] as? String else { return }
        
        db.collection("genres").document(id).setData(data) { err in
            
            if let err = err {
                
                errBlock(err)
                
                
            }
            else {
                
                completion()
            }
        }
    }
    
    
    static func createGenres(genres: [Genre], user: Firebase.User) -> Observable<([Genre], Bool)> {
        
        return .create { observer in
            
            genres.enumerated().forEach { index, genre in
                
                let arrGenre = Array(genre.title)
                var dicGenre:[String: Bool] = [:]
                
                arrGenre.forEach {
                    
                    let key = String($0)
                    dicGenre[key] = true
                    
                }
                
                
                let data: [String : Any] = [
                    
                    "id": genre.id,
                    "title": genre.title,
                    "count": FieldValue.increment(Int64(1)),
                    "usedLatestDate": Date(),
                    "searchChar": dicGenre
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
                    
//                    self.storage.child("users/\(user.uid)/userImage.jpg").getData(maxSize: 1 * 1024 * 1024) { data, err in
                        
//                        if let err = err {
//
//                            observer.onError(err)
//
//                        }
//                        else {
                            
//                            if let data = data {
                                
                    if let doc = doc, let user = User(document: doc) {
                                    
                        observer.onNext(user)
                                    
                    }
                    else {
                        observer.onNext(User(id: "", name: "Publisher could not get", isVIP: false, imgURLString: ""))
                    }
//                            }
//                        }
                        
                    }
//                }
                
            }
            
            return Disposables.create()
        }
    }
    
    //MARK: create uploading recipe data
    static func convertToUploadingRecipeData(title: String, time: Int, serving: Int, isVIP: Bool, user: Firebase.User) -> Observable<[String: Any]> {
        
        return .create { observer in
            
            var data:[String: Any] = [:]
        
            
            let uuid = UUID()
            let uniqueIdString = uuid.uuidString.replacingOccurrences(of: "-", with: "")
            
            
            data["id"] = uniqueIdString
            data["publisherID"] = user.uid
            data["isVIP"] = isVIP
            data["updateDate"] = Date()
            
            data["title"] = title
            data["time"] = time
            data["serving"] = serving
                    
            
            observer.onNext(data)
                        
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
            data["updateDate"] = Date()
            
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
                        genresDic[$0.id] = true
                    }
                    
                case let .ingredients(ingredient):
                    
                    ingredientsDic[ingredient.id] = true
                    genresDic[ingredient.id] = true
                    
                    
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
    
    //MARK: convert to genres data
    
    static func convertToGenresData(ingredients: [Ingredient]) -> Observable<[[String: Any]]> {
        
        return .create { observer in
            
            let ingredientsdata:[[String: Any]] = ingredients.map { ingredient in
                                
                return self.generateGenreDic(id: ingredient.id, title: ingredient.name)
                
            }
            
            observer.onNext(ingredientsdata)

            return Disposables.create()
        }
        
    }
    
    static func convertToGenresData(genres: [Genre]) -> Observable<[[String: Any]]> {
        
        return .create { observer in
            
            let genressdata:[[String: Any]] = genres.map { genre in
                                
                return self.generateGenreDic(id: genre.id, title: genre.title)
                
            }
            
            observer.onNext(genressdata)

            return Disposables.create()
        }
        
    }
    
    static func convertToBasicInfoDic(ingredients: [Ingredient]) -> Observable<[String: Bool]> {
        
        return .create { observer in
            
            var dic:[String: Bool] = [:]
            
            ingredients.forEach { ingredient in
                dic[ingredient.id] = true
            }
            
            observer.onNext(dic)
            
            return Disposables.create()
        }
    }
    
    static func convertToBasicInfoDic(genres: [Genre]) -> Observable<[String: Bool]> {
        
        return .create { observer in
            
            var dic:[String: Bool] = [:]
            
            genres.forEach { genre in
                dic[genre.id] = true
            }
            
            observer.onNext(dic)
            
            return Disposables.create()
        }
    }
    
    static func generateGenreDic(id: String, title: String) -> [String: Any] {
       
        var dic:[String: Any] = [:]
        
        dic["id"] = id
        dic["title"] = title
        dic["usedLatestDate"] = Date()
        dic["count"] = FieldValue.increment(Int64(1))
        
        
        let nameCharArr = Array(title)
        var dicSearchingChar:[String: Bool] = [:]
        
        nameCharArr.forEach {
            
            let key = String($0)
            dicSearchingChar[key] = true
            
        }
        
        dic["searchChar"] = dicSearchingChar
        
        return dic
        
    }
    
    static func convertToGenresData(sections: [RecipeItemSectionModel]) -> Observable<[[String: Any]]>  {
        
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
                        data["title"] = genre.title
                        data["usedLatestDate"] =  Date()
                        data["count"] = FieldValue.increment(Int64(1))
                        
                        let arrGenre = Array(genre.title)
                        var dicGenre:[String: Bool] = [:]
                        
                        arrGenre.forEach {
                            
                            let key = String($0)
                            dicGenre[key] = true
                            
                        }
                        
                        data["searchChar"] = dicGenre
                        
                        result.append(data)
                    }
                    
                case let .ingredients(ingredient):
                    
                    var data:[String: Any] = [:]
                    
                    let uuid = UUID()
                    let uniqueIdString = uuid.uuidString.replacingOccurrences(of: "-", with: "")
                    
                    data["id"] = uniqueIdString
                    data["name"] = ingredient.name
                    data["usedLatestDate"] =  Date()
                    data["count"] = FieldValue.increment(Int64(1))
                    
                    
                    let arrIngredient = Array(ingredient.name)
                    var dicIngredient:[String: Bool] = [:]
                    
                    arrIngredient.forEach {
                        
                        let key = String($0)
                        dicIngredient[key] = true
                        
                    }
                    
                    data["searchChar"] = dicIngredient
                    
                    result.append(data)
                    
                    
                default:
                    break
                }
                
                
            }
            
            observer.onNext(result)
            
            return Disposables.create()
        }
    }
    
    static func getIngredientIDs(ingredients: [Ingredient]) -> Observable<[Ingredient]> {
        
        return .create { observer in
            
            var result:[Ingredient] = []
            
            ingredients.forEach { ingredient in
                
                getIngredientID(name: ingredient.name) { id in
                    
                    let newIngredient = ingredient
                   
                    if let id = id {
                        
                        newIngredient.id = id
                        
                    }
                    
                    result.append(newIngredient)
                    
                    if ingredients.count == result.count {
                        
                        observer.onNext(result)
                        
                    }
                }
                
            }
            
            return Disposables.create()
        }
    }
    
    //MARK: ask if firebase knows ingredient and genres
    static func getIngredientID(name: String, completion: @escaping (String?) -> Void) {
        
        db.collection("genres").whereField("name", isEqualTo: name).getDocuments { snapShot, err in
            
            if let err = err {
                
                print(err)
                completion(nil)
                
            }
            else {
                
                if let doc = snapShot?.documents.first {
                    
                    let data = doc.data()
                    
                    if let id = data["id"] as? String {
                        
                        completion(id)
                    }
                    else {
                        
                        completion(nil)
                        
                    }
                }
                else {
                    
                    completion(nil)
                    
                }
                
            }
            
        }
        
    }
    
    static func convertToInstructionsData(section: RecipeItemSectionModel, user: Firebase.User, recipeID: String) -> Observable<[[String: Any]]>  {
        
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
                    
                    
                    
                    //                    let uuid = UUID()
                    //                    let uniqueIdString = uuid.uuidString.replacingOccurrences(of: "-", with: "")
                    
                    data["id"] = instruction.id
                    data["index"] = instruction.index
                    data["text"] = instruction.text
                    //                    data["imageURL"] = "users/\(user.uid)/recipes/\(recipeID)/\(uniqueIdString)/\(instruction.index).jpg"
                    
                    result.append(data)
                    
                default:
                    break
                }
            }
            
            observer.onNext(result)
            
            return  Disposables.create()
        }
    }
    
    
//    static func createIngredientsData(section: RecipeItemSectionModel, user: Firebase.User, recipeID: String) -> Observable<[[String: Any]]> {
//
    static func convertToIngredientsData(ingredients: [Ingredient]) -> Observable<[[String: Any]]> {
        return .create { observer in
            
//            var tempItems:[RecipeDetailSectionItem] = []
            var result: [[String: Any]] = []
//
//            switch section {
//            case let .ingredients(ingredients):
//
//                tempItems.append(contentsOf: ingredients)
//
//
//            default:
//                break
//            }
//
//            tempItems.enumerated().forEach { index, item in

            ingredients.enumerated().forEach { index, ingredient in

                var data:[String: Any] = [:]
//
//                switch item {
//                case let .ingredients(ingredient):
                    
                    data["id"] = ingredient.id
                    data["name"] = ingredient.name
                    data["amount"] = ingredient.amount
                    data["index"] = index
                    
                    result.append(data)
                    
//                default:
//                    break
//                }
            }
            
            observer.onNext(result)
            
            return Disposables.create()
        }
    }
    
    static func convertToInstructionData(instructions: [Instruction]) -> Observable<[[String: Any]]> {
        
        return .create { observer in
                        
            let data: [[String: Any]] = instructions.map { instruction in
               
                var dic:[String: Any] = [:]
                
                dic["id"] = instruction.id
                dic["index"] = instruction.index
                dic["text"] = instruction.text
                
                return dic
            }
            
            observer.onNext(data)
            
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
                   
                    var ingredientNum = 0
                    
                    ingredientsData.forEach { ingredientData in
                        
                        addRecipeMoreInfo(collectionName: "ingredients", recipeID: recipeId, data: ingredientData) {
                        
                            ingredientNum += 1
                            
                            if ingredientNum == ingredientsData.count {
                            
                                var instructiontNum = 0
                                
                                instructionsData.forEach { instructionData in
                                    
                                    addRecipeMoreInfo(collectionName: "instructions", recipeID: recipeId, data: instructionData) {
                                    
                                        instructiontNum += 1
                                        
                                        if ingredientNum == ingredientsData.count {
                                        
                                            observer.onNext(recipeData)
                                        
                                        }
                                    
                                    } errBlock: { err in
                                        
                                        instructiontNum += 1
                                        
                                        print(err)
                                        
                                        if ingredientNum == ingredientsData.count {
                                        
                                            observer.onNext(recipeData)
                                        
                                        }
                                        
                                    }

                                }
                            
                            }
                        
                        } errBlock: { err in
                            
                            ingredientNum += 1
                            
                            print(err)
                            
                            if ingredientNum == ingredientsData.count {
                            
                                var instructiontNum = 0
                                
                                instructionsData.forEach { instructionData in
                                    
                                    addRecipeMoreInfo(collectionName: "instructions", recipeID: recipeId, data: instructionData) {
                                    
                                        instructiontNum += 1
                                        
                                        if ingredientNum == ingredientsData.count {
                                        
                                            observer.onNext(recipeData)
                                        
                                        }
                                    
                                    } errBlock: { err in
                                        
                                        instructiontNum += 1
                                        
                                        print(err)
                                        
                                        if ingredientNum == ingredientsData.count {
                                        
                                            observer.onNext(recipeData)
                                        
                                        }
                                        
                                    }

                                }
                                
                                
                            
                            }
                            
                        }

                    }
                    
                  
                    
                    
//                    ingredientsData.forEach {
//
//                        guard let ingredientID = $0["id"] as? String else { return }
//
//                        db.collection("recipes").document(recipeId).collection("ingredients").document(ingredientID).setData($0, merge: true) { err in
//
//                            if let err = err {
//
//                                observer.onError(err)
//                            }
//                            else {
//
//                                instructionsData.forEach {
//
//                                    guard let instructionID = $0["id"] as? String else { return }
//
//                                    db.collection("recipes").document(recipeId).collection("instructions").document(instructionID).setData($0, merge: true) { err in
//
//                                        if let err = err {
//
//                                            observer.onError(err)
//                                        }
//                                        else {
//
//                                            observer.onNext(recipeData)
//                                        }
//                                    }
//                                }
//                            }
//                        }
//                    }
                    
                }
            }
            
            return  Disposables.create()
            
        }
    }
    
   static func addRecipeMoreInfo(collectionName: String, recipeID: String, data: [String: Any], completion: @escaping () -> Void, errBlock: @escaping (Error) -> Void) {
        
        guard let id = data["id"] as? String else { return }

        db.collection("recipes").document(recipeID).collection(collectionName).document(id).setData(data, merge: true) { err in
            
            if let err = err {
                
                errBlock(err)
            }
            else {
                
                completion()
            }
        }
        
    }
    
    static func generateGenresIDs(genresData: [[String: Any]], user: Firebase.User) -> Observable<[String: Bool]> {
        
        return .create { observer in
            
            var ids:[String: Bool] = [:]
            
            genresData.enumerated().forEach { index, data in
                
                checkGenresSaved(data: data, user: user, completion: { id in
                    
                    ids[id] = true
                    
                    if ids.count == genresData.count {
                        observer.onNext(ids)
                    }
                    
                }, errBlock: { err in
                    
                    print(err)
                    
                    if ids.count == genresData.count {
                        observer.onNext(ids)
                    }
                    
                })
                
            }
            
            
            return  Disposables.create()
        }
        
    }
    
    static func checkGenresSaved(data:[String: Any], user: Firebase.User, completion: @escaping (String) -> Void, errBlock: @escaping (Error) -> Void) {
        
        guard let genreID = data["id"] as? String, let name = data["name"] as? String else { return }
        
        db.collection("genres").whereField("name", isEqualTo: name).getDocuments() { snapShot, err in
            
            if let _ = err {
                
                db.collection("genres").document(genreID).setData(data, merge: true) { err in
                    
                    if let err = err {
                        
                        errBlock(err)
                        
                    }
                    else {
                        
                        completion(genreID)
                        
                    }
                }
                
            }
            else {
                
                if let snapShot = snapShot {
                    
                    if snapShot.documents.isEmpty {
                        
                        db.collection("genres").document(genreID).setData(data, merge: true) { err in
                            
                            if let err = err {
                                
                                errBlock(err)
                                
                            }
                            
                            completion(genreID)
                        }
                        
                        
                    }
                    else {
                        
                        if let item = snapShot.documents.first {
                            
                            let id = item.documentID
                            completion(id)
                            
                        }
                        else {
                            
                            completion(genreID)
                            
                        }
                        
                    }
                    
                    
                }
                
                
            }
            
        }
    }
    
    
    //    static func updateUserInterestedGenres(ids: [String: Any], user: Firebase.User, completion: @escaping () -> Void, errBlock: @escaping (Error) -> Void) {
    
    static func updateUserInterestedGenres(ids: [String: Any], user: Firebase.User) -> Observable<Void> {
        
        return .create { observer in
            
            var idsData: [String: Any] = [:]
            idsData["genres"] = ids
            
            db.collection("users").document(user.uid).getDocument() { snapShot, err in
                
                if let err = err {
                    
                    observer.onError(err)
                    
                }
                else {
                    
                    if let data = snapShot?.data(),
                       let arrOfData = data["genres"] as? [String:Bool] {
                        
                        let filteredIds = ids.filter  { !arrOfData.keys.contains($0.key) }
                        idsData["genres"] = filteredIds
                        
                    }
                    else {
                        
                        idsData["genres"] = ids
                        
                    }
                    
                    db.collection("users").document(user.uid).updateData(idsData) { err in
                        
                        if let err = err {
                            
                            observer.onError(err)
                            
                        }
                        else {
                            
                            observer.onNext(())
                            
                        }
                    }
                    
                    
                }
                
            }
            
            return Disposables.create()
        }
        
        //        }
    }
    
    static func compressData(imgData: [Data]) -> Observable<[Data]> {
        
        return .create { observer in
            
            var result:[Data] = []
            
            imgData.forEach { data in
                
                if let img = UIImage(data: data), let compressedData = img.jpegData(compressionQuality: 0.7) {
                    
                    result.append(compressedData)
                }
            }
            
            observer.onNext(result)
            
            return Disposables.create ()
        }
    }
    
    
    static func uploadImages(mainPhoto: Data, videoURL: URL?, user: Firebase.User, recipeID: String) -> Observable<Void> {
        
        return .create { observer in
            
            //            if let imgData = mainPhoto {
            //            if let imgData = mainPhoto.jpegData(compressionQuality: 0.75)  {
            let metaData = StorageMetadata()
            metaData.contentType = "image/jpg"
            
            self.storage.child("users/\(user.uid)/\(recipeID)/mainPhoto.jpg").putData(mainPhoto, metadata: metaData) { metadata, err in
                
                if let err = err {
                    
                    observer.onError(err)
                    
                } else {
                    
                    self.storage.child("users/\(user.uid)/\(recipeID)/mainPhoto.jpg").downloadURL { imgURL, err in
                        
                        if let err = err {
                            
                            observer.onError(err)
                            
                        } else {
                            
                            if let imgURL = imgURL?.absoluteString {
                                
                                
                                self.db.collection("recipes").document(recipeID).setData([
                                    
                                    "imgString": imgURL
                                    
                                ]) { err in
                                    
                                    if let err = err {
                                        
                                        observer.onError(err)
                                        
                                    }
                                    else {
                                        
                                        
                                        if let videoURL = videoURL {
                                            
                                            let metadata = StorageMetadata()
                                            //specify MIME type
                                            metadata.contentType = "video/quicktime"
                                            
                                            //convert video url to data
                                            if let videoData = NSData(contentsOf: videoURL) as Data? {
                                                //use 'putData' instead
                                                let uploadTask = self.storage.child("users/\(user.uid)/\(recipeID)/movie.mov").putData(videoData, metadata: metadata)
                                                
                                                // Listen for state changes, errors, and completion of the upload.
                                                uploadTask.observe(.resume) { snapshot in
                                                    // Upload resumed, also fires when the upload starts
                                                    print("resume")
                                                }
                                                
                                                uploadTask.observe(.pause) { snapshot in
                                                    // Upload paused
                                                    print("pause")
                                                }
                                                
                                                uploadTask.observe(.progress) { snapshot in
                                                    // Upload reported progress
                                                    let percentComplete = 100.0 * Double(snapshot.progress!.completedUnitCount)
                                                    / Double(snapshot.progress!.totalUnitCount)
                                                    
                                                    print(percentComplete)
                                                }
                                                
                                                uploadTask.observe(.success) { snapshot in
                                                    // Upload completed successfully
                                                    self.storage.child("users/\(user.uid)/\(recipeID)/movie.mov").downloadURL { downloadedVideoURL, err in
                                                        
                                                        if let err = err {
                                                            observer.onError(err)
                                                        }
                                                        else {
                                                            
                                                            if let downloadedVideoURL = downloadedVideoURL?.absoluteString {
                                                                
                                                                self.db.collection("recipes").document(recipeID).updateData([
                                                                                                                      
                                                                    "videoURL": downloadedVideoURL
                                                                                                                      
                                                                ]) { err in
                                                                                                                      
                                                                    if let err = err {
                                                                                                                          
                                                                        observer.onError(err)
                                                                                                                          
                                                                    }
                                                                    else {
                                                                                                                         
                                                                        observer.onNext(())
                                                                                                                      
                                                                    }
                                                                                                                  
                                                                }
                                                                
                                                            }
                                                            
                                                        }
                                                        
                                                    }
                                                    
                                                  
                                                }
                                                
                                                
                                                uploadTask.observe(.failure) { snapshot in
                                                    
                                                    if let err = snapshot.error {
                                                        
                                                        observer.onError(err)
                                                        
                                                    }
                                                }
                                            }
                                            
                                        } else {
                                            
                                            observer.onNext(())
                                        
                                        }
                                        
                                        
                                    }
                                }
                                
                            }
                        }
                    }
                    
                    
                    
                }
            }
            //            }
            return Disposables.create()
        }
    }
    
    static func startUpload(instructions: [Instruction], user: Firebase.User, recipeID: String) -> Observable<Int> {
        
        return .create { observer in
            
            let sortedInstructions = instructions.sorted { $0.index < $1.index }
            
            sortedInstructions.enumerated().forEach { index, instruction in
                
                self.uploadInstructionsImages(instruction: instruction, user: user, recipeID: recipeID, index: index, block: {
                    
                    observer.onNext(index)
                    
                }, errBlock: { err in
                    
                    print(index, err)
                    
                    observer.onNext(index)
                    
                })
                
                
            }
            
            
            return Disposables.create()
        }
    }
    
    static func uploadInstructionsImages(instruction: Instruction, user: Firebase.User, recipeID: String, index: Int, block: @escaping () -> Void, errBlock: @escaping (Error) -> Void) {
        
        
//        if let urlString = instruction.imageURL, let url = URL(string: urlString), let img = UIImage(data: NSData(url: url)), let compressedData = img.jpegData(compressionQuality: 0.7) {
            
        if let urlString = instruction.imageURL, let data = Data(base64Encoded: urlString, options: .ignoreUnknownCharacters) {
            
            let metaData = StorageMetadata()
            metaData.contentType = "image/jpg"
            
            let uploadTask = self.storage.child("users/\(user.uid)/\(recipeID)/\(instruction.index).jpg").putData(data, metadata: metaData)
//            let uploadTask = self.storage.child("users/\(user.uid)/\(recipeID)/\(instruction.index).jpg").putFile(from: url, metadata: metaData)
            // Listen for state changes, errors, and completion of the upload.
            uploadTask.observe(.resume) { snapshot in
                // Upload resumed, also fires when the upload starts
                print("resume")
            }
            
            uploadTask.observe(.pause) { snapshot in
                // Upload paused
                print("pause")
            }
            
            uploadTask.observe(.progress) { snapshot in
                // Upload reported progress
                let percentComplete = 100.0 * Double(snapshot.progress!.completedUnitCount)
                / Double(snapshot.progress!.totalUnitCount)
                
                print(percentComplete)
                
                
            }
            
            uploadTask.observe(.success) { snapshot in
                
                self.storage.child("users/\(user.uid)/\(recipeID)/\(instruction.index).jpg").downloadURL { url, err in
                    
                    if let err = err {
                        errBlock(err)
                    }
                    else {
                        
                        if let url = url {
                            
                            self.db.collection("recipes").document(recipeID).collection("instructions").document(instruction.id).updateData([
                                
                                "imgString": url.absoluteString
                                
                            ]) { err in
                                
                                if let err = err {
                                    
                                    errBlock(err)
                                    
                                }
                                else {
                                    
                                    block()
                                    
                                }
                            }
                        }
                        
                    }
                }
                
                
            }
            
            
            uploadTask.observe(.failure) { snapshot in
                
                if let err = snapshot.error {
                    
                    errBlock(err)
                    
                }
            }
        }
        
    }
    
    
    static func updateTimeLines(data: [String: Any], user: Firebase.User) -> Observable<Bool> {
        
        let query = db.collection("users").document(user.uid).collection("followers").whereField("isFollowed", isEqualTo: true)
        
        return firestoreServices.getDocuments(query: query)
            .map { docs -> [String] in
                
                if docs.isEmpty {
                    return []
                }
                
                let ids:[String] = docs.compactMap {
                    
                    let id = $0["id"] as? String
                    
                    return id
                }
                
                return ids
            }
            .flatMapLatest { ids -> Observable<Bool> in
                
                 let publisherID = data["publisherID"] as? String
                 let recipeId = data["id"] as? String
                
                return self.addTimelines(ids: ids, publisherID: publisherID, recipeId: recipeId)
            
            }
//            .map { dics -> [(DocumentReference)] in
//
//                if dics.isEmpty {
//                    return []
//                }
//
//                let pathes:[DocumentReference] = dics.compactMap { dic in
//
//                    let uuid = UUID()
//                    let uniqueIdString = uuid.uuidString.replacingOccurrences(of: "-", with: "")
//
//                    guard let id = dic["id"] as? String else { return nil }
//
//                    let path = db.collection("users").document(id).collection("timeline").document(uniqueIdString)
//
//                    return path
//                }
//
//
//
//                return pathes
//            }
//            .flatMapLatest { references -> Observable<Bool> in
//
//                if let id = data["id"] as? String , let publisherID = data["publisherID"] as? String {
//
//                    var data: [String: Any] = [
//
//                        "id": uniqueIdString,
//                        "recipeId": id,
//                        "publisherID": publisherID,
//                        "kind": "recipes"
//
//                    ]
//
//                    let recipePath = db.collection("recipes").document(id)
//
//                    return firestoreServices.getDocument(path: recipePath)
//                        .map({ newData -> [String: Any] in
//                            if let updateDate = newData["updateDate"] as? Timestamp {
//                                data["updateDate"] = updateDate
//                            }
//
//                            return data
//                        })
//                        .flatMapLatest { newData in
//                            firestoreServices.setData(references: references, dic: data).map { true }
//                        }
//
//                }
//
//                return .just(false)
//            }
        
    }
    
    static func addTimelines(ids: [String], publisherID: String?, recipeId: String?) -> Observable<Bool> {
        
        let uuid = UUID()
        let uniqueIdString = uuid.uuidString.replacingOccurrences(of: "-", with: "")
        
        guard let publisherID = publisherID, let recipeId = recipeId else {
            return .just(false)
        }

        let references:[DocumentReference] = ids.compactMap { id in
            
            let path = db.collection("users").document(id).collection("timeline").document(uniqueIdString)
            
            return path
        }
        
        var data: [String: Any] = [
           
            "id": uniqueIdString,
            "kind": "recipes",
            "publisherId": publisherID,
            "recipeId": recipeId
            
        ]
        
        let recipePath = db.collection("recipes").document(recipeId)
      
        return firestoreServices.getDocument(path: recipePath)
            .map({ newData -> [String: Any] in
                if let updateDate = newData["updateDate"] as? Timestamp {
                    data["updateDate"] = updateDate
                }
                
                return data
            })
            .flatMapLatest { newData -> Observable<Bool> in
                
                if references.count == 0 {
                    return Observable<Bool>.just(true)
                }
                
                else if references.count == 1 {
                    return firestoreServices.setData(path: references[0], data: newData).map { _ in true }
                }
                
                return firestoreServices.setData(references: references, dic: newData).map { true }
           
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
