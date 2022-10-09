//
//  PublishRecipeVM.swift
//  TastyBox-2
//
//  Created by 北島　志帆美 on 2021-10-27.
//

import Foundation
import Firebase
import UIKit
import RxSwift
import SCLAlertView
import SwiftUI

final class PublishRecipeVM: ViewModelBase {
    
    let sceneCoodinator: SceneCoordinator
    let user: Firebase.User
    
    let mainImageData: Data
    let videoURL: URL?
    
    let title: String
    let time: Int
    let serving: Int
    let isVIP: Bool
    let genres: [Genre]
    let ingredients: [Ingredient]
    let instructions: [Instruction]
    
    let apiType: CreateRecipeDMProtocol.Type
    
    var options:[(Data, String)]
    
    let tappedPublishSubject = BehaviorSubject<Void>(value: ())
    
    let ingredientsSubject: BehaviorSubject<[Ingredient]>
    let basicDataSubject: BehaviorSubject<[[String: Any]]>
    
    
    init(sceneCoodinator: SceneCoordinator, user: Firebase.User, apiType: CreateRecipeDMProtocol.Type = CreateRecipeDM.self, title: String, serving: Int, time: Int, isVIP: Bool, video: URL?, mainImageData: Data, genres: [Genre], ingredients: [Ingredient], instructions: [Instruction]) {
        
        self.sceneCoodinator = sceneCoodinator
        self.user = user
        self.apiType = apiType
        self.options = []
        
        self.mainImageData = mainImageData
        self.videoURL = video
        self.title = title
        self.time = time
        self.serving = serving
        self.isVIP = isVIP
        self.genres = genres
        self.ingredients = ingredients
        self.instructions = instructions
        
        self.ingredientsSubject = BehaviorSubject<[Ingredient]>(value: [])
        self.basicDataSubject = BehaviorSubject<[[String: Any]]>(value: [])
        
        if let cancelBtnData = UIImage(systemName: "arrowshape.turn.up.backward")?.convertToData(), let publishNormalBtnData = UIImage(systemName: "square.and.arrow.up")?.convertToData() {
            
            let publishTitle = isVIP ? "Publish VIP Only Recipe" : "Publish Your Recipe"
            var publishBtnData = publishNormalBtnData
            
            if let vipOnlyRecipe = UIImage(systemName: "rosette")?.convertToData() {
                
                publishBtnData = isVIP ? vipOnlyRecipe : publishBtnData
            }
            
            self.options = [(publishBtnData, publishTitle), (cancelBtnData, "Cancel")]
        }
        
        super.init()
        
    }
    
    func getCorrectIngredientIDs() -> Observable<Void> {

        return self.apiType.getIngredientIDs(ingredients: self.ingredients)
            .do(onNext: { ingredients in

                self.ingredientsSubject.onNext(ingredients)

            })
                .map { _ in }
                
    }
 
    func uploadIngredientAsGenre() -> Observable<Bool> {
      
        return ingredientsSubject
            .flatMapLatest { [unowned self] in
                self.apiType.convertToGenresData(ingredients: $0)
            }
            .flatMapLatest { [unowned self] in
                self.apiType.uploadIngredientsAsGenres(data: $0, user: self.user)
            }
    }
    
    func uploadRecipe() -> Observable<Bool> {
        
        return uploadImages()
            .flatMapLatest { [unowned self] data in
                self.zippedUploadRecipeStreams(basicData: data)
            }
            .flatMapLatest { [unowned self] basicData, ingredientData, instructionData -> Observable<Bool> in
                self.uploadRecipe(basicData: basicData, ingredientData: ingredientData, instructionData: instructionData)
            }
            
           
    }
    //MARK: check
    func zippedUploadRecipeStreams(basicData: [String: Any]) -> Observable<([String: Any], [[String: Any]], [[String: Any]])> {
       
        let ingredientDataStream = ingredientsSubject
            .flatMapLatest { [unowned self] ingredients in
                self.convertToIngredientsData(ingredients: ingredients)
            }
        let instructionDataStream = self.convertToInstructionData(instructions: self.instructions)
       
        return .zip(ingredientDataStream, instructionDataStream) { ingredientData, instructionData in
            return (basicData, ingredientData, instructionData)
        }
        
    }
    
