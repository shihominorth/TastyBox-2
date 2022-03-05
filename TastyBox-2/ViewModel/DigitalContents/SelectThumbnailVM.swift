//
//  SelectThumbnailVM.swift
//  TastyBox-2
//
//  Created by 北島　志帆美 on 2021-12-17.
//

import Foundation
import Firebase
import Photos
import RxSwift

protocol SelectThumbnailDelegate: AnyObject {
    func selectedThumbnail(imageData: Data)
}

final class SelectThumbnailVM: ViewModelBase {
    
    private var sceneCoodinator: SceneCoordinator
    private let apiType: CreateRecipeDMProtocol.Type
    
    let user: Firebase.User
    var imageDataSubject: BehaviorSubject<Data>
    
    weak var delegate: SelectThumbnailDelegate?
    
    init(sceneCoodinator: SceneCoordinator, user: Firebase.User, apiType: CreateRecipeDMProtocol.Type = CreateRecipeDM.self, imageData: Data) {
        
        self.sceneCoodinator = sceneCoodinator
        self.user = user
        self.apiType = apiType
        self.imageDataSubject = BehaviorSubject<Data>(value: imageData)
        
    }
    
    func selectThumbnail() {
        
        let vm = SelectDigitalContentsVM(sceneCoodinator: self.sceneCoodinator, user: self.user, kind: .recipeMain(.thumbnail), isEnableSelectOnlyOneDigitalContentType: true)
        let scene: Scene = .digitalContentsPickerScene(scene: .selectDigitalContents(vm))
        
        vm.delegate = self
        
        self.sceneCoodinator.transition(to: scene, type: .modal(presentationStyle: .fullScreen, modalTransisionStyle: .coverVertical, hasNavigationController: true))
        
        
    }
    
    func selectThumbnail(imageData: Data) {
        
        if let delegate = delegate {
           
            self.sceneCoodinator.pop(animated: true) {
                
                delegate.selectedThumbnail(imageData: imageData)
                
            }
        }
        
    }
    
    func dissmiss() {

        self.sceneCoodinator.pop(animated: true)

    }
    
}

extension SelectThumbnailVM: SelectDegitalContentDelegate {
    
    func selectedVideo(asset: PHAsset) {
        
    }
    
   
    func selectedImage(asset: PHAsset, kind: DigitalContentsFor, sceneCoordinator: SceneCoordinator) {
      
        self.sceneCoodinator = sceneCoordinator
        
        let vm = SelectedImageVM(sceneCoodinator: self.sceneCoodinator, user: self.user, kind: kind, asset: asset)
        let scene: Scene = .digitalContentsPickerScene(scene: .selectedImage(vm))
        
        vm.delegate = self
        
        self.sceneCoodinator.transition(to: scene, type: .modal(presentationStyle: .fullScreen, modalTransisionStyle: .coverVertical, hasNavigationController: false))
    
    }
    
    func selectedImage(imageData: Data) {

        self.imageDataSubject.onNext(imageData)

        
    }

}
