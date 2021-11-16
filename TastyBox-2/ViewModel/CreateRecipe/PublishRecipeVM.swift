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

class PublishRecipeVM: ViewModelBase {
    
    let sceneCoodinator: SceneCoordinator
    let user: Firebase.User
    
    let recipeData:[String: Any]
    let instructionsData: [[String: Any]]
    let ingredientsData: [[String: Any]]
    let genresData: [[String: Any]]
    let videoURL: URL?
    let mainImage: Data
    let instructions: [Instruction]
    
    let apiType: CreateRecipeDMProtocol.Type
    
    var options:[(Data, String)]
    
    let tappedPublishSubject = BehaviorSubject<Void>(value: ())
    
    init(sceneCoodinator: SceneCoordinator, user: Firebase.User, apiType: CreateRecipeDMProtocol.Type = CreateRecipeDM.self, recipeData: [String: Any], ingredientsData: [[String: Any]], instructionsData: [[String: Any]], genresData: [[String: Any]], isVIP: Bool, video: URL?, mainImage: Data, instructions: [Instruction]) {
        
        self.sceneCoodinator = sceneCoodinator
        self.user = user
        self.apiType = apiType
        self.options = []
        
        self.recipeData = recipeData
        self.ingredientsData = ingredientsData
        self.instructionsData = instructionsData
        self.genresData = genresData
        
        self.mainImage = mainImage
        self.videoURL = video
        self.instructions = instructions

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
     
    func uploadRecipe() -> Observable<Bool> {
        
        var currentInstructionUPloadedNum = 0
        
        let uploadRecipeFieldValues = self.apiType.updateRecipe(recipeData: recipeData, ingredientsData: ingredientsData, instructionsData: instructionsData, user: self.user)
        
        let uploadGenres = self.apiType.generateGenresIDs(genresData: genresData, user: self.user)
            .flatMapLatest { [unowned self] data in
                self.apiType.updateUserInterestedGenres(ids: data, user: self.user)
            }
            .catch { err in
                
                print(err)
                
                return .empty()
            }
        
        let uploadImages = self.apiType.compressData(imgData: [mainImage])
            .map { $0[0] }
            .flatMapLatest { [unowned self] in
                self.apiType.uploadImages(mainPhoto: $0, videoURL: self.videoURL, user: self.user, recipeID: self.recipeData["id"] as! String)
            }
            .catch { err in
                
                if let reason = err.handleStorageError()  {
                    
                    SCLAlertView().showTitle(
                        reason.reason, // Title of view
                        subTitle: reason.solution,
                        timeout: .none, // String of view
                        completeText: "Done", // Optional button value, default: ""
                        style: .error, // Styles - see below.
                        colorStyle: 0xA429FF,
                        colorTextButton: 0xFFFFFF
                    )
                    
                }
                
                return .empty()
            }
        
        let uploadInstructionsImages = self.apiType.startUpload(instructions: instructions, user: self.user, recipeID: self.recipeData["id"] as! String)
        
        
       
        return Observable.zip(uploadRecipeFieldValues, uploadGenres, uploadImages, uploadInstructionsImages) { [unowned self] _, _, _, index in
            
            currentInstructionUPloadedNum += 1
            
            return self.instructions.count == currentInstructionUPloadedNum
        }
            
        
    }
}

