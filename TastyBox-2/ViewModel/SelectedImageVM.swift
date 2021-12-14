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

class SelectedImageVM: ViewModelBase {
   
    let sceneCoodinator: SceneCoordinator
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
    
    func addImage() {
        
        self.delegate?.selectedImage(asset: asset)
        
    }
}


