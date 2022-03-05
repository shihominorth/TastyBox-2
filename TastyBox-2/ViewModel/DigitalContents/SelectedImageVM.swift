//
//  SelectImageVM.swift
//  TastyBox-2
//
//  Created by 北島　志帆美 on 2021-12-14.
//

import Foundation
import Firebase
import Photos
import RxSwift

final class SelectedImageVM: ViewModelBase {
    
    private let sceneCoodinator: SceneCoordinator
    let user: Firebase.User
    let kind: DigitalContentsFor
    let asset: PHAsset
    let isHiddenSubject: BehaviorSubject<Bool>
    
    weak var delegate: SelectDegitalContentDelegate?
    
    init(sceneCoodinator: SceneCoordinator, user: Firebase.User, kind: DigitalContentsFor, asset: PHAsset) {
        
        self.sceneCoodinator = sceneCoodinator
        self.user = user
        self.kind = kind
        self.asset = asset
        self.isHiddenSubject = BehaviorSubject<Bool>(value: false)
        
        super.init()
        
    }
    
    func getImageData() -> Observable<Data?> {
        
        return .create { [unowned self] observer in
            
            let requestOption = PHContentEditingInputRequestOptions()
            requestOption.isNetworkAccessAllowed = true
            
            self.asset.requestContentEditingInput(with: requestOption) { (contentEditingInput: PHContentEditingInput?, _) -> Void in
                
                let ciImage = CIImage(contentsOf: contentEditingInput!.fullSizeImageURL!)!
                let image = UIImage(ciImage: ciImage.oriented(forExifOrientation: contentEditingInput!.fullSizeImageOrientation))
                
                if let data = image.convertToData() {
                    
                    observer.onNext(data)
                    
                }
                else {
                    
                    observer.onNext(nil)
                    
                }
            }
            
            return Disposables.create()
        }
        
    }
    
    func addImage(imgData: Data) {
        
        switch kind {
            
        case .profile:
            print("profile")
        case .recipeMain(.image):
            
            
            let vm = CreateRecipeVM(sceneCoodinator: self.sceneCoodinator, user: self.user, imgData: imgData, videoUrl: nil, kind: .image)
            let scene: Scene = .createReceipeScene(scene: .createRecipe(vm))
            
            self.sceneCoodinator.transition(to: scene, type: .push)
            
            
        case .recipeMain(.thumbnail):
            
            if let delegate = delegate {
                
                self.sceneCoodinator.pop(animated: true) {
                    
                    delegate.selectedImage(imageData: imgData)
                    
                }
                
            }
            
            
            
        case .instructionImg:
            print("instruction")
            
        default:
            break
        }
        
        
        
    }
    
    
    func cropImage(imageData: Data) -> Observable<Data> {
        
        return self.sceneCoodinator.cropImage(cropMode: .square, imageData: imageData)
        
    }
}


