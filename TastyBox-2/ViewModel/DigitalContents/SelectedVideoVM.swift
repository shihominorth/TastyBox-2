//
//  SelectedVideoVM.swift
//  TastyBox-2
//
//  Created by 北島　志帆美 on 2021-12-15.
//

import Foundation
import Firebase
import Photos
import RxSwift

final class SelectedVideoVM: ViewModelBase {
    
    let sceneCoodinator: SceneCoordinator
    let user: Firebase.User
    let apiType: CreateRecipeDMProtocol.Type
    let asset: PHAsset
    let isHiddenSubject: BehaviorSubject<Bool>
    let isPlayingSubject: BehaviorSubject<Bool>
    
    init(sceneCoodinator: SceneCoordinator, user: Firebase.User, apiType: CreateRecipeDMProtocol.Type = CreateRecipeDM.self, asset: PHAsset) {
        
        self.sceneCoodinator = sceneCoodinator
        self.user = user
        self.apiType = apiType
        self.asset = asset
        self.isHiddenSubject = BehaviorSubject<Bool>(value: true)
        self.isPlayingSubject = BehaviorSubject<Bool>(value: true)
        
        super.init()
        
    }
    
    func getVideoUrl() -> Observable<URL> {
        
        return .create { [unowned self] observer in
            
            let requestOption = PHContentEditingInputRequestOptions()
            requestOption.isNetworkAccessAllowed = true
            
            self.asset.requestContentEditingInput(with: requestOption) { (contentEditingInput: PHContentEditingInput?, _) -> Void in
                
                if let url = (contentEditingInput!.audiovisualAsset as? AVURLAsset)?.url
                {
                    observer.onNext(url)
                }
                else {
                    
                    print("failed")
                    
                }
            }
            
            return Disposables.create()
        }
        
    }
    
    
    func getThumbnail(url: URL) -> Observable<Data> {
        
        return self.apiType.getThumbnailData(url: url)
        
    }
    
    
    func addVideo(data: Data, url: URL) {
        
        let vm = CreateRecipeVM(sceneCoodinator: self.sceneCoodinator, user: self.user, imgData: data, videoUrl: url, kind: .video)
        
        let scene: Scene = .createReceipeScene(scene: .createRecipe(vm))
        
        self.sceneCoodinator.transition(to: scene, type: .push)
           
        
    }
    
}