    func uploadRecipe(basicData: [String: Any], ingredientData: [[String: Any]], instructionData: [[String: Any]]) -> Observable<Bool> {

        return self.uploadData(basicData: basicData, ingredientsData: ingredientData, instructionsData: instructionData)
            .flatMapLatest { basicData in
                self.uploadInstructionImages(data: basicData)
            }
            .flatMapLatest { isCompleted -> Observable<Bool> in
                
                if isCompleted {
                    
                   return self.uploadIngredientAsGenre()
                    
                }
                else {
                    
                    return Observable<Bool>.empty()
                    
                }
                
            }
            .filter { $0 }
            .flatMapLatest { isUploaded in
                self.addRecipeTimeLines(data: basicData)
            }
        
    }
    

    
    func uploadImages() -> Observable<[String: Any]> {
        
        return convertToUploadBasicData()
            .flatMapLatest { [unowned self] data -> Observable<[String: Any]> in
                
                if let recipeID = data["id"] as? String {
                    
                    return tryUploadImages(recipeID)
                        .map { data }
                }
                else {
                    
                    let uuid = UUID()
                    let uniqueIdString = uuid.uuidString.replacingOccurrences(of: "-", with: "")
                    
                    return tryUploadImages(uniqueIdString)
                        .map { data }
                    
                }
            }
        
    }
    
    
    fileprivate func tryUploadImages(_ uniqueIdString: String) -> Observable<Void> {
        
        return self.apiType.compressData(imgData: [self.mainImageData])
            .map { $0[0] }
            .flatMapLatest { [unowned self] in
                
                self.apiType.uploadImages(mainPhoto: $0, videoURL: self.videoURL, user: self.user, recipeID: uniqueIdString)
                
            }
            .retry(3)
            .catch { err in
                
                guard let reason = err.handleStorageError() else { return .empty() }
                
                reason.showErrNotification()
                
                return .empty()
            }
    }
    
    func convertToUploadBasicData() -> Observable<[String: Any]> {
        
        
        let basicInfoStream = self.apiType.convertToUploadingRecipeData(title: self.title, time: self.time, serving: self.serving, isVIP: self.isVIP, user: self.user)
        
        let ingredientsStream = ingredientsSubject
            .flatMapLatest { ingredients in
                self.apiType.convertToBasicInfoDic(ingredients: ingredients)
            }
        
        
        let genresStream = self.apiType.convertToBasicInfoDic(genres: self.genres)
        
        return basicInfoStream
            .flatMapLatest { data -> Observable<[String: Any]> in
                
                return ingredientsStream
                    .map { ingredientData in
                        
                        var newData: [String: Any] = data

                        var genresDic: [String: Bool] = [:]
                        
                        ingredientData.forEach { key, value in
                            
                            genresDic[key] = value
                            
                        }
                        
                        newData["genres"] = genresDic
                        
                        return newData
                    }
            }
            .flatMapLatest { data -> Observable<[String: Any]> in
                
                return genresStream
                    .map { genresData in
                        
                        var newData: [String: Any] = data

                        var genresDic: [String: Bool] = [:]
                        
                        genresData.forEach { key, value in
                            
                            genresDic[key] = value
                            
                        }
                        
                        if let genres = newData["genres"] as? [String: Bool] {
                            
                            genres.forEach { key, value in
                            
                                genresDic[key] = value
                            
                            }
                            
                            newData["genres"] = genresDic
                        }
                       
                        
                        return newData
                    }
                
            }
        
        
    }
    
    
    func convertToIngredientsData(ingredients: [Ingredient]) -> Observable<[[String: Any]]> {
        
        return self.apiType.convertToIngredientsData(ingredients: ingredients)
        
    }
    
    func convertToInstructionData(instructions: [Instruction]) -> Observable<[[String: Any]]> {
        
        return self.apiType.convertToInstructionData(instructions: instructions)
        
    }
    
    // why separate zippedData and upload data?
    // shows err if not separated.
    func zippedData(data: [String: Any], ingredients: [Ingredient]) -> Observable<([String: Any], [[String: Any]], [[String: Any]])> {

        return .zip(convertToIngredientsData(ingredients: ingredients), convertToInstructionData(instructions: self.instructions), resultSelector: {ingredientData, instructionData in
            
            return (data, ingredientData, instructionData)
            
        })
        
    }
    
    
    func uploadData(basicData: [String: Any], ingredientsData: [[String: Any]], instructionsData: [[String: Any]]) -> Observable<[String: Any]> {
        
        return self.apiType.updateRecipe(recipeData: basicData, ingredientsData: ingredientsData, instructionsData: instructionsData, user: self.user)
            .retry(3)
            .catch { err in
                
                guard let reason = err.handleFireStoreError() else { return .empty() }
                
                reason.showErrNotification()
                
                return .empty()
            }
        
            .retry(3)
            .catch { err in
                
                guard let reason = err.handleFireStoreError() else { return .empty() }
                
                reason.showErrNotification()
                
                return .empty()
            }
    }
    
    func uploadInstructionImages(data: [String: Any]) -> Observable<Bool> {
       
        var currentInstructionUploadedNum = 0

        if self.instructions.isEmpty {
        
            return .just(true)
        
        }
        else {
           
            return self.apiType.startUpload(instructions: self.instructions, user: self.user, recipeID: data["id"] as! String)
                .do(onNext: { index in
                    
                    print(index)
                    
                    currentInstructionUploadedNum += 1
                })
                    .map { _ in
                        
                        currentInstructionUploadedNum == self.instructions.count
                    
                    }

        }
        
    }
    
    func addRecipeTimeLines(data: [String: Any]) -> Observable<Bool> {
        return self.apiType.updateTimeLines(data: data, user: self.user)
    }
    
}

