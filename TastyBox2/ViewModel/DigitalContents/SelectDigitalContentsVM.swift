//
//  SelectDigitalContentsVM.swift
//  TastyBox-2
//
//  Created by 北島　志帆美 on 2022-03-08.
//

import Foundation
import Firebase
import Photos
import RxSwift

enum DigitalContentsFor {
    
    enum RecipeMain {
        case image, video, thumbnail
    }
    
    case profile, recipeMain(RecipeMain), instructionImg
}

protocol SelectDegitalContentDelegate: AnyObject {
    func selectedImage(imageData: Data)
    func selectedImage(asset: PHAsset, kind: DigitalContentsFor, sceneCoordinator: SceneCoordinator)
    func selectedVideo(asset: PHAsset)
}

final class SelectDigitalContentsVM: ViewModelBase {
    
    var assets: PHFetchResult<PHAsset>

    private let sceneCoordinator: SceneCoordinator
    let user: Firebase.User
    var kind: DigitalContentsFor
    var isHiddenSegment: BehaviorSubject<Bool>
    
    weak var delegate: SelectDegitalContentDelegate?
    
    init(sceneCoodinator: SceneCoordinator, user: Firebase.User, kind: DigitalContentsFor, isEnableSelectOnlyOneDigitalContentType: Bool) {
        
        self.assets = PHFetchResult<PHAsset>()
        self.sceneCoordinator = sceneCoodinator
        self.user = user
        self.kind = kind
        self.isHiddenSegment = BehaviorSubject<Bool>(value: isEnableSelectOnlyOneDigitalContentType)
        
        super.init()
 
    }
    
    func fetchContents(kind: DigitalContentsFor) {

        switch kind {
        
        case .profile, .recipeMain(.image), .recipeMain(.thumbnail), .instructionImg:
            
            assets = PHAsset.fetchAssets(with: .image, options: nil)
      
        case .recipeMain(.video):
            
            assets = PHAsset.fetchAssets(with: .video, options: nil)
      
        }
 
    }

    func toSelectImageVC(asset: PHAsset) {
        
        if let delegate = delegate {
            
            self.sceneCoordinator.pop(animated: true) { [weak self] in
                
                guard let strognSelf = self else { return }
                delegate.selectedImage(asset: asset, kind: strognSelf.kind, sceneCoordinator: strognSelf.sceneCoordinator)

            }
            
        
        }
        else {
            
            let vm = SelectedImageVM(sceneCoodinator: self.sceneCoordinator, user: self.user, kind: kind, asset: asset)
            let scene: Scene = .digitalContentsPickerScene(scene: .selectedImage(vm))
            
            self.sceneCoordinator.transition(to: scene, type: .push)
            
        }
      
        
    }
    
    func toSelectVideoVC(asset: PHAsset) {
        
        let vm = SelectedVideoVM(sceneCoodinator: self.sceneCoordinator, user: self.user, asset: asset)
        let scene: Scene = .digitalContentsPickerScene(scene: .selectedVideo(vm))
        
        self.sceneCoordinator.transition(to: scene, type: .push)
        
    }
    
    func userDismissed() {
        
        self.sceneCoordinator.userDismissed()
        
    }
    
  
}

