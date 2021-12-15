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

class SelelctedVideoVM: ViewModelBase {
    
    let sceneCoodinator: SceneCoordinator
    let user: Firebase.User
    let asset: PHAsset
    let isHiddenSubject: BehaviorSubject<Bool>
    
    init(sceneCoodinator: SceneCoordinator, user: Firebase.User, asset: PHAsset) {
        
        self.sceneCoodinator = sceneCoodinator
        self.user = user
        self.asset = asset
        self.isHiddenSubject = BehaviorSubject<Bool>(value: false)

        super.init()
 
    }
    
}
