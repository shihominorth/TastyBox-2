//
//  SelectDigitalContentsVM.swift
//  TastyBox-2
//
//  Created by 北島　志帆美 on 2021-12-13.
//

import Foundation
import Firebase
import Photos
import RxSwift

enum DigitalContentsFor {
    
    enum RecipeMain {
        case image, video
    }
    
    case profile, recipeMain(RecipeMain), instructionImg
}

protocol SelectDegitalContentDelegate: AnyObject {
    func selectedImage(asset: PHAsset)
    func selectedVideo(asset: URL)
}

class SelectDigitalContentsVM: ViewModelBase {
    
    var assets = PHFetchResult<PHAsset>()

    let sceneCoodinator: SceneCoordinator
    let user: Firebase.User
    var kind: DigitalContentsFor
  
    
    weak var delegate: SelectDegitalContentDelegate?
    
    init(sceneCoodinator: SceneCoordinator, user: Firebase.User, kind: DigitalContentsFor) {
        
        self.sceneCoodinator = sceneCoodinator
        self.user = user
        self.kind = kind

        super.init()
 
    }
    
    func fetchContents(kind: DigitalContentsFor) {

        switch kind {
        
        case .profile, .recipeMain(.image), .instructionImg:
            
            assets = PHAsset.fetchAssets(with: .image, options: nil)
      
        case .recipeMain(.video):
            
            assets = PHAsset.fetchAssets(with: .video, options: nil)
      
        }
 
    }

    
    func toSelectImageVC(asset: PHAsset) {
        
        let vm = SelectedImageVM(sceneCoodinator: self.sceneCoodinator, user: self.user, kind: kind, asset: asset)
        let scene: Scene = .digitalContentsPickerScene(scene: .selectedImage(vm))
        
        self.sceneCoodinator.modalTransition(to: scene, type: .push)
        
    }
    
    func toSelectVideoVC(asset: PHAsset) {
        
        let vm = SelelctedVideoVM(sceneCoodinator: self.sceneCoodinator, user: self.user, asset: asset)
        let scene: Scene = .digitalContentsPickerScene(scene: .selectedVideo(vm))
        
        self.sceneCoodinator.modalTransition(to: scene, type: .push)
        
        
    }
  
}
